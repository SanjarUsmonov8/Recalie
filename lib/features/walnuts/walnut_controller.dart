import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/recall_plan/effective_recall_plan.dart';
import 'package:recalie/features/walnuts/walnut_models.dart';

class WalnutController extends ChangeNotifier {
  WalnutController(this._repository, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const _balanceKey = 'walnut_balance';
  static const _ledgerKey = 'walnut_award_ledger';

  final LocalRepository _repository;
  final DateTime Function() _now;
  final Set<String> _awardLedger = <String>{};
  StreamSubscription<List<SavedPictureGroup>>? _groupsSubscription;
  StreamSubscription<List<SavedRecallEvent>>? _recallsSubscription;
  List<SavedPictureGroup>? _groups;
  List<SavedRecallEvent>? _recalls;
  Timer? _evaluationTimer;
  bool _evaluating = false;
  bool _evaluateAgain = false;
  bool _loaded = false;
  bool _disposed = false;
  int _balance = 0;

  int get balance => _balance;
  bool get isLoaded => _loaded;
  WalnutStage get stage => WalnutStage.forBalance(_balance);

  Future<void> load() async {
    _balance =
        int.tryParse(await _repository.readPreference(_balanceKey) ?? '') ?? 0;
    final savedLedger = await _repository.readPreference(_ledgerKey);
    if (_disposed) return;
    if (savedLedger != null) {
      try {
        final decoded = jsonDecode(savedLedger);
        if (decoded is List) {
          _awardLedger.addAll(decoded.whereType<String>());
        }
      } on FormatException {
        // A damaged reward ledger must not prevent the app from opening.
      }
    }
    _loaded = true;
    notifyListeners();
    _groupsSubscription = _repository.watchPictureGroups().listen((groups) {
      _groups = groups;
      _scheduleEvaluation();
    });
    _recallsSubscription = _repository.watchAllRecallEvents().listen((recalls) {
      _recalls = recalls;
      _scheduleEvaluation();
    });
  }

  Future<bool> spend(int amount) async {
    if (amount <= 0 || _balance < amount) return false;
    _balance -= amount;
    await _repository.savePreference(_balanceKey, '$_balance');
    notifyListeners();
    return true;
  }

  void _scheduleEvaluation() {
    _evaluationTimer?.cancel();
    _evaluationTimer = Timer(
      const Duration(milliseconds: 80),
      _evaluateAvailableWeeks,
    );
  }

  Future<void> _evaluateAvailableWeeks() async {
    final groups = _groups;
    final recalls = _recalls;
    if (!_loaded || groups == null || recalls == null || groups.isEmpty) return;
    if (_evaluating) {
      _evaluateAgain = true;
      return;
    }
    _evaluating = true;
    try {
      final grants = calculateWalnutRewards(
        groups: groups,
        recalls: recalls,
        now: _now(),
        existingLedger: _awardLedger,
      );
      if (grants.isEmpty) return;
      for (final grant in grants) {
        final rewardStage = WalnutStage.forBalance(_balance);
        _balance += switch (grant.kind) {
          WalnutRewardKind.perfectWeek => rewardStage.perfectWeekReward,
          WalnutRewardKind.oneMissedDay => rewardStage.oneMissedDayReward,
          WalnutRewardKind.setWeek => rewardStage.setWeekReward,
        };
        _awardLedger.add(grant.ledgerId);
      }
      await _repository.savePreference(_balanceKey, '$_balance');
      await _repository.savePreference(
        _ledgerKey,
        jsonEncode(_awardLedger.toList()..sort()),
      );
      notifyListeners();
    } finally {
      _evaluating = false;
      if (_evaluateAgain) {
        _evaluateAgain = false;
        _scheduleEvaluation();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _evaluationTimer?.cancel();
    _groupsSubscription?.cancel();
    _recallsSubscription?.cancel();
    super.dispose();
  }
}

List<WalnutRewardGrant> calculateWalnutRewards({
  required List<SavedPictureGroup> groups,
  required List<SavedRecallEvent> recalls,
  required DateTime now,
  Set<String> existingLedger = const <String>{},
}) {
  if (groups.isEmpty) return const [];
  final today = dateOnly(now);
  final currentWeek = mondayOf(today);
  final firstPlanDate = groups
      .map((group) => dateOnly(group.planStartDate))
      .reduce((left, right) => left.isBefore(right) ? left : right);
  final firstWeek = mondayOf(firstPlanDate);
  final grants = <WalnutRewardGrant>[];

  for (
    var week = firstWeek;
    week.isBefore(currentWeek);
    week = week.add(const Duration(days: 7))
  ) {
    final weekKey = _dateKey(week);
    final allObligations = <_WeeklyObligation>[];
    final obligationsBySet = <int, List<_WeeklyObligation>>{};

    for (final group in groups) {
      final plan = EffectiveRecallPlan(
        group.planStartDate,
        type: RecallPlanType.fromStorage(group.planType),
      );
      final obligations = plan.requirements
          .where((requirement) => sameDate(mondayOf(requirement.start), week))
          .map(
            (requirement) => _WeeklyObligation(
              requirement: requirement,
              completed:
                  recalls
                      .where(
                        (event) =>
                            event.pictureGroupId == group.id &&
                            requirement.contains(event.recalledAt),
                      )
                      .length >=
                  requirement.targetRecalls,
            ),
          )
          .toList();
      if (obligations.isEmpty) continue;
      obligationsBySet[group.id] = obligations;
      allObligations.addAll(obligations);
    }

    if (allObligations.isEmpty) continue;
    final missed = allObligations.where((item) => !item.completed).length;
    final globalKind = missed == 0
        ? WalnutRewardKind.perfectWeek
        : missed == 1
        ? WalnutRewardKind.oneMissedDay
        : null;
    if (globalKind != null) {
      final ledgerId = 'global:${globalKind.name}:$weekKey';
      if (!existingLedger.contains(ledgerId)) {
        grants.add(WalnutRewardGrant(ledgerId: ledgerId, kind: globalKind));
      }
    }

    for (final entry in obligationsBySet.entries) {
      if (!entry.value.every((item) => item.completed)) continue;
      final ledgerId = 'set:${entry.key}:$weekKey';
      if (!existingLedger.contains(ledgerId)) {
        grants.add(
          WalnutRewardGrant(ledgerId: ledgerId, kind: WalnutRewardKind.setWeek),
        );
      }
    }
  }
  return grants;
}

class _WeeklyObligation {
  const _WeeklyObligation({required this.requirement, required this.completed});

  final RecallRequirement requirement;
  final bool completed;
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

class WalnutScope extends InheritedNotifier<WalnutController> {
  const WalnutScope({
    super.key,
    required WalnutController controller,
    required super.child,
  }) : super(notifier: controller);

  static WalnutController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WalnutScope>();
    assert(scope != null, 'WalnutScope is missing above this context.');
    return scope!.notifier!;
  }
}
