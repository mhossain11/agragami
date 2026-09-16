import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../controller/monthly_controller.dart';

class UnpaidReportView extends StatelessWidget {
  const UnpaidReportView();

  @override
  Widget build(BuildContext context) {
    final controller =
    Get.find<MonthlyPaidUnpaidController>();

    return Obx(() {
      if (controller.unpaidUsers.isEmpty) {
        return const Center(
          child: Text(
            'No unpaid members',
          ),
        );
      }

      return ListView.builder(
        itemCount:
        controller.unpaidUsers.length,
        itemBuilder: (context, index) {
          final user =
          controller.unpaidUsers[index];

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  '${index + 1}',
                ),
              ),

              title: Text(
                user['userName'] ?? '',
              ),

              subtitle: Text(
                user['userId'] ?? '',
              ),

              trailing: const Chip(
                label: Text('Unpaid'),
              ),
            ),
          );
        },
      );
    });
  }
}