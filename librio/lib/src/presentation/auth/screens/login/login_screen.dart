import 'package:flutter/material.dart';
import 'package:librio/src/data/data.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/presentation/presentation.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Focus nodes to track which field is selected
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late LoginViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = LoginViewModel(LoginUseCase(UserRepositoryImpl(AuthService())));
    viewModel.addListener(() => setState(() {}));
    _emailFocusNode = FocusNode()..addListener(() => setState(() {}));
    _passwordFocusNode = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    viewModel.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      viewModel.login(
        _emailController.text.trim(), // Remove espaços em branco
        _passwordController.text.trim(), // Remove espaços em branco
        context,
      );
    }
  }

  void _navigateToSignUp() {
    viewModel.navigateToSignup(context);
  }

  void _navigateToForgotPassword() {
    // TODO: Implementar navegação para a tela de "Esqueceu a senha"
    // context.push('/forgot-password');
    print('Navegar para esqueci minha senha');
  }

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 64),
              const Text(
                'Librio',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4ED8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 96),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    TextFormField(
                      focusNode: _emailFocusNode,
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: const Color(0xFFF0F3FF),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1D4ED8),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu email';
                        }
                        // Regex mais flexível e padrão para validação de email
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value.trim())) {
                          return 'Por favor, insira um email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Senha
                    TextFormField(
                      focusNode: _passwordFocusNode,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        filled: true,
                        fillColor: const Color(0xFFF0F3FF),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1D4ED8),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, right: 4.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _navigateToForgotPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Esqueceu sua senha?',
                            style: TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : _onLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4ED8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (viewModel.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          viewModel.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: _navigateToSignUp,
                child: const Text(
                  'Cadastre-se',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Ou continue com',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centralizar os botões sociais
                children: [
                  _SocialButton(
                    child: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    onPressed: () {
                      // TODO: Implementar login com Google
                    },
                  ),
                  const SizedBox(width: 20),
                  _SocialButton(
                    child: const Icon(
                      Icons.facebook,
                      size: 28,
                      color: Color(0xFF0866FF),
                    ),
                    onPressed: () {
                      // TODO: Implementar login com Facebook
                    },
                  ),
                  const SizedBox(width: 20),
                  _SocialButton(
                    child: Icon(
                      Icons.apple,
                      size: 28,
                      color: Colors.grey.shade800,
                    ),
                    onPressed: () {
                      // TODO: Implementar login com Apple
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32), // Espaço no final
            ],
          ),
        ),
      ),
    );
  }
}

// Widget _SocialButton (pode ser mantido como está ou ajustado)
class _SocialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  const _SocialButton({required this.child, required this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56, // Pode ajustar o tamanho se necessário
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white, // Fundo branco como na imagem
          borderRadius: BorderRadius.circular(12), // Bordas mais arredondadas
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // Sombra mais sutil
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
          // border: Border.all(color: Colors.grey.shade300) // Opcional: borda sutil
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
