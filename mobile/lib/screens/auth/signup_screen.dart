import 'package:material_ui/material_ui.dart';
import '../../services/api/auth_api.dart';
import '../../services/flagsmith_service.dart';
import '../../services/localization_service.dart';
import '../../theme/app_theme.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.mustAcceptTerms),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim().toLowerCase();
    final name = _nameController.text.trim();
    final password = _passwordController.text;
    final phone = _mobileController.text.trim();

    try {
      await AuthApi.sendSignupOtp(email: email);

      if (!mounted) return;
      setState(() => _isLoading = false);

      _showSignupOtpDialog(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
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

  void _showSignupOtpDialog({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) {
    final otpController = TextEditingController();
    bool isVerifying = false;
    bool isResending = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.mark_email_read_outlined, color: AppTheme.primarySaffron),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppStrings.otpDialogTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.otpDialogSubtitle,
                  style: const TextStyle(fontSize: 13, color: AppTheme.darkWood),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.chipBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    email,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepVermilion,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    hintText: '••••••',
                    counterText: '',
                    labelText: AppStrings.otpFieldLabel,
                    prefixIcon: const Icon(Icons.password, color: AppTheme.primarySaffron),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: isResending
                          ? null
                          : () async {
                              setDialogState(() => isResending = true);
                              try {
                                await AuthApi.sendSignupOtp(email: email);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppStrings.otpResentSuccess),
                                    backgroundColor: AppTheme.successGreen,
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString().replaceAll('ApiException: ', '')),
                                    backgroundColor: AppTheme.dangerRed,
                                  ),
                                );
                              } finally {
                                setDialogState(() => isResending = false);
                              }
                            },
                      icon: isResending
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.refresh, size: 16),
                      label: Text(AppStrings.resend, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isVerifying ? null : () => Navigator.pop(dialogCtx),
              child: Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: isVerifying
                  ? null
                  : () async {
                      final otp = otpController.text.trim();
                      if (otp.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppStrings.enterSixDigitOtp),
                            backgroundColor: AppTheme.dangerRed,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isVerifying = true);
                      try {
                        final res = await AuthApi.signup(
                          name: name,
                          email: email,
                          password: password,
                          phone: phone,
                          otp: otp,
                        );

                        if (!dialogCtx.mounted) return;
                        Navigator.pop(dialogCtx);
                        await FlagsmithService.identifyUser();
                        if (!mounted) return;

                        final userName = res['user']?['name'] ?? name;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${AppStrings.welcomeUser}, $userName! ${AppStrings.signupSuccess}'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      } catch (e) {
                        setDialogState(() => isVerifying = false);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceAll('ApiException: ', '')),
                            backgroundColor: AppTheme.dangerRed,
                          ),
                        );
                      }
                    },
              child: isVerifying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(AppStrings.verifyAndRegister),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: AppStrings.loginTitle,
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
        ),
        title: Text(AppStrings.signupTitle),
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
                  width: 72,
                  height: 72,
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
                  child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 14),

              Center(
                child: Text(
                  AppStrings.createAccountTitle,
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
                  AppStrings.signupSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 20),

              // Form Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Full Name
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: AppStrings.fullNameLabel,
                            hintText: AppStrings.fullNameHint,
                            prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primarySaffron),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppStrings.enterFullNamePrompt;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: AppStrings.emailLabel,
                            hintText: AppStrings.emailHint,
                            prefixIcon: const Icon(Icons.mail_outline, color: AppTheme.primarySaffron),
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
                        const SizedBox(height: 14),

                        // Mobile Phone - Optional
                        TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: AppStrings.mobileOptionalLabel,
                            hintText: '98765 43210',
                            prefixText: '+91 ',
                            prefixIcon: const Icon(Icons.phone_android_outlined, color: AppTheme.primarySaffron),
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty && val.trim().length < 10) {
                              return AppStrings.mobileValidationPrompt;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: AppStrings.createPasswordLabel,
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
                        const SizedBox(height: 14),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: AppStrings.confirmPasswordLabel,
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppTheme.primarySaffron),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppTheme.textMuted,
                              ),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return AppStrings.confirmPasswordPrompt;
                            }
                            if (val != _passwordController.text) {
                              return AppStrings.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Terms and Conditions Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _agreeToTerms,
                                activeColor: AppTheme.primarySaffron,
                                onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppStrings.acceptTerms,
                                style: const TextStyle(fontSize: 12, color: AppTheme.darkWood),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Submit Button
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleSignup,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.mark_email_read_outlined),
                          label: Text(_isLoading ? AppStrings.sendingOtp : AppStrings.getOtpAndRegister),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Already have an account row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${AppStrings.alreadyHaveAccount} ',
                    style: const TextStyle(color: AppTheme.darkWood),
                  ),
                  TextButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      }
                    },
                    child: Text(
                      AppStrings.loginLink,
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
