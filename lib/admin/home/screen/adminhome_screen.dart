import 'dart:async';

import 'package:Agragami/admin/id_create/screen/create_id_screen.dart';
import 'package:Agragami/developer/developer_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';


import '../../../auth/login/prasentation/screen/login_screen.dart';
import '../../../contact/screen/contact_screen.dart';
import '../../../core/cachehelper/chechehelper.dart';
import '../../../core/routes/app_routes.dart';
import '../../deleteid/screen/deleteid_screen.dart';
import '../../id_create/screen/edit_id_screen.dart';
import '../../id_list/screen/id_list_screen.dart';
import '../../log/screen/log_screen.dart';
import '../../moneydelete/screen/moneydelete_screen.dart';
import '../../notification/screen/note_screen.dart';
import '../../notification/screen/notificationlist_screen.dart';
import '../../notification/service/note_service.dart';
import '../../pdf/screen/pdf_generate_screen.dart';
import '../../profile/screen/profile_screen.dart';
import '../../save_money/screen/saving_money_screen.dart';
import '../../userlist/screen/userlist_screen.dart';
import '../service/adminhome_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
   final AdminHomeService _adminHomeService = AdminHomeService();
   final NoteService _noteService = NoteService();
  bool _isLoading = false;
  int userTotal =0;
  int adminTotal =0;
  int totalTk =0;
  String name='';
  String DocId='';

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    countTota();
    getName();
  }

  Future<String?> getName() async {
    final userName =  await CacheHelper().getString('names');
    final userDocId =  await CacheHelper().getString('userDocId');
    final adminId =  await CacheHelper().getString('adminId');
    final email =  await CacheHelper().getString('email');
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

  void countTota() async{
    userTotal= await loadUserCount('user');
    adminTotal= await loadUserCount('admin');
    totalTk= await totalMoney();

  }


  Future<int> loadUserCount(String role) async {
    try {
      setState(() {
        _isLoading = true;
      });
      int totalUsers = await _adminHomeService.getTotalUserCount(role);

      if (!mounted) return 0; // ✅ Widget dispose হয়ে গেলে return করো


      setState(() {
        _isLoading = false;
      });
      return totalUsers;
    } catch (e) {
      if (!mounted) return 0;

      setState(() {
        _isLoading = false;
      });

      debugPrint('Error loading user count: $e');
      return 0; // ✅ catch ব্লকেও return দিতে হবে
    }
  }
  Future<int> totalMoney() async {
    try {
      setState(() => _isLoading = true);

      int totalUsers = await _adminHomeService.getAllUsersTotalAmountStream().first;

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
        title: Text('Admin Home'),
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
                    builder: (_) => ProfileScreen(
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
                      color: Colors.green.shade300,
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

        centerTitle: true,
        actions: [
          //Notification
          FutureBuilder<List<String>>(
            future: _noteService.getAdminDocIds(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Icon(Icons.notifications);
              final adminDocIds = snapshot.data!;
              return StreamBuilder<int>(
                stream: _noteService.getTotalUnreadCount(adminDocIds),
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
                            builder: (_) => NotificationListScreen(adminDocId: DocId,),
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
                        Icon(Icons.login,color: Colors.black),
                        SizedBox(width: 10,),
                        Text('Logout'),
                      ],
                    )),
          //  const PopupMenuDivider(),
            PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.person,color: Colors.black,),
                        SizedBox(width: 10,),
                        Text('Profile'),
                      ],
                    )),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Image.asset('assets/images/contact-mail.png', height: 20, width: 20),
                      const SizedBox(width: 10),
                      const Text('Contact'),
                    ],
                  ),
                ),

                PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      Image.asset('assets/images/coding.png', height: 20, width: 20),
                      const SizedBox(width: 10),
                      const Text('About Developer'),
                    ],
                  ),
                ),



          ]
          ),

        ],
      ),

      body: RefreshIndicator(
        onRefresh: totalMoney,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            color: Colors.green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              /*const Icon(
                        Icons.person,
                        color: Colors.red,
                        size: 22,
                      ),*/
                              // const SizedBox(width: 8),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),


                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Total Member & Admin
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Card(
                        elevation: 5,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                             // color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(userTotal.toString(),style: TextStyle(
                                  fontSize: 25,color: Colors.green,
                                  fontWeight: FontWeight.bold
                              ),),
                              Text('Total Members',style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700
                              ),),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  /*Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Card(
                        elevation: 5,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(adminTotal.toString(),style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),),
                              Text('Total Admin',style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700
                              ),),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),*/
                ],
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
                              style: const TextStyle(color:Colors.green,
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Balance',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )


                      ,
                    ),
                  ),
                ),
              )
              ,
              //Saving Money & List user Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>SavingMoneyScreen()));
                    },
                    child: Card(
                      elevation: 5,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          //  color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/taka.png',
                              color: Colors.green,
                              width: 80,
                              height: 50,),
                            SizedBox(height: 5,),
                            Text('Saving Money',style: TextStyle(
                                fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500
                            ),)

                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  //list button
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>UserListScreen()));
                    },
                    child: Card(
                      elevation: 5,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          //  color: Colors.blue.shade300,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset('assets/images/userlist.png',
                                  color: Colors.green,
                                  width: 80,
                                  height: 50,),
                              ),
                            SizedBox(height: 5,),
                            Text('Members List',style: TextStyle(
                                fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //Log & delete
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Log
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>LogScreen()));
                    },
                    child: Card(
                      elevation: 5,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                            //color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/log.png',
                              color: Colors.green,
                              width: 80,
                              height: 50,),
                            SizedBox(height: 5,),
                            Text('Admin Log',style: TextStyle(
                                fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500
                            ),)

                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  //delete button
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>MoneyDeleteSimpleScreen()));
                    },
                    child: Card(
                      elevation: 5,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                           // color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/delete_report.png',
                              color: Colors.green,
                              width: 80,
                              height: 50,),
                            SizedBox(height: 5,),
                            Text('Delete Record',maxLines: 2,style: TextStyle(
                                fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500
                            ),)

                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10,),
              //Note button
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context)=>NoteScreen()));
                },
                child: Card(
                  elevation: 5,
                  child: Container(
                    height: 150,
                    width: 300,
                    decoration: BoxDecoration(
                       // color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/notes.png',
                          color: Colors.green,
                          width: 80,
                          height: 50,),
                        SizedBox(height: 5,),
                        Text('Notice board',maxLines: 2,style: TextStyle(
                            fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500
                        ),)

                      ],
                    ),
                  ),
                ),
              ),
              //Saving Money & List user Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>CreateIdScreen()));
                    },
                    child: Card(
                      elevation: 5,
                      child: Container(
                        height: 150.h,
                        width: 150.w,
                        decoration: BoxDecoration(
                          //  color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/id.png',
                              color: Colors.green,
                              width: 80,
                              height: 50,),
                            SizedBox(height: 5,),
                            Text('User Id Create',style: TextStyle(
                                fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500
                            ),)

                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  //list button
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>IdListScreen()));
                    },
                    child: Card(
                      elevation: 5,
                      child: Container(
                        height: 150.h,
                        width: 150.w,
                        decoration: BoxDecoration(
                          //  color: Colors.blue.shade300,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/images/id_list.png',
                                color: Colors.green,
                                width: 80,
                                height: 50,),
                            ),
                            SizedBox(height: 5,),
                            Text('User Id List',style: TextStyle(
                                fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                ],
              ),

              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context)=>DeleteIdScreen()));
                },
                child: Card(
                  elevation: 5,
                  child: Container(
                    height: 150.h,
                    width: 150.w,
                    decoration: BoxDecoration(
                      //  color: Colors.blue.shade300,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/images/delete_id.png',
                            color: Colors.green,
                            width: 80,
                            height: 50,),
                        ),
                        SizedBox(height: 5,),
                        Text('Delete Id',style: TextStyle(
                            fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500
                        ),)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10,),
              //Note button
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context)=>UserMoneyScreen()));
                },
                child: Card(
                  elevation: 5,
                  child: Container(
                    height: 150.h,
                    width: 300.w,
                    decoration: BoxDecoration(
                      // color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/pdf.png',
                          color: Colors.green,
                          width: 80,
                          height: 50,),
                        SizedBox(height: 5,),
                        Text('Generate a Pdf',maxLines: 2,style: TextStyle(
                            fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500
                        ),)

                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void onSelected(int item, BuildContext context) async{
    switch (item){
      case 0:
        await _auth.signOut();
        await CacheHelper().setLoggedIn(false);
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            /*Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
                  (route) => false,
            );*/
            Get.offAllNamed(AppRoutes.login);
          }
        });
        break;

      case 1:
        Navigator.push(context, MaterialPageRoute(
            builder: (context)=>ProfileScreen(userId:DocId,)));
        break;

      case 2:
        Navigator.push(context, MaterialPageRoute(
            builder: (context)=>ContactScreen(color: Colors.green,)));
        break;

      case 3:
        Navigator.push(context, MaterialPageRoute(
            builder: (context)=>DeveloperScreen(color: Colors.green,)));
        break;
    }


  }
}
