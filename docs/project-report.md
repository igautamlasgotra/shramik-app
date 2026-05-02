# Shramik Project Report

## Title

Shramik: A Flutter and Firebase Based Role-Oriented Local Service Marketplace for Customers, Workers, and Hardware Approvers

## Student Details

- Student Name: Gautam Lasgotra
- Programme: B.Tech CSE
- Semester: 6th Semester
- University: Shri Mata Vaishno Devi University, Katra
- Project Type: Minor Project

## 1. Abstract

Shramik is an Android mobile application developed to digitally connect customers, local workers, hardware store approvers, and a platform administrator. The main objective of the project is to reduce the communication gap between customers who need local skilled services and workers who need local job opportunities. The application is built using Flutter for cross-platform mobile development and Firebase as the backend platform for authentication, realtime data storage, and document uploads.

The app introduces a role-based ecosystem. Customers can post service requests and discover nearby workers and hardware stores using pincode-based filtering. Workers can create profiles, upload identity documents, accept jobs, and manage earnings and commission payments. Approvers, who are typically local hardware store owners, can verify workers in their locality and act as trusted hardware vendors. The admin manages verification, complaints, and commission approvals.

The application also supports job lifecycle tracking, UPI-based manual payment proof submission, WhatsApp-based complaint initiation, dark/light mode support, worker verification, hardware listing monetization, and Firebase-powered backend storage. This project demonstrates the use of modern mobile application architecture to solve a practical real-world problem for the unorganised workforce sector.

## 2. Introduction

In many Indian towns and semi-urban areas, customers still depend on informal phone calls, word-of-mouth communication, and personal contacts to find electricians, plumbers, carpenters, painters, and other daily service workers. At the same time, many skilled workers struggle to find consistent job opportunities. There is also a trust problem because customers are often unsure about worker authenticity, pricing transparency, and accountability.

Shramik was designed to solve this issue with a structured mobile platform that allows verified service discovery, job posting, progress tracking, payment proof submission, and complaint escalation. The system adds a special business role called Approver, usually a local hardware shop owner, who helps in worker verification and also becomes part of the local service supply chain for spare parts and materials.

## 3. Problem Statement

The traditional local labour ecosystem suffers from the following problems:

- customers face difficulty in finding verified and nearby workers
- workers face irregular work opportunities and poor digital visibility
- there is no structured method to verify workers in local areas
- there is no transparent digital record of jobs, complaints, and payments
- there is no integrated business model connecting workers, customers, and hardware suppliers
- complaint handling is mostly informal and undocumented

Therefore, a role-based mobile platform is needed to streamline discovery, trust, verification, and accountability in local service hiring.

## 4. Objectives

The main objectives of the project are:

- to build a mobile application for local job-service discovery
- to provide separate dashboards for customer, worker, approver, and admin
- to implement worker verification using document upload and approver-based trust
- to use pincode as the locality mapping identifier
- to store app data in a realtime backend using Firebase
- to manage job status updates and proof-based payment flow
- to support business monetization through worker commission and approver listing plans
- to create a complaint mechanism through structured WhatsApp redirection

## 5. Scope of the Project

The project scope includes Android mobile application development, Firebase backend integration, worker and shop onboarding, job management, complaint initiation, payment proof submission, and admin-side moderation.

The current version focuses on:

- Android app only
- manual UPI payment flow
- timeline-based job tracking instead of GPS live tracking
- Firebase backend integration
- demo-friendly but functional admin moderation

## 6. Proposed System

The proposed system is a role-based service marketplace mobile app with the following actors:

- Customer
- Worker
- Approver
- Admin

The system flow is as follows:

1. users register with their role
2. customer posts a job request
3. nearby worker views and accepts the job
4. worker performs the job and updates status
5. customer pays through UPI and uploads proof
6. worker earning and commission get updated
7. admin verifies commission submissions
8. approver verifies workers and participates in materials supply

## 7. System Requirements

### Hardware Requirements

- Laptop or PC with minimum 8 GB RAM
- Android smartphone for testing
- Stable internet connection

### Software Requirements

- Windows OS
- Flutter SDK
- Android Studio
- Git
- Firebase project
- Dart SDK

## 8. Tools and Technologies Used

### 8.1 Flutter

Flutter was used to build the mobile frontend because it allows fast UI development, modern widget-based design, and smooth performance.

### 8.2 Dart

Dart is the programming language used by Flutter for building the entire application logic.

### 8.3 Firebase Authentication

Firebase Auth was used to manage secure role-based email/password login for app users.

### 8.4 Cloud Firestore

Cloud Firestore was used to store:

- user profiles
- jobs
- complaints
- commission submissions
- role-based metadata

### 8.5 Firebase Storage

Firebase Storage was used to store:

- worker photos
- worker ID proof PDFs
- customer payment screenshots
- hardware bill images/PDFs
- commission proof screenshots

### 8.6 Provider

Provider was used for app state management and reactive UI updates.

### 8.7 Shared Preferences

Shared Preferences was used for local preference persistence such as app language and fallback/local state handling during development.

## 9. System Architecture

The Shramik app follows a frontend-backend architecture:

- Presentation Layer: Flutter widgets and dashboards
- State Layer: `AppState` using Provider
- Data Layer: Firebase Auth, Firestore, Storage
- Domain Layer: model classes like `AppUser`, `JobRequest`, `ComplaintRecord`, `CommissionSubmission`

### Data Flow

1. User interacts with UI
2. UI calls `AppState`
3. `AppState` performs validation and business logic
4. Data is saved to Firebase services
5. Firestore streams update UI in realtime

## 10. Roles and Functional Modules

### 10.1 Customer Module

Customer can:

- sign up and log in
- browse nearby workers and hardware stores
- post a job request
- track job status
- complete worker payment using UPI
- upload payment screenshot and transaction ID
- submit feedback
- raise complaints through WhatsApp flow

### 10.2 Worker Module

Worker can:

- sign up with trade details, photo, Aadhaar/ID proof, and UPI ID
- get linked to local approver using pincode
- view jobs matching pincode and category
- accept and update job progress
- view earnings
- view commission due
- pay monthly commission and upload proof
- send private note on hardware store to admin

### 10.3 Approver Module

Approver can:

- register as hardware store owner
- view workers linked by pincode
- approve pending workers
- use preferred listing plan
- upload bill proof for material sales
- track parts-related earnings only

### 10.4 Admin Module

Admin can:

- log in using permanent credentials
- review all users
- approve worker verification
- suspend/reactivate workers
- verify commission proofs
- review complaints
- inspect private worker notes

## 11. Key Business Rules Implemented

### 11.1 Worker Commission Rule

Worker commission is calculated as:

- 5% of job amount, or
- Rs. 50

whichever is lower.

### 11.2 Approver Revenue Rule

Approver income is not generated when a worker simply completes a service job. Approver income is tracked only when a hardware or parts transaction is actually recorded.

### 11.3 Verification Rule

Workers must upload identity proof and can be approved based on local pincode trust flow.

### 11.4 Active Profile Rule

Only active worker and approver profiles are shown in user-facing discovery sections. If a backend account is removed, the profile is marked inactive and hidden from customers.

## 12. Database Design Overview

The main Firestore collections include:

- `users`
- `jobs`
- `complaints`
- `commissionSubmissions`

### Important Fields in `users`

- id
- role
- email
- name
- phone
- address
- pincode
- trade
- upiId
- linkedApproverId
- isActive
- isVerified
- isSuspended
- totalEarned
- commissionDue
- totalShopEarnings

### Important Fields in `jobs`

- customerId
- customerName
- category
- title
- description
- address
- pincode
- budget
- status
- workerId
- workerUpiId
- paymentTransactionId
- paymentScreenshotPath
- storeBillPath
- internalStoreReview

## 13. UI/UX Design Considerations

The UI was intentionally designed to be colourful, modern, and accessible for semi-technical users. Important design choices include:

- role-wise dashboards
- dark/light mode support
- large touch targets
- visually distinct cards
- gradient hero sections
- simple language toggle
- direct actions for payments and complaints
- status chips and timeline tracking

## 14. Implementation Details

### 14.1 Authentication Implementation

Authentication was implemented using Firebase email/password login. Admin signup was removed and a permanent admin account was created separately in Firebase. In the public repository version, sensitive runtime credentials are intentionally sanitized.

### 14.2 State Management Implementation

The `AppState` class was created to manage:

- authentication state
- user session
- Firestore listeners
- job flow updates
- uploads
- commission calculations
- complaint generation

### 14.3 Storage Upload Flow

Whenever a worker or customer uploads a file, the app:

1. picks the file using File Picker
2. uploads it to Firebase Storage
3. stores the returned URL/path in Firestore document fields

### 14.4 Complaint Handling Flow

Complaint creation follows this logic:

1. user selects target role/person
2. user enters complaint category and details
3. app creates a structured complaint string
4. app stores complaint in Firestore
5. app redirects to WhatsApp using configured support number
6. every complaint uses the newly created message instead of cached previous complaint data

## 15. Testing and Validation

The project was validated through:

- Flutter static analysis using `flutter analyze`
- widget testing using `flutter test`
- manual Android device testing
- Firebase Auth signup/login validation
- Firestore document verification
- Firebase Storage upload verification
- complaint message freshness validation
- inactive approver visibility validation after backend account removal

## 16. Results Achieved

The project successfully achieved the following outcomes:

- role-based Android mobile application built in Flutter
- Firebase-backed realtime data storage
- professional login and dashboard flows
- working complaint redirection system
- dark/light theme toggle with saved preference
- correct complaint message generation for every complaint request
- active/inactive profile filtering for backend consistency
- worker earnings and commission calculation
- permanent admin account
- document upload support
- release APK generated and installed on physical Android phone

## 17. Limitations

Current limitations include:

- payment gateway is manual rather than automated
- GPS live worker tracking is not implemented
- security rules are demo-oriented and can be strengthened further
- advanced analytics and search filters can be extended later

## 18. Future Scope

Future improvements may include:

- real-time map tracking
- integrated digital payment gateway
- stronger Firebase rules and role-based access policy
- push notifications
- service rating and recommendation engine
- multilingual expansion
- web admin panel
- invoice generation

## 19. Conclusion

Shramik is a practical and socially relevant mobile application that digitizes the local service hiring process. It connects customers, workers, hardware shops, and administrators in one platform and introduces accountability, verification, and data-backed workflow management. The project demonstrates the effective use of Flutter and Firebase to solve a real-world problem in the unorganised service sector.

This project is technically functional, modular, scalable, and suitable as a B.Tech minor project with real implementation value.

## 20. References

- Flutter Documentation: https://docs.flutter.dev/
- Firebase Documentation: https://firebase.google.com/docs
- Dart Documentation: https://dart.dev/
- Android Developers: https://developer.android.com/
