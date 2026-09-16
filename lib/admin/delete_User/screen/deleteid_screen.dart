/*
import 'package:flutter/material.dart';

import '../../../core/cachehelper/chechehelper.dart';
import '../../../core/cachehelper/toast.dart';
import '../../log/service/log_service.dart';
import '../service/deleteid_service.dart';

class DeleteIdScreen extends StatefulWidget {
  const DeleteIdScreen({super.key});

  @override
  State<DeleteIdScreen> createState() => _DeleteIdScreenState();
}

class _DeleteIdScreenState extends State<DeleteIdScreen> {
  final TextEditingController _userIdController =
  TextEditingController();
  final TextEditingController _moneyIdController =
  TextEditingController();

  final LogService _logService = LogService();
  final DeleteIdService _deleteIdService =
  DeleteIdService();

  bool _isLoading = false;

  String name = '';
  String docId = '';
  String email = '';
  String adminId = '';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      final cachedName =
      CacheHelper().getString('names');

      final cachedDocId =
      CacheHelper().getString('userDocId');

      final cachedAdminId =
      CacheHelper().getString('adminId');

      final cachedEmail =
      CacheHelper().getString('email');

      if (cachedName == null || cachedName.isEmpty) {
        debugPrint('Error: Name not found in cache!');
        return;
      }

      if (cachedDocId == null || cachedDocId.isEmpty) {
        debugPrint(
          'Error: UserDocId not found in cache!',
        );
        return;
      }

      if (cachedAdminId == null || cachedAdminId.isEmpty) {
        debugPrint(
          'Error: adminId not found in cache!',
        );
        return;
      }

      if (cachedEmail == null || cachedEmail.isEmpty) {
        debugPrint(
          'Error: Email not found in cache!',
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        name = cachedName;
        docId = cachedDocId;
        adminId = cachedAdminId;
        email = cachedEmail;
      });
    } catch (e) {
      debugPrint('Error loading cache: $e');
    }
  }

  Future<void> _deleteId() async {
    final userId =
    _userIdController.text.trim();

    if (userId.isEmpty) {
      CustomToast().showToast(
        context,
        'User ID is required.',
        Colors.red,
      );
      return;
    }

    // Admin info check
    if (adminId.isEmpty) {
      CustomToast().showToast(
        context,
        'Admin ID not found in cache.',
        Colors.red,
      );
      return;
    }

    final bool? confirm =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete user "$userId"?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _deleteIdService.deleteUserByAuthUid(
        authDocId: 'HUbPbYgwEss4dIE4Uiv8',
        authUserDocId: _userIdController.text.trim(),
        moneyDocId: _moneyIdController.text.trim(),
      );

      await _logService.addLog(
        name: name,
        email: email,
        userid: adminId,
        oldData: 'N/A',
        newData: userId,
        note: 'User Id:$userId deleted',
      );

      if (!mounted) return;

      CustomToast().showToast(
        context,
        '$userId deleted successfully',
        Colors.green,
      );

      _userIdController.clear();
    } catch (e) {
      if (!mounted) return;

      CustomToast().showToast(
        context,
        'Error: $e',
        Colors.red,
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete User'),
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
              onPressed:
              _isLoading ? null : _deleteId,
              child: _isLoading
                  ? const SizedBox(
                height: 22,
                width: 22,
                child:
                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Delete User Id',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import '../../../core/cachehelper/chechehelper.dart';
import '../../../core/cachehelper/toast.dart';
import '../../log/service/log_service.dart';
import '../service/deleteid_service.dart';

class DeleteUserScreen extends StatefulWidget {
  const DeleteUserScreen({super.key});

  @override
  State<DeleteUserScreen> createState() => _DeleteUserScreenState();
}

class _DeleteUserScreenState extends State<DeleteUserScreen> {
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
  Future<void> getName() async {
    try {
      final cachedName = CacheHelper().getString('names');
      final cachedDocId = CacheHelper().getString('userDocId');
      final cachedAdminId = CacheHelper().getString('userId');
      final cachedEmail = CacheHelper().getString('email');

      if (!mounted) return;

      setState(() {
        name = cachedName ?? '';
        DocId = cachedDocId ?? '';
        adminId = cachedAdminId ?? '';
        email = cachedEmail ?? '';
      });

      debugPrint('Name: $name');
      debugPrint('DocId: $DocId');
      debugPrint('AdminId: $adminId');
      debugPrint('Email: $email');
    } catch (e) {
      debugPrint('getName Error: $e');
    }
  }

  Future<void> _deleteId() async {
    final userId = _userIdController.text.trim();

    if (userId.isEmpty) {
      CustomToast().showToast(
        context,
        'User ID is required.',
        Colors.red,
      );
      return;
    }

    if (adminId.isEmpty) {
      CustomToast().showToast(
        context,
        'Admin ID not found in cache.',
        Colors.red,
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'User ID: $userId\n\n'
              'এই User-এর সব information এবং সব Money permanently delete হবে.\n'
              'Continue করতে চান?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // User + ALL Money delete
      await _deleteIdService.deleteAllMoney(
        userId: _userIdController.text.trim(),
      );

      // Admin Log থাকবে
      await _logService.addLog(
        name: name,
        email: email,
        userid: adminId,
        oldData: 'N/A',
        newData: userId,
        note: 'User ID: $userId deleted',
      );

      if (!mounted) return;

      CustomToast().showToast(
        context,
        '$userId deleted successfully',
        Colors.green,
      );

      _userIdController.clear();
    } catch (e) {
      if (!mounted) return;

      CustomToast().showToast(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
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
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: 300,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _deleteId,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Delete User',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

