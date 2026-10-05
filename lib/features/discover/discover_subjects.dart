import 'package:flutter/material.dart';

class DiscoverSubjects extends StatelessWidget {
  const DiscoverSubjects({super.key});

  static const _subjects = <_DiscoverSubject>[
    _DiscoverSubject(
      name: 'English',
      subtitle: 'Words, grammar, and literature',
      icon: Icons.translate_rounded,
      colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
    ),
    _DiscoverSubject(
      name: 'Mathematics',
      subtitle: 'Formulas, rules, and methods',
      icon: Icons.calculate_rounded,
      colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    ),
    _DiscoverSubject(
      name: 'Physics',
      subtitle: 'Laws, units, and equations',
      icon: Icons.bolt_rounded,
      colors: [Color(0xFF0F766E), Color(0xFF2DD4BF)],
    ),
    _DiscoverSubject(
      name: 'Chemistry',
      subtitle: 'Elements, reactions, and structures',
      icon: Icons.science_rounded,
      colors: [Color(0xFFDB2777), Color(0xFFF472B6)],
    ),
    _DiscoverSubject(
      name: 'Biology',
      subtitle: 'Life, anatomy, and ecosystems',
      icon: Icons.biotech_rounded,
      colors: [Color(0xFF15803D), Color(0xFF4ADE80)],
    ),
    _DiscoverSubject(
      name: 'History',
      subtitle: 'Dates, people, and events',
      icon: Icons.account_balance_rounded,
      colors: [Color(0xFFB45309), Color(0xFFFBBF24)],
    ),
    _DiscoverSubject(
      name: 'Geography',
      subtitle: 'Places, maps, and environments',
      icon: Icons.public_rounded,
      colors: [Color(0xFF0369A1), Color(0xFF38BDF8)],
    ),
    _DiscoverSubject(
      name: 'Computer science',
      subtitle: 'Concepts, syntax, and systems',
      icon: Icons.code_rounded,
      colors: [Color(0xFF334155), Color(0xFF64748B)],
    ),
    _DiscoverSubject(
      name: 'Medicine',
      subtitle: 'Terms, systems, and treatments',
      icon: Icons.medical_services_rounded,
      colors: [Color(0xFFDC2626), Color(0xFFFB7185)],
    ),
    _DiscoverSubject(
      name: 'Law',
      subtitle: 'Cases, principles, and terminology',
      icon: Icons.gavel_rounded,
      colors: [Color(0xFF4338CA), Color(0xFF818CF8)],
    ),
  ];

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
          'Explore ideas for information you may want to remember.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: _subjects.length,
          itemBuilder: (context, index) =>
              _SubjectCard(subject: _subjects[index]),
        ),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject});

  final _DiscoverSubject subject;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _SubjectCover(subject: subject)),
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
    );
  }
}

class _SubjectCover extends StatelessWidget {
  const _SubjectCover({required this.subject});

  final _DiscoverSubject subject;

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
            colors: subject.colors,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -20,
              top: -24,
              child: Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.13),
                ),
              ),
            ),
            Positioned(
              left: -22,
              bottom: -35,
              child: Container(
                width: 115,
                height: 115,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(subject.icon, size: 42, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverSubject {
  const _DiscoverSubject({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}
