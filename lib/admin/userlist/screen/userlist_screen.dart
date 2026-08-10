import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../cachehelper/toast.dart';
import '../../../res/apptextstyle.dart';
import '../../home/widgets/fullimage.dart';
import 'UsermoneyInfo_screen.dart';


class UserListScreen extends StatelessWidget {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('List of users'),centerTitle: true,),
      body: StreamBuilder<QuerySnapshot>(
        // Filter করে শুধু role = "User"
        stream: usersCollection.where('role', isEqualTo: 'user').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found'));
          }

          final users = snapshot.data!.docs;

          return Column(
            children: [
              Card(
                elevation: 3,
                color: Colors.green.shade50,
                child: SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: Center(child: Text('User Length:${ users.length}',
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),))),
              ),
              SizedBox(height: 5,),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final doc = users[index];
                    final user = doc.data() as Map<String, dynamic>;
                    final userDocId = doc.id; //
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>
                                UserMoneyInfoScreen (
                                  userId: user['user_id'],
                                  name: user['name'],
                                  email: user['email'],
                                  phone: user['phone'],
                                  nid: user['nid'],
                                  birthdate: user['birthdate'],
                                  address: user['address'],
                                  nomineeName: user['nomineeName'],
                                  nomineeRelation: user['nomineeRelation'],
                                )));
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [

                                  // UserDocID
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'UserDocID: $userDocId',
                                          style: AppTextStyles.style10_bold,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.copy,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () async {
                                          await Clipboard.setData(
                                            ClipboardData(text: userDocId),
                                          );

                                          CustomToast().showToast(
                                            context,
                                            'Copied: $userDocId',
                                            Colors.green,
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [

                                      // Profile Icon
                                      GestureDetector(
                                        onTap: () {
                                          final imageUrl =
                                              user['profileImage']?.toString() ?? '';


                                          if (imageUrl.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                duration: Duration(seconds:2),
                                                backgroundColor: Colors.red,
                                                content: Text('No image found'),
                                              ),
                                            );
                                            return;
                                          }

                                          showImageDialog(context, imageUrl);
                                        },
                                        child: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.teal.shade100,
                                          backgroundImage: user['profileImage'] != null &&
                                              user['profileImage'].toString().isNotEmpty
                                              ? NetworkImage(user['profileImage'])
                                              : null,
                                          child: user['profileImage'] == null ||
                                              user['profileImage'].toString().isEmpty
                                              ? const Icon(
                                            Icons.person,
                                            color: Colors.teal,
                                          )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user['name'] ?? 'No Name',
                                              style:
                                              AppTextStyles.small_bold,
                                            ),

                                            const SizedBox(height: 4),

                                            Text(
                                              user['email'] ?? 'N/A',
                                              style: AppTextStyles
                                                  .style10_normal,
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),


                                            const SizedBox(height: 8),

                                          ],
                                        ),
                                      ),

                                      // User Info
                                      const SizedBox(width: 12),


                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,

                                    children: [
                                      Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.teal
                                              .withOpacity(0.1),
                                          borderRadius:
                                          BorderRadius.circular(
                                              20),
                                        ),
                                        child: Text(
                                          user['user_id'] ?? 'N/A',
                                          style: const TextStyle(
                                              color: Colors.teal,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 12
                                          ),
                                        ),
                                      ),

                                      // Copy User ID
                                      IconButton(
                                        icon: const Icon(
                                          Icons.copy,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () async {
                                          final userId =
                                              user['user_id']
                                                  ?.toString() ??
                                                  '';

                                          if (userId.isEmpty) {
                                            CustomToast().showToast(
                                              context,
                                              'User ID not found',
                                              Colors.red,
                                            );
                                            return;
                                          }

                                          await Clipboard.setData(
                                            ClipboardData(text: userId),
                                          );

                                          CustomToast().showToast(
                                            context,
                                            'Copied: $userId',
                                            Colors.green,
                                          );
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );

                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}





