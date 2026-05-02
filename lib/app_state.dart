import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  AppState();

  static const String _storageKey = 'shramik_snapshot_v1';
  static const String _languageKey = 'shramik_language_v1';
  static const String ownerUpiId = 'glasgotra578-2@okicici';
  static const String supportNumber = '917051135222';
  static const String adminEmail = 'admin@shramik.com';
  static const String adminPassword = 'CHANGE_ME_IN_FIREBASE';
  static const String adminName = 'Shramik Admin';
  static const String adminPhone = '7051135222';
  static const String adminAddress = 'Shramik Control Desk, Jammu';
  static const String adminPincode = '181201';
  static const String _firebasePlaceholder = '__CONFIGURE_ME__';

  bool _isReady = false;
  bool _usesFirebase = false;
  bool _firebaseConfigured = false;
  String? _firebaseError;
  AppLanguage _language = AppLanguage.english;
  AppUser? _currentUser;
  final List<AppUser> _users = <AppUser>[];
  final List<JobRequest> _jobs = <JobRequest>[];
  final List<ComplaintRecord> _complaints = <ComplaintRecord>[];
  final List<CommissionSubmission> _commissionSubmissions =
      <CommissionSubmission>[];

  SharedPreferences? _preferences;
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usersSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _jobsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _complaintsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _commissionSubscription;

  bool get isReady => _isReady;
  bool get isUsingFirebase => _usesFirebase;
  bool get firebaseConfigured => _firebaseConfigured;
  String? get firebaseError => _firebaseError;
  AppLanguage get language => _language;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  List<AppUser> get allUsers => List<AppUser>.unmodifiable(_users);
  List<JobRequest> get allJobs => List<JobRequest>.unmodifiable(_jobs);
  List<ComplaintRecord> get complaints =>
      List<ComplaintRecord>.unmodifiable(_complaints.reversed);
  List<CommissionSubmission> get commissionSubmissions =>
      List<CommissionSubmission>.unmodifiable(_commissionSubmissions.reversed);

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore!.collection('users');

  CollectionReference<Map<String, dynamic>> get _jobsCollection =>
      _firestore!.collection('jobs');

  CollectionReference<Map<String, dynamic>> get _complaintsCollection =>
      _firestore!.collection('complaints');

  CollectionReference<Map<String, dynamic>> get _commissionCollection =>
      _firestore!.collection('commissionSubmissions');

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    _loadLanguagePreference();

    _firebaseConfigured = _isFirebaseConfigured();
    if (_firebaseConfigured) {
      await _initializeFirebaseMode();
    }

    if (!_usesFirebase) {
      await _loadLocalFallback();
    }

    _isReady = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _usersSubscription?.cancel();
    _jobsSubscription?.cancel();
    _complaintsSubscription?.cancel();
    _commissionSubscription?.cancel();
    super.dispose();
  }

  Future<void> updateLanguage(AppLanguage value) async {
    _language = value;
    await _saveLanguagePreference();
    if (!_usesFirebase) {
      await _persistLocalSnapshot();
    }
    notifyListeners();
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_usesFirebase) {
      try {
        await _auth!.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        await _refreshCurrentUserFromAuth();
        if (_currentUser == null) {
          await _auth!.signOut();
          return 'User profile not found in backend';
        }
        notifyListeners();
        return null;
      } on FirebaseAuthException catch (error) {
        return _authErrorMessage(error);
      } catch (_) {
        return 'Unable to log in right now';
      }
    }

    for (final user in _users) {
      if (user.email.trim().toLowerCase() == normalizedEmail &&
          user.password == password) {
        _currentUser = user;
        notifyListeners();
        return null;
      }
    }
    return 'Invalid email or password';
  }

  Future<String?> signUp(SignUpData data) async {
    if (data.role == UserRole.admin) {
      return 'Admin account is managed separately';
    }

    if (_usesFirebase) {
      return _signUpWithFirebase(data);
    }

    final normalizedEmail = data.email.trim().toLowerCase();
    final existingUser = _findUserByEmail(normalizedEmail);
    if (existingUser != null) {
      return 'An account already exists with this email';
    }

    final linkedApprover = _findApproverByPincode(data.pincode);
    final isWorker = data.role == UserRole.worker;
    final isApprover = data.role == UserRole.approver;

    final user = AppUser(
      id: createId('user'),
      role: data.role,
      email: normalizedEmail,
      password: data.password,
      name: data.name.trim(),
      phone: data.phone.trim(),
      address: data.address.trim(),
      pincode: data.pincode.trim(),
      shopName: isApprover ? data.shopName?.trim() : null,
      trade: isWorker ? data.trade?.trim() : null,
      upiId: isWorker ? data.upiId?.trim() : null,
      photoPath: isWorker ? data.photoPath : null,
      idProofPath: isWorker ? data.idProofPath : null,
      linkedApproverId: isWorker ? linkedApprover?.id : null,
      isVerified: data.role == UserRole.customer,
      preferredListing: false,
    );

    _users.add(user);
    if (isApprover) {
      _autoLinkWorkersToApproverLocally(user);
    }

    _currentUser = user;
    await _persistLocalSnapshot();
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    if (_usesFirebase) {
      await _auth!.signOut();
    }
    _currentUser = null;
    notifyListeners();
  }

  List<AppUser> nearbyHardwareStoresFor(AppUser user) {
    final stores = _users.where((item) {
      return item.role == UserRole.approver && item.pincode == user.pincode;
    }).toList();

    stores.sort((first, second) {
      if (first.preferredListing != second.preferredListing) {
        return second.preferredListing ? 1 : -1;
      }
      return (first.shopName ?? first.name).compareTo(
        second.shopName ?? second.name,
      );
    });
    return stores;
  }

  List<AppUser> nearbyWorkersFor(AppUser user) {
    final workers = _users.where((item) {
      return item.role == UserRole.worker &&
          item.pincode == user.pincode &&
          item.isVerified &&
          !item.isSuspended;
    }).toList();
    workers.sort((a, b) => a.name.compareTo(b.name));
    return workers;
  }

  List<JobRequest> jobsForCustomer(String customerId) {
    final jobs = _jobs.where((job) => job.customerId == customerId).toList();
    jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return jobs;
  }

  List<JobRequest> availableJobsForWorker(AppUser worker) {
    final jobs = _jobs.where((job) {
      final matchesTrade =
          worker.trade == null ||
          worker.trade == 'Other' ||
          job.category == worker.trade;
      return job.status == JobStatus.open &&
          job.pincode == worker.pincode &&
          matchesTrade;
    }).toList();
    jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return jobs;
  }

  List<JobRequest> jobsForWorker(String workerId) {
    final jobs = _jobs.where((job) => job.workerId == workerId).toList();
    jobs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return jobs;
  }

  List<AppUser> linkedWorkersForApprover(AppUser approver) {
    final workers = _users.where((user) {
      return user.role == UserRole.worker &&
          user.pincode == approver.pincode &&
          user.linkedApproverId == approver.id;
    }).toList();
    workers.sort((a, b) => a.name.compareTo(b.name));
    return workers;
  }

  List<AppUser> pendingWorkersForApprover(AppUser approver) {
    final workers = _users.where((user) {
      return user.role == UserRole.worker &&
          user.pincode == approver.pincode &&
          !user.isVerified;
    }).toList();
    workers.sort((a, b) => a.name.compareTo(b.name));
    return workers;
  }

  List<JobRequest> jobsForApprover(AppUser approver) {
    final jobs = _jobs.where((job) {
      return job.pincode == approver.pincode &&
          (job.approverId == approver.id ||
              _worker(job.workerId)?.linkedApproverId == approver.id);
    }).toList();
    jobs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return jobs;
  }

  List<AppUser> pendingWorkersForAdmin() {
    final workers = _users.where((user) {
      return user.role == UserRole.worker && !user.isVerified;
    }).toList();
    workers.sort((a, b) => a.name.compareTo(b.name));
    return workers;
  }

  List<AppUser> allWorkers() {
    final workers = _users
        .where((user) => user.role == UserRole.worker)
        .toList();
    workers.sort((a, b) => a.name.compareTo(b.name));
    return workers;
  }

  List<AppUser> allApprovers() {
    final approvers = _users
        .where((user) => user.role == UserRole.approver)
        .toList();
    approvers.sort(
      (a, b) => (a.shopName ?? a.name).compareTo(b.shopName ?? b.name),
    );
    return approvers;
  }

  List<CommissionSubmission> pendingCommissionSubmissions() {
    final submissions = _commissionSubmissions
        .where((item) => item.status == SubmissionStatus.pending)
        .toList();
    submissions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return submissions;
  }

  Future<void> postJob({
    required String title,
    required String category,
    required String description,
    required String address,
    required String pincode,
    required double budget,
  }) async {
    final customer = _currentUser;
    if (customer == null) {
      return;
    }

    final job = JobRequest(
      id: _usesFirebase ? _jobsCollection.doc().id : createId('job'),
      customerId: customer.id,
      customerName: customer.name,
      customerPhone: customer.phone,
      category: category,
      title: title,
      description: description,
      address: address,
      pincode: pincode,
      budget: budget,
      status: JobStatus.open,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_usesFirebase) {
      await _jobsCollection.doc(job.id).set(job.toMap());
      return;
    }

    _jobs.add(job);
    await _persistLocalSnapshot();
    notifyListeners();
  }

  Future<void> acceptJob(String jobId) async {
    final worker = _currentUser;
    if (worker == null) {
      return;
    }
    final index = _jobs.indexWhere((job) => job.id == jobId);
    if (index == -1) {
      return;
    }

    final job = _jobs[index];
    final updatedJob = job.copyWith(
      workerId: worker.id,
      workerName: worker.name,
      workerPhone: worker.phone,
      workerUpiId: worker.upiId,
      approverId: worker.linkedApproverId,
      status: JobStatus.accepted,
      updatedAt: DateTime.now(),
    );

    if (_usesFirebase) {
      await _jobsCollection.doc(jobId).update(updatedJob.toMap());
      return;
    }

    _jobs[index] = updatedJob;
    await _persistLocalSnapshot();
    notifyListeners();
  }

  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    final index = _jobs.indexWhere((job) => job.id == jobId);
    if (index == -1) {
      return;
    }
    final updatedJob = _jobs[index].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    if (_usesFirebase) {
      await _jobsCollection.doc(jobId).update(<String, dynamic>{
        'status': enumName(status),
        'updatedAt': updatedJob.updatedAt.toIso8601String(),
      });
      return;
    }

    _jobs[index] = updatedJob;
    await _persistLocalSnapshot();
    notifyListeners();
  }

  Future<void> submitStoreBill({
    required String jobId,
    required String billPath,
  }) async {
    final index = _jobs.indexWhere((job) => job.id == jobId);
    if (index == -1) {
      return;
    }

    final storedPath = _usesFirebase
        ? await _uploadFileToStorage(
            localPath: billPath,
            remoteDirectory: 'jobs/$jobId/store_bills',
          )
        : billPath;

    final updatedJob = _jobs[index].copyWith(
      storeBillPath: storedPath,
      updatedAt: DateTime.now(),
    );

    if (_usesFirebase) {
      await _jobsCollection.doc(jobId).update(<String, dynamic>{
        'storeBillPath': storedPath,
        'updatedAt': updatedJob.updatedAt.toIso8601String(),
      });
      return;
    }

    _jobs[index] = updatedJob;
    await _persistLocalSnapshot();
    notifyListeners();
  }

  Future<void> submitInternalStoreReview({
    required String jobId,
    required String note,
  }) async {
    final index = _jobs.indexWhere((job) => job.id == jobId);
    if (index == -1) {
      return;
    }

    final updatedJob = _jobs[index].copyWith(
      internalStoreReview: note,
      updatedAt: DateTime.now(),
    );

    if (_usesFirebase) {
      await _jobsCollection.doc(jobId).update(<String, dynamic>{
        'internalStoreReview': note,
        'updatedAt': updatedJob.updatedAt.toIso8601String(),
      });
      return;
    }

    _jobs[index] = updatedJob;
    await _persistLocalSnapshot();
    notifyListeners();
  }

  Future<void> submitCustomerPayment({
    required String jobId,
    required String transactionId,
    required String screenshotPath,
    required String feedback,
  }) async {
    final index = _jobs.indexWhere((job) => job.id == jobId);
    if (index == -1) {
      return;
    }

    final job = _jobs[index];
    final storedPath = _usesFirebase
        ? await _uploadFileToStorage(
            localPath: screenshotPath,
            remoteDirectory: 'jobs/$jobId/payment_proofs',
          )
        : screenshotPath;

    final updatedJob = job.copyWith(
      paymentTransactionId: transactionId,
      paymentScreenshotPath: storedPath,
      feedback: feedback,
      status: JobStatus.closed,
      updatedAt: DateTime.now(),
    );

    if (_usesFirebase) {
      final batch = _firestore!.batch();
      batch.update(_jobsCollection.doc(jobId), updatedJob.toMap());

      if (job.workerId != null) {
        final worker = _worker(job.workerId);
        if (worker != null) {
          final commission = calculateCommission(job.budget);
          final nextDueDate = _nextCommissionDate(DateTime.now());
          batch.update(_usersCollection.doc(worker.id), <String, dynamic>{
            'totalEarned': worker.totalEarned + job.budget,
            'commissionDue': worker.commissionDue + commission,
            'commissionDueDate': nextDueDate.toIso8601String(),
          });
        }
      }

      await batch.commit();
      return;
    }

    _jobs[index] = updatedJob;

    if (job.workerId != null) {
      final workerIndex = _users.indexWhere((user) => user.id == job.workerId);
      if (workerIndex != -1) {
        final worker = _users[workerIndex];
        final commission = calculateCommission(job.budget);
        _users[workerIndex] = worker.copyWith(
          totalEarned: worker.totalEarned + job.budget,
          commissionDue: worker.commissionDue + commission,
          commissionDueDate: _nextCommissionDate(DateTime.now()),
        );
      }
    }

    _syncWorkerSuspensions();
    await _persistLocalSnapshot();
    notifyListeners();
  }

  Future<void> submitCommissionPayment({
    required String transactionId,
    required String screenshotPath,
  }) async {
    final worker = _currentUser;
    if (worker == null || worker.commissionDue <= 0) {
      return;
    }

    final storedPath = _usesFirebase
        ? await _uploadFileToStorage(
            localPath: screenshotPath,
            remoteDirectory: 'commission/${worker.id}',
          )
        : screenshotPath;

    final submission = CommissionSubmission(
      id: _usesFirebase
          ? _commissionCollection.doc().id
          : createId('commission'),
      workerId: worker.id,
      workerName: worker.name,
      amount: worker.commissionDue,
      transactionId: transactionId,
      screenshotPath: storedPath,
      status: SubmissionStatus.pending,
      submittedAt: DateTime.now(),
    );

    if (_usesFirebase) {
      await _commissionCollection.doc(submission.id).set(submission.toMap());
      return;
    }

    _commissionSubmissions.add(submission);
    await _persistLocalSnapshot();
    notifyListeners();
  }

  Future<void> approveWorker(String workerId, {String? approverId}) async {
    final index = _users.indexWhere((user) => user.id == workerId);
    if (index == -1) {
      return;
    }
    final worker = _users[index];
    final linkedApproverId = approverId ?? worker.linkedApproverId;

    if (_usesFirebase) {
      await _usersCollection.doc(workerId).update(<String, dynamic>{
        'isVerified': true,
        'linkedApproverId': linkedApproverId,
      });
      return;
    }

    _users[index] = worker.copyWith(
      isVerified: true,
      linkedApproverId: linkedApproverId,
    );
    await _persistLocalSnapshot();
    notifyListeners();
  }

  Future<void> toggleWorkerSuspension(String workerId, bool value) async {
    final index = _users.indexWhere((user) => user.id == workerId);
    if (index == -1) {
      return;
    }

    if (_usesFirebase) {
      await _usersCollection.doc(workerId).update(<String, dynamic>{
        'isSuspended': value,
      });
      return;
    }

    _users[index] = _users[index].copyWith(isSuspended: value);
    await _persistLocalSnapshot();
    notifyListeners();
  }

  Future<void> approveCommissionSubmission(String submissionId) async {
    final submissionIndex = _commissionSubmissions.indexWhere(
      (item) => item.id == submissionId,
    );
    if (submissionIndex == -1) {
      return;
    }

    final submission = _commissionSubmissions[submissionIndex];

    if (_usesFirebase) {
      final worker = _userById(submission.workerId);
      final batch = _firestore!.batch();
      batch.update(_commissionCollection.doc(submissionId), <String, dynamic>{
        'status': enumName(SubmissionStatus.approved),
      });

      if (worker != null) {
        final updatedDue = math.max(
          0,
          worker.commissionDue - submission.amount,
        );
        batch.update(_usersCollection.doc(worker.id), <String, dynamic>{
          'commissionDue': updatedDue,
          'isSuspended': false,
          'commissionDueDate': updatedDue == 0
              ? null
              : worker.commissionDueDate?.toIso8601String(),
        });
      }

      await batch.commit();
      return;
    }

    _commissionSubmissions[submissionIndex] = submission.copyWith(
      status: SubmissionStatus.approved,
    );

    final workerIndex = _users.indexWhere(
      (user) => user.id == submission.workerId,
    );
    if (workerIndex != -1) {
      final worker = _users[workerIndex];
      final updatedDue = math
          .max(0, worker.commissionDue - submission.amount)
          .toDouble();
      _users[workerIndex] = worker.copyWith(
        commissionDue: updatedDue,
        isSuspended: false,
        clearCommissionDueDate: updatedDue == 0,
      );
    }

    await _persistLocalSnapshot();
    notifyListeners();
  }

  Future<void> activatePreferredListing(String plan) async {
    final approver = _currentUser;
    if (approver == null) {
      return;
    }

    if (_usesFirebase) {
      await _usersCollection.doc(approver.id).update(<String, dynamic>{
        'preferredListing': true,
        'preferredPlan': plan,
      });
      return;
    }

    final index = _users.indexWhere((user) => user.id == approver.id);
    if (index == -1) {
      return;
    }

    _users[index] = _users[index].copyWith(
      preferredListing: true,
      preferredPlan: plan,
    );
    _currentUser = _users[index];
    await _persistLocalSnapshot();
    notifyListeners();
  }

  Future<void> addComplaint({
    required String againstId,
    required String againstLabel,
    required String category,
    required String message,
  }) async {
    final reporter = _currentUser;
    if (reporter == null) {
      return;
    }

    final complaint = ComplaintRecord(
      id: _usesFirebase
          ? _complaintsCollection.doc().id
          : createId('complaint'),
      reporterId: reporter.id,
      reporterName: reporter.name,
      reporterRole: reporter.role,
      againstLabel: againstLabel,
      againstId: againstId,
      category: category,
      message: message,
      whatsAppMessage: buildComplaintMessage(
        reporter: reporter,
        againstLabel: againstLabel,
        category: category,
        message: message,
      ),
      createdAt: DateTime.now(),
    );

    if (_usesFirebase) {
      await _complaintsCollection.doc(complaint.id).set(complaint.toMap());
      return;
    }

    _complaints.add(complaint);
    await _persistLocalSnapshot();
    notifyListeners();
  }

  String buildComplaintMessage({
    required AppUser reporter,
    required String againstLabel,
    required String category,
    required String message,
  }) {
    return '''Shramik Complaint Request
Role: ${reporter.displayTitle}
Name: ${reporter.name}
Phone: ${reporter.phone}
Pincode: ${reporter.pincode}
Against: $againstLabel
Complaint Type: $category
Details: $message
Generated By: Shramik App''';
  }

  double calculateCommission(double amount) {
    return math.min(amount * 0.05, 50);
  }

  Future<void> resetDemoData() async {
    if (_usesFirebase) {
      await _seedFirestoreSampleDataIfNeeded(force: true);
      return;
    }

    _currentUser = null;
    _seedLocalDemoData();
    await _persistLocalSnapshot();
    notifyListeners();
  }

  Future<String?> _signUpWithFirebase(SignUpData data) async {
    final normalizedEmail = data.email.trim().toLowerCase();
    final isWorker = data.role == UserRole.worker;
    final isApprover = data.role == UserRole.approver;

    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: data.password,
      );

      final uid = credential.user!.uid;
      final linkedApprover = _findApproverByPincode(data.pincode);
      final photoUrl = isWorker && data.photoPath != null
          ? await _uploadFileToStorage(
              localPath: data.photoPath!,
              remoteDirectory: 'workers/$uid/photos',
            )
          : null;
      final idProofUrl = isWorker && data.idProofPath != null
          ? await _uploadFileToStorage(
              localPath: data.idProofPath!,
              remoteDirectory: 'workers/$uid/id_proofs',
            )
          : null;

      final user = AppUser(
        id: uid,
        role: data.role,
        email: normalizedEmail,
        password: '',
        name: data.name.trim(),
        phone: data.phone.trim(),
        address: data.address.trim(),
        pincode: data.pincode.trim(),
        shopName: isApprover ? data.shopName?.trim() : null,
        trade: isWorker ? data.trade?.trim() : null,
        upiId: isWorker ? data.upiId?.trim() : null,
        photoPath: photoUrl,
        idProofPath: idProofUrl,
        linkedApproverId: isWorker ? linkedApprover?.id : null,
        isVerified: data.role == UserRole.customer,
        preferredListing: false,
      );

      await _usersCollection.doc(uid).set(user.toMap());
      if (isApprover) {
        await _linkWorkersToApproverInFirebase(user);
      }
      _currentUser = user;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (error) {
      return _authErrorMessage(error);
    } catch (_) {
      return 'Unable to create account right now';
    }
  }

  Future<void> _initializeFirebaseMode() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _usesFirebase = true;
      _firebaseError = null;

      await _seedFirestoreSampleDataIfNeeded();
      _bindFirebaseStreams();
      await _refreshCurrentUserFromAuth();
    } catch (error) {
      _usesFirebase = false;
      _firebaseError = error.toString();
      debugPrint('Firebase initialization failed: $error');
    }
  }

  void _bindFirebaseStreams() {
    _authSubscription?.cancel();
    _usersSubscription?.cancel();
    _jobsSubscription?.cancel();
    _complaintsSubscription?.cancel();
    _commissionSubscription?.cancel();

    _authSubscription = _auth!.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        notifyListeners();
        return;
      }
      await _refreshCurrentUser(firebaseUser.uid);
      notifyListeners();
    });

    _usersSubscription = _usersCollection.snapshots().listen((snapshot) {
      _users
        ..clear()
        ..addAll(snapshot.docs.map(_userFromDocument));
      _syncWorkerSuspensions();
      _syncCurrentUserFromCache();
      notifyListeners();
    });

    _jobsSubscription = _jobsCollection.snapshots().listen((snapshot) {
      _jobs
        ..clear()
        ..addAll(snapshot.docs.map(_jobFromDocument));
      notifyListeners();
    });

    _complaintsSubscription = _complaintsCollection.snapshots().listen((
      snapshot,
    ) {
      _complaints
        ..clear()
        ..addAll(snapshot.docs.map(_complaintFromDocument));
      notifyListeners();
    });

    _commissionSubscription = _commissionCollection.snapshots().listen((
      snapshot,
    ) {
      _commissionSubmissions
        ..clear()
        ..addAll(snapshot.docs.map(_commissionFromDocument));
      notifyListeners();
    });
  }

  Future<void> _refreshCurrentUserFromAuth() async {
    final firebaseUser = _auth?.currentUser;
    if (firebaseUser == null) {
      _currentUser = null;
      return;
    }
    await _refreshCurrentUser(firebaseUser.uid);
  }

  Future<void> _refreshCurrentUser(String uid) async {
    final cachedUser = _userById(uid);
    if (cachedUser != null) {
      _currentUser = cachedUser;
      return;
    }

    final snapshot = await _usersCollection.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      _currentUser = null;
      return;
    }

    _currentUser = _userFromDocument(snapshot);
  }

  void _syncCurrentUserFromCache() {
    if (_currentUser != null) {
      _currentUser = _userById(_currentUser!.id);
    }
  }

  Future<void> _seedFirestoreSampleDataIfNeeded({bool force = false}) async {
    if (!_usesFirebase) {
      return;
    }

    final existingUsers = await _usersCollection.limit(1).get();
    if (existingUsers.docs.isNotEmpty && !force) {
      return;
    }

    const katraPincode = '182320';
    final approver = AppUser(
      id: 'sample-approver-1',
      role: UserRole.approver,
      email: 'sample.approver@shramik.demo',
      password: '',
      name: 'Ramesh Gupta',
      phone: '9876500011',
      address: 'Main Bazaar, Katra',
      pincode: katraPincode,
      shopName: 'Gupta Hardware Store',
      isVerified: true,
      preferredListing: true,
      preferredPlan: 'Monthly',
      totalShopEarnings: 0,
    );
    final worker = AppUser(
      id: 'sample-worker-1',
      role: UserRole.worker,
      email: 'sample.worker@shramik.demo',
      password: '',
      name: 'Imran Ali',
      phone: '9876500022',
      address: 'Ward 3, Katra',
      pincode: katraPincode,
      trade: 'Electrician',
      upiId: 'imranali@upi',
      photoPath: 'sample_worker_photo.jpg',
      idProofPath: 'aadhaar_imran.pdf',
      linkedApproverId: approver.id,
      isVerified: true,
      totalEarned: 3200,
      commissionDue: 45,
      commissionDueDate: _nextCommissionDate(DateTime.now()),
    );
    final customer = AppUser(
      id: 'sample-customer-1',
      role: UserRole.customer,
      email: 'sample.customer@shramik.demo',
      password: '',
      name: 'Neha Sharma',
      phone: '9876500033',
      address: 'Near Bus Stand, Katra',
      pincode: katraPincode,
      isVerified: true,
    );
    final workerTwo = AppUser(
      id: 'sample-worker-2',
      role: UserRole.worker,
      email: 'sample.plumber@shramik.demo',
      password: '',
      name: 'Ravi Kumar',
      phone: '9876500044',
      address: 'Ward 5, Katra',
      pincode: katraPincode,
      trade: 'Plumber',
      upiId: 'ravikumar@upi',
      photoPath: 'sample_ravi_photo.jpg',
      idProofPath: 'aadhaar_ravi.pdf',
      linkedApproverId: approver.id,
      isVerified: false,
    );

    final jobOne = JobRequest(
      id: 'sample-job-1',
      customerId: customer.id,
      customerName: customer.name,
      customerPhone: customer.phone,
      category: 'Electrician',
      title: 'Fan wiring repair',
      description: 'Ceiling fan spark issue in drawing room.',
      address: customer.address,
      pincode: katraPincode,
      budget: 700,
      status: JobStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      workerId: worker.id,
      workerName: worker.name,
      workerPhone: worker.phone,
      workerUpiId: worker.upiId,
      approverId: approver.id,
    );
    final jobTwo = JobRequest(
      id: 'sample-job-2',
      customerId: customer.id,
      customerName: customer.name,
      customerPhone: customer.phone,
      category: 'Plumber',
      title: 'Kitchen tap replacement',
      description: 'Need plumber for leaking tap and fitting change.',
      address: customer.address,
      pincode: katraPincode,
      budget: 900,
      status: JobStatus.open,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    );
    final commission = CommissionSubmission(
      id: 'sample-commission-1',
      workerId: worker.id,
      workerName: worker.name,
      amount: 45,
      transactionId: 'TXNDEMO45',
      screenshotPath: 'commission_proof_demo.jpg',
      status: SubmissionStatus.pending,
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
    );

    final batch = _firestore!.batch();
    for (final user in <AppUser>[approver, worker, customer, workerTwo]) {
      batch.set(_usersCollection.doc(user.id), user.toMap());
    }
    for (final job in <JobRequest>[jobOne, jobTwo]) {
      batch.set(_jobsCollection.doc(job.id), job.toMap());
    }
    batch.set(_commissionCollection.doc(commission.id), commission.toMap());
    await batch.commit();
  }

  Future<String> _uploadFileToStorage({
    required String localPath,
    required String remoteDirectory,
  }) async {
    if (!_usesFirebase || _storage == null) {
      return localPath;
    }

    final extension = _extensionFromPath(localPath);
    final objectName =
        '${DateTime.now().microsecondsSinceEpoch}${extension.isEmpty ? '' : '.$extension'}';
    final reference = _storage!.ref().child('$remoteDirectory/$objectName');
    try {
      await reference.putFile(File(localPath));
      return reference.getDownloadURL();
    } catch (error) {
      _firebaseError =
          'Firebase Storage is not fully set up yet. File references are being kept locally until Storage is enabled.';
      notifyListeners();
      return localPath;
    }
  }

  Future<void> _linkWorkersToApproverInFirebase(AppUser approver) async {
    final query = await _usersCollection
        .where('role', isEqualTo: enumName(UserRole.worker))
        .where('pincode', isEqualTo: approver.pincode)
        .get();

    final batch = _firestore!.batch();
    var hasUpdates = false;
    for (final document in query.docs) {
      final worker = _userFromDocument(document);
      if (worker.linkedApproverId == null) {
        batch.update(document.reference, <String, dynamic>{
          'linkedApproverId': approver.id,
        });
        hasUpdates = true;
      }
    }
    if (hasUpdates) {
      await batch.commit();
    }
  }

  bool _isFirebaseConfigured() {
    try {
      return DefaultFirebaseOptions.currentPlatform.projectId !=
          _firebasePlaceholder;
    } catch (_) {
      return false;
    }
  }

  void _loadLanguagePreference() {
    final raw = _preferences?.getString(_languageKey);
    if (raw == null) {
      _language = AppLanguage.english;
      return;
    }
    _language = enumFromName(AppLanguage.values, raw);
  }

  Future<void> _saveLanguagePreference() async {
    await _preferences?.setString(_languageKey, enumName(_language));
  }

  Future<void> _loadLocalFallback() async {
    final snapshotJson = _preferences?.getString(_storageKey);
    if (snapshotJson == null) {
      _seedLocalDemoData();
      await _persistLocalSnapshot();
      return;
    }

    final snapshot = AppSnapshot.fromJson(snapshotJson);
    _users
      ..clear()
      ..addAll(snapshot.users);
    _jobs
      ..clear()
      ..addAll(snapshot.jobs);
    _complaints
      ..clear()
      ..addAll(snapshot.complaints);
    _commissionSubmissions
      ..clear()
      ..addAll(snapshot.commissionSubmissions);
    _syncWorkerSuspensions();
  }

  void _seedLocalDemoData() {
    _users.clear();
    _jobs.clear();
    _complaints.clear();
    _commissionSubmissions.clear();

    const katraPincode = '182320';
    final admin = AppUser(
      id: 'admin-1',
      role: UserRole.admin,
      email: adminEmail,
      password: adminPassword,
      name: adminName,
      phone: adminPhone,
      address: adminAddress,
      pincode: adminPincode,
      isVerified: true,
    );
    final approver = AppUser(
      id: 'approver-1',
      role: UserRole.approver,
      email: 'shop@shramik.app',
      password: 'demo123',
      name: 'Ramesh Gupta',
      phone: '9876500011',
      address: 'Main Bazaar, Katra',
      pincode: katraPincode,
      shopName: 'Gupta Hardware Store',
      isVerified: true,
      preferredListing: true,
      preferredPlan: 'Monthly',
      totalShopEarnings: 0,
    );
    final worker = AppUser(
      id: 'worker-1',
      role: UserRole.worker,
      email: 'worker@shramik.app',
      password: 'demo123',
      name: 'Imran Ali',
      phone: '9876500022',
      address: 'Ward 3, Katra',
      pincode: katraPincode,
      trade: 'Electrician',
      upiId: 'imranali@upi',
      photoPath: 'sample_worker_photo.jpg',
      idProofPath: 'aadhaar_imran.pdf',
      linkedApproverId: approver.id,
      isVerified: true,
      totalEarned: 3200,
      commissionDue: 45,
      commissionDueDate: _nextCommissionDate(DateTime.now()),
    );
    final customer = AppUser(
      id: 'customer-1',
      role: UserRole.customer,
      email: 'customer@shramik.app',
      password: 'demo123',
      name: 'Neha Sharma',
      phone: '9876500033',
      address: 'Near Bus Stand, Katra',
      pincode: katraPincode,
      isVerified: true,
    );
    final workerTwo = AppUser(
      id: 'worker-2',
      role: UserRole.worker,
      email: 'plumber@shramik.app',
      password: 'demo123',
      name: 'Ravi Kumar',
      phone: '9876500044',
      address: 'Ward 5, Katra',
      pincode: katraPincode,
      trade: 'Plumber',
      upiId: 'ravikumar@upi',
      photoPath: 'sample_ravi_photo.jpg',
      idProofPath: 'aadhaar_ravi.pdf',
      linkedApproverId: approver.id,
      isVerified: false,
    );

    _users.addAll(<AppUser>[admin, approver, worker, customer, workerTwo]);

    _jobs.addAll(<JobRequest>[
      JobRequest(
        id: 'job-1',
        customerId: customer.id,
        customerName: customer.name,
        customerPhone: customer.phone,
        category: 'Electrician',
        title: 'Fan wiring repair',
        description: 'Ceiling fan spark issue in drawing room.',
        address: customer.address,
        pincode: katraPincode,
        budget: 700,
        status: JobStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        workerId: worker.id,
        workerName: worker.name,
        workerPhone: worker.phone,
        workerUpiId: worker.upiId,
        approverId: approver.id,
      ),
      JobRequest(
        id: 'job-2',
        customerId: customer.id,
        customerName: customer.name,
        customerPhone: customer.phone,
        category: 'Plumber',
        title: 'Kitchen tap replacement',
        description: 'Need plumber for leaking tap and fitting change.',
        address: customer.address,
        pincode: katraPincode,
        budget: 900,
        status: JobStatus.open,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);

    _commissionSubmissions.add(
      CommissionSubmission(
        id: 'commission-1',
        workerId: worker.id,
        workerName: worker.name,
        amount: 45,
        transactionId: 'TXNDEMO45',
        screenshotPath: 'commission_proof_demo.jpg',
        status: SubmissionStatus.pending,
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    );

    _syncWorkerSuspensions();
  }

  Future<void> _persistLocalSnapshot() async {
    _syncWorkerSuspensions();
    final snapshot = AppSnapshot(
      language: _language,
      users: _users,
      jobs: _jobs,
      complaints: _complaints,
      commissionSubmissions: _commissionSubmissions,
    );
    await _preferences?.setString(_storageKey, snapshot.toJson());
    await _saveLanguagePreference();

    if (_currentUser != null) {
      final latest = _users.where((user) => user.id == _currentUser!.id);
      _currentUser = latest.isEmpty ? null : latest.first;
    }
  }

  AppUser? _findUserByEmail(String email) {
    for (final user in _users) {
      if (user.email == email) {
        return user;
      }
    }
    return null;
  }

  AppUser? _findApproverByPincode(String pincode) {
    for (final user in _users) {
      if (user.role == UserRole.approver && user.pincode == pincode) {
        return user;
      }
    }
    return null;
  }

  AppUser? _worker(String? id) {
    if (id == null) {
      return null;
    }
    return _userById(id);
  }

  AppUser? _userById(String id) {
    for (final user in _users) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }

  void _autoLinkWorkersToApproverLocally(AppUser approver) {
    for (var index = 0; index < _users.length; index++) {
      final user = _users[index];
      if (user.role == UserRole.worker &&
          user.pincode == approver.pincode &&
          user.linkedApproverId == null) {
        _users[index] = user.copyWith(linkedApproverId: approver.id);
      }
    }
  }

  DateTime _nextCommissionDate(DateTime from) {
    return DateTime(from.year, from.month + 1, 7);
  }

  void _syncWorkerSuspensions() {
    for (var index = 0; index < _users.length; index++) {
      final user = _users[index];
      if (user.role != UserRole.worker) {
        continue;
      }

      final shouldSuspend =
          user.commissionDue > 0 &&
          user.commissionDueDate != null &&
          DateTime.now().isAfter(user.commissionDueDate!);
      if (shouldSuspend != user.isSuspended) {
        _users[index] = user.copyWith(isSuspended: shouldSuspend);
      }
    }
  }

  AppUser _userFromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = Map<String, dynamic>.from(
      snapshot.data() ?? <String, dynamic>{},
    );
    data['id'] = data['id'] ?? snapshot.id;
    return AppUser.fromMap(data);
  }

  JobRequest _jobFromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = Map<String, dynamic>.from(
      snapshot.data() ?? <String, dynamic>{},
    );
    data['id'] = data['id'] ?? snapshot.id;
    return JobRequest.fromMap(data);
  }

  ComplaintRecord _complaintFromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = Map<String, dynamic>.from(
      snapshot.data() ?? <String, dynamic>{},
    );
    data['id'] = data['id'] ?? snapshot.id;
    return ComplaintRecord.fromMap(data);
  }

  CommissionSubmission _commissionFromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = Map<String, dynamic>.from(
      snapshot.data() ?? <String, dynamic>{},
    );
    data['id'] = data['id'] ?? snapshot.id;
    return CommissionSubmission.fromMap(data);
  }

  String _extensionFromPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    final fileName = normalized.split('/').last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex + 1);
  }

  String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'invalid-email':
      case 'user-not-found':
        return 'Invalid email or password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'network-request-failed':
        return 'Network error, please check your internet connection';
      default:
        return error.message ?? 'Authentication failed';
    }
  }
}
