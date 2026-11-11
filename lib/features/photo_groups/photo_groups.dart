import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/ads/recalie_native_ad.dart';
import 'package:recalie/features/ads/rewarded_access_gate.dart';
import 'package:recalie/features/photo_groups/memory_set_style.dart';
import 'package:recalie/features/photo_groups/memory_set_groups.dart';
import 'package:recalie/features/photo_groups/set_group_assignment.dart';
import 'package:recalie/features/recall_plan/effective_recall_plan.dart';
import 'package:recalie/features/recall_plan/recall_plan_page.dart';

Future<void> showAddPictureGroupSheet(
  BuildContext context,
  LocalRepository repository,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _AddPictureGroupSheet(repository: repository),
  );
}

class PictureGroupsSection extends StatelessWidget {
  const PictureGroupsSection({super.key, required this.repository});

  final LocalRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SavedPictureGroup>>(
      stream: repository.watchPictureGroups(),
      builder: (context, snapshot) {
        final groups = snapshot.data ?? const <SavedPictureGroup>[];
        if (groups.isEmpty) return const SizedBox.shrink();
        final ungroupedSets = groups
            .where((group) => group.memorySetGroupId == null)
            .toList();
        return StreamBuilder<List<SavedRecallEvent>>(
          stream: repository.watchAllRecallEvents(),
          builder: (context, recallSnapshot) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _RecallOverviewCalendar(
                repository: repository,
                groups: groups,
                recalls: recallSnapshot.data ?? const [],
              ),
              const RecalieNativeAdCard(
                margin: EdgeInsets.symmetric(vertical: 24),
              ),
              MemorySetGroupsSection(repository: repository),
              if (ungroupedSets.isNotEmpty) ...[
                Text(
                  'Your memory sets',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 174 / 210,
                  ),
                  itemCount: ungroupedSets.length,
                  itemBuilder: (context, index) => _PictureGroupCard(
                    repository: repository,
                    group: ungroupedSets[index],
                  ),
                ),
              ],
              const RecalieNativeAdCard(margin: EdgeInsets.only(top: 24)),
            ],
          ),
        );
      },
    );
  }
}

class _RecallOverviewCalendar extends StatefulWidget {
  const _RecallOverviewCalendar({
    required this.repository,
    required this.groups,
    required this.recalls,
  });

  final LocalRepository repository;
  final List<SavedPictureGroup> groups;
  final List<SavedRecallEvent> recalls;

  @override
  State<_RecallOverviewCalendar> createState() =>
      _RecallOverviewCalendarState();
}

class _RecallOverviewCalendarState extends State<_RecallOverviewCalendar> {
  late DateTime _visibleMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  late DateTime _selectedDate = dateOnly(DateTime.now());

  List<_DueMemorySet> _dueSets(DateTime date) {
    final result = <_DueMemorySet>[];
    for (final group in widget.groups) {
      final plan = EffectiveRecallPlan(
        group.planStartDate,
        type: RecallPlanType.fromStorage(group.planType),
      );
      final requirement = plan.requirementFor(date);
      if (requirement == null) continue;
      final recalled = widget.recalls
          .where(
            (event) =>
                event.pictureGroupId == group.id &&
                requirement.contains(event.recalledAt),
          )
          .length;
      result.add(
        _DueMemorySet(
          group: group,
          completed: recalled >= requirement.targetRecalls,
        ),
      );
    }
    return result;
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
      _selectedDate = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final first = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final last = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0);
    final gridStart = mondayOf(first);
    final gridEnd = mondayOf(last).add(const Duration(days: 6));
    final dates = List.generate(
      gridEnd.difference(gridStart).inDays + 1,
      (index) => gridStart.add(Duration(days: index)),
    );
    final selectedSets = _dueSets(_selectedDate);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Previous month',
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    _monthYearLabel(_visibleMonth),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Next month',
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final day in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                  Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dates.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.86,
                crossAxisSpacing: 2,
                mainAxisSpacing: 3,
              ),
              itemBuilder: (context, index) {
                final date = dates[index];
                final due = _dueSets(date);
                final completed = due.where((item) => item.completed).length;
                final allComplete = due.isNotEmpty && completed == due.length;
                final selected = sameDate(date, _selectedDate);
                final outsideMonth = date.month != _visibleMonth.month;
                return Opacity(
                  opacity: outsideMonth ? 0.42 : 1,
                  child: InkWell(
                    onTap: () => setState(() => _selectedDate = dateOnly(date)),
                    customBorder: const CircleBorder(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: due.isEmpty
                            ? Colors.transparent
                            : colors.primary,
                        border: selected
                            ? Border.all(color: colors.onSurface, width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: allComplete ? 0.24 : 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: due.isEmpty
                                        ? colors.onSurface
                                        : colors.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (due.isNotEmpty)
                                  Text(
                                    '$completed/${due.length}',
                                    style: TextStyle(
                                      color: colors.onPrimary,
                                      fontSize: 9,
                                      height: 1,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (allComplete)
                            Icon(
                              Icons.check_rounded,
                              color: colors.onPrimary,
                              size: 31,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (selectedSets.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Sets to recall',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              for (final due in selectedSets)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _NumberCircle(label: '${due.group.setNumber}'),
                  title: Text(
                    due.group.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      decoration: due.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationThickness: 2,
                    ),
                  ),
                  trailing: due.completed
                      ? Icon(Icons.check_circle_rounded, color: colors.primary)
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openMemorySet(
                    context,
                    repository: widget.repository,
                    group: due.group,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DueMemorySet {
  const _DueMemorySet({required this.group, required this.completed});

  final SavedPictureGroup group;
  final bool completed;
}

String _monthYearLabel(DateTime date) {
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

class _PictureGroupCard extends StatelessWidget {
  const _PictureGroupCard({required this.repository, required this.group});

  final LocalRepository repository;
  final SavedPictureGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox.expand(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              _openMemorySet(context, repository: repository, group: group),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (group.images.isNotEmpty)
                Image.memory(group.images.first, fit: BoxFit.cover)
              else if (_hasCatalogCover(group))
                _CatalogMemorySetCover(group: group)
              else
                ColoredBox(
                  color: colors.primary.withValues(alpha: 0.18),
                  child: Icon(
                    Icons.notes_rounded,
                    color: colors.primary,
                    size: 52,
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.76),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: _NumberCircle(label: '${group.setNumber}'),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 13,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _memoryTypeLabel(group),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openMemorySet(
  BuildContext context, {
  required LocalRepository repository,
  required SavedPictureGroup group,
}) async {
  final granted = await RewardedAccessGate.requestAccess(
    context,
    contentName: '“${group.name}”',
  );
  if (!granted || !context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => RecallPlanPage(repository: repository, group: group),
    ),
  );
}

bool _hasCatalogCover(SavedPictureGroup group) {
  return (group.coverIcon?.isNotEmpty ?? false) ||
      (group.coverImageUrl?.isNotEmpty ?? false);
}

class _CatalogMemorySetCover extends StatelessWidget {
  const _CatalogMemorySetCover({required this.group});

  final SavedPictureGroup group;

  @override
  Widget build(BuildContext context) {
    final start = _colorFromHex(
      group.coverColorStart,
      Theme.of(context).colorScheme.primary,
    );
    final end = _colorFromHex(
      group.coverColorEnd,
      Theme.of(context).colorScheme.tertiary,
    );
    final imageUrl = group.coverImageUrl?.trim() ?? '';

    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ),
      ),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            color: Colors.white.withValues(alpha: 0.18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Icon(
            _catalogIcon(group.coverIcon),
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );

    if (imageUrl.isEmpty) return fallback;
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

Color _colorFromHex(String? value, Color fallback) {
  final hex = (value ?? '').replaceFirst('#', '');
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null || hex.length != 6
      ? fallback
      : Color(0xFF000000 | parsed);
}

IconData _catalogIcon(String? value) => switch (value) {
  'translate' => Icons.translate_rounded,
  'calculate' => Icons.calculate_rounded,
  'bolt' => Icons.bolt_rounded,
  'science' => Icons.science_rounded,
  'biotech' => Icons.biotech_rounded,
  'account_balance' => Icons.account_balance_rounded,
  'public' => Icons.public_rounded,
  'code' => Icons.code_rounded,
  'medical_services' => Icons.medical_services_rounded,
  'gavel' => Icons.gavel_rounded,
  _ => Icons.menu_book_rounded,
};

class _AddPictureGroupSheet extends StatefulWidget {
  const _AddPictureGroupSheet({required this.repository});

  final LocalRepository repository;

  @override
  State<_AddPictureGroupSheet> createState() => _AddPictureGroupSheetState();
}

class _AddPictureGroupSheetState extends State<_AddPictureGroupSheet> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _textController = TextEditingController();
  final _picker = ImagePicker();
  List<XFile> _photos = const [];
  DateTime _startDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  RecallPlanType _planType = RecallPlanType.mostEffective;
  SetGroupAssignment _groupAssignment = const SetGroupAssignment.none();
  List<SavedMemorySetGroup> _memorySetGroups = const [];
  bool _isSaving = false;
  bool _isLoadingNumber = true;

  @override
  void initState() {
    super.initState();
    _loadNextSetNumber();
    _loadMemorySetGroups();
  }

  Future<void> _loadMemorySetGroups() async {
    final groups = await widget.repository.getMemorySetGroups();
    if (mounted) setState(() => _memorySetGroups = groups);
  }

  Future<void> _chooseGroupAssignment() async {
    final assignment = await showSetGroupAssignmentDialog(
      context: context,
      repository: widget.repository,
      initialValue: _groupAssignment,
    );
    if (assignment == null || !mounted) return;
    setState(() => _groupAssignment = assignment);
  }

  Future<void> _loadNextSetNumber() async {
    final nextNumber = await widget.repository.nextSetNumber();
    if (!mounted) return;
    _numberController.text = '$nextNumber';
    setState(() => _isLoadingNumber = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _choosePhotos() async {
    final photos = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 2048,
    );
    if (!mounted || photos.isEmpty) return;
    setState(() => _photos = photos);
  }

  Future<void> _movePickedPhoto(int oldIndex) async {
    var enteredPosition = oldIndex + 1;
    final newPosition = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change picture order'),
        content: TextFormField(
          initialValue: '$enteredPosition',
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            enteredPosition = int.tryParse(value) ?? 0;
          },
          decoration: InputDecoration(
            labelText: 'Position',
            suffixText: '/${_photos.length}',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(enteredPosition),
            child: const Text('Move'),
          ),
        ],
      ),
    );
    if (!mounted || newPosition == null) return;
    final targetIndex = (newPosition - 1).clamp(0, _photos.length - 1);
    setState(() {
      final reordered = [..._photos];
      final moved = reordered.removeAt(oldIndex);
      reordered.insert(targetIndex, moved);
      _photos = reordered;
    });
  }

  Future<void> _chooseStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 20, 12, 31),
      helpText: 'Choose plan start date',
    );
    if (selectedDate == null || !mounted) return;
    setState(() => _startDate = selectedDate);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a name for the memory set.')),
      );
      return;
    }
    final setNumber = int.tryParse(_numberController.text);
    if (setNumber == null || setNumber < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid memory set number.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final images = <Uint8List>[];
      for (final photo in _photos) {
        images.add(await photo.readAsBytes());
      }
      await widget.repository.createPictureGroup(
        name: _nameController.text,
        setNumber: setNumber,
        images: images,
        textContent: _textController.text,
        planStartDate: _startDate,
        planType: _planType.storageValue,
        memorySetGroupId:
            _groupAssignment.type == SetGroupAssignmentType.existing
            ? _groupAssignment.groupId
            : null,
        newMemorySetGroupName:
            _groupAssignment.type == SetGroupAssignmentType.newGroup
            ? _groupAssignment.newGroupName
            : null,
        newMemorySetGroupCover:
            _groupAssignment.type == SetGroupAssignmentType.newGroup
            ? _groupAssignment.newGroupCover
            : null,
      );
      if (mounted) Navigator.of(context).pop();
    } on SetNumberAlreadyUsedException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Set number $setNumber is already used.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The memory set could not be saved.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, 0, 22, bottomInset + 22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create memory set',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start with pictures or text, or create an empty plan and add them later.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Memory set name',
                  hintText: 'For example, Biology chapter 1',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const Key('memorySetNumberField'),
                controller: _numberController,
                enabled: !_isSaving && !_isLoadingNumber,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Memory set number',
                  helperText: 'Every memory set must have a unique number.',
                  prefixIcon: const Icon(Icons.format_list_numbered_rounded),
                  suffixIcon: _isLoadingNumber
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _textController,
                minLines: 3,
                maxLines: 7,
                decoration: const InputDecoration(
                  labelText: 'Text to memorize (optional)',
                  hintText:
                      'Paste or write the information you want to recall.',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _choosePhotos,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _photos.isEmpty
                      ? 'Choose pictures'
                      : '${_photos.length} ${_photos.length == 1 ? 'picture' : 'pictures'} selected',
                ),
              ),
              if (_photos.isNotEmpty) ...[
                const SizedBox(height: 14),
                SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photos.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) => _PickedPhotoPreview(
                      photo: _photos[index],
                      position: index + 1,
                      onPositionPressed: () => _movePickedPhoto(index),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  onTap: _isSaving ? null : _chooseGroupAssignment,
                  leading: const Icon(Icons.folder_copy_outlined),
                  title: const Text('Set group'),
                  subtitle: Text(_groupAssignment.label(_memorySetGroups)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  key: const Key('memorySetStartDate'),
                  onTap: _isSaving ? null : _chooseStartDate,
                  leading: const Icon(Icons.calendar_month_rounded),
                  title: const Text('Plan start date'),
                  subtitle: Text(_formatDate(_startDate)),
                  trailing: const Icon(Icons.edit_calendar_rounded),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Recall plan',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              _PlanChoiceCard(
                type: RecallPlanType.mostEffective,
                selectedType: _planType,
                description:
                    'The strongest schedule, with more early and long-term recalls.',
                onSelected: (type) => setState(() => _planType = type),
              ),
              const SizedBox(height: 8),
              _PlanChoiceCard(
                type: RecallPlanType.effective,
                selectedType: _planType,
                description:
                    'A balanced schedule with fewer early and long-term recalls.',
                onSelected: (type) => setState(() => _planType = type),
              ),
              const SizedBox(height: 8),
              _PlanChoiceCard(
                type: RecallPlanType.fast,
                selectedType: _planType,
                description:
                    'More recalls in a shorter period for time-sensitive learning.',
                onSelected: (type) => setState(() => _planType = type),
              ),
              const SizedBox(height: 8),
              _PlanChoiceCard(
                type: RecallPlanType.ebbinghausSpecial,
                selectedType: _planType,
                description:
                    'A focused schedule inspired by Ebbinghaus\'s forgetting-curve research.',
                onSelected: (type) => setState(() => _planType = type),
              ),
              const SizedBox(height: 8),
              _PlanChoiceCard(
                type: RecallPlanType.sanjarUsmonovSpecial,
                selectedType: _planType,
                description:
                    'A weekly-only schedule with gradually increasing gaps.',
                onSelected: (type) => setState(() => _planType = type),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_task_rounded),
                  label: Text('Start ${_planType.displayName}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanChoiceCard extends StatelessWidget {
  const _PlanChoiceCard({
    required this.type,
    required this.selectedType,
    required this.description,
    required this.onSelected,
  });

  final RecallPlanType type;
  final RecallPlanType selectedType;
  final String description;
  final ValueChanged<RecallPlanType> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = type == selectedType;
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: selected ? colors.primaryContainer : null,
      child: ListTile(
        onTap: () => onSelected(type),
        leading: const Icon(Icons.auto_graph_rounded),
        title: Text(type.displayName),
        subtitle: Text('$description\nDuration: ${type.durationLabel}'),
        trailing: Icon(
          selected
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: selected ? colors.primary : colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

String _memoryTypeLabel(SavedPictureGroup group) {
  final hasText = group.textContent?.trim().isNotEmpty ?? false;
  if (group.images.isNotEmpty && hasText) {
    return '${group.images.length} ${group.images.length == 1 ? 'photo' : 'photos'} + text';
  }
  if (group.images.isNotEmpty) {
    return '${group.images.length} ${group.images.length == 1 ? 'photo' : 'photos'}';
  }
  return hasText ? 'Text notes' : 'Empty plan';
}

String _formatDate(DateTime date) {
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

class _PickedPhotoPreview extends StatelessWidget {
  const _PickedPhotoPreview({
    required this.photo,
    required this.position,
    required this.onPositionPressed,
  });

  final XFile photo;
  final int position;
  final VoidCallback onPositionPressed;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: photo.readAsBytes(),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        return SizedBox(
          width: 84,
          height: 84,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: bytes == null
                      ? const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Image.memory(bytes, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                left: 5,
                top: 5,
                child: GestureDetector(
                  onTap: onPositionPressed,
                  child: _NumberCircle(label: '$position', size: 29),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NumberCircle extends StatelessWidget {
  const _NumberCircle({required this.label, this.size = 34});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: memoryNumberCircleColor,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: size < 32 ? 12 : 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
