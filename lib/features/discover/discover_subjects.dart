import 'package:flutter/material.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/discover/catalog_api.dart';
import 'package:recalie/features/discover/subject_learning_pages.dart';

class DiscoverSubjects extends StatefulWidget {
  const DiscoverSubjects({
    super.key,
    required this.repository,
    this.apiClient = const CatalogApiClient(),
  });

  final LocalRepository repository;
  final CatalogApiClient apiClient;

  @override
  State<DiscoverSubjects> createState() => _DiscoverSubjectsState();
}

class _DiscoverSubjectsState extends State<DiscoverSubjects> {
  late Future<List<CatalogSubject>> _subjects;

  @override
  void initState() {
    super.initState();
    _subjects = widget.apiClient.fetchSubjects();
  }

  void _retry() {
    setState(() => _subjects = widget.apiClient.fetchSubjects());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Text(
          'Choose a subject',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Explore server-hosted review blocks and add the ones you want to remember.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        FutureBuilder<List<CatalogSubject>>(
          future: _subjects,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return _CatalogError(onRetry: _retry);
            }
            final subjects = snapshot.data ?? const <CatalogSubject>[];
            if (subjects.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No subjects are published yet.')),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: subjects.length,
              itemBuilder: (context, index) => _SubjectCard(
                subject: subjects[index],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SubjectOverviewPage(
                      subject: subjects[index],
                      apiClient: widget.apiClient,
                      repository: widget.repository,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not reach the Recalie catalog server.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject, required this.onTap});

  final CatalogSubject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SubjectCover(subject: subject)),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 11, 13, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subject.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.25,
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

class SubjectCover extends StatelessWidget {
  const SubjectCover({super.key, required this.subject});

  final CatalogSubject subject;

  @override
  Widget build(BuildContext context) {
    final start = colorFromHex(subject.colorStart, const Color(0xFF2563EB));
    final end = colorFromHex(subject.colorEnd, const Color(0xFF60A5FA));
    if (subject.coverImageUrl.isNotEmpty) {
      return Image.network(
        subject.coverImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            _GradientSubjectCover(subject: subject, start: start, end: end),
      );
    }
    return _GradientSubjectCover(subject: subject, start: start, end: end);
  }
}

class _GradientSubjectCover extends StatelessWidget {
  const _GradientSubjectCover({
    required this.subject,
    required this.start,
    required this.end,
  });

  final CatalogSubject subject;
  final Color start;
  final Color end;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: '${subject.name} cover image',
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [start, end],
          ),
        ),
        child: Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: Icon(
              iconForCatalogName(subject.icon),
              size: 42,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

Color colorFromHex(String value, Color fallback) {
  final hex = value.replaceFirst('#', '');
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null || hex.length != 6
      ? fallback
      : Color(0xFF000000 | parsed);
}

IconData iconForCatalogName(String value) => switch (value) {
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
