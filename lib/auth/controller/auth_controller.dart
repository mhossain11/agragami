import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';


class AuthController extends GetxController{

  final isUpdateAvailable = false.obs;
  final latestVersion = ''.obs;
  final releaseUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      final currentVersion = packageInfo.version;

      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/faysalfh11/invoice_maker/releases/latest',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final latest =
        data['tag_name']
            .toString()
            .replaceFirst('v-', '');

        if (latest != currentVersion) {
          if (data['assets'] != null &&
              data['assets'].isNotEmpty) {
            isUpdateAvailable.value = true;
            latestVersion.value = latest;
            releaseUrl.value =
            data['assets'][0]['browser_download_url'];

            showUpdateDialog();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

  }

  void showUpdateDialog() {
    Get.defaultDialog(
      title: "Update Available",
      middleText:
      "New version $latestVersion is available.",
      textCancel: "Later",
      textConfirm: "Update",
      onConfirm: () async {
        Get.back();

        await launchUrl(
        Uri.parse(releaseUrl.value),
        mode: LaunchMode.externalApplication,
        );
      },
    );
  }
}