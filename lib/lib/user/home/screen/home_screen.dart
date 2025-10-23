import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../admin/home/service/adminhome_service.dart';
import '../../../auth/screen/login_screen.dart';
import '../../../cachehelper/chechehelper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AdminHomeService _adminHomeService = AdminHomeService();

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
