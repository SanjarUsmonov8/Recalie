class RecallRequirement {
  const RecallRequirement.exact({
    required this.start,
    required this.targetRecalls,
  }) : isFlexibleWeek = false;

  const RecallRequirement.flexibleWeek({required this.start})
    : targetRecalls = 1,
      isFlexibleWeek = true;

  final DateTime start;
  final int targetRecalls;
  final bool isFlexibleWeek;

  DateTime get end =>
      isFlexibleWeek ? start.add(const Duration(days: 6)) : start;

  bool contains(DateTime date) {
    final value = dateOnly(date);
    return !value.isBefore(start) && !value.isAfter(end);
  }
}

enum RecallPlanType {
  mostEffective('most_effective', 'Most effective'),
  effective('effective', 'Effective'),
  fast('fast', 'Fast');

  const RecallPlanType(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static RecallPlanType fromStorage(String value) {
    return RecallPlanType.values.firstWhere(
      (type) => type.storageValue == value,
      orElse: () => RecallPlanType.mostEffective,
    );
  }
}

class EffectiveRecallPlan {
  EffectiveRecallPlan(
    DateTime startDate, {
    this.type = RecallPlanType.mostEffective,
  }) : startDate = dateOnly(startDate) {
    requirements = _buildRequirements(this.startDate);
  }

  final DateTime startDate;
  final RecallPlanType type;
  late final List<RecallRequirement> requirements;

  static const mostEffectiveDailyOffsets = <int>[0, 1, 2, 4, 6, 8, 11, 14, 18];
  static const effectiveDailyOffsets = <int>[0, 1, 2, 4, 7, 11];
  static const fastDailyOffsets = <int>[0, 1, 2, 4, 6, 8, 11, 14, 18];

  // The first two weekly recalls are consecutive. Each later number is the
  // count of calendar weeks from the first mandatory weekly recall.
  static const mostEffectiveMandatoryWeekOffsets = <int>[
    0,
    1,
    3,
    6,
    9,
    12,
    16,
    20,
    25,
  ];
  static const effectiveMandatoryWeekOffsets = <int>[0, 2, 5, 8, 12, 17];
  static const fastMandatoryWeekOffsets = <int>[0, 2, 5, 9];

  List<int> get dailyOffsets => switch (type) {
    RecallPlanType.mostEffective => mostEffectiveDailyOffsets,
    RecallPlanType.effective => effectiveDailyOffsets,
    RecallPlanType.fast => fastDailyOffsets,
  };

  List<int> get mandatoryWeekOffsets => switch (type) {
    RecallPlanType.mostEffective => mostEffectiveMandatoryWeekOffsets,
    RecallPlanType.effective => effectiveMandatoryWeekOffsets,
    RecallPlanType.fast => fastMandatoryWeekOffsets,
  };

  int targetRecallsForOffset(int offset) => switch (type) {
    RecallPlanType.fast when offset == 0 => 3,
    RecallPlanType.fast when offset == 1 => 2,
    RecallPlanType.mostEffective ||
    RecallPlanType.effective when offset == 0 => 2,
    _ => 1,
  };

  List<RecallRequirement> _buildRequirements(DateTime startDate) {
    final exact = <RecallRequirement>[
      for (final offset in dailyOffsets)
        RecallRequirement.exact(
          start: startDate.add(Duration(days: offset)),
          targetRecalls: targetRecallsForOffset(offset),
        ),
    ];

    final lastExact = exact.last.start;
    final firstWeeklyMonday = mondayOf(lastExact).add(const Duration(days: 7));
    final weekly = <RecallRequirement>[
      for (final offset in mandatoryWeekOffsets)
        RecallRequirement.flexibleWeek(
          start: firstWeeklyMonday.add(Duration(days: offset * 7)),
        ),
    ];
    return [...exact, ...weekly];
  }

  RecallRequirement? requirementFor(DateTime date) {
    for (final requirement in requirements) {
      if (requirement.contains(date)) return requirement;
    }
    return null;
  }

  bool isMandatoryWeek(DateTime weekStart) {
    final monday = mondayOf(weekStart);
    return requirements.any(
      (requirement) =>
          requirement.isFlexibleWeek && sameDate(requirement.start, monday),
    );
  }

  List<DateTime> get calendarWeeks {
    final first = mondayOf(startDate);
    final last = mondayOf(requirements.last.end);
    final weeks = <DateTime>[];
    for (
      var current = first;
      !current.isAfter(last);
      current = current.add(const Duration(days: 7))
    ) {
      weeks.add(current);
    }
    return weeks;
  }
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime mondayOf(DateTime value) {
  final date = dateOnly(value);
  return date.subtract(Duration(days: date.weekday - DateTime.monday));
}

bool sameDate(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

int isoWeekNumber(DateTime value) {
  final date = dateOnly(value);
  final thursday = date.add(Duration(days: DateTime.thursday - date.weekday));
  final firstWeekMonday = mondayOf(DateTime(thursday.year, 1, 4));
  return mondayOf(thursday).difference(firstWeekMonday).inDays ~/ 7 + 1;
}
