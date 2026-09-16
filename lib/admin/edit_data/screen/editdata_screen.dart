import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/cachehelper/toast.dart';
import '../../log/service/log_service.dart';
import '../service/editdata_service.dart';
import '../widgets/amount_field.dart';
import '../widgets/date_time_field.dart';
import '../widgets/edit_user_info.dart';
import '../widgets/payment_method_field.dart';
import '../widgets/received_by_field.dart';
import '../widgets/update_button.dart';

class EditDataScreen extends StatefulWidget {
  const EditDataScreen({
    super.key,
    required this.name,
    required this.email,
    required this.userId,
    required this.money,
    required this.paymentMethod,
    required this.receivedBy,
    required this.dateTime,
    required this.moneyDocId,
  });

  final String name;
  final String email;
  final String userId;
  final String money;
  final String paymentMethod;
  final String receivedBy;
  final DateTime? dateTime;
  final String moneyDocId;

  @override
  State<EditDataScreen> createState() =>
      _EditDataScreenState();
}

class _EditDataScreenState
    extends State<EditDataScreen> {

  final TextEditingController amountController =
  TextEditingController();

  final TextEditingController receivedByController =
  TextEditingController();

  final EditDataService editService =
  EditDataService();

  final LogService logService =
  LogService();

  bool isLoading = false;

  late String selectedPaymentMethod;

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    amountController.text = widget.money;

    receivedByController.text =
        widget.receivedBy;

    selectedPaymentMethod =
    widget.paymentMethod.isNotEmpty
        ? widget.paymentMethod
        : 'Cash';

    selectedDate =
        widget.dateTime ?? DateTime.now();
  }

  Future<void> selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
      selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        selectedDate ?? DateTime.now(),
      ),
    );

    if (time == null) return;

    setState(() {
      selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> updateMoney() async {
    if (amountController.text.trim().isEmpty) {
      CustomToast().showToast(
        context,
        'Please enter amount',
        Colors.red,
      );
      return;
    }

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null) {
      CustomToast().showToast(
        context,
        'Invalid amount',
        Colors.red,
      );
      return;
    }

    if (receivedByController.text.trim().isEmpty) {
      CustomToast().showToast(
        context,
        'Please enter received by',
        Colors.red,
      );
      return;
    }

    if (selectedDate == null) {
      CustomToast().showToast(
        context,
        'Please select date',
        Colors.red,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await editService.editMoney(
        userId: widget.userId,
        moneyDocId: widget.moneyDocId,
        newAmount: amount,
        paymentMethod: selectedPaymentMethod,
        receivedBy: receivedByController.text.trim(),
        dateTime: selectedDate!,
      );

      await logService.addLog(
        name: widget.name,
        email: widget.email,
        userid: widget.userId,
        oldData:
        'Amount: ${widget.money}\n'
            'Payment Method: ${widget.paymentMethod}\n'
            'Received By: ${widget.receivedBy}\n'
            'Date: ${widget.dateTime != null ? DateFormat('dd-MMM-yyyy hh:mm a').format(widget.dateTime!) : 'N/A'}',
        newData:
        'Amount: ${amountController.text}\n'
            'Payment Method: $selectedPaymentMethod\n'
            'Received By: ${receivedByController.text}\n'
            'Date: ${DateFormat('dd-MMM-yyyy hh:mm a').format(selectedDate!)}',
        note: 'Update Money',
      );

      if (!mounted) return;

      CustomToast().showToast(
        context,
        'Money updated successfully!',
        Colors.green,
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      CustomToast().showToast(
        context,
        'Error: $e',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    receivedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User Money'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            EditUserInfo(
              name: widget.name,
              email: widget.email,
              userId: widget.userId,
            ),

            const SizedBox(height: 20),

            AmountField(
              controller: amountController,
            ),

            const SizedBox(height: 16),

            PaymentMethodField(
              value: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value;
                });
              },
            ),

            const SizedBox(height: 16),

            ReceivedByField(
              controller: receivedByController,
            ),

            const SizedBox(height: 16),

            DateTimeField(
              selectedDate: selectedDate,
              onTap: selectDateTime,
            ),

            const SizedBox(height: 25),

            UpdateButton(
              isLoading: isLoading,
              onPressed: updateMoney,
            ),
          ],
        ),
      ),
    );
  }
}