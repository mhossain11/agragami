import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../admin/home/service/adminhome_service.dart';
import '../../../auth/screen/login_screen.dart';
import '../../../cachehelper/chechehelper.dart';
import '../../notification/screen/notification_screen.dart';
import '../../notification/service/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Home'),

        centerTitle: true,
        actions: [
          /*StreamBuilder(
            stream: _notificationService.getAllAdminNotifications(),
            builder: (context, snapshot) {
              int count = 0;
              if (snapshot.hasData) {
                count = (snapshot.data! as List).length;
              }

              return badges.Badge(
                position: badges.BadgePosition.topEnd(top: -5, end: -5),
                showBadge: count > 0,
                badgeContent: Text(
                  count.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),*/
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
          /*Padding(
            padding: const EdgeInsets.all(14.0),
            child: Card(
              elevation: 5,
              child: Container(
                height: 100,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: StreamBuilder<int>(
                    stream: _adminHomeService.getAllUsersTotalAmountStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final totalAmount = snapshot.data ?? 0;
                      return Text(
                        '$totalAmount Tk',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      );
                    },
                  )


                  ,
                ),
              ),
            ),
          )*/
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
