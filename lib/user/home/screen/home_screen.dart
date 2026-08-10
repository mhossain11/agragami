import 'package:Agragami/admin/profile/screen/profile_screen.dart';
import 'package:Agragami/contact/screen/contact_screen.dart';
import 'package:Agragami/user/profile/screen/profile_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../auth/screen/login_screen.dart';
import '../../../cachehelper/chechehelper.dart';
import '../../../developer/developer_screen.dart';
import '../../about_us/screen/aboutus_screen.dart';
import '../../money record/screen/user_money_record_screen.dart';
import '../../notification/screen/user_notification_screen.dart';
import '../../notification/service/user_notification_service.dart';
import '../../userlist/screen/userlist_screen.dart';
import '../service/home_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserNotificationService _notificationService = UserNotificationService();
  final HomeService _homeService = HomeService();


  bool _isLoading = false;
  String userDocId = '';
  String name = '';
  String DocId = '';
  int totalTk = 0;
  String profileImage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initData();
    FocusManager.instance.primaryFocus?.unfocus();
    getProfileImage();

  }

  Future<void> _initData() async {
    await getUserDocId();
    await getName();
    await countTotal();
  }

  Future<void> getProfileImage() async {
    final image = await CacheHelper().getString('profileImage');

    if (!mounted) return;

    setState(() {
      profileImage = image ?? '';
    });
  }

  Future<void> countTotal() async {
    final totalUsers = await totalMoney();
    if (!mounted) return;
    setState(() => totalTk = totalUsers);
  }

  Future<int> totalMoney() async {
    try {
      if (!mounted) return 0;
      setState(() => _isLoading = true);

      final totalUsers = await _homeService.getAllUsersTotalAmountStream().first;

      if (!mounted) return 0;
      setState(() => _isLoading = false);
      return totalUsers;
    } catch (e) {
      if (!mounted) return 0;
      setState(() => _isLoading = false);
      debugPrint('Error loading total money: $e');
      return 0;
    }
  }

  Future<void> getName() async {
    final userName = await CacheHelper().getString('names');
    final userDocId = await CacheHelper().getString('userDocId');

    if (!mounted) return;

    setState(() {
      name = userName ?? '';
      DocId = userDocId ?? '';
    });
  }

  Future<void> getUserDocId() async {
    final id = await CacheHelper().getString('userDocId');
    if (!mounted) return;
    setState(() => userDocId = id ?? '');
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      await FirebaseAuth.instance.signOut();
      await CacheHelper().setLoggedIn(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (cotexte)=>ProfileScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: Image.network(
                  profileImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print(error);
                    return const Icon(Icons.person);
                  },
                ),
              ),
            ),
          ),
        ),
        title: const Text('Home'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          const NotificationBadgeWidget(),
          PopupMenuButton<int>(
            onSelected: (item) => _onSelected(item, context),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: const [
                    Icon(Icons.login, color: Colors.black),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Image.asset('assets/images/contact-mail.png', height: 20, width: 20),
                    const SizedBox(width: 10),
                    const Text('Contact'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Image.asset('assets/images/coding.png', height: 20, width: 20),
                    const SizedBox(width: 10),
                    const Text('About Developer'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Name
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  name,
                  style: const TextStyle(
                      fontSize: 25, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Total Amount Card
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Card(
                elevation: 5,
                child: Container(
                  height: 100,
                  width: 300,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$totalTk Tk',
                          style: const TextStyle(
                              color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Balance',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  _buildCardRow(
                    context,
                    first: _HomeCardData(
                      title: 'Transaction Report',
                      imagePath: 'assets/images/transactional.png',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UserMoneyRecordScreen()),
                        );
                      },
                    ),
                    second: _HomeCardData(
                      title: 'Members List',
                      imagePath: 'assets/images/userlist.png',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UsersListScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildCardRow(
                    context,
                    first: _HomeCardData(
                      title: 'Profile',
                      imagePath: 'assets/images/profile.png',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UserProfileScreen(userId: DocId)),
                        );
                      },
                    ),
                    second: _HomeCardData(
                      title: 'About us',
                      imagePath: 'assets/images/about-us.png',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AboutUsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSelected(int item, BuildContext context) async {
    switch (item) {
      case 0:
        await _auth.signOut();
        await CacheHelper().setLoggedIn(false);
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
                  (route) => false,
            );
          }
        });
        break;

      case 1:
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ContactScreen(color: Colors.red,)));
        }
        break;

      case 2:
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context)=>DeveloperScreen(color: Colors.red,)));
        }
        break;
    }
  }

  Widget _buildCardRow(BuildContext context,
      {required _HomeCardData first, required _HomeCardData second}) {
    return Row(
      children: [
        Expanded(child: _HomeCard(first)),
        const SizedBox(width: 10),
        Expanded(child: _HomeCard(second)),
      ],
    );
  }
}

class _HomeCardData {
  final String title;
  final String imagePath;
  final Color color;
  final VoidCallback onTap;

  _HomeCardData(
      {required this.title, required this.imagePath, required this.color, required this.onTap});
}

class _HomeCard extends StatelessWidget {
  final _HomeCardData data;

  const _HomeCard(this.data);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Card(
        elevation: 5,
        child: Container(
          height: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(data.imagePath, color: data.color, width: 80, height: 50),
              ),
              const SizedBox(height: 5),
              Center(
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Notification Badge Widget
class NotificationBadgeWidget extends StatelessWidget {
  const NotificationBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final _notificationService = UserNotificationService();

    return FutureBuilder<List<String>>(
      future: _notificationService.getAdminDocIds(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Icon(Icons.notifications);

        final adminDocIds = snapshot.data!;
        return StreamBuilder<int>(
          stream: _notificationService.getTotalUnreadCount(adminDocIds),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return badges.Badge(
              showBadge: count > 0,
              badgeContent: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10)),
              badgeStyle: badges.BadgeStyle(
                badgeColor: Colors.green,
                padding: const EdgeInsets.all(6),
                borderRadius: BorderRadius.circular(8),
                elevation: 4,
                borderSide: const BorderSide(color: Colors.white, width: 1),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserNotificationScreen(adminDocIds: adminDocIds)),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
