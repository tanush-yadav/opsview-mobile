# OpsView Mobile - Agentic Workflow Guide

> How to efficiently fix all bugs using Claude Code with parallel execution

---

## Recommended Approach: Phased Parallel Execution

**DON'T**: Run 10 Claude Code instances in parallel on all PRs
- PRs have dependencies (PR-8 needs PR-7 changes)
- Merge conflicts will be painful
- Testing becomes chaotic

**DO**: Use a **2-wave parallel approach** with automated testing between waves

---

## Step 1: Merge This Analysis PR First

```bash
# On main branch
git merge claude/opsview-bug-analysis-w6Y0x
git push origin main
```

This gives all agents access to the RCA document.

---

## Step 2: Wave 1 - Independent PRs (4 Parallel Instances)

These PRs have **NO dependencies** on each other:

| Instance | Branch | Bugs | Scope |
|----------|--------|------|-------|
| Agent 1 | `fix/login-input-validation` | #2 | 50 lines |
| Agent 2 | `fix/shift-selection-ux` | #5, #6 | 80 lines |
| Agent 3 | `fix/training-screen` | #11, #12 | 80 lines |
| Agent 4 | `fix/logout-functionality` | #22 | 50 lines |

### Launch Command (for each agent)

```bash
# Terminal 1 - Login Validation
claude --prompt "Read docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md section for PR-1.
Create branch fix/login-input-validation from main.
Implement the fix for Bug #2 (auto-lowercase).
Run flutter analyze. Commit and push."

# Terminal 2 - Shift Selection
claude --prompt "Read docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md section for PR-5.
Create branch fix/shift-selection-ux from main.
Implement fixes for Bugs #5 and #6.
Run flutter analyze. Commit and push."

# Terminal 3 - Training Screen
claude --prompt "Read docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md section for PR-6.
Create branch fix/training-screen from main.
Implement fixes for Bugs #11 and #12.
Run flutter analyze. Commit and push."

# Terminal 4 - Logout
claude --prompt "Read docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md section for PR-10.
Create branch fix/logout-functionality from main.
Implement fix for Bug #22.
Run flutter analyze. Commit and push."
```

### After Wave 1: Test & Merge

```bash
# Run Flutter tests
flutter test

# If tests pass, merge all Wave 1 PRs to main
git checkout main
git merge fix/login-input-validation
git merge fix/shift-selection-ux
git merge fix/training-screen
git merge fix/logout-functionality
git push origin main
```

---

## Step 3: Wave 2 - Dependent PRs (3 Parallel Instances)

These depend on Wave 1 being merged:

| Instance | Branch | Bugs | Depends On |
|----------|--------|------|------------|
| Agent 5 | `fix/profile-creation` | #7, #8, #10 | main (Wave 1) |
| Agent 6 | `fix/camera-selfie` | #1, #9 | main (Wave 1) |
| Agent 7 | `fix/navigation-flow` | #3 | main (Wave 1) |

### Launch Command

```bash
# All agents start from updated main
git checkout main && git pull

# Terminal 5 - Profile Creation
claude --prompt "Read docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md section for PR-3.
Create branch fix/profile-creation from main.
Implement fixes for Bugs #7, #8, #10 (validations, error handling).
Run flutter analyze and flutter test. Commit and push."

# Terminal 6 - Camera/Selfie
claude --prompt "Read docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md section for PR-4.
Create branch fix/camera-selfie from main.
Implement fixes for Bugs #1 and #9 (camera lockout, retake).
Run flutter analyze. Commit and push."

# Terminal 7 - Navigation Flow
claude --prompt "Read docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md section for PR-2.
Create branch fix/navigation-flow from main.
Implement fix for Bug #3 (skip profile/training).
NOTE: Skip TASK_DOWNLOADED event (de-prioritized).
Run flutter analyze. Commit and push."
```

---

## Step 4: Wave 3 - Task Workflow (2 Sequential)

These must be done **sequentially** (PR-8 depends on PR-7):

```bash
# Terminal 8 - Task Capture (first)
claude --prompt "Read docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md section for PR-7.
Create branch fix/task-capture from main.
Implement fixes for:
- Bug #13 (Inside/Outside indicator)
- Bug #15 (Full image view)
- Bug #16 (Button text -> Submit Task)
NOTE: Skip image count enforcement (deferred).
NOTE: Gallery access IS allowed - no change needed.
Run flutter analyze. Commit and push."

# After PR-7 merged:
git checkout main && git merge fix/task-capture && git push

# Terminal 8 - Data Isolation (second)
claude --prompt "Read docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md section for PR-8.
Create branch fix/task-data-isolation from main.
Implement fixes for Bugs #18 and #21 (task data cross-contamination).
CRITICAL: Use UUID for task references, not task code.
Run flutter analyze. Commit and push."
```

---

## Step 5: Wave 4 - Sync Status (Final)

```bash
# Terminal 9 - Sync Status
claude --prompt "Read docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md section for PR-9.
Create branch fix/sync-status from main.
Implement:
- Auto-sync when internet becomes available
- Correct sync status display per task
- Use UUID for task identification
Add connectivity_plus listener in main.dart.
Run flutter analyze. Commit and push."
```

---

## Automated Testing Integration

### Option A: Flutter Integration Tests (Recommended)

Create a hook that runs tests after each commit:

```bash
# .claude/hooks/post-commit.sh
#!/bin/bash
echo "Running Flutter tests..."
flutter test
if [ $? -ne 0 ]; then
  echo "Tests failed! Please fix before pushing."
  exit 1
fi
```

### Option B: Device Testing with Patrol/Maestro

For real device testing, you can use **Patrol** (Flutter-native E2E):

```yaml
# pubspec.yaml
dev_dependencies:
  patrol: ^3.0.0
```

```dart
// integration_test/app_test.dart
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('Login flow works', ($) async {
    await $.pumpWidgetAndSettle(const OpsViewApp());

    // Test login
    await $(TextField).at(0).enterText('neet1'); // exam code
    await $(TextField).at(1).enterText('center060_frisking');
    await $(TextField).at(2).enterText('password');
    await $('Secure Login').tap();

    // Verify navigation
    await $.waitUntilVisible($('Confirm'));
  });
}
```

Run on connected device:
```bash
patrol test --target integration_test/app_test.dart
```

### Option C: CI/CD Integration

Add to `.github/workflows/test.yml`:

```yaml
name: Test on PR
on: [pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

---

## Complete Execution Timeline

```
Day 1 Morning:
├── Merge analysis PR to main
└── Launch Wave 1 (4 parallel agents)

Day 1 Afternoon:
├── Review Wave 1 PRs
├── Run tests
└── Merge Wave 1 to main

Day 1 Evening:
├── Launch Wave 2 (3 parallel agents)
└── Launch Wave 3 Part 1 (Task Capture)

Day 2 Morning:
├── Review Wave 2 PRs
├── Merge Wave 2 to main
├── Merge Task Capture PR
└── Launch Wave 3 Part 2 (Data Isolation)

Day 2 Afternoon:
├── Merge Data Isolation PR
├── Launch Wave 4 (Sync Status)
└── Final integration testing

Day 2 Evening:
├── Merge all remaining PRs
└── Full regression test on device
```

---

## Agent Prompt Template

Use this template for consistent agent behavior:

```
You are fixing bugs in the OpsView Mobile Flutter app.

CONTEXT:
- Read: docs/BUG_RCA_AND_IMPLEMENTATION_PLAN.md
- Focus on: [SECTION FOR THIS PR]
- Branch: [BRANCH NAME]

TASK:
1. Create branch from main
2. Implement fixes as described in RCA document
3. Follow existing code patterns
4. Run: flutter analyze
5. Run: flutter test (if tests exist)
6. Commit with descriptive message
7. Push branch

CONSTRAINTS:
- Don't modify unrelated files
- Use existing utilities/patterns
- Add comments only where logic is complex
- Keep changes minimal and focused

IMPORTANT NOTES:
- Gallery access IS allowed (spec updated)
- Image count enforcement is DEFERRED
- TASK_DOWNLOADED event is DEPRIORITIZED
- Use UUID for task references, not task code

When done, report:
- Files changed
- Key changes made
- Any issues encountered
- Test results
```

---

## Summary

| Wave | PRs | Parallelism | Duration |
|------|-----|-------------|----------|
| 1 | PR-1, PR-5, PR-6, PR-10 | 4 agents | ~1 hour |
| 2 | PR-3, PR-4, PR-2 | 3 agents | ~2 hours |
| 3 | PR-7, PR-8 | Sequential | ~2 hours |
| 4 | PR-9 | 1 agent | ~1 hour |

**Total**: 8-9 PRs in ~6 hours of agent time, spread across 2 days with testing.

---

## Quick Start Checklist

- [ ] Merge analysis PR to main
- [ ] Set up test hooks (Option A, B, or C)
- [ ] Launch Wave 1 agents
- [ ] Review & merge after each wave
- [ ] Device test after Wave 4
- [ ] Create release candidate

