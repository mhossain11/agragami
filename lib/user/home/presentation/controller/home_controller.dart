import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/cachehelper/chechehelper.dart';
import '../../domain/models/userHomeModel.dart';
import '../../domain/repository/home_repository.dart';

class HomeController extends GetxController with WidgetsBindingObserver {

  final HomeRepository repository;

  HomeController(this.repository);

  final isLoading = false.obs;
  final homeData = HomeData().obs;

  StreamSubscription<String>? _profileImageSub;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached) {
      _forceLogoutOnDetach();
    }
  }

  Future<void> _forceLogoutOnDetach() async {
    await FirebaseAuth.instance.signOut();
    await CacheHelper().setLoggedIn(false);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _profileImageSub?.cancel();
    super.onClose();
  }
}
