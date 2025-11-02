import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../cachehelper/chechehelper.dart';
import '../service/moneyrecord_service.dart';

class UserMoneyRecordScreen extends StatefulWidget {


  const UserMoneyRecordScreen({super.key,});

  @override
  State<UserMoneyRecordScreen> createState() => _UserMoneyRecordScreenState();
}

class _UserMoneyRecordScreenState extends State<UserMoneyRecordScreen> {
  final MoneyRecordService _moneyRecordService = MoneyRecordService();
  String userDocId = '';

  @override
  void initState() {
    super.initState();
    getUserDocId();
  }

  Future<void> getUserDocId() async {
    final id = await CacheHelper().getString('userDocId');

    if (id == null || id.isEmpty) {
      debugPrint("Error: userDocId not found in cache!");
      return; // stop
    }

    if (!mounted) return;
    setState(() {
      userDocId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Records'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: userDocId.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: _moneyRecordService.getMoneyListByUserId(userDocId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No money record found.'));
          }

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
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${totalAmount.toStringAsFixed(0)} Tk ',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: moneyDocs.length,
                  itemBuilder: (context, index) {
                    final data = moneyDocs[index].data() as Map<String, dynamic>;
                    final moneyDocId = moneyDocs[index].id;
                    final amount = data['amount'] ?? 0;
                    final dateTime = (data['date&time'] as Timestamp).toDate();
                    final formattedDate =
                    DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'MoneyID: $moneyDocId',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, color: Colors.blue),
                                onPressed: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: moneyDocId));
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
                            subtitle: Text(formattedDate),
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

