import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/localization/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/utils/text_formatters.dart';
import '../../viewmodels/login_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _examCodeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _examCodeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final strings = ref.read(appStringsProvider);
    final examCode = _examCodeController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (examCode.isEmpty || username.isEmpty || password.isEmpty) {
      SnackBarUtils.warning(context, strings.fillAllFields);
      return;
    }

    final success = await ref.read(loginViewModelProvider.notifier).login(
          examCode: examCode,
          username: username,
          password: password,
        );

    if (!mounted) return;

    if (success) {
      SnackBarUtils.success(context, strings.loginSuccess);
      context.go(AppRoutes.confirmation);
    } else {
      final error = ref.read(loginViewModelProvider).error;
      SnackBarUtils.error(context, error ?? strings.loginFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final loginState = ref.watch(loginViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Hash Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.tag,
                          color: AppColors.textLight,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Welcome Back
                    Text(strings.welcomeBack, style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      strings.enterExamCredentials,
                      style: AppTextStyles.muted,
                    ),
                    const SizedBox(height: 32),
                    // Form Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 24,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Exam Code Field
                          Text(
                            strings.examCode,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBorderlessTextField(
                            controller: _examCodeController,
                            hintText: strings.examCodeHint,
                            icon: Icons.tag,
                            inputFormatters: [LowerCaseTextFormatter()],
                          ),
                          const Divider(height: 24, color: AppColors.border),
                          // Username Field
                          Text(
                            strings.username,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBorderlessTextField(
                            controller: _usernameController,
                            hintText: strings.usernameHint,
                            icon: Icons.person_outline,
                            inputFormatters: [LowerCaseTextFormatter()],
                          ),
                          const Divider(height: 24, color: AppColors.border),
                          // Password Field
                          Text(
                            strings.password,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBorderlessTextField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Login Button - Fixed at bottom
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: material.ElevatedButton(
                  onPressed: loginState.isLoading ? null : _handleLogin,
                  style: material.ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textLight,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: loginState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textLight,
                          ),
                        )
                      : Text(
                          strings.secureLogin,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorderlessTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: material.TextField(
            controller: controller,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            decoration: material.InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.textMuted),
              border: material.InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: AppTextStyles.body,
          ),
        ),
        if (suffixIcon != null) suffixIcon,
      ],
    );
  }
}
