import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../../../shared/runtime/app_runtime.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      if (AppRuntime.isDemoMode) {
        await Future.delayed(const Duration(milliseconds: 800));
        ref.read(demoLoggedInProvider.notifier).state = true;
      } else {
        await ref.read(authRepositoryProvider).signInWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
      }
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = _parseError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      if (AppRuntime.isDemoMode) {
        await Future.delayed(const Duration(milliseconds: 800));
        ref.read(demoLoggedInProvider.notifier).state = true;
      } else {
        await ref.read(authRepositoryProvider).signInWithGoogle();
      }
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = _parseError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseError(String error) {
    if (error.contains('user-not-found')) return 'No account found with this email.';
    if (error.contains('wrong-password')) return 'Incorrect password.';
    if (error.contains('too-many-requests')) return 'Too many attempts. Try again later.';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.backgroundDark, AppColors.surfaceDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Top gradient blob
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.primary.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    // Logo
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Icon(Icons.shopping_bag_rounded,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Bae Talk',
                          style: AppTextStyles.heading2.copyWith(color: Colors.white),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 48),

                    Text(
                      'Welcome Back! 👋',
                      style: AppTextStyles.heading1.copyWith(color: Colors.white),
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to continue shopping',
                      style: AppTextStyles.body.copyWith(color: Colors.white54),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 40),

                    // Error message
                    if (_error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Text(_error!,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Field
                    _AuthTextField(
                      controller: _emailCtrl,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'Enter email' :
                          !v.contains('@') ? 'Enter valid email' : null,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    // Password Field
                    _AuthTextField(
                      controller: _passCtrl,
                      label: 'Password',
                      icon: Icons.lock_outlined,
                      obscureText: _obscurePass,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Colors.white38,
                        ),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                      validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 12),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.label.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ).animate().fadeIn(delay: 450.ms),

                    const SizedBox(height: 24),

                    // Login Button
                    _GradientButton(
                      label: 'Sign In',
                      isLoading: _isLoading,
                      onTap: _login,
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.white12)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('or', style: AppTextStyles.caption.copyWith(color: Colors.white38)),
                        ),
                        const Expanded(child: Divider(color: Colors.white12)),
                      ],
                    ).animate().fadeIn(delay: 550.ms),

                    const SizedBox(height: 24),

                    // Google Sign In
                    _SocialButton(
                      label: 'Continue with Google',
                      icon: '🇬',
                      onTap: _googleLogin,
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 32),

                    // Sign Up Link
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: AppTextStyles.body.copyWith(color: Colors.white54),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 650.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontFamily: 'Poppins'),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        errorStyle: const TextStyle(color: AppColors.error, fontFamily: 'Poppins'),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(label,
                  style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;

  const _SocialButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(label,
              style: AppTextStyles.button.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
