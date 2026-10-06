import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/photo_groups/memory_set_style.dart';
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
  bool _isSaving = false;
  bool _isLoadingNumber = true;

  @override
  void initState() {
    super.initState();
    _loadNextSetNumber();
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
