import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../core/localization/app_strings.dart';
import '../core/providers/app_state_provider.dart';
import '../services/api/api_service.dart';
import '../services/database/app_database.dart';
import '../core/enums/location_status.dart';


enum ProfileStep { details, selfie }

class ProfileState {
  const ProfileState({
    this.currentStep = ProfileStep.details,
    this.fullName = '',
    this.age = '',
    this.mobileNumber = '',
    this.aadhaarNumber = '',
    this.isAadhaarVisible = false,
    this.selfieImagePath,
    this.isLoading = false,
    this.error,
    this.showOtpInput = false,
    this.otpDigits = const ['', '', '', ''],
    this.isOtpLoading = false,
    this.mobileVerificationId,
    this.locationStatus = LocationStatus.idle,
    this.currentLat,
    this.currentLng,
    this.centerLat,
    this.centerLng,
    this.distanceFromCenter,
    this.livenessScore,
  });
  final ProfileStep currentStep;
  final String fullName;
  final String age;
  final String mobileNumber;
  final String aadhaarNumber;
  final bool isAadhaarVisible;
  final String? selfieImagePath;
  final bool isLoading;
  final String? error;
  // OTP
  final bool showOtpInput;
  final List<String> otpDigits;
  final bool isOtpLoading;
  final String? mobileVerificationId;
  // Location
  final LocationStatus locationStatus;
  final double? currentLat;
  final double? currentLng;
  final double? centerLat;
  final double? centerLng;
  final double? distanceFromCenter;
  // Liveness
  final double? livenessScore;

  ProfileState copyWith({
    ProfileStep? currentStep,
    String? fullName,
    String? age,
    String? mobileNumber,
    String? aadhaarNumber,
    bool? isAadhaarVisible,
    String? selfieImagePath,
    bool? isLoading,
    String? error,
    bool? showOtpInput,
    List<String>? otpDigits,
    bool? isOtpLoading,
    String? mobileVerificationId,
    LocationStatus? locationStatus,
    double? currentLat,
    double? currentLng,
    double? centerLat,
    double? centerLng,
    double? distanceFromCenter,
    double? livenessScore,
  }) {
    return ProfileState(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      isAadhaarVisible: isAadhaarVisible ?? this.isAadhaarVisible,
      selfieImagePath: selfieImagePath ?? this.selfieImagePath,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      showOtpInput: showOtpInput ?? this.showOtpInput,
      otpDigits: otpDigits ?? this.otpDigits,
      isOtpLoading: isOtpLoading ?? this.isOtpLoading,
      mobileVerificationId: mobileVerificationId ?? this.mobileVerificationId,
      locationStatus: locationStatus ?? this.locationStatus,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      distanceFromCenter: distanceFromCenter ?? this.distanceFromCenter,
      livenessScore: livenessScore ?? this.livenessScore,
    );
  }

  bool get isMobileVerified => mobileVerificationId != null;

  /// Validates age is a number between 18 and 100
  bool get isAgeValid {
    final ageInt = int.tryParse(age);
    return ageInt != null && ageInt >= 18 && ageInt <= 100;
  }

  /// Validates mobile number is exactly 10 digits
  bool get isMobileValid => RegExp(r'^\d{10}$').hasMatch(mobileNumber);

  /// Validates Aadhaar number is exactly 12 digits
  bool get isAadhaarValid => RegExp(r'^\d{12}$').hasMatch(aadhaarNumber);

  /// Validates full name contains only letters and spaces (no numbers)
  bool get isNameValid =>
      fullName.trim().isNotEmpty &&
      RegExp(r'^[a-zA-Z\s]+$').hasMatch(fullName.trim());

  /// Returns true if name field should show an error (has content but invalid)
  bool get showNameError => fullName.isNotEmpty && !isNameValid;

  /// Returns true if age field should show an error (has content but invalid)
  bool get showAgeError => age.isNotEmpty && !isAgeValid;

  /// Returns true if mobile field should show an error (has content but invalid)
  bool get showMobileError => mobileNumber.isNotEmpty && !isMobileValid;

  /// Returns true if aadhaar field should show an error (has content but invalid)
  bool get showAadhaarError => aadhaarNumber.isNotEmpty && !isAadhaarValid;

  bool get isDetailsValid =>
      fullName.trim().isNotEmpty &&
      isAgeValid &&
      isMobileValid &&
      isAadhaarValid;

  String get maskedAadhaar {
    if (aadhaarNumber.length < 4) return aadhaarNumber;
    final lastFour = aadhaarNumber.substring(aadhaarNumber.length - 4);
    return '•••• •••• $lastFour';
  }

  String get formattedMobile {
    if (mobileNumber.length < 10) return mobileNumber;
    return '${mobileNumber.substring(0, 5)} ${mobileNumber.substring(5)}';
  }

  String get formattedDistance {
    if (distanceFromCenter == null) return '';
    if (distanceFromCenter! < 1000) {
      return '${distanceFromCenter!.round()}m';
    }
    return '${(distanceFromCenter! / 1000).toStringAsFixed(1)}km';
  }

  bool get isLocationValid => locationStatus == LocationStatus.detected;
}

class ProfileViewModel extends Notifier<ProfileState> {
  String? _pendingVerificationId;

  @override
  ProfileState build() {
    return const ProfileState();
  }

  void updateFullName(String value) {
    state = state.copyWith(fullName: value);
  }

  void updateAge(String value) {
    state = state.copyWith(age: value);
  }

  void updateMobileNumber(String value) {
    state = state.copyWith(mobileNumber: value.replaceAll(' ', ''));
  }

  void updateAadhaarNumber(String value) {
    state = state.copyWith(aadhaarNumber: value.replaceAll(' ', ''));
  }

  void toggleAadhaarVisibility() {
    state = state.copyWith(isAadhaarVisible: !state.isAadhaarVisible);
  }

  Future<void> verifyMobile() async {
    state = state.copyWith(isOtpLoading: true);
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.initiateMobileVerification(
        state.mobileNumber,
      );

      final strings = ref.read(appStringsProvider);
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final verificationId = data['id'] as String?;
        _pendingVerificationId = verificationId;
        state = state.copyWith(
          showOtpInput: true,
          otpDigits: ['', '', '', ''],
          isOtpLoading: false,
        );
      } else {
        state = state.copyWith(isOtpLoading: false);
        throw Exception(response.notify?.message ?? strings.somethingWentWrong);
      }
    } catch (e) {
      final strings = ref.read(appStringsProvider);
      state = state.copyWith(
        isOtpLoading: false,
        error: strings.somethingWentWrong,
      );
    }
  }

  void updateOtpDigit(int index, String value) {
    final newDigits = List<String>.from(state.otpDigits);
    newDigits[index] = value;
    state = state.copyWith(otpDigits: newDigits);
  }

  Future<void> submitOtp() async {
    if (_pendingVerificationId == null) return;

    state = state.copyWith(isOtpLoading: true);
    try {
      final apiService = ref.read(apiServiceProvider);
      final otp = state.otpDigits.join();
      final response = await apiService.verifyOtp(_pendingVerificationId!, otp);

      final strings = ref.read(appStringsProvider);
      if (response.isSuccess) {
        state = state.copyWith(
          isOtpLoading: false,
          mobileVerificationId: _pendingVerificationId,
          showOtpInput: false,
        );
        _pendingVerificationId = null;
      } else {
        state = state.copyWith(
          isOtpLoading: false,
          error: response.notify?.message ?? strings.somethingWentWrong,
        );
      }
    } on AppException catch (e) {
      state = state.copyWith(isOtpLoading: false, error: e.message);
    } catch (e) {
      final strings = ref.read(appStringsProvider);
      state = state.copyWith(
        isOtpLoading: false,
        error: strings.somethingWentWrong,
      );
    }
  }

  Future<void> resendOtp() async {
    if (_pendingVerificationId == null) return;

    state = state.copyWith(isOtpLoading: true);
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.resendOtp(_pendingVerificationId!);
      state = state.copyWith(otpDigits: ['', '', '', ''], isOtpLoading: false);
    } catch (e) {
      final strings = ref.read(appStringsProvider);
      state = state.copyWith(
        isOtpLoading: false,
        error: strings.somethingWentWrong,
      );
    }
  }

  void cancelOtpVerification() {
    _pendingVerificationId = null;
    state = state.copyWith(
      showOtpInput: false,
      otpDigits: ['', '', '', '', '', ''],
    );
  }

  void goToSelfie() {
    final appState = ref.read(appStateProvider);
    state = state.copyWith(
      currentStep: ProfileStep.selfie,
      centerLat: appState.centerLat,
      centerLng: appState.centerLng,
    );
    _detectLocation();
  }

  void goToDetails() {
    state = state.copyWith(currentStep: ProfileStep.details);
  }

  Future<void> _detectLocation() async {
    state = state.copyWith(locationStatus: LocationStatus.detecting);

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(locationStatus: LocationStatus.error);
        return;
      }

      // Check and request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(locationStatus: LocationStatus.permissionDenied);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(locationStatus: LocationStatus.permissionDenied);
        return;
      }

      // Get current position with 3-second timeout to prevent indefinite blocking
      // (BUG-01: exam centres may have signal jammers)
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw TimeoutException('Location detection timed out'),
      );

      // Calculate distance from center
      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        state.centerLat ?? 0,
        state.centerLng ?? 0,
      );

      state = state.copyWith(
        locationStatus: LocationStatus.detected,
        currentLat: position.latitude,
        currentLng: position.longitude,
        distanceFromCenter: distance,
      );
    } on TimeoutException {
      // Timeout is acceptable - allow user to proceed without blocking
      // Location can be captured during photo submission instead
      state = state.copyWith(locationStatus: LocationStatus.detected);
    } catch (e) {
      state = state.copyWith(locationStatus: LocationStatus.error);
    }
  }

  Future<void> retryLocationDetection() async {
    await _detectLocation();
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Set selfie from liveness camera result
  /// Called when LivenessCameraScreen returns successfully
  void setLivenessCameraResult(String imagePath, double livenessScore) {
    state = state.copyWith(
      selfieImagePath: imagePath,
      livenessScore: livenessScore,
      isLoading: false,
    );
  }

  /// Start the selfie capture process
  /// This sets loading state before navigating to camera
  void startSelfieCapture() {
    state = state.copyWith(isLoading: true);
  }

  /// Cancel selfie capture (user closed camera without capturing)
  void cancelSelfieCapture() {
    state = state.copyWith(isLoading: false);
  }

  void setSelfieImage(String path, {double? livenessScore}) {
    state = state.copyWith(selfieImagePath: path, livenessScore: livenessScore);
  }

  void clearSelfie() {
    state = state.copyWith(selfieImagePath: null, livenessScore: null);
    // Don't re-detect location - it was already detected and user just wants to retake photo
  }

  Future<void> submitProfile() async {
    state = state.copyWith(isLoading: true);

    try {
      final db = ref.read(appDatabaseProvider);
      final appState = ref.read(appStateProvider);
      final shiftId = appState.selectedShiftId;

      if (shiftId == null) {
        throw Exception('No shift selected');
      }

      // Validate age is a valid number before submission
      final parsedAge = int.tryParse(state.age);
      if (parsedAge == null || parsedAge < 18 || parsedAge > 100) {
        throw Exception(
          'Invalid age. Please enter a valid age between 18 and 100.',
        );
      }

      // Generate UUID for the profile
      final profileId = const Uuid().v4();
      final now = DateTime.now();

      // Save profile to local database
      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              id: profileId,
              shiftId: shiftId,
              name: state.fullName.trim(),
              contact: state.mobileNumber,
              age: parsedAge,
              aadhaar: state.aadhaarNumber,
              selfieLocalPath: Value(state.selfieImagePath),
              livenessStatus: const Value('PASSED'),
              livenessScore: Value(state.livenessScore ?? 0),
              livenessAttemptedAt: Value(now),
              latitude: Value(state.currentLat),
              longitude: Value(state.currentLng),
              location: Value(appState.center?.name),
              mobileVerificationId: Value(state.mobileVerificationId),
            ),
          );

      // Update onboarding step to training
      await (db.update(db.sessions)..where((t) => const Constant(true))).write(
        SessionsCompanion(onboardingStep: Value(OnboardingStep.training.value)),
      );

      // Update app state
      ref
          .read(appStateProvider.notifier)
          .updateOnboardingStep(OnboardingStep.training.value);

      // Reload app state to fetch the new profile
      await ref.read(appStateProvider.notifier).loadFromDatabase();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final profileViewModelProvider =
    NotifierProvider.autoDispose<ProfileViewModel, ProfileState>(
      ProfileViewModel.new,
    );
