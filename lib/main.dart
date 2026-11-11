import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:recalie/data/local/app_database.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/ads/recalie_native_ad.dart';
import 'package:recalie/features/ai/ai_coach_panel.dart';
import 'package:recalie/features/discover/catalog_api.dart';
import 'package:recalie/features/discover/discover_subjects.dart';
import 'package:recalie/features/photo_groups/photo_groups.dart';
import 'package:recalie/features/plans/plan_access.dart';
import 'package:recalie/features/plans/plans_page.dart';
import 'package:recalie/features/profile/profile_controller.dart';
import 'package:recalie/features/profile/profile_page.dart';
import 'package:recalie/features/settings/settings_page.dart';
import 'package:recalie/features/walnuts/walnut_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    MobileAds.instance.initialize();
  }
  runApp(RecalieApp(database: AppDatabase.defaults()));
}

class RecalieApp extends StatefulWidget {
  const RecalieApp({
    super.key,
    required this.database,
    this.showPictureGroups = true,
    this.enableAds = true,
    this.catalogApiClient = const CatalogApiClient(),
  });

  final AppDatabase database;
  final bool showPictureGroups;
  final bool enableAds;
  final CatalogApiClient catalogApiClient;

  @override
  State<RecalieApp> createState() => _RecalieAppState();
}

class _RecalieAppState extends State<RecalieApp> {
  ThemeMode _themeMode = ThemeMode.light;
  RecalieMembershipPlan _membershipPlan = RecalieMembershipPlan.free;
  DateTime? _membershipPlanExpiresAt;
  late final LocalRepository _localRepository;
  late final RecalieProfileController _profileController;
  late final WalnutController _walnutController;

  @override
  void initState() {
    super.initState();
    _localRepository = LocalRepository(widget.database);
    _profileController = RecalieProfileController(_localRepository);
    _walnutController = WalnutController(_localRepository);
    _restoreTheme();
    _restoreMembershipPlan();
    _profileController.load();
    _walnutController.load();
  }

  @override
  void dispose() {
    _walnutController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  Future<void> _restoreTheme() async {
    final savedTheme = await _localRepository.readPreference('theme_mode');
    if (!mounted || savedTheme == null) return;
    setState(() {
      _themeMode = switch (savedTheme) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      };
    });
  }

  Future<void> _setTheme(ThemeMode themeMode) async {
    setState(() => _themeMode = themeMode);
    await _localRepository.savePreference('theme_mode', switch (themeMode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    });
  }

  Future<void> _restoreMembershipPlan() async {
    final savedPlan = await _localRepository.readPreference('membership_plan');
    final savedExpiry = await _localRepository.readPreference(
      'membership_plan_expires_at',
    );
    if (!mounted) return;
    var plan = RecalieMembershipPlanRules.fromStorage(savedPlan);
    var expiresAt = DateTime.tryParse(savedExpiry ?? '');
    final now = DateTime.now();
    if (plan != RecalieMembershipPlan.free && expiresAt == null) {
      expiresAt = _sameDayNextMonth(now);
      await _localRepository.savePreference(
        'membership_plan_expires_at',
        expiresAt.toIso8601String(),
      );
    } else if (plan != RecalieMembershipPlan.free && expiresAt!.isBefore(now)) {
      plan = RecalieMembershipPlan.free;
      expiresAt = null;
      await _localRepository.savePreference(
        'membership_plan',
        RecalieMembershipPlan.free.storageValue,
      );
      await _localRepository.savePreference('membership_plan_expires_at', '');
    }
    if (!mounted) return;
    setState(() {
      _membershipPlan = plan;
      _membershipPlanExpiresAt = expiresAt;
    });
  }

  Future<void> _setMembershipPlan(RecalieMembershipPlan plan) async {
    final expiresAt = plan == RecalieMembershipPlan.free
        ? null
        : _sameDayNextMonth(DateTime.now());
    setState(() {
      _membershipPlan = plan;
      _membershipPlanExpiresAt = expiresAt;
    });
    await _localRepository.savePreference('membership_plan', plan.storageValue);
    await _localRepository.savePreference(
      'membership_plan_expires_at',
      expiresAt?.toIso8601String() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return WalnutScope(
      controller: _walnutController,
      child: RecalieProfileScope(
        controller: _profileController,
        child: RecaliePlanScope(
          plan: _membershipPlan,
          expiresAt: _membershipPlanExpiresAt,
          onPlanChanged: _setMembershipPlan,
          child: MaterialApp(
            title: 'Recalie',
            debugShowCheckedModeBanner: false,
            themeMode: _themeMode,
            theme: _recalieTheme(Brightness.light),
            darkTheme: _recalieTheme(Brightness.dark),
            home: RecalieShell(
              localRepository: _localRepository,
              themeMode: _themeMode,
              onThemeChanged: _setTheme,
              showPictureGroups: widget.showPictureGroups,
              enableAds: widget.enableAds,
              catalogApiClient: widget.catalogApiClient,
            ),
          ),
        ),
      ),
    );
  }
}

DateTime _sameDayNextMonth(DateTime date) {
  final firstOfFollowingMonth = DateTime(date.year, date.month + 2);
  final lastDayOfNextMonth = firstOfFollowingMonth.subtract(
    const Duration(days: 1),
  );
  final day = date.day < lastDayOfNextMonth.day
      ? date.day
      : lastDayOfNextMonth.day;
  return DateTime(
    lastDayOfNextMonth.year,
    lastDayOfNextMonth.month,
    day,
    date.hour,
    date.minute,
    date.second,
  );
}

ThemeData _recalieTheme(Brightness brightness) {
  const blue = Color(0xFF2563EB);
  final isDark = brightness == Brightness.dark;
  final colors = ColorScheme.fromSeed(seedColor: blue, brightness: brightness);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colors,
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF0B1220)
        : const Color(0xFFF5F8FF),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF172033) : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}

class RecalieShell extends StatefulWidget {
  const RecalieShell({
    super.key,
    required this.localRepository,
    required this.themeMode,
    required this.onThemeChanged,
    required this.showPictureGroups,
    required this.enableAds,
    required this.catalogApiClient,
  });

  final LocalRepository localRepository;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final bool showPictureGroups;
  final bool enableAds;
  final CatalogApiClient catalogApiClient;

  @override
  State<RecalieShell> createState() => _RecalieShellState();
}

class _RecalieShellState extends State<RecalieShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _restoreSelectedTab();
  }

  Future<void> _restoreSelectedTab() async {
    final savedIndex = int.tryParse(
      await widget.localRepository.readPreference('selected_tab') ?? '',
    );
    if (!mounted || savedIndex == null || savedIndex < 0 || savedIndex > 2) {
      return;
    }
    setState(() => _selectedIndex = savedIndex);
  }

  Future<void> _selectTab(int index) async {
    setState(() => _selectedIndex = index);
    await widget.localRepository.savePreference('selected_tab', '$index');
  }

  Future<void> _addMemorySet() async {
    final plan = RecaliePlanScope.of(context).plan;
    final limit = plan.memorySetLimit;
    if (limit != null) {
      final count = await widget.localRepository.pictureGroupCount();
      if (!mounted) return;
      if (count >= limit) {
        await showPlanUpgradePrompt(
          context,
          title: 'Free plan limit reached',
          message:
              'Free includes up to $limit memory sets. Upgrade to Plus for unlimited sets.',
        );
        return;
      }
    }
    if (!mounted) return;
    await showAddPictureGroupSheet(context, widget.localRepository);
  }

  Future<void> _openProfile() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(repository: widget.localRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      RecaliePage(
        title: 'Recalie',
        onProfilePressed: _openProfile,
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        lowerContent: widget.showPictureGroups
            ? PictureGroupsSection(repository: widget.localRepository)
            : null,
      ),
      RecaliePage(
        title: 'Discover',
        onProfilePressed: _openProfile,
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        lowerContent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ForgettingCurveIntroduction(),
            if (widget.enableAds)
              const RecalieNativeAdCard(margin: EdgeInsets.only(top: 18)),
            DiscoverSubjects(
              repository: widget.localRepository,
              apiClient: widget.catalogApiClient,
              onViewHome: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                _selectTab(0);
              },
            ),
          ],
        ),
      ),
      RecaliePage(
        title: 'AI Coach',
        onProfilePressed: _openProfile,
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        lowerContent: const AiCoachPanel(),
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(index: _selectedIndex, children: pages),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RecalieNavigationBar(
              currentIndex: _selectedIndex,
              onChanged: _selectTab,
              onAddPressed: _addMemorySet,
            ),
          ),
        ],
      ),
    );
  }
}

class RecaliePage extends StatelessWidget {
  const RecaliePage({
    super.key,
    required this.title,
    required this.onProfilePressed,
    required this.themeMode,
    required this.onThemeChanged,
    this.lowerContent,
  });

  final String title;
  final VoidCallback onProfilePressed;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final Widget? lowerContent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = lowerContent ?? const SizedBox.shrink();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 118),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ProfilePictureButton(onPressed: onProfilePressed),
                const Spacer(),
                _TopActionCapsule(
                  isDark: isDark,
                  onPremiumPressed: () => openPlansPage(context),
                  onSettingsPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SettingsPage(
                        themeMode: themeMode,
                        onThemeChanged: onThemeChanged,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }
}

class _ForgettingCurveIntroduction extends StatelessWidget {
  const _ForgettingCurveIntroduction();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(top: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              'assets/images/herecalling diagram.png',
              width: double.infinity,
              fit: BoxFit.cover,
              semanticLabel: 'Diagram of the Ebbinghaus forgetting curve',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The forgetting curve: Hermann Ebbinghaus',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The forgetting curve describes how newly learned information can fade when it is not reviewed. Recalling it again at gradually increasing intervals strengthens the memory and helps slow that decline. Recalie uses this spaced-review technique to schedule each memory set when another recall is useful.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: colors.onSurfaceVariant,
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

class _ProfilePictureButton extends StatelessWidget {
  const _ProfilePictureButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final photoBytes = RecalieProfileScope.of(context).photoBytes;
    return Semantics(
      button: true,
      label: 'Profile',
      child: InkWell(
        key: const Key('profileButton'),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: colors.primary.withValues(alpha: 0.16),
          foregroundImage: photoBytes == null ? null : MemoryImage(photoBytes),
          child: photoBytes == null
              ? Icon(Icons.person_rounded, color: colors.primary)
              : null,
        ),
      ),
    );
  }
}

class _TopActionCapsule extends StatelessWidget {
  const _TopActionCapsule({
    required this.isDark,
    required this.onPremiumPressed,
    required this.onSettingsPressed,
  });

  final bool isDark;
  final VoidCallback onPremiumPressed;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        color: (isDark ? const Color(0xFF172033) : Colors.white).withValues(
          alpha: isDark ? 0.82 : 0.86,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: const Key('premiumButton'),
            tooltip: 'Premium',
            onPressed: onPremiumPressed,
            icon: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF38BDF8),
                  Color(0xFF2563EB),
                  Color(0xFF8B5CF6),
                ],
              ).createShader(bounds),
              child: const Icon(Icons.workspace_premium_rounded),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: colors.outlineVariant.withValues(alpha: 0.65),
          ),
          IconButton(
            key: const Key('settingsButton'),
            tooltip: 'Settings',
            onPressed: onSettingsPressed,
            icon: Icon(Icons.settings_rounded, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class RecalieNavigationBar extends StatelessWidget {
  const RecalieNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.onAddPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              key: const Key('recalieNavigationBar'),
              height: 66,
              padding: const EdgeInsets.all(7),
              decoration: _navigationDecoration(isDark),
              child: Row(
                children: [
                  _NavigationItem(
                    key: const Key('recalieNavHome'),
                    label: 'Home',
                    icon: Icons.home_rounded,
                    isSelected: currentIndex == 0,
                    colors: colors,
                    onTap: () => onChanged(0),
                  ),
                  _NavigationItem(
                    key: const Key('recalieNavDiscover'),
                    label: 'Discover',
                    icon: Icons.explore_rounded,
                    isSelected: currentIndex == 1,
                    colors: colors,
                    onTap: () => onChanged(1),
                  ),
                  _NavigationItem(
                    key: const Key('recalieNavAi'),
                    label: 'AI',
                    icon: Icons.auto_awesome_rounded,
                    isSelected: currentIndex == 2,
                    colors: colors,
                    onTap: () => onChanged(2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            key: const Key('recalieAddButton'),
            width: 66,
            height: 66,
            decoration: _navigationDecoration(isDark),
            child: IconButton(
              tooltip: 'Add memory set',
              onPressed: onAddPressed,
              icon: Icon(Icons.add_rounded, color: colors.primary, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _navigationDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF172033) : Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.10),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final ColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(23),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isSelected)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      color: colors.primary.withValues(alpha: 0.17),
                    ),
                  ),
                Center(
                  child: Icon(
                    icon,
                    color: isSelected
                        ? colors.primary
                        : colors.onSurfaceVariant,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
