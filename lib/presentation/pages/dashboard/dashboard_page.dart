import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';

class DashboardPage extends StatelessWidget {
  final Widget child;
  const DashboardPage({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    const paths = ['/map', '/posts', '/create', '/notifications', '/profile'];
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < paths.length; i++) {
      if (location.startsWith(paths[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final selected = _selectedIndex(context);

    final tabs = [
      _Tab(
        icon: Icons.map_outlined,
        activeIcon: Icons.map_rounded,
        label: l.tabMap,
        path: '/map',
      ),
      _Tab(
        icon: Icons.article_outlined,
        activeIcon: Icons.article_rounded,
        label: l.tabPosts,
        path: '/posts',
      ),
      _Tab(
        icon: Icons.add,
        activeIcon: Icons.add,
        label: l.tabCreate,
        path: '/create',
        isFab: true,
      ),
      _Tab(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications_rounded,
        label: l.tabNotifications,
        path: '/notifications',
      ),
      _Tab(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: l.tabProfile,
        path: '/profile',
      ),
    ];

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: _FloatingNavBar(
        tabs: tabs,
        selectedIndex: selected,
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final List<_Tab> tabs;
  final int selectedIndex;
  const _FloatingNavBar(
      {required this.tabs, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          boxShadow: AppColors.clayShadow(
              color: AppColors.primary, elevation: 1.2),
          border: Border.all(color: AppColors.borderLight, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(33),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final tab = tabs[i];
              final isSelected = selectedIndex == i;

              if (tab.isFab) {
                // ── FAB centre button ────────────────────────────────────
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(tab.path),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? AppColors.ctaGradient
                              : AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.clayShadow(
                            color: isSelected
                                ? AppColors.cta
                                : AppColors.primary,
                            elevation: 0.8,
                          ),
                        ),
                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 300),
                          turns: isSelected ? 0.125 : 0,
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 26),
                        ),
                      ),
                    ),
                  ),
                );
              }

              // ── Regular tab ────────────────────────────────────────────
              return Expanded(
                child: GestureDetector(
                  onTap: () => context.go(tab.path),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: isSelected ? 40 : 30,
                        height: isSelected ? 40 : 30,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isSelected ? tab.activeIcon : tab.icon,
                          size: isSelected ? 22 : 20,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: isSelected ? 10.5 : 10,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textHint,
                        ),
                        child: Text(tab.label),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  final bool isFab;
  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
    this.isFab = false,
  });
}
