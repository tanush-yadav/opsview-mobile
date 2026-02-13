import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../viewmodels/profile_viewmodel.dart';

class ProfileDetailsStep extends ConsumerStatefulWidget {
  const ProfileDetailsStep({super.key});

  @override
  ConsumerState<ProfileDetailsStep> createState() => _ProfileDetailsStepState();
}

class _ProfileDetailsStepState extends ConsumerState<ProfileDetailsStep> {
  late final material.TextEditingController _fullNameController;
  late final material.TextEditingController _ageController;
  late final material.TextEditingController _mobileController;
  late final material.TextEditingController _aadhaarController;
  final List<material.TextEditingController> _otpControllers = [];
  final List<FocusNode> _otpFocusNodes = [];

  @override
  void initState() {
    super.initState();
    final state = ref.read(profileViewModelProvider);
    _fullNameController = material.TextEditingController(text: state.fullName);
    _ageController = material.TextEditingController(text: state.age);
    _mobileController = material.TextEditingController(
      text: state.mobileNumber,
    );
    _aadhaarController = material.TextEditingController(
      text: state.aadhaarNumber,
    );

    // Initialize OTP controllers and focus nodes (4 digits)
    for (int i = 0; i < 4; i++) {
      _otpControllers.add(
        material.TextEditingController(text: state.otpDigits[i]),
      );
      _otpFocusNodes.add(
        FocusNode(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              if (_otpControllers[i].text.isEmpty && i > 0) {
                // Clear previous controller and update state
                _otpControllers[i - 1].clear();
                ref
                    .read(profileViewModelProvider.notifier)
                    .updateOtpDigit(i - 1, '');
                _otpFocusNodes[i - 1].requestFocus();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _mobileController.dispose();
    _aadhaarController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final strings = ref.watch(appStringsProvider);
    final state = ref.watch(profileViewModelProvider);
    final viewModel = ref.read(profileViewModelProvider.notifier);

    ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        SnackBarUtils.error(context, next.error!);
      }
    });

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(strings.operatorProfile, style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text(strings.fillDetailsManually, style: AppTextStyles.muted),
          const SizedBox(height: 24),
          // Form Card
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    _buildFieldLabel(strings.fullName),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _fullNameController,
                      icon: Icons.person_outline,
                      onChanged: viewModel.updateFullName,
                      hasError: state.showNameError,
                    ),
                    if (state.showNameError)
                      _buildErrorText(strings.invalidName),
                    const SizedBox(height: 20),
                    // Age
                    _buildFieldLabel(strings.age),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _ageController,
                      icon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: viewModel.updateAge,
                      hasError: state.showAgeError,
                    ),
                    if (state.showAgeError) _buildErrorText(strings.invalidAge),
                    const SizedBox(height: 20),
                    // Mobile Number
                    _buildFieldLabel(strings.mobileNumber),
                    const SizedBox(height: 8),
                    _buildMobileField(state, strings),
                    if (state.showMobileError &&
                        !state.showOtpInput &&
                        !state.isMobileVerified)
                      _buildErrorText(strings.invalidMobile),
                    const SizedBox(height: 20),
                    // Aadhaar Number
                    _buildFieldLabel(strings.aadhaarNumber),
                    const SizedBox(height: 8),
                    _buildAadhaarField(state),
                    if (state.showAadhaarError)
                      _buildErrorText(strings.invalidAadhaar),
                  ],
                ),
              ),
            ),
          ),
          // Continue Button
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Consumer(
              builder: (context, ref, _) {
                // BUG-08 Fix: Enforce OTP verification when internet is available
                final connectivityAsync = ref.watch(connectivityProvider);
                final isOnline = connectivityAsync.when(
                  data: (results) => results.any((r) =>
                      r == ConnectivityResult.wifi ||
                      r == ConnectivityResult.mobile ||
                      r == ConnectivityResult.ethernet),
                  loading: () => false,
                  error: (_, __) => false,
                );
                
                // When online, require OTP verification; when offline, allow bypass
                final canProceed = state.isDetailsValid && 
                    (!isOnline || state.isMobileVerified);
                
                return PrimaryButton(
                  onPressed: canProceed
                      ? () {
                          FocusScope.of(context).unfocus();
                          viewModel.goToSelfie();
                        }
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        strings.continueToSelfie,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildErrorText(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required material.TextEditingController controller,
    required IconData icon,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    bool hasError = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: hasError ? Border.all(color: AppColors.error, width: 1) : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: hasError ? AppColors.error : AppColors.textMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: material.TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: keyboardType,
              style: AppTextStyles.body,
              decoration: const material.InputDecoration(
                border: material.InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileField(ProfileState state, AppStrings strings) {
    final viewModel = ref.read(profileViewModelProvider.notifier);
    final bool canVerify =
        state.mobileNumber.length >= 10 &&
        !state.isMobileVerified &&
        !state.showOtpInput;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.phone_android,
                size: 20,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: material.TextField(
                  controller: _mobileController,
                  onChanged: viewModel.updateMobileNumber,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.body,
                  enabled: !state.showOtpInput && !state.isMobileVerified,
                  decoration: const material.InputDecoration(
                    border: material.InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              // Always show button, but disable when < 10 digits
              GestureDetector(
                onTap: canVerify ? viewModel.verifyMobile : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: state.isMobileVerified
                        ? AppColors.success.withValues(alpha: 0.1)
                        : canVerify
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: state.isOtpLoading && !state.showOtpInput
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: material.CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textLight,
                          ),
                        )
                      : MediaQuery.withNoTextScaling(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (state.isMobileVerified) ...[
                                const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                state.isMobileVerified
                                    ? strings.verified.toUpperCase()
                                    : strings.verify,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: state.isMobileVerified
                                      ? AppColors.success
                                      : canVerify
                                      ? AppColors.textLight
                                      : AppColors.textLight.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        if (state.showOtpInput) ...[
          const SizedBox(height: 16),
          _buildOtpSection(state, strings),
        ],
      ],
    );
  }

  Widget _buildOtpSection(ProfileState state, AppStrings strings) {
    final viewModel = ref.read(profileViewModelProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with "Enter OTP" and "Change Number"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  strings.enterOtpSentToMobile,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  viewModel.cancelOtpVerification();
                  // Clear OTP controllers
                  for (final controller in _otpControllers) {
                    controller.clear();
                  }
                },
                child: Text(
                  strings.changeNumber,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // OTP Input Boxes (4 digits)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                width: 52,
                height: 56,
                margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: material.TextField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    onChanged: (value) {
                      if (value.length <= 1) {
                        viewModel.updateOtpDigit(index, value);
                        // Auto-focus next field
                        if (value.isNotEmpty && index < 3) {
                          _otpFocusNodes[index + 1].requestFocus();
                        }
                      }
                    },
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: AppTextStyles.h3,
                    decoration: const material.InputDecoration(
                      border: material.InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          // Resend OTP
          Center(
            child: GestureDetector(
              onTap: () {
                viewModel.resendOtp();
                // Clear OTP controllers
                for (final controller in _otpControllers) {
                  controller.clear();
                }
                _otpFocusNodes[0].requestFocus();
              },
              child: Text(
                strings.resendOtp,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Submit OTP Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: PrimaryButton(
              onPressed:
                  state.otpDigits.every((d) => d.isNotEmpty) &&
                      !state.isOtpLoading
                  ? () {
                      FocusScope.of(context).unfocus();
                      viewModel.submitOtp();
                    }
                  : null,
              child: state.isOtpLoading
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textLight,
                    )
                  : Text(
                      strings.submitOtp,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAadhaarField(ProfileState state) {
    final viewModel = ref.read(profileViewModelProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: material.TextField(
              controller: _aadhaarController,
              onChanged: viewModel.updateAadhaarNumber,
              keyboardType: TextInputType.number,
              obscureText: !state.isAadhaarVisible,
              obscuringCharacter: '•',
              style: AppTextStyles.body,
              decoration: const material.InputDecoration(
                border: material.InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          GestureDetector(
            onTap: viewModel.toggleAadhaarVisibility,
            child: Icon(
              state.isAadhaarVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
