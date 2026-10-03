import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/monthly_controller.dart';

class MonthlyReportPage extends StatelessWidget {
  MonthlyReportPage({super.key});

  final MonthlyController controller =
  Get.put(MonthlyController());

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDateSelector(),

            const SizedBox(height: 20),

            Expanded(
              child: Obx(
                    () {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.report.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildReport();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // YEAR + MONTH
  // ============================================================

  Widget _buildDateSelector() {
    return Row(
      children: [
        Expanded(
          child: Obx(
                () => DropdownButtonFormField<int>(
              value: controller.selectedYear.value,
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
              ),
              items: _buildYears(),
              onChanged: (value) {
                if (value == null) return;

                controller.changeYear(value);
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
              items: _buildMonths(),
              onChanged: (value) {
                if (value == null) return;

                controller.changeMonth(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<int>> _buildYears() {
    final currentYear = DateTime.now().year;

    return List.generate(
      10,
          (index) {
        final year = currentYear - 5 + index;

        return DropdownMenuItem<int>(
          value: year,
          child: Text('$year'),
        );
      },
    );
  }

  List<DropdownMenuItem<int>> _buildMonths() {
    return List.generate(
      months.length,
          (index) {
        return DropdownMenuItem<int>(
          value: index + 1,
          child: Text(months[index]),
        );
      },
    );
  }

  // ============================================================
  // REPORT
  // ============================================================

  Widget _buildReport() {
    return RefreshIndicator(
      onRefresh: controller.refreshReport,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildDataTable(),
        ),
      ),
    );
  }

  // ============================================================
  // DATA TABLE
  // ============================================================

  Widget _buildDataTable() {
    final data = controller.report;

    return DataTable(
      headingRowHeight: 50,
      dataRowMinHeight: 55,
      dataRowMaxHeight: 65,

      columns: const [
        DataColumn(
          label: Text(
            'SL',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'User ID',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Name',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Money ID',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Date',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Amount',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Payment Method',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Received By',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Total Amount',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],

      rows: List<DataRow>.generate(
        data.length,
            (index) {
          final item = data[index];

          return DataRow(
            cells: [
              DataCell(
                Text('${index + 1}'),
              ),

              DataCell(
                Text(item.userId),
              ),

              DataCell(
                Text(item.userName),
              ),

              DataCell(
                Text(item.moneyId),
              ),

              DataCell(
                Text(
                  DateFormat(
                    'dd-MMM-yyyy',
                  ).format(item.date),
                ),
              ),

              DataCell(
                Text(
                  '৳${item.amount.toStringAsFixed(0)}',
                ),
              ),

              DataCell(
                Text(item.paymentMethod),
              ),

              DataCell(
                Text(item.receivedBy),
              ),

              DataCell(
                Text(
                  '৳${item.totalAmount.toStringAsFixed(0)}',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: controller.refreshReport,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 250,
            child: Center(
              child: Text(
                'No data found',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}