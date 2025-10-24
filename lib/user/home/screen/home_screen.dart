import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../admin/home/service/adminhome_service.dart';
import '../../../auth/screen/login_screen.dart';
import '../../../cachehelper/chechehelper.dart';
import '../../money record/screen/user_money_record_screen.dart';
import '../../notification/screen/notification_screen.dart';
import '../../notification/service/notification_service.dart';
import '../service/home_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
    final HomeService _homeService = HomeService();
    String userDocId = '';

    @override
  void initState() {
    super.initState();
    getUserDocId();
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
      debugPrint('User Doc ID: $userDocId');
    return Scaffold(
      appBar: AppBar(
        title: Text('User Home'),

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
                    badgeContent: Text('$count',
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                    child: IconButton(
                      icon: Icon(Icons.notifications),
                      onPressed: () {
                        // Navigate to NotificationScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationScreen(adminDocIds: adminDocIds),
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
                        Icon(Icons.login),
                        SizedBox(width: 10,),
                        Text('Logout'),
                      ],
                    )),
                const PopupMenuDivider(),
                PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 10,),
                        Text('Setting'),
                      ],
                    )),

              ]
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Card(
              elevation: 5,
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FutureBuilder<int?>(
                    future: _homeService.getUserTotalMoney(userDocId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final totalAmount = snapshot.data?.toInt() ?? 0; // double to int

                      return Text(
                        '$totalAmount Tk',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
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
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.blue.shade300,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/images/userlist.png',
                              color: Colors.white,
                              width: 80,
                              height: 50,),
                          ),
                          SizedBox(height: 5,),
                          Text('User List',style: TextStyle(
                              fontSize: 16,color: Colors.white
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
                        builder: (context)=>UserMoneyRecordScreen()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.blue.shade300,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/images/profile.png',
                              color: Colors.white,
                              width: 80,
                              height: 50,),
                          ),
                          SizedBox(height: 5,),
                          Text('Profile',style: TextStyle(
                              fontSize: 16,color: Colors.white
                          ),)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
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
