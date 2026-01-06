First 2 Instances (Launch Now)
Terminal 1: Login Validation
claude 

"You are fixing Bug #2 in the OpsView Mobile Flutter app.

## CONTEXT
Read these files to understand the bug and fix:
- docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md (search for 'BUG #2' and 'PR-1')
- lib/views/login/login_screen.dart

## THE BUG
Exam code and username fields don't auto-convert to lowercase.
Password should remain case-sensitive.

## IMPLEMENTATION
1. git checkout main && git pull
2. git checkout -b fix/login-input-validation
3. Create lib/core/utils/text_formatters.dart with LowerCaseTextFormatter class
4. In login_screen.dart: Apply formatter to examCode and username fields only
5. Run: flutter analyze
6. git add -A && git commit -m 'fix: Auto-lowercase exam code and username on login (#2)'
7. git push -u origin fix/login-input-validation

## CONSTRAINTS
- Keep password case-sensitive
- Follow existing code style in lib/core/utils/

Report: files changed, analyze output, any issues."


Terminal 2: Shift Selection
claude 

"You are fixing Bugs #5 and #6 in the OpsView Mobile Flutter app.

## CONTEXT
Read these files:
- docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md (search for 'BUG #5', 'BUG #6', 'PR-5')
- lib/viewmodels/shift_selection_viewmodel.dart
- lib/views/shift_selection/shift_selection_screen.dart

## THE BUGS
#5: Default tab shows empty when other tab has shifts - auto-select non-empty tab
#6: Time shows '09:00:00' instead of '09:00' - format to HH:mm

## IMPLEMENTATION
1. git checkout main && git pull
2. git checkout -b fix/shift-selection-ux
3. In viewmodel build(): Check which tab has shifts, default to non-empty one
4. In screen: Add _formatTimeHHMM(time) helper that returns time.substring(0,5)
5. Apply formatter to shift time displays
6. Run: flutter analyze
7. git add -A && git commit -m 'fix: Auto-select non-empty shift tab and format time HH:mm (#5, #6)'
8. git push -u origin fix/shift-selection-ux

Report: files changed, analyze output, confirm time shows without seconds."

After First 2 Merged → Launch Remaining 2

Terminal 3: Training Screen
claude "You are fixing Bugs #11 and #12 in the OpsView Mobile Flutter app.

## CONTEXT
Read these files:
- docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md (search for 'BUG #11', 'BUG #12', 'PR-6')
- lib/views/training/training_screen.dart
- lib/viewmodels/training_viewmodel.dart

## THE BUGS
#11: Shows hardcoded '4m 20s' duration and 'Mandatory' - API doesn't provide these, REMOVE them
#12: No Skip button - need to add one per spec

## IMPLEMENTATION
1. git checkout main && git pull
2. git checkout -b fix/training-screen
3. In training_screen.dart _buildVideoCard(): REMOVE Duration and Priority columns entirely
4. Add Skip TextButton below the Complete button that navigates to AppRoutes.home
5. Add 'skip' string to en_strings.dart if missing
6. Run: flutter analyze
7. git add -A && git commit -m 'fix: Remove hardcoded duration/priority and add skip button (#11, #12)'
8. git push -u origin fix/training-screen

Report: files changed, confirm Duration/Priority removed, Skip button works."

Terminal 4: Logout Fix
claude "You are fixing Bug #22 in the OpsView Mobile Flutter app.

## CONTEXT
Read these files:
- docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md (search for 'BUG #22' and 'PR-10')
- lib/viewmodels/settings_viewmodel.dart
- lib/views/settings/settings_screen.dart

## THE BUG
Logout button always disabled. Wrong logic checks if ANY task is PENDING (all tasks start PENDING).
Should check for UNSYNCED submissions instead.

## FIX
In settings_viewmodel.dart build():
WRONG: appState.tasks.any((t) => t.taskStatus == TaskStatus.pending.toDbValue)
RIGHT: appState.taskSubmissions.any((s) => s.status == SyncStatus.unsynced.toDbValue)

Also check: appState.profile?.backendProfileId == null (unsynced profile)

## IMPLEMENTATION
1. git checkout main && git pull
2. git checkout -b fix/logout-functionality
3. Fix hasPendingSync logic in settings_viewmodel.dart
4. In settings_screen.dart: Allow logout even with warning (show confirmation dialog)
5. Run: flutter analyze
6. git add -A && git commit -m 'fix: Logout button works - check unsynced submissions not pending tasks (#22)'
7. git push -u origin fix/logout-functionality

Report: files changed, confirm logout works, warning shows for unsynced data."





Testing Options Summary
Tool	Install	Best For	Run Command
Flutter Test	Built-in	Fast CI, unit tests	flutter test
Patrol	dart pub global activate patrol_cli	Real device E2E, camera	patrol test
Maestro	brew install maestro	Quick smoke tests, YAML	maestro test .maestro/
Recommended Flow
# After each PR merge
flutter analyze && flutter test

# After all Wave 1 merged (on device)
maestro test .maestro/login_smoke.yaml

# After Wave 2 (camera fixes)
patrol test --target integration_test/selfie_test.dart

Instance Requirements
What	Command	Needed For
Flutter SDK	flutter doctor	All instances
Git	git --version	All instances
Project deps	flutter pub get	Run once before
Android SDK	flutter doctor --android	Device testing only
Xcode	xcode-select -p	iOS testing only
Your 4 Wave 1 instances only need: Flutter SDK + Git + flutter pub get run once

