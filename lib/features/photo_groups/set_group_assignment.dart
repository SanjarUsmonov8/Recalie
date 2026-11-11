import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recalie/data/local/local_repository.dart';

enum SetGroupAssignmentType { none, existing, newGroup }

class SetGroupAssignment {
  const SetGroupAssignment._({
    required this.type,
    this.groupId,
    this.newGroupName,
    this.newGroupCover,
  });

  const SetGroupAssignment.none() : this._(type: SetGroupAssignmentType.none);

  const SetGroupAssignment.existing(int groupId)
    : this._(type: SetGroupAssignmentType.existing, groupId: groupId);

  const SetGroupAssignment.newGroup(String name, Uint8List? cover)
    : this._(
        type: SetGroupAssignmentType.newGroup,
        newGroupName: name,
        newGroupCover: cover,
      );

  final SetGroupAssignmentType type;
  final int? groupId;
  final String? newGroupName;
  final Uint8List? newGroupCover;

  String label(List<SavedMemorySetGroup> groups) {
    return switch (type) {
      SetGroupAssignmentType.none => 'Don\'t add to a group',
      SetGroupAssignmentType.existing =>
        groups
                .where((group) => group.id == groupId)
                .map((group) => group.name)
                .firstOrNull ??
            'Existing group',
      SetGroupAssignmentType.newGroup =>
        newGroupName?.trim().isNotEmpty == true
            ? newGroupName!.trim()
            : 'New group',
    };
  }
}

Future<SetGroupAssignment?> showSetGroupAssignmentDialog({
  required BuildContext context,
  required LocalRepository repository,
  required SetGroupAssignment initialValue,
}) async {
  final groups = await repository.getMemorySetGroups();
  if (!context.mounted) return null;
  var type = initialValue.type;
  var selectedGroupId = initialValue.groupId;
  if (type == SetGroupAssignmentType.existing &&
      !groups.any((group) => group.id == selectedGroupId)) {
    selectedGroupId = groups.firstOrNull?.id;
    if (selectedGroupId == null) type = SetGroupAssignmentType.none;
  }
  final nameController = TextEditingController(
    text: initialValue.newGroupName ?? '',
  );
  var cover = initialValue.newGroupCover;
  final picker = ImagePicker();

  final result = await showDialog<SetGroupAssignment>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Choose a group'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioGroup<SetGroupAssignmentType>(
                groupValue: type,
                onChanged: (value) {
                  if (value != null) setState(() => type = value);
                },
                child: Column(
                  children: [
                    const RadioListTile(
                      value: SetGroupAssignmentType.none,
                      title: Text('Don\'t add to a group'),
                    ),
                    RadioListTile(
                      value: SetGroupAssignmentType.existing,
                      enabled: groups.isNotEmpty,
                      title: const Text('Add to an existing group'),
                    ),
                    const RadioListTile(
                      value: SetGroupAssignmentType.newGroup,
                      title: Text('Add to a new group'),
                    ),
                  ],
                ),
              ),
              if (type == SetGroupAssignmentType.existing) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: selectedGroupId ?? groups.firstOrNull?.id,
                  decoration: const InputDecoration(
                    labelText: 'Group',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final group in groups)
                      DropdownMenuItem(
                        value: group.id,
                        child: Text(group.name),
                      ),
                  ],
                  onChanged: (value) => selectedGroupId = value,
                ),
              ],
              if (type == SetGroupAssignmentType.newGroup) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'New group name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final photo = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 88,
                      maxWidth: 1600,
                    );
                    if (photo == null) return;
                    final bytes = await photo.readAsBytes();
                    setState(() => cover = bytes);
                  },
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(
                    cover == null ? 'Choose group cover' : 'Change group cover',
                  ),
                ),
                if (cover != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      cover!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (type == SetGroupAssignmentType.none) {
                Navigator.of(
                  dialogContext,
                ).pop(const SetGroupAssignment.none());
                return;
              }
              if (type == SetGroupAssignmentType.existing) {
                final id = selectedGroupId ?? groups.firstOrNull?.id;
                if (id != null) {
                  Navigator.of(
                    dialogContext,
                  ).pop(SetGroupAssignment.existing(id));
                }
                return;
              }
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(
                  dialogContext,
                ).pop(SetGroupAssignment.newGroup(name, cover));
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    ),
  );
  nameController.dispose();
  return result;
}
