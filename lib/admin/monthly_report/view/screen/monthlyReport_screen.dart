import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/monthly_controller.dart';
import '../widgets/paidReportView.dart';
import '../widgets/unpaidReportView.dart';

class MonthlyReportPage extends StatelessWidget {
  MonthlyReportPage({super.key});

  final MonthlyController controller = Get.put(MonthlyController());

  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =========================
            // YEAR + MONTH
            // =========================

            Row(
              children: [
                // YEAR
                Expanded(
                  child: Obx(
                        () => DropdownButtonFormField<int>(
                      value: controller
                          .selectedYear.value,
                      decoration:
                      const InputDecoration(
                        labelText: 'Year',
                        border:
                        OutlineInputBorder(),
                      ),
                      items: List.generate(
                        10,
                            (index) {
                          final year =
                              DateTime.now().year -
                                  5 +
                                  index;

                          return DropdownMenuItem<int>(
                            value: year,
                            child:
                            Text('$year'),
                          );
                        },
                      ),
                      onChanged: (value) {
                        if (value == null) return;

                        controller.changeYear(
                          value,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // MONTH
                Expanded(
                  child: Obx(
                        () => DropdownButtonFormField<int>(
                      value: controller
                          .selectedMonth.value,
                      decoration:
                      const InputDecoration(
                        labelText: 'Month',
                        border:
                        OutlineInputBorder(),
                      ),
                      items: List.generate(
                        12,
                            (index) {
                          return DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text(
                              months[index],
                            ),
                          );
                        },
                      ),
                      onChanged: (value) {
                        if (value == null) return;

                        controller.changeMonth(
                          value,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =========================
            // REPORT
            // =========================

            Expanded(
              child: Obx(
                    () {
                  if (controller.isLoading.value) {
                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  if (controller.report.isEmpty) {
                    return const Center(
                      child: Text(
                        'No data found',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return _buildDataTable();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('Monthly Report')),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // YEAR + MONTH
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => DropdownButtonFormField<int>(
                        value: controller.selectedYear.value,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(10, (index) {
                          final year = DateTime.now().year - 5 + index;

                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text('$year'),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            controller.changeYear(value);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Obx(
                      () => DropdownButtonFormField<int>(
                        value: controller.selectedMonth.value,
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(12, (index) {
                          return DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text(months[index]),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            controller.changeMonth(value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SUMMARY
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        'Total Members',
                        '${controller.totalMembers}',
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _summaryCard('Paid', '${controller.paidCount}'),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _summaryCard(
                        'Unpaid',
                        '${controller.unpaidCount}',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // COLLECTION
              Obx(
                () => _summaryCard(
                  'Total Collection',
                  '৳${controller.totalCollection.toStringAsFixed(0)}',
                ),
              ),

              const SizedBox(height: 16),

              // TABS
              const TabBar(
                tabs: [
                  Tab(text: 'Paid Members'),
                  Tab(text: 'Unpaid Members'),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return const TabBarView(
                    children: [PaidReportView(), UnpaidReportView()],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _summaryCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }


  /*Widget _buildDataTable() {
    final data = controller.report;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 50,
          dataRowMinHeight: 55,
          dataRowMaxHeight: 65,

          columns: const [
            DataColumn(
              label: Text('SL', style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            DataColumn(
              label: Text(
                'User ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            DataColumn(
              label: Text(
                'Money ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            DataColumn(
              label: Text(
                'Amount',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            DataColumn(
              label: Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            DataColumn(
              label: Text(
                'Received By',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            DataColumn(
              label: Text(
                'Total Amount',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],

          rows: List.generate(data.length, (index) {
            final item = data[index];

            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),

                DataCell(Text(item.userId)),

                DataCell(Text(item.userName)),

                DataCell(Text(item.moneyId)),

                DataCell(Text(DateFormat('dd-MMM-yyyy').format(item.date))),

                DataCell(Text('৳${item.amount.toStringAsFixed(0)}')),

                DataCell(Text(item.paymentMethod)),

                DataCell(Text(item.receivedBy)),

                DataCell(Text('৳${item.totalAmount.toStringAsFixed(0)}')),
              ],
            );
          }),
        ),
      ),
    );
  }*/
}
