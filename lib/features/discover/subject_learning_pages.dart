import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/discover/catalog_api.dart';
import 'package:recalie/features/discover/discover_subjects.dart';
import 'package:recalie/features/recall_plan/effective_recall_plan.dart';

class SubjectOverviewPage extends StatefulWidget {
  const SubjectOverviewPage({
    super.key,
    required this.subject,
    required this.apiClient,
    required this.repository,
    required this.onViewHome,
  });

  final CatalogSubject subject;
  final CatalogApiClient apiClient;
  final LocalRepository repository;
  final VoidCallback onViewHome;

  @override
  State<SubjectOverviewPage> createState() => _SubjectOverviewPageState();
}

class _SubjectOverviewPageState extends State<SubjectOverviewPage> {
  late Future<CatalogSubject> _subject;

  @override
  void initState() {
    super.initState();
    _subject = widget.apiClient.fetchSubject(widget.subject.slug);
  }

  void _retry() {
    setState(
      () => _subject = widget.apiClient.fetchSubject(widget.subject.slug),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<CatalogSubject>(
          future: _subject,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _SubjectLoadError(onRetry: _retry);
            }
            final subject = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 40),
              children: [
                _PageHeader(title: subject.name),
                const SizedBox(height: 14),
                SizedBox(
                  height: 190,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: SubjectCover(subject: subject),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Main parts',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a part, then select a review block sized for about one focused hour.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                for (var index = 0; index < subject.parts.length; index++) ...[
                  _PartCard(
                    number: index + 1,
                    part: subject.parts[index],
                    color: colorFromHex(
                      subject.colorStart,
                      Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SubjectPartPage(
                          subject: subject,
                          part: subject.parts[index],
                          repository: widget.repository,
                          onViewHome: widget.onViewHome,
                        ),
                      ),
                    ),
                  ),
                  if (index != subject.parts.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class SubjectPartPage extends StatelessWidget {
  const SubjectPartPage({
    super.key,
    required this.subject,
    required this.part,
    required this.repository,
    required this.onViewHome,
  });

  final CatalogSubject subject;
  final CatalogSubjectPart part;
  final LocalRepository repository;
  final VoidCallback onViewHome;

  @override
  Widget build(BuildContext context) {
    final accent = colorFromHex(
      subject.colorStart,
      Theme.of(context).colorScheme.primary,
    );
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 40),
          children: [
            _PageHeader(title: part.title),
            const SizedBox(height: 14),
            Text(
              subject.name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              part.description,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Review blocks',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              'Each block is designed for a focused 45–60 minute session.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            for (var index = 0; index < part.reviewBlocks.length; index++) ...[
              _ReviewBlockCard(
                number: index + 1,
                block: part.reviewBlocks[index],
                accent: accent,
                onInfo: () => _showReviewInfo(
                  context,
                  subjectName: subject.name,
                  partTitle: part.title,
                  block: part.reviewBlocks[index],
                  accent: accent,
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReviewBlockPage(
                      subject: subject,
                      part: part,
                      block: part.reviewBlocks[index],
                      repository: repository,
                      onViewHome: onViewHome,
                    ),
                  ),
                ),
              ),
              if (index != part.reviewBlocks.length - 1)
                const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class ReviewBlockPage extends StatefulWidget {
  const ReviewBlockPage({
    super.key,
    required this.subject,
    required this.part,
    required this.block,
    required this.repository,
    required this.onViewHome,
  });

  final CatalogSubject subject;
  final CatalogSubjectPart part;
  final CatalogReviewBlock block;
  final LocalRepository repository;
  final VoidCallback onViewHome;

  @override
  State<ReviewBlockPage> createState() => _ReviewBlockPageState();
}

class _ReviewBlockPageState extends State<ReviewBlockPage> {
  bool _isSaving = false;
  bool _added = false;

  Future<void> _addToHome() async {
    final selection = await _showPlanPicker(context);
    if (selection == null || !mounted) return;
    setState(() => _isSaving = true);
    try {
      await widget.repository.createPictureGroup(
        name: '${widget.subject.name} · ${widget.block.title}',
        images: const <Uint8List>[],
        textContent: widget.block.memoryText(
          subjectName: widget.subject.name,
          partTitle: widget.part.title,
        ),
        planType: selection.type.storageValue,
        planStartDate: selection.startDate,
        coverIcon: widget.subject.icon,
        coverColorStart: widget.subject.colorStart,
        coverColorEnd: widget.subject.colorEnd,
        coverImageUrl: widget.subject.coverImageUrl,
      );
      if (!mounted) return;
      setState(() => _added = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to Home.'),
          action: SnackBarAction(label: 'VIEW', onPressed: widget.onViewHome),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = colorFromHex(
      widget.subject.colorStart,
      Theme.of(context).colorScheme.primary,
    );
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 38),
          children: [
            _PageHeader(
              title: widget.block.title,
              trailing: OutlinedButton.icon(
                key: const Key('reviewBlockViewInfo'),
                onPressed: () => _showReviewInfo(
                  context,
                  subjectName: widget.subject.name,
                  partTitle: widget.part.title,
                  block: widget.block,
                  accent: accent,
                ),
                icon: const Icon(Icons.info_outline_rounded, size: 18),
                label: const Text('View info'),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                  icon: Icons.menu_book_rounded,
                  label: widget.subject.name,
                ),
                _InfoPill(
                  icon: Icons.schedule_rounded,
                  label: '${widget.block.estimatedMinutes} min',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ContentCard(
              title: 'Overview',
              child: Text(
                widget.block.summary,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            _BulletCard(
              title: 'Key points',
              values: widget.block.keyPoints,
              accent: accent,
            ),
            const SizedBox(height: 12),
            _StudySessionCard(
              minutes: widget.block.estimatedMinutes,
              accent: accent,
            ),
            const SizedBox(height: 12),
            _BulletCard(
              title: 'Active-recall prompts',
              values: widget.block.recallPrompts,
              accent: accent,
              numbered: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving || _added ? null : _addToHome,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _added ? Icons.check_rounded : Icons.add_home_rounded,
                      ),
                label: Text(_added ? 'Added to Home' : 'Recall this on Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

class _PartCard extends StatelessWidget {
  const _PartCard({
    required this.number,
    required this.part,
    required this.color,
    required this.onTap,
  });

  final int number;
  final CatalogSubjectPart part;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.16),
                foregroundColor: color,
                child: Text('$number'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      part.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewBlockCard extends StatelessWidget {
  const _ReviewBlockCard({
    required this.number,
    required this.block,
    required this.accent,
    required this.onInfo,
    required this.onTap,
  });

  final int number;
  final CatalogReviewBlock block;
  final Color accent;
  final VoidCallback onInfo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'BLOCK $number',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'View info',
                    onPressed: onInfo,
                    icon: const Icon(Icons.info_outline_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Icon(Icons.schedule_rounded, size: 17),
                  const SizedBox(width: 4),
                  Text('${block.estimatedMinutes} min'),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                block.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(block.summary, maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showReviewInfo(
  BuildContext context, {
  required String subjectName,
  required String partTitle,
  required CatalogReviewBlock block,
  required Color accent,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review information',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$subjectName · $partTitle',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                children: [
                  _ContentCard(
                    title: block.title,
                    child: Text(
                      block.summary,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _BulletCard(
                    title: 'Key ideas and formulas',
                    values: block.keyPoints,
                    accent: accent,
                  ),
                  const SizedBox(height: 12),
                  _BulletCard(
                    title: 'Questions to recall',
                    values: block.recallPrompts,
                    accent: accent,
                    numbered: true,
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 17), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({
    required this.title,
    required this.values,
    required this.accent,
    this.numbered = false,
  });

  final String title;
  final List<String> values;
  final Color accent;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    return _ContentCard(
      title: title,
      child: Column(
        children: [
          for (var index = 0; index < values.length; index++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.15),
                  ),
                  child: Text(
                    numbered ? '${index + 1}' : '•',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    values[index],
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
            if (index != values.length - 1) const SizedBox(height: 11),
          ],
        ],
      ),
    );
  }
}

class _StudySessionCard extends StatelessWidget {
  const _StudySessionCard({required this.minutes, required this.accent});

  final int minutes;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('Read and organize', '10 min'),
      ('Work through key ideas', '20 min'),
      ('Recall without notes', '15 min'),
      ('Check and summarize', '5 min'),
    ];
    return _ContentCard(
      title: 'Suggested $minutes-minute session',
      child: Column(
        children: [
          for (var index = 0; index < steps.length; index++) ...[
            Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: accent),
                const SizedBox(width: 10),
                Expanded(child: Text(steps[index].$1)),
                Text(
                  steps[index].$2,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            if (index != steps.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SubjectLoadError extends StatelessWidget {
  const _SubjectLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 12),
            const Text('This subject could not be loaded.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _PlanSelection {
  const _PlanSelection({required this.type, required this.startDate});

  final RecallPlanType type;
  final DateTime startDate;
}

Future<_PlanSelection?> _showPlanPicker(BuildContext context) {
  var selectedType = RecallPlanType.mostEffective;
  var startDate = dateOnly(DateTime.now());
  return showModalBottomSheet<_PlanSelection>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a recall plan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<RecallPlanType>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Plan',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final type in RecallPlanType.values)
                    DropdownMenuItem(
                      value: type,
                      child: Text('${type.label} plan'),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setSheetState(() => selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.calendar_month_rounded),
                  title: const Text('Plan start date'),
                  subtitle: Text(_dateLabel(startDate)),
                  trailing: const Icon(Icons.edit_calendar_rounded),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(DateTime.now().year + 20, 12, 31),
                    );
                    if (picked != null) {
                      setSheetState(() => startDate = picked);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(
                    _PlanSelection(type: selectedType, startDate: startDate),
                  ),
                  icon: const Icon(Icons.add_home_rounded),
                  label: const Text('Add to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _dateLabel(DateTime date) {
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
