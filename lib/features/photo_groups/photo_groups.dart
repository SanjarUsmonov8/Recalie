import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recalie/data/local/local_repository.dart';
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
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
              itemCount: groups.length,
              itemBuilder: (context, index) => _PictureGroupCard(
                repository: repository,
                group: groups[index],
              ),
            ),
          ],
        );
      },
    );
  }
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
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  RecallPlanPage(repository: repository, group: group),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (group.images.isNotEmpty)
                Image.memory(group.images.first, fit: BoxFit.cover)
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

class _AddPictureGroupSheet extends StatefulWidget {
  const _AddPictureGroupSheet({required this.repository});

  final LocalRepository repository;

  @override
  State<_AddPictureGroupSheet> createState() => _AddPictureGroupSheetState();
}

class _AddPictureGroupSheetState extends State<_AddPictureGroupSheet> {
  final _nameController = TextEditingController();
  final _textController = TextEditingController();
  final _picker = ImagePicker();
  List<XFile> _photos = const [];
  DateTime _startDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  RecallPlanType _planType = RecallPlanType.mostEffective;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
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

    setState(() => _isSaving = true);
    try {
      final images = <Uint8List>[];
      for (final photo in _photos) {
        images.add(await photo.readAsBytes());
      }
      await widget.repository.createPictureGroup(
        name: _nameController.text,
        images: images,
        textContent: _textController.text,
        planStartDate: _startDate,
        planType: _planType.storageValue,
      );
      if (mounted) Navigator.of(context).pop();
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
                    itemBuilder: (context, index) =>
                        _PickedPhotoPreview(photo: _photos[index]),
                  ),
                ),
              ],
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
                  label: Text('Start ${_planType.label} plan'),
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
        title: Text('${type.label} plan'),
        subtitle: Text(description),
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
  const _PickedPhotoPreview({required this.photo});

  final XFile photo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: photo.readAsBytes(),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: bytes == null
              ? const SizedBox(
                  width: 84,
                  height: 84,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Image.memory(bytes, width: 84, height: 84, fit: BoxFit.cover),
        );
      },
    );
  }
}
