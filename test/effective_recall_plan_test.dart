import 'package:flutter_test/flutter_test.dart';
import 'package:recalie/features/recall_plan/effective_recall_plan.dart';

void main() {
  test('Most effective plan follows its daily and weekly gaps', () {
    final plan = EffectiveRecallPlan(
      DateTime(2026, 10, 5),
      type: RecallPlanType.mostEffective,
    );
    final exact = plan.requirements
        .where((item) => !item.isFlexibleWeek)
        .toList();
    final weekly = plan.requirements
        .where((item) => item.isFlexibleWeek)
        .toList();

    expect(
      exact.map((item) => item.start.difference(plan.startDate).inDays),
      EffectiveRecallPlan.mostEffectiveDailyOffsets,
    );
    expect(exact.first.targetRecalls, 2);
    expect(exact.skip(1).every((item) => item.targetRecalls == 1), isTrue);

    final firstWeekly = weekly.first.start;
    expect(
      weekly.map((item) => item.start.difference(firstWeekly).inDays ~/ 7),
      EffectiveRecallPlan.mostEffectiveMandatoryWeekOffsets,
    );
    expect(
      weekly.every((item) => item.end.difference(item.start).inDays == 6),
      isTrue,
    );
  });

  test('Effective plan uses the balanced daily and weekly gaps', () {
    final plan = EffectiveRecallPlan(
      DateTime(2026, 10, 5),
      type: RecallPlanType.effective,
    );
    final exact = plan.requirements
        .where((item) => !item.isFlexibleWeek)
        .toList();
    final weekly = plan.requirements
        .where((item) => item.isFlexibleWeek)
        .toList();

    expect(
      exact.map((item) => item.start.difference(plan.startDate).inDays),
      EffectiveRecallPlan.effectiveDailyOffsets,
    );
    expect(exact.first.targetRecalls, 2);
    expect(exact.skip(1).every((item) => item.targetRecalls == 1), isTrue);

    final firstWeekly = weekly.first.start;
    expect(
      weekly.map((item) => item.start.difference(firstWeekly).inDays ~/ 7),
      [0, 2, 5, 8, 12, 17],
    );
  });

  test('Fast plan concentrates recalls into a shorter schedule', () {
    final plan = EffectiveRecallPlan(
      DateTime(2026, 10, 5),
      type: RecallPlanType.fast,
    );
    final exact = plan.requirements
        .where((item) => !item.isFlexibleWeek)
        .toList();
    final weekly = plan.requirements
        .where((item) => item.isFlexibleWeek)
        .toList();

    expect(
      exact.map((item) => item.start.difference(plan.startDate).inDays),
      EffectiveRecallPlan.fastDailyOffsets,
    );
    expect(exact.map((item) => item.targetRecalls), [
      3,
      2,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
    ]);

    final firstWeekly = weekly.first.start;
    expect(
      weekly.map((item) => item.start.difference(firstWeekly).inDays ~/ 7),
      EffectiveRecallPlan.fastMandatoryWeekOffsets,
    );
  });

  test('calendar uses universal ISO week numbers across year boundaries', () {
    expect(isoWeekNumber(DateTime(2026, 1, 1)), 1);
    expect(isoWeekNumber(DateTime(2026, 12, 31)), 53);
    expect(isoWeekNumber(DateTime(2027, 1, 1)), 53);
    expect(isoWeekNumber(DateTime(2027, 1, 4)), 1);
  });
}
