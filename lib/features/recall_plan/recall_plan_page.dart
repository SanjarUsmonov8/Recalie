import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/recall_plan/effective_recall_plan.dart';
import 'package:recalie/features/recall_plan/subject_text_page.dart';

class RecallPlanPage extends StatelessWidget {
  const RecallPlanPage({
    super.key,
    required this.repository,
    required this.group,
  });

  final LocalRepository repository;
  final SavedPictureGroup group;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<SavedPictureGroup?>(
          stream: repository.watchPictureGroup(group.id),
          initialData: group,
          builder: (context, subjectSnapshot) {
            final subject = subjectSnapshot.data;
            if (subject == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final plan = EffectiveRecallPlan(
              subject.planStartDate,
              type: RecallPlanType.fromStorage(subject.planType),
            );
            return StreamBuilder<List<SavedRecallEvent>>(
              stream: repository.watchRecallEvents(subject.id),
              builder: (context, recallSnapshot) {
                final recalls =
                    recallSnapshot.data ?? const <SavedRecallEvent>[];
                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
                  children: [
                    _PlanHeader(
                      name: subject.name,
                      onEdit: () => _editMemorySet(context, subject),
                      onDelete: () => _deleteSubject(context, subject),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'What you are recalling',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SubjectTextCard(subject: subject, repository: repository),
                    const SizedBox(height: 12),
                    _MemoryImages(
                      images: subject.images,
                      onAddPictures: () => _addPictures(context, subject),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      '${plan.type.label} plan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _EffectiveCalendar(
                      plan: plan,
                      recalls: recalls,
                      onRecall: (date) =>
                          _confirmRecall(context, date, plan, subject),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmRecall(
    BuildContext context,
    DateTime date,
    EffectiveRecallPlan plan,
    SavedPictureGroup subject,
  ) async {
    final requirement = plan.requirementFor(date);
    if (requirement == null ||
        dateOnly(date).isAfter(dateOnly(DateTime.now()))) {
      return;
    }
    final shouldRecord = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as recalled?'),
        content: Text(
          'Confirm that you recalled “${subject.name}” on ${_longDate(date)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('I recalled it'),
          ),
        ],
      ),
    );
    if (shouldRecord != true) return;
    final now = DateTime.now();
    await repository.recordRecall(
      subject.id,
      DateTime(
        date.year,
        date.month,
        date.day,
        now.hour,
        now.minute,
        now.second,
      ),
    );
  }

  Future<void> _editMemorySet(
    BuildContext context,
    SavedPictureGroup subject,
  ) async {
    final controller = TextEditingController(text: subject.name);
    var selectedType = RecallPlanType.fromStorage(subject.planType);
    var selectedStartDate = dateOnly(subject.planStartDate);
    final update = await showModalBottomSheet<_MemorySetPlanUpdate>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            0,
            22,
            MediaQuery.viewInsetsOf(context).bottom + 22,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit memory set',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Memory set name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<RecallPlanType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Recall plan',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final type in RecallPlanType.values)
                      DropdownMenuItem(
                        value: type,
                        child: Text('${type.label} plan'),
                      ),
                  ],
                  onChanged: (type) {
                    if (type != null) {
                      setSheetState(() => selectedType = type);
                    }
                  },
                ),
                const SizedBox(height: 14),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month_rounded),
                    title: const Text('Plan start date'),
                    subtitle: Text(_longDate(selectedStartDate)),
                    trailing: const Icon(Icons.edit_calendar_rounded),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedStartDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(DateTime.now().year + 20, 12, 31),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedStartDate = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      _MemorySetPlanUpdate(
                        name: controller.text,
                        type: selectedType,
                        startDate: selectedStartDate,
                      ),
                    ),
                    child: const Text('Save memory set'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    controller.dispose();
    if (update == null || update.name.trim().isEmpty) return;
    await repository.updateMemorySetPlan(
      pictureGroupId: subject.id,
      name: update.name,
      planType: update.type.storageValue,
      planStartDate: update.startDate,
    );
  }

  Future<void> _deleteSubject(
    BuildContext context,
    SavedPictureGroup subject,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete memory set permanently?'),
        content: Text(
          '“${subject.name}”, its text, pictures, plan, and recall history will be permanently deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await repository.deleteSubject(subject.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _addPictures(
    BuildContext context,
    SavedPictureGroup subject,
  ) async {
    final files = await ImagePicker().pickMultiImage(
      imageQuality: 85,
      maxWidth: 2048,
    );
    if (files.isEmpty) return;
    final images = <Uint8List>[];
    for (final file in files) {
      images.add(await file.readAsBytes());
    }
    await repository.addSubjectPictures(subject.id, images);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${images.length} ${images.length == 1 ? 'picture was' : 'pictures were'} added.',
          ),
        ),
      );
    }
  }
}

class _MemorySetPlanUpdate {
  const _MemorySetPlanUpdate({
    required this.name,
    required this.type,
    required this.startDate,
  });

  final String name;
  final RecallPlanType type;
  final DateTime startDate;
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({
    required this.name,
    required this.onEdit,
    required this.onDelete,
  });

  final String name;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        IconButton(
          key: const Key('editSubjectButton'),
          tooltip: 'Edit memory set',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_rounded),
        ),
        IconButton(
          key: const Key('deleteSubjectButton'),
          tooltip: 'Delete memory set',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    );
  }
}

class _SubjectTextCard extends StatelessWidget {
  const _SubjectTextCard({required this.subject, required this.repository});

  final SavedPictureGroup subject;
  final LocalRepository repository;

  @override
  Widget build(BuildContext context) {
    final text = subject.textContent?.trim();
    final hasText = text?.isNotEmpty ?? false;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('subjectTextCard'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SubjectTextPage(
              repository: repository,
              subject: subject,
              startEditing: !hasText,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                hasText ? Icons.notes_rounded : Icons.note_add_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasText ? text! : 'Add text to this memory set',
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.45),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _EffectiveCalendar extends StatefulWidget {
  const _EffectiveCalendar({
    required this.plan,
    required this.recalls,
    required this.onRecall,
  });

  final EffectiveRecallPlan plan;
  final List<SavedRecallEvent> recalls;
  final ValueChanged<DateTime> onRecall;

  @override
  State<_EffectiveCalendar> createState() => _EffectiveCalendarState();
}

class _EffectiveCalendarState extends State<_EffectiveCalendar> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(
      widget.plan.startDate.year,
      widget.plan.startDate.month,
    );
  }

  int _recallCount(RecallRequirement requirement) {
    return widget.recalls
        .where((event) => requirement.contains(event.recalledAt))
        .length;
  }

  void _changeMonth(int difference) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + difference,
      );
    });
  }

  List<DateTime> get _visibleWeeks {
    final firstWeek = mondayOf(_visibleMonth);
    final lastDay = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0);
    final lastWeek = mondayOf(lastDay);
    return [
      for (
        var week = firstWeek;
        !week.isAfter(lastWeek);
        week = week.add(const Duration(days: 7))
      )
        week,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  key: const Key('previousRecallMonth'),
                  tooltip: 'Previous month',
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    _monthLabel(_visibleMonth),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('nextRecallMonth'),
                  tooltip: 'Next month',
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 38),
                for (final day in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                  Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < _visibleWeeks.length; index++) ...[
              _CalendarWeekRow(
                weekStart: _visibleWeeks[index],
                displayedMonth: _visibleMonth,
                plan: widget.plan,
                recallCount: _recallCount,
                onRecall: widget.onRecall,
              ),
              if (index != _visibleWeeks.length - 1) const SizedBox(height: 7),
            ],
          ],
        ),
      ),
    );
  }
}

class _CalendarWeekRow extends StatelessWidget {
  const _CalendarWeekRow({
    required this.weekStart,
    required this.displayedMonth,
    required this.plan,
    required this.recallCount,
    required this.onRecall,
  });

  final DateTime weekStart;
  final DateTime displayedMonth;
  final EffectiveRecallPlan plan;
  final int Function(RecallRequirement requirement) recallCount;
  final ValueChanged<DateTime> onRecall;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final mandatoryWeek = plan.isMandatoryWeek(weekStart);
    final weeklyRequirement = mandatoryWeek
        ? plan.requirementFor(weekStart)
        : null;
    final weeklyComplete =
        weeklyRequirement != null &&
        recallCount(weeklyRequirement) >= weeklyRequirement.targetRecalls;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: mandatoryWeek
                ? (weeklyComplete ? const Color(0xFF22C55E) : colors.primary)
                : colors.surfaceContainerHighest,
          ),
          child: Text(
            '${isoWeekNumber(weekStart)}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: mandatoryWeek ? Colors.white : colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: mandatoryWeek
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color:
                        (weeklyComplete
                                ? const Color(0xFF22C55E)
                                : colors.primary)
                            .withValues(alpha: 0.20),
                  )
                : null,
            child: Row(
              children: [
                for (var dayIndex = 0; dayIndex < 7; dayIndex++)
                  Expanded(child: _dayForIndex(dayIndex)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dayForIndex(int dayIndex) {
    final date = weekStart.add(Duration(days: dayIndex));
    final outsideDisplayedMonth =
        date.month != displayedMonth.month || date.year != displayedMonth.year;
    return Opacity(
      opacity: outsideDisplayedMonth ? 0.42 : 1,
      child: _CalendarDay(
        date: date,
        requirement: plan.requirementFor(date),
        recallCount: recallCount,
        mandatoryWeek: plan.isMandatoryWeek(weekStart),
        weeklyComplete: _weeklyComplete,
        onTap: onRecall,
      ),
    );
  }

  bool get _weeklyComplete {
    final requirement = plan.isMandatoryWeek(weekStart)
        ? plan.requirementFor(weekStart)
        : null;
    return requirement != null &&
        recallCount(requirement) >= requirement.targetRecalls;
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.requirement,
    required this.recallCount,
    required this.mandatoryWeek,
    required this.weeklyComplete,
    required this.onTap,
  });

  final DateTime date;
  final RecallRequirement? requirement;
  final int Function(RecallRequirement requirement) recallCount;
  final bool mandatoryWeek;
  final bool weeklyComplete;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final today = dateOnly(DateTime.now());
    final isFuture = dateOnly(date).isAfter(today);
    final count = requirement == null ? 0 : recallCount(requirement!);
    final complete = requirement != null && count >= requirement!.targetRecalls;
    final missed =
        requirement != null && !complete && dateOnly(date).isBefore(today);
    final isExact = requirement != null && !requirement!.isFlexibleWeek;

    Color? background;
    Color foreground = colors.onSurfaceVariant;
    if (isExact) {
      background = complete
          ? const Color(0xFF22C55E)
          : missed
          ? const Color(0xFFEF4444)
          : colors.primary;
      foreground = Colors.white;
    } else if (mandatoryWeek) {
      foreground = weeklyComplete ? const Color(0xFF15803D) : colors.primary;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: requirement != null && !isFuture && !complete
          ? () => onTap(date)
          : null,
      child: SizedBox(
        height: 34,
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: background,
            ),
            child: complete && isExact
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 17)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      if (isExact && requirement!.targetRecalls > 1)
                        Text(
                          '$count/${requirement!.targetRecalls}',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 7,
                            height: 1,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _MemoryImages extends StatelessWidget {
  const _MemoryImages({required this.images, required this.onAddPictures});

  final List<Uint8List> images;
  final VoidCallback onAddPictures;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        if (index == images.length) {
          return Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: const Key('addSubjectPicturesButton'),
              onTap: onAddPictures,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 38,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add pictures'),
                ],
              ),
            ),
          );
        }
        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  _MemoryImageViewer(images: images, initialIndex: index),
            ),
          ),
          borderRadius: BorderRadius.circular(18),
          child: Hero(
            tag: 'memory-image-$index-${images[index].length}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.memory(images[index], fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }
}

class _MemoryImageViewer extends StatefulWidget {
  const _MemoryImageViewer({required this.images, required this.initialIndex});

  final List<Uint8List> images;
  final int initialIndex;

  @override
  State<_MemoryImageViewer> createState() => _MemoryImageViewerState();
}

class _MemoryImageViewerState extends State<_MemoryImageViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        itemBuilder: (context, index) => InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: Center(
            child: Hero(
              tag: 'memory-image-$index-${widget.images[index].length}',
              child: Image.memory(widget.images[index], fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

String _longDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _monthLabel(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}
