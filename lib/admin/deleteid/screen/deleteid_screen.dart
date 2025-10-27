import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../cachehelper/toast.dart';
import '../service/deleteid_service.dart';

class DeleteIdScreen extends StatefulWidget {
  const DeleteIdScreen({super.key});

  @override
  State<DeleteIdScreen> createState() => _DeleteIdScreenState();
}

class _DeleteIdScreenState extends State<DeleteIdScreen> {
  TextEditingController _userIdController = TextEditingController();
  bool _isLoading = false;

  final DeleteIdService _deleteIdService = DeleteIdService();

  /*Future<void> _deleteId() async {
    final userId = _userIdController.text.trim();


    if (userId.isEmpty ) {
      CustomToast().showToast(context, 'User ID are required.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      //await _deleteIdService.deleteUser(docId: userId);
       await _deleteIdService.deleteUserByAuthDoc(
           authDocId: 'HUbPbYgwEss4dIE4Uiv8',
           authuserDocId: _userIdController.text.trim());

      CustomToast().showToast(context, '$userId deleted successfully', Colors.green);


      // Optional: clear fields
      _userIdController.clear();
    } catch (e) {
      CustomToast().showToast(context, 'Error: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }*/
  Future<void> _deleteId() async {
    final userId = _userIdController.text.trim();

    if (userId.isEmpty) {
      CustomToast().showToast(context, 'User ID is required.', Colors.red);
      return;
    }

    // 🔹 Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete user "$userId"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), // Confirm delete
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return; // 🔹 Stop if user canceled

    setState(() {
      _isLoading = true;
    });

    try {
      await _deleteIdService.deleteUserByAuthDoc(
        authDocId: 'HUbPbYgwEss4dIE4Uiv8',
        authuserDocId: userId,
      );

      CustomToast().showToast(context, '$userId deleted successfully', Colors.green);
      _userIdController.clear();
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
      appBar: AppBar(
        title: const Text("Delete User Id"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User Id record',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: 300,
            height: 50,
            child: ElevatedButton(
              onPressed: _deleteId,
              child: _isLoading
                  ? const CircularProgressIndicator(
                color: Colors.white,
              )
                  : const Text(
                'Delete User Id',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
