import 'package:flutter/material.dart';

import 'buildInfoRow.dart';

class BuildUserInfoCard extends StatefulWidget {
   BuildUserInfoCard({super.key,
     required this.userData,
     required this.currentUserId,
     required this.isUserVerified,
   });

  Map<String, dynamic> userData;
   String currentUserId;
   bool isUserVerified ;
  @override
  State<BuildUserInfoCard> createState() => _BuildUserInfoCardState();
}

class _BuildUserInfoCardState extends State<BuildUserInfoCard> {


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'User Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
               /* Spacer(),
                IconButton(
                  icon: Icon(Icons.logout, size: 20),
                  onPressed: _resetUser,
                  tooltip: 'Change User',
                ),*/
              ],
            ),
            SizedBox(height: 10),
            BuildInfoRow('Name', widget.userData['name'] ?? 'N/A'),
            BuildInfoRow('Email', widget.userData['email'] ?? 'N/A'),
            BuildInfoRow('User ID', widget.currentUserId),
            BuildInfoRow('Phone', widget.userData['phone'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }
}
