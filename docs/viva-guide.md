# Shramik Viva Guide

## 1. One-Line Introduction

Shramik is a Flutter and Firebase based Android application that connects customers with nearby verified workers and trusted hardware store approvers using pincode-based local discovery.

## 2. Why This Project Was Made

This project was made to solve a real local problem:

- customers do not easily find verified local workers
- workers do not get regular local job visibility
- there is no trust-driven digital record of jobs, payments, and complaints
- hardware store owners can also become useful ecosystem participants

## 3. Main Innovation

The main innovation in the project is the introduction of the Approver role. Instead of only customer and worker, the system also includes a local hardware shop owner who helps in:

- worker verification
- local trust building
- materials supply chain integration
- preferred store business model

## 4. Full Role Explanation

### Customer

- views workers and stores by pincode
- posts job request
- tracks status
- pays worker using UPI
- uploads payment proof
- gives feedback and raises complaint

### Worker

- creates profile with identity proof and UPI ID
- gets linked with approver using pincode
- accepts jobs
- updates progress
- tracks earnings and commission
- pays commission monthly

### Approver

- verifies workers locally
- acts as trusted hardware store
- uploads bill proof when parts are sold
- can buy preferred listing plan

### Admin

- permanent system owner account
- verifies worker and commission records
- views complaints
- moderates platform

## 5. How We Built It

### Step 1: Project Initialization

We created a new Flutter Android project using `flutter create` and replaced the default counter app with a full custom role-based application.

### Step 2: UI Design

We designed:

- splash/loading screen
- app branding and custom logo
- login/signup flows
- role-based dashboards
- dark/light theme support from side menu
- cards, metrics, status chips, and timeline views

### Step 3: Domain Modeling

We created model classes to represent:

- users
- jobs
- complaints
- commission submissions

This made the code clean and easier to serialize into Firestore.

### Step 4: State Management

We used Provider and created a central `AppState` class for:

- user login/logout
- language control
- posting jobs
- accepting jobs
- updating job progress
- payment proof submission
- complaint creation
- commission logic

### Step 5: Firebase Integration

We integrated:

- Firebase Auth for email/password login
- Firestore for structured data
- Firebase Storage for files

We created a Firebase project, registered the Android app, downloaded `google-services.json`, added Firebase Gradle setup, and connected Flutter using `firebase_options.dart`.

### Step 6: Role-Based Logic

We built separate dashboards for:

- customer
- worker
- approver
- admin

Each dashboard only shows relevant modules and actions.

### Step 7: Business Rules

We implemented:

- worker earnings update after job completion and payment proof
- worker commission calculation
- admin commission verification flow
- no automatic approver earnings on simple job completion
- approver earnings only from explicit material/parts sale tracking
- dark/light theme toggle with local persistence
- only active approvers/workers shown in discovery lists

### Step 8: Complaint Flow

We created a structured WhatsApp complaint mechanism where the app generates the formatted complaint text and redirects the user to the support number. We also fixed the complaint flow so every new complaint opens WhatsApp with its own fresh message instead of reusing an old saved complaint.

### Step 9: Testing

We used:

- `flutter analyze`
- `flutter test`
- Android phone installation testing
- Firebase API checks for Auth, Firestore, and Storage

## 6. Important Implementation Files

### `lib/main.dart`

Contains:

- UI screens
- dashboards
- forms
- bottom navigation
- complaint and payment interaction flow

### `lib/app_state.dart`

Contains:

- app business logic
- Firebase integration
- authentication methods
- Firestore reads/writes
- Storage upload logic

### `lib/models.dart`

Contains all domain models and serialization logic.

## 7. Why We Used Pincode

Pincode acts as a simple locality-level unique identifier for:

- worker discovery
- customer-job locality matching
- approver linkage

It is much easier and more practical for a minor project than full GIS-based location mapping.

## 8. Why We Used Manual UPI Instead of Payment Gateway

We used manual UPI flow because:

- it is practical for local users
- it avoids complex payment gateway onboarding
- it is suitable for academic demonstration
- proof-based submission still gives transaction transparency

## 9. Why Firebase Was Chosen

Firebase was chosen because it gives fast mobile-backend integration for:

- authentication
- realtime storage
- file uploads
- easy testing
- no custom server setup required

## 10. Permanent Admin Account

Admin account was made permanent and removed from signup because in a real system admin should be controlled and not publicly self-created.

- email: `admin@shramik.com`
- password: kept private in Firebase configuration and not published in the public repository

## 11. Likely Viva Questions and Answers

### Q1. Why did you choose Flutter?

Because Flutter provides fast UI development, smooth performance, single codebase, and modern mobile design support.

### Q2. Why did you choose Firebase?

Because Firebase provides Auth, Firestore, and Storage in one platform and is ideal for mobile prototypes and production-style student projects.

### Q3. What is the role of Approver?

Approver is a local hardware shop owner who verifies workers by pincode and acts as a trusted store for material supply.

### Q4. How is worker commission calculated?

Commission is the lower of 5% of job amount or Rs. 50.

### Q5. Why did you not use direct GPS live tracking?

For the current scope, a status timeline is simpler, more stable, and enough for a minor project. GPS tracking can be a future enhancement.

### Q6. How are complaints managed?

The app stores complaint details in Firestore and also redirects the user to WhatsApp with a structured complaint message for direct contact.

### Q7. How do you ensure shop earning is correct?

We corrected the logic so shop/approver income is not added on normal service completion. It should only be recorded when actual material sale is entered.

### Q8. What is the role of Firebase Storage?

It stores uploaded files like worker photo, Aadhaar PDF, payment screenshot, and bill proof.

### Q9. How did you handle deleted approvers still showing in customer dashboard?

We added an `isActive` profile flag and filtered discovery lists to show only active approvers and workers. If a backend login account is missing but the Firestore profile still exists, the app deactivates that stale profile and hides it from customer-facing lists.

## 12. Final Summary for Viva

If asked to summarize the complete project in 1-2 minutes, you can say:

Shramik is a Flutter Android application built to digitize local service hiring for customers and unorganised workers. The system uses pincode-based matching so customers can find nearby verified workers and hardware stores. The app has four roles: customer, worker, approver, and admin. Workers upload photo, ID proof, and UPI details. Customers can post jobs, track job status, pay using UPI, and upload payment proof. Approvers verify workers and participate as hardware suppliers. Admin manages verification, complaints, and commission proof approvals. The app is integrated with Firebase Auth, Firestore, and Firebase Storage for backend support, realtime data, and file uploads. The main business logic includes worker commission calculation, role-based dashboards, verification flow, and structured WhatsApp complaint redirection.
