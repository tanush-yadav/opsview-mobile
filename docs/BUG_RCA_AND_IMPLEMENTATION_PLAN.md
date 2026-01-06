# OpsView Mobile App - Bug RCA & Multi-PR Implementation Plan

> **Document Version**: 1.0
> **Date**: 2026-01-06
> **Author**: Engineering Team

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Bug Categorization & Clustering](#bug-clustering)
3. [Detailed Root Cause Analysis](#detailed-rca)
4. [Multi-PR Branch Strategy](#multi-pr-strategy)
5. [Implementation Milestones](#milestones)
6. [Alignment Questions](#alignment-questions)

---

## Executive Summary {#executive-summary}

This document provides a comprehensive Root Cause Analysis (RCA) for 21 identified bugs in the OpsView Mobile App, along with a multi-PR, multi-branch implementation strategy to fix them systematically.

### Bug Severity Distribution

| Severity | Count | Description |
|----------|-------|-------------|
| 🔴 Critical | 6 | Blocks core functionality |
| 🟡 Medium | 13 | Affects user experience |
| 🟢 Low | 2 | Minor UX improvements |

### Proposed PR Structure

| PR # | Branch Name | Bug Cluster | Files Affected |
|------|-------------|-------------|----------------|
| PR-1 | `fix/login-input-validation` | Login & Input Validation | 2 files |
| PR-2 | `fix/navigation-flow` | Navigation Flow Issues | 4 files |
| PR-3 | `fix/profile-creation` | Profile Creation & Validation | 5 files |
| PR-4 | `fix/camera-selfie` | Camera & Selfie Capture | 3 files |
| PR-5 | `fix/shift-selection-ux` | Shift Selection UX | 2 files |
| PR-6 | `fix/training-screen` | Training Screen | 2 files |
| PR-7 | `fix/task-capture` | Task Capture & Image Handling | 3 files |
| PR-8 | `fix/task-data-isolation` | Task Data Isolation | 4 files |
| PR-9 | `fix/sync-status` | Sync Status & Auto-Sync | 5 files |
| PR-10 | `fix/logout-functionality` | Logout & Session | 2 files |

---

## Bug Categorization & Clustering {#bug-clustering}

### Cluster 1: Login & Input Validation
**Bugs**: #2 (Auto-lowercase)

### Cluster 2: Navigation Flow Issues
**Bugs**: #3 (Skip profile/training), #4 (TASK_DOWNLOADED event)

### Cluster 3: Profile Creation & Validation
**Bugs**: #7 (Field validations), #8 (Profile submit failing), #10 (Error popups)

### Cluster 4: Camera & Selfie Capture
**Bugs**: #1 (Camera lockout), #9 (Retake not working)

### Cluster 5: Shift Selection UX
**Bugs**: #5 (Empty tab navigation), #6 (Seconds in time)

### Cluster 6: Training Screen
**Bugs**: #11 (Duration/Priority shown), #12 (No skip option)

### Cluster 7: Task Capture & Image Handling
**Bugs**: #13 (Inside/Outside indicator), #14 (Image count ignored), #15 (Full image view), #16 (Button text)

### Cluster 8: Task Data Isolation
**Bugs**: #18 (Random message in observations), #21 (Task data cross-contamination)

### Cluster 9: Sync Status & Auto-Sync
**Bugs**: #15 (Unsynced when internet available), #16 (Sync required in profile), #17 (Sync status wrong), #19 (All tasks showing unsynced), #20 (Only 1st task synced)

### Cluster 10: Logout & Session
**Bugs**: #22 (Logout not working)

---

## Detailed Root Cause Analysis {#detailed-rca}

---

### BUG #1: Camera Lockout on Selfie Capture

| Attribute | Details |
|-----------|---------|
| **Screen** | Selfie Capture |
| **Severity** | 🔴 Critical |
| **Reported Issue** | Camera doesn't open, keeps loading, locks out user after 2-3 clicks |

#### Root Cause Analysis

**File**: `lib/views/profile/liveness_check_screen.dart:19-25`

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Start liveness detection immediately when this page is built
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _startLivenessDetection(context, ref, strings);
  });
  // Show a loading screen while the detection starts
  return const Scaffold(child: Center(child: CircularProgressIndicator()));
}
```

**Root Cause**:
1. The `build()` method re-executes `_startLivenessDetection` on every rebuild
2. No guard to prevent multiple concurrent liveness detection calls
3. `addPostFrameCallback` is called every time widget rebuilds
4. No state tracking for "detection in progress" vs "already attempted"

**Technical Evidence**:
- No `hasAttempted` or `isDetecting` flag
- Widget rebuilds can trigger multiple overlapping camera sessions
- The liveness plugin doesn't handle concurrent invocations well

#### Fix Strategy

```dart
class _LivenessCheckPageState extends ConsumerStatefulWidget {
  bool _hasStartedDetection = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasStartedDetection) {
        _hasStartedDetection = true;
        _startLivenessDetection(context, ref, strings);
      }
    });
  }
}
```

---

### BUG #2: Exam Code & Username Not Auto-Lowercase

| Attribute | Details |
|-----------|---------|
| **Screen** | Login |
| **Severity** | 🟡 Medium |
| **Reported Issue** | Exam code and username don't auto-convert to lowercase |

#### Root Cause Analysis

**File**: `lib/views/login/login_screen.dart:134-153`

```dart
_buildBorderlessTextField(
  controller: _examCodeController,
  hintText: strings.examCodeHint,
  icon: Icons.tag,
),
// ... similar for username
```

**Root Cause**:
1. No `TextInputFormatter` applied to the text fields
2. No `onChanged` callback to transform input to lowercase
3. The design spec requires auto-lowercase but implementation lacks it

**Technical Evidence**:
- `_examCodeController` and `_usernameController` store raw input
- Line 49: `final examCode = _examCodeController.text.trim();` - no `.toLowerCase()`

#### Fix Strategy

```dart
_buildBorderlessTextField(
  controller: _examCodeController,
  hintText: strings.examCodeHint,
  icon: Icons.tag,
  inputFormatters: [LowerCaseTextFormatter()],
),
```

Or in `_handleLogin()`:
```dart
final examCode = _examCodeController.text.trim().toLowerCase();
final username = _usernameController.text.trim().toLowerCase();
```

---

### BUG #3: Post Login Jumping Directly to Shift Selection

| Attribute | Details |
|-----------|---------|
| **Screen** | Navigation Flow |
| **Severity** | 🔴 Critical |
| **Reported Issue** | Profile creation and Training link screen completely skipped |

#### Root Cause Analysis

**File**: `lib/views/login/login_screen.dart:58`

```dart
if (success) {
  SnackBarUtils.success(context, strings.loginSuccess);
  context.go(AppRoutes.confirmation);
}
```

**File**: `lib/views/profile/profile_flow_screen.dart:40-47`

```dart
// If a profile already exists for this shift, skip to home
if (profile != null &&
    selectedShiftId != null &&
    profile.shiftId == selectedShiftId) {
  debugPrint('[ProfileFlow] Profile exists for shift $selectedShiftId, skipping to home');
  context.go(AppRoutes.training);
}
```

**Root Cause**:
1. The app state `selectedShiftId` might be persisted from a previous session
2. When the profile check runs, it incorrectly matches an old profile with the new session
3. The onboarding step stored in `sessions` table isn't properly reset on fresh login
4. The splash screen navigation doesn't account for session state properly

**Technical Evidence**:
- `SessionsCompanion.insert` in login_viewmodel.dart (line 71-77) doesn't explicitly set `onboardingStep`
- Default onboarding step might be "home" from a previous session

#### Fix Strategy

1. Always reset `onboardingStep` to `"confirmation"` on fresh login
2. Clear `selectedShiftId` when starting new session
3. Add explicit navigation guard in router

---

### BUG #4: No TASK_DOWNLOADED Event Sent

| Attribute | Details |
|-----------|---------|
| **Screen** | Post Confirmation |
| **Severity** | 🟡 Medium |
| **Reported Issue** | Event of type TASK_DOWNLOADED is not sent after tasks download |

#### Root Cause Analysis

**File**: `lib/viewmodels/login_viewmodel.dart:113-157`

```dart
Future<void> _fetchAndStoreTasks(ApiService apiService, AppDatabase db) async {
  try {
    final tasksResponse = await apiService.getOperatorTasks();
    // ... stores tasks but no event sent
  }
}
```

**Root Cause**:
1. No API call exists to send the `TASK_DOWNLOADED` event
2. The design spec requires this event but it's not implemented
3. `ApiService` class has no method for sending events

**Technical Evidence**:
- Searched entire codebase: No "TASK_DOWNLOADED" string exists
- No event-sending endpoint defined in `api_constants.dart`

#### Fix Strategy

1. Add API endpoint: `POST /api/events` or similar
2. Add `sendEvent(eventType: String)` method to `ApiService`
3. Call after successful task download in `_fetchAndStoreTasks()`

---

### BUG #5: Shift Tab Not Adjusting to Active/Non-Empty Tab

| Attribute | Details |
|-----------|---------|
| **Screen** | Shift Selection |
| **Severity** | 🟡 Medium |
| **Reported Issue** | Shows empty tab, should auto-navigate to tab with shifts |

#### Root Cause Analysis

**File**: `lib/viewmodels/shift_selection_viewmodel.dart:81-93`

```dart
@override
ShiftSelectionState build() {
  final appState = ref.watch(appStateProvider);
  if (appState.isLoaded && appState.exam != null) {
    return ShiftSelectionState(
      shifts: appState.exam!.shifts,
      isLoading: false,
    );
  }
  return const ShiftSelectionState();
}
```

**Root Cause**:
1. Default `selectedType` is always `ShiftType.exam` (line 16)
2. No logic to check which tab has shifts
3. No logic to find the active shift and select its tab

**Technical Evidence**:
- `ShiftSelectionState` constructor defaults to `selectedType = ShiftType.exam`
- `build()` method doesn't analyze shift distribution

#### Fix Strategy

```dart
@override
ShiftSelectionState build() {
  final appState = ref.watch(appStateProvider);
  if (appState.isLoaded && appState.exam != null) {
    final shifts = appState.exam!.shifts;

    // Determine best default tab
    final examShifts = shifts.where((s) => s.type == 'ExamDay').toList();
    final mockShifts = shifts.where((s) => s.type == 'MockDay').toList();

    ShiftType defaultType = ShiftType.exam;
    if (examShifts.isEmpty && mockShifts.isNotEmpty) {
      defaultType = ShiftType.mock;
    }

    // Find active shift
    final now = DateTime.now();
    final activeShift = shifts.where((s) => _isShiftActive(s, now)).firstOrNull;
    if (activeShift != null) {
      defaultType = activeShift.type == 'ExamDay' ? ShiftType.exam : ShiftType.mock;
    }

    return ShiftSelectionState(
      shifts: shifts,
      selectedType: defaultType,
      isLoading: false,
    );
  }
  return const ShiftSelectionState();
}
```

---

### BUG #6: Seconds Shown in Shift Timings

| Attribute | Details |
|-----------|---------|
| **Screen** | Shift Selection |
| **Severity** | 🟡 Medium |
| **Reported Issue** | Time shows "09:00:00" instead of "09:00" |

#### Root Cause Analysis

**File**: `lib/views/shift_selection/shift_selection_screen.dart:274-277`

```dart
Text(
  '${shift.startTime} - ${shift.endTime}',
  style: AppTextStyles.bodySmall,
),
```

**Root Cause**:
1. Direct display of `shift.startTime` which comes as "HH:mm:ss" from API
2. No time formatting applied before display

**Technical Evidence**:
- API returns `"startTime": "09:00:00"` (from Postman collection)
- No formatting helper used

#### Fix Strategy

```dart
String _formatTimeHHMM(String time) {
  if (time.length >= 5) {
    return time.substring(0, 5); // "09:00:00" -> "09:00"
  }
  return time;
}

// Usage:
Text(
  '${_formatTimeHHMM(shift.startTime)} - ${_formatTimeHHMM(shift.endTime)}',
  style: AppTextStyles.bodySmall,
),
```

---

### BUG #7: Age, Mobile, Aadhaar Validations Missing

| Attribute | Details |
|-----------|---------|
| **Screen** | Operator Profile |
| **Severity** | 🟡 Medium |
| **Reported Issue** | Basic validations missing, Continue button active without validation |

#### Root Cause Analysis

**File**: `lib/viewmodels/profile_viewmodel.dart:113-117`

```dart
bool get isDetailsValid =>
    fullName.isNotEmpty &&
    age.isNotEmpty &&
    mobileNumber.length >= 10 &&
    aadhaarNumber.length >= 12;
```

**Root Cause**:
1. `age` validation only checks non-empty, not numeric range (18-100)
2. Mobile validation only checks length >= 10, not exactly 10 digits
3. Aadhaar validation only checks length >= 12, not exactly 12 digits
4. No Aadhaar checksum validation (Verhoeff algorithm)
5. No visual feedback for invalid fields

**Technical Evidence**:
- Screenshot shows invalid values accepted (Age: "abc", Mobile: "123")
- No input formatters on the fields

#### Fix Strategy

```dart
bool get isAgeValid {
  final ageInt = int.tryParse(age);
  return ageInt != null && ageInt >= 18 && ageInt <= 100;
}

bool get isMobileValid => RegExp(r'^\d{10}$').hasMatch(mobileNumber);

bool get isAadhaarValid => RegExp(r'^\d{12}$').hasMatch(aadhaarNumber);

bool get isDetailsValid =>
    fullName.trim().isNotEmpty &&
    isAgeValid &&
    isMobileValid &&
    isAadhaarValid;
```

---

### BUG #8: Profile Submit Failing

| Attribute | Details |
|-----------|---------|
| **Screen** | Verify Location & Selfie |
| **Severity** | 🔴 Critical |
| **Reported Issue** | Profile creation is failing |

#### Root Cause Analysis

**File**: `lib/viewmodels/profile_viewmodel.dart:370-426`

```dart
Future<void> submitProfile() async {
  state = state.copyWith(isLoading: true);
  try {
    // ... saves to local DB but errors not handled gracefully
    await db.into(db.profiles).insert(...);
    // Line 395: int.parse(state.age) - can throw if age is not numeric
  } catch (e) {
    state = state.copyWith(isLoading: false);
    rethrow; // <-- Line 424: rethrows without user-friendly message
  }
}
```

**File**: `lib/views/profile/steps/profile_selfie_step.dart:133-149`

```dart
Future<void> _handleSubmit(...) async {
  try {
    await ref.read(profileViewModelProvider.notifier).submitProfile();
    if (context.mounted) {
      context.go(AppRoutes.training);
    }
  } catch (e) {
    if (context.mounted) {
      SnackBarUtils.error(context, strings.somethingWentWrong);
    }
  }
}
```

**Root Cause**:
1. `int.parse(state.age)` throws if age is not a valid integer
2. Error is rethrown with no context about what failed
3. Generic "Something went wrong" message gives no debugging info
4. No field-level validation before submission attempt
5. Database insertion might fail due to constraint violations

**Technical Evidence**:
- Line 395 uses `int.parse` without try-catch
- No validation of required fields before DB insert

#### Fix Strategy

1. Validate all fields before database insert
2. Use `int.tryParse` with fallback
3. Catch specific exceptions and provide meaningful errors
4. Add transaction rollback on failure

---

### BUG #9: Retake Selfie Not Working

| Attribute | Details |
|-----------|---------|
| **Screen** | Verify Location & Selfie |
| **Severity** | 🟡 Medium |
| **Reported Issue** | Retake button doesn't work |

#### Root Cause Analysis

**File**: `lib/views/profile/steps/profile_selfie_step.dart:82`

```dart
OutlineButton(
  onPressed: viewModel.clearSelfie,
  child: Text(strings.retake),
),
```

**File**: `lib/viewmodels/profile_viewmodel.dart:366-368`

```dart
void clearSelfie() {
  state = state.copyWith(selfieImagePath: null, livenessScore: null);
}
```

**Root Cause**:
1. `clearSelfie()` correctly clears the state
2. However, after clearing, the "Capture Photo" button should appear
3. The button navigates to liveness check: `context.push(AppRoutes.livenessCheck)`
4. Issue: Liveness check might still have cached state from previous attempt
5. Possible: The `isLocationValid` guard prevents capture after retake

**Technical Evidence**:
- Line 108: `onPressed: state.isLocationValid ? () => context.push(AppRoutes.livenessCheck) : null`
- If location detection errored during first attempt, button stays disabled

#### Fix Strategy

1. Re-trigger location detection after clearing selfie
2. Ensure liveness check screen state is fresh on each navigation

```dart
void clearSelfie() {
  state = state.copyWith(selfieImagePath: null, livenessScore: null);
  _detectLocation(); // Re-detect location
}
```

---

### BUG #10: Random Error Popups on Profile Submit

| Attribute | Details |
|-----------|---------|
| **Screen** | Submit Operator Profile |
| **Severity** | 🟡 Medium |
| **Reported Issue** | Multiple error popups appearing during submission |

#### Root Cause Analysis

**File**: `lib/views/profile/steps/profile_details_step.dart:64-68`

```dart
ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
  if (next.error != null && next.error != previous?.error) {
    SnackBarUtils.error(context, next.error!);
  }
});
```

**Root Cause**:
1. Error listener triggers snackbar for ANY error state change
2. Multiple state updates during submit can each trigger errors
3. Concurrent API calls (OTP, verification) can overlap errors
4. The `ref.listen` fires on every state change, not just submission errors

**Technical Evidence**:
- Multiple places set `error` state: verifyMobile, submitOtp, resendOtp
- Each error change triggers a new snackbar

#### Fix Strategy

1. Add error type/category to distinguish submission vs validation errors
2. Only show submission errors during submit flow
3. Debounce error displays

---

### BUG #11: Training Duration & Priority Shown Without API Data

| Attribute | Details |
|-----------|---------|
| **Screen** | Training Required |
| **Severity** | 🟡 Medium |
| **Reported Issue** | Shows "4m 20s" duration and "Mandatory" priority when API doesn't provide these |

#### Root Cause Analysis

**File**: `lib/views/training/training_screen.dart:138-175`

```dart
// Duration - HARDCODED
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(strings.duration.toUpperCase(), ...),
    const SizedBox(height: 4),
    Text('4m 20s', ...), // <-- HARDCODED VALUE
  ],
),
// Priority - HARDCODED
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(strings.priority.toUpperCase(), ...),
    const SizedBox(height: 4),
    Text(strings.mandatory, ...), // <-- HARDCODED VALUE
  ],
),
```

**Root Cause**:
1. Duration and Priority are hardcoded in the UI
2. API response (`ShiftService.trainingLink`) only provides a URL
3. No fields for duration or priority in the data model

**Technical Evidence**:
- `ShiftService` model only has: `name`, `templateName`, `trainingLink`
- No `duration` or `priority` fields

#### Fix Strategy

Per spec: "Show simple training link (default image or icon can be used) on center of the screen"

```dart
// Remove Duration and Priority sections entirely
// Replace with simple centered training link button
```

---

### BUG #12: Training Skip Option Not Available

| Attribute | Details |
|-----------|---------|
| **Screen** | Training Required |
| **Severity** | 🟡 Medium |
| **Reported Issue** | No skip button to bypass training |

#### Root Cause Analysis

**File**: `lib/views/training/training_screen.dart:46-66`

```dart
// Complete Button - Only option
SizedBox(
  width: double.infinity,
  height: 56,
  child: PrimaryButton(
    onPressed: () async {
      await trainingViewModel.completeTraining();
      if (context.mounted) {
        context.go(AppRoutes.home);
      }
    },
    child: Text(strings.completed, ...),
  ),
),
```

**Root Cause**:
1. Only "Completed" button exists
2. No "Skip" button implemented
3. Spec clearly states: "Must have a SKIP option"

**Technical Evidence**:
- No skip-related code in training_screen.dart
- No `skipTraining()` method in viewmodel

#### Fix Strategy

```dart
// Add Skip button above or below Complete button
TextButton(
  onPressed: () {
    await trainingViewModel.skipTraining();
    if (context.mounted) {
      context.go(AppRoutes.home);
    }
  },
  child: Text(strings.skip),
),
```

---

### BUG #13: Inside/Outside Not Shown During Photo Capture

| Attribute | Details |
|-----------|---------|
| **Screen** | Task Capture |
| **Severity** | 🟡 Medium |
| **Reported Issue** | No indicator showing if user is inside or outside geo-fence while taking photos |

#### Root Cause Analysis

**File**: `lib/views/task_capture/task_capture_screen.dart:174-180`

```dart
LocationStatusCard(
  status: state.locationStatus,
  formattedDistance: state.formattedDistance,
  strings: strings,
  onRetry: viewModel.retryLocationDetection,
),
```

**Root Cause**:
1. `LocationStatusCard` shows distance but not INSIDE/OUTSIDE status
2. The card displays distance like "120m" but doesn't indicate fence status
3. No fence radius comparison logic in the widget

**Technical Evidence**:
- `formattedDistance` is just distance in meters
- No `fenceStatus` field in `TaskCaptureState`
- Fence check only happens in `task_sync_service.dart` during sync

#### Fix Strategy

1. Add `fenceStatus` (INSIDE/OUTSIDE) to `TaskCaptureState`
2. Calculate during location detection: `distance <= fenceRadius ? 'INSIDE' : 'OUTSIDE'`
3. Display badge on `LocationStatusCard`

---

### BUG #14: Image Count Limits Ignored (no-img-cnt)

| Attribute | Details |
|-----------|---------|
| **Screen** | Task Capture |
| **Severity** | 🟡 Medium |
| **Reported Issue** | User can click more photos than required, no enforcement of image count |

#### Root Cause Analysis

**File**: `lib/views/task_capture/task_capture_screen.dart:401-444`

```dart
Widget _buildTakePhotoCard(bool hasPhotos) {
  return GestureDetector(
    onTap: _takePhoto, // <-- No limit check
    child: Container(...),
  );
}
```

**File**: `lib/viewmodels/task_capture_viewmodel.dart:102-112`

```dart
bool get canComplete {
  if (isImageTask) {
    return capturedPhotos.isNotEmpty; // <-- Only checks "at least 1"
  }
  // ...
}
```

**Root Cause**:
1. No `maxImageCount` or `requiredImageCount` field in task model
2. `canComplete` only checks `isNotEmpty`, not exact count
3. Take photo button always enabled, no limit enforcement
4. Task metaData has `no-img-cnt` but it's not being used

**Technical Evidence**:
- `TaskMetaData` model doesn't include image count field
- No validation against required count

#### Fix Strategy

1. Parse `no-img-cnt` from task metaData
2. Disable "Add Photo" when limit reached
3. Update `canComplete` to check exact count
4. Change button text: "Complete Task" → "Submit Task"

---

### BUG #15: Can't View Full Last Submission Image

| Attribute | Details |
|-----------|---------|
| **Screen** | Task Detail |
| **Severity** | 🟡 Medium |
| **Reported Issue** | Cannot view full-size image of previous submission |

#### Root Cause Analysis

**File**: `lib/views/task_capture/task_capture_screen.dart:336-398`

```dart
Widget _buildCapturedPhotoCard(int index, CapturedPhoto photo) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    height: 200,
    // ... image displayed but no onTap for full view
    child: Stack(
      children: [
        ClipRRect(
          child: Image.file(File(photo.imagePath), fit: BoxFit.cover),
        ),
        // Only delete button, no view button
      ],
    ),
  );
}
```

**Root Cause**:
1. Image card has no tap handler for full-screen view
2. No full-screen image viewer implemented
3. Only action available is delete (X button)

**Technical Evidence**:
- No `GestureDetector` wrapping the image
- No `Navigator.push` to full-screen viewer

#### Fix Strategy

```dart
GestureDetector(
  onTap: () => _showFullScreenImage(photo.imagePath),
  child: ClipRRect(
    child: Image.file(File(photo.imagePath), fit: BoxFit.cover),
  ),
),

void _showFullScreenImage(String path) {
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => FullScreenImageViewer(imagePath: path),
  ));
}
```

---

### BUG #16: Button Says "Complete Task" Instead of "Submit Task"

| Attribute | Details |
|-----------|---------|
| **Screen** | Task Capture |
| **Severity** | 🟢 Low |
| **Reported Issue** | Button text should be "Submit Task" per spec |

#### Root Cause Analysis

**File**: `lib/views/task_capture/task_capture_screen.dart:637-639`

```dart
child: Text(
  'Complete Task', // <-- Hardcoded wrong text
  style: AppTextStyles.button.copyWith(fontSize: 16),
),
```

**Root Cause**:
1. Hardcoded string instead of using localization
2. Wrong text per design spec

#### Fix Strategy

```dart
child: Text(
  strings.submitTask, // Use localized string
  style: AppTextStyles.button.copyWith(fontSize: 16),
),
```

---

### BUG #17: Sync Status Wrong - Shows Unsynced When Internet Available

| Attribute | Details |
|-----------|---------|
| **Screen** | Submitted Tab |
| **Severity** | 🟡 Medium |
| **Reported Issue** | Data not synced automatically when internet available |

#### Root Cause Analysis

**File**: `lib/viewmodels/home_viewmodel.dart:103-118`

```dart
SyncStatus getSyncStatus(String taskId) {
  final appState = ref.read(appStateProvider);
  final submission = appState.taskSubmissions
      .where((s) => s.taskId == taskId)
      .firstOrNull;

  if (submission == null) return SyncStatus.unsynced; // <-- No submission = unsynced
  // ...
}
```

**Root Cause**:
1. **No auto-sync**: App doesn't automatically sync when internet becomes available
2. **No connectivity listener**: No `connectivity_plus` stream subscription
3. **Manual sync only**: User must go to Settings and tap "Sync Data"
4. The design spec says: "Sync immediately when internet becomes available"

**Technical Evidence**:
- No `ConnectivityResult` listener anywhere in codebase
- No background sync service
- `taskSyncService.syncAllTasks()` only called from Settings screen

#### Fix Strategy

1. Add connectivity listener in app initialization
2. Trigger sync when connectivity changes to connected
3. Add periodic background sync check

---

### BUG #18: Random Message Populated in Wrong Task Observations

| Attribute | Details |
|-----------|---------|
| **Screen** | Task Detail |
| **Severity** | 🔴 Critical |
| **Reported Issue** | Observations typed for one task appear in another task |

#### Root Cause Analysis

**File**: `lib/viewmodels/task_capture_viewmodel.dart:119-121`

```dart
@override
TaskCaptureState build() {
  return const TaskCaptureState(); // <-- Shared singleton state
}
```

**File**: `lib/views/task_capture/task_capture_screen.dart:26-28`

```dart
final TextEditingController _observationsController = TextEditingController();

// Line 152-158:
if (!_observationsInitialized && state.observations.isNotEmpty) {
  _observationsInitialized = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _observationsController.text = state.observations;
  });
}
```

**Root Cause**:
1. `TaskCaptureViewModel` is a **singleton Notifier** - state persists across tasks
2. When navigating to a new task, `loadTask()` is called but old state lingers
3. `_observationsInitialized` flag prevents re-syncing controller
4. The controller text isn't reset when loading a new task

**Technical Evidence**:
- `taskCaptureViewModelProvider` is a global `NotifierProvider`
- `loadTask()` updates state but controller isn't bound to state reactively
- `_observationsInitialized = false` is never reset when switching tasks

#### Fix Strategy

1. Reset state completely in `loadTask()` before loading new task
2. Use `.family` provider: `taskCaptureViewModelProvider(taskId)`
3. Reset `_observationsInitialized` in `initState` or `didUpdateWidget`

---

### BUG #19: All Tasks Showing Unsynced

| Attribute | Details |
|-----------|---------|
| **Screen** | Submitted Tab |
| **Severity** | 🔴 Critical |
| **Reported Issue** | On submitting new task, all synced tasks show as unsynced |

#### Root Cause Analysis

**File**: `lib/viewmodels/home_viewmodel.dart:103-118`

```dart
SyncStatus getSyncStatus(String taskId) {
  final appState = ref.read(appStateProvider);
  final submission = appState.taskSubmissions
      .where((s) => s.taskId == taskId) // <-- Matches by taskId CODE not UUID
      .firstOrNull;
  // ...
}
```

**File**: `lib/services/database/tables/task_submissions.dart`

```dart
TextColumn get taskId => text()(); // Stores task CODE like "FRISK_M_T2"
```

**Root Cause**:
1. `getSyncStatus` queries `taskSubmissions` by `taskId`
2. `taskSubmissions.taskId` stores the task **code** (e.g., "FRISK_M_T2")
3. When `appState.loadFromDatabase()` is called, it might not load submissions correctly
4. The query `where((s) => s.taskId == taskId)` might use wrong field

**Technical Evidence**:
- Task table has both `id` (UUID) and `taskId` (code)
- Confusion between which ID is being used
- After reload, `taskSubmissions` array might be stale or empty

#### Fix Strategy

1. Ensure consistent use of task identifiers (UUID vs code)
2. Verify `appStateProvider.loadFromDatabase()` loads submissions correctly
3. Add explicit refresh after sync operations

---

### BUG #20: Only 1st Task Showing Synced After Manual Sync

| Attribute | Details |
|-----------|---------|
| **Screen** | Submitted Tab |
| **Severity** | 🟡 Medium |
| **Reported Issue** | Manual sync shows success but only first task marked synced |

#### Root Cause Analysis

**File**: `lib/services/sync/task_sync_service.dart:185-197`

```dart
Future<int> syncAllTasks() async {
  final unsyncedTasks = await getUnsyncedTasks();
  int syncedCount = 0;

  for (final task in unsyncedTasks) {
    final success = await syncTask(task);
    if (success) {
      syncedCount++;
    }
    // <-- No error handling, continues silently on failure
  }
  return syncedCount;
}
```

**Root Cause**:
1. If first sync succeeds but subsequent syncs fail, only first is marked synced
2. API might be returning errors for subsequent tasks
3. No retry logic for failed syncs
4. UI refresh happens once, might not reflect all changes

**Technical Evidence**:
- `syncTask()` returns false on any exception (line 178-181)
- No logging of which tasks failed and why
- `loadFromDatabase()` called once after sync, might have race condition

#### Fix Strategy

1. Add detailed error logging per task
2. Implement retry with exponential backoff
3. Return detailed sync results (success list, failure list)
4. Add small delay between UI refresh and database updates

---

### BUG #21: Task Data Cross-Contamination

| Attribute | Details |
|-----------|---------|
| **Screen** | Task Detail |
| **Severity** | 🔴 Critical |
| **Reported Issue** | Data from one task appears in another, submissions mixed up |

#### Root Cause Analysis

Same as BUG #18 - Root cause is shared singleton state in `TaskCaptureViewModel`.

**Additional Evidence**:

**File**: `lib/viewmodels/task_capture_viewmodel.dart:159-199`

```dart
if (submission != null) {
  submissionId = submission.id;
  observations = submission.observations ?? '';

  // Load checklist answers from submission
  try {
    final List<dynamic> answersJson = jsonDecode(submission.verificationAnswers);
    // ... updates checklist from submission
  }

  // Load captured photos
  try {
    final List<dynamic> photosJson = jsonDecode(submission.imagePaths);
    capturedPhotos = photosJson.map((p) => ...).toList();
  }
}
```

**Root Cause**:
1. `submission` lookup uses `taskId` which might match wrong task
2. State from previous task load isn't fully cleared
3. `observations`, `capturedPhotos`, `checklist` persist across task switches

#### Fix Strategy

1. Clear ALL state fields at start of `loadTask()`:
```dart
void loadTask(String taskId) {
  // Reset all state first
  state = const TaskCaptureState(isLoading: true);

  // Then load new task data...
}
```

2. Use `.family` provider for task-specific state

---

### BUG #22: Logout Not Working

| Attribute | Details |
|-----------|---------|
| **Screen** | Profile/Settings |
| **Severity** | 🔴 Critical |
| **Reported Issue** | Logout button doesn't work |

#### Root Cause Analysis

**File**: `lib/views/settings/settings_screen.dart:355-376`

```dart
material.OutlinedButton(
  onPressed: state.hasPendingSync
      ? null // <-- DISABLED when hasPendingSync is true
      : () async {
          await viewModel.logout();
          if (context.mounted) {
            context.go(AppRoutes.login);
          }
        },
  // ...
),
```

**File**: `lib/viewmodels/settings_viewmodel.dart:67-82`

```dart
@override
SettingsState build() {
  final appState = ref.watch(appStateProvider);

  // Check for pending sync (tasks that are not submitted)
  final hasPendingSync = appState.tasks.any(
    (t) => t.taskStatus == TaskStatus.pending.toDbValue,
  );

  return SettingsState(
    // ...
    hasPendingSync: hasPendingSync,
  );
}
```

**Root Cause**:
1. `hasPendingSync` checks if ANY task has status "PENDING"
2. This is **wrong logic**: it should check for UNSYNCED submissions, not PENDING tasks
3. All tasks start as PENDING, so logout is ALWAYS disabled
4. Per spec: "If unsynced data exists → Show warning, allow logout, preserve data locally"

**Technical Evidence**:
- `TaskStatus.pending.toDbValue` = "PENDING" (task not yet done)
- Should check: `taskSubmissions.any((s) => s.status == 'UNSYNCED')`
- Current logic: "Has any incomplete task" vs "Has any unsynced submission"

#### Fix Strategy

```dart
// WRONG: Checks for incomplete tasks
final hasPendingSync = appState.tasks.any(
  (t) => t.taskStatus == TaskStatus.pending.toDbValue,
);

// CORRECT: Checks for unsynced submissions
final hasUnsyncedSubmissions = appState.taskSubmissions.any(
  (s) => s.status == SyncStatus.unsynced.toDbValue,
);
```

---

## Multi-PR Branch Strategy {#multi-pr-strategy}

### Branch Naming Convention

```
fix/<cluster-name>
```

### PR Dependency Graph

```
                    ┌─────────────────┐
                    │  PR-1: Login    │
                    │  Input Valid.   │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  PR-2: Nav Flow │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
┌────────▼────────┐ ┌────────▼────────┐ ┌────────▼────────┐
│  PR-3: Profile  │ │  PR-5: Shift    │ │  PR-6: Training │
│  Creation       │ │  Selection      │ │  Screen         │
└────────┬────────┘ └─────────────────┘ └─────────────────┘
         │
┌────────▼────────┐
│  PR-4: Camera   │
│  & Selfie       │
└────────┬────────┘
         │
         ├───────────────────┬───────────────────┐
         │                   │                   │
┌────────▼────────┐ ┌────────▼────────┐ ┌────────▼────────┐
│  PR-7: Task     │ │  PR-8: Data     │ │  PR-9: Sync     │
│  Capture        │ │  Isolation      │ │  Status         │
└─────────────────┘ └─────────────────┘ └────────┬────────┘
                                                 │
                                        ┌────────▼────────┐
                                        │  PR-10: Logout  │
                                        └─────────────────┘
```

### Detailed PR Specifications

---

#### PR-1: Login Input Validation

**Branch**: `fix/login-input-validation`

**Bugs Fixed**: #2

**Files Modified**:
- `lib/views/login/login_screen.dart`
- `lib/core/utils/text_formatters.dart` (NEW)

**Changes**:
1. Add `LowerCaseTextFormatter` class
2. Apply formatter to examCode and username fields
3. Keep password case-sensitive

**Estimated Scope**: ~50 lines changed

**Tests Required**:
- [ ] Uppercase input converted to lowercase
- [ ] Password remains case-sensitive
- [ ] Login works with mixed case input

---

#### PR-2: Navigation Flow Fixes

**Branch**: `fix/navigation-flow`

**Bugs Fixed**: #3, #4

**Files Modified**:
- `lib/viewmodels/login_viewmodel.dart`
- `lib/services/api/api_service.dart`
- `lib/core/constants/api_constants.dart`
- `lib/core/router/app_router.dart`

**Changes**:
1. Reset `onboardingStep` to "confirmation" on fresh login
2. Clear `selectedShiftId` on new session
3. Add `sendEvent(eventType)` API method
4. Call `TASK_DOWNLOADED` event after tasks fetched

**Estimated Scope**: ~100 lines changed

**Tests Required**:
- [ ] Fresh login goes to Confirmation screen
- [ ] Profile/Training not skipped
- [ ] TASK_DOWNLOADED event sent (verify in backend logs)

---

#### PR-3: Profile Creation & Validation

**Branch**: `fix/profile-creation`

**Bugs Fixed**: #7, #8, #10

**Files Modified**:
- `lib/viewmodels/profile_viewmodel.dart`
- `lib/views/profile/steps/profile_details_step.dart`
- `lib/views/profile/steps/profile_selfie_step.dart`
- `lib/core/utils/validators.dart` (NEW)
- `lib/core/localization/strings/en_strings.dart`

**Changes**:
1. Add proper validation for age (18-100), mobile (10 digits), Aadhaar (12 digits)
2. Show field-level validation errors
3. Disable Continue button until all validations pass
4. Improve error handling in `submitProfile()`
5. Add specific error messages instead of generic "Something went wrong"

**Estimated Scope**: ~200 lines changed

**Tests Required**:
- [ ] Invalid age rejected (non-numeric, <18, >100)
- [ ] Invalid mobile rejected (not 10 digits)
- [ ] Invalid Aadhaar rejected (not 12 digits)
- [ ] Continue button disabled with invalid data
- [ ] Profile submission shows meaningful errors

---

#### PR-4: Camera & Selfie Capture

**Branch**: `fix/camera-selfie`

**Bugs Fixed**: #1, #9

**Files Modified**:
- `lib/views/profile/liveness_check_screen.dart`
- `lib/viewmodels/profile_viewmodel.dart`
- `lib/views/profile/steps/profile_selfie_step.dart`

**Changes**:
1. Convert `LivenessCheckPage` to StatefulWidget with detection guard
2. Prevent multiple concurrent liveness detection calls
3. Fix retake by re-triggering location detection
4. Add error recovery for camera failures

**Estimated Scope**: ~100 lines changed

**Tests Required**:
- [ ] Camera opens on first tap
- [ ] No lockout on failed attempts
- [ ] Retake button works correctly
- [ ] Location re-detected after retake

---

#### PR-5: Shift Selection UX

**Branch**: `fix/shift-selection-ux`

**Bugs Fixed**: #5, #6

**Files Modified**:
- `lib/viewmodels/shift_selection_viewmodel.dart`
- `lib/views/shift_selection/shift_selection_screen.dart`

**Changes**:
1. Auto-select tab with active shift or non-empty tab
2. Format time to HH:mm (remove seconds)
3. Hide empty tabs or prevent showing them

**Estimated Scope**: ~80 lines changed

**Tests Required**:
- [ ] Default tab has shifts (not empty)
- [ ] Active shift's tab is selected
- [ ] Time shows "09:00" not "09:00:00"

---

#### PR-6: Training Screen Fixes

**Branch**: `fix/training-screen`

**Bugs Fixed**: #11, #12

**Files Modified**:
- `lib/views/training/training_screen.dart`
- `lib/viewmodels/training_viewmodel.dart`

**Changes**:
1. Remove hardcoded Duration and Priority sections
2. Add Skip button
3. Simplify UI to centered training link with icon
4. Add `skipTraining()` method

**Estimated Scope**: ~80 lines changed

**Tests Required**:
- [ ] No Duration/Priority shown
- [ ] Skip button navigates to Home
- [ ] Training link opens in browser

---

#### PR-7: Task Capture Improvements

**Branch**: `fix/task-capture`

**Bugs Fixed**: #13, #14, #15, #16

**Files Modified**:
- `lib/views/task_capture/task_capture_screen.dart`
- `lib/viewmodels/task_capture_viewmodel.dart`
- `lib/views/widgets/full_screen_image_viewer.dart` (NEW)

**Changes**:
1. Add INSIDE/OUTSIDE indicator to location card
2. Enforce image count limit from task config
3. Add full-screen image viewer
4. Change button text to "Submit Task"
5. Parse `no-img-cnt` from task metaData

**Estimated Scope**: ~200 lines changed

**Tests Required**:
- [ ] Inside/Outside badge shows during capture
- [ ] Cannot add more than max images
- [ ] Tapping image opens full screen
- [ ] Button says "Submit Task"

---

#### PR-8: Task Data Isolation

**Branch**: `fix/task-data-isolation`

**Bugs Fixed**: #18, #21

**Files Modified**:
- `lib/viewmodels/task_capture_viewmodel.dart`
- `lib/views/task_capture/task_capture_screen.dart`
- `lib/core/providers/task_capture_provider.dart` (NEW - family provider)

**Changes**:
1. Reset ALL state at start of `loadTask()`
2. Convert to `.family` provider keyed by taskId
3. Reset `_observationsInitialized` when task changes
4. Clear controller text on task switch

**Estimated Scope**: ~150 lines changed

**Tests Required**:
- [ ] Observations don't carry over between tasks
- [ ] Photos don't carry over between tasks
- [ ] Checklist answers don't carry over
- [ ] Each task shows its own submission data

---

#### PR-9: Sync Status & Auto-Sync

**Branch**: `fix/sync-status`

**Bugs Fixed**: #17, #19, #20 (partial), Profile sync status

**Files Modified**:
- `lib/viewmodels/home_viewmodel.dart`
- `lib/services/sync/task_sync_service.dart`
- `lib/core/providers/connectivity_provider.dart` (NEW)
- `lib/main.dart`
- `lib/viewmodels/settings_viewmodel.dart`

**Changes**:
1. Add connectivity listener for auto-sync
2. Fix `getSyncStatus()` to use correct ID field
3. Add detailed sync logging
4. Refresh UI properly after sync
5. Implement retry logic for failed syncs

**Estimated Scope**: ~250 lines changed

**Tests Required**:
- [ ] Auto-sync triggers when internet connects
- [ ] Correct sync status shown per task
- [ ] All synced tasks show green
- [ ] Retry on sync failure

---

#### PR-10: Logout Functionality

**Branch**: `fix/logout-functionality`

**Bugs Fixed**: #22

**Files Modified**:
- `lib/viewmodels/settings_viewmodel.dart`
- `lib/views/settings/settings_screen.dart`

**Changes**:
1. Fix `hasPendingSync` logic to check unsynced submissions, not pending tasks
2. Allow logout even with unsynced data (with warning)
3. Preserve local data on logout as per spec

**Estimated Scope**: ~50 lines changed

**Tests Required**:
- [ ] Logout button works when no unsynced data
- [ ] Warning shown when unsynced data exists
- [ ] Can still logout with warning
- [ ] Local data preserved after logout

---

## Implementation Milestones {#milestones}

### Phase 1: Core Flow Fixes (PR-1, PR-2, PR-10)
**Focus**: Login, navigation, and logout - the bookends of user flow

| PR | Status | Blocker |
|----|--------|---------|
| PR-1: Login Validation | Ready | None |
| PR-2: Navigation Flow | Ready | None |
| PR-10: Logout | Ready | None |

### Phase 2: Profile & Onboarding (PR-3, PR-4, PR-5, PR-6)
**Focus**: Profile creation and onboarding experience

| PR | Status | Blocker |
|----|--------|---------|
| PR-3: Profile Validation | Ready | PR-2 |
| PR-4: Camera/Selfie | Ready | PR-3 |
| PR-5: Shift Selection | Ready | PR-2 |
| PR-6: Training Screen | Ready | PR-2 |

### Phase 3: Task Workflow (PR-7, PR-8)
**Focus**: Task capture and data integrity

| PR | Status | Blocker |
|----|--------|---------|
| PR-7: Task Capture | Ready | PR-4 |
| PR-8: Data Isolation | Ready | PR-7 |

### Phase 4: Sync & Polish (PR-9)
**Focus**: Data synchronization

| PR | Status | Blocker |
|----|--------|---------|
| PR-9: Sync Status | Ready | PR-8 |

---

## Alignment Questions {#alignment-questions}

### Critical Questions for Product/Backend Team

1. **TASK_DOWNLOADED Event API**
   - What is the exact endpoint for sending events?
   - Expected payload structure?
   - Is this a fire-and-forget or does it return confirmation?

2. **Image Count Configuration**
   - Where is `no-img-cnt` stored? In task metaData JSON?
   - What's the field name exactly?
   - Default value if not specified?

3. **Geo-Fence Radius**
   - `fenceRadius` from exam is currently 0 in test data
   - What should be the default radius? 500m?
   - Should we allow configuration per exam?

4. **Offline Profile Creation**
   - Spec mentions "Profile ID = Mobile + Aadhaar + Timestamp"
   - Currently using UUID - should we change?
   - How to handle profile ID conflicts on sync?

5. **Auto-Sync Behavior**
   - Should sync happen immediately on connectivity or with delay?
   - Should there be a minimum interval between syncs?
   - Should user be notified of background sync?

6. **Logout with Unsynced Data**
   - Spec says "preserve data locally" - for how long?
   - Can user re-login and continue syncing?
   - What happens to orphaned data on reinstall?

### Technical Questions

7. **Task ID Confusion**
   - Tasks have `id` (UUID) and `taskId` (code like "FRISK_M_T2")
   - Which should be used for submission reference?
   - Need alignment on naming convention

8. **Training Link Handling**
   - Some shifts have empty `trainingLink`
   - Should we hide training screen entirely if no link?
   - Or show "No training available" message?

9. **Gallery Access**
   - Spec says "No gallery allowed in whole app"
   - Currently photo picker shows gallery option
   - Confirm we should remove gallery option completely?

10. **Error Message Strategy**
    - Currently using generic "Something went wrong"
    - Should we show technical error details to users?
    - Or log to analytics and show generic message?

---

## Appendix: File Index

| File Path | PRs Affected |
|-----------|--------------|
| `lib/views/login/login_screen.dart` | PR-1 |
| `lib/viewmodels/login_viewmodel.dart` | PR-2 |
| `lib/services/api/api_service.dart` | PR-2 |
| `lib/core/constants/api_constants.dart` | PR-2 |
| `lib/viewmodels/profile_viewmodel.dart` | PR-3, PR-4 |
| `lib/views/profile/steps/profile_details_step.dart` | PR-3 |
| `lib/views/profile/steps/profile_selfie_step.dart` | PR-3, PR-4 |
| `lib/views/profile/liveness_check_screen.dart` | PR-4 |
| `lib/viewmodels/shift_selection_viewmodel.dart` | PR-5 |
| `lib/views/shift_selection/shift_selection_screen.dart` | PR-5 |
| `lib/views/training/training_screen.dart` | PR-6 |
| `lib/viewmodels/training_viewmodel.dart` | PR-6 |
| `lib/views/task_capture/task_capture_screen.dart` | PR-7, PR-8 |
| `lib/viewmodels/task_capture_viewmodel.dart` | PR-7, PR-8 |
| `lib/viewmodels/home_viewmodel.dart` | PR-9 |
| `lib/services/sync/task_sync_service.dart` | PR-9 |
| `lib/viewmodels/settings_viewmodel.dart` | PR-9, PR-10 |
| `lib/views/settings/settings_screen.dart` | PR-10 |

---

*End of Document*
