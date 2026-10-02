import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../domain/models/userHomeModel.dart';
import '../../domain/repository/home_repository.dart';

class HomeController extends GetxController {

  final HomeRepository repository;

  HomeController(this.repository);

  final isLoading = false.obs;
  final homeData = HomeData().obs;

  StreamSubscription<String>? _profileImageSub;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }


  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      final cached = await repository.localCachedUserInfo();
      homeData.value = cached;

      _listenProfileImage(cached.userDocId);

      final total = await repository.getAllUsersTotalAmount();
      homeData.value = homeData.value.copyWith(totalTk: total);
    } catch (e) {
      debugPrint('Home load error => $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _listenProfileImage(String userDocId) {
    _profileImageSub?.cancel();
    _profileImageSub = repository.watchProfileImage(userDocId).listen((url) {
      homeData.value = homeData.value.copyWith(profileImage: url);
    });
  }


  Future<void> refreshTotal() async {
    final total = await repository.getAllUsersTotalAmount();
    homeData.value = homeData.value.copyWith(totalTk: total);
  }

  // NOTE: No forced logout on lifecycle events — backgrounding must keep
  // the session. Cold start (kill/swipe-away) lands on the Login screen by
  // design (see core/session/session_guard.dart); logout is explicit only.

  @override
  void onClose() {
    _profileImageSub?.cancel();
    super.onClose();
  }
}
