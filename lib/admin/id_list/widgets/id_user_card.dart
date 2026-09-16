import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/cachehelper/toast.dart';
import '../../../res/apptextstyle.dart';
import '../service/id_list_service.dart';
import 'delete_id_dialog.dart';

class IdUserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final IdListService service;

  const IdUserCard({
    super.key,
    required this.user,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final userId = user['user_id']?.toString() ?? 'N/A';
    final userName = user['user']?.toString() ?? 'N/A';
    final docId = user['docId']?.toString() ?? '';
    final type = user['type']?.toString() ?? 'user';

    final isAdmin = type == 'admin';

    // 🔴 শুধু User N/A হলে Delete button দেখাবে
    final canDelete = userName == 'N/A';

    return Card(
      color: isAdmin
          ? Colors.green.shade50
          : Colors.red.shade50,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Column(
        children: [
          // =========================
          // ID RECORD
          // =========================
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    'Id record: $docId',
                    style: AppTextStyles.style12_bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Copy button
              IconButton(
                tooltip: 'Copy ID',
                icon: const Icon(
                  Icons.copy,
                  color: Colors.blue,
                ),
                onPressed: () => _copy(
                  context,
                  docId,
                ),
              ),

              // =========================
              // DELETE BUTTON
              // =========================
              if (canDelete)
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => _delete(
                    context,
                    docId: docId,
                    userId: userId,
                    userName: userName,
                    type: type,
                  ),
                ),
            ],
          ),

          // =========================
          // USER INFORMATION
          // =========================
          ListTile(
            leading: Icon(
              isAdmin
                  ? Icons.admin_panel_settings
                  : Icons.person,
              color: isAdmin
                  ? Colors.red
                  : Colors.green,
            ),

            title: Text(
              'User: $userName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    'User ID: $userId',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                IconButton(
                  tooltip: 'Copy User ID',
                  icon: const Icon(
                    Icons.copy,
                    color: Colors.blue,
                  ),
                  onPressed: () => _copy(
                    context,
                    userId,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // COPY
  // =========================

  Future<void> _copy(
      BuildContext context,
      String text,
      ) async {
    await Clipboard.setData(
      ClipboardData(text: text),
    );

    CustomToast().showToast(
      context,
      'Copied: $text',
      Colors.green,
    );
  }

  // =========================
  // DELETE
  // =========================

  Future<void> _delete(
      BuildContext context, {
        required String docId,
        required String userId,
        required String userName,
        required String type,
      }) async {
    final confirmed = await DeleteIdDialog.show(
      context,
      userId: userId,
      userName: userName,
      type: type,
    );

    if (!confirmed) return;

    try {
      await service.deleteUser(
        docId: docId,
        type: type,
      );

      if (!context.mounted) return;

      CustomToast().showToast(
        context,
        '$userId deleted successfully',
        Colors.green,
      );
    } catch (e) {
      if (!context.mounted) return;

      CustomToast().showToast(
        context,
        'Delete failed',
        Colors.red,
      );
    }
  }
}