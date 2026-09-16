import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/monthly_controller.dart';

class UnpaidReportView extends StatelessWidget {
  const UnpaidReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MonthlyPaidUnpaidController>();

    return Obx(() {
      if (controller.unpaidUsers.isEmpty) {
        return const Center(
          child: Text('No unpaid members'),
        );
      }

      return ListView.builder(
        itemCount: controller.unpaidUsers.length,
        itemBuilder: (context, index) {
          final user = controller.unpaidUsers[index];

          final userId = user['userId']?.toString() ?? '';
          final phone = user['phone']?.toString() ?? '';
          final userName = user['userName']?.toString() ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),

              title: Text(userName),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userId),

                  const SizedBox(height: 4),

                  Text(
                    phone.isEmpty
                        ? 'No WhatsApp number'
                        : phone,
                  ),
                ],
              ),

              trailing: phone.isEmpty
                  ? const Text(
                'No Number',
                style: TextStyle(
                  color: Colors.grey,
                ),
              )
                  : Obx(() {
                final sent =
                controller.isMessageSent(userId);

                return ElevatedButton.icon(
                  onPressed: sent
                      ? null
                      : () async {
                    final success =
                    await _sendWhatsAppMessage(
                      context,
                      user,
                    );

                    if (success) {
                      controller.markMessageSent(
                        userId,
                      );
                    }
                  },

                  icon: Icon(
                    sent
                        ? Icons.check
                        : Icons.message,
                  ),

                  label: Text(
                    sent ? 'Sent' : '',
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    sent ? Colors.green : null,

                    foregroundColor:
                    sent ? Colors.white : null,

                    disabledBackgroundColor:
                    sent ? Colors.green : null,

                    disabledForegroundColor:
                    sent ? Colors.white : null,
                  ),
                );
              }),
            ),
          );
        },
      );
    });
  }

  Future<bool> _sendWhatsAppMessage(
      BuildContext context,
      Map<String, dynamic> user,
      ) async {
    final controller =
    Get.find<MonthlyPaidUnpaidController>();

    final userName =
        user['userName']?.toString() ?? '';

    String phone =
        user['phone']?.toString() ?? '';

    // ==========================================
    // BANGLADESH PHONE NUMBER FORMAT
    // ==========================================

    phone = phone.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );

    if (phone.startsWith('01')) {
      phone = '880${phone.substring(1)}';
    } else if (phone.startsWith('+880')) {
      phone = phone.substring(1);
    }

    // ==========================================
    // MONTH NAME
    // ==========================================

    final monthName = DateFormat('MMMM').format(
      DateTime(
        controller.selectedYear.value,
        controller.selectedMonth.value,
      ),
    );

    final year =
        controller.selectedYear.value;

    // ==========================================
    // DEFAULT MESSAGE
    // ==========================================

    final message =
        'Assalamu Alaikum $userName,\n\n'
        'আপনার $monthName $year মাসের '
        'payment এখনো পাওয়া যায়নি।\n\n'
        'অনুগ্রহ করে আপনার payment টি '
        'সম্পন্ন করার জন্য অনুরোধ করা যাচ্ছে।\n\n'
        'ধন্যবাদ।';

    // ==========================================
    // WHATSAPP URL
    // ==========================================

    final uri = Uri.parse(
      'https://wa.me/$phone'
          '?text=${Uri.encodeComponent(message)}',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          'Error',
          'Could not open WhatsApp',
        );

        return false;
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open WhatsApp',
      );

      return false;
    }
  }
}