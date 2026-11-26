import 'package:material_ui/material_ui.dart';
import '../../services/api/auth_api.dart';
import '../../services/flagsmith_service.dart';
import '../../services/localization_service.dart';
import '../../theme/app_theme.dart';
import '../home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    try {
      final res = await AuthApi.login(
        email: email,
        password: password,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['token'] != null) {
        _onLoginSuccess(res['user']?['name'] ?? email);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('ApiException: ', '')),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  void _onLoginSuccess(String userName) async {
    await FlagsmithService.identifyUser();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppStrings.welcomeUser}, $userName! ${AppStrings.loginSuccess}'),
        backgroundColor: AppTheme.successGreen,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _showForgotPasswordDialog() {
    final resetController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock_reset, color: AppTheme.primarySaffron),
            const SizedBox(width: 8),
            Text(AppStrings.resetPasswordTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.resetPasswordDesc,
              style: const TextStyle(fontSize: 13, color: AppTheme.darkWood),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: resetController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: AppStrings.emailLabel,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.resetLinkSent),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: Text(AppStrings.sendLink),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppStrings.loginTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Brand Badge
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primarySaffron, AppTheme.deepVermilion],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.deepVermilion.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 38),
                ),
              ),
              const SizedBox(height: 14),

              Center(
                child: Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepVermilion,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  AppStrings.loginSubtitle,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 24),

              // Login Form Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field (Strictly Email based)
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: AppStrings.emailLabel,
                            hintText: AppStrings.emailHint,
                            prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primarySaffron),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppStrings.enterEmailPrompt;
                            }
                            if (!val.contains('@') || !val.contains('.')) {
                              return AppStrings.enterValidEmailPrompt;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: AppStrings.passwordLabel,
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primarySaffron),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppTheme.textMuted,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return AppStrings.enterPasswordPrompt;
                            }
                            if (val.length < 6) {
                              return AppStrings.passwordMinLengthPrompt;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Remember Me & Forgot Password Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppTheme.primarySaffron,
                                    onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.rememberMe,
                                  style: const TextStyle(fontSize: 13, color: AppTheme.darkWood),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _showForgotPasswordDialog,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(
                                AppStrings.forgotPassword,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primarySaffron,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Submit Button
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleLogin,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.login),
                          label: Text(_isLoading ? AppStrings.loggingIn : AppStrings.loginButton),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sign Up Link Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${AppStrings.dontHaveAccount} ',
                    style: const TextStyle(color: AppTheme.darkWood),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: Text(
                      AppStrings.signUpLink,
                      style: const TextStyle(
                        color: AppTheme.deepVermilion,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
