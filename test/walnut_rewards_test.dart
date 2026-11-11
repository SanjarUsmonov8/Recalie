import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/recall_plan/effective_recall_plan.dart';
import 'package:recalie/features/walnuts/walnut_controller.dart';
import 'package:recalie/features/walnuts/walnut_models.dart';

void main() {
  test('walnut stages use the requested cumulative boundaries', () {
    expect(WalnutStage.forBalance(0), WalnutStage.walnut1);
    expect(WalnutStage.forBalance(200), WalnutStage.walnut1);
    expect(WalnutStage.forBalance(201), WalnutStage.walnut15);
    expect(WalnutStage.forBalance(500), WalnutStage.walnut15);
    expect(WalnutStage.forBalance(501), WalnutStage.walnut2);
    expect(WalnutStage.forBalance(1001), WalnutStage.walnut25);
    expect(WalnutStage.forBalance(2001), WalnutStage.walnut3);
    expect(WalnutStage.walnut15.progressFor(350), closeTo(0.5, 0.001));
  });

  test('a completed set week grants both perfect and set rewards once', () {
    final group = _group(start: DateTime(2026, 10, 5));
    final plan = EffectiveRecallPlan(
      group.planStartDate,
      type: RecallPlanType.fast,
    );
    final recalls = <SavedRecallEvent>[];
    var id = 1;
    for (final requirement in plan.requirements.where(
      (requirement) =>
          sameDate(mondayOf(requirement.start), DateTime(2026, 10, 5)),
    )) {
      for (var count = 0; count < requirement.targetRecalls; count++) {
        recalls.add(
          SavedRecallEvent(
            id: id++,
            pictureGroupId: group.id,
            recalledAt: requirement.start.add(Duration(hours: count + 1)),
          ),
        );
      }
    }

    final grants = calculateWalnutRewards(
      groups: [group],
      recalls: recalls,
      now: DateTime(2026, 10, 12),
    );
    expect(
      grants.map((grant) => grant.kind),
      containsAll([WalnutRewardKind.perfectWeek, WalnutRewardKind.setWeek]),
    );

    final repeated = calculateWalnutRewards(
      groups: [group],
      recalls: recalls,
      now: DateTime(2026, 10, 12),
      existingLedger: grants.map((grant) => grant.ledgerId).toSet(),
    );
    expect(repeated, isEmpty);
  });

  test('exactly one missed requirement grants the one-missed reward', () {
    final group = _group(start: DateTime(2026, 10, 5));
    final plan = EffectiveRecallPlan(
      group.planStartDate,
      type: RecallPlanType.fast,
    );
    final weekRequirements = plan.requirements
        .where(
          (requirement) =>
              sameDate(mondayOf(requirement.start), DateTime(2026, 10, 5)),
        )
        .toList();
    final recalls = <SavedRecallEvent>[];
    var id = 1;
    for (final requirement in weekRequirements.skip(1)) {
      for (var count = 0; count < requirement.targetRecalls; count++) {
        recalls.add(
          SavedRecallEvent(
            id: id++,
            pictureGroupId: group.id,
            recalledAt: requirement.start.add(Duration(hours: count + 1)),
          ),
        );
      }
    }

    final grants = calculateWalnutRewards(
      groups: [group],
      recalls: recalls,
      now: DateTime(2026, 10, 12),
    );
    expect(grants, hasLength(1));
    expect(grants.single.kind, WalnutRewardKind.oneMissedDay);
  });
}

SavedPictureGroup _group({required DateTime start}) => SavedPictureGroup(
  id: 7,
  setNumber: 1,
  name: 'Biology',
  textContent: 'Cells',
  planType: RecallPlanType.fast.storageValue,
  planStartDate: start,
  coverIcon: null,
  coverColorStart: null,
  coverColorEnd: null,
  coverImageUrl: null,
  pictures: [
    SavedPicture(
      id: 1,
      bytes: Uint8List.fromList([1]),
      position: 1,
      isReviewed: false,
    ),
  ],
  attachments: const [],
);
