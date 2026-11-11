import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:recalie/features/walnuts/walnut_controller.dart';

class WalnutProfileCard extends StatelessWidget {
  const WalnutProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WalnutScope.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final stage = controller.stage;
        final decoration = _walnutDecoration(context);
        return Container(
          key: const Key('walnutProfileCard'),
          width: double.infinity,
          decoration: decoration,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _showWalnutDetails(context, controller),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 21),
                child: Column(
                  children: [
                    Text(
                      'Your walnuts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Image.asset(
                      stage.assetPath,
                      key: const Key('walnutStageImage'),
                      height: 178,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                    Text(
                      stage.balanceLabel(controller.balance),
                      key: const Key('walnutBalanceLabel'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: stage.progressFor(controller.balance),
                        color: const Color(0xFFF28A24),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.58),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> _showWalnutDetails(
  BuildContext context,
  WalnutController controller,
) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close walnut details',
    barrierColor: Colors.black.withValues(alpha: 0.24),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              decoration: _walnutDecoration(dialogContext, radius: 32),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(32),
                clipBehavior: Clip.antiAlias,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) => _WalnutDetails(
                    controller: controller,
                    onClose: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _WalnutDetails extends StatelessWidget {
  const _WalnutDetails({required this.controller, required this.onClose});

  final WalnutController controller;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final stage = controller.stage;
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 20, 0),
          child: Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Back',
                onPressed: onClose,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 12),
              Text(
                'Your walnuts',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
            child: Column(
              children: [
                Image.asset(
                  stage.assetPath,
                  height: 270,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
                Text(
                  stage.label,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFE56B16),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  stage.balanceLabel(controller.balance),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 11,
                    value: stage.progressFor(controller.balance),
                    color: const Color(0xFFF28A24),
                    backgroundColor: colors.surface.withValues(alpha: 0.58),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'How to earn at this stage',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _RequirementTile(
                  icon: Icons.calendar_month_rounded,
                  title:
                      'Complete every required recall across all sets for a calendar week',
                  reward: stage.perfectWeekReward,
                ),
                const SizedBox(height: 10),
                _RequirementTile(
                  icon: Icons.event_available_rounded,
                  title:
                      'Finish a calendar week with only one required recall day missed',
                  reward: stage.oneMissedDayReward,
                ),
                const SizedBox(height: 10),
                _RequirementTile(
                  icon: Icons.collections_bookmark_rounded,
                  title:
                      'Complete every required recall for one memory set during a calendar week',
                  reward: stage.setWeekReward,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RequirementTile extends StatelessWidget {
  const _RequirementTile({
    required this.icon,
    required this.title,
    required this.reward,
  });

  final IconData icon;
  final String title;
  final int reward;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.14,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF28A24).withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFE56B16)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '+$reward',
            style: TextStyle(
              color: const Color(0xFFE56B16),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _walnutDecoration(BuildContext context, {double radius = 28}) {
  final colors = Theme.of(context).colorScheme;
  final dark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: colors.surface,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFFFC45B).withValues(alpha: dark ? 0.34 : 0.46),
        const Color(0xFFF28A24).withValues(alpha: dark ? 0.22 : 0.29),
        colors.surface.withValues(alpha: dark ? 0.94 : 0.88),
      ],
      stops: const [0, 0.48, 1],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: const Color(0xFFF28A24).withValues(alpha: dark ? 0.30 : 0.24),
    ),
    boxShadow: dark
        ? null
        : [
            BoxShadow(
              color: const Color(0xFFE56B16).withValues(alpha: 0.13),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
  );
}
