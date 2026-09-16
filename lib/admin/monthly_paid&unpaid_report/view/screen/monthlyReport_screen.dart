import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/monthly_controller.dart';
import '../widgets/paidReportView.dart';
import '../widgets/unpaidReportView.dart';

class MonthlyPaidUnpaidReportPage extends StatelessWidget {
  MonthlyPaidUnpaidReportPage({super.key});

  final MonthlyPaidUnpaidController controller = Get.put(MonthlyPaidUnpaidController());

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
                      flex:1,
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

              const SizedBox(height: 12),

              // COLLECTION
              Obx(
                () => _summaryCard(
                  'Total Collection',
                  '৳${controller.totalCollection.toStringAsFixed(0)}',
                ),
              ),

              const SizedBox(height: 14),

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
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              value,textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
