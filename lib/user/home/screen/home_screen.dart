import 'package:agragami/user/profile/screen/profile_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../auth/screen/login_screen.dart';
import '../../../cachehelper/chechehelper.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserNotificationService _notificationService = UserNotificationService();
    final HomeService _homeService = HomeService();
   bool _isLoading = false;
    String userDocId = '';
    String name='';
    String DocId='';
    int totalTk =0;

    @override
  void initState() {
    super.initState();
    getUserDocId();
    getName();
    countTota();
    FocusManager.instance.primaryFocus?.unfocus();
  }
  void countTota() async{
    totalTk= await totalMoney();

  }

  Future<int> totalMoney() async {
    try {
      setState(() => _isLoading = true);

      int totalUsers = await _homeService.getAllUsersTotalAmountStream().first;

      if (!mounted) return 0;

      setState(() {
        _isLoading = false;
        totalTk= totalUsers;
      } );

      return totalUsers;
    } catch (e) {
      if (!mounted) return 0;

      setState(() => _isLoading = false);
      debugPrint('Error loading total money: $e');
      return 0;
    }
  }
  Future<String?> getName() async {
    final userName =  await CacheHelper().getString('names');
    final userDocId =  await CacheHelper().getString('userDocId');
    if (userName == null || userName.isEmpty) {
      debugPrint('Error: Name not found in cache!');
      return null;
    }

    if (userDocId == null || userDocId.isEmpty) {
      debugPrint('Error: UserDocId not found in cache!');
      return null;
    }

    setState(() {
      name = userName;
      DocId = userDocId;
    });
  }
  Future<String?> getUserDocId() async {
    final id =  await CacheHelper().getString('userDocId');
    if (id == null || id.isEmpty) {
      debugPrint('Error: userDocId not found in cache!');
      return null;
    }
    setState(() {
      userDocId = id;
    });
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          FutureBuilder<List<String>>(
            future: _notificationService.getAdminDocIds(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Icon(Icons.notifications);
              final adminDocIds = snapshot.data!;
              return StreamBuilder<int>(
                stream: _notificationService.getTotalUnreadCount(adminDocIds),
                builder: (context, snapshot) {
                  int count = snapshot.data ?? 0;
                  return badges.Badge(
                    showBadge: count > 0,
                    badgeAnimation: badges.BadgeAnimation.scale(), // optional animation
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: Colors.green,        // 🎨 background color of badge
                      padding: EdgeInsets.all(6),    // inner padding
                      borderRadius: BorderRadius.circular(8), // shape of badge
                      borderSide: BorderSide(color: Colors.white, width: 1), // optional border
                      elevation: 4,                  // drop shadow
                    ),
                    badgeContent: Text('$count',
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                    child: IconButton(
                      icon: Icon(Icons.notifications),
                      onPressed: () {
                        // Navigate to NotificationScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserNotificationScreen(adminDocIds: adminDocIds),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),

          PopupMenuButton<int>(
              onSelected: (item)=>onSelected(item,context),
              itemBuilder: (context)=>[
                PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: [
                        Icon(Icons.login,color: Colors.black,),
                        SizedBox(width: 10,),
                        Text('Logout'),
                      ],
                    )),
                //const PopupMenuDivider(),
               /* PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 10,),
                        Text('Setting'),
                      ],
                    )),*/

              ]
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(' $name',style: TextStyle(
                        fontSize: 25,color: Colors.red,
                        fontWeight: FontWeight.bold
                    )),
                  ),
                ],
              ),
            ),
            //Total Amount
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Card(
                elevation: 5,
                child: Container(
                  height: 100,
                  width: 300,
                  decoration: BoxDecoration(
                    // color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            '$totalTk Tk',
                            style: const TextStyle(color:Colors.red,
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Total Amount',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
        
        
                    ,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>UserMoneyRecordScreen()));
                    },
                    child: Card(
                      elevation: 5,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                            //color: Colors.blue.shade300,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/images/transactional.png',
                                color: Colors.red,
                                width: 80,
                                height: 50,),
                            ),
                            SizedBox(height: 5,),
                            Text('Transactional',style: TextStyle(
                                fontSize: 16,color: Colors.black ,
                                fontWeight: FontWeight.w500
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>UsersListScreen()));
                    },
                    child: Card(
                      elevation: 5,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          //color: Colors.blue.shade300,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/images/userlist.png',
                                color: Colors.red,
                                width: 80,
                                height: 50,),
                            ),
                            SizedBox(height: 5,),
                            Text('User List',style: TextStyle(
                                fontSize: 16,color: Colors.black ,
                                fontWeight: FontWeight.w500
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>UserProfileScreen(userId: DocId)));
                    },
                    child: Card(
                      elevation: 5,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          //color: Colors.blue.shade300,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/images/profile.png',
                                color: Colors.red,
                                width: 80,
                                height: 50,),
                            ),
                            SizedBox(height: 5,),
                            Text('Profile',style: TextStyle(
                                fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>AboutUsScreen()));
                    },
                    child: Card(
                      elevation: 5,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                            //color: Colors.blue.shade300,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/images/about-us.png',
                                color: Colors.red,
                                width: 80,
                                height: 50,),
                            ),
                            SizedBox(height: 5,),
                            Text('About us',style: TextStyle(
                                fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void onSelected(int item, BuildContext context) async{
    switch (item){
      case 0:
        await _auth.signOut();
        CacheHelper().clear();
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context)=>LoginScreen()));
        break;

    }

  }
}
