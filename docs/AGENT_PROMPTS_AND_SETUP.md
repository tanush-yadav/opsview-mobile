# OpsView Mobile - Agent Prompts & Setup Guide

> Detailed prompts for each wave with file references, plus testing setup

---

## Prerequisites: SDK & Dependencies

### Required for ALL Instances

```bash
# Verify these are installed before launching agents
flutter --version    # Flutter 3.x required
dart --version       # Dart 3.x (comes with Flutter)
```

### Environment Setup Checklist

| Requirement | Command to Verify | Install If Missing |
|-------------|-------------------|-------------------|
| Flutter SDK | `flutter doctor` | [flutter.dev/docs/get-started](https://flutter.dev/docs/get-started/install) |
| Dart SDK | `dart --version` | Included with Flutter |
| Android SDK | `flutter doctor --android` | Android Studio or cmdline-tools |
| iOS (Mac only) | `xcode-select -p` | Xcode from App Store |
| Git | `git --version` | `brew install git` / `apt install git` |

### Project Dependencies (run once before agents)

```bash
cd /home/user/opsview-mobile
flutter pub get
flutter analyze  # Should pass with no errors
```

---

## Wave 1: First Batch (2 Instances)

### Instance 1: Login Input Validation

**Branch**: `fix/login-input-validation`
**Bug**: #2 (Auto-lowercase exam code and username)
**Estimated Time**: 30 minutes

```
You are fixing Bug #2 in the OpsView Mobile Flutter app.

## CONTEXT
Read these files to understand the bug and fix:
- docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md (search for "BUG #2" and "PR-1")
- docs/OpsView Mobile App — Final Design Specification.md (Screen 2: Login section)

## SOURCE FILES TO MODIFY
- lib/views/login/login_screen.dart (lines 134-153, 233-261)

## THE BUG
Exam code and username fields don't auto-convert to lowercase while typing.
Password should remain case-sensitive.

## ROOT CAUSE (from RCA)
- No TextInputFormatter applied to exam code and username fields
- No transformation to lowercase before sending to API

## IMPLEMENTATION STEPS
1. Create branch: git checkout -b fix/login-input-validation

2. Create a new file lib/core/utils/text_formatters.dart:
```dart
import 'package:flutter/services.dart';

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
```

3. In lib/views/login/login_screen.dart:
   - Import the new formatter
   - Add inputFormatters parameter to _buildBorderlessTextField method
   - Apply LowerCaseTextFormatter to examCode and username fields only
   - Do NOT apply to password field

4. Run: flutter analyze
5. Run: flutter test (if tests exist)
6. Commit: git add -A && git commit -m "fix: Auto-lowercase exam code and username on login (#2)"
7. Push: git push -u origin fix/login-input-validation

## CONSTRAINTS
- Only modify login_screen.dart and create text_formatters.dart
- Keep password field case-sensitive
- Follow existing code style (look at other files in lib/core/utils/)
- Don't add comments unless logic is complex

## REPORT WHEN DONE
- Files changed (list them)
- flutter analyze output (should be clean)
- Any issues encountered
```

---

### Instance 2: Shift Selection UX

**Branch**: `fix/shift-selection-ux`
**Bugs**: #5 (Empty tab navigation), #6 (Seconds in time)
**Estimated Time**: 45 minutes

```
You are fixing Bugs #5 and #6 in the OpsView Mobile Flutter app.

## CONTEXT
Read these files to understand the bugs and fixes:
- docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md (search for "BUG #5", "BUG #6", and "PR-5")
- docs/OpsView Mobile App — Final Design Specification.md (Screen 4: Shift Selection)

## SOURCE FILES TO MODIFY
- lib/viewmodels/shift_selection_viewmodel.dart (lines 79-93)
- lib/views/shift_selection/shift_selection_screen.dart (lines 274-277)

## THE BUGS

### Bug #5: Shift tab not adjusting to active/non-empty tab
- Default tab is always "Exam Day" even if it has no shifts
- Should auto-select tab that has shifts, preferring the one with active shift

### Bug #6: Seconds shown in shift timings
- Time shows "09:00:00" instead of "09:00"
- Should display only HH:mm format

## IMPLEMENTATION STEPS
1. Create branch: git checkout -b fix/shift-selection-ux

2. In lib/viewmodels/shift_selection_viewmodel.dart, modify build() method:
```dart
@override
ShiftSelectionState build() {
  final appState = ref.watch(appStateProvider);

  if (appState.isLoaded && appState.exam != null) {
    final shifts = appState.exam!.shifts;

    // Determine best default tab
    final examShifts = shifts.where((s) => s.type == AppConstants.shiftTypeExamDay).toList();
    final mockShifts = shifts.where((s) => s.type == AppConstants.shiftTypeMockDay).toList();

    ShiftType defaultType = ShiftType.exam;

    // If exam tab is empty but mock has shifts, default to mock
    if (examShifts.isEmpty && mockShifts.isNotEmpty) {
      defaultType = ShiftType.mock;
    }

    // TODO: Optionally find active shift and select its tab
    // final now = DateTime.now();
    // ... additional logic for active shift detection

    return ShiftSelectionState(
      shifts: shifts,
      selectedType: defaultType,
      isLoading: false,
    );
  }

  return const ShiftSelectionState();
}
```

3. In lib/views/shift_selection/shift_selection_screen.dart, add time formatting helper and use it:
```dart
// Add this helper method to the class
String _formatTimeHHMM(String time) {
  // "09:00:00" -> "09:00"
  if (time.length >= 5) {
    return time.substring(0, 5);
  }
  return time;
}

// Update line ~275 where time is displayed:
Text(
  '${_formatTimeHHMM(shift.startTime)} - ${_formatTimeHHMM(shift.endTime)}',
  style: AppTextStyles.bodySmall,
),
```

4. Run: flutter analyze
5. Run: flutter test
6. Commit: git add -A && git commit -m "fix: Auto-select non-empty shift tab and remove seconds from time (#5, #6)"
7. Push: git push -u origin fix/shift-selection-ux

## CONSTRAINTS
- Only modify the two files listed above
- Don't change the visual design, only the logic
- Keep time format consistent throughout the file

## REPORT WHEN DONE
- Files changed
- flutter analyze output
- Confirm time now shows "09:00" format
- Confirm empty tab is not default-selected
```

---

## Wave 1: Second Batch (2 Instances) - Run After First Batch Merged

### Instance 3: Training Screen

**Branch**: `fix/training-screen`
**Bugs**: #11 (Duration/Priority shown), #12 (No skip option)
**Estimated Time**: 45 minutes

```
You are fixing Bugs #11 and #12 in the OpsView Mobile Flutter app.

## CONTEXT
Read these files to understand the bugs and fixes:
- docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md (search for "BUG #11", "BUG #12", and "PR-6")
- docs/OpsView Mobile App — Final Design Specification.md (Screen 7: Training Video)

## SOURCE FILES TO MODIFY
- lib/views/training/training_screen.dart (lines 74-186)
- lib/viewmodels/training_viewmodel.dart
- lib/core/localization/strings/en_strings.dart (add "skip" string if needed)

## THE BUGS

### Bug #11: Training Duration and Priority shown when not from API
- UI shows hardcoded "4m 20s" duration and "Mandatory" priority
- API doesn't provide these fields
- Should show simple training link only

### Bug #12: No training skip option
- Only "Completed" button exists
- Need a "Skip" button per spec

## IMPLEMENTATION STEPS
1. Create branch: git checkout -b fix/training-screen

2. In lib/views/training/training_screen.dart, simplify _buildVideoCard:
   - REMOVE the Duration column (lines ~138-155)
   - REMOVE the Priority column (lines ~156-175)
   - Keep only: thumbnail, title, play icon
   - Simplify to a centered card with training link

3. Add Skip button in the main build() method:
```dart
// After the Complete Button, add:
const SizedBox(height: 12),
TextButton(
  onPressed: () {
    // Skip training and go to home
    if (context.mounted) {
      context.go(AppRoutes.home);
    }
  },
  child: Text(
    strings.skip, // Add to localization if needed
    style: AppTextStyles.body.copyWith(
      color: AppColors.textMuted,
    ),
  ),
),
```

4. If "skip" string doesn't exist in localization:
   - Add to lib/core/localization/strings/en_strings.dart:
   ```dart
   String get skip => 'Skip';
   ```

5. In lib/viewmodels/training_viewmodel.dart:
   - Add skipTraining() method if needed (may just navigate directly in UI)

6. Run: flutter analyze
7. Run: flutter test
8. Commit: git add -A && git commit -m "fix: Remove hardcoded duration/priority and add skip button (#11, #12)"
9. Push: git push -u origin fix/training-screen

## CONSTRAINTS
- Keep the training link clickable to open in browser
- Skip should navigate to home same as "Completed"
- Don't remove the training link display, just the metadata

## REPORT WHEN DONE
- Files changed
- flutter analyze output
- Confirm Duration/Priority sections removed
- Confirm Skip button works
```

---

### Instance 4: Logout Functionality

**Branch**: `fix/logout-functionality`
**Bug**: #22 (Logout not working)
**Estimated Time**: 30 minutes

```
You are fixing Bug #22 in the OpsView Mobile Flutter app.

## CONTEXT
Read these files to understand the bug and fix:
- docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md (search for "BUG #22" and "PR-10")
- docs/OpsView Mobile App — Final Design Specification.md (Screen 10: Profile / Settings)

## SOURCE FILES TO MODIFY
- lib/viewmodels/settings_viewmodel.dart (lines 67-82)
- lib/views/settings/settings_screen.dart (lines 355-376) - for understanding only

## THE BUG
Logout button is always disabled because hasPendingSync logic is wrong.

## ROOT CAUSE (from RCA)
Current code checks if ANY task has status "PENDING" (not done yet).
This is WRONG - all tasks start as PENDING.
Should check for UNSYNCED submissions instead.

## WRONG CODE (current):
```dart
final hasPendingSync = appState.tasks.any(
  (t) => t.taskStatus == TaskStatus.pending.toDbValue,
);
```

## CORRECT LOGIC:
Should check if there are any task submissions that haven't been synced to backend.

## IMPLEMENTATION STEPS
1. Create branch: git checkout -b fix/logout-functionality

2. In lib/viewmodels/settings_viewmodel.dart, fix the build() method:
```dart
@override
SettingsState build() {
  final appState = ref.watch(appStateProvider);

  // FIXED: Check for unsynced SUBMISSIONS, not pending TASKS
  // A submission is unsynced if its status is 'UNSYNCED'
  final hasUnsyncedData = appState.taskSubmissions.any(
    (s) => s.status == SyncStatus.unsynced.toDbValue,
  );

  // Also check for unsynced profiles
  final hasUnsyncedProfiles = appState.profile != null &&
    appState.profile!.backendProfileId == null;

  return SettingsState(
    user: appState.user,
    exam: appState.exam,
    center: appState.center,
    service: appState.user?.service,
    profile: appState.profile,
    hasPendingSync: hasUnsyncedData || hasUnsyncedProfiles,
  );
}
```

3. Import SyncStatus if not already imported:
```dart
import '../models/task/task_enums.dart';
```

4. Verify the settings_screen.dart logout button logic:
   - It should show warning when hasPendingSync is true
   - But still ALLOW logout (per spec: "allow logout, preserve data locally")
   - Check if the button is disabled when hasPendingSync - if so, that's also a bug to fix

5. In settings_screen.dart line 359, change:
```dart
// FROM:
onPressed: state.hasPendingSync ? null : () async { ... }

// TO (allow logout even with warning):
onPressed: () async {
  if (state.hasPendingSync) {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.unsyncedDataWarning ?? 'Unsynced Data'),
        content: Text(strings.logoutWithUnsyncedData ?? 'You have unsynced data. Logout anyway?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(strings.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(strings.logout)),
        ],
      ),
    );
    if (confirm != true) return;
  }
  await viewModel.logout();
  if (context.mounted) {
    context.go(AppRoutes.login);
  }
},
```

6. Add missing localization strings if needed

7. Run: flutter analyze
8. Run: flutter test
9. Commit: git add -A && git commit -m "fix: Logout button now works - check unsynced submissions not pending tasks (#22)"
10. Push: git push -u origin fix/logout-functionality

## CONSTRAINTS
- Keep the warning indicator for unsynced data
- Allow logout even with unsynced data (with confirmation)
- Preserve local data on logout (already implemented in logout() method)

## REPORT WHEN DONE
- Files changed
- flutter analyze output
- Confirm logout works with no submissions
- Confirm warning shows with unsynced data
- Confirm can still logout after warning
```

---

## Testing Options - Detailed Guide

### Option A: Flutter Unit & Widget Tests

**Best For**: Fast CI/CD, testing business logic, widget rendering

#### Setup

```bash
# Already included in Flutter - no additional setup needed
flutter test  # Run all tests
```

#### Dependencies (pubspec.yaml)

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0  # For mocking
```

#### Example Test

```dart
// test/viewmodels/login_viewmodel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('LoginViewModel', () {
    test('should convert exam code to lowercase', () {
      // Test the lowercase transformation
      expect('NEET1'.toLowerCase(), equals('neet1'));
    });
  });
}
```

#### Pros & Cons

| Pros | Cons |
|------|------|
| Very fast (~seconds) | No real device testing |
| Runs in CI/CD easily | Can't test platform-specific features |
| No device/emulator needed | Limited camera/GPS testing |
| Good for business logic | Widget tests can be flaky |

---

### Option B: Patrol (Flutter E2E)

**Best For**: Real device testing, full user flows, Flutter-native

#### Setup

```bash
# Add to pubspec.yaml
flutter pub add patrol --dev
flutter pub add patrol_finders --dev

# For Android
patrol build android

# For iOS
patrol build ios
```

#### Dependencies (pubspec.yaml)

```yaml
dev_dependencies:
  patrol: ^3.6.0
  patrol_finders: ^2.1.0
```

#### Required: patrol_cli

```bash
dart pub global activate patrol_cli
```

#### Example Test

```dart
// integration_test/login_test.dart
import 'package:patrol/patrol.dart';
import 'package:opsview_mobile/main.dart' as app;

void main() {
  patrolTest('User can login with lowercase conversion', ($) async {
    app.main();
    await $.pumpAndSettle();

    // Enter uppercase exam code
    await $(#examCodeField).enterText('NEET1');

    // Verify it's converted to lowercase
    expect($(#examCodeField).text, equals('neet1'));

    // Complete login
    await $(#usernameField).enterText('CENTER060_FRISKING');
    await $(#passwordField).enterText('password');
    await $('Secure Login').tap();

    // Verify navigation
    await $.pumpAndSettle();
    expect($('Confirm'), findsOneWidget);
  });
}
```

#### Run on Device

```bash
# Android (device connected)
patrol test --target integration_test/login_test.dart

# iOS (simulator)
patrol test --target integration_test/login_test.dart --device iPhone-15
```

#### Pros & Cons

| Pros | Cons |
|------|------|
| Real device/emulator | Slower (~minutes per test) |
| Flutter-native API | Requires physical device or emulator |
| Tests actual UI rendering | Setup can be complex |
| Tests camera, GPS, etc. | iOS requires Mac + Xcode |
| Native permission handling | Android requires SDK setup |

---

### Option C: Maestro (Cross-Platform)

**Best For**: Quick E2E, cross-platform, YAML-based tests

#### Setup

```bash
# macOS
brew install maestro

# Linux/Windows
curl -Ls "https://get.maestro.mobile.dev" | bash
```

#### No pubspec changes needed - Maestro runs externally

#### Example Test

```yaml
# .maestro/login_flow.yaml
appId: com.opsview.mobile
---
- launchApp

# Test lowercase conversion
- tapOn:
    id: "examCodeField"
- inputText: "NEET1"

# Verify (Maestro automatically waits)
- assertVisible: "neet1"

- tapOn:
    id: "usernameField"
- inputText: "center060_frisking"

- tapOn:
    id: "passwordField"
- inputText: "password"

- tapOn: "Secure Login"

# Verify navigation to confirmation
- assertVisible: "Confirm"
```

#### Run Tests

```bash
# Run single test
maestro test .maestro/login_flow.yaml

# Run all tests in folder
maestro test .maestro/

# Record a test (interactive)
maestro record
```

#### Pros & Cons

| Pros | Cons |
|------|------|
| Easy YAML syntax | External tool (not Flutter-native) |
| Cross-platform (iOS + Android) | Limited Flutter widget access |
| Fast to write tests | Can't access Flutter state |
| Visual recording tool | Uses accessibility IDs |
| No code changes needed | May miss Flutter-specific bugs |
| Great for smoke tests | Less precise than Patrol |

---

## Comparison Matrix

| Feature | Flutter Test | Patrol | Maestro |
|---------|--------------|--------|---------|
| **Speed** | ⚡ Very Fast | 🐢 Slow | 🚶 Medium |
| **Setup** | None | Medium | Easy |
| **Real Device** | ❌ | ✅ | ✅ |
| **Camera/GPS** | ❌ | ✅ | ✅ |
| **CI/CD** | ✅ Easy | ⚠️ Complex | ✅ Easy |
| **Flutter State** | ✅ | ✅ | ❌ |
| **Learning Curve** | Low | Medium | Low |
| **Best For** | Logic, Widgets | Full E2E | Smoke Tests |

---

## Recommended Testing Strategy

### For This Bug Fix Project:

1. **Before each PR merge**: Run `flutter analyze` and `flutter test`
2. **After Wave 1 merged**: Run Maestro smoke test on device
3. **After Wave 2 merged**: Run Patrol tests for profile/camera flows
4. **Final regression**: Full Patrol suite on physical device

### Quick Smoke Test Script

```bash
#!/bin/bash
# scripts/smoke_test.sh

echo "Running Flutter analyze..."
flutter analyze
if [ $? -ne 0 ]; then exit 1; fi

echo "Running Flutter tests..."
flutter test
if [ $? -ne 0 ]; then exit 1; fi

echo "Building APK..."
flutter build apk --debug
if [ $? -ne 0 ]; then exit 1; fi

echo "All checks passed!"
```

---

## Instance Requirements Summary

| Requirement | Wave 1 | Wave 2+ | Testing |
|-------------|--------|---------|---------|
| Flutter SDK | ✅ | ✅ | ✅ |
| Dart SDK | ✅ | ✅ | ✅ |
| Git | ✅ | ✅ | ✅ |
| Android SDK | ❌ | ⚠️ (PR-4) | ✅ |
| Xcode (Mac) | ❌ | ⚠️ (PR-4) | ✅ |
| Physical Device | ❌ | ❌ | ✅ |
| Patrol CLI | ❌ | ❌ | ⚠️ |
| Maestro CLI | ❌ | ❌ | ⚠️ |

**Note**: Wave 2 PR-4 (Camera/Selfie) may need device testing to verify camera fixes.

