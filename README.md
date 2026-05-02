# Shramik App

Shramik is a Flutter-based Android service marketplace for connecting customers, workers, approvers, and the platform admin in a single workflow. The app is designed around local service discovery using pincode, worker verification, job posting, payment proof submission, commission management, and complaint handling.

## Project Context

- Project type: B.Tech CSE 6th Semester Minor Project
- Target platform: Android
- Frontend: Flutter
- Backend: Firebase Auth, Cloud Firestore, Firebase Storage
- Focus area: Local labour/service ecosystem digitization for unorganised workers

## Core Roles

- Customer
  - browse nearby verified workers and hardware stores
  - post jobs
  - track job progress
  - pay workers using UPI flow
  - upload payment proof and feedback
- Worker
  - register with trade, UPI ID, photo, and ID proof
  - view and accept nearby jobs
  - update job status
  - track earnings and commission due
  - submit commission payment proof
- Approver
  - act as trusted local hardware store
  - verify local workers by pincode
  - maintain preferred listing plan
  - upload store bill proof when materials are sold
- Admin
  - permanent controlled account
  - moderate workers
  - review complaints
  - verify commission submissions

## Key Features

- role-based login and signup
- customer, worker, approver, and admin dashboards
- bilingual support: English and Hindi
- pincode-based service discovery
- worker verification workflow
- job posting and status timeline
- manual UPI payment flow with screenshot and transaction ID
- complaint generation through WhatsApp
- monthly worker commission tracking
- Firebase-backed realtime persistence for users, jobs, complaints, and uploads

## Business Logic

- worker commission = minimum of:
  - 5% of job amount
  - Rs. 50
- approver basic listing: free
- approver preferred listing:
  - Rs. 199 monthly
  - Rs. 1800 yearly
- approver earnings are tracked only when hardware/parts sales are explicitly recorded, not on simple job completion

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Provider
- Shared Preferences
- URL Launcher
- File Picker
- Google Fonts
- Flutter SVG

## Permanent Admin Login

- Email: `admin@shramik.com`
- Password: configured privately in Firebase and not published in this repository

## Project Structure

```text
lib/
  main.dart                UI, navigation, dashboards, flows
  app_state.dart           State management, Firebase integration, business logic
  models.dart              Domain models and serialization
  firebase_options.dart    Firebase platform configuration

assets/logo/
  shramik_mark.svg         App logo

docs/
  project-report.md        Full report-ready content
  viva-guide.md            Viva explanation and implementation summary
```

## Setup

1. Install Flutter and Android Studio
2. Connect an Android device or emulator
3. Add your own Firebase Android config and update `lib/firebase_options.dart`
4. Run:

```bash
flutter pub get
flutter run
```

To build APK:

```bash
flutter build apk --release
```

## Quality Checks

```bash
flutter analyze
flutter test
```

## Notes

- Complaint WhatsApp redirect number: `+917051135222`
- Admin commission UPI ID: `glasgotra578-2@okicici`
- This public repository is sanitized. Add your own Firebase project config before building the live backend version.

## Documentation

- Detailed report content: `docs/project-report.md`
- Viva explanation and implementation summary: `docs/viva-guide.md`
