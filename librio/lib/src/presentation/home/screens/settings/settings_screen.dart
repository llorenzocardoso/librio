import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/presentation/presentation.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel();
    _viewModel.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChange() {
    setState(() {});

    // Mostrar mensagens de erro ou sucesso
    if (_viewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error!),
          backgroundColor: Colors.red,
        ),
      );
      _viewModel.clearMessages();
    }

    if (_viewModel.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.successMessage!),
          backgroundColor: Colors.green,
        ),
      );
      _viewModel.clearMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fb.User? user = _viewModel.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Configurações',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Seção de Perfil
                _buildSectionHeader('Perfil'),
                _buildSettingsCard([
                  _buildSettingsTile(
                    icon: Icons.person_outline,
                    title: 'Editar perfil',
                    subtitle: 'Alterar informações pessoais e descrição',
                    onTap: () => _viewModel.navigateToEditProfile(context),
                  ),
                ]),

                const SizedBox(height: 24),

                // Seção de Conta
                _buildSectionHeader('Conta'),
                _buildSettingsCard([
                  _buildSettingsTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: user?.email ?? 'Não informado',
                    onTap: null, // Não clicável por enquanto
                  ),
                ]),

                const SizedBox(height: 24),

                // Seção de Localização
                _buildSectionHeader('Localização'),
                _buildSettingsCard([
                  _buildSettingsTile(
                    icon: Icons.location_on,
                    title: 'Configurações de Localização',
                    subtitle: 'Gerenciar localização e distância',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LocationSettingsScreen(),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // Botão de Sair
                _buildSettingsCard([
                  _buildSettingsTile(
                    icon: Icons.logout,
                    title: 'Sair',
                    subtitle: 'Fazer logout da conta',
                    titleColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ]),

                const SizedBox(height: 32),

                // Informações da versão
                Center(
                  child: Text(
                    'Librio v1.0.0',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.grey[700],
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor ?? Colors.black87,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair da conta'),
          content: const Text('Tem certeza que deseja fazer logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Fechar dialog
                await _viewModel.signOut();
                if (mounted) {
                  _viewModel.navigateToLogin(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alterar senha'),
          content: const Text(
            'Será enviado um email com instruções para redefinir sua senha.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _viewModel.sendPasswordResetEmail();
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
}
