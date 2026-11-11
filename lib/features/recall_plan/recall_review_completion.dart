import 'dart:convert';

import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/recall_plan/effective_recall_plan.dart';

String imageReviewItemKey(int pictureId) => 'image:$pictureId';
String textReviewItemKey(int pageIndex) => 'text:$pageIndex';
String attachmentReviewItemKey(int attachmentId) => 'attachment:$attachmentId';

class RecallItemProgress {
  const RecallItemProgress({
    required this.target,
    required this.counts,
    required this.requirement,
  });

  final int target;
  final Map<String, int> counts;
  final RecallRequirement? requirement;

  int countFor(String itemKey) => (counts[itemKey] ?? 0).clamp(0, target);

  bool isComplete(String itemKey) => countFor(itemKey) >= target;
}

Future<RecallItemProgress> loadCurrentItemProgress({
  required LocalRepository repository,
  required SavedPictureGroup subject,
  DateTime? now,
}) async {
  final currentTime = now ?? DateTime.now();
  final plan = EffectiveRecallPlan(
    subject.planStartDate,
    type: RecallPlanType.fromStorage(subject.planType),
  );
  final requirement = plan.requirementFor(currentTime);
  final target = requirement?.targetRecalls ?? 1;
  final periodStart = requirement?.start ?? dateOnly(currentTime);
  final stored = await repository.readPreference(
    _progressPreferenceKey(subject.id, periodStart),
  );
  final counts = <String, int>{};
  if (stored != null && stored.isNotEmpty) {
    try {
      final decoded = jsonDecode(stored);
      if (decoded is Map<String, dynamic>) {
        for (final entry in decoded.entries) {
          final value = entry.value;
          if (value is num) counts[entry.key] = value.toInt();
        }
      }
    } on FormatException {
      // Ignore malformed legacy preference data and start this period cleanly.
    }
  }
  return RecallItemProgress(
    target: target,
    counts: Map.unmodifiable(counts),
    requirement: requirement,
  );
}

Future<RecallItemProgress> advanceItemReview({
  required LocalRepository repository,
  required SavedPictureGroup subject,
  required String itemKey,
  DateTime? now,
}) async {
  final currentTime = now ?? DateTime.now();
  final current = await loadCurrentItemProgress(
    repository: repository,
    subject: subject,
    now: currentTime,
  );
  final updated = Map<String, int>.from(current.counts);
  final oldCount = current.countFor(itemKey);
  updated[itemKey] = oldCount >= current.target ? 0 : oldCount + 1;
  final periodStart = current.requirement?.start ?? dateOnly(currentTime);
  await repository.savePreference(
    _progressPreferenceKey(subject.id, periodStart),
    jsonEncode(updated),
  );
  await repository.touchPictureGroup(subject.id);

  final result = RecallItemProgress(
    target: current.target,
    counts: Map.unmodifiable(updated),
    requirement: current.requirement,
  );
  await _completeRequirementIfReady(
    repository: repository,
    subject: subject,
    progress: result,
    now: currentTime,
  );
  return result;
}

Future<void> reorderTextItemProgress({
  required LocalRepository repository,
  required SavedPictureGroup subject,
  required int oldIndex,
  required int newIndex,
  DateTime? now,
}) async {
  final currentTime = now ?? DateTime.now();
  final current = await loadCurrentItemProgress(
    repository: repository,
    subject: subject,
    now: currentTime,
  );
  final pageCount = subject.textContent?.split('\f').length ?? 0;
  if (oldIndex < 0 ||
      oldIndex >= pageCount ||
      newIndex < 0 ||
      newIndex >= pageCount ||
      oldIndex == newIndex) {
    return;
  }
  final oldOrder = List<int>.generate(pageCount, (index) => index);
  final moved = oldOrder.removeAt(oldIndex);
  oldOrder.insert(newIndex, moved);
  final updated = Map<String, int>.from(current.counts)
    ..removeWhere((key, _) => key.startsWith('text:'));
  for (var index = 0; index < oldOrder.length; index++) {
    final count = current.countFor(textReviewItemKey(oldOrder[index]));
    if (count > 0) updated[textReviewItemKey(index)] = count;
  }
  final periodStart = current.requirement?.start ?? dateOnly(currentTime);
  await repository.savePreference(
    _progressPreferenceKey(subject.id, periodStart),
    jsonEncode(updated),
  );
}

Future<void> deleteItemProgress({
  required LocalRepository repository,
  required SavedPictureGroup subject,
  required Set<int> pictureIds,
  required Set<int> attachmentIds,
  required Set<int> textPageIndexes,
  DateTime? now,
}) async {
  final currentTime = now ?? DateTime.now();
  final current = await loadCurrentItemProgress(
    repository: repository,
    subject: subject,
    now: currentTime,
  );
  final updated = Map<String, int>.from(current.counts);
  for (final pictureId in pictureIds) {
    updated.remove(imageReviewItemKey(pictureId));
  }
  for (final attachmentId in attachmentIds) {
    updated.remove(attachmentReviewItemKey(attachmentId));
  }

  final pageCount = subject.textContent?.split('\f').length ?? 0;
  final keptPageIndexes = [
    for (var index = 0; index < pageCount; index++)
      if (!textPageIndexes.contains(index)) index,
  ];
  updated.removeWhere((key, _) => key.startsWith('text:'));
  for (var newIndex = 0; newIndex < keptPageIndexes.length; newIndex++) {
    final count = current.countFor(
      textReviewItemKey(keptPageIndexes[newIndex]),
    );
    if (count > 0) updated[textReviewItemKey(newIndex)] = count;
  }

  final periodStart = current.requirement?.start ?? dateOnly(currentTime);
  await repository.savePreference(
    _progressPreferenceKey(subject.id, periodStart),
    jsonEncode(updated),
  );
}

Future<bool> completeTodayIfEveryItemIsReviewed({
  required LocalRepository repository,
  required int subjectId,
}) async {
  final subject = await repository.getPictureGroup(subjectId);
  if (subject == null) return false;
  final progress = await loadCurrentItemProgress(
    repository: repository,
    subject: subject,
  );
  return _completeRequirementIfReady(
    repository: repository,
    subject: subject,
    progress: progress,
    now: DateTime.now(),
  );
}

List<String> reviewItemKeysFor(SavedPictureGroup subject) {
  final pages =
      subject.textContent == null || subject.textContent!.trim().isEmpty
      ? const <String>[]
      : subject.textContent!.split('\f');
  return [
    for (final picture in subject.pictures) imageReviewItemKey(picture.id),
    for (var index = 0; index < pages.length; index++) textReviewItemKey(index),
    for (final attachment in subject.attachments)
      attachmentReviewItemKey(attachment.id),
  ];
}

Future<bool> _completeRequirementIfReady({
  required LocalRepository repository,
  required SavedPictureGroup subject,
  required RecallItemProgress progress,
  required DateTime now,
}) async {
  final requirement = progress.requirement;
  final itemKeys = reviewItemKeysFor(subject);
  if (requirement == null ||
      itemKeys.isEmpty ||
      !itemKeys.every(progress.isComplete)) {
    return false;
  }

  final recalls = await repository.watchRecallEvents(subject.id).first;
  final completed = recalls
      .where((event) => requirement.contains(event.recalledAt))
      .length;
  final missing = requirement.targetRecalls - completed;
  if (missing <= 0) return false;

  for (var index = 0; index < missing; index++) {
    await repository.recordRecall(
      subject.id,
      now.add(Duration(milliseconds: index)),
    );
  }
  return true;
}

String _progressPreferenceKey(int subjectId, DateTime periodStart) =>
    'recall_item_progress_${subjectId}_${periodStart.millisecondsSinceEpoch}';
