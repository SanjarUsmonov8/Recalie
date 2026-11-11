import 'package:flutter/material.dart';
import 'package:recalie/features/plans/plan_access.dart';

Future<void> openPlansPage(
  BuildContext context, {
  RecalieMembershipPlan? initialPlan,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => PlansPage(initialPlan: initialPlan),
    ),
  );
}

Future<void> showPlanUpgradePrompt(
  BuildContext context, {
  required String title,
  required String message,
  RecalieMembershipPlan target = RecalieMembershipPlan.plus,
}) async {
  final upgrade = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.workspace_premium_rounded, size: 34),
      title: Text(title),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text('View ${target.displayName}'),
        ),
      ],
    ),
  );
  if (upgrade == true && context.mounted) {
    await openPlansPage(context, initialPlan: target);
  }
}

class PlansPage extends StatefulWidget {
  const PlansPage({super.key, this.initialPlan});

  final RecalieMembershipPlan? initialPlan;

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final Map<RecalieMembershipPlan, GlobalKey> _keys = {
    for (final plan in RecalieMembershipPlan.values) plan: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = widget.initialPlan;
      final targetContext = target == null
          ? null
          : _keys[target]?.currentContext;
      if (targetContext == null) return;
      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.08,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = RecaliePlanScope.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF38BDF8), Color(0xFF2563EB), Color(0xFF8B5CF6)],
          ).createShader(bounds),
          child: const Text(
            'Choose your plan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose how you want to build and review your memory sets.',
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 20),
            KeyedSubtree(
              key: _keys[RecalieMembershipPlan.free],
              child: _PlanCard(
                plan: RecalieMembershipPlan.free,
                price: r'$0',
                features: const [
                  'Up to 4 memory sets',
                  'Images and notes',
                  'Subjects remain visible but locked',
                  'Native and rewarded ads',
                ],
                selected: scope.plan == RecalieMembershipPlan.free,
                onPressed: () =>
                    scope.onPlanChanged(RecalieMembershipPlan.free),
              ),
            ),
            const SizedBox(height: 16),
            KeyedSubtree(
              key: _keys[RecalieMembershipPlan.plus],
              child: _PlanCard(
                plan: RecalieMembershipPlan.plus,
                price: r'$1.99 / month',
                accent: const Color(0xFFF2B72B),
                features: const [
                  'Unlimited memory sets',
                  'Images, notes, files, audio and video',
                  'Full Discover access',
                  'Native and rewarded ads',
                ],
                selected: scope.plan == RecalieMembershipPlan.plus,
                onPressed: () =>
                    scope.onPlanChanged(RecalieMembershipPlan.plus),
              ),
            ),
            const SizedBox(height: 16),
            KeyedSubtree(
              key: _keys[RecalieMembershipPlan.pro],
              child: _PlanCard(
                plan: RecalieMembershipPlan.pro,
                price: r'$4.99 / month',
                accent: const Color(0xFF3E9B72),
                features: const [
                  'Unlimited memory sets',
                  'Every available item format',
                  'Full Discover access',
                  'No native or rewarded ads',
                ],
                selected: scope.plan == RecalieMembershipPlan.pro,
                onPressed: () => scope.onPlanChanged(RecalieMembershipPlan.pro),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Plan selection is saved locally for testing. Store billing will be connected before release.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.price,
    required this.features,
    required this.selected,
    required this.onPressed,
    this.accent,
  });

  final RecalieMembershipPlan plan;
  final String price;
  final List<String> features;
  final bool selected;
  final Future<void> Function() onPressed;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardAccent = accent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        gradient: cardAccent == null
            ? null
            : RadialGradient(
                center: Alignment.topRight,
                radius: 1.3,
                colors: [
                  cardAccent.withValues(alpha: isDark ? 0.42 : 0.22),
                  cardAccent.withValues(alpha: isDark ? 0.16 : 0.08),
                  Colors.transparent,
                ],
                stops: const [0, 0.42, 1],
              ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: cardAccent == null
                    ? Text(
                        plan.displayName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      )
                    : ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            cardAccent.withValues(alpha: 0.8),
                            cardAccent,
                            colors.primary,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          plan.displayName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: colors.primary),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            price,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          for (final feature in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 19,
                    color: cardAccent ?? colors.primary,
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: Text(feature)),
                ],
              ),
            ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: selected ? null : onPressed,
              child: Text(
                selected ? 'Current plan' : 'Choose ${plan.displayName}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
