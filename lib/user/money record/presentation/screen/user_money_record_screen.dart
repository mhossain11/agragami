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
                  colors: [Colors.red.shade400, Colors.red.shade400],
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
                        style: TextStyle(color: Colors.white, fontSize: 16),
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

            /// =====================
            /// Data Table Card
            /// =====================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: controller.records.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            size: 34,
                            color: Colors.red.shade400,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No Payment Records',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'No payment data found for this period.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                      : SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 52,
                        dataRowMinHeight: 62,
                        dataRowMaxHeight: 68,

                        // =====================
                        // Header Background
                        // =====================
                        headingRowColor: WidgetStateProperty.all(
                          Colors.red.shade50,
                        ),

                        // =====================
                        // Header Text
                        // =====================
                        headingTextStyle: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),

                        // =====================
                        // Body Text
                        // =====================
                        dataTextStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),

                        dividerThickness: 0.5,

                        columnSpacing: 30,

                        horizontalMargin: 18,

                        columns: const [
                          DataColumn(
                            label: Text('SL'),
                          ),
                          DataColumn(
                            label: Text('Money ID'),
                          ),
                          DataColumn(
                            label: Text('Amount'),
                          ),
                          DataColumn(
                            label: Text('Method'),
                          ),
                          DataColumn(
                            label: Text('Date & Time'),
                          ),
                          DataColumn(
                            label: Text('Received By'),
                          ),
                          DataColumn(
                            label: Text(''),
                          ),
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
                              isEven
                                  ? Colors.white
                                  : Colors.grey.shade50.withOpacity(0.6),
                            ),
                            cells: [

                              // =====================
                              // SL
                              // =====================
                              DataCell(
                                Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ),

                              // =====================
                              // Money ID
                              // =====================
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.receipt_rounded,
                                      size: 17,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      record.id,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // =====================
                              // Amount
                              // =====================
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '৳ ${record.amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.green.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),

                              // =====================
                              // Payment Method
                              // =====================
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.payment_rounded,
                                        size: 14,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        record.paymentMethod,
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // =====================
                              // Date & Time
                              // =====================
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.calendar_month_rounded,
                                        size: 16,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // =====================
                              // Received By
                              // =====================
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.purple.shade50,
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 17,
                                        color: Colors.purple.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      record.receivedBy,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // =====================
                              // Copy Button
                              // =====================
                              DataCell(
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    splashRadius: 20,
                                    icon: Icon(
                                      Icons.copy_rounded,
                                      color: Colors.grey.shade600,
                                      size: 17,
                                    ),
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text: record.id,
                                        ),
                                      );

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Copied: ${record.id}',
                                          ),
                                          behavior:
                                          SnackBarBehavior.floating,
                                          backgroundColor: Colors.black87,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          duration:
                                          const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
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
