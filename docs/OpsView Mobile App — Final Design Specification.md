# OpsView Mobile App — Final Design Specification

> **Source of Truth Document**
> 

> Last Updated: 6 January 2026 | Version 1.0
> 

> 
> 

> This
 document consolidates all requirements, API specifications, review comments, and known bugs into a single authoritative reference for the OpsView Mobile App development.
> 

---

## Table of Contents

1. [Overview & App Flow](#overview)
2. [Screen 1: Splash Screen](#screen-1)
3. [Screen 2: Login](#screen-2)
4. [Screen 3: Confirmation](#screen-3)
5. [Screen 4: Shift Selection](#screen-4)
6. [Screen 5: Profile Creation](#screen-5)
7. [Screen 6: Selfie Capture & Liveness](#screen-6)
8. [Screen 7: Training Video](#screen-7)
9. [Screen 8: Task Dashboard](#screen-8)
10. [Screen 9: Task Capture](#screen-9)
11. [Screen 10: Profile / Settings](#screen-10)
12. [Data Sync Architecture](#data-sync)
13. [Known Bugs & Required Fixes](#bugs)
14. [API Reference](#api-reference)

---

## Overview & App Flow {#overview}

### Application Purpose

OpsView Mobile App enables field operators (Frisking, Biometric, CSO) to:

- Authenticate and verify their identity
- Download tasks for assigned shifts
- Capture geo-tagged photos for task completion
- Work offline with automatic sync when connectivity returns

### Core User Flow

```
Splash → Login → Confirmation → Shift Selection → Profile Creation (if no profile for shift) → Training → Task Dashboard → Task Capture
```

### Key Design Principles

| Principle | Implementation |
| --- | --- |
| **Offline-First** | All task work must function without internet; sync when available |
| **Geo-Fencing** | WARN only (informative indicator), never block user actions |
| **Data Isolation** | Each task's submissions are completely independent |
| **Auto-Sync** | Sync immediately when internet becomes available |

---

## Screen 1: Splash Screen {#screen-1}

### Behavior

| Scenario | Action |
| --- | --- |
| **Online** | Show app logo, check for stored JWT token |
| **Offline** | Show logo, if valid cached session → skip to Shift Selection |
| **API** | None required |

### Requirements

- Display OpsView logo centered
- Check local storage for valid JWT (7-day expiry)
- Auto-navigate based on session state

---

## Screen 2: Login {#screen-2}

### Behavior

| Scenario | Action |
| --- | --- |
| **Online** | Enter Exam Code + Username + Password → Authenticate |
| **Offline** | ❌ Cannot login — Show "Internet required" message |

### UI Requirements

<aside>
⚠️

**BUG FIX REQUIRED**: Exam code and username must auto-convert to lowercase while typing. Password remains case-sensitive.

</aside>

- **Exam Code** field — auto-lowercase
- **Username** field — format: `CenterCode_service` — auto-lowercase
- **Password** field — with eye toggle, case-sensitive
- **Login button**

### API: `POST /api/auth/op-login`

**Request:**

```json
{
  "username": "center060_frisking",
  "password": "Braj1234",
  "examCode": "neet1"
}
```

**Success Response (200):**

```json
{
  "status": "SUCCESS",
  "code": "200",
  "data": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "tokenType": "Bearer",
    "user": {
      "id": "7d5806c9-cb79-4b8c-b87e-23ebaf0ee361",
      "username": "neet1_center060_frisking",
      "firstName": "Operator-CENTER060",
      "lastName": "frisking",
      "active": true,
      "roles": [{"id": 5, "name": "ROLE_CENTER_FRISKING", "shortName": "frisking"}],
      "centerCode": "CENTER060",
      "clientCode": "NEET",
      "examId": "f63fdcca-310e-46d0-b023-223618b2d02f",
      "centerId": "0fbbc69e-f9fd-43b3-b5dc-e912ad623adc",
      "service": "frisking"
    },
    "exam": {
      "id": "f63fdcca-310e-46d0-b023-223618b2d02f",
      "code": "NEET1",
      "name": "NEET Examination 2025",
      "fenceRadius": 0,
      "shifts": [
        {
          "id": "3becd6a0-f2ae-4529-926a-e6128b3c0ecf",
          "name": "Mock Day Shift",
          "type": "ExamDay",
          "startDate": "2025-12-17",
          "startTime": "09:00:00",
          "endDate": "2025-12-17",
          "endTime": "13:00:00",
          "services": [
            {"name": "frisking", "trainingLink": "[https://example.com/training/frisking](https://example.com/training/frisking)"}
          ]
        }
      ]
    },
    "center": {
      "id": "0fbbc69e-f9fd-43b3-b5dc-e912ad623adc",
      "code": "CENTER060",
      "name": "New Delhi Examination Center 60",
      "address": "Plot 60, Sector 1, Main Road",
      "city": "New Delhi",
      "state": "Delhi",
      "pinCode": "110060",
      "lat": "28.619900",
      "lng": "77.215000",
      "spoc1Name": "Ravi Kumar 60",
      "spoc1Contact": "900000060",
      "spoc2Name": "Anita Sharma 60",
      "spoc2Contact": "900000060"
    },
    "service": "frisking"
  }
}
```

**Failed Response (401):**

```json
{
  "status": "FAILED",
  "code": "401",
  "message": "Bad credentials",
  "notify": {"message": "Username or password is incorrect", "type": "error"}
}
```

### Data to Cache Locally

| Field | Source | Purpose |
| --- | --- | --- |
| `accessToken` | data.accessToken | All authenticated requests |
| `examId` | [data.exam.id](http://data.exam.id) | Task queries |
| `examName` | [data.exam.name](http://data.exam.name) | Display on Confirmation |
| `centerId` | [data.center.id](http://data.center.id) | Task queries |
| `centerName` | [data.center.name](http://data.center.name) | Display on Confirmation |
| `centerLat` | [data.center.lat](http://data.center.lat) | Offline geo-fencing |
| `centerLng` | [data.center](http://data.center).lng | Offline geo-fencing |
| `fenceRadius` | data.exam.fenceRadius | Geo-fence calculation |
| `shifts[]` | data.exam.shifts | Shift selection |
| `spoc1Name/Contact` | [data.center](http://data.center).spoc1* | Escalation contacts |
| `spoc2Name/Contact` | [data.center](http://data.center).spoc2* | Escalation contacts |
| `trainingLink` | data.exam.shifts[].services[].trainingLink | Training screen |

---

## Screen 3: Confirmation {#screen-3}

### Behavior

| Scenario | Action |
| --- | --- |
| **Online** | Display exam/center details for operator to confirm |
| **Offline** | N/A — only appears after fresh login |

### UI Elements

- **Exam Name** display (from login response: [`data.exam.name`](http://data.exam.name))
- **Center Name** display (from login response: [`data.center.name`](http://data.center.name))
- **Service Type** (from login response: `data.service`)
- **Confirm button** → proceeds to Shift Selection, then calls `GET /api/tasks/operator-tasks`
- **Exit App button** → closes app (no logout API needed, token remains valid 7 days)

<aside>
💡

**Review Note**: If operator selects incorrect center, they should logout and re-login with correct credentials.

</aside>

---

## Screen 4: Shift Selection {#screen-4}

### Behavior

| Scenario | Action |
| --- | --- |
| **Online** | Show available shifts → Download tasks for ALL shifts |
| **Offline** | ✅ Show cached shifts if data was downloaded earlier |

<aside>
⚠️

**BUG FIXES REQUIRED**:

1. Do NOT show seconds in shift timings — display only Hour:Minute (HH:mm)
2. Shift tab must auto-navigate to tab with active shift, or if only 1 shift, navigate to non-empty type tab
3. Do NOT show empty tabs
</aside>

### Shift Enabling Logic

| Rule | Implementation |
| --- | --- |
| **Active Shifts** | All shifts where `startDate + startTime` ≤ current device time |
| **Future Shifts** | Disabled automatically based on device time |
| **Past Shifts** | Active by default per device time |

### UI Elements

- **Shift cards** showing:
    - Shift name (e.g., "Morning Shift")
    - Type badge (MockDay / ExamDay)
    - Date & time range — **HH:mm format only, no seconds**
    - Status (Active / Upcoming)
- **Select button** per shift

### Data Source

Shifts come from login response: `data.exam.shifts[]`

### On Shift Selection

1. Check if shift has a profile tagged locally
2. If NO profile → Navigate to Profile Creation
3. If profile exists → Navigate to Task Dashboard
4. Send `TASK_DOWNLOADED` event after tasks are downloaded

<aside>
⚠️

**BUG FIX REQUIRED**: An event of type `TASK_DOWNLOADED` must be sent to backend after tasks are downloaded.

</aside>

---

## Screen 5: Profile Creation — Details {#screen-5}

### When to Show

- Launched when operator selects a shift AND that shift has no profile tagged
- This screen is typically used offline (during exam with jammers)

### Behavior

| Scenario | Action |
| --- | --- |
| **Online** | Enter details → OTP verification → Continue to Selfie |
| **Offline** | Enter details → Skip OTP → Create local profile → Sync later |

<aside>
⚠️

**BUG FIXES REQUIRED**:

1. Add basic validations for Age, Mobile (10 digits), Aadhaar (12 digits)
2. "Continue to Selfie" button must be disabled until validations pass
3. Mobile OTP can be skipped when offline (no network)
</aside>

### UI Elements

- **Full Name** field
- **Age** field — Integer only
- **Mobile Number** field — 10 digits, validated
- **Aadhaar Number** field — 12 digits, masked display, checksum validation on app
- **Send OTP button** (disabled if offline)
- **OTP input** (appears after sending)
- **Continue to Selfie button** — active only when validations pass

### API: Mobile Verification

**Initiate OTP: `POST /api/mobile-verifications`**

```json
{"contact": "9876543210"}
```

**Response:**

```json
{
  "status": "SUCCESS",
  "code": "2001",
  "data": {
    "id": "dd0ada5f-83a2-4d21-b7a3-d855b28358ed",
    "contact": "9876543210",
    "status": "OTP_SENT",
    "attemptedAt": "2025-12-26T04:32:26.246Z",
    "expiresAt": "2025-12-26T04:34:26.246Z"
  }
}
```

| Parameter | Value |
| --- | --- |
| OTP Validity | 2 minutes (from `expiresAt`) |
| Aadhaar Validation | Client-side 12-digit format check only |

**Verify OTP: `POST /api/mobile-verifications/{id}/verify`**

```json
{"otp": "4296"}
```

**Resend OTP: `POST /api/mobile-verifications/{id}/resend`**

---

## Screen 6: Selfie Capture & Liveness {#screen-6}

### Behavior

| Scenario | Action |
| --- | --- |
| **Online/Offline** | Capture selfie → Liveness check (local) → Show location status |

<aside>
⚠️

**BUG FIXES REQUIRED**:

1. Camera must open smoothly in one go — no loading loops
2. Never lock out user on failed attempts
3. Retake Selfie button must work correctly
4. Profile submission must not show random error popups
</aside>

### UI Elements

- **Camera preview** (front-facing only)
- **Face guide overlay** (oval frame)
- **Capture button**
- **Preview of captured image**
- **Location indicator** — Show green (inside) or red (outside) — NOT blocking
- **Retake / Continue buttons**

### Liveness Configuration

| Parameter | Value |
| --- | --- |
| SDK | MLKit |
| Status Values | `PASSED`, `FAILED`, `UNKNOWN` |
| Threshold | 70%+ score = PASSED (app configurable) |
| Geo-location | Optional — show indicator but never block |
| Max Image Size | 15MB |

### Profile ID Generation (Offline)

```
profileId = Mobile + Aadhaar + Timestamp
```

### API: Create Profile `POST /api/profiles`

**Request (multipart/form-data):**

```
file: <selfie.jpg>
payload: {
  "id": "a99d6214-d37d-43a7-a566-b4870d71fcb3",
  "name": "Rajesh Kumar",
  "contact": "9876543210",
  "age": 28,
  "aadhaar": "123412341234",
  "livenessStatus": "PASSED",
  "livenessScore": 97.2,
  "livenessAttemptedAt": "2025-12-06T06:07:40.328Z",
  "location": "HCL Chack Gajaria Campus",
  "mobileVerificationId": "a3f9c8b0-1d23-4e56-9f78-1234567890ab",
  "creationTime": "2025-11-23T03:32:57Z"
}
```

**Response (201):**

```json
{
  "status": "SUCCESS",
  "code": "2001",
  "data": {
    "id": "a99d6214-d37d-43a7-a566-b4870d71fcb3",
    "clientCode": "NEET",
    "examId": "f63fdcca-310e-46d0-b023-223618b2d02f",
    "centerId": "0fbbc69e-f9fd-43b3-b5dc-e912ad623adc",
    "service": "frisking",
    "name": "Rajesh Kumar",
    "contact": "9876543210",
    "age": 28,
    "aadhaar": "XXXX-XXXX-1234",
    "otpVerified": false,
    "livenessStatus": "PASSED",
    "livenessScore": 97.2
  }
}
```

---

## Screen 7: Training Video {#screen-7}

### Behavior

| Scenario | Action |
| --- | --- |
| **Online** | Show training link → Opens in external browser |
| **Offline** | Show link but disabled / warn "Internet required" |

<aside>
⚠️

**BUG FIXES REQUIRED**:

1. Do NOT show "Duration" and "Priority" when not provided by API
2. Show simple training link with default icon centered on screen
3. Must have a SKIP option
4. Request permission before leaving app to open browser
</aside>

### UI Elements

- **Title**: "Training Required"
- **Training link** — simple icon + link, centered
- **Watch Training button** → opens browser (with permission prompt)
- **Skip button** → proceeds to Task Dashboard

### Data Source

Training link from: `data.exam.shifts[].services[].trainingLink`

### Tracking

- Training completion is NOT tracked by API
- User can skip freely

---

## Screen 8: Task Dashboard / Home {#screen-8}

### Behavior

| Scenario | Action |
| --- | --- |
| **Online** | Fetch fresh task list, show sync status |
| **Offline** | ✅ Show cached tasks, show "Unsynced" warning |

<aside>
⚠️

**BUG FIXES REQUIRED**:

1. Auto-sync when internet becomes available — don't show "unsynced" if synced
2. Only unsynced tasks should show "unsynced" indicator
3. Synced tasks must show correct synced status
4. Each task's data must be isolated — no cross-contamination
</aside>

### UI Elements

- **Header**: Shift name, sync status indicator
- **Tab**: Pending | Submitted
- **Task cards** showing:
    - Task label
    - Task description
    - Status (Pending / Completed)
    - Thumbnail of captured image (if any)
- **Capture button** per task
- **Floating Sync button**

### API: `GET /api/tasks/operator-tasks`

**Optional Query Param:** `?shiftId={shiftId}`

**Response:**

```json
{
  "status": "SUCCESS",
  "code": "2000",
  "data": [
    {
      "shift": {
        "id": "3becd6a0-f2ae-4529-926a-e6128b3c0ecf",
        "name": "Mock Day Shift",
        "type": "ExamDay",
        "startDate": "2025-12-17",
        "startTime": "09:00:00",
        "endDate": "2025-12-17",
        "endTime": "13:00:00"
      },
      "tasks": [
        {
          "id": "1b5468f8-1329-445d-9aff-33d102209c65",
          "taskId": "FRISK_M_T2",
          "taskLabel": "Material Image",
          "taskDesc": "Upload image showing frisking-related materials",
          "taskType": "IMAGE",
          "seqNumber": 1,
          "required": true,
          "taskStatus": "PENDING",
          "submissions": []
        }
      ]
    }
  ]
}
```

---

## Screen 9: Task Capture {#screen-9}

### Behavior

| Scenario | Action |
| --- | --- |
| **Online** | Capture image → Upload immediately |
| **Offline** | ✅ Capture → Save locally → Sync when online |

<aside>
⚠️

**BUG FIXES REQUIRED**:

1. Show INSIDE/OUTSIDE indicator while capturing photos
2. ~~Disable gallery access — camera only throughout app~~ **[UPDATED: Gallery access IS allowed]**
3. ~~Enforce image count limits from task config (`no-img-cnt`)~~ **[DEFERRED: Field not present in API]**
4. Button should say "Submit Task" not "Complete Task"
5. ~~Submit button active ONLY when exact required images are taken~~ **[DEFERRED: See #3]**
6. User must be able to view full image of last submission
7. Each task's observations/messages must be isolated
</aside>

### UI Elements

- **Task title & instructions**
- **Camera preview / Capture button** (gallery allowed)
- **Captured image preview**
- **INSIDE/OUTSIDE badge** — informative only, not blocking
- **Distance indicator** (e.g., "120m from center")
- **Message/Observation field** — isolated per task
- **Previous submissions gallery** (view full image supported)
- **Retake / Submit buttons**

### Request Headers

```
x-lat: 28.6139
x-lng: 77.2090
x-imei: 356789123456789
x-mod: Samsung-S23
x-brd: Samsung
x-appv: 1.0.0
x-profileid: P12345
```

### Geo-Fence Calculation

| Parameter | Source |
| --- | --- |
| Center Lat/Lng | From login response: [`data.center.lat`](http://data.center.lat), [`data.center](http://data.center).lng` |
| Fence Radius | From login response: `data.exam.fenceRadius` |
| Algorithm | Haversine formula |
| Behavior | WARN only — show indicator, allow capture |

### Submission Structure

```json
{
  "taskId": "1b5468f8-1329-445d-9aff-33d102209c65",
  "filename": "photo.png",
  "url": "s3://...",
  "message": "Observation text",
  "lat": 28.6139,
  "lng": 77.209,
  "fenceStatus": "INSIDE",
  "distFromCenter": 120,
  "location": "ABC Examination Center",
  "submittedAt": "2025-12-22T10:30:00Z"
}
```

### Multiple Images

- Each image is stored as a **separate submission** in backend
- Append mode — keep all images, show history
- Timestamps in UTC from device local time

---

## Screen 10: Profile / Settings {#screen-10}

### Behavior

| Scenario | Action |
| --- | --- |
| **Online** | Show profile, sync status, logout |
| **Offline** | ✅ Show cached profile, warn if unsynced data |

<aside>
⚠️

**BUG FIXES REQUIRED**:

1. Sync status indicator must show GREEN if synced, not "Sync required"
2. Logout button must work correctly
</aside>

### UI Elements

- **Operator photo** (from selfie)
- **Name, Mobile** display
- **Exam/Center info**
- **Sync status** (X tasks pending) — accurate count
- **Sync Now button**
- **Training link**
- **Escalation contacts** (from login: `center.spoc1*`, `center.spoc2*`)
- **Logout button**

### Logout Behavior

- If unsynced data exists → Show warning, allow logout, preserve data locally
- Clear JWT token on logout

---

## Data Sync Architecture {#data-sync}

### Sync Principles

| Principle | Implementation |
| --- | --- |
| **Auto-Sync** | When internet becomes available, sync immediately |
| **Offline-First** | All captures saved locally first, then synced |
| **Data Isolation** | Each task's submissions are completely independent |
| **Profile per Shift** | Profile created/linked per shift |

### Sync Queue

1. **Profile Sync** (if created offline)
    - Endpoint: `POST /api/profiles`
    - Profile ID: `Mobile + Aadhaar + Timestamp`
2. **Task Submissions Sync**
    - Endpoint: Task update API
    - Each image = separate submission
    - Include: lat, lng, fenceStatus, distFromCenter, submittedAt (UTC)

### Events to Send

| Event | When |
| --- | --- |
| `TASK_DOWNLOADED` | After tasks are downloaded post-confirmation |

---

## Known Bugs & Required Fixes {#bugs}

### 🔴 Critical Bugs

| # | Bug | Screen | Fix Required |
| --- | --- | --- | --- |
| 1 | Camera doesn't open / locks out user on selfie capture | Selfie Capture | Open camera smoothly in one attempt, never lock out |
| 2 | Profile submit failing with random error popups | Profile Creation | Debug API integration, show meaningful errors |
| 3 | Post login jumps directly to shift selection, skipping profile/training | Flow | Follow correct flow: Confirmation → Shift → Profile (if needed) → Training |
| 4 | All tasks showing unsynced even when synced | Submitted Tab | Show accurate sync status per task |
| 5 | Task data cross-contamination | Task Detail | Isolate each task's submissions completely |
| 6 | Logout not working | Profile | Fix logout functionality |

### 🟡 Medium Bugs

| # | Bug | Screen | Fix Required |
| --- | --- | --- | --- |
| 7 | Exam code/username not auto-lowercase | Login | Auto-convert to lowercase |
| 8 | No TASK_DOWNLOADED event sent | Post Download | Send event after task download |
| 9 | Shift tab not adjusting to active/non-empty | Shift Selection | Auto-navigate to correct tab |
| 10 | Seconds shown in shift timings | Shift Selection | Show HH:mm only |
| 11 | Age/Mobile/Aadhaar validations missing | Profile Creation | Add validations, disable Continue until valid |
| 12 | Retake selfie not working | Selfie Capture | Fix retake functionality |
| 13 | Training shows Duration/Priority when not in API | Training | Show simple link only |
| 14 | No training skip option | Training | Add Skip button |
| 15 | INSIDE/OUTSIDE not shown during photo capture | Task Capture | Show indicator |
| 16 | Image count limits ignored | Task Capture | Enforce exact count |
| 17 | Can't view full submission image | Task Detail | Enable full image view |
| 18 | Sync status wrong in Profile section | Profile | Show accurate status |
| 19 | Random message populated in wrong task | Task Detail | Isolate observations per task |

### 🟢 Low Priority

| # | Bug | Screen | Fix Required |
| --- | --- | --- | --- |
| 20 | Internet available but showing unsynced | Submitted Tab | Auto-sync when online |
| 21 | Manual sync shows all synced but UI doesn't update | Submitted Tab | Refresh UI after sync |

---

## API Reference {#api-reference}

### Authentication

| Endpoint | Method | Auth | Description |
| --- | --- | --- | --- |
| `/api/auth/op-login` | POST | None | Operator login |

### Mobile Verification

| Endpoint | Method | Auth | Description |
| --- | --- | --- | --- |
| `/api/mobile-verifications` | POST | Bearer | Initiate OTP |
| `/api/mobile-verifications/{id}/verify` | POST | Bearer | Verify OTP |
| `/api/mobile-verifications/{id}/resend` | POST | Bearer | Resend OTP |

### Profile

| Endpoint | Method | Auth | Description |
| --- | --- | --- | --- |
| `/api/profiles` | POST | Bearer | Create profile (multipart) |

### Tasks

| Endpoint | Method | Auth | Description |
| --- | --- | --- | --- |
| `/api/tasks/operator-tasks` | GET | Bearer | Get all tasks |
| `/api/tasks/operator-tasks?shiftId={id}` | GET | Bearer | Get tasks for shift |

### Common

| Endpoint | Method | Auth | Description |
| --- | --- | --- | --- |
| `/api/common/place-name` | GET | Bearer | Get place name (online only) |

---

## Document History

| Version | Date | Author | Changes |
| --- | --- | --- | --- |
| 1.0 | 6 Jan 2026 | Consolidated | Initial consolidated version from API Questionnaire, Braj's bug report, and Postman collection |