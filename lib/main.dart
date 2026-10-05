import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:recalie/data/local/app_database.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/discover/discover_subjects.dart';
import 'package:recalie/features/photo_groups/photo_groups.dart';
import 'package:recalie/features/settings/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RecalieApp(database: AppDatabase.defaults()));
}

class RecalieApp extends StatefulWidget {
  const RecalieApp({
    super.key,
    required this.database,
    this.showPictureGroups = true,
  });

  final AppDatabase database;
  final bool showPictureGroups;

  @override
  State<RecalieApp> createState() => _RecalieAppState();
}

class _RecalieAppState extends State<RecalieApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late final LocalRepository _localRepository;

  @override
  void initState() {
    super.initState();
    _localRepository = LocalRepository(widget.database);
    _restoreTheme();
  }

  Future<void> _restoreTheme() async {
    final savedTheme = await _localRepository.readPreference('theme_mode');
    if (!mounted || savedTheme == null) return;
    setState(() {
      _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _setTheme(ThemeMode themeMode) async {
    setState(() => _themeMode = themeMode);
    await _localRepository.savePreference(
      'theme_mode',
      themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      ),
    );
  }
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
  });

  final LocalRepository localRepository;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final bool showPictureGroups;

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

  @override
  Widget build(BuildContext context) {
    final pages = [
      RecaliePage(
        title: 'Recalie',
        description:
            'Save images or text and recall them through increasing review gaps.',
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        lowerContent: widget.showPictureGroups
            ? PictureGroupsSection(repository: widget.localRepository)
            : null,
      ),
      RecaliePage(
        title: 'Discover',
        description: 'Find subjects and build memory sets around them.',
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        lowerContent: const DiscoverSubjects(),
      ),
      RecaliePage(
        title: 'AI Coach',
        description: 'Get thoughtful help whenever you need it.',
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: RecalieNavigationBar(
        currentIndex: _selectedIndex,
        onChanged: _selectTab,
        onAddPressed: () =>
            showAddPictureGroupSheet(context, widget.localRepository),
      ),
    );
  }
}

class RecaliePage extends StatelessWidget {
  const RecaliePage({
    super.key,
    required this.title,
    required this.description,
    required this.themeMode,
    required this.onThemeChanged,
    this.lowerContent,
  });

  final String title;
  final String description;
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
                const _ProfilePictureButton(),
                const Spacer(),
                _TopActionCapsule(
                  isDark: isDark,
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
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }
}

class _ProfilePictureButton extends StatelessWidget {
  const _ProfilePictureButton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Profile',
      child: InkWell(
        key: const Key('profileButton'),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile settings are coming soon.')),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: colors.primary.withValues(alpha: 0.16),
          child: Icon(Icons.person_rounded, color: colors.primary),
        ),
      ),
    );
  }
}

class _TopActionCapsule extends StatelessWidget {
  const _TopActionCapsule({
    required this.isDark,
    required this.onSettingsPressed,
  });

  final bool isDark;
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Premium is coming soon.')),
              );
            },
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
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
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                key: const Key('recalieAddButton'),
                width: 66,
                height: 66,
                decoration: _navigationDecoration(isDark),
                child: IconButton(
                  tooltip: 'Add memory set',
                  onPressed: onAddPressed,
                  icon: Icon(
                    Icons.add_rounded,
                    color: colors.primary,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _navigationDecoration(bool isDark) {
    return BoxDecoration(
      color: (isDark ? const Color(0xFF172033) : Colors.white).withValues(
        alpha: isDark ? 0.82 : 0.76,
      ),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.17)
                  : Colors.transparent,
            ),
            child: Icon(
              icon,
              color: isSelected ? colors.primary : colors.onSurfaceVariant,
              size: 25,
            ),
          ),
        ),
      ),
    );
  }
}
