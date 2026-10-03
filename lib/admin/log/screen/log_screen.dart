import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/log_model.dart';
import '../service/log_service.dart';

/// Real-time Admin Audit Log.
///
/// Shows only the CURRENT admin's own folder
/// (`users/{adminDocId}/Log`), newest first, and updates automatically
/// when a new action is logged — no manual refresh.
///
/// All Firestore work lives in [LogService]; all parsing in [LogModel].
/// This file is UI only: loading / error / empty / pending-timestamp
/// states, no nested Scaffold, no hard-coded ids.
class LogScreen extends StatelessWidget {
  LogScreen({super.key});

  final LogService _logService = LogService.instance;

  @override
  Widget build(BuildContext context) {
    // Admin id comes from the login cache — synchronous, no FutureBuilder
    // (and no Future rebuilt on every frame like the old screen did).
    final String? adminDocId = _logService.adminDocId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Log'),
      ),
      body: adminDocId == null || adminDocId.isEmpty
          ? const _CenterMessage(
              'Admin session not found.\nPlease log out and log in again.',
            )
          : StreamBuilder<List<LogModel>>(
              stream: _logService.watchLogs(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Log stream error: ${snapshot.error}');
                  return _CenterMessage(_friendlyError(snapshot.error));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final logs = snapshot.data ?? const <LogModel>[];
                if (logs.isEmpty) {
                  return const _CenterMessage('No Logs Found');
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: logs.length,
                  itemBuilder: (context, index) =>
                      _LogTile(log: logs[index]),
                );
              },
            ),
    );
  }

  String _friendlyError(Object? error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to view these logs.';
        case 'unavailable':
          return 'No internet connection. Please try again.';
        default:
          return 'Could not load the logs (${error.code}).';
      }
    }
    return 'Could not load the logs. Please try again.';
  }
}

// ============================================================
// Reusable widgets
// ============================================================

class _CenterMessage extends StatelessWidget {
  const _CenterMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

/// One log entry card:
///
/// Admin Name / Admin Email / Target User / Old / New / Action / Time.
class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});

  final LogModel log;

  static final DateFormat _timeFormat = DateFormat('dd-MM-yyyy hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Admin (who performed the action) ----
            Text(
              log.adminName.isEmpty ? 'Unknown admin' : log.adminName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              log.adminEmail.isEmpty ? '-' : log.adminEmail,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // ---- Action details (target user + change) ----
            _row('Target User', log.targetUserId),
            _row('Old', log.oldData),
            _row('New', log.newData),
            _row(
              'Action',
              log.action,
              valueColor: Colors.red[700],
            ),
            const SizedBox(height: 6),

            // ---- Time ----
            Text(
              'Time: ${_formatTime()}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// `datetime` is null while `FieldValue.serverTimestamp()` is still
  /// pending (or if the field is missing) — show a placeholder instead
  /// of crashing.
  String _formatTime() {
    final DateTime? dt = log.datetime;
    if (dt == null) return 'Saving…';
    return _timeFormat.format(dt);
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: value.isEmpty ? '-' : value,
              style: TextStyle(color: valueColor),
            ),
          ],
        ),
      ),
    );
  }
}
