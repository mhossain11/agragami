import 'dart:async';

import 'package:agragami/admin/id_create/screen/create_id_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../auth/screen/login_screen.dart';
import '../../../cachehelper/chechehelper.dart';
import '../../id_create/screen/edit_id_screen.dart';
import '../../log/screen/log_screen.dart';
import '../../moneydelete/screen/moneydelete_screen.dart';
import '../../notification/screen/note_screen.dart';
import '../../save_money/screen/saving_money_screen.dart';
import '../../userlist/screen/userlist_screen.dart';
import '../service/adminhome_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
   final AdminHomeService _adminHomeService = AdminHomeService();
  bool _isLoading = true;
  int userTotal =0;
  int adminTotal =0;
  String name='';

  @override
  void initState(){
    super.initState();
    countTota();
    getName();
  }
  Future<String?> getName() async {
    final userName =  await CacheHelper().getString('names');
    if (userName == null || userName.isEmpty) {
      debugPrint('Error: Name not found in cache!');
      return null;
    }
    setState(() {
      name = userName;
    });
  }

  void countTota() async{
    userTotal= await loadUserCount('user');
    adminTotal= await loadUserCount('admin');
  }


  Future<int> loadUserCount(String role) async {
    try {
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




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),

        centerTitle: true,
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.notifications)),
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
            const PopupMenuDivider(),
            PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.person,color: Colors.black,),
                        SizedBox(width: 10,),
                        Text('Profile'),
                      ],
                    )),

          ]
          ),
        ],
      ),

      body: SingleChildScrollView(
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
                    padding: const EdgeInsets.all(8.0),
                    child: Text(name,style: TextStyle(
                        fontSize: 25,color: Colors.green,
                        fontWeight: FontWeight.bold
                    )),
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
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                '$totalAmount Tk',
                                style: const TextStyle(color:Colors.green,
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Center(
                              child: Text(
                                'TotalAmount',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        );
                      },
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
                          Text('User List',style: TextStyle(
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
                      height: 150,
                      width: 150,
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
                          Text('User id Create',style: TextStyle(
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
                        builder: (context)=>EditIdScreen()));
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
                            child: Image.asset('assets/images/id_list.png',
                              color: Colors.green,
                              width: 80,
                              height: 50,),
                          ),
                          SizedBox(height: 5,),
                          Text('Id List',style: TextStyle(
                              fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500
                          ),)
                        ],
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
