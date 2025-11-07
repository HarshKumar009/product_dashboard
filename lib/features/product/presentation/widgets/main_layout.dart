import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:product_dashboard/core/blocs/theme_cubit.dart';
import 'package:product_dashboard/features/auth/presentation/blocs/auth_cubit.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/settings')) {
      return 1;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    Navigator.pop(context);
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 650) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Dashboard'),
              elevation: 1,
              shadowColor: Theme.of(context).shadowColor.withOpacity(0.3),
              actions: [
                IconButton(
                  icon: Icon(
                    context.watch<ThemeCubit>().state == ThemeMode.light
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  tooltip: 'Toggle Theme',
                  onPressed: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  offset: const Offset(0, 48),
                  tooltip: 'Profile',
                  icon: const CircleAvatar(child: Icon(Icons.person_outline)),
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.read<AuthCubit>().logout();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin User', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('admin@example.com', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _calculateSelectedIndex(context),
                  onDestinationSelected: (index) => context.go(index == 0 ? '/' : '/settings'),
                  labelType: NavigationRailLabelType.all,
                  minWidth: 88,
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: Text('Products')),
                    NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }
        else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
            ),
            body: child,
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // --- CHANGE START ---
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Theme.of(context).primaryColor,
                    ),
                    accountName: const Text('Harsh Kumar'),
                    accountEmail: const Text('harshchhabria399@gmail.com'),
                    currentAccountPicture: const CircleAvatar(
                      child: Icon(Icons.person, size: 40),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: const Text('Products'),
                    selected: _calculateSelectedIndex(context) == 0,
                    onTap: () => _onItemTapped(0, context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    selected: _calculateSelectedIndex(context) == 1,
                    onTap: () => _onItemTapped(1, context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      context.watch<ThemeCubit>().state == ThemeMode.light
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                    ),
                    title: const Text('Toggle Theme'),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AuthCubit>().logout();
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}