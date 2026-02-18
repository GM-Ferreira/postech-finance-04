import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/i_totp_repository.dart';
import '../../utils/dialogs.dart';
import '../../widgets/common/app_drawer.dart';
import '../../utils/formatters.dart';
import '../auth/totp_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool? _totpEnabled;

  @override
  void initState() {
    super.initState();
    _loadTotpStatus();
  }

  Future<void> _loadTotpStatus() async {
    final authProvider = context.read<AuthProvider>();
    final totpRepo = context.read<ITotpRepository>();
    final userId = authProvider.user?.uid;
    if (userId == null) return;

    try {
      final enabled = await totpRepo.isEnabled(userId);
      if (mounted) {
        setState(() => _totpEnabled = enabled);
      }
    } catch (e) {
      debugPrint('Failed to load TOTP status: $e');
      if (mounted) {
        setState(() => _totpEnabled = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(currentPage: DrawerPage.profile),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryGreen,
              child: Text(
                Formatters.initials(user?.displayName ?? user?.email ?? 'U'),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              user?.displayName ?? 'Usuário',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              user?.email ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 32),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.person,
                      label: 'Nome',
                      value: user?.displayName ?? 'Não informado',
                    ),

                    const Divider(height: 24),

                    _buildInfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: user?.email ?? 'Não informado',
                    ),

                    const Divider(height: 24),

                    _buildInfoRow(
                      icon: Icons.verified_user,
                      label: 'Email verificado',
                      value: user?.emailVerified == true ? 'Sim' : 'Não',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.edit,
                      color: AppTheme.primaryGreen,
                    ),
                    title: const Text('Editar nome'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _handleEditName(context),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(
                      Icons.lock,
                      color: AppTheme.primaryGreen,
                    ),
                    title: const Text('Alterar senha'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _handleChangePassword(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TOTP 2FA Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.security,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Autenticação em dois fatores',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'TOTP via app autenticador',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_totpEnabled == null)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _totpEnabled!
                                  ? Colors.green.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _totpEnabled! ? 'Ativado' : 'Desativado',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _totpEnabled!
                                    ? Colors.green
                                    : AppTheme.textGray,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: _totpEnabled == true
                          ? OutlinedButton(
                              onPressed: () => _handleDisableTotp(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text('Desativar'),
                            )
                          : ElevatedButton(
                              onPressed: () => _handleEnableTotp(context),
                              child: const Text('Ativar'),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  if (await AppDialogs.confirmLogout(context)) {
                    if (!context.mounted) return;
                    await context.read<AuthProvider>().logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthWrapper()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.exit_to_app, color: Colors.red),
                label: const Text('Sair da conta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEnableTotp(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TotpSetupScreen()),
    );

    if (result == true && mounted) {
      setState(() => _totpEnabled = true);
    }
  }

  Future<void> _handleDisableTotp(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Desativar 2FA'),
        content: const Text(
          'Tem certeza que deseja desativar a autenticação em dois fatores? '
          'Sua conta ficará menos segura.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final authProvider = context.read<AuthProvider>();
    final totpRepo = context.read<ITotpRepository>();
    final userId = authProvider.user?.uid;
    if (userId == null) return;

    await totpRepo.disable(userId);

    if (!mounted) return;
    setState(() => _totpEnabled = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Autenticação em dois fatores desativada.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleEditName(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final currentName = authProvider.user?.displayName ?? '';

    final newName = await AppDialogs.editName(
      context,
      currentName: currentName,
    );

    if (newName != null && newName != currentName) {
      if (!context.mounted) return;

      final success = await AppDialogs.showLoading(
        context,
        message: 'Atualizando nome...',
        operation: () => authProvider.updateName(newName),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Nome atualizado com sucesso!'
                : authProvider.errorMessage ?? 'Erro ao atualizar nome',
          ),
          backgroundColor: success ? AppTheme.primaryGreen : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleChangePassword(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    final result = await AppDialogs.changePassword(context);

    if (result != null) {
      if (!context.mounted) return;

      final success = await AppDialogs.showLoading(
        context,
        message: 'Alterando senha...',
        operation: () => authProvider.updatePassword(
          currentPassword: result['currentPassword']!,
          newPassword: result['newPassword']!,
        ),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Senha alterada com sucesso!'
                : authProvider.errorMessage ?? 'Erro ao alterar senha',
          ),
          backgroundColor: success ? AppTheme.primaryGreen : Colors.red,
        ),
      );
    }
  }
}
