/*
import 'package:Agragami/user/home/presentation/controller/home_controller.dart';
import 'package:Agragami/user/profile/screen/profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../core/cachehelper/chechehelper.dart';
import '../../../about_us/screen/aboutus_screen.dart';
import '../../../money record/screen/user_money_record_screen.dart';
import '../../../notification/service/user_notification_service.dart';
import '../../../userlist/screen/userlist_screen.dart';
import '../../domain/models/homeCardData.dart';
import '../../service/home_service.dart';
import '../../widgets/buildCardRow.dart';
import '../../widgets/homeCard.dart';
import '../../widgets/notificationBadgeWidget.dart';
import '../../widgets/onSelected.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

 // final HomeController controller = Get.find<HomeController>();
  final UserNotificationService _notificationService = UserNotificationService();
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  String userDocId = '';
  String name = '';
  String DocId = '';
  int totalTk = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initData();
    FocusManager.instance.primaryFocus?.unfocus();

  }

  Future<void> _initData() async {
    await getUserDocId();
    await getName();
    await countTotal();
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

      final totalUsers = await _homeService.getAllUsersTotalAmount();

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
    final userName = CacheHelper().getString('names');
    final userDocId = CacheHelper().getString('userDocId');

    if (!mounted) return;

    setState(() {
      name = userName ?? '';
      DocId = userDocId ?? '';
    });
    if (kDebugMode) {
      print("DocId => $DocId");
    }
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
        leading:DocId.isEmpty
            ? const Padding(
          padding: EdgeInsets.all(8),
          child: CircleAvatar(
            child: Icon(Icons.person),
          ),
        )
            : StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(DocId) // Firebase UID
              .snapshots(),
          builder: (context, snapshot) {

            String profileImage = '';

            if (snapshot.hasData && snapshot.data!.exists) {
              final data =
              snapshot.data!.data() as Map<String, dynamic>;

              profileImage =
                  data['profileImage']?.toString() ?? '';
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(
                      userId: DocId,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.redAccent,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child: profileImage.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: profileImage,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,

                        placeholder:
                            (context, url) =>
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),

                        errorWidget:
                            (context, url, error) =>
                        const Icon(
                          Icons.person,
                          color: Colors.red,
                        ),
                      )
                          : const Icon(
                        Icons.person,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        title: const Text('Home'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          const NotificationBadgeWidget(),
          PopupMenuButton<int>(
            onSelected: (item) => onSelected(item, context),
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
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),


                    ],
                  ),
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
                  buildCardRow(
                    context,
                    first: HomeCardData(
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
                    second: HomeCardData(
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
                  buildCardRow(
                    context,
                    first: HomeCardData(
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
                    second: HomeCardData(
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



}*/

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../about_us/screen/aboutus_screen.dart';
import '../../../money record/screen/user_money_record_screen.dart';
import '../../../profile/screen/profile_screen.dart';
import '../../../userlist/screen/userlist_screen.dart';
import '../../widgets/buildCardRow.dart';
import '../../widgets/notificationBadgeWidget.dart';
import '../../widgets/onSelected.dart';
import '../controller/home_controller.dart';
import '../../domain/models/homeCardData.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Obx(() {
          final data = controller.homeData.value;

          if (data.userDocId.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(8),
              child: CircleAvatar(child: Icon(Icons.person)),
            );
          }

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(userId: data.userDocId),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.redAccent, width: 2),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                  child: ClipOval(
                    child: data.profileImage.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: data.profileImage,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (_, __, ___) =>
                      const Icon(Icons.person, color: Colors.red),
                    )
                        : const Icon(Icons.person, color: Colors.red),
                  ),
                ),
              ),
            ),
          );
        }),
        title: const Text('Home'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          const NotificationBadgeWidget(),
          PopupMenuButton<int>(
            onSelected: (item) => onSelected(item, context),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Row(children: const [
                  Icon(Icons.login, color: Colors.black),
                  SizedBox(width: 10),
                  Text('Logout'),
                ]),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(children: [
                  Image.asset('assets/images/contact-mail.png', height: 20, width: 20),
                  const SizedBox(width: 10),
                  const Text('Contact'),
                ]),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(children: [
                  Image.asset('assets/images/coding.png', height: 20, width: 20),
                  const SizedBox(width: 10),
                  const Text('About Developer'),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Obx(() => Text(
                    controller.homeData.value.name,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Card(
                elevation: 5,
                child: Container(
                  height: 100,
                  width: 300,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Obx(() => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${controller.homeData.value.totalTk} Tk',
                          style: const TextStyle(
                              color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        const Text('Balance',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    )),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Obx(() {
                final docId = controller.homeData.value.userDocId;
                return Column(
                  children: [
                    buildCardRow(
                      context,
                      first: HomeCardData(
                        title: 'Transaction Report',
                        imagePath: 'assets/images/transactional.png',
                        color: Colors.red,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => UserMoneyRecordScreen())),
                      ),
                      second: HomeCardData(
                        title: 'Members List',
                        imagePath: 'assets/images/userlist.png',
                        color: Colors.red,
                        onTap: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => UsersListScreen())),
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildCardRow(
                      context,
                      first: HomeCardData(
                        title: 'Profile',
                        imagePath: 'assets/images/profile.png',
                        color: Colors.red,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => UserProfileScreen(userId: docId))),
                      ),
                      second: HomeCardData(
                        title: 'About us',
                        imagePath: 'assets/images/about-us.png',
                        color: Colors.red,
                        onTap: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => AboutUsScreen())),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
