import 'package:flutter/widgets.dart';

enum RecalieMembershipPlan { free, plus, pro }

extension RecalieMembershipPlanRules on RecalieMembershipPlan {
  String get storageValue => name;

  String get displayName => switch (this) {
    RecalieMembershipPlan.free => 'Free',
    RecalieMembershipPlan.plus => 'Plus',
    RecalieMembershipPlan.pro => 'Pro',
  };

  bool get showsAds => this != RecalieMembershipPlan.pro;
  bool get canAccessDiscover => this != RecalieMembershipPlan.free;
  bool get supportsAllItemTypes => this != RecalieMembershipPlan.free;
  int? get memorySetLimit => this == RecalieMembershipPlan.free ? 4 : null;

  static RecalieMembershipPlan fromStorage(String? value) =>
      RecalieMembershipPlan.values.firstWhere(
        (plan) => plan.storageValue == value,
        orElse: () => RecalieMembershipPlan.free,
      );
}

class RecaliePlanScope extends InheritedWidget {
  const RecaliePlanScope({
    super.key,
    required this.plan,
    required this.expiresAt,
    required this.onPlanChanged,
    required super.child,
  });

  final RecalieMembershipPlan plan;
  final DateTime? expiresAt;
  final Future<void> Function(RecalieMembershipPlan plan) onPlanChanged;

  static RecaliePlanScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<RecaliePlanScope>();
    assert(scope != null, 'RecaliePlanScope is missing above this context.');
    return scope!;
  }

  static RecaliePlanScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RecaliePlanScope>();

  @override
  bool updateShouldNotify(RecaliePlanScope oldWidget) =>
      plan != oldWidget.plan || expiresAt != oldWidget.expiresAt;
}
