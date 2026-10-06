import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/recall_plan/effective_recall_plan.dart';

Future<bool> completeTodayIfEveryItemIsReviewed({
  required LocalRepository repository,
  required int subjectId,
}) async {
  final subject = await repository.getPictureGroup(subjectId);
  if (subject == null) return false;

  final pages =
      subject.textContent == null || subject.textContent!.trim().isEmpty
      ? const <String>[]
      : subject.textContent!.split('\f');
  final stored = await repository.readPreference(
    'subject_text_reviewed_$subjectId',
  );
  final reviewedPages = <int>{};
  if (stored != null && stored.isNotEmpty) {
    for (final part in stored.split(',')) {
      final page = int.tryParse(part);
      if (page != null) reviewedPages.add(page);
    }
  }

  final allPicturesReviewed = subject.pictures.every(
    (picture) => picture.isReviewed,
  );
  final allPagesReviewed = List.generate(
    pages.length,
    reviewedPages.contains,
  ).every((reviewed) => reviewed);
  final itemCount = subject.pictures.length + pages.length;
  if (itemCount == 0 || !allPicturesReviewed || !allPagesReviewed) {
    return false;
  }

  final now = DateTime.now();
  final plan = EffectiveRecallPlan(
    subject.planStartDate,
    type: RecallPlanType.fromStorage(subject.planType),
  );
  final requirement = plan.requirementFor(now);
  if (requirement == null) return false;

  final recalls = await repository.watchRecallEvents(subjectId).first;
  final completed = recalls
      .where((event) => requirement.contains(event.recalledAt))
      .length;
  final missing = requirement.targetRecalls - completed;
  if (missing <= 0) return false;

  for (var index = 0; index < missing; index++) {
    await repository.recordRecall(
      subjectId,
      now.add(Duration(milliseconds: index)),
    );
  }
  return true;
}
