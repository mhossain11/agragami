import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../admin/id_create/screen/create_id_screen.dart';
import '../../../contact/screen/contact_screen.dart';
import '../../../developer/developer_screen.dart';
import '../../deleteid/screen/deleteid_screen.dart';
import '../../id_list/screen/id_list_screen.dart';
import '../../log/screen/log_screen.dart';
import '../../moneydelete/screen/moneydelete_screen.dart';
import '../../notification/screen/note_screen.dart';
import '../../notification/service/note_service.dart';
import '../../pdf/screen/pdf_generate_screen.dart';
import '../../profile/screen/profile_screen.dart';
import '../../save_money/screen/saving_money_screen.dart';
import '../../userlist/screen/userlist_screen.dart';
import '../controller/admin_home_controller.dart';
import 'widgets/admin_actions_menu.dart';
import 'widgets/dashboard_menu_card.dart';
import 'widgets/notification_bell.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/stat_card.dart';

class AdminHomeScreen extends GetView<AdminHomeController> {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildGreeting(),
              _buildMemberStatsRow(),
              _buildBalanceCard(),
              _buildRow(
                left: DashboardMenuCard(
                  assetPath: 'assets/images/taka.png',
                  label: 'Saving Money',
                  onTap: () => Get.to(() => SavingMoneyScreen()),
                ),
                right: DashboardMenuCard(
                  assetPath: 'assets/images/userlist.png',
                  label: 'Members List',
                  onTap: () => Get.to(() => UserListScreen()),
                ),
              ),
              _buildRow(
                left: DashboardMenuCard(
                  assetPath: 'assets/images/log.png',
                  label: 'Admin Log',
                  onTap: () => Get.to(() => LogScreen()),
                ),
                right: DashboardMenuCard(
                  assetPath: 'assets/images/delete_report.png',
                  label: 'Delete Record',
                  maxLines: 2,
                  onTap: () => Get.to(() => MoneyDeleteSimpleScreen()),
                ),
              ),
              const SizedBox(height: 10),
              DashboardMenuCard(
                assetPath: 'assets/images/notes.png',
                label: 'Notice board',
                width: 300,
                maxLines: 2,
                onTap: () => Get.to(() => NoteScreen()),
              ),
              _buildRow(
                left: DashboardMenuCard(
                  assetPath: 'assets/images/id.png',
                  label: 'User Id Create',
                  width: 150.w,
                  height: 150.h,
                  onTap: () => Get.to(() => const CreateIdScreen()),
                ),
                right: DashboardMenuCard(
                  assetPath: 'assets/images/id_list.png',
                  label: 'User Id List',
                  width: 150.w,
                  height: 150.h,
                  onTap: () => Get.to(() => IdListScreen()),
                ),
              ),
              DashboardMenuCard(
                assetPath: 'assets/images/delete_id.png',
                label: 'Delete Id',
                width: 150.w,
                height: 150.h,
                onTap: () => Get.to(() => DeleteIdScreen()),
              ),
              const SizedBox(height: 10),
              DashboardMenuCard(
                assetPath: 'assets/images/pdf.png',
                label: 'Generate a Pdf',
                width: 300.w,
                height: 150.h,
                maxLines: 2,
                onTap: () => Get.to(() => UserMoneyScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Admin Home'),
      centerTitle: true,
      leading: Obx(() {
        if (controller.docId.value.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: CircleAvatar(child: Icon(Icons.person)),
          );
        }
        return ProfileAvatar(
          imageStream: controller.profileImageStream(),
          onTap: () => Get.to(
            () => ProfileScreen(userId: controller.docId.value),
          ),
        );
      }),
      actions: [
        Obx(
          () => NotificationBell(
            noteService: Get.find<NoteService>(),
            adminDocId: controller.docId.value,
          ),
        ),
        AdminActionsMenu(onSelected: (action) => _onAction(action)),
      ],
    );
  }

  void _onAction(AdminAction action) {
    switch (action) {
      case AdminAction.logout:
        controller.logout();
        break;
      case AdminAction.profile:
        Get.to(() => ProfileScreen(userId: controller.docId.value));
        break;
      case AdminAction.contact:
        Get.to(() => ContactScreen(color: Colors.green));
        break;
      case AdminAction.aboutDeveloper:
        Get.to(() => DeveloperScreen(color: Colors.green));
        break;
    }
  }

  Widget _buildGreeting() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Obx(
              () => Text(
                controller.name.value,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Obx(
              () => StatCard(
                value: controller.userTotal.value.toString(),
                label: 'Total Members',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Obx(
        () => StatCard(
          value: '${controller.totalTk.value} Tk',
          label: 'Balance',
          width: 300,
        ),
      ),
    );
  }

  Widget _buildRow({required Widget left, required Widget right}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [left, const SizedBox(width: 10), right],
    );
  }
}
