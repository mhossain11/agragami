/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/cachehelper/chechehelper.dart';
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
                    final amount = data['amount'] ?? 00;
                    final payMethod = data['payment_method'];
                    DateTime? dateTime;
                    final rawDate = data['date&time'];

                    if (rawDate is Timestamp) {
                      dateTime = rawDate.toDate();
                    } else if (rawDate is String) {
                      dateTime = DateTime.tryParse(rawDate);
                    }
                    final formattedDate = dateTime != null
                        ? DateFormat('dd-MM-yyyy hh:mm a').format(dateTime)
                        : 'No Date';
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
                                      fontSize: 14, fontWeight: FontWeight.bold),
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
                            leading: const Icon(Icons.account_balance_wallet
                            ),
                            title: Text(
                              '৳ $amount',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(formattedDate,style: TextStyle(fontSize: 10),),
                            trailing: Text('$payMethod'),
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

*/

/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/money_controller.dart';


class UserMoneyRecordScreen extends GetView<MoneyRecordController> {
  const UserMoneyRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Records'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.records.isEmpty) {
          return const Center(child: Text('No money record found.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================
            // Total Amount Card
            // =====================
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
                        '${controller.sumOfAmounts.toStringAsFixed(0)} Tk ',
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

            const SizedBox(height: 10),

            // =====================
            // Data Table
            // =====================
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.red.shade50),
                    columns: const [
                      DataColumn(label: Text('Money ID')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Payment Method')),
                      DataColumn(label: Text('Date & Time')),
                      DataColumn(label: Text('Copy')),
                    ],
                    rows: controller.records.map((record) {
                      final formattedDate = record.dateTime != null
                          ? DateFormat('dd-MM-yyyy hh:mm a').format(record.dateTime!)
                          : 'No Date';

                      return DataRow(
                        cells: [
                          DataCell(Text(record.id)),
                          DataCell(Text('৳ ${record.amount.toStringAsFixed(0)}')),
                          DataCell(Text(record.paymentMethod)),
                          DataCell(Text(formattedDate, style: const TextStyle(fontSize: 12))),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.blue, size: 20),
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: record.id));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Copied: ${record.id}')),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/money_controller.dart';


class UserMoneyRecordScreen extends GetView<MoneyRecordController> {
  const UserMoneyRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Money Records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.records.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No money record found.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================
            // Total Amount Banner
            // =====================
            Container(
              margin: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade600, Colors.red.shade400],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sum of all records',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                  Text(
                    '৳ ${controller.sumOfAmounts.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // =====================
            // Data Table Card
            // =====================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 48,
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 56,
                        headingRowColor: WidgetStateProperty.all(
                          Colors.red.shade50,
                        ),
                        headingTextStyle: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        dataTextStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        dividerThickness: 0.4,
                        columnSpacing: 28,
                        columns: const [
                          DataColumn(label: Text('SL')),
                          DataColumn(label: Text('Money ID')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Method')),
                          DataColumn(label: Text('Date & Time')),
                          DataColumn(label: Text('Received By')),
                          DataColumn(label: Text('Total Amount')),
                          DataColumn(label: Text('')), // copy icon column
                        ],
                        rows: controller.records.asMap().entries.map((entry) {
                          final index = entry.key;
                          final record = entry.value;

                          final formattedDate = record.dateTime != null
                              ? DateFormat('dd-MM-yyyy hh:mm a')
                              .format(record.dateTime!)
                              : 'No Date';

                          final isEven = index % 2 == 0;

                          return DataRow(
                            color: WidgetStateProperty.all(
                              isEven ? Colors.white : Colors.grey.shade50,
                            ),
                            cells: [
                              DataCell(
                                Text(
                                  '${index + 1}', // 👈 Serial Number
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  record.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '৳ ${record.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    record.paymentMethod,
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  record.receivedBy,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              DataCell(                                        // 👈 নতুন cell
                                Text(
                                  '৳ ${controller.totalForRecord(record.id).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.copy_rounded,
                                      color: Colors.grey.shade500, size: 18),
                                  onPressed: () async {
                                    await Clipboard.setData(
                                        ClipboardData(text: record.id));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Copied: ${record.id}'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.black87,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
