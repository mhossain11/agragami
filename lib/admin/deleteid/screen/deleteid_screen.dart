import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../cachehelper/chechehelper.dart';
import '../../../cachehelper/toast.dart';
import '../../log/service/log_service.dart';
import '../service/deleteid_service.dart';

class DeleteIdScreen extends StatefulWidget {
  const DeleteIdScreen({super.key});

  @override
  State<DeleteIdScreen> createState() => _DeleteIdScreenState();
}

class _DeleteIdScreenState extends State<DeleteIdScreen> {
 final TextEditingController _userIdController = TextEditingController();
  final LogService _logService = LogService();
  bool _isLoading = false;
  String name='';
  String DocId='';
  String email='';
  String adminId='';

  final DeleteIdService _deleteIdService = DeleteIdService();


 @override
  void initState() {
    super.initState();
    getName();
  }
 Future<String?> getName() async {
    name =  (await CacheHelper().getString('names'))!;
    DocId =  (await CacheHelper().getString('userDocId'))!;
    adminId =  (await CacheHelper().getString('adminId'))!;
    email =  (await CacheHelper().getString('email'))!;
   if (name == null || name.isEmpty) {
     debugPrint('Error: Name not found in cache!');
     return null;
   }if (adminId == null ||adminId.isEmpty) {
     debugPrint('Error: Name not found in cache!');
     return null;
   }

   if (DocId == null || DocId.isEmpty) {
     debugPrint('Error: UserDocId not found in cache!');
     return null;
   }
   if (email == null || email.isEmpty) {
     debugPrint('Error: Name not found in cache!');
     return null;
   }
   setState(() {
     name = name;
     DocId = DocId;
     email = email;
     adminId = adminId;
   });
 }

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
      await _deleteIdService.deleteUserByAuthUid(
        authDocId: 'HUbPbYgwEss4dIE4Uiv8',
        authUserDocId: userId,
      );
      await _logService.addLog(
          name:  name,
          email: email,
          userid:  adminId,
          oldData:  'N/A',
          newData: userId,
          note: 'User Id:$userId deleted'
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
        title: const Text("Delete User"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'Id record',
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
