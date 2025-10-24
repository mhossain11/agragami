import 'package:flutter/material.dart';

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

  bool _isLoading = false;

  @override
  void dispose() {
    _userIdController.dispose();
    _moneyDocIdController.dispose();
    super.dispose();
  }

  Future<void> _deleteMoney() async {
    final userId = _userIdController.text.trim();
    final moneyDocId = _moneyDocIdController.text.trim();

    if (userId.isEmpty || moneyDocId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both fields are required')),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted successfully')),
      );

      // Optional: clear fields
      _userIdController.clear();
      _moneyDocIdController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
                labelText: 'Money Document ID',
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
