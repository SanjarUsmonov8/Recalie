import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/ads/rewarded_access_gate.dart';
import 'package:recalie/features/recall_plan/recall_plan_page.dart';

class MemorySetGroupsSection extends StatelessWidget {
  const MemorySetGroupsSection({super.key, required this.repository});

  final LocalRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SavedMemorySetGroup>>(
      stream: repository.watchMemorySetGroups(),
      builder: (context, snapshot) {
        final groups = snapshot.data ?? const <SavedMemorySetGroup>[];
        if (groups.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your groups',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groups.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 174 / 150,
              ),
              itemBuilder: (context, index) => _MemorySetGroupCard(
                group: groups[index],
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => MemorySetGroupPage(
                      repository: repository,
                      initialGroup: groups[index],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
          ],
        );
      },
    );
  }
}

class _MemorySetGroupCard extends StatelessWidget {
  const _MemorySetGroupCard({required this.group, required this.onTap});

  final SavedMemorySetGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _GroupCover(bytes: group.coverImageBytes),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colors.scrim.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${group.setCount} ${group.setCount == 1 ? 'set' : 'sets'}',
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
    );
  }
}

class MemorySetGroupPage extends StatefulWidget {
  const MemorySetGroupPage({
    super.key,
    required this.repository,
    required this.initialGroup,
  });

  final LocalRepository repository;
  final SavedMemorySetGroup initialGroup;

  @override
  State<MemorySetGroupPage> createState() => _MemorySetGroupPageState();
}

class _MemorySetGroupPageState extends State<MemorySetGroupPage> {
  late SavedMemorySetGroup _group = widget.initialGroup;

  Future<void> _editGroup() async {
    final nameController = TextEditingController(text: _group.name);
    var cover = _group.coverImageBytes;
    var replaceCover = false;
    final picker = ImagePicker();
    final result = await showModalBottomSheet<_GroupEditResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
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
                  'Edit group',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Group name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 88,
                      maxWidth: 1600,
                    );
                    if (image == null) return;
                    final bytes = await image.readAsBytes();
                    setSheetState(() {
                      cover = bytes;
                      replaceCover = true;
                    });
                  },
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(
                    cover == null ? 'Add cover image' : 'Change cover',
                  ),
                ),
                if (cover != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      cover!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;
                      Navigator.of(sheetContext).pop(
                        _GroupEditResult(
                          name: name,
                          cover: cover,
                          replaceCover: replaceCover,
                        ),
                      );
                    },
                    child: const Text('Save group'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    nameController.dispose();
    if (result == null || !mounted) return;
    await widget.repository.updateMemorySetGroup(
      groupId: _group.id,
      name: result.name,
      coverImageBytes: result.cover,
      replaceCover: result.replaceCover,
    );
    if (!mounted) return;
    setState(
      () => _group = SavedMemorySetGroup(
        id: _group.id,
        name: result.name,
        coverImageBytes: result.replaceCover
            ? result.cover
            : _group.coverImageBytes,
        setCount: _group.setCount,
      ),
    );
  }

  Future<void> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this group?'),
        content: const Text(
          'The group will be deleted, but its memory sets will stay on your home screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete group'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.repository.deleteMemorySetGroup(_group.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _openSet(SavedPictureGroup set) async {
    final granted = await RewardedAccessGate.requestAccess(
      context,
      contentName: '“${set.name}”',
    );
    if (!granted || !mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            RecallPlanPage(repository: widget.repository, group: set),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_group.name),
        actions: [
          IconButton(
            tooltip: 'Edit group',
            onPressed: _editGroup,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Delete group',
            onPressed: _deleteGroup,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: StreamBuilder<List<SavedPictureGroup>>(
        stream: widget.repository.watchPictureGroups(),
        builder: (context, snapshot) {
          final sets = (snapshot.data ?? const <SavedPictureGroup>[])
              .where((set) => set.memorySetGroupId == _group.id)
              .toList();
          if (sets.isEmpty) {
            return const Center(
              child: Text('No memory sets in this group yet.'),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            itemCount: sets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 174 / 210,
            ),
            itemBuilder: (context, index) => _GroupedSetCard(
              set: sets[index],
              onTap: () => _openSet(sets[index]),
            ),
          );
        },
      ),
    );
  }
}

class _GroupedSetCard extends StatelessWidget {
  const _GroupedSetCard({required this.set, required this.onTap});

  final SavedPictureGroup set;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (set.images.isNotEmpty)
              Image.memory(set.images.first, fit: BoxFit.cover)
            else
              ColoredBox(
                color: colors.primaryContainer,
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
                    Colors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: CircleAvatar(
                radius: 17,
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                child: Text('${set.setNumber}'),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Text(
                set.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCover extends StatelessWidget {
  const _GroupCover({required this.bytes});

  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    if (bytes != null) return Image.memory(bytes!, fit: BoxFit.cover);
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.tertiaryContainer],
        ),
      ),
      child: Icon(Icons.folder_copy_rounded, color: colors.primary, size: 52),
    );
  }
}

class _GroupEditResult {
  const _GroupEditResult({
    required this.name,
    required this.cover,
    required this.replaceCover,
  });

  final String name;
  final Uint8List? cover;
  final bool replaceCover;
}
