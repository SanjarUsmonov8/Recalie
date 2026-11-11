import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/ads/recalie_native_ad.dart';
import 'package:recalie/features/photo_groups/memory_set_style.dart';
import 'package:recalie/features/photo_groups/set_group_assignment.dart';
import 'package:recalie/features/plans/plan_access.dart';
import 'package:recalie/features/plans/plans_page.dart';
import 'package:recalie/features/recall_plan/effective_recall_plan.dart';
import 'package:recalie/features/recall_plan/movable_note_popup.dart';
import 'package:recalie/features/recall_plan/recall_review_completion.dart';
import 'package:recalie/features/recall_plan/subject_text_page.dart';

enum _SetItemType { picture, textPage, attachment }

typedef _SelectedSetItem = ({_SetItemType type, int id});

class RecallPlanPage extends StatefulWidget {
  const RecallPlanPage({
    super.key,
    required this.repository,
    required this.group,
  });

  final LocalRepository repository;
  final SavedPictureGroup group;

  @override
  State<RecallPlanPage> createState() => _RecallPlanPageState();
}

class _RecallPlanPageState extends State<RecallPlanPage> {
  final Set<_SelectedSetItem> _selectedItems = {};

  LocalRepository get repository => widget.repository;
  SavedPictureGroup get group => widget.group;
  bool get _isSelecting => _selectedItems.isNotEmpty;

  void _toggleSelection(_SetItemType type, int id) {
    final item = (type: type, id: id);
    setState(() {
      if (!_selectedItems.remove(item)) _selectedItems.add(item);
    });
  }

  bool _isSelected(_SetItemType type, int id) =>
      _selectedItems.contains((type: type, id: id));

  @override
  Widget build(BuildContext context) {
    final membershipPlan = RecaliePlanScope.of(context).plan;
    return Scaffold(
      bottomNavigationBar: !_isSelecting
          ? null
          : _DeleteSelectedItemsBar(
              count: _selectedItems.length,
              onDelete: _deleteSelectedItems,
            ),
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
                return FutureBuilder<RecallItemProgress>(
                  future: loadCurrentItemProgress(
                    repository: repository,
                    subject: subject,
                  ),
                  builder: (context, progressSnapshot) {
                    final progress =
                        progressSnapshot.data ??
                        RecallItemProgress(
                          target:
                              plan
                                  .requirementFor(DateTime.now())
                                  ?.targetRecalls ??
                              1,
                          counts: const {},
                          requirement: plan.requirementFor(DateTime.now()),
                        );
                    final pages = _textPages(subject.textContent);
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
                      children: [
                        _PlanHeader(
                          name: subject.name,
                          selectionMode: _isSelecting,
                          onBack: () {
                            if (_isSelecting) {
                              setState(_selectedItems.clear);
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          onEdit: () => _editMemorySet(context, subject),
                          onDelete: () => _deleteSubject(context, subject),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'You are recalling ${subject.pictures.length + pages.length + subject.attachments.length} items',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (subject.pictures.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          const _ContentSectionTitle('Images'),
                          const SizedBox(height: 8),
                          _MemoryImages(
                            subject: subject,
                            pictures: subject.pictures,
                            progress: progress,
                            onChangePosition: (picture) =>
                                _changePicturePosition(
                                  context,
                                  subject,
                                  picture,
                                ),
                            repository: repository,
                            selectionMode: _isSelecting,
                            isSelected: (pictureId) =>
                                _isSelected(_SetItemType.picture, pictureId),
                            onToggleSelection: (pictureId) => _toggleSelection(
                              _SetItemType.picture,
                              pictureId,
                            ),
                          ),
                        ],
                        if (pages.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          const _ContentSectionTitle('Notes'),
                          const SizedBox(height: 8),
                          _SubjectTextCard(
                            subject: subject,
                            repository: repository,
                            progress: progress,
                            selectionMode: _isSelecting,
                            isSelected: (pageIndex) =>
                                _isSelected(_SetItemType.textPage, pageIndex),
                            onToggleSelection: (pageIndex) => _toggleSelection(
                              _SetItemType.textPage,
                              pageIndex,
                            ),
                          ),
                        ],
                        for (final type in const ['file', 'audio', 'video'])
                          if (subject.attachments.any(
                            (item) => item.type == type,
                          )) ...[
                            const SizedBox(height: 18),
                            _ContentSectionTitle(_attachmentSectionName(type)),
                            const SizedBox(height: 8),
                            _AttachmentGrid(
                              subject: subject,
                              attachments: subject.attachments
                                  .where((item) => item.type == type)
                                  .toList(),
                              progress: progress,
                              repository: repository,
                              onChangePosition: (attachment) =>
                                  _changeAttachmentPosition(
                                    context,
                                    subject,
                                    attachment,
                                  ),
                              selectionMode: _isSelecting,
                              isSelected: (attachmentId) => _isSelected(
                                _SetItemType.attachment,
                                attachmentId,
                              ),
                              onToggleSelection: (attachmentId) =>
                                  _toggleSelection(
                                    _SetItemType.attachment,
                                    attachmentId,
                                  ),
                            ),
                          ],
                        const RecalieNativeAdCard(
                          format: RecalieNativeAdFormat.large,
                          margin: EdgeInsets.symmetric(vertical: 26),
                        ),
                        Text(
                          plan.type.displayName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        _EffectiveCalendar(
                          plan: plan,
                          recalls: recalls,
                          onRecall: (date) =>
                              _confirmRecall(context, date, plan, subject),
                        ),
                        const SizedBox(height: 22),
                        _AddItemsPanel(
                          onPicture: () => _addPictures(context, subject),
                          onNote: () => _openNotes(context, subject),
                          richItemTypesLocked:
                              !membershipPlan.supportsAllItemTypes,
                          onFile: membershipPlan.supportsAllItemTypes
                              ? () => _addAttachments(context, subject, 'file')
                              : () => _requestRichItemsUpgrade(context),
                          onAudio: membershipPlan.supportsAllItemTypes
                              ? () => _addAttachments(context, subject, 'audio')
                              : () => _requestRichItemsUpgrade(context),
                          onVideo: membershipPlan.supportsAllItemTypes
                              ? () => _addAttachments(context, subject, 'video')
                              : () => _requestRichItemsUpgrade(context),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteSelectedItems() async {
    final subject = await repository.getPictureGroup(group.id);
    if (subject == null || !mounted) return;
    final count = _selectedItems.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete $count ${count == 1 ? 'item' : 'items'} permanently?',
        ),
        content: const Text(
          'The selected items and their saved notes or drawings will be permanently deleted. This cannot be undone.',
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

    final pictureIds = <int>{
      for (final item in _selectedItems)
        if (item.type == _SetItemType.picture) item.id,
    };
    final attachmentIds = <int>{
      for (final item in _selectedItems)
        if (item.type == _SetItemType.attachment) item.id,
    };
    final textPageIndexes = <int>{
      for (final item in _selectedItems)
        if (item.type == _SetItemType.textPage) item.id,
    };
    await repository.deleteMemorySetItems(
      pictureGroupId: subject.id,
      pictureIds: pictureIds,
      attachmentIds: attachmentIds,
      textPageIndexes: textPageIndexes,
    );
    await deleteItemProgress(
      repository: repository,
      subject: subject,
      pictureIds: pictureIds,
      attachmentIds: attachmentIds,
      textPageIndexes: textPageIndexes,
    );
    if (!mounted) return;
    setState(_selectedItems.clear);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$count ${count == 1 ? 'item was' : 'items were'} deleted.',
        ),
      ),
    );
  }

  Future<void> _requestRichItemsUpgrade(BuildContext context) {
    return showPlanUpgradePrompt(
      context,
      title: 'Unlock every item format',
      message:
          'Free supports images and notes. Upgrade to Plus to add files, audio and video.',
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
    var editedName = subject.name;
    var editedNumber = subject.setNumber;
    var selectedType = RecallPlanType.fromStorage(subject.planType);
    var selectedStartDate = dateOnly(subject.planStartDate);
    var memorySetGroups = await repository.getMemorySetGroups();
    if (!context.mounted) return;
    var groupAssignment = subject.memorySetGroupId == null
        ? const SetGroupAssignment.none()
        : SetGroupAssignment.existing(subject.memorySetGroupId!);
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
                TextFormField(
                  initialValue: editedName,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) => editedName = value,
                  decoration: const InputDecoration(
                    labelText: 'Memory set name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: '$editedNumber',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    editedNumber = int.tryParse(value) ?? 0;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Memory set number',
                    helperText: 'This number must be unique.',
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
                        child: Text(type.displayName),
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
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.folder_copy_outlined),
                    title: const Text('Set group'),
                    subtitle: Text(groupAssignment.label(memorySetGroups)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final selection = await showSetGroupAssignmentDialog(
                        context: context,
                        repository: repository,
                        initialValue: groupAssignment,
                      );
                      if (selection == null || !context.mounted) return;
                      memorySetGroups = await repository.getMemorySetGroups();
                      setSheetState(() => groupAssignment = selection);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      _MemorySetPlanUpdate(
                        name: editedName,
                        setNumber: editedNumber,
                        type: selectedType,
                        startDate: selectedStartDate,
                        groupAssignment: groupAssignment,
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
    if (update == null || update.name.trim().isEmpty || update.setNumber < 1) {
      return;
    }
    try {
      await repository.updateMemorySetPlan(
        pictureGroupId: subject.id,
        setNumber: update.setNumber,
        name: update.name,
        planType: update.type.storageValue,
        planStartDate: update.startDate,
        memorySetGroupId:
            update.groupAssignment.type == SetGroupAssignmentType.existing
            ? update.groupAssignment.groupId
            : null,
        newMemorySetGroupName:
            update.groupAssignment.type == SetGroupAssignmentType.newGroup
            ? update.groupAssignment.newGroupName
            : null,
        newMemorySetGroupCover:
            update.groupAssignment.type == SetGroupAssignmentType.newGroup
            ? update.groupAssignment.newGroupCover
            : null,
      );
    } on SetNumberAlreadyUsedException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Set number ${update.setNumber} is already used.'),
          ),
        );
      }
    }
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

  Future<void> _openNotes(
    BuildContext context,
    SavedPictureGroup subject,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SubjectTextPage(
          repository: repository,
          subject: subject,
          startEditing: true,
        ),
      ),
    );
  }

  Future<void> _addAttachments(
    BuildContext context,
    SavedPictureGroup subject,
    String type,
  ) async {
    final pickerType = switch (type) {
      'audio' => FileType.audio,
      'video' => FileType.video,
      _ => FileType.any,
    };
    final result = await FilePicker.platform.pickFiles(
      type: pickerType,
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    const maximumBytes = 100 * 1024 * 1024;
    final accepted = <AttachmentDraft>[];
    var skipped = 0;
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null || bytes.length > maximumBytes) {
        skipped++;
        continue;
      }
      accepted.add(AttachmentDraft(displayName: file.name, data: bytes));
    }
    if (accepted.isNotEmpty) {
      await repository.addAttachments(
        pictureGroupId: subject.id,
        type: type,
        attachments: accepted,
      );
    }
    if (!context.mounted) return;
    final message = accepted.isEmpty
        ? 'No files were added. Files must be no larger than 100 MB.'
        : '${accepted.length} ${accepted.length == 1 ? 'item was' : 'items were'} added.'
              '${skipped == 0 ? '' : ' $skipped oversized item(s) were skipped.'}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changePicturePosition(
    BuildContext context,
    SavedPictureGroup subject,
    SavedPicture picture,
  ) async {
    final currentIndex = subject.pictures.indexWhere(
      (item) => item.id == picture.id,
    );
    var enteredPosition = currentIndex + 1;
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
            suffixText: '/${subject.pictures.length}',
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
    if (newPosition == null || newPosition < 1) return;
    await repository.movePicture(
      pictureGroupId: subject.id,
      pictureId: picture.id,
      newPosition: newPosition,
    );
  }

  Future<void> _changeAttachmentPosition(
    BuildContext context,
    SavedPictureGroup subject,
    SavedAttachment attachment,
  ) async {
    final sameType = subject.attachments
        .where((item) => item.type == attachment.type)
        .toList();
    final currentIndex = sameType.indexWhere(
      (item) => item.id == attachment.id,
    );
    var enteredPosition = currentIndex + 1;
    final newPosition = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change ${attachment.type} order'),
        content: TextFormField(
          initialValue: '$enteredPosition',
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => enteredPosition = int.tryParse(value) ?? 0,
          decoration: InputDecoration(
            labelText: 'Position',
            suffixText: '/${sameType.length}',
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
    if (newPosition == null || newPosition < 1) return;
    await repository.moveAttachment(
      pictureGroupId: subject.id,
      attachmentId: attachment.id,
      type: attachment.type,
      newPosition: newPosition,
    );
  }
}

class _MemorySetPlanUpdate {
  const _MemorySetPlanUpdate({
    required this.name,
    required this.setNumber,
    required this.type,
    required this.startDate,
    required this.groupAssignment,
  });

  final String name;
  final int setNumber;
  final RecallPlanType type;
  final DateTime startDate;
  final SetGroupAssignment groupAssignment;
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({
    required this.name,
    required this.selectionMode,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  final String name;
  final bool selectionMode;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Back',
          onPressed: onBack,
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
        if (!selectionMode) ...[
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
      ],
    );
  }
}

class _DeleteSelectedItemsBar extends StatelessWidget {
  const _DeleteSelectedItemsBar({required this.count, required this.onDelete});

  final int count;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => SafeArea(
    minimum: const EdgeInsets.fromLTRB(18, 8, 18, 14),
    child: SizedBox(
      height: 58,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
          shape: const StadiumBorder(),
        ),
        onPressed: onDelete,
        icon: const Icon(Icons.delete_forever_rounded),
        label: Text(
          'Delete $count ${count == 1 ? 'item' : 'items'}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
    ),
  );
}

class _SelectedItemOverlay extends StatelessWidget {
  const _SelectedItemOverlay();

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 43,
            ),
          ),
        ),
      ),
    ),
  );
}

List<String> _textPages(String? text) {
  if (text == null || text.trim().isEmpty) return const [];
  return text.split('\f');
}

class _SubjectTextCard extends StatelessWidget {
  const _SubjectTextCard({
    required this.subject,
    required this.repository,
    required this.progress,
    required this.selectionMode,
    required this.isSelected,
    required this.onToggleSelection,
  });

  final SavedPictureGroup subject;
  final LocalRepository repository;
  final RecallItemProgress progress;
  final bool selectionMode;
  final bool Function(int pageIndex) isSelected;
  final ValueChanged<int> onToggleSelection;

  Future<void> _changePosition(BuildContext context, int index) async {
    final pages = _textPages(subject.textContent);
    var enteredPosition = index + 1;
    final newPosition = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change note order'),
        content: TextFormField(
          initialValue: '$enteredPosition',
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => enteredPosition = int.tryParse(value) ?? 0,
          decoration: InputDecoration(
            labelText: 'Position',
            suffixText: '/${pages.length}',
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
    if (newPosition == null || newPosition < 1) return;
    await moveSubjectTextPage(
      repository: repository,
      subject: subject,
      oldIndex: index,
      newPosition: newPosition,
    );
  }

  Future<void> _advanceReview(BuildContext context, int index) async {
    await advanceItemReview(
      repository: repository,
      subject: subject,
      itemKey: textReviewItemKey(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = _textPages(subject.textContent);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) => Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: index == 0 ? const Key('subjectTextCard') : null,
          onLongPress: () => onToggleSelection(index),
          onTap: selectionMode
              ? () => onToggleSelection(index)
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SubjectTextPage(
                      repository: repository,
                      subject: subject,
                      initialPage: index,
                    ),
                  ),
                ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                  child: Text(
                    pages[index].trim().isEmpty
                        ? 'This page is empty.'
                        : pages[index].trim(),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.35),
                  ),
                ),
              ),
              Positioned(
                left: 7,
                top: 7,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: selectionMode
                          ? () => onToggleSelection(index)
                          : () => _changePosition(context, index),
                      child: _ImageStatusCircle(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: selectionMode
                          ? () => onToggleSelection(index)
                          : () => _advanceReview(context, index),
                      child: _ReviewProgressCircle(
                        count: progress.countFor(textReviewItemKey(index)),
                        target: progress.target,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected(index)) const _SelectedItemOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentSectionTitle extends StatelessWidget {
  const _ContentSectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
  );
}

String _attachmentSectionName(String type) => switch (type) {
  'audio' => 'Audio',
  'video' => 'Videos',
  _ => 'Files',
};

IconData _attachmentIcon(String type) => switch (type) {
  'audio' => Icons.headphones_rounded,
  'video' => Icons.movie_rounded,
  _ => Icons.insert_drive_file_rounded,
};

class _AttachmentGrid extends StatelessWidget {
  const _AttachmentGrid({
    required this.subject,
    required this.attachments,
    required this.progress,
    required this.repository,
    required this.onChangePosition,
    required this.selectionMode,
    required this.isSelected,
    required this.onToggleSelection,
  });

  final SavedPictureGroup subject;
  final List<SavedAttachment> attachments;
  final RecallItemProgress progress;
  final LocalRepository repository;
  final ValueChanged<SavedAttachment> onChangePosition;
  final bool selectionMode;
  final bool Function(int attachmentId) isSelected;
  final ValueChanged<int> onToggleSelection;

  static const _androidAttachmentChannel = MethodChannel(
    'com.example.recalie/attachments',
  );

  Future<void> _openAttachment(
    BuildContext context,
    SavedAttachment attachment,
  ) async {
    try {
      final directory = await getTemporaryDirectory();
      final safeName = attachment.displayName
          .replaceAll(RegExp(r'[^A-Za-z0-9._ -]'), '_')
          .trim();
      final fileName = safeName.isEmpty
          ? 'recalie_attachment_${attachment.id}'
          : 'recalie_${attachment.id}_$safeName';
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(attachment.data, flush: true);
      if (Platform.isAndroid) {
        await _androidAttachmentChannel.invokeMethod<void>('openFile', {
          'path': file.path,
        });
      } else {
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          throw StateError(
            result.message.isEmpty
                ? 'No compatible app could open this item.'
                : result.message,
          );
        }
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open this item: $error')),
      );
    }
  }

  Future<void> _advanceReview(
    BuildContext context,
    SavedAttachment attachment,
  ) async {
    final itemKey = attachmentReviewItemKey(attachment.id);
    final updated = await advanceItemReview(
      repository: repository,
      subject: subject,
      itemKey: itemKey,
    );
    if (!context.mounted) return;
    final updatedCount = updated.countFor(itemKey);
    final label = updatedCount >= updated.target
        ? 'Reviewed'
        : '$updatedCount/${updated.target} reviews';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${attachment.displayName}: $label')),
    );
  }

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: attachments.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemBuilder: (context, index) {
      final attachment = attachments[index];
      final itemKey = attachmentReviewItemKey(attachment.id);
      final count = progress.countFor(itemKey);
      return Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onLongPress: () => onToggleSelection(attachment.id),
          onTap: selectionMode
              ? () => onToggleSelection(attachment.id)
              : () => _openAttachment(context, attachment),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 42, 14, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _attachmentIcon(attachment.type),
                        size: 42,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        attachment.displayName,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 7,
                top: 7,
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: selectionMode
                          ? () => onToggleSelection(attachment.id)
                          : () => onChangePosition(attachment),
                      child: _ImageStatusCircle(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: selectionMode
                          ? () => onToggleSelection(attachment.id)
                          : () => _advanceReview(context, attachment),
                      child: _ReviewProgressCircle(
                        count: count,
                        target: progress.target,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected(attachment.id)) const _SelectedItemOverlay(),
            ],
          ),
        ),
      );
    },
  );
}

class _ReviewProgressCircle extends StatelessWidget {
  const _ReviewProgressCircle({required this.count, required this.target});

  final int count;
  final int target;

  @override
  Widget build(BuildContext context) => _ImageStatusCircle(
    backgroundColor: count == 0
        ? Colors.black.withValues(alpha: 0.28)
        : memoryNumberCircleColor,
    child: count == 0
        ? const SizedBox.shrink()
        : count >= target
        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
        : Text(
            '$count/$target',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
  );
}

class _AddItemsPanel extends StatelessWidget {
  const _AddItemsPanel({
    required this.onPicture,
    required this.onNote,
    required this.richItemTypesLocked,
    required this.onFile,
    required this.onAudio,
    required this.onVideo,
  });

  final VoidCallback onPicture;
  final VoidCallback onNote;
  final bool richItemTypesLocked;
  final VoidCallback onFile;
  final VoidCallback onAudio;
  final VoidCallback onVideo;

  @override
  Widget build(BuildContext context) {
    final options = [
      (Icons.add_photo_alternate_rounded, 'Picture', onPicture, false),
      (Icons.note_add_rounded, 'Note', onNote, false),
      (Icons.insert_drive_file_rounded, 'File', onFile, richItemTypesLocked),
      (Icons.audio_file_rounded, 'Audio', onAudio, richItemTypesLocked),
      (Icons.video_file_rounded, 'Video', onVideo, richItemTypesLocked),
    ];
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < options.length; index++) ...[
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Icon(options[index].$1),
                title: Text(options[index].$2),
                trailing: Icon(
                  options[index].$4 ? Icons.lock_rounded : Icons.add_rounded,
                ),
                onTap: options[index].$3,
              ),
              if (index != options.length - 1) const Divider(height: 1),
            ],
          ],
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
  const _MemoryImages({
    required this.subject,
    required this.pictures,
    required this.progress,
    required this.onChangePosition,
    required this.repository,
    required this.selectionMode,
    required this.isSelected,
    required this.onToggleSelection,
  });

  final SavedPictureGroup subject;
  final List<SavedPicture> pictures;
  final RecallItemProgress progress;
  final ValueChanged<SavedPicture> onChangePosition;
  final LocalRepository repository;
  final bool selectionMode;
  final bool Function(int pictureId) isSelected;
  final ValueChanged<int> onToggleSelection;

  Future<void> _advanceReview(SavedPicture picture) {
    return advanceItemReview(
      repository: repository,
      subject: subject,
      itemKey: imageReviewItemKey(picture.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pictures.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final picture = pictures[index];
        final reviewCount = progress.countFor(imageReviewItemKey(picture.id));
        return InkWell(
          onLongPress: () => onToggleSelection(picture.id),
          onTap: selectionMode
              ? () => onToggleSelection(picture.id)
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _MemoryImageViewer(
                      subjectId: subject.id,
                      pictures: pictures,
                      initialIndex: index,
                      repository: repository,
                    ),
                  ),
                ),
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: 'memory-image-${picture.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(picture.bytes, fit: BoxFit.cover),
                  ),
                ),
              ),
              Positioned(
                left: 7,
                top: 7,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: selectionMode
                          ? () => onToggleSelection(picture.id)
                          : () => onChangePosition(picture),
                      child: _ImageStatusCircle(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: selectionMode
                          ? () => onToggleSelection(picture.id)
                          : () => _advanceReview(picture),
                      child: _ReviewProgressCircle(
                        count: reviewCount,
                        target: progress.target,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected(picture.id)) const _SelectedItemOverlay(),
            ],
          ),
        );
      },
    );
  }
}

class _MemoryImageViewer extends StatefulWidget {
  const _MemoryImageViewer({
    required this.subjectId,
    required this.pictures,
    required this.initialIndex,
    required this.repository,
  });

  final int subjectId;
  final List<SavedPicture> pictures;
  final int initialIndex;
  final LocalRepository repository;

  @override
  State<_MemoryImageViewer> createState() => _MemoryImageViewerState();
}

class _MemoryImageViewerState extends State<_MemoryImageViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late final List<SavedPicture> _pictures = [...widget.pictures];
  final ScrollController _thumbnailController = ScrollController();
  final Map<int, TransformationController> _transformControllers = {};
  final Map<int, List<_ImageStroke>> _strokes = {};
  final Map<int, List<SavedImageNote>> _notes = {};
  final Map<int, Size> _imageSizes = {};
  late int _currentIndex = widget.initialIndex;
  bool _currentImageZoomed = false;
  bool _drawingMode = false;
  bool _savingDrawings = false;
  bool _showToolPreview = true;
  bool _coverMode = false;
  bool _noteMode = false;
  Offset _draftNotePosition = const Offset(0.5, 0.5);
  bool _solidCover = false;
  _CoverDirection _coverDirection = _CoverDirection.right;
  double _coverFraction = 0.5;
  _AnnotationTool _tool = _AnnotationTool.pen;
  _EraserMode _eraserMode = _EraserMode.line;
  bool _straightLine = false;
  double _thickness = 5;
  double _opacity = 0.95;
  Color _drawingColor = Colors.red;
  final List<List<_ImageStroke>> _undoHistory = [];
  final List<List<_ImageStroke>> _redoHistory = [];
  bool _controlsVisible = true;
  SavedPictureGroup? _subject;
  RecallItemProgress? _reviewProgress;

  @override
  void initState() {
    super.initState();
    _loadAnnotations();
    _loadNotes();
    _loadImageSize(widget.initialIndex);
    _loadReviewProgress();
  }

  Future<void> _loadReviewProgress() async {
    final subject = await widget.repository.getPictureGroup(widget.subjectId);
    if (subject == null) return;
    final progress = await loadCurrentItemProgress(
      repository: widget.repository,
      subject: subject,
    );
    if (!mounted) return;
    setState(() {
      _subject = subject;
      _reviewProgress = progress;
    });
  }

  Future<void> _loadNotes() async {
    try {
      for (final picture in _pictures) {
        _notes[picture.id] = await widget.repository.loadImageNotes(picture.id);
      }
    } catch (error, stackTrace) {
      debugPrint('Could not load image notes: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadImageSize(int index) async {
    final picture = _pictures[index];
    if (_imageSizes.containsKey(picture.id)) return;
    try {
      final codec = await ui.instantiateImageCodec(picture.bytes);
      final frame = await codec.getNextFrame();
      final size = Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
      frame.image.dispose();
      codec.dispose();
      if (!mounted) return;
      setState(() => _imageSizes[picture.id] = size);
    } catch (error) {
      debugPrint('Could not read image dimensions: $error');
    }
  }

  Rect _imageRectFor(int index, Size canvasSize) {
    final imageSize = _imageSizes[_pictures[index].id];
    if (imageSize == null || imageSize.isEmpty) {
      return Offset.zero & canvasSize;
    }
    final fitted = applyBoxFit(BoxFit.contain, imageSize, canvasSize);
    return Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & canvasSize,
    );
  }

  Future<void> _loadAnnotations() async {
    try {
      for (final picture in _pictures) {
        final saved = await widget.repository.loadImageAnnotations(picture.id);
        _strokes[picture.id] = saved.map(_ImageStroke.fromSaved).toList();
      }
    } catch (error, stackTrace) {
      debugPrint('Could not load image annotations: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    if (!mounted) return;
    setState(() {});
  }

  TransformationController _transformControllerFor(int index) {
    return _transformControllers.putIfAbsent(index, () {
      final controller = TransformationController();
      controller.addListener(() {
        if (!mounted || index != _currentIndex) return;
        final zoomed = controller.value.getMaxScaleOnAxis() > 1.01;
        if (zoomed != _currentImageZoomed) {
          setState(() => _currentImageZoomed = zoomed);
        }
      });
      return controller;
    });
  }

  void _handleDoubleTap(int index, TapDownDetails details) {
    if (_drawingMode || _coverMode || _noteMode) return;
    final controller = _transformControllerFor(index);
    if (controller.value.getMaxScaleOnAxis() > 1.01) {
      controller.value = Matrix4.identity();
      return;
    }
    const scale = 2.5;
    final target = Matrix4.identity();
    target.setEntry(0, 0, scale);
    target.setEntry(1, 1, scale);
    target.setEntry(0, 3, -details.localPosition.dx * (scale - 1));
    target.setEntry(1, 3, -details.localPosition.dy * (scale - 1));
    controller.value = target;
  }

  Offset _normalizedPoint(Offset point, Size size) {
    return Offset(
      (point.dx / size.width).clamp(0.0, 1.0),
      (point.dy / size.height).clamp(0.0, 1.0),
    );
  }

  void _startStroke(int index, Offset point, Size size) {
    if (!_drawingMode) return;
    if (_showToolPreview) {
      setState(() => _showToolPreview = false);
    }
    _recordUndo(index);
    if (_tool == _AnnotationTool.eraser) {
      _eraseAt(index, point, size);
      return;
    }
    final pictureId = _pictures[index].id;
    final normalized = _normalizedPoint(point, size);
    setState(() {
      (_strokes[pictureId] ??= []).add(
        _ImageStroke(
          tool: _tool,
          straight: _straightLine,
          thickness: _thickness,
          opacity: _opacity,
          color: _drawingColor,
          points: [normalized],
        ),
      );
    });
  }

  void _extendStroke(int index, Offset point, Size size) {
    if (!_drawingMode) return;
    if (_tool == _AnnotationTool.eraser) {
      _eraseAt(index, point, size);
      return;
    }
    final pictureId = _pictures[index].id;
    final strokes = _strokes[pictureId];
    if (strokes == null || strokes.isEmpty) return;
    final stroke = strokes.last;
    final normalized = _normalizedPoint(point, size);
    setState(() {
      if (stroke.straight) {
        stroke.points
          ..removeRange(1, stroke.points.length)
          ..add(normalized);
      } else {
        stroke.points.add(normalized);
      }
    });
  }

  void _finishStroke(int index) {
    if (!_drawingMode || _tool == _AnnotationTool.eraser) return;
    final pictureId = _pictures[index].id;
    final strokes = _strokes[pictureId];
    if (strokes == null || strokes.isEmpty) return;
    final stroke = strokes.last;
    if (stroke.points.length == 1) {
      stroke.points.add(stroke.points.first + const Offset(0.001, 0.001));
    }
  }

  void _eraseAt(int index, Offset point, Size size) {
    if (_eraserMode == _EraserMode.area) {
      _eraseAreaAt(index, point, size);
      return;
    }
    final pictureId = _pictures[index].id;
    final strokes = _strokes[pictureId];
    if (strokes == null || strokes.isEmpty) return;
    final hitIndex = strokes.lastIndexWhere((stroke) {
      final points = stroke.points
          .map(
            (savedPoint) =>
                Offset(savedPoint.dx * size.width, savedPoint.dy * size.height),
          )
          .toList();
      final hitRadius = (stroke.thickness / 2 + 12);
      final maximumDistanceSquared = hitRadius * hitRadius;
      if (points.length == 1) {
        return (point - points.first).distanceSquared <= maximumDistanceSquared;
      }
      for (var pointIndex = 1; pointIndex < points.length; pointIndex++) {
        if (_distanceSquaredToSegment(
              point,
              points[pointIndex - 1],
              points[pointIndex],
            ) <=
            maximumDistanceSquared) {
          return true;
        }
      }
      return false;
    });
    if (hitIndex < 0) return;
    setState(() {
      final stroke = strokes[hitIndex];
      final remainingOpacity = stroke.opacity * (1 - _opacity);
      if (remainingOpacity <= 0.05) {
        strokes.removeAt(hitIndex);
      } else {
        strokes[hitIndex] = stroke.copyWith(
          clearId: true,
          opacity: remainingOpacity,
        );
      }
    });
  }

  void _eraseAreaAt(int index, Offset point, Size size) {
    final pictureId = _pictures[index].id;
    final strokes = _strokes[pictureId];
    if (strokes == null || strokes.isEmpty) return;
    final radius = (_thickness * 1.3).clamp(10.0, 32.0);
    var changed = false;
    final result = <_ImageStroke>[];
    for (final stroke in strokes) {
      final pieces = _eraseAreaFromStroke(stroke, point, size, radius);
      if (pieces.length != 1 || !identical(pieces.single, stroke)) {
        changed = true;
      }
      result.addAll(pieces);
    }
    if (!changed) return;
    setState(() => _strokes[pictureId] = result);
  }

  List<_ImageStroke> _eraseAreaFromStroke(
    _ImageStroke stroke,
    Offset eraserCenter,
    Size size,
    double radius,
  ) {
    if (stroke.points.length < 2) return [stroke];
    final sampled = <Offset>[];
    for (var index = 1; index < stroke.points.length; index++) {
      final start = stroke.points[index - 1];
      final end = stroke.points[index];
      final pixelStart = Offset(start.dx * size.width, start.dy * size.height);
      final pixelEnd = Offset(end.dx * size.width, end.dy * size.height);
      final steps = ((pixelEnd - pixelStart).distance / 4).ceil().clamp(1, 300);
      for (var step = index == 1 ? 0 : 1; step <= steps; step++) {
        final progress = step / steps;
        sampled.add(start + (end - start) * progress);
      }
    }
    final radiusSquared = radius * radius;
    final groups = <({bool erased, List<Offset> points})>[];
    var current = <Offset>[];
    bool? currentErased;
    var touched = false;
    for (final normalized in sampled) {
      final pixel = Offset(
        normalized.dx * size.width,
        normalized.dy * size.height,
      );
      final erased = (pixel - eraserCenter).distanceSquared <= radiusSquared;
      touched = touched || erased;
      if (currentErased != null && currentErased != erased) {
        if (current.length >= 2) {
          groups.add((erased: currentErased, points: current));
        }
        current = <Offset>[];
      }
      currentErased = erased;
      current.add(normalized);
    }
    if (current.length >= 2 && currentErased != null) {
      groups.add((erased: currentErased, points: current));
    }
    if (!touched) return [stroke];
    return groups
        .where(
          (group) => !group.erased || stroke.opacity * (1 - _opacity) > 0.05,
        )
        .map(
          (group) => stroke.copyWith(
            clearId: true,
            straight: false,
            opacity: group.erased
                ? stroke.opacity * (1 - _opacity)
                : stroke.opacity,
            points: group.points,
          ),
        )
        .toList();
  }

  List<_ImageStroke> _snapshotFor(int index) {
    final pictureId = _pictures[index].id;
    return (_strokes[pictureId] ?? const <_ImageStroke>[])
        .map((stroke) => stroke.copyWith())
        .toList();
  }

  void _recordUndo(int index) {
    _undoHistory.add(_snapshotFor(index));
    if (_undoHistory.length > 50) _undoHistory.removeAt(0);
    _redoHistory.clear();
  }

  void _undoDrawing() {
    if (_undoHistory.isEmpty) return;
    final pictureId = _pictures[_currentIndex].id;
    setState(() {
      _redoHistory.add(_snapshotFor(_currentIndex));
      _strokes[pictureId] = _undoHistory.removeLast();
    });
  }

  void _redoDrawing() {
    if (_redoHistory.isEmpty) return;
    final pictureId = _pictures[_currentIndex].id;
    setState(() {
      _undoHistory.add(_snapshotFor(_currentIndex));
      _strokes[pictureId] = _redoHistory.removeLast();
    });
  }

  void _openDrawingEditor() {
    setState(() {
      _coverMode = false;
      _noteMode = false;
      _drawingMode = true;
      _showToolPreview = true;
      _undoHistory.clear();
      _redoHistory.clear();
    });
  }

  Future<void> _toggleCoverTool() async {
    if (_savingDrawings) return;
    if (_drawingMode) {
      await _saveDrawingEdits();
      if (!mounted || _drawingMode) return;
    }
    setState(() {
      _coverMode = !_coverMode;
      _noteMode = false;
      if (_coverMode) _coverFraction = 0.5;
    });
  }

  Future<void> _toggleNoteTool() async {
    if (_savingDrawings) return;
    if (_drawingMode) {
      await _saveDrawingEdits();
      if (!mounted || _drawingMode) return;
    }
    setState(() {
      _noteMode = !_noteMode;
      _coverMode = false;
      if (_noteMode) _draftNotePosition = const Offset(0.5, 0.5);
    });
  }

  Future<void> _addNoteAt(int index, Offset normalizedPosition) async {
    final result = await _showNoteEditor();
    if (result == null || result.action != _NoteEditorAction.save) return;
    final pictureId = _pictures[index].id;
    try {
      final note = await widget.repository.createImageNote(
        pictureId: pictureId,
        normalizedX: normalizedPosition.dx,
        normalizedY: normalizedPosition.dy,
        content: result.content,
        images: result.images,
      );
      if (!mounted) return;
      setState(() {
        (_notes[pictureId] ??= []).add(note);
        _draftNotePosition = const Offset(0.5, 0.5);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save the note: $error')),
      );
    }
  }

  Future<void> _openNote(SavedImageNote note) async {
    final result = await _showNoteEditor(note: note);
    if (result == null) return;
    try {
      if (result.action == _NoteEditorAction.delete) {
        await widget.repository.deleteImageNote(note.id);
        if (!mounted) return;
        setState(
          () => _notes[note.pictureId]?.removeWhere(
            (savedNote) => savedNote.id == note.id,
          ),
        );
      } else {
        await widget.repository.updateImageNote(
          note.id,
          result.content,
          images: result.images,
        );
        if (!mounted) return;
        final notes = _notes[note.pictureId];
        final index = notes?.indexWhere((savedNote) => savedNote.id == note.id);
        if (notes != null && index != null && index >= 0) {
          setState(
            () => notes[index] = note.copyWith(
              content: result.content,
              images: result.images,
            ),
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update the note: $error')),
      );
    }
  }

  Future<void> _showNote(SavedImageNote note, Offset anchor) {
    return showMovableNotePopup(
      context: context,
      anchor: anchor,
      content: note.content,
      images: note.images,
    );
  }

  void _moveNote(SavedImageNote note, Offset position) {
    final notes = _notes[note.pictureId];
    final index = notes?.indexWhere((saved) => saved.id == note.id) ?? -1;
    if (notes == null || index < 0) return;
    setState(() {
      notes[index] = note.copyWith(
        normalizedX: position.dx,
        normalizedY: position.dy,
      );
    });
  }

  Future<void> _saveNotePosition(SavedImageNote note) async {
    final notes = _notes[note.pictureId];
    final index = notes?.indexWhere((saved) => saved.id == note.id) ?? -1;
    if (notes == null || index < 0) return;
    final current = notes[index];
    await widget.repository.updateImageNotePosition(
      noteId: current.id,
      normalizedX: current.normalizedX,
      normalizedY: current.normalizedY,
    );
  }

  Future<_NoteEditorResult?> _showNoteEditor({SavedImageNote? note}) {
    var draft = note?.content ?? '';
    final draftImages = <Uint8List>[...?note?.images];
    return showModalBottomSheet<_NoteEditorResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final colors = Theme.of(context).colorScheme;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              14,
              14,
              14,
              MediaQuery.viewInsetsOf(context).bottom + 14,
            ),
            child: Material(
              color: colors.surface,
              borderRadius: BorderRadius.circular(26),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sticky_note_2_rounded,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            note == null ? 'New note' : 'Edit note',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: draft,
                      autofocus: true,
                      minLines: 5,
                      maxLines: 10,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Write your note…',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setSheetState(() => draft = value),
                      contentInsertionConfiguration:
                          ContentInsertionConfiguration(
                            allowedMimeTypes: const [
                              'image/png',
                              'image/jpeg',
                              'image/gif',
                              'image/webp',
                            ],
                            onContentInserted: (content) {
                              final bytes = content.data;
                              if (bytes != null && bytes.isNotEmpty) {
                                setSheetState(() => draftImages.add(bytes));
                              }
                            },
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (draftImages.isNotEmpty) ...[
                      _NoteImageEditorStrip(
                        images: draftImages,
                        onRemove: (index) =>
                            setSheetState(() => draftImages.removeAt(index)),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final photos = await ImagePicker().pickMultiImage(
                            imageQuality: 85,
                            maxWidth: 2048,
                          );
                          if (photos.isEmpty) return;
                          final images = await Future.wait(
                            photos.map((photo) => photo.readAsBytes()),
                          );
                          setSheetState(() => draftImages.addAll(images));
                        },
                        icon: const Icon(Icons.add_photo_alternate_rounded),
                        label: const Text('Add photos'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (note != null)
                          TextButton.icon(
                            onPressed: () => Navigator.of(sheetContext).pop(
                              const _NoteEditorResult(
                                action: _NoteEditorAction.delete,
                                content: '',
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Delete'),
                          ),
                        const Spacer(),
                        FilledButton(
                          onPressed: draft.trim().isEmpty && draftImages.isEmpty
                              ? null
                              : () => Navigator.of(sheetContext).pop(
                                  _NoteEditorResult(
                                    action: _NoteEditorAction.save,
                                    content: draft.trim(),
                                    images: List.of(draftImages),
                                  ),
                                ),
                          child: const Text('Save note'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveDrawingEdits() async {
    if (_savingDrawings) return;
    final pictureId = _pictures[_currentIndex].id;
    final strokes = _strokes[pictureId] ?? const <_ImageStroke>[];
    setState(() => _savingDrawings = true);
    try {
      await widget.repository.replaceImageAnnotations(
        pictureId: pictureId,
        annotations: strokes
            .map(
              (stroke) => ImageAnnotationDraft(
                tool: stroke.tool.name,
                isStraight: stroke.straight,
                thickness: stroke.thickness,
                opacity: stroke.opacity,
                colorValue: stroke.color.toARGB32(),
                normalizedPoints: [
                  for (final point in stroke.points) ...[point.dx, point.dy],
                ],
              ),
            )
            .toList(),
      );
      final saved = await widget.repository.loadImageAnnotations(pictureId);
      if (!mounted) return;
      setState(() {
        _strokes[pictureId] = saved.map(_ImageStroke.fromSaved).toList();
        _drawingMode = false;
        _savingDrawings = false;
        _undoHistory.clear();
        _redoHistory.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drawing saved in Recalie.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _savingDrawings = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save the drawing: $error')),
      );
    }
  }

  void _selectTool(_AnnotationTool tool) {
    setState(() {
      _tool = tool;
      if (tool == _AnnotationTool.highlighter) {
        _opacity = 0.35;
        _thickness = 14;
      } else if (tool == _AnnotationTool.pen) {
        _opacity = 0.95;
        _thickness = 5;
      } else {
        _opacity = 1;
        _thickness = 14;
      }
      _showToolPreview = true;
    });
  }

  Future<void> _toggleReviewed() async {
    final picture = _pictures[_currentIndex];
    final subject =
        _subject ?? await widget.repository.getPictureGroup(widget.subjectId);
    if (subject == null) return;
    final updated = await advanceItemReview(
      repository: widget.repository,
      subject: subject,
      itemKey: imageReviewItemKey(picture.id),
    );
    if (!mounted) return;
    setState(() => _reviewProgress = updated);
  }

  void _toggleControls() {
    if (_drawingMode || _coverMode || _noteMode) return;
    setState(() => _controlsVisible = !_controlsVisible);
  }

  void _showImageAt(int index) {
    if (index == _currentIndex) return;
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _centerSelectedThumbnail() {
    if (!_thumbnailController.hasClients) return;
    const itemExtent = 60.0;
    final viewport = _thumbnailController.position.viewportDimension;
    final target = (_currentIndex * itemExtent - (viewport - 52) / 2).clamp(
      0.0,
      _thumbnailController.position.maxScrollExtent,
    );
    _thumbnailController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _deleteCurrentPicture() async {
    final picture = _pictures[_currentIndex];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this image permanently?'),
        content: const Text(
          'The image, its drawings, and its notes will be permanently deleted. This cannot be undone.',
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

    await widget.repository.deletePicture(
      pictureGroupId: widget.subjectId,
      pictureId: picture.id,
    );
    if (!mounted) return;
    for (final controller in _transformControllers.values) {
      controller.dispose();
    }
    _transformControllers.clear();
    _strokes.remove(picture.id);
    _notes.remove(picture.id);
    _imageSizes.remove(picture.id);
    setState(() {
      _pictures.removeAt(_currentIndex);
      if (_pictures.isNotEmpty) {
        _currentIndex = _currentIndex.clamp(0, _pictures.length - 1);
        _currentImageZoomed = false;
      }
    });
    if (_pictures.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.jumpToPage(_currentIndex);
      _loadImageSize(_currentIndex);
      _centerSelectedThumbnail();
    });
  }

  void _openFutureAiTools() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI image tools are coming later.')),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _thumbnailController.dispose();
    for (final controller in _transformControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              physics:
                  _drawingMode || _coverMode || _noteMode || _currentImageZoomed
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
              onPageChanged: (index) {
                _loadImageSize(index);
                final transform = _transformControllerFor(index);
                setState(() {
                  _currentIndex = index;
                  _currentImageZoomed =
                      transform.value.getMaxScaleOnAxis() > 1.01;
                });
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _centerSelectedThumbnail(),
                );
              },
              itemCount: _pictures.length,
              itemBuilder: (context, index) => LayoutBuilder(
                builder: (context, constraints) {
                  final canvasSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleControls,
                    onDoubleTapDown: (details) =>
                        _handleDoubleTap(index, details),
                    child: InteractiveViewer(
                      transformationController: _transformControllerFor(index),
                      minScale: 1,
                      maxScale: 5,
                      panEnabled:
                          !_drawingMode &&
                          !_coverMode &&
                          !_noteMode &&
                          _transformControllerFor(
                                index,
                              ).value.getMaxScaleOnAxis() >
                              1.01,
                      scaleEnabled: !_drawingMode && !_coverMode && !_noteMode,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: !_drawingMode
                            ? null
                            : (details) => _startStroke(
                                index,
                                details.localPosition,
                                canvasSize,
                              ),
                        onPanUpdate: !_drawingMode
                            ? null
                            : (details) => _extendStroke(
                                index,
                                details.localPosition,
                                canvasSize,
                              ),
                        onPanEnd: !_drawingMode
                            ? null
                            : (_) => _finishStroke(index),
                        child: SizedBox(
                          width: canvasSize.width,
                          height: canvasSize.height,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Center(
                                child: Hero(
                                  tag: 'memory-image-${_pictures[index].id}',
                                  child: Image.memory(
                                    _pictures[index].bytes,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: CustomPaint(
                                  painter: _ImageAnnotationPainter(
                                    _strokes[_pictures[index].id] ?? const [],
                                  ),
                                ),
                              ),
                              if (_coverMode && index == _currentIndex)
                                _PartialCoverOverlay(
                                  imageRect: _imageRectFor(index, canvasSize),
                                  direction: _coverDirection,
                                  fraction: _coverFraction,
                                  solid: _solidCover,
                                  darkMode:
                                      Theme.of(context).brightness ==
                                      Brightness.dark,
                                  onFractionChanged: (value) =>
                                      setState(() => _coverFraction = value),
                                ),
                              if (!_drawingMode && !_coverMode)
                                _ImageNotesOverlay(
                                  imageRect: _imageRectFor(index, canvasSize),
                                  notes:
                                      _notes[_pictures[index].id] ?? const [],
                                  adding: _noteMode,
                                  draftPosition: _draftNotePosition,
                                  onDraftMoved: (position) => setState(
                                    () => _draftNotePosition = position,
                                  ),
                                  onCreate: (position) =>
                                      _addNoteAt(index, position),
                                  editing: _noteMode,
                                  onOpen: (note, anchor) => _noteMode
                                      ? _openNote(note)
                                      : _showNote(note, anchor),
                                  onMoved: _moveNote,
                                  onMoveEnd: _saveNotePosition,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_controlsVisible)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const _ImageStatusCircle(
                      size: 46,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _ViewerToolCapsule(
                    noteMode: _noteMode,
                    drawingMode: _drawingMode,
                    coverMode: _coverMode,
                    savingDrawings: _savingDrawings,
                    onDrawingTap: _savingDrawings
                        ? null
                        : (_drawingMode
                              ? _saveDrawingEdits
                              : _openDrawingEditor),
                    onCoverTap: _toggleCoverTool,
                    onNoteTap: _toggleNoteTool,
                  ),
                  const SizedBox(width: 7),
                  GestureDetector(
                    onTap: _toggleReviewed,
                    child: _ImageStatusCircle(
                      size: 46,
                      child:
                          (_reviewProgress?.isComplete(
                                imageReviewItemKey(_pictures[_currentIndex].id),
                              ) ??
                              false)
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 29,
                            )
                          : Text(
                              (_reviewProgress?.countFor(
                                            imageReviewItemKey(
                                              _pictures[_currentIndex].id,
                                            ),
                                          ) ??
                                          0) >
                                      0
                                  ? '${_reviewProgress!.countFor(imageReviewItemKey(_pictures[_currentIndex].id))}/${_reviewProgress!.target}'
                                  : '${_currentIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          if (_coverMode)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 64,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _CoverDirectionPicker(
                    direction: _coverDirection,
                    onChanged: (direction) => setState(() {
                      _coverDirection = direction;
                      _coverFraction = 0.5;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _CoverOpacityPicker(
                    solid: _solidCover,
                    onChanged: (value) => setState(() => _solidCover = value),
                  ),
                ],
              ),
            ),
          if (_drawingMode && _showToolPreview)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: _DrawingPreview(
                    tool: _tool,
                    thickness: _thickness,
                    opacity: _opacity,
                    color: _drawingColor,
                  ),
                ),
              ),
            ),
          if (_drawingMode)
            Positioned(
              left: 18,
              right: 18,
              bottom: 24,
              child: _DrawingToolbar(
                tool: _tool,
                eraserMode: _eraserMode,
                straightLine: _straightLine,
                thickness: _thickness,
                opacity: _opacity,
                color: _drawingColor,
                onToolChanged: _selectTool,
                onEraserModeChanged: (value) => setState(() {
                  _eraserMode = value;
                  _showToolPreview = true;
                }),
                onStraightChanged: (value) => setState(() {
                  _straightLine = value;
                  _showToolPreview = true;
                }),
                onThicknessChanged: (value) => setState(() {
                  _thickness = value;
                  _showToolPreview = true;
                }),
                onOpacityChanged: (value) => setState(() {
                  _opacity = value;
                  _showToolPreview = true;
                }),
                onColorChanged: (value) => setState(() {
                  _drawingColor = value;
                  _showToolPreview = true;
                }),
                canUndo: _undoHistory.isNotEmpty,
                canRedo: _redoHistory.isNotEmpty,
                onUndo: _undoDrawing,
                onRedo: _redoDrawing,
              ),
            ),
          if (_controlsVisible && !_drawingMode && !_coverMode && !_noteMode)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12 + MediaQuery.paddingOf(context).bottom,
              child: _ImageViewerBottomControls(
                pictures: _pictures,
                currentIndex: _currentIndex,
                controller: _thumbnailController,
                onImageSelected: _showImageAt,
                onDelete: _deleteCurrentPicture,
                onAi: _openFutureAiTools,
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageViewerBottomControls extends StatelessWidget {
  const _ImageViewerBottomControls({
    required this.pictures,
    required this.currentIndex,
    required this.controller,
    required this.onImageSelected,
    required this.onDelete,
    required this.onAi,
  });

  final List<SavedPicture> pictures;
  final int currentIndex;
  final ScrollController controller;
  final ValueChanged<int> onImageSelected;
  final VoidCallback onDelete;
  final VoidCallback onAi;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        height: 46,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: memoryNumberCircleColor,
          borderRadius: BorderRadius.circular(23),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ViewerBottomAction(
              tooltip: 'Delete image',
              icon: Icons.delete_outline_rounded,
              onTap: onDelete,
            ),
            Container(width: 1, height: 24, color: Colors.white30),
            _ViewerBottomAction(
              tooltip: 'AI image tools',
              icon: Icons.auto_awesome_rounded,
              onTap: onAi,
            ),
          ],
        ),
      ),
      const SizedBox(height: 9),
      SizedBox(
        height: 64,
        child: ListView.separated(
          controller: controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: pictures.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final selected = index == currentIndex;
            return GestureDetector(
              onTap: () => onImageSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 52,
                padding: EdgeInsets.all(selected ? 3 : 0),
                decoration: BoxDecoration(
                  color: selected
                      ? memoryNumberCircleColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    pictures[index].bytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

class _ViewerBottomAction extends StatelessWidget {
  const _ViewerBottomAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox.square(
        dimension: 42,
        child: Icon(icon, color: Colors.white, size: 23),
      ),
    ),
  );
}

enum _NoteEditorAction { save, delete }

class _NoteEditorResult {
  const _NoteEditorResult({
    required this.action,
    required this.content,
    this.images = const [],
  });

  final _NoteEditorAction action;
  final String content;
  final List<Uint8List> images;
}

class _NoteImageEditorStrip extends StatelessWidget {
  const _NoteImageEditorStrip({required this.images, required this.onRemove});

  final List<Uint8List> images;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 150,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: images.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) => Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              images[index],
              width: 170,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: IconButton.filled(
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove image',
              onPressed: () => onRemove(index),
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ImageNotesOverlay extends StatelessWidget {
  const _ImageNotesOverlay({
    required this.imageRect,
    required this.notes,
    required this.adding,
    required this.draftPosition,
    required this.onDraftMoved,
    required this.onCreate,
    required this.editing,
    required this.onOpen,
    required this.onMoved,
    required this.onMoveEnd,
  });

  final Rect imageRect;
  final List<SavedImageNote> notes;
  final bool adding;
  final Offset draftPosition;
  final ValueChanged<Offset> onDraftMoved;
  final ValueChanged<Offset> onCreate;
  final bool editing;
  final void Function(SavedImageNote note, Offset anchor) onOpen;
  final void Function(SavedImageNote note, Offset position) onMoved;
  final ValueChanged<SavedImageNote> onMoveEnd;

  @override
  Widget build(BuildContext context) {
    const iconSize = 36.0;
    return Stack(
      children: [
        if (adding)
          Positioned(
            left:
                (imageRect.left +
                        draftPosition.dx * imageRect.width -
                        iconSize / 2)
                    .clamp(imageRect.left, imageRect.right - iconSize),
            top:
                (imageRect.top +
                        draftPosition.dy * imageRect.height -
                        iconSize / 2)
                    .clamp(imageRect.top, imageRect.bottom - iconSize),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                onDraftMoved(
                  Offset(
                    (draftPosition.dx + details.delta.dx / imageRect.width)
                        .clamp(0.0, 1.0),
                    (draftPosition.dy + details.delta.dy / imageRect.height)
                        .clamp(0.0, 1.0),
                  ),
                );
              },
              onTap: () => onCreate(draftPosition),
              child: Material(
                color: memoryNumberCircleColor,
                elevation: 6,
                shadowColor: Colors.black54,
                shape: const CircleBorder(),
                child: const SizedBox.square(
                  dimension: iconSize,
                  child: Icon(
                    Icons.note_add_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ),
          ),
        for (final note in notes)
          Positioned(
            left:
                (imageRect.left +
                        note.normalizedX * imageRect.width -
                        iconSize / 2)
                    .clamp(imageRect.left, imageRect.right - iconSize),
            top:
                (imageRect.top +
                        note.normalizedY * imageRect.height -
                        iconSize / 2)
                    .clamp(imageRect.top, imageRect.bottom - iconSize),
            child: Tooltip(
              message: note.content,
              child: GestureDetector(
                onPanUpdate: !editing
                    ? null
                    : (details) => onMoved(
                        note,
                        Offset(
                          (note.normalizedX +
                                  details.delta.dx / imageRect.width)
                              .clamp(0.0, 1.0),
                          (note.normalizedY +
                                  details.delta.dy / imageRect.height)
                              .clamp(0.0, 1.0),
                        ),
                      ),
                onPanEnd: !editing ? null : (_) => onMoveEnd(note),
                child: Material(
                  color: memoryNumberCircleColor,
                  elevation: 4,
                  shadowColor: Colors.black54,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTapUp: (details) => onOpen(note, details.globalPosition),
                    customBorder: const CircleBorder(),
                    child: const SizedBox.square(
                      dimension: iconSize,
                      child: Icon(
                        Icons.sticky_note_2_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ViewerToolCapsule extends StatelessWidget {
  const _ViewerToolCapsule({
    required this.noteMode,
    required this.drawingMode,
    required this.coverMode,
    required this.savingDrawings,
    required this.onDrawingTap,
    required this.onCoverTap,
    required this.onNoteTap,
  });

  final bool noteMode;
  final bool drawingMode;
  final bool coverMode;
  final bool savingDrawings;
  final VoidCallback? onDrawingTap;
  final VoidCallback onCoverTap;
  final VoidCallback onNoteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: memoryNumberCircleColor,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewerToolButton(
            tooltip: 'Image notes',
            selected: noteMode,
            onTap: onNoteTap,
            child: Icon(
              noteMode ? Icons.check_rounded : Icons.note_add_rounded,
              size: noteMode ? 27 : 23,
            ),
          ),
          Container(width: 1, height: 24, color: Colors.white30),
          _ViewerToolButton(
            tooltip: 'Partial cover',
            selected: coverMode,
            onTap: onCoverTap,
            child: const _PartialCoverToolIcon(),
          ),
          Container(width: 1, height: 24, color: Colors.white30),
          _ViewerToolButton(
            key: const Key('imageDrawingButton'),
            tooltip: drawingMode ? 'Save drawing' : 'Draw or highlight',
            selected: drawingMode,
            onTap: onDrawingTap,
            child: savingDrawings
                ? const SizedBox.square(
                    dimension: 19,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.4,
                    ),
                  )
                : Icon(
                    drawingMode ? Icons.check_rounded : Icons.draw_rounded,
                    size: drawingMode ? 27 : 23,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ViewerToolButton extends StatelessWidget {
  const _ViewerToolButton({
    super.key,
    required this.tooltip,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final bool selected;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? Colors.white24 : Colors.transparent,
          ),
          child: IconTheme(
            data: const IconThemeData(color: Colors.white),
            child: child,
          ),
        ),
      ),
    );
  }
}

enum _CoverDirection { right, left, bottom, top }

class _PartialCoverToolIcon extends StatelessWidget {
  const _PartialCoverToolIcon({this.direction});

  final _CoverDirection? direction;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
      child: CustomPaint(
        painter: _PartialCoverToolIconPainter(direction: direction),
      ),
    );
  }
}

class _PartialCoverToolIconPainter extends CustomPainter {
  const _PartialCoverToolIconPainter({this.direction});

  final _CoverDirection? direction;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(2.5, 2.5, size.width - 5, size.height - 5);
    final stroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    if (direction != null) {
      final coveredRect = switch (direction!) {
        _CoverDirection.right => Rect.fromLTRB(
          rect.center.dx,
          rect.top,
          rect.right,
          rect.bottom,
        ),
        _CoverDirection.left => Rect.fromLTRB(
          rect.left,
          rect.top,
          rect.center.dx,
          rect.bottom,
        ),
        _CoverDirection.bottom => Rect.fromLTRB(
          rect.left,
          rect.center.dy,
          rect.right,
          rect.bottom,
        ),
        _CoverDirection.top => Rect.fromLTRB(
          rect.left,
          rect.top,
          rect.right,
          rect.center.dy,
        ),
      };
      canvas.drawRect(
        coveredRect,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      stroke,
    );
    final divider = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8;
    if (direction == _CoverDirection.bottom ||
        direction == _CoverDirection.top) {
      canvas.drawLine(
        Offset(rect.left, rect.center.dy),
        Offset(rect.right, rect.center.dy),
        divider,
      );
    } else {
      canvas.drawLine(
        Offset(rect.center.dx, rect.top),
        Offset(rect.center.dx, rect.bottom),
        divider,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PartialCoverToolIconPainter oldDelegate) =>
      oldDelegate.direction != direction;
}

class _CoverDirectionPicker extends StatelessWidget {
  const _CoverDirectionPicker({
    required this.direction,
    required this.onChanged,
  });

  final _CoverDirection direction;
  final ValueChanged<_CoverDirection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xF2202732),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in _CoverDirection.values)
            InkWell(
              onTap: () => onChanged(option),
              customBorder: const CircleBorder(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: option == direction
                      ? memoryNumberCircleColor
                      : Colors.transparent,
                ),
                child: _PartialCoverToolIcon(direction: option),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoverOpacityPicker extends StatelessWidget {
  const _CoverOpacityPicker({required this.solid, required this.onChanged});

  final bool solid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xF2202732),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CoverOpacityButton(
            tooltip: 'Transparent cover',
            selected: !solid,
            solid: false,
            onTap: () => onChanged(false),
          ),
          _CoverOpacityButton(
            tooltip: 'Solid cover',
            selected: solid,
            solid: true,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _CoverOpacityButton extends StatelessWidget {
  const _CoverOpacityButton({
    required this.tooltip,
    required this.selected,
    required this.solid,
    required this.onTap,
  });

  final String tooltip;
  final bool selected;
  final bool solid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? memoryNumberCircleColor : Colors.transparent,
          ),
          child: _CoverOpacityIcon(solid: solid),
        ),
      ),
    );
  }
}

class _CoverOpacityIcon extends StatelessWidget {
  const _CoverOpacityIcon({required this.solid});

  final bool solid;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 23,
      height: 23,
      decoration: BoxDecoration(
        color: const Color(0xFF60A5FA).withValues(alpha: solid ? 1 : 0.38),
        border: Border.all(color: Colors.white, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _PartialCoverOverlay extends StatelessWidget {
  const _PartialCoverOverlay({
    required this.imageRect,
    required this.direction,
    required this.fraction,
    required this.solid,
    required this.darkMode,
    required this.onFractionChanged,
  });

  final Rect imageRect;
  final _CoverDirection direction;
  final double fraction;
  final bool solid;
  final bool darkMode;
  final ValueChanged<double> onFractionChanged;

  bool get _usesVerticalDivider =>
      direction == _CoverDirection.right || direction == _CoverDirection.left;

  void _updateFromPosition(Offset position) {
    final value = _usesVerticalDivider
        ? position.dx / imageRect.width
        : position.dy / imageRect.height;
    onFractionChanged(value.clamp(0.04, 0.96));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fromRect(
          rect: imageRect,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: !_usesVerticalDivider
                ? null
                : (details) => _updateFromPosition(details.localPosition),
            onHorizontalDragUpdate: !_usesVerticalDivider
                ? null
                : (details) => _updateFromPosition(details.localPosition),
            onVerticalDragStart: _usesVerticalDivider
                ? null
                : (details) => _updateFromPosition(details.localPosition),
            onVerticalDragUpdate: _usesVerticalDivider
                ? null
                : (details) => _updateFromPosition(details.localPosition),
            child: CustomPaint(
              painter: _PartialCoverPainter(
                direction: direction,
                fraction: fraction,
                solid: solid,
                darkMode: darkMode,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PartialCoverPainter extends CustomPainter {
  const _PartialCoverPainter({
    required this.direction,
    required this.fraction,
    required this.solid,
    required this.darkMode,
  });

  final _CoverDirection direction;
  final double fraction;
  final bool solid;
  final bool darkMode;

  @override
  void paint(Canvas canvas, Size size) {
    final boundary = switch (direction) {
      _CoverDirection.right || _CoverDirection.left => size.width * fraction,
      _CoverDirection.bottom || _CoverDirection.top => size.height * fraction,
    };
    final coverRect = switch (direction) {
      _CoverDirection.right => Rect.fromLTRB(
        boundary,
        0,
        size.width,
        size.height,
      ),
      _CoverDirection.left => Rect.fromLTRB(0, 0, boundary, size.height),
      _CoverDirection.bottom => Rect.fromLTRB(
        0,
        boundary,
        size.width,
        size.height,
      ),
      _CoverDirection.top => Rect.fromLTRB(0, 0, size.width, boundary),
    };
    final coverPaint = Paint();
    if (solid) {
      coverPaint.color = darkMode
          ? const Color(0xFF163B73)
          : const Color(0xFF93C5FD);
    } else {
      coverPaint.shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xC75BB9F8), Color(0xDD1D4ED8)],
      ).createShader(coverRect);
    }
    canvas.drawRect(coverRect, coverPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF102F70)
      ..strokeWidth = 4;
    final Offset handleCenter;
    if (direction == _CoverDirection.right ||
        direction == _CoverDirection.left) {
      canvas.drawLine(
        Offset(boundary, 0),
        Offset(boundary, size.height),
        borderPaint,
      );
      handleCenter = Offset(boundary, size.height / 2);
    } else {
      canvas.drawLine(
        Offset(0, boundary),
        Offset(size.width, boundary),
        borderPaint,
      );
      handleCenter = Offset(size.width / 2, boundary);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: handleCenter, width: 16, height: 32),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF102F70),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: handleCenter, width: 7, height: 21),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF93C5FD),
    );
  }

  @override
  bool shouldRepaint(covariant _PartialCoverPainter oldDelegate) =>
      oldDelegate.direction != direction ||
      oldDelegate.fraction != fraction ||
      oldDelegate.solid != solid ||
      oldDelegate.darkMode != darkMode;
}

double _distanceSquaredToSegment(Offset point, Offset start, Offset end) {
  final segment = end - start;
  final segmentLengthSquared = segment.distanceSquared;
  if (segmentLengthSquared == 0) return (point - start).distanceSquared;
  final relative = point - start;
  final projection =
      ((relative.dx * segment.dx + relative.dy * segment.dy) /
              segmentLengthSquared)
          .clamp(0.0, 1.0);
  final nearest = start + segment * projection;
  return (point - nearest).distanceSquared;
}

enum _AnnotationTool { pen, highlighter, eraser }

enum _EraserMode { line, area }

class _ImageStroke {
  _ImageStroke({
    this.id,
    required this.tool,
    required this.straight,
    required this.thickness,
    required this.opacity,
    required this.color,
    required this.points,
  });

  factory _ImageStroke.fromSaved(SavedImageAnnotation annotation) {
    final coordinates = annotation.normalizedPoints;
    return _ImageStroke(
      id: annotation.id,
      tool: annotation.tool == _AnnotationTool.highlighter.name
          ? _AnnotationTool.highlighter
          : _AnnotationTool.pen,
      straight: annotation.isStraight,
      thickness: annotation.thickness,
      opacity: annotation.opacity,
      color: Color(annotation.colorValue),
      points: [
        for (var index = 0; index + 1 < coordinates.length; index += 2)
          Offset(coordinates[index], coordinates[index + 1]),
      ],
    );
  }

  _ImageStroke copyWith({
    bool clearId = false,
    bool? straight,
    double? opacity,
    List<Offset>? points,
  }) {
    return _ImageStroke(
      id: clearId ? null : id,
      tool: tool,
      straight: straight ?? this.straight,
      thickness: thickness,
      opacity: opacity ?? this.opacity,
      color: color,
      points: [...?points, if (points == null) ...this.points],
    );
  }

  final int? id;
  final _AnnotationTool tool;
  final bool straight;
  final double thickness;
  final double opacity;
  final Color color;
  final List<Offset> points;
}

class _ImageAnnotationPainter extends CustomPainter {
  const _ImageAnnotationPainter(this.strokes);

  final List<_ImageStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final points = stroke.points
          .map((point) => Offset(point.dx * size.width, point.dy * size.height))
          .toList();
      final paint = Paint()
        ..color = stroke.color.withValues(alpha: stroke.opacity)
        ..strokeWidth = stroke.thickness
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      if (stroke.straight || points.length < 3) {
        path.lineTo(points.last.dx, points.last.dy);
      } else {
        for (var index = 1; index < points.length - 1; index++) {
          final current = points[index];
          final next = points[index + 1];
          final midpoint = Offset(
            (current.dx + next.dx) / 2,
            (current.dy + next.dy) / 2,
          );
          path.quadraticBezierTo(
            current.dx,
            current.dy,
            midpoint.dx,
            midpoint.dy,
          );
        }
        path.lineTo(points.last.dx, points.last.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ImageAnnotationPainter oldDelegate) => true;
}

class _DrawingToolbar extends StatelessWidget {
  const _DrawingToolbar({
    required this.tool,
    required this.eraserMode,
    required this.straightLine,
    required this.thickness,
    required this.opacity,
    required this.color,
    required this.onToolChanged,
    required this.onEraserModeChanged,
    required this.onStraightChanged,
    required this.onThicknessChanged,
    required this.onOpacityChanged,
    required this.onColorChanged,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
  });

  final _AnnotationTool tool;
  final _EraserMode eraserMode;
  final bool straightLine;
  final double thickness;
  final double opacity;
  final Color color;
  final ValueChanged<_AnnotationTool> onToolChanged;
  final ValueChanged<_EraserMode> onEraserModeChanged;
  final ValueChanged<bool> onStraightChanged;
  final ValueChanged<double> onThicknessChanged;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<Color> onColorChanged;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  static const _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.black,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xE6202732),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DrawingChoice(
                    tooltip: 'Pen',
                    selected: tool == _AnnotationTool.pen,
                    icon: const Icon(Icons.draw_rounded),
                    onTap: () => onToolChanged(_AnnotationTool.pen),
                  ),
                  _DrawingChoice(
                    tooltip: 'Highlighter',
                    selected: tool == _AnnotationTool.highlighter,
                    icon: const Icon(Icons.border_color_rounded),
                    onTap: () => onToolChanged(_AnnotationTool.highlighter),
                  ),
                  _DrawingChoice(
                    tooltip: 'Eraser',
                    selected: tool == _AnnotationTool.eraser,
                    icon: const _EraserToolIcon(),
                    onTap: () => onToolChanged(_AnnotationTool.eraser),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
              decoration: BoxDecoration(
                color: const Color(0xF2202732),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Undo',
                        onPressed: canUndo ? onUndo : null,
                        color: Colors.white,
                        disabledColor: Colors.white24,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: tool == _AnnotationTool.eraser
                              ? [
                                  _LineChoice(
                                    tooltip: 'Erase whole line',
                                    selected: eraserMode == _EraserMode.line,
                                    icon: Icons.show_chart_rounded,
                                    onTap: () =>
                                        onEraserModeChanged(_EraserMode.line),
                                  ),
                                  const SizedBox(width: 10),
                                  _LineChoice(
                                    tooltip: 'Erase area',
                                    selected: eraserMode == _EraserMode.area,
                                    icon: Icons.blur_circular_rounded,
                                    onTap: () =>
                                        onEraserModeChanged(_EraserMode.area),
                                  ),
                                ]
                              : [
                                  _LineChoice(
                                    tooltip: 'Curved line',
                                    selected: !straightLine,
                                    icon: Icons.gesture_rounded,
                                    onTap: () => onStraightChanged(false),
                                  ),
                                  const SizedBox(width: 10),
                                  _LineChoice(
                                    tooltip: 'Straight line',
                                    selected: straightLine,
                                    icon: Icons.horizontal_rule_rounded,
                                    onTap: () => onStraightChanged(true),
                                  ),
                                ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Redo',
                        onPressed: canRedo ? onRedo : null,
                        color: Colors.white,
                        disabledColor: Colors.white24,
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                    ],
                  ),
                  _ToolbarSlider(
                    label: 'Thickness',
                    value: thickness,
                    min: 1,
                    max: 20,
                    onChanged: onThicknessChanged,
                  ),
                  _ToolbarSlider(
                    label: 'Opacity',
                    value: opacity,
                    min: 0.1,
                    max: 1,
                    onChanged: onOpacityChanged,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final option in _colors)
                        GestureDetector(
                          onTap: () => onColorChanged(option),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 31,
                            height: 31,
                            decoration: BoxDecoration(
                              color: option,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color.toARGB32() == option.toARGB32()
                                    ? memoryNumberCircleColor
                                    : Colors.white54,
                                width: color.toARGB32() == option.toARGB32()
                                    ? 3
                                    : 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawingPreview extends StatelessWidget {
  const _DrawingPreview({
    required this.tool,
    required this.thickness,
    required this.opacity,
    required this.color,
  });

  final _AnnotationTool tool;
  final double thickness;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final previewSize = (thickness * 1.8).clamp(10.0, 42.0);
    return SizedBox(
      height: 48,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: previewSize,
          height: previewSize,
          decoration: BoxDecoration(
            color: tool == _AnnotationTool.eraser
                ? Colors.white.withValues(alpha: opacity)
                : color.withValues(alpha: opacity),
            shape: tool == _AnnotationTool.highlighter
                ? BoxShape.rectangle
                : BoxShape.circle,
            borderRadius: tool == _AnnotationTool.highlighter
                ? BorderRadius.circular(3)
                : null,
          ),
        ),
      ),
    );
  }
}

class _DrawingChoice extends StatelessWidget {
  const _DrawingChoice({
    required this.tooltip,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final bool selected;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: selected
            ? memoryNumberCircleColor
            : Colors.transparent,
      ),
      icon: icon,
    );
  }
}

class _EraserToolIcon extends StatelessWidget {
  const _EraserToolIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 25,
      child: CustomPaint(painter: _EraserToolIconPainter()),
    );
  }
}

class _EraserToolIconPainter extends CustomPainter {
  const _EraserToolIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 25;
    final scaleY = size.height / 25;
    canvas.scale(scaleX, scaleY);
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final body = Path()
      ..moveTo(4.5, 15.5)
      ..lineTo(13.4, 6.6)
      ..quadraticBezierTo(14.8, 5.2, 16.3, 6.6)
      ..lineTo(21.1, 11.4)
      ..quadraticBezierTo(22.5, 12.8, 21.1, 14.3)
      ..lineTo(14.2, 21.2)
      ..quadraticBezierTo(12.8, 22.5, 11.3, 21.1)
      ..lineTo(4.5, 14.3)
      ..close();
    canvas.drawPath(body, paint);
    canvas.drawLine(const Offset(8.2, 11.8), const Offset(16.8, 20.4), paint);
    canvas.drawLine(const Offset(2.0, 22.2), const Offset(13.2, 22.2), paint);
  }

  @override
  bool shouldRepaint(covariant _EraserToolIconPainter oldDelegate) => false;
}

class _LineChoice extends StatelessWidget {
  const _LineChoice({
    required this.tooltip,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 62,
          height: 40,
          decoration: BoxDecoration(
            color: selected ? memoryNumberCircleColor : Colors.white10,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _ToolbarSlider extends StatelessWidget {
  const _ToolbarSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            activeColor: memoryNumberCircleColor,
            inactiveColor: Colors.white24,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _ImageStatusCircle extends StatelessWidget {
  const _ImageStatusCircle({
    required this.child,
    this.size = 34,
    this.backgroundColor,
  });

  final Widget child;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? memoryNumberCircleColor,
      ),
      child: child,
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
