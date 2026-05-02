import 'dart:convert';

enum UserRole { customer, worker, approver, admin }

enum AppLanguage { english, hindi }

enum JobStatus { open, accepted, inProgress, paymentPending, closed }

enum SubmissionStatus { pending, approved, rejected }

String enumName(Object value) => value.toString().split('.').last;

T enumFromName<T>(Iterable<T> values, String raw) {
  return values.firstWhere((value) => enumName(value as Object) == raw);
}

String createId(String prefix) =>
    '$prefix-${DateTime.now().microsecondsSinceEpoch.toString()}';

class AppUser {
  const AppUser({
    required this.id,
    required this.role,
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.address,
    required this.pincode,
    this.shopName,
    this.trade,
    this.upiId,
    this.photoPath,
    this.idProofPath,
    this.linkedApproverId,
    this.isVerified = false,
    this.isSuspended = false,
    this.preferredListing = false,
    this.preferredPlan,
    this.totalEarned = 0,
    this.commissionDue = 0,
    this.commissionDueDate,
    this.totalShopEarnings = 0,
  });

  final String id;
  final UserRole role;
  final String email;
  final String password;
  final String name;
  final String phone;
  final String address;
  final String pincode;
  final String? shopName;
  final String? trade;
  final String? upiId;
  final String? photoPath;
  final String? idProofPath;
  final String? linkedApproverId;
  final bool isVerified;
  final bool isSuspended;
  final bool preferredListing;
  final String? preferredPlan;
  final double totalEarned;
  final double commissionDue;
  final DateTime? commissionDueDate;
  final double totalShopEarnings;

  String get displayTitle {
    switch (role) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.worker:
        return 'Worker';
      case UserRole.approver:
        return 'Approver';
      case UserRole.admin:
        return 'Admin';
    }
  }

  AppUser copyWith({
    String? id,
    UserRole? role,
    String? email,
    String? password,
    String? name,
    String? phone,
    String? address,
    String? pincode,
    String? shopName,
    String? trade,
    String? upiId,
    String? photoPath,
    String? idProofPath,
    String? linkedApproverId,
    bool? isVerified,
    bool? isSuspended,
    bool? preferredListing,
    String? preferredPlan,
    double? totalEarned,
    double? commissionDue,
    DateTime? commissionDueDate,
    bool clearCommissionDueDate = false,
    double? totalShopEarnings,
  }) {
    return AppUser(
      id: id ?? this.id,
      role: role ?? this.role,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      pincode: pincode ?? this.pincode,
      shopName: shopName ?? this.shopName,
      trade: trade ?? this.trade,
      upiId: upiId ?? this.upiId,
      photoPath: photoPath ?? this.photoPath,
      idProofPath: idProofPath ?? this.idProofPath,
      linkedApproverId: linkedApproverId ?? this.linkedApproverId,
      isVerified: isVerified ?? this.isVerified,
      isSuspended: isSuspended ?? this.isSuspended,
      preferredListing: preferredListing ?? this.preferredListing,
      preferredPlan: preferredPlan ?? this.preferredPlan,
      totalEarned: totalEarned ?? this.totalEarned,
      commissionDue: commissionDue ?? this.commissionDue,
      commissionDueDate: clearCommissionDueDate
          ? null
          : commissionDueDate ?? this.commissionDueDate,
      totalShopEarnings: totalShopEarnings ?? this.totalShopEarnings,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'role': enumName(role),
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'address': address,
      'pincode': pincode,
      'shopName': shopName,
      'trade': trade,
      'upiId': upiId,
      'photoPath': photoPath,
      'idProofPath': idProofPath,
      'linkedApproverId': linkedApproverId,
      'isVerified': isVerified,
      'isSuspended': isSuspended,
      'preferredListing': preferredListing,
      'preferredPlan': preferredPlan,
      'totalEarned': totalEarned,
      'commissionDue': commissionDue,
      'commissionDueDate': commissionDueDate?.toIso8601String(),
      'totalShopEarnings': totalShopEarnings,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      role: enumFromName(UserRole.values, map['role'] as String),
      email: map['email'] as String,
      password: (map['password'] as String?) ?? '',
      name: map['name'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      pincode: map['pincode'] as String,
      shopName: map['shopName'] as String?,
      trade: map['trade'] as String?,
      upiId: map['upiId'] as String?,
      photoPath: map['photoPath'] as String?,
      idProofPath: map['idProofPath'] as String?,
      linkedApproverId: map['linkedApproverId'] as String?,
      isVerified: (map['isVerified'] as bool?) ?? false,
      isSuspended: (map['isSuspended'] as bool?) ?? false,
      preferredListing: (map['preferredListing'] as bool?) ?? false,
      preferredPlan: map['preferredPlan'] as String?,
      totalEarned: (map['totalEarned'] as num?)?.toDouble() ?? 0,
      commissionDue: (map['commissionDue'] as num?)?.toDouble() ?? 0,
      commissionDueDate: map['commissionDueDate'] == null
          ? null
          : DateTime.parse(map['commissionDueDate'] as String),
      totalShopEarnings: (map['totalShopEarnings'] as num?)?.toDouble() ?? 0,
    );
  }
}

class JobRequest {
  const JobRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.category,
    required this.title,
    required this.description,
    required this.address,
    required this.pincode,
    required this.budget,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.workerId,
    this.workerName,
    this.workerPhone,
    this.workerUpiId,
    this.approverId,
    this.paymentTransactionId,
    this.paymentScreenshotPath,
    this.feedback,
    this.storeBillPath,
    this.internalStoreReview,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String category;
  final String title;
  final String description;
  final String address;
  final String pincode;
  final double budget;
  final JobStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? workerId;
  final String? workerName;
  final String? workerPhone;
  final String? workerUpiId;
  final String? approverId;
  final String? paymentTransactionId;
  final String? paymentScreenshotPath;
  final String? feedback;
  final String? storeBillPath;
  final String? internalStoreReview;

  JobRequest copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? category,
    String? title,
    String? description,
    String? address,
    String? pincode,
    double? budget,
    JobStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workerId,
    String? workerName,
    String? workerPhone,
    String? workerUpiId,
    String? approverId,
    String? paymentTransactionId,
    String? paymentScreenshotPath,
    String? feedback,
    String? storeBillPath,
    String? internalStoreReview,
  }) {
    return JobRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      pincode: pincode ?? this.pincode,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      workerPhone: workerPhone ?? this.workerPhone,
      workerUpiId: workerUpiId ?? this.workerUpiId,
      approverId: approverId ?? this.approverId,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      paymentScreenshotPath:
          paymentScreenshotPath ?? this.paymentScreenshotPath,
      feedback: feedback ?? this.feedback,
      storeBillPath: storeBillPath ?? this.storeBillPath,
      internalStoreReview: internalStoreReview ?? this.internalStoreReview,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'category': category,
      'title': title,
      'description': description,
      'address': address,
      'pincode': pincode,
      'budget': budget,
      'status': enumName(status),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'workerId': workerId,
      'workerName': workerName,
      'workerPhone': workerPhone,
      'workerUpiId': workerUpiId,
      'approverId': approverId,
      'paymentTransactionId': paymentTransactionId,
      'paymentScreenshotPath': paymentScreenshotPath,
      'feedback': feedback,
      'storeBillPath': storeBillPath,
      'internalStoreReview': internalStoreReview,
    };
  }

  factory JobRequest.fromMap(Map<String, dynamic> map) {
    return JobRequest(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String,
      customerPhone: map['customerPhone'] as String,
      category: map['category'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      address: map['address'] as String,
      pincode: map['pincode'] as String,
      budget: (map['budget'] as num).toDouble(),
      status: enumFromName(JobStatus.values, map['status'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      workerId: map['workerId'] as String?,
      workerName: map['workerName'] as String?,
      workerPhone: map['workerPhone'] as String?,
      workerUpiId: map['workerUpiId'] as String?,
      approverId: map['approverId'] as String?,
      paymentTransactionId: map['paymentTransactionId'] as String?,
      paymentScreenshotPath: map['paymentScreenshotPath'] as String?,
      feedback: map['feedback'] as String?,
      storeBillPath: map['storeBillPath'] as String?,
      internalStoreReview: map['internalStoreReview'] as String?,
    );
  }
}

class ComplaintRecord {
  const ComplaintRecord({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reporterRole,
    required this.againstLabel,
    required this.againstId,
    required this.category,
    required this.message,
    required this.whatsAppMessage,
    required this.createdAt,
  });

  final String id;
  final String reporterId;
  final String reporterName;
  final UserRole reporterRole;
  final String againstLabel;
  final String againstId;
  final String category;
  final String message;
  final String whatsAppMessage;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reporterRole': enumName(reporterRole),
      'againstLabel': againstLabel,
      'againstId': againstId,
      'category': category,
      'message': message,
      'whatsAppMessage': whatsAppMessage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ComplaintRecord.fromMap(Map<String, dynamic> map) {
    return ComplaintRecord(
      id: map['id'] as String,
      reporterId: map['reporterId'] as String,
      reporterName: map['reporterName'] as String,
      reporterRole: enumFromName(
        UserRole.values,
        map['reporterRole'] as String,
      ),
      againstLabel: map['againstLabel'] as String,
      againstId: map['againstId'] as String,
      category: map['category'] as String,
      message: map['message'] as String,
      whatsAppMessage: map['whatsAppMessage'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class CommissionSubmission {
  const CommissionSubmission({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.amount,
    required this.transactionId,
    required this.screenshotPath,
    required this.status,
    required this.submittedAt,
  });

  final String id;
  final String workerId;
  final String workerName;
  final double amount;
  final String transactionId;
  final String screenshotPath;
  final SubmissionStatus status;
  final DateTime submittedAt;

  CommissionSubmission copyWith({
    String? id,
    String? workerId,
    String? workerName,
    double? amount,
    String? transactionId,
    String? screenshotPath,
    SubmissionStatus? status,
    DateTime? submittedAt,
  }) {
    return CommissionSubmission(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      amount: amount ?? this.amount,
      transactionId: transactionId ?? this.transactionId,
      screenshotPath: screenshotPath ?? this.screenshotPath,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'workerId': workerId,
      'workerName': workerName,
      'amount': amount,
      'transactionId': transactionId,
      'screenshotPath': screenshotPath,
      'status': enumName(status),
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  factory CommissionSubmission.fromMap(Map<String, dynamic> map) {
    return CommissionSubmission(
      id: map['id'] as String,
      workerId: map['workerId'] as String,
      workerName: map['workerName'] as String,
      amount: (map['amount'] as num).toDouble(),
      transactionId: map['transactionId'] as String,
      screenshotPath: map['screenshotPath'] as String,
      status: enumFromName(SubmissionStatus.values, map['status'] as String),
      submittedAt: DateTime.parse(map['submittedAt'] as String),
    );
  }
}

class AppSnapshot {
  const AppSnapshot({
    required this.language,
    required this.users,
    required this.jobs,
    required this.complaints,
    required this.commissionSubmissions,
  });

  final AppLanguage language;
  final List<AppUser> users;
  final List<JobRequest> jobs;
  final List<ComplaintRecord> complaints;
  final List<CommissionSubmission> commissionSubmissions;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'language': enumName(language),
      'users': users.map((user) => user.toMap()).toList(),
      'jobs': jobs.map((job) => job.toMap()).toList(),
      'complaints': complaints.map((item) => item.toMap()).toList(),
      'commissionSubmissions': commissionSubmissions
          .map((item) => item.toMap())
          .toList(),
    };
  }

  String toJson() => jsonEncode(toMap());

  factory AppSnapshot.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return AppSnapshot(
      language: enumFromName(AppLanguage.values, map['language'] as String),
      users: (map['users'] as List<dynamic>)
          .map((item) => AppUser.fromMap(item as Map<String, dynamic>))
          .toList(),
      jobs: (map['jobs'] as List<dynamic>)
          .map((item) => JobRequest.fromMap(item as Map<String, dynamic>))
          .toList(),
      complaints: (map['complaints'] as List<dynamic>)
          .map((item) => ComplaintRecord.fromMap(item as Map<String, dynamic>))
          .toList(),
      commissionSubmissions: (map['commissionSubmissions'] as List<dynamic>)
          .map(
            (item) =>
                CommissionSubmission.fromMap(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class SignUpData {
  const SignUpData({
    required this.role,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.pincode,
    this.shopName,
    this.trade,
    this.upiId,
    this.photoPath,
    this.idProofPath,
  });

  final UserRole role;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String address;
  final String pincode;
  final String? shopName;
  final String? trade;
  final String? upiId;
  final String? photoPath;
  final String? idProofPath;
}
