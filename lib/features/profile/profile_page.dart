import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/plans/plan_access.dart';
import 'package:recalie/features/profile/profile_controller.dart';
import 'package:recalie/features/walnuts/walnut_profile_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.repository});

  final LocalRepository repository;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = RecalieProfileScope.of(context);
    final planScope = RecaliePlanScope.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: profile,
        builder: (context, _) => DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                colors.primary.withValues(alpha: isDark ? 0.48 : 0.40),
                colors.primaryContainer.withValues(alpha: isDark ? 0.27 : 0.36),
                colors.surface.withValues(alpha: 0.96),
                colors.surface,
              ],
              stops: const [0, 0.27, 0.62, 1],
            ),
          ),
          child: SafeArea(
            child: StreamBuilder<List<SavedPictureGroup>>(
              stream: repository.watchPictureGroups(),
              builder: (context, snapshot) {
                final groups = snapshot.data ?? const <SavedPictureGroup>[];
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton.filledTonal(
                            tooltip: 'Back',
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const Spacer(),
                          IconButton.filledTonal(
                            key: const Key('editProfileButton'),
                            tooltip: 'Edit profile',
                            onPressed: () => _editProfile(context, profile),
                            icon: const Icon(Icons.edit_rounded, size: 19),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _ProfilePhoto(bytes: profile.photoBytes, radius: 52),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name.isEmpty
                                      ? 'Your Name'
                                      : profile.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        height: 1.1,
                                      ),
                                ),
                                const SizedBox(height: 13),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _ProfileFact(
                                        label: 'Sets',
                                        value: '${groups.length}',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ProfileFact(
                                        label: 'Plan',
                                        value: planScope.plan.displayName,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: _ProfileFact(
                                        label: 'Active until',
                                        value: _profilePlanExpiryText(
                                          context,
                                          planScope,
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
                      const SizedBox(height: 28),
                      const WalnutProfileCard(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editProfile(
    BuildContext context,
    RecalieProfileController profile,
  ) async {
    var draftName = profile.name;
    var draftPhoto = profile.photoBytes;
    final picker = ImagePicker();
    final result = await showDialog<_ProfileDraft>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ProfilePhoto(bytes: draftPhoto, radius: 48),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 82,
                          maxWidth: 1200,
                        );
                        if (image == null) return;
                        final bytes = await image.readAsBytes();
                        setDialogState(() => draftPhoto = bytes);
                      },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(
                        draftPhoto == null ? 'Add photo' : 'Change photo',
                      ),
                    ),
                    if (draftPhoto != null)
                      TextButton.icon(
                        onPressed: () =>
                            setDialogState(() => draftPhoto = null),
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Remove'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('profileNameField'),
                  initialValue: draftName,
                  onChanged: (value) => draftName = value,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_ProfileDraft(name: draftName, photoBytes: draftPhoto)),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    await profile.update(name: result.name, photoBytes: result.photoBytes);
  }
}

String _profilePlanExpiryText(BuildContext context, RecaliePlanScope scope) {
  if (scope.plan == RecalieMembershipPlan.free || scope.expiresAt == null) {
    return 'No expiry';
  }
  return MaterialLocalizations.of(context).formatShortDate(scope.expiresAt!);
}

class _ProfileDraft {
  const _ProfileDraft({required this.name, required this.photoBytes});

  final String name;
  final Uint8List? photoBytes;
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.bytes, required this.radius});

  final Uint8List? bytes;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primary.withValues(alpha: 0.16),
      foregroundImage: bytes == null ? null : MemoryImage(bytes!),
      child: bytes == null
          ? Icon(Icons.person_rounded, color: colors.primary, size: radius)
          : null,
    );
  }
}

class _ProfileFact extends StatelessWidget {
  const _ProfileFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
