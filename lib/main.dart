import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_state.dart';
import 'models.dart';

const List<String> serviceCategories = <String>[
  'Electrician',
  'Plumber',
  'Carpenter',
  'Painter',
  'Mason',
  'Welder',
  'Appliance Repair',
  'Helper',
  'Other',
];

void main() {
  runApp(
    ChangeNotifierProvider<AppState>(
      create: (_) => AppState()..initialize(),
      child: const ShramikApp(),
    ),
  );
}

class ShramikApp extends StatelessWidget {
  const ShramikApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return MaterialApp(
      title: 'Shramik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEF6C32),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F6F1),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: !app.isReady
          ? const BrandedLoadingScreen()
          : app.isLoggedIn
          ? const DashboardShell()
          : const AuthScreen(),
    );
  }
}

class BrandedLoadingScreen extends StatelessWidget {
  const BrandedLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFFFFF1DB),
              Color(0xFFF7E8FF),
              Color(0xFFE8F4FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ShramikLogo(size: 100),
              const SizedBox(height: 18),
              Text(
                'Shramik',
                style: GoogleFonts.poppins(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1D1B34),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connecting karigars, customers and trusted shops',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF5B5871),
                ),
              ),
              const SizedBox(height: 28),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _pincode = TextEditingController();
  final _shopName = TextEditingController();
  final _upiId = TextEditingController();

  int _mode = 0;
  UserRole _role = UserRole.customer;
  String _category = serviceCategories.first;
  String? _photoPath;
  String? _idProofPath;

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _address.dispose();
    _pincode.dispose();
    _shopName.dispose();
    _upiId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final language = app.language;
    final usesFirebase = app.isUsingFirebase;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFFFFF2E5),
              Color(0xFFF3EDFF),
              Color(0xFFEAFBFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: _LanguageToggle(language: language),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const ShramikLogo(size: 82),
                      const SizedBox(height: 18),
                      Text(
                        tr(language, 'Shramik', 'श्रमिक'),
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E1C38),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tr(
                          language,
                          'A colourful local service marketplace for customers, workers and trusted hardware stores.',
                          'ग्राहकों, कामगारों और भरोसेमंद हार्डवेयर दुकानों को जोड़ने वाला स्थानीय सेवा प्लेटफॉर्म।',
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5B5871),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: SegmentedButton<int>(
                            segments: <ButtonSegment<int>>[
                              ButtonSegment<int>(
                                value: 0,
                                label: Text(tr(language, 'Login', 'लॉगिन')),
                              ),
                              ButtonSegment<int>(
                                value: 1,
                                label: Text(tr(language, 'Sign Up', 'साइन अप')),
                              ),
                            ],
                            selected: <int>{_mode},
                            onSelectionChanged: (selection) {
                              setState(() => _mode = selection.first);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_mode == 0)
                          _buildLogin(language)
                        else
                          _buildSignUp(language),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          usesFirebase
                              ? tr(
                                  language,
                                  'Live backend connected',
                                  'लाइव बैकएंड कनेक्टेड',
                                )
                              : tr(
                                  language,
                                  'Local demo mode',
                                  'लोकल डेमो मोड',
                                ),
                          style: themeTitle(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          usesFirebase
                              ? tr(
                                  language,
                                  'Signup and login now use Firebase Auth, while users, jobs, complaints, and uploads sync with Firestore and Storage.',
                                  'अब साइनअप और लॉगिन Firebase Auth से होते हैं, और यूजर्स, जॉब्स, शिकायतें तथा अपलोड Firestore और Storage से सिंक होते हैं।',
                                )
                              : tr(
                                  language,
                                  'The app still works fully in local mode until Firebase project binding is completed on this PC.',
                                  'जब तक इस पीसी पर Firebase project binding पूरी नहीं होती, ऐप लोकल मोड में पूरी तरह काम करता रहेगा।',
                                ),
                          style: const TextStyle(
                            color: Color(0xFF6A667C),
                            height: 1.45,
                          ),
                        ),
                        if (app.firebaseError != null) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            app.firebaseError!,
                            style: const TextStyle(color: Color(0xFFB3261E)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (!usesFirebase)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            tr(
                              language,
                              'Quick demo accounts',
                              'डेमो अकाउंट्स',
                            ),
                            style: themeTitle(context),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: <Widget>[
                              _DemoChip(
                                label: 'Customer',
                                onTap: () => _setDemoLogin(
                                  'customer@shramik.app',
                                  'demo123',
                                ),
                              ),
                              _DemoChip(
                                label: 'Worker',
                                onTap: () => _setDemoLogin(
                                  'worker@shramik.app',
                                  'demo123',
                                ),
                              ),
                              _DemoChip(
                                label: 'Approver',
                                onTap: () => _setDemoLogin(
                                  'shop@shramik.app',
                                  'demo123',
                                ),
                              ),
                              _DemoChip(
                                label: 'Admin',
                                onTap: () => _setDemoLogin(
                                  AppState.adminEmail,
                                  AppState.adminPassword,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogin(AppLanguage language) {
    return Column(
      children: <Widget>[
        TextField(
          controller: _loginEmail,
          decoration: InputDecoration(
            labelText: tr(language, 'Email', 'ईमेल'),
            prefixIcon: const Icon(Icons.mail_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _loginPassword,
          obscureText: true,
          decoration: InputDecoration(
            labelText: tr(language, 'Password', 'पासवर्ड'),
            prefixIcon: const Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: _submitLogin,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: const Color(0xFFEF6C32),
          ),
          child: Text(
            tr(language, 'Login to Shramik', 'श्रमिक में लॉगिन करें'),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUp(AppLanguage language) {
    final isWorker = _role == UserRole.worker;
    final isApprover = _role == UserRole.approver;

    return Column(
      children: <Widget>[
        DropdownButtonFormField<UserRole>(
          initialValue: _role,
          items:
              <UserRole>[
                UserRole.customer,
                UserRole.worker,
                UserRole.approver,
              ].map((role) {
                return DropdownMenuItem<UserRole>(
                  value: role,
                  child: Text(roleLabel(language, role)),
                );
              }).toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() => _role = value);
          },
          decoration: InputDecoration(
            labelText: tr(language, 'Sign up as', 'किस रूप में साइन अप करें'),
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _name,
          decoration: InputDecoration(
            labelText: tr(
              language,
              isApprover ? 'Owner name' : 'Full name',
              isApprover ? 'मालिक का नाम' : 'पूरा नाम',
            ),
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        if (isApprover) ...<Widget>[
          TextField(
            controller: _shopName,
            decoration: InputDecoration(
              labelText: tr(language, 'Shop name', 'दुकान का नाम'),
              prefixIcon: const Icon(Icons.storefront_outlined),
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _email,
          decoration: InputDecoration(
            labelText: tr(language, 'Email', 'ईमेल'),
            prefixIcon: const Icon(Icons.mail_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(
            labelText: tr(language, 'Password', 'पासवर्ड'),
            prefixIcon: const Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: tr(language, 'Mobile number', 'मोबाइल नंबर'),
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _address,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: tr(language, 'Address', 'पता'),
            prefixIcon: const Icon(Icons.home_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pincode,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: tr(language, 'Pincode', 'पिनकोड'),
            prefixIcon: const Icon(Icons.pin_drop_outlined),
          ),
        ),
        if (isWorker) ...<Widget>[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: serviceCategories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _category = value);
            },
            decoration: InputDecoration(
              labelText: tr(language, 'Worker category', 'काम की श्रेणी'),
              prefixIcon: const Icon(Icons.handyman_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _upiId,
            decoration: InputDecoration(
              labelText: tr(language, 'UPI ID', 'यूपीआई आईडी'),
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
            ),
          ),
          const SizedBox(height: 12),
          _FilePickerTile(
            icon: Icons.photo_camera_back_outlined,
            title: tr(language, 'Worker photo', 'कामगार की फोटो'),
            value: _photoPath,
            onTap: () async {
              final path = await pickSingleFile(
                extensions: <String>['jpg', 'jpeg', 'png'],
              );
              if (path != null) {
                setState(() => _photoPath = path);
              }
            },
          ),
          const SizedBox(height: 10),
          _FilePickerTile(
            icon: Icons.picture_as_pdf_outlined,
            title: tr(
              language,
              'Aadhaar or ID proof PDF',
              'आधार या आईडी प्रूफ पीडीएफ',
            ),
            value: _idProofPath,
            onTap: () async {
              final path = await pickSingleFile(extensions: <String>['pdf']);
              if (path != null) {
                setState(() => _idProofPath = path);
              }
            },
          ),
        ],
        const SizedBox(height: 18),
        FilledButton(
          onPressed: _submitSignUp,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: const Color(0xFF5F3BFF),
          ),
          child: Text(tr(language, 'Create account', 'अकाउंट बनाएं')),
        ),
      ],
    );
  }

  void _setDemoLogin(String email, String password) {
    setState(() {
      _mode = 0;
      _loginEmail.text = email;
      _loginPassword.text = password;
    });
  }

  Future<void> _submitLogin() async {
    final app = context.read<AppState>();
    final error = await app.login(
      email: _loginEmail.text.trim(),
      password: _loginPassword.text,
    );
    if (error != null && mounted) {
      showSnack(context, error);
    }
  }

  Future<void> _submitSignUp() async {
    final language = context.read<AppState>().language;
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _address.text.trim().isEmpty ||
        _pincode.text.trim().isEmpty) {
      showSnack(
        context,
        tr(
          language,
          'Please fill all required fields',
          'कृपया सभी जरूरी जानकारी भरें',
        ),
      );
      return;
    }
    if (_role == UserRole.worker &&
        (_upiId.text.trim().isEmpty ||
            _photoPath == null ||
            _idProofPath == null)) {
      showSnack(
        context,
        tr(
          language,
          'Worker photo, UPI ID and ID proof are required',
          'कामगार की फोटो, यूपीआई आईडी और आईडी प्रूफ जरूरी है',
        ),
      );
      return;
    }
    if (_role == UserRole.approver && _shopName.text.trim().isEmpty) {
      showSnack(
        context,
        tr(language, 'Shop name is required', 'दुकान का नाम जरूरी है'),
      );
      return;
    }

    final app = context.read<AppState>();
    final error = await app.signUp(
      SignUpData(
        role: _role,
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        pincode: _pincode.text.trim(),
        shopName: _shopName.text.trim().isEmpty ? null : _shopName.text.trim(),
        trade: _role == UserRole.worker ? _category : null,
        upiId: _role == UserRole.worker ? _upiId.text.trim() : null,
        photoPath: _photoPath,
        idProofPath: _idProofPath,
      ),
    );

    if (error != null && mounted) {
      showSnack(context, error);
    }
  }
}

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.currentUser!;
    final language = app.language;
    final pages = _buildPagesForRole(user.role);

    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              pages[_selectedIndex].label(language),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              '${roleLabel(language, user.role)} • ${user.pincode}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6A667C)),
            ),
          ],
        ),
      ),
      drawer: _AppDrawer(user: user),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages.map((page) => page.builder()).toList(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() => _selectedIndex = value);
        },
        destinations: pages
            .map(
              (page) => NavigationDestination(
                icon: Icon(page.icon),
                label: page.label(language),
              ),
            )
            .toList(),
      ),
    );
  }
}

List<_RolePage> _buildPagesForRole(UserRole role) {
  switch (role) {
    case UserRole.customer:
      return <_RolePage>[
        _RolePage(
          icon: Icons.dashboard_customize_outlined,
          label: (language) => tr(language, 'Home', 'होम'),
          builder: () => const CustomerOverviewPage(),
        ),
        _RolePage(
          icon: Icons.work_history_outlined,
          label: (language) => tr(language, 'Jobs', 'जॉब्स'),
          builder: () => const CustomerJobsPage(),
        ),
        _RolePage(
          icon: Icons.support_agent_outlined,
          label: (language) => tr(language, 'Support', 'सहायता'),
          builder: () => const ProfileSupportPage(),
        ),
      ];
    case UserRole.worker:
      return <_RolePage>[
        _RolePage(
          icon: Icons.dashboard_outlined,
          label: (language) => tr(language, 'Dashboard', 'डैशबोर्ड'),
          builder: () => const WorkerOverviewPage(),
        ),
        _RolePage(
          icon: Icons.assignment_outlined,
          label: (language) => tr(language, 'My Jobs', 'मेरे जॉब्स'),
          builder: () => const WorkerJobsPage(),
        ),
        _RolePage(
          icon: Icons.account_circle_outlined,
          label: (language) => tr(language, 'Profile', 'प्रोफाइल'),
          builder: () => const ProfileSupportPage(),
        ),
      ];
    case UserRole.approver:
      return <_RolePage>[
        _RolePage(
          icon: Icons.storefront_outlined,
          label: (language) => tr(language, 'Shop', 'दुकान'),
          builder: () => const ApproverOverviewPage(),
        ),
        _RolePage(
          icon: Icons.fact_check_outlined,
          label: (language) => tr(language, 'Approvals', 'अप्रूवल'),
          builder: () => const ApproverApprovalsPage(),
        ),
        _RolePage(
          icon: Icons.support_agent_outlined,
          label: (language) => tr(language, 'Support', 'सहायता'),
          builder: () => const ProfileSupportPage(),
        ),
      ];
    case UserRole.admin:
      return <_RolePage>[
        _RolePage(
          icon: Icons.admin_panel_settings_outlined,
          label: (language) => tr(language, 'Overview', 'ओवरव्यू'),
          builder: () => const AdminOverviewPage(),
        ),
        _RolePage(
          icon: Icons.verified_user_outlined,
          label: (language) => tr(language, 'Moderation', 'प्रबंधन'),
          builder: () => const AdminModerationPage(),
        ),
        _RolePage(
          icon: Icons.report_problem_outlined,
          label: (language) => tr(language, 'Complaints', 'शिकायतें'),
          builder: () => const AdminComplaintsPage(),
        ),
      ];
  }
}

class CustomerOverviewPage extends StatelessWidget {
  const CustomerOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final language = app.language;
    final user = app.currentUser!;
    final stores = app.nearbyHardwareStoresFor(user);
    final workers = app.nearbyWorkersFor(user);
    final jobs = app.jobsForCustomer(user.id);
    final activeCount = jobs
        .where((job) => job.status != JobStatus.closed)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: <Widget>[
          HeroCard(
            title: tr(
              language,
              'Trusted local help at your pincode',
              'आपके पिनकोड पर भरोसेमंद स्थानीय मदद',
            ),
            subtitle: tr(
              language,
              'See nearby workers, top hardware stores and track every request from one place.',
              'नजदीकी कामगार, हार्डवेयर स्टोर और हर रिक्वेस्ट की प्रगति एक ही जगह देखें।',
            ),
            chips: <String>[
              '${jobs.length} ${tr(language, 'jobs', 'जॉब्स')}',
              '${workers.length} ${tr(language, 'workers', 'कामगार')}',
              '${stores.length} ${tr(language, 'shops', 'दुकानें')}',
            ],
            colorA: const Color(0xFFEF6C32),
            colorB: const Color(0xFFFFB648),
            action: FilledButton.icon(
              onPressed: () => showPostJobSheet(context),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(tr(language, 'Post a job', 'जॉब पोस्ट करें')),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: MetricCard(
                  title: tr(language, 'Open requests', 'खुले रिक्वेस्ट'),
                  value: '$activeCount',
                  icon: Icons.pending_actions_outlined,
                  color: const Color(0xFF5F3BFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  title: tr(language, 'Preferred stores', 'पसंदीदा दुकानें'),
                  value:
                      '${stores.where((item) => item.preferredListing).length}',
                  icon: Icons.workspace_premium_outlined,
                  color: const Color(0xFF008B7B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: tr(
              language,
              'Hardware stores in your area',
              'आपके इलाके की हार्डवेयर दुकानें',
            ),
            subtitle: tr(
              language,
              'Preferred stores are shown first.',
              'पसंदीदा दुकानें सबसे ऊपर दिखाई जाती हैं।',
            ),
            child: Column(
              children: stores.isEmpty
                  ? <Widget>[
                      EmptyMessage(
                        message: tr(
                          language,
                          'No stores in your pincode yet.',
                          'आपके पिनकोड में अभी कोई दुकान नहीं है।',
                        ),
                      ),
                    ]
                  : stores.map((store) => StoreTile(store: store)).toList(),
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: tr(language, 'Available workers', 'उपलब्ध कामगार'),
            subtitle: tr(
              language,
              'Verified workers matched using your pincode.',
              'आपके पिनकोड के अनुसार सत्यापित कामगार।',
            ),
            child: Column(
              children: workers.isEmpty
                  ? <Widget>[
                      EmptyMessage(
                        message: tr(
                          language,
                          'No verified workers are available right now.',
                          'अभी कोई सत्यापित कामगार उपलब्ध नहीं है।',
                        ),
                      ),
                    ]
                  : workers
                        .map((worker) => WorkerTile(worker: worker))
                        .toList(),
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: tr(
              language,
              'Live request tracking',
              'लाइव रिक्वेस्ट ट्रैकिंग',
            ),
            subtitle: tr(
              language,
              'Watch job progress from request to payment.',
              'रिक्वेस्ट से पेमेंट तक जॉब की स्थिति देखें।',
            ),
            actionLabel: tr(language, 'See all jobs', 'सभी जॉब्स देखें'),
            onAction: () {},
            child: Column(
              children: jobs.take(3).isEmpty
                  ? <Widget>[
                      EmptyMessage(
                        message: tr(
                          language,
                          'No jobs posted yet.',
                          'अभी तक कोई जॉब पोस्ट नहीं हुई।',
                        ),
                      ),
                    ]
                  : jobs
                        .take(3)
                        .map((job) => JobCard(job: job, role: user.role))
                        .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerJobsPage extends StatelessWidget {
  const CustomerJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final language = app.language;
    final user = app.currentUser!;
    final jobs = app.jobsForCustomer(user.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => showPostJobSheet(context),
              icon: const Icon(Icons.add),
              label: Text(tr(language, 'Post new job', 'नई जॉब पोस्ट करें')),
            ),
          ),
          const SizedBox(height: 12),
          if (jobs.isEmpty)
            EmptyMessage(
              message: tr(
                language,
                'Start by posting your first service request.',
                'अपनी पहली सेवा रिक्वेस्ट पोस्ट करें।',
              ),
            )
          else
            ...jobs.map((job) {
              return DetailedJobCard(
                job: job,
                role: user.role,
                trailing: job.status == JobStatus.paymentPending
                    ? FilledButton(
                        onPressed: () => showCustomerPaymentSheet(context, job),
                        child: Text(tr(language, 'Pay now', 'अब भुगतान करें')),
                      )
                    : null,
              );
            }),
        ],
      ),
    );
  }
}

class WorkerOverviewPage extends StatelessWidget {
  const WorkerOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final language = app.language;
    final user = app.currentUser!;
    final linkedStore = app.allUsers
        .where((item) => item.id == user.linkedApproverId)
        .firstOrNull;
    final availableJobs = app.availableJobsForWorker(user);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: <Widget>[
          HeroCard(
            title: tr(
              language,
              'Ready to take work in your area',
              'अपने इलाके में काम लेने के लिए तैयार',
            ),
            subtitle: tr(
              language,
              'Accept matching jobs, track earnings, and pay monthly commission before the due date.',
              'मेल खाते जॉब स्वीकार करें, कमाई ट्रैक करें और समय पर मासिक कमीशन जमा करें।',
            ),
            chips: <String>[
              user.trade ?? tr(language, 'General worker', 'सामान्य कामगार'),
              user.isVerified
                  ? tr(language, 'Verified', 'सत्यापित')
                  : tr(language, 'Pending approval', 'अप्रूवल लंबित'),
              user.isSuspended
                  ? tr(language, 'Suspended', 'निलंबित')
                  : tr(language, 'Active', 'सक्रिय'),
            ],
            colorA: const Color(0xFF5F3BFF),
            colorB: const Color(0xFF8E67FF),
            action: user.commissionDue > 0
                ? FilledButton.icon(
                    onPressed: () => showCommissionPaymentSheet(context),
                    icon: const Icon(Icons.currency_rupee),
                    label: Text(
                      tr(language, 'Pay commission', 'कमीशन जमा करें'),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: MetricCard(
                  title: tr(language, 'Total earned', 'कुल कमाई'),
                  value: formatCurrency(user.totalEarned),
                  icon: Icons.payments_outlined,
                  color: const Color(0xFF008B7B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  title: tr(language, 'Commission due', 'बकाया कमीशन'),
                  value: formatCurrency(user.commissionDue),
                  icon: Icons.account_balance_wallet_outlined,
                  color: const Color(0xFFEF6C32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: tr(
              language,
              'Linked hardware store',
              'जुड़ी हुई हार्डवेयर दुकान',
            ),
            subtitle: tr(
              language,
              'Approver assigned using your pincode.',
              'आपके पिनकोड के आधार पर जुड़ा अप्रूवर।',
            ),
            child: linkedStore == null
                ? EmptyMessage(
                    message: tr(
                      language,
                      'No store linked yet.',
                      'अभी कोई दुकान लिंक नहीं है।',
                    ),
                  )
                : StoreTile(store: linkedStore),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: tr(
              language,
              'Jobs you can accept',
              'जॉब्स जिन्हें आप स्वीकार कर सकते हैं',
            ),
            subtitle: tr(
              language,
              'These jobs match your pincode and category.',
              'ये जॉब्स आपके पिनकोड और श्रेणी से मेल खाते हैं।',
            ),
            child: Column(
              children: availableJobs.isEmpty
                  ? <Widget>[
                      EmptyMessage(
                        message: tr(
                          language,
                          'No matching jobs are available right now.',
                          'अभी कोई मेल खाती जॉब उपलब्ध नहीं है।',
                        ),
                      ),
                    ]
                  : availableJobs.map((job) {
                      return DetailedJobCard(
                        job: job,
                        role: user.role,
                        trailing: user.isVerified && !user.isSuspended
                            ? FilledButton(
                                onPressed: () =>
                                    context.read<AppState>().acceptJob(job.id),
                                child: Text(
                                  tr(
                                    language,
                                    'Accept job',
                                    'जॉब स्वीकार करें',
                                  ),
                                ),
                              )
                            : OutlinedButton(
                                onPressed: null,
                                child: Text(
                                  tr(
                                    language,
                                    'Approval needed',
                                    'अप्रूवल जरूरी',
                                  ),
                                ),
                              ),
                      );
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerJobsPage extends StatelessWidget {
  const WorkerJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final language = app.language;
    final user = app.currentUser!;
    final jobs = app.jobsForWorker(user.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: jobs.isEmpty
            ? <Widget>[
                EmptyMessage(
                  message: tr(
                    language,
                    'Your accepted jobs will appear here.',
                    'आपके स्वीकार किए गए जॉब्स यहां दिखेंगे।',
                  ),
                ),
              ]
            : jobs.map((job) {
                Widget? trailing;
                if (job.status == JobStatus.accepted) {
                  trailing = FilledButton(
                    onPressed: () => context.read<AppState>().updateJobStatus(
                      job.id,
                      JobStatus.inProgress,
                    ),
                    child: Text(tr(language, 'Start job', 'जॉब शुरू करें')),
                  );
                } else if (job.status == JobStatus.inProgress) {
                  trailing = Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      OutlinedButton(
                        onPressed: () => showStoreBillSheet(context, job),
                        child: Text(
                          tr(language, 'Upload bill', 'बिल अपलोड करें'),
                        ),
                      ),
                      FilledButton(
                        onPressed: () => context
                            .read<AppState>()
                            .updateJobStatus(job.id, JobStatus.paymentPending),
                        child: Text(
                          tr(language, 'Mark complete', 'पूरा दिखाएं'),
                        ),
                      ),
                    ],
                  );
                } else if (job.status == JobStatus.paymentPending) {
                  trailing = OutlinedButton(
                    onPressed: () => showInternalStoreReviewSheet(context, job),
                    child: Text(tr(language, 'Store note', 'स्टोर नोट')),
                  );
                }

                return DetailedJobCard(
                  job: job,
                  role: user.role,
                  trailing: trailing,
                );
              }).toList(),
      ),
    );
  }
}

class ApproverOverviewPage extends StatelessWidget {
  const ApproverOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final language = app.language;
    final user = app.currentUser!;
    final linkedWorkers = app.linkedWorkersForApprover(user);
    final jobs = app.jobsForApprover(user);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: <Widget>[
          HeroCard(
            title: tr(
              language,
              user.shopName ?? 'Hardware store',
              user.shopName ?? 'हार्डवेयर दुकान',
            ),
            subtitle: tr(
              language,
              'Approve workers, upload material bills and activate preferred listing for more visibility.',
              'कामगारों को अप्रूव करें, सामग्री बिल अपलोड करें और अधिक दृश्यता के लिए प्रीफर्ड लिस्टिंग चालू करें।',
            ),
            chips: <String>[
              user.preferredListing
                  ? tr(language, 'Preferred shop', 'पसंदीदा दुकान')
                  : tr(language, 'Free listing', 'फ्री लिस्टिंग'),
              '${linkedWorkers.length} ${tr(language, 'workers', 'कामगार')}',
              '${jobs.length} ${tr(language, 'orders', 'ऑर्डर')}',
            ],
            colorA: const Color(0xFF008B7B),
            colorB: const Color(0xFF00B7A4),
            action: user.preferredListing
                ? null
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      FilledButton(
                        onPressed: () => context
                            .read<AppState>()
                            .activatePreferredListing('Monthly'),
                        child: const Text('Rs. 199 / month'),
                      ),
                      OutlinedButton(
                        onPressed: () => context
                            .read<AppState>()
                            .activatePreferredListing('Annual'),
                        child: const Text('Rs. 1800 / year'),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: MetricCard(
                  title: tr(
                    language,
                    'Parts sales tracked',
                    'पार्ट्स बिक्री कमाई',
                  ),
                  value: formatCurrency(user.totalShopEarnings),
                  icon: Icons.show_chart_outlined,
                  color: const Color(0xFFEF6C32),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  title: tr(language, 'Linked workers', 'जुड़े कामगार'),
                  value: '${linkedWorkers.length}',
                  icon: Icons.groups_outlined,
                  color: const Color(0xFF5F3BFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: tr(language, 'Linked workers', 'जुड़े हुए कामगार'),
            subtitle: tr(
              language,
              'These workers are attached to your store for trust and materials flow.',
              'ये कामगार भरोसे और सामग्री व्यवस्था के लिए आपकी दुकान से जुड़े हैं।',
            ),
            child: Column(
              children: linkedWorkers.isEmpty
                  ? <Widget>[
                      EmptyMessage(
                        message: tr(
                          language,
                          'No workers linked yet.',
                          'अभी कोई कामगार लिंक नहीं है।',
                        ),
                      ),
                    ]
                  : linkedWorkers
                        .map((worker) => WorkerTile(worker: worker))
                        .toList(),
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: tr(
              language,
              'Orders received through Shramik',
              'श्रमिक से प्राप्त ऑर्डर',
            ),
            subtitle: tr(
              language,
              'Upload store bills to keep pricing transparent.',
              'मूल्य पारदर्शिता के लिए स्टोर बिल अपलोड करें।',
            ),
            child: Column(
              children: jobs.isEmpty
                  ? <Widget>[
                      EmptyMessage(
                        message: tr(
                          language,
                          'No orders yet.',
                          'अभी कोई ऑर्डर नहीं है।',
                        ),
                      ),
                    ]
                  : jobs.map((job) {
                      return DetailedJobCard(
                        job: job,
                        role: user.role,
                        trailing: OutlinedButton(
                          onPressed: () => showStoreBillSheet(context, job),
                          child: Text(
                            tr(language, 'Upload bill', 'बिल अपलोड करें'),
                          ),
                        ),
                      );
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class ApproverApprovalsPage extends StatelessWidget {
  const ApproverApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final language = app.language;
    final user = app.currentUser!;
    final pendingWorkers = app.pendingWorkersForApprover(user);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SectionCard(
        title: tr(
          language,
          'Approve workers in your pincode',
          'अपने पिनकोड के कामगार अप्रूव करें',
        ),
        subtitle: tr(
          language,
          'Review documents and approve genuine workers for trust.',
          'दस्तावेज़ देखकर भरोसेमंद कामगारों को अप्रूव करें।',
        ),
        child: Column(
          children: pendingWorkers.isEmpty
              ? <Widget>[
                  EmptyMessage(
                    message: tr(
                      language,
                      'No pending worker approvals.',
                      'कोई लंबित कामगार अप्रूवल नहीं है।',
                    ),
                  ),
                ]
              : pendingWorkers.map((worker) {
                  return WorkerTile(
                    worker: worker,
                    action: FilledButton(
                      onPressed: () => context.read<AppState>().approveWorker(
                        worker.id,
                        approverId: user.id,
                      ),
                      child: Text(tr(language, 'Approve', 'अप्रूव करें')),
                    ),
                  );
                }).toList(),
        ),
      ),
    );
  }
}

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final language = app.language;
    final totalUsers = app.allUsers.length;
    final totalJobs = app.allJobs.length;
    final totalComplaints = app.complaints.length;
    final pendingWorkers = app.pendingWorkersForAdmin();
    final pendingCommission = app.pendingCommissionSubmissions();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: <Widget>[
          HeroCard(
            title: tr(language, 'Shramik control room', 'श्रमिक कंट्रोल रूम'),
            subtitle: tr(
              language,
              'Manage worker verification, commission proof, complaints and account health from one dashboard.',
              'एक ही डैशबोर्ड से वेरिफिकेशन, कमीशन प्रूफ, शिकायतें और अकाउंट हेल्थ संभालें।',
            ),
            chips: <String>[
              '$totalUsers ${tr(language, 'users', 'यूजर्स')}',
              '$totalJobs ${tr(language, 'jobs', 'जॉब्स')}',
              '$totalComplaints ${tr(language, 'complaints', 'शिकायतें')}',
            ],
            colorA: const Color(0xFF1E1C38),
            colorB: const Color(0xFF463A74),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: MetricCard(
                  title: tr(
                    language,
                    'Pending worker approvals',
                    'लंबित कामगार अप्रूवल',
                  ),
                  value: '${pendingWorkers.length}',
                  icon: Icons.verified_user_outlined,
                  color: const Color(0xFFEF6C32),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: MetricCard(
                  title: tr(
                    language,
                    'Pending commission proofs',
                    'लंबित कमीशन प्रूफ',
                  ),
                  value: '${pendingCommission.length}',
                  icon: Icons.receipt_long_outlined,
                  color: const Color(0xFF008B7B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: tr(language, 'Review queue', 'रिव्यू कतार'),
            subtitle: tr(
              language,
              'Most important items that need admin action.',
              'सबसे जरूरी आइटम जिन पर एडमिन कार्रवाई चाहिए।',
            ),
            child: Column(
              children: <Widget>[
                ...pendingWorkers
                    .take(3)
                    .map((worker) => WorkerTile(worker: worker)),
                ...pendingCommission
                    .take(3)
                    .map(
                      (submission) => CommissionTile(submission: submission),
                    ),
                if (pendingWorkers.isEmpty && pendingCommission.isEmpty)
                  EmptyMessage(
                    message: tr(
                      language,
                      'All queues are clear.',
                      'सभी कतारें साफ हैं।',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminModerationPage extends StatelessWidget {
  const AdminModerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final language = app.language;
    final workers = app.allWorkers();
    final submissions = app.pendingCommissionSubmissions();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: <Widget>[
          SectionCard(
            title: tr(language, 'Worker moderation', 'कामगार प्रबंधन'),
            subtitle: tr(
              language,
              'Approve, suspend or reactivate workers.',
              'कामगारों को अप्रूव, निलंबित या पुनः सक्रिय करें।',
            ),
            child: Column(
              children: workers.map((worker) {
                return WorkerTile(
                  worker: worker,
                  action: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      if (!worker.isVerified)
                        FilledButton(
                          onPressed: () =>
                              context.read<AppState>().approveWorker(worker.id),
                          child: Text(tr(language, 'Approve', 'अप्रूव करें')),
                        ),
                      OutlinedButton(
                        onPressed: () =>
                            context.read<AppState>().toggleWorkerSuspension(
                              worker.id,
                              !worker.isSuspended,
                            ),
                        child: Text(
                          worker.isSuspended
                              ? tr(language, 'Reactivate', 'फिर से सक्रिय करें')
                              : tr(language, 'Suspend', 'निलंबित करें'),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: tr(language, 'Commission submissions', 'कमीशन सबमिशन'),
            subtitle: tr(
              language,
              'Approve worker payment proofs after checking transaction details.',
              'लेनदेन विवरण देखकर कामगार के भुगतान प्रूफ अप्रूव करें।',
            ),
            child: Column(
              children: submissions.isEmpty
                  ? <Widget>[
                      EmptyMessage(
                        message: tr(
                          language,
                          'No pending commission submissions.',
                          'कोई लंबित कमीशन सबमिशन नहीं है।',
                        ),
                      ),
                    ]
                  : submissions.map((submission) {
                      return CommissionTile(
                        submission: submission,
                        action: FilledButton(
                          onPressed: () => context
                              .read<AppState>()
                              .approveCommissionSubmission(submission.id),
                          child: Text(
                            tr(
                              language,
                              'Approve payment',
                              'भुगतान अप्रूव करें',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminComplaintsPage extends StatelessWidget {
  const AdminComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final language = app.language;
    final internalReviews = app.allJobs
        .where((job) => (job.internalStoreReview ?? '').trim().isNotEmpty)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: <Widget>[
          SectionCard(
            title: tr(language, 'Complaint log', 'शिकायत रिकॉर्ड'),
            subtitle: tr(
              language,
              'WhatsApp complaint drafts are also stored inside the app log.',
              'व्हाट्सऐप शिकायत ड्राफ्ट ऐप लॉग में भी सेव होते हैं।',
            ),
            child: Column(
              children: app.complaints.isEmpty
                  ? <Widget>[
                      EmptyMessage(
                        message: tr(
                          language,
                          'No complaints yet.',
                          'अभी कोई शिकायत नहीं है।',
                        ),
                      ),
                    ]
                  : app.complaints
                        .map((item) => ComplaintTile(item: item))
                        .toList(),
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: tr(
              language,
              'Private worker notes on stores',
              'दुकानों पर निजी कामगार नोट्स',
            ),
            subtitle: tr(
              language,
              'Visible only to admin for monitoring approver quality.',
              'अप्रूवर गुणवत्ता देखने के लिए केवल एडमिन को दिखता है।',
            ),
            child: Column(
              children: internalReviews.isEmpty
                  ? <Widget>[
                      EmptyMessage(
                        message: tr(
                          language,
                          'No private notes submitted yet.',
                          'अभी तक कोई निजी नोट नहीं भेजा गया।',
                        ),
                      ),
                    ]
                  : internalReviews.map((job) {
                      return _NoteTile(job: job);
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSupportPage extends StatelessWidget {
  const ProfileSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final language = app.language;
    final user = app.currentUser!;
    final myComplaints = app.complaints
        .where((item) => item.reporterId == user.id)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: <Widget>[
          SectionCard(
            title: tr(language, 'Profile summary', 'प्रोफाइल सारांश'),
            subtitle: tr(
              language,
              'Core account and locality details.',
              'मुख्य अकाउंट और इलाके की जानकारी।',
            ),
            child: Column(
              children: <Widget>[
                InfoRow(label: tr(language, 'Name', 'नाम'), value: user.name),
                InfoRow(
                  label: tr(language, 'Role', 'भूमिका'),
                  value: roleLabel(language, user.role),
                ),
                InfoRow(
                  label: tr(language, 'Email', 'ईमेल'),
                  value: user.email,
                ),
                InfoRow(label: tr(language, 'Phone', 'फोन'), value: user.phone),
                InfoRow(
                  label: tr(language, 'Address', 'पता'),
                  value: user.address,
                ),
                InfoRow(
                  label: tr(language, 'Pincode', 'पिनकोड'),
                  value: user.pincode,
                ),
                if (user.upiId != null)
                  InfoRow(
                    label: tr(language, 'UPI ID', 'यूपीआई आईडी'),
                    value: user.upiId!,
                  ),
                if (user.shopName != null)
                  InfoRow(
                    label: tr(language, 'Shop name', 'दुकान का नाम'),
                    value: user.shopName!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: tr(language, 'Complaint support', 'शिकायत सहायता'),
            subtitle: tr(
              language,
              'Create a structured complaint and open it in WhatsApp.',
              'संरचित शिकायत बनाएं और उसे व्हाट्सऐप में खोलें।',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () => showComplaintSheet(context),
                  icon: const Icon(Icons.chat_outlined),
                  label: Text(
                    tr(
                      language,
                      'Raise complaint on WhatsApp',
                      'व्हाट्सऐप पर शिकायत करें',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (myComplaints.isEmpty)
                  EmptyMessage(
                    message: tr(
                      language,
                      'No complaints raised yet.',
                      'अभी तक कोई शिकायत दर्ज नहीं की गई है।',
                    ),
                  )
                else
                  ...myComplaints.map((item) => ComplaintTile(item: item)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final language = app.language;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF1E1C38), Color(0xFF5F3BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  children: <Widget>[
                    const ShramikLogo(size: 58),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${roleLabel(language, user.role)} • ${user.pincode}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(tr(language, 'Language', 'भाषा')),
              trailing: _LanguageToggle(language: language),
            ),
            ListTile(
              leading: Icon(
                app.isUsingFirebase ? Icons.cloud_done_outlined : Icons.storage,
              ),
              title: Text(tr(language, 'Backend mode', 'बैकएंड मोड')),
              subtitle: Text(
                app.isUsingFirebase
                    ? tr(language, 'Firebase live sync', 'Firebase लाइव सिंक')
                    : tr(language, 'Local demo storage', 'लोकल डेमो स्टोरेज'),
              ),
            ),
            if (user.role == UserRole.worker && user.commissionDue > 0)
              ListTile(
                leading: const Icon(Icons.currency_rupee_outlined),
                title: Text(tr(language, 'Commission due', 'बकाया कमीशन')),
                subtitle: Text(formatCurrency(user.commissionDue)),
              ),
            if (user.role == UserRole.approver && user.preferredListing)
              ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: Text(
                  tr(language, 'Preferred shop plan', 'पसंदीदा दुकान योजना'),
                ),
                subtitle: Text(user.preferredPlan ?? '-'),
              ),
            if (user.role == UserRole.admin)
              ListTile(
                leading: const Icon(Icons.restart_alt_outlined),
                title: Text(
                  app.isUsingFirebase
                      ? tr(
                          language,
                          'Seed sample backend data',
                          'सैंपल बैकएंड डेटा डालें',
                        )
                      : tr(language, 'Reset demo data', 'डेमो डेटा रीसेट करें'),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await context.read<AppState>().resetDemoData();
                },
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await context.read<AppState>().logout();
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: const Icon(Icons.logout),
                label: Text(tr(language, 'Logout', 'लॉगआउट')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.colorA,
    required this.colorB,
    this.action,
  });

  final String title;
  final String subtitle;
  final List<String> chips;
  final Color colorA;
  final Color colorB;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[colorA, colorB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, height: 1.45),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (chip) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      chip,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
          ),
          if (action != null) ...<Widget>[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Color(0xFF6A667C))),
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: themeTitle(context)),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF6A667C),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (actionLabel != null && onAction != null)
                  TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class StoreTile extends StatelessWidget {
  const StoreTile({super.key, required this.store});

  final AppUser store;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppState>().language;
    return _SurfaceTile(
      title: store.shopName ?? store.name,
      subtitle: '${store.address} • ${store.phone}',
      leading: const Icon(Icons.storefront_outlined),
      badges: <String>[
        if (store.preferredListing)
          tr(language, 'Preferred shop', 'पसंदीदा दुकान'),
        store.pincode,
      ],
    );
  }
}

class WorkerTile extends StatelessWidget {
  const WorkerTile({super.key, required this.worker, this.action});

  final AppUser worker;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppState>().language;
    return _SurfaceTile(
      title: worker.name,
      subtitle: '${worker.trade ?? '-'} • ${worker.phone}',
      leading: const Icon(Icons.engineering_outlined),
      badges: <String>[
        worker.isVerified
            ? tr(language, 'Verified', 'सत्यापित')
            : tr(language, 'Pending', 'लंबित'),
        if (worker.isSuspended) tr(language, 'Suspended', 'निलंबित'),
        worker.pincode,
      ],
      trailing: action,
      footer: worker.upiId == null ? null : 'UPI: ${worker.upiId}',
    );
  }
}

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, required this.role});

  final JobRequest job;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return _SurfaceTile(
      title: job.title,
      subtitle: '${job.category} • ${formatCurrency(job.budget)}',
      leading: const Icon(Icons.work_outline),
      badges: <String>[
        jobStatusLabel(context.watch<AppState>().language, job.status),
        job.pincode,
      ],
      footer: job.description,
    );
  }
}

class DetailedJobCard extends StatelessWidget {
  const DetailedJobCard({
    super.key,
    required this.job,
    required this.role,
    this.trailing,
  });

  final JobRequest job;
  final UserRole role;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppState>().language;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(job.title, style: themeTitle(context)),
                      const SizedBox(height: 6),
                      Text(
                        '${job.category} • ${formatCurrency(job.budget)}',
                        style: const TextStyle(color: Color(0xFF6A667C)),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: job.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(job.description, style: const TextStyle(height: 1.45)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 14,
              runSpacing: 10,
              children: <Widget>[
                _MiniInfo(
                  icon: Icons.pin_drop_outlined,
                  label: '${job.pincode} • ${job.address}',
                ),
                _MiniInfo(
                  icon: Icons.schedule_outlined,
                  label: formatDate(job.updatedAt),
                ),
                if (job.workerName != null)
                  _MiniInfo(
                    icon: Icons.person_outline,
                    label: '${job.workerName} • ${job.workerPhone ?? '-'}',
                  ),
                if (job.workerUpiId != null)
                  _MiniInfo(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'UPI: ${job.workerUpiId}',
                  ),
                if (job.storeBillPath != null)
                  _MiniInfo(
                    icon: Icons.receipt_long_outlined,
                    label: fileNameFromPath(job.storeBillPath!),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            StatusTimeline(status: job.status),
            if (job.feedback != null) ...<Widget>[
              const SizedBox(height: 14),
              InfoRow(
                label: tr(language, 'Feedback', 'फीडबैक'),
                value: job.feedback!,
              ),
            ],
            if (job.paymentTransactionId != null) ...<Widget>[
              InfoRow(
                label: tr(language, 'Transaction ID', 'ट्रांजैक्शन आईडी'),
                value: job.paymentTransactionId!,
              ),
            ],
            if (trailing != null) ...<Widget>[
              const SizedBox(height: 14),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.status});

  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppState>().language;
    final statuses = <JobStatus>[
      JobStatus.open,
      JobStatus.accepted,
      JobStatus.inProgress,
      JobStatus.paymentPending,
      JobStatus.closed,
    ];
    final activeIndex = statuses.indexOf(status);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List<Widget>.generate(statuses.length, (index) {
        final item = statuses[index];
        final active = index <= activeIndex;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? statusColor(item).withValues(alpha: 0.14)
                : const Color(0xFFF3F2F7),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            jobStatusLabel(language, item),
            style: TextStyle(
              color: active ? statusColor(item) : const Color(0xFF827E92),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppState>().language;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor(status).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        jobStatusLabel(language, status),
        style: TextStyle(
          color: statusColor(status),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class CommissionTile extends StatelessWidget {
  const CommissionTile({super.key, required this.submission, this.action});

  final CommissionSubmission submission;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppState>().language;
    return _SurfaceTile(
      title: submission.workerName,
      subtitle:
          '${formatCurrency(submission.amount)} • ${submission.transactionId}',
      leading: const Icon(Icons.receipt_long_outlined),
      badges: <String>[
        tr(
          language,
          enumName(submission.status).toUpperCase(),
          enumName(submission.status).toUpperCase(),
        ),
        formatDate(submission.submittedAt),
      ],
      footer: fileNameFromPath(submission.screenshotPath),
      trailing: action,
    );
  }
}

class ComplaintTile extends StatelessWidget {
  const ComplaintTile({super.key, required this.item});

  final ComplaintRecord item;

  @override
  Widget build(BuildContext context) {
    return _SurfaceTile(
      title: '${item.reporterName} -> ${item.againstLabel}',
      subtitle: item.category,
      leading: const Icon(Icons.report_problem_outlined),
      badges: <String>[formatDate(item.createdAt)],
      footer: item.message,
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF6A667C),
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xFF6A667C))),
    );
  }
}

class ShramikLogo extends StatelessWidget {
  const ShramikLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF5F3BFF).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.14),
      child: SvgPicture.asset('assets/logo/shramik_mark.svg'),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButton<AppLanguage>(
            value: language,
            items: const <DropdownMenuItem<AppLanguage>>[
              DropdownMenuItem(
                value: AppLanguage.english,
                child: Text('English'),
              ),
              DropdownMenuItem(value: AppLanguage.hindi, child: Text('हिंदी')),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<AppState>().updateLanguage(value);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _DemoChip extends StatelessWidget {
  const _DemoChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}

class _FilePickerTile extends StatelessWidget {
  const _FilePickerTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: const Color(0xFFF3F2F7),
              foregroundColor: const Color(0xFF5F3BFF),
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value == null
                        ? 'Tap to choose a file'
                        : fileNameFromPath(value!),
                    style: const TextStyle(color: Color(0xFF6A667C)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.upload_file_outlined),
          ],
        ),
      ),
    );
  }
}

class _SurfaceTile extends StatelessWidget {
  const _SurfaceTile({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.badges,
    this.trailing,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget leading;
  final List<String> badges;
  final Widget? trailing;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FB),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5F3BFF),
                child: leading,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF6A667C)),
                    ),
                  ],
                ),
              ),
              ...?(trailing == null ? null : <Widget>[trailing!]),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges
                .where((badge) => badge.trim().isNotEmpty)
                .map(
                  (badge) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (footer != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              footer!,
              style: const TextStyle(color: Color(0xFF444156), height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: const Color(0xFF6A667C)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Color(0xFF6A667C))),
      ],
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.job});

  final JobRequest job;

  @override
  Widget build(BuildContext context) {
    return _SurfaceTile(
      title: job.title,
      subtitle: '${job.workerName ?? '-'} • ${job.approverId ?? '-'}',
      leading: const Icon(Icons.note_alt_outlined),
      badges: <String>[formatDate(job.updatedAt)],
      footer: job.internalStoreReview,
    );
  }
}

class _RolePage {
  const _RolePage({
    required this.icon,
    required this.label,
    required this.builder,
  });

  final IconData icon;
  final String Function(AppLanguage language) label;
  final Widget Function() builder;
}

Future<void> showPostJobSheet(BuildContext context) async {
  final app = context.read<AppState>();
  final language = app.language;
  final user = app.currentUser!;
  final title = TextEditingController();
  final description = TextEditingController();
  final address = TextEditingController(text: user.address);
  final pincode = TextEditingController(text: user.pincode);
  final budget = TextEditingController();
  var category = serviceCategories.first;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tr(language, 'Post a new job', 'नई जॉब पोस्ट करें'),
                    style: themeTitle(context),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: title,
                    decoration: InputDecoration(
                      labelText: tr(language, 'Job title', 'जॉब शीर्षक'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    items: serviceCategories
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => category = value);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: tr(language, 'Category', 'श्रेणी'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: description,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: tr(language, 'Description', 'विवरण'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: address,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: tr(language, 'Address', 'पता'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pincode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: tr(language, 'Pincode', 'पिनकोड'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: budget,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: tr(language, 'Budget amount', 'बजट राशि'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () async {
                      final parsedBudget = double.tryParse(budget.text.trim());
                      if (title.text.trim().isEmpty ||
                          description.text.trim().isEmpty ||
                          parsedBudget == null) {
                        showSnack(
                          context,
                          tr(
                            language,
                            'Please complete all required fields.',
                            'कृपया सभी जरूरी जानकारी भरें।',
                          ),
                        );
                        return;
                      }
                      await app.postJob(
                        title: title.text.trim(),
                        category: category,
                        description: description.text.trim(),
                        address: address.text.trim(),
                        pincode: pincode.text.trim(),
                        budget: parsedBudget,
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(
                      tr(language, 'Submit request', 'रिक्वेस्ट सबमिट करें'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> showCustomerPaymentSheet(
  BuildContext context,
  JobRequest job,
) async {
  final app = context.read<AppState>();
  final language = app.language;
  final transactionId = TextEditingController();
  final feedback = TextEditingController();
  String? screenshotPath;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tr(
                      language,
                      'Complete worker payment',
                      'कामगार का भुगतान पूरा करें',
                    ),
                    style: themeTitle(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'UPI: ${job.workerUpiId ?? '-'}',
                    style: const TextStyle(color: Color(0xFF6A667C)),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: job.workerUpiId == null
                        ? null
                        : () => openUpiPayment(
                            context,
                            upiId: job.workerUpiId!,
                            name: job.workerName ?? 'Worker',
                            amount: job.budget,
                            note: job.title,
                          ),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(
                      tr(language, 'Open UPI app', 'यूपीआई ऐप खोलें'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: transactionId,
                    decoration: InputDecoration(
                      labelText: tr(
                        language,
                        'Transaction ID',
                        'ट्रांजैक्शन आईडी',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: feedback,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: tr(
                        language,
                        'Feedback for worker',
                        'कामगार के लिए फीडबैक',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FilePickerTile(
                    icon: Icons.image_outlined,
                    title: tr(
                      language,
                      'Payment screenshot',
                      'पेमेंट स्क्रीनशॉट',
                    ),
                    value: screenshotPath,
                    onTap: () async {
                      final path = await pickSingleFile(
                        extensions: <String>['jpg', 'jpeg', 'png'],
                      );
                      if (path != null) {
                        setModalState(() => screenshotPath = path);
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () async {
                      if (transactionId.text.trim().isEmpty ||
                          screenshotPath == null) {
                        showSnack(
                          context,
                          tr(
                            language,
                            'Transaction ID and screenshot are required.',
                            'ट्रांजैक्शन आईडी और स्क्रीनशॉट जरूरी है।',
                          ),
                        );
                        return;
                      }
                      await app.submitCustomerPayment(
                        jobId: job.id,
                        transactionId: transactionId.text.trim(),
                        screenshotPath: screenshotPath!,
                        feedback: feedback.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(
                      tr(
                        language,
                        'Submit payment proof',
                        'भुगतान प्रमाण जमा करें',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> showCommissionPaymentSheet(BuildContext context) async {
  final app = context.read<AppState>();
  final language = app.language;
  final transactionId = TextEditingController();
  String? screenshotPath;
  final amount = app.currentUser?.commissionDue ?? 0;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tr(
                      language,
                      'Pay monthly commission',
                      'मासिक कमीशन जमा करें',
                    ),
                    style: themeTitle(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${tr(language, 'Owner UPI ID', 'ओनर यूपीआई आईडी')}: ${AppState.ownerUpiId}',
                    style: const TextStyle(color: Color(0xFF6A667C)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tr(language, 'Amount due', 'बकाया राशि')}: ${formatCurrency(amount)}',
                    style: const TextStyle(color: Color(0xFF6A667C)),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => openUpiPayment(
                      context,
                      upiId: AppState.ownerUpiId,
                      name: 'Shramik Owner',
                      amount: amount,
                      note: 'Worker commission payment',
                    ),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(
                      tr(language, 'Open UPI app', 'यूपीआई ऐप खोलें'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: transactionId,
                    decoration: InputDecoration(
                      labelText: tr(
                        language,
                        'Transaction ID',
                        'ट्रांजैक्शन आईडी',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FilePickerTile(
                    icon: Icons.image_outlined,
                    title: tr(
                      language,
                      'Payment screenshot',
                      'पेमेंट स्क्रीनशॉट',
                    ),
                    value: screenshotPath,
                    onTap: () async {
                      final path = await pickSingleFile(
                        extensions: <String>['jpg', 'jpeg', 'png'],
                      );
                      if (path != null) {
                        setModalState(() => screenshotPath = path);
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () async {
                      if (transactionId.text.trim().isEmpty ||
                          screenshotPath == null) {
                        showSnack(
                          context,
                          tr(
                            language,
                            'Transaction ID and screenshot are required.',
                            'ट्रांजैक्शन आईडी और स्क्रीनशॉट जरूरी है।',
                          ),
                        );
                        return;
                      }
                      await app.submitCommissionPayment(
                        transactionId: transactionId.text.trim(),
                        screenshotPath: screenshotPath!,
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(
                      tr(
                        language,
                        'Submit commission proof',
                        'कमीशन प्रूफ जमा करें',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> showStoreBillSheet(BuildContext context, JobRequest job) async {
  final app = context.read<AppState>();
  final language = app.language;
  String? billPath = job.storeBillPath;

  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.all(18),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  tr(
                    language,
                    'Upload material bill',
                    'सामग्री बिल अपलोड करें',
                  ),
                  style: themeTitle(context),
                ),
                const SizedBox(height: 14),
                _FilePickerTile(
                  icon: Icons.receipt_long_outlined,
                  title: tr(
                    language,
                    'Bill image or PDF',
                    'बिल इमेज या पीडीएफ',
                  ),
                  value: billPath,
                  onTap: () async {
                    final path = await pickSingleFile(
                      extensions: <String>['jpg', 'jpeg', 'png', 'pdf'],
                    );
                    if (path != null) {
                      setModalState(() => billPath = path);
                    }
                  },
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: billPath == null
                      ? null
                      : () async {
                          await app.submitStoreBill(
                            jobId: job.id,
                            billPath: billPath!,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(
                    tr(language, 'Save bill proof', 'बिल प्रूफ सेव करें'),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

Future<void> showInternalStoreReviewSheet(
  BuildContext context,
  JobRequest job,
) async {
  final app = context.read<AppState>();
  final language = app.language;
  final note = TextEditingController(text: job.internalStoreReview);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tr(language, 'Private store note', 'निजी स्टोर नोट'),
              style: themeTitle(context),
            ),
            const SizedBox(height: 8),
            Text(
              tr(
                language,
                'This note is only visible to admin for quality monitoring.',
                'यह नोट केवल एडमिन को दिखेगा।',
              ),
              style: const TextStyle(color: Color(0xFF6A667C)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: note,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: tr(language, 'Describe the issue', 'समस्या बताएं'),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () async {
                if (note.text.trim().isEmpty) {
                  showSnack(
                    context,
                    tr(
                      language,
                      'Please write a short note.',
                      'कृपया छोटा नोट लिखें।',
                    ),
                  );
                  return;
                }
                await app.submitInternalStoreReview(
                  jobId: job.id,
                  note: note.text.trim(),
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(tr(language, 'Submit note', 'नोट जमा करें')),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showComplaintSheet(BuildContext context) async {
  final app = context.read<AppState>();
  final language = app.language;
  final user = app.currentUser!;
  final targets = complaintTargets(app, user);
  String? selectedTargetId = targets.isEmpty ? null : targets.first.id;
  final category = TextEditingController();
  final message = TextEditingController();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tr(language, 'Raise complaint', 'शिकायत दर्ज करें'),
                    style: themeTitle(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(
                      language,
                      'A structured WhatsApp message will be generated using app details.',
                      'ऐप की जानकारी से संरचित व्हाट्सऐप संदेश तैयार होगा।',
                    ),
                    style: const TextStyle(color: Color(0xFF6A667C)),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTargetId,
                    items: targets
                        .map(
                          (target) => DropdownMenuItem<String>(
                            value: target.id,
                            child: Text(
                              '${target.name} (${roleLabel(language, target.role)})',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setModalState(() => selectedTargetId = value),
                    decoration: InputDecoration(
                      labelText: tr(
                        language,
                        'Complaint against',
                        'किसके खिलाफ शिकायत',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: category,
                    decoration: InputDecoration(
                      labelText: tr(
                        language,
                        'Complaint type',
                        'शिकायत प्रकार',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: message,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: tr(
                        language,
                        'Complaint details',
                        'शिकायत विवरण',
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: selectedTargetId == null
                        ? null
                        : () async {
                            final target = targets.firstWhere(
                              (item) => item.id == selectedTargetId,
                            );
                            if (category.text.trim().isEmpty ||
                                message.text.trim().isEmpty) {
                              showSnack(
                                context,
                                tr(
                                  language,
                                  'Please fill complaint type and details.',
                                  'कृपया शिकायत प्रकार और विवरण भरें।',
                                ),
                              );
                              return;
                            }
                            await app.addComplaint(
                              againstId: target.id,
                              againstLabel: target.shopName ?? target.name,
                              category: category.text.trim(),
                              message: message.text.trim(),
                            );
                            final latest = app.complaints.first;
                            if (!context.mounted) {
                              return;
                            }
                            Navigator.of(context).pop();
                            await openWhatsAppComplaint(
                              context,
                              latest.whatsAppMessage,
                            );
                          },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(
                      tr(
                        language,
                        'Create WhatsApp complaint',
                        'व्हाट्सऐप शिकायत बनाएं',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

List<AppUser> complaintTargets(AppState app, AppUser user) {
  final users = app.allUsers.where((item) => item.id != user.id);

  switch (user.role) {
    case UserRole.customer:
      return users
          .where(
            (item) =>
                item.role == UserRole.worker || item.role == UserRole.approver,
          )
          .toList();
    case UserRole.worker:
      return users
          .where(
            (item) =>
                item.role == UserRole.customer ||
                item.role == UserRole.approver,
          )
          .toList();
    case UserRole.approver:
      return users
          .where(
            (item) =>
                item.role == UserRole.customer || item.role == UserRole.worker,
          )
          .toList();
    case UserRole.admin:
      return users.toList();
  }
}

Future<String?> pickSingleFile({required List<String> extensions}) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: extensions,
  );
  return result?.files.single.path;
}

Future<void> openUpiPayment(
  BuildContext context, {
  required String upiId,
  required String name,
  required double amount,
  required String note,
}) async {
  final uri = Uri.parse(
    'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(name)}&am=${amount.toStringAsFixed(0)}&cu=INR&tn=${Uri.encodeComponent(note)}',
  );
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    showSnack(context, 'Unable to open a UPI app on this device.');
  }
}

Future<void> openWhatsAppComplaint(BuildContext context, String message) async {
  final uri = Uri.parse(
    'https://wa.me/${AppState.supportNumber}?text=${Uri.encodeComponent(message)}',
  );
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    showSnack(context, 'Unable to open WhatsApp.');
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

TextStyle themeTitle(BuildContext context) {
  return Theme.of(
    context,
  ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700);
}

String tr(AppLanguage language, String english, String hindi) {
  return language == AppLanguage.hindi ? hindi : english;
}

String roleLabel(AppLanguage language, UserRole role) {
  switch (role) {
    case UserRole.customer:
      return tr(language, 'Customer', 'ग्राहक');
    case UserRole.worker:
      return tr(language, 'Worker', 'कामगार');
    case UserRole.approver:
      return tr(language, 'Approver', 'अप्रूवर');
    case UserRole.admin:
      return tr(language, 'Admin', 'एडमिन');
  }
}

String jobStatusLabel(AppLanguage language, JobStatus status) {
  switch (status) {
    case JobStatus.open:
      return tr(language, 'Requested', 'रिक्वेस्टेड');
    case JobStatus.accepted:
      return tr(language, 'Accepted', 'स्वीकार');
    case JobStatus.inProgress:
      return tr(language, 'In progress', 'कार्य जारी');
    case JobStatus.paymentPending:
      return tr(language, 'Payment pending', 'भुगतान लंबित');
    case JobStatus.closed:
      return tr(language, 'Closed', 'बंद');
  }
}

Color statusColor(JobStatus status) {
  switch (status) {
    case JobStatus.open:
      return const Color(0xFF5F3BFF);
    case JobStatus.accepted:
      return const Color(0xFF1B7FFF);
    case JobStatus.inProgress:
      return const Color(0xFF008B7B);
    case JobStatus.paymentPending:
      return const Color(0xFFEF6C32);
    case JobStatus.closed:
      return const Color(0xFF2E7D32);
  }
}

String formatCurrency(double value) => 'Rs. ${value.toStringAsFixed(0)}';

String formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year;
  return '$day/$month/$year';
}

String fileNameFromPath(String value) {
  return value.replaceAll('\\', '/').split('/').last;
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
