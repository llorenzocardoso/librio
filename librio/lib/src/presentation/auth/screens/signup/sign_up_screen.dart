import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:librio/src/data/datasources/auth_service.dart';
import 'package:librio/src/data/repositories/user_repository_impl.dart';
import 'package:librio/src/domain/usecases/sign_up_usecase.dart';
import 'package:librio/src/presentation/auth/screens/signup/sign_up_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  // Focus nodes to track which field is selected
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;
  late FocusNode _nameFocusNode;

  late SignUpViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel =
        SignUpViewModel(SignUpUseCase(UserRepositoryImpl(AuthService())));
    viewModel.addListener(() => setState(() {}));
    _emailFocusNode = FocusNode()..addListener(() => setState(() {}));
    _passwordFocusNode = FocusNode()..addListener(() => setState(() {}));
    _confirmPasswordFocusNode = FocusNode()..addListener(() => setState(() {}));
    _nameFocusNode = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    viewModel.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _onSignUp() {
    if (_formKey.currentState!.validate()) {
      viewModel.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
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
                'Crie sua conta',
                style: TextStyle(
                  fontSize: 32,
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
                    // Name
                    TextFormField(
                      focusNode: _nameFocusNode,
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        filled: true,
                        fillColor: const Color(0xFFF1F4FF),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF1D4ED8)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome';
                        }
                        return null;
                      },
                    ),

                    // Email
                    TextFormField(
                      focusNode: _emailFocusNode,
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: const Color(0xFFF1F4FF),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF1D4ED8)),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu email';
                        }
                        // Add email validation
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Password
                    TextFormField(
                      focusNode: _passwordFocusNode,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        filled: true,
                        fillColor: const Color(0xFFF1F4FF),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF1D4ED8)),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Confirm password
                    TextFormField(
                      focusNode: _confirmPasswordFocusNode,
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirme sua senha',
                        filled: true,
                        fillColor: const Color(0xFFF1F4FF),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF1D4ED8)),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirme sua senha';
                        }
                        if (value != _passwordController.text) {
                          return 'As senhas não correspondem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : _onSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4ED8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Criar',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
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
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Já tenho uma conta',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Ou continue com',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SocialButton(
                    child: const Text('G', style: TextStyle(fontSize: 24)),
                    onPressed: () {},
                  ),
                  _SocialButton(
                    child: const Icon(Icons.facebook, size: 24),
                    onPressed: () {},
                  ),
                  _SocialButton(
                    child: const Icon(
                      Icons.apple,
                      size: 24,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Social Button widget
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
