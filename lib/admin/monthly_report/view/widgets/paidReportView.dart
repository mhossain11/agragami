import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';

import '../controller/monthly_controller.dart';

class PaidReportView extends StatelessWidget {
  const PaidReportView();

  @override
  Widget build(BuildContext context) {
    final controller =
    Get.find<MonthlyController>();

    return Obx(() {
      if (controller.report.isEmpty) {
        return const Center(
          child: Text('No paid data found'),
        );
      }

      return _buildPaidTable(controller);
    });
  }

  Widget _buildPaidTable(
      MonthlyController controller,
      ) {
    final data = controller.report;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('SL')),
            DataColumn(label: Text('User ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Money ID')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Payment Method')),
            DataColumn(label: Text('Received By')),
            DataColumn(label: Text('Total Amount')),
          ],
          rows: List.generate(
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
        ),
      ),
    );
  }
}