import 'package:flutter/material.dart';

import '../../../cachehelper/chechehelper.dart';
import '../../../cachehelper/toast.dart';
import '../../log/service/log_service.dart';
import '../service/moneydelete_service.dart';

class MoneyDeleteSimpleScreen extends StatefulWidget {
  const MoneyDeleteSimpleScreen({super.key});

  @override
  State<MoneyDeleteSimpleScreen> createState() =>
      _MoneyDeleteSimpleScreenState();
}

class _MoneyDeleteSimpleScreenState extends State<MoneyDeleteSimpleScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _moneyDocIdController = TextEditingController();
  final MoneyDeleteService _deleteService = MoneyDeleteService();
  final LogService _logService = LogService();
  String adminName='';
  String adminDocId='';
  String adminId='';
  String adminEmail='';
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    getName();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _moneyDocIdController.dispose();
    super.dispose();
  }
  Future<String?> getName() async {
    final userName =  await CacheHelper().getString('names');
    final userDocId =  await CacheHelper().getString('userDocId');
    var Id =  await CacheHelper().getString('adminId');
    final email =  await CacheHelper().getString('email');


    if (userName == null || userName.isEmpty) {
      debugPrint('Error: Name not found in cache!');
      return null;
    }

    if (userDocId == null || userDocId.isEmpty) {
      debugPrint('Error: UserDocId not found in cache!');
      return null;
    }

    if (Id == null || Id.isEmpty) {
      debugPrint('Error: Id not found in cache!');
      return null;
    }

    if (email == null || email.isEmpty) {
      debugPrint('Error: email not found in cache!');
      return null;
    }
    setState(() {
      adminName = userName;
      adminDocId = userDocId;
      adminId = Id;
      adminEmail = email  ;
    });
    return null;
  }

  Future<void> _deleteMoney() async {
    final userId = _userIdController.text.trim();
    final moneyDocId = _moneyDocIdController.text.trim();

    if (userId.isEmpty || moneyDocId.isEmpty) {
      CustomToast().showToast(context, 'Both fields are required', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _deleteService.deleteMoneyByUserId(
        userId: userId,
        moneyDocId: moneyDocId,
      );

      await _logService.addLog(
          name: adminName ?? 'Unknown',
          email: adminEmail ?? 'N/A',
          userid: adminId ?? 'N/A',
          oldData: userId ?? '0',
          newData: moneyDocId,
          note: 'Money Record Delete'
      );
      CustomToast().showToast(context, 'Record deleted successfully', Colors.green);

      // Optional: clear fields
      _userIdController.clear();
      _moneyDocIdController.clear();
    } catch (e) {
      CustomToast().showToast(context, 'Error: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Money Record')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _moneyDocIdController,
              decoration: const InputDecoration(
                labelText: 'Money ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _deleteMoney,
                child: _isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  'Delete',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
