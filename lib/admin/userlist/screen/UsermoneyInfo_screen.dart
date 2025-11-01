import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../service/userlist_service.dart';

class UserMoneyInfoScreen extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String nid;
  final String birthdate;
  final String address;
  final String nomineeName;
  final String nomineeRelation;


  final UserListService _userListService = UserListService();

  UserMoneyInfoScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.nid,
    required this.birthdate,
    required this.address,
    required this.nomineeName,
    required this.nomineeRelation,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('userId: $userId');

    return Scaffold(
      appBar: AppBar(title: const Text('User transaction history'),centerTitle: true,),
      body: StreamBuilder<QuerySnapshot>(
        stream: _userListService.getMoneyListByUserId(userId),
        builder: (context, snapshot) {
          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🚫 Empty data check
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return  Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 4,
                  color: Colors.red.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: $name',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('User ID: $userId',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('Email: $email',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('phone: $phone',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('Nid: $nid',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('BirthDate: $birthdate',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('Address: $address',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('NomineeName: $nomineeName',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('NomineeRelation: $nomineeRelation',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(child: Center(child: Text('No money record found.'))),
              ],
            );
          }

          // ✅ Snapshot data list
          final moneyDocs = snapshot.data!.docs;
          double totalAmount = 0;
          for (var doc in moneyDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] ?? 0).toDouble();
            totalAmount += amount;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                color: Colors.green.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: $name',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('User ID: $userId',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('Email: $email',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('phone: $phone',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('Nid: $nid',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('BirthDate: $birthdate',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('Address: $address',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('NomineeName: $nomineeName',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('NomineeRelation: $nomineeRelation',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Card(
                  elevation: 3,
                  color: Colors.grey.shade300,
                  child: SizedBox(
                    width: 300,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Total Amount:',
                          style: TextStyle(
                              fontSize:14,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),),
                        Text('${totalAmount.toStringAsFixed(0)} Tk ',
                          style: TextStyle(
                              fontSize:16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 8),
              //  Money List
              Expanded(
                child: ListView.builder(
                  itemCount: moneyDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                    moneyDocs[index].data() as Map<String, dynamic>;
                     final moneyDocId = moneyDocs[index].id;
                    final amount = data['amount'] ?? 0;
                    final paymentMethod = data['payment_method'] ?? '';
                    final dateTime = (data['date&time'] as Timestamp).toDate();
                    final formattedDate =
                    DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text('MoneyID: $moneyDocId',style: const TextStyle(
                                                          fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, color: Colors.blue),
                                onPressed: () async {
                                  await Clipboard.setData(ClipboardData(text: moneyDocId)); // ✅ Copy to clipboard
                                  ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content: Text('Copied: $moneyDocId')),
                                  );
                                },
                              ),
                            ],
                          ),
                          ListTile(
                            leading: const Icon(Icons.monetization_on_outlined),
                            title: Text(
                              '৳ $amount',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(paymentMethod,style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),),
                            trailing: Text(formattedDate)
                          ),

                        ],
                      ),
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
