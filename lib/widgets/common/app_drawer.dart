import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../screens/home/dashboard_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/transactions/transactions_screen.dart';
import '../../utils/dialogs.dart';
import '../../utils/formatters.dart';

enum DrawerPage { dashboard, transactions, profile }

class AppDrawer extends StatelessWidget {
  final DrawerPage currentPage;

  const AppDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryGreen),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                Formatters.initials(user?.displayName ?? user?.email ?? 'U'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
            accountName: Text(
              user?.displayName ?? 'Usuário',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user?.email ?? ''),
          ),
          _buildItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            page: DrawerPage.dashboard,
            destination: const DashboardScreen(),
          ),
          _buildItem(
            context,
            icon: Icons.receipt_long,
            title: 'Transações',
            page: DrawerPage.transactions,
            destination: const TransactionsScreen(),
          ),
          _buildItem(
            context,
            icon: Icons.person,
            title: 'Perfil',
            page: DrawerPage.profile,
            destination: const ProfileScreen(),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await AppDialogs.confirmLogout(context);
              if (!confirmed) return;
              if (!context.mounted) return;
              Navigator.pop(context);
              if (!context.mounted) return;
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthWrapper()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required DrawerPage page,
    required Widget destination,
  }) {
    final isSelected = currentPage == page;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: isSelected,
      selectedColor: AppTheme.primaryGreen,
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        }
      },
    );
  }
}
