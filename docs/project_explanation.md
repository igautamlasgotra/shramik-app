# Project Explanation

## 1. What This File Is For

This file is for your own understanding of the project. You can use it for:

- viva preparation
- project report understanding
- code explanation to professor
- LinkedIn project section
- resume bullet points

This document explains:

- what we planned
- what we built
- how each part was implemented
- where the logic exists in code
- what files to show in viva

## 2. Project Idea in Simple Words

Shramik is a local service marketplace app.

It connects 4 roles:

- Customer
- Worker
- Approver
- Admin

### What each role does

- Customer posts jobs and finds nearby workers and hardware stores.
- Worker creates a profile, accepts jobs, completes work, and receives payment.
- Approver is a local hardware store owner who verifies workers and can supply material/parts.
- Admin controls the full system, handles moderation, complaints, and commission verification.

## 3. How We Planned the App

The project was planned in these major stages:

### Stage 1: Identify the real-world problem

We first understood the actual local problem:

- customers do not easily find trusted workers
- workers do not get regular local digital visibility
- there is no structured worker verification model
- complaint and payment proof tracking is missing
- hardware stores are disconnected from service flow

### Stage 2: Define the main roles

Instead of making only a customer-worker app, we made a 4-role system:

- customer
- worker
- approver
- admin

This made the project stronger and more original.

### Stage 3: Finalize the technical stack

We selected:

- Flutter for Android app development
- Firebase Auth for login
- Firestore for backend data
- Firebase Storage for files
- Provider for app state management

### Stage 4: Define business rules

We finalized important rules:

- pincode-based locality mapping
- worker commission = 5% or Rs. 50 whichever is lower
- approver is verified hardware store role
- job payment is proof-based UPI flow
- complaints redirect to WhatsApp with structured message

## 4. What We Actually Built

We built a complete Flutter Android application with:

- custom UI and app branding
- role-based login and signup
- dark/light mode toggle
- customer dashboard
- worker dashboard
- approver dashboard
- admin dashboard
- job posting and tracking flow
- worker verification flow
- complaint flow
- commission flow
- Firebase backend connection
- APK build and Android device installation

## 5. Main Code Files and Their Purpose

These are the most important files in the project.

### `lib/main.dart`

This file contains most of the UI and screens.

It includes:

- app theme and branding
- login and signup screen
- role-based dashboard shell
- customer, worker, approver, admin dashboard widgets
- bottom sheets for posting jobs, making payment, complaint, bill upload, commission payment
- WhatsApp and UPI redirection helpers

### `lib/app_state.dart`

This file is the brain of the app.

It contains:

- login and signup logic
- Firebase initialization
- Firestore sync logic
- job posting logic
- job acceptance logic
- commission calculation logic
- complaint saving logic
- theme persistence logic
- inactive profile handling logic
- admin verification logic
- file upload to Firebase Storage

### `lib/models.dart`

This file contains app data models.

It defines:

- roles
- job status enums
- user model
- job model
- complaint model
- commission submission model

### `lib/firebase_options.dart`

This is the Firebase configuration file used by Flutter app initialization.

Note: in public repo this file is sanitized.

### `android/app/google-services.json`

This is the Android Firebase config file.

Note: this is intentionally not present in the public repo because it contains project-specific config.

## 6. Exact Feature-to-Code Mapping

This section is important for viva.

## 6.1 Authentication Screen

### Where in code

- `lib/main.dart:136` -> `class AuthScreen`

### What it does

- shows login/signup UI
- role selection for signup
- worker-specific fields
- approver-specific fields
- language toggle
- demo login chips in local mode

### Important internal methods

- `lib/main.dart:401` -> `_buildLogin()`
- `lib/main.dart:435` -> `_buildSignUp()`
- `lib/main.dart` -> `_submitLogin()`
- `lib/main.dart` -> `_submitSignUp()`

### What to say in viva

The login and signup user interface is built in `AuthScreen` in `main.dart`. The actual backend login and signup logic is not directly written inside the widget; instead it calls `AppState`, which keeps UI and business logic separate.

## 6.2 Dashboard Routing by Role

### Where in code

- `lib/main.dart:673` -> `class DashboardShell`
- `lib/main.dart` -> `_buildPagesForRole(...)`

### What it does

- after login, app checks role
- based on role, it shows different pages in bottom navigation

### What to say in viva

The app uses role-based dashboard composition. The `DashboardShell` dynamically loads different page sets depending on whether the current user is a customer, worker, approver, or admin.

## 6.2A Theme Toggle

### Where in code

- `lib/main.dart` -> `buildShramikTheme(...)`
- `lib/main.dart` -> `_AppDrawer`
- `lib/app_state.dart` -> `setDarkMode(...)`

### What it does

- gives dark/light mode switch in side drawer
- stores selected theme locally using SharedPreferences
- restores theme after app restart

### What to say in viva

The app uses a single source of truth for theme state in `AppState`. `MaterialApp` reads that state and switches between light and dark theme dynamically.

## 6.3 Customer Dashboard

### Where in code

- `lib/main.dart:812` -> `class CustomerOverviewPage`
- `lib/main.dart` -> `class CustomerJobsPage`

### What it does

- shows nearby hardware stores
- shows nearby workers
- shows post job button
- shows live request tracking
- shows customer job list

### Related helper

- `lib/main.dart:2712` -> `showPostJobSheet(...)`
- `lib/main.dart:2850` -> `showCustomerPaymentSheet(...)`

### Backend logic used

- `lib/app_state.dart:328` -> `postJob(...)`
- `lib/app_state.dart:482` -> `submitCustomerPayment(...)`

## 6.4 Worker Dashboard

### Where in code

- `lib/main.dart:1015` -> `class WorkerOverviewPage`
- `lib/main.dart` -> `class WorkerJobsPage`

### What it does

- shows linked hardware store
- shows available jobs by pincode and category
- lets worker accept jobs
- lets worker start or complete jobs
- shows earnings and commission due
- lets worker upload commission proof

### Related helper

- `lib/main.dart:2994` -> `showCommissionPaymentSheet(...)`

### Backend logic used

- `lib/app_state.dart:367` -> `acceptJob(...)`
- `lib/app_state.dart:398` -> `updateJobStatus(...)`
- `lib/app_state.dart:550` -> `submitCommissionPayment(...)`

## 6.5 Approver Dashboard

### Where in code

- `lib/main.dart:1239` -> `class ApproverOverviewPage`
- `lib/main.dart` -> `class ApproverApprovalsPage`

### What it does

- shows linked workers
- shows preferred listing status
- lets approver approve workers
- lets approver upload hardware bill proof

### Backend logic used

- `lib/app_state.dart:589` -> `approveWorker(...)`

### Important business correction

Approver earnings are not increased on normal service job completion anymore. That logic was fixed in `submitCustomerPayment(...)` in `lib/app_state.dart` by removing shop earning increase on plain job closure.

## 6.6 Admin Dashboard

### Where in code

- `lib/main.dart:1440` -> `class AdminOverviewPage`
- `lib/main.dart` -> `class AdminModerationPage`
- `lib/main.dart` -> `class AdminComplaintsPage`

### What it does

- shows platform overview
- shows worker moderation controls
- shows commission proof approvals
- shows complaint log
- shows private worker notes on approvers

### Backend logic used

- `lib/app_state.dart:589` -> `approveWorker(...)`
- `lib/app_state.dart:631` -> `approveCommissionSubmission(...)`
- `lib/app_state.dart:717` -> `addComplaint(...)`

## 6.7 WhatsApp Complaint Flow

### Where in code

- `lib/main.dart:3273` -> `showComplaintSheet(...)`
- `lib/main.dart:3471` -> `openWhatsAppComplaint(...)`
- `lib/app_state.dart:717` -> `addComplaint(...)`

### How it works

1. user opens complaint sheet
2. selects target person/role
3. enters complaint type and details
4. app builds structured complaint message
5. app stores complaint in Firestore
6. app redirects to WhatsApp number `+917051135222`

### What to say in viva

Complaint handling is hybrid. We save the complaint record in Firestore for platform tracking and also redirect the user to WhatsApp with a prefilled structured message for faster real-world communication.

### Important bug fix

Earlier the app was opening WhatsApp using the first saved complaint from the complaints list, which sometimes caused an old complaint message to be reused. This was fixed by making `addComplaint(...)` return the newly created complaint object and sending that exact message immediately.

## 6.8 UPI Payment Flow

### Where in code

- `lib/main.dart:3455` -> `openUpiPayment(...)`
- `lib/main.dart:2850` -> `showCustomerPaymentSheet(...)`
- `lib/main.dart:2994` -> `showCommissionPaymentSheet(...)`

### How it works

The app does not directly process money. Instead:

1. it opens external UPI app using UPI URI
2. user makes payment manually
3. user returns and uploads screenshot + transaction ID
4. app stores proof in Firebase

### Why this approach was used

- easier for a college project
- practical for local users
- avoids payment gateway complexity

## 6.9 Job Lifecycle Logic

### Job states defined in

- `lib/models.dart:7` -> `enum JobStatus`

States:

- open
- accepted
- inProgress
- paymentPending
- closed

### Job model defined in

- `lib/models.dart:192` -> `class JobRequest`

### Main job methods

- `lib/app_state.dart:328` -> `postJob(...)`
- `lib/app_state.dart:367` -> `acceptJob(...)`
- `lib/app_state.dart:398` -> `updateJobStatus(...)`
- `lib/app_state.dart:482` -> `submitCustomerPayment(...)`

### What to say in viva

The entire service workflow was modelled as a state machine using `JobStatus`. That makes progress tracking simple, readable, and scalable.

## 6.10A Inactive Approver Handling

### Where in code

- `lib/models.dart` -> `AppUser.isActive`
- `lib/app_state.dart` -> discovery filters like `nearbyHardwareStoresFor(...)`
- `lib/app_state.dart` -> `_deactivateProfileIfAuthMissing(...)`

### Why this was added

If an approver account was deleted from Firebase Auth but the Firestore profile still existed, customers could still see the stale shop profile.

### How it was fixed

1. added `isActive` field in user model
2. customer and complaint target lists now only show active users
3. if login fails because backend auth account is missing, the profile is checked and deactivated

### What to say in viva

This fix handles backend consistency between Firebase Auth and Firestore profile data, which is a practical production-style concern.

### Additional login recovery fix

If a real Firebase Auth account successfully logs in but the profile document was previously inactive, the app now automatically reactivates that profile. This solved the problem where approvers could log in using a valid email/password but still see a backend profile missing error.

## 6.10 Worker Commission Logic

### Where in code

- `lib/app_state.dart:775` -> `calculateCommission(...)`

### Formula

- minimum of 5% of job amount and Rs. 50

### When it is applied

When customer submits payment proof and the job is closed, worker total earned and commission due are updated.

### What to say in viva

We separated commission calculation into its own function so that the business rule stays centralized and easy to change later.

## 7. How Firebase Auth Was Implemented

### Firebase initialization

- `lib/app_state.dart:850` -> `_initializeFirebaseMode()`

### Login logic

- `lib/app_state.dart:117` -> `login(...)`

### Signup logic

- `lib/app_state.dart:154` -> `signUp(...)`
- `lib/app_state.dart:791` -> `_signUpWithFirebase(...)`

### How Auth works technically

1. app starts
2. `AppState.initialize()` runs
3. if Firebase config exists, `_initializeFirebaseMode()` runs
4. `Firebase.initializeApp(...)` is called
5. `FirebaseAuth.instance` is created
6. login/signup calls Firebase email/password methods
7. after successful auth, user profile is read from Firestore
8. role in Firestore decides which dashboard is shown

### Important design choice

Auth identity and Firestore profile are separate.

That means:

- Firebase Auth stores login identity
- Firestore `users` collection stores role, profile, pincode, trade, UPI, verification state, earnings, etc.

This is a standard production-style design.

## 8. How Firestore Was Implemented

### Collections used

- `users`
- `jobs`
- `complaints`
- `commissionSubmissions`

### Firestore stream setup

- inside `lib/app_state.dart` in `_bindFirebaseStreams()`

### What it does

This method sets realtime listeners on collections so the UI updates automatically whenever data changes.

### What to say in viva

We used Firestore snapshots to keep the app reactive. Instead of manually reloading all data after every action, changes automatically refresh the state and UI.

## 9. How Firebase Storage Was Implemented

### Where in code

- `lib/app_state.dart` -> `_uploadFileToStorage(...)`

### What it uploads

- worker photo
- worker ID proof
- customer payment screenshot
- hardware bill proof
- commission payment screenshot

### How it works

1. file is selected by File Picker
2. file path is passed to app state
3. app creates Firebase Storage reference
4. file is uploaded
5. download URL/path is stored back in Firestore

## 10. Data Models in Code

### Role enum

- `lib/models.dart:3` -> `UserRole`

### Job status enum

- `lib/models.dart:7` -> `JobStatus`

### User model

- `lib/models.dart:20` -> `AppUser`

### Job model

- `lib/models.dart:192` -> `JobRequest`

### Complaint model

- `lib/models.dart:353` -> `ComplaintRecord`

### Commission model

- `lib/models.dart:412` -> `CommissionSubmission`

### Signup form model

- `lib/models.dart:534` -> `SignUpData`

### Why models were important

Models made it easy to:

- structure app data
- serialize to Firestore maps
- reconstruct data from Firestore
- keep the project modular

## 11. Why We Removed Admin Signup

Admin should never be a public self-registration role in a serious app.

So we changed the design to:

- remove admin option from signup UI
- create a permanent admin account separately
- keep admin as controlled backend user

This is a better design and more professional in viva discussion.

## 12. Why Approver Income Logic Was Corrected

Earlier, simple worker job completion was also increasing approver income.

That was wrong because approver/shop income should only come from actual hardware sales or material purchase, not from service completion itself.

So we fixed the logic in `submitCustomerPayment(...)` by removing automatic increment of `totalShopEarnings` during plain job closure.

## 13. Which Files to Show If Sir Asks for Code

Show these files in this order.

### File 1: `README.md`

Show this first to explain project purpose, stack, roles, and structure.

### File 2: `lib/models.dart`

Show this second.

Why:

- explains roles
- explains job model
- explains complaint model
- gives professor the project data structure

### File 3: `lib/app_state.dart`

This is the most important file.

Show these functions:

- `login(...)`
- `signUp(...)`
- `_signUpWithFirebase(...)`
- `_initializeFirebaseMode()`
- `postJob(...)`
- `acceptJob(...)`
- `updateJobStatus(...)`
- `submitCustomerPayment(...)`
- `submitCommissionPayment(...)`
- `approveWorker(...)`
- `approveCommissionSubmission(...)`
- `addComplaint(...)`
- `calculateCommission(...)`

This file proves the backend and business logic are real.

### File 4: `lib/main.dart`

Show dashboard classes and bottom sheet helpers.

Good sections to show:

- `AuthScreen`
- `DashboardShell`
- `CustomerOverviewPage`
- `WorkerOverviewPage`
- `ApproverOverviewPage`
- `AdminOverviewPage`
- `showPostJobSheet(...)`
- `showCustomerPaymentSheet(...)`
- `showComplaintSheet(...)`
- `openUpiPayment(...)`
- `openWhatsAppComplaint(...)`

### File 5: `firebase.json`, `firestore.rules`, `storage.rules`

Show this if sir asks backend/security side.

### File 6: `docs/project-report.md`

Show this if sir wants structured documentation.

## 14. Best Code Demo Order During Viva

If you are screen-sharing code, show in this order:

1. `README.md`
2. `lib/models.dart`
3. `lib/app_state.dart`
4. `lib/main.dart`
5. Firebase files and docs

That gives a clean explanation flow:

- what project is
- how data is structured
- how backend logic works
- how UI works
- how configuration works

## 15. LinkedIn Project Description

Use this in LinkedIn Projects section.

### LinkedIn Project Section Version

Shramik is a Flutter and Firebase based Android application developed as a B.Tech CSE minor project to connect customers with nearby verified workers using pincode-based local discovery. The application supports four roles: customer, worker, approver, and admin. It includes worker verification, job posting and tracking, UPI-based payment proof submission, complaint redirection through WhatsApp, monthly commission management, and Firebase-backed data storage using Authentication, Firestore, and Storage. The project was designed for the unorganised local labour ecosystem and focuses on trust, locality mapping, and workflow transparency.

### Short LinkedIn Caption Version

Built `Shramik`, a Flutter + Firebase Android app for local service hiring, worker verification, job tracking, payment proof flow, and hardware-store based approval workflow. Developed as a B.Tech CSE minor project with role-based dashboards for customer, worker, approver, and admin.

### LinkedIn Post Version

Excited to share my minor project **Shramik**, a Flutter and Firebase based Android application built to digitally connect customers, local workers, hardware store approvers, and the platform admin in a single workflow.

The idea behind Shramik is to support the local unorganised service ecosystem by solving real problems like worker discovery, verification, job tracking, payment proof management, and complaint handling.

Key highlights:

- Flutter-based Android mobile application
- Firebase Authentication, Firestore, and Storage integration
- Role-based dashboards for Customer, Worker, Approver, and Admin
- Pincode-based local service discovery
- Worker verification using local hardware store approvers
- UPI-based payment proof and commission workflow
- WhatsApp-based complaint escalation flow

This project was developed as part of my **B.Tech CSE 6th Semester Minor Project**.

GitHub Repository: `https://github.com/igautamlasgotra/shramik-app`

I would be happy to receive feedback and suggestions.

## 16. Resume Bullet Points

Use any 3-5 of these depending on your resume length.

- Developed `Shramik`, a Flutter-based Android marketplace app connecting customers, workers, approvers, and admin through role-based dashboards and pincode-based local discovery.
- Integrated Firebase Authentication, Cloud Firestore, and Firebase Storage to implement secure login, realtime backend persistence, and document upload workflows.
- Implemented end-to-end job lifecycle features including job posting, worker acceptance, progress tracking, UPI payment proof submission, and customer feedback.
- Designed and implemented business logic for worker commission calculation, admin moderation, worker verification, and approver listing workflows.
- Built structured complaint escalation through WhatsApp redirection with backend complaint logging for traceability.
- Created a modular Flutter architecture using Provider-based state management, reusable domain models, and Firebase-backed reactive data flows.

## 17. What to Say If Sir Asks “How Did You Make This?”

You can answer like this:

First I finalized the problem statement and the four user roles. Then I designed the mobile app architecture in Flutter. I created data models for users, jobs, complaints, and commission submissions. After that I built the UI in `main.dart`, including authentication, role-based dashboards, and all interaction flows. Then I implemented business logic and backend operations in `app_state.dart` using Provider. For backend, I integrated Firebase Authentication for login, Firestore for realtime structured data, and Firebase Storage for uploaded documents like ID proofs and screenshots. I tested the app using Flutter analysis, widget tests, Firebase checks, and final APK installation on a physical Android phone.

## 18. What to Say If Sir Asks “Where Is This Implemented in Code?”

You can say:

- data structure is in `lib/models.dart`
- UI and dashboards are in `lib/main.dart`
- business logic and Firebase integration are in `lib/app_state.dart`
- Firebase platform config is in `lib/firebase_options.dart`
- project report and viva material are in `docs/`
