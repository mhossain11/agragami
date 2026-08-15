
import 'package:flutter/material.dart';

import '../../../core/cachehelper/toast.dart';
import '../../../core/widgets/text_field.dart';
import '../../log/service/log_service.dart';
import '../service/editdata_service.dart';

class EditDataScreen extends StatefulWidget {
  const EditDataScreen({super.key,
    required this.name,
    required this.email,
    required this.userId,
    required this.money});

  final String name;
  final String email;
  final String userId;
  final String money;

  @override
  State<EditDataScreen> createState() => _EditDataScreenState();
}

class _EditDataScreenState extends State<EditDataScreen> {
  final TextEditingController _amountController = TextEditingController();
  final EditDataService _editService =EditDataService();
  final LogService _logService = LogService();
  bool _isLoading = false;
  String? _error;


  @override
  void initState() {
    super.initState();
    _amountController.text = widget.money;
  }

  Future<void> _updateMoney() async {
    if (_amountController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _editService.editMoney(
        userId: widget.userId,
        newAmount: double.parse(_amountController.text),
      );
      CustomToast().showToast(context,'Money updated successfully!', Colors.green);
      Navigator.pop(context); // Back to previous screen
    } catch (e) {
      CustomToast().showToast(context,'Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _amountController.dispose();

  }
  @override
  Widget build(BuildContext context) {
    print('Taka: ${widget.money}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Money'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(widget.name),
              subtitle: Text(widget.email),
              trailing: Text("ID: ${widget.userId}"),
            ),
          ),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextField(
              controller: _amountController,
              labelText: 'Amount',),
          ),
          SizedBox(height: 20,),
          Container(
            padding:EdgeInsets.all(5),
            width: 200,
            child: ElevatedButton(onPressed:()async{
              _updateMoney();
              await _logService.addLog(
                name: widget.name,
                email: widget.email,
                userid: widget.userId,
                oldData: widget.money,
                newData: _amountController.text,
                note: 'Update Money'
              );
            } ,
                child: const Text('Update Money')),
          ),

        ],
      ),
    );
  }
}
