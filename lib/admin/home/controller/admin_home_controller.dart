import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/cachehelper/chechehelper.dart';
import '../../../core/routes/app_routes.dart';
import '../data/admin_home_repository.dart';

class AdminHomeController extends GetxController with WidgetsBindingObserver {
  AdminHomeController({required AdminHomeRepository repository})
      : _repository = repository;

  final AdminHomeRepository _repository;

  // ── Reactive state ────────────────────────────────────────────────
  final isLoading = false.obs;
  final userTotal = 0.obs;
  final adminTotal = 0.obs;
  final totalTk = 0.obs;
  final name = ''.obs;
  final docId = ''.obs;

  StreamSubscription<int>? _moneySub;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadProfileFromCache();
    _loadCounts();
    _listenToTotalMoney();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _moneySub?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      await _repository.logout();
      await CacheHelper().setLoggedIn(false);
    }
  }

  void _loadProfileFromCache() {
    final cache = CacheHelper();
    final userName = cache.getString('names');
    final userDocId = cache.getString('userDocId');

    if (userName == null || userName.isEmpty) return;
    if (userDocId == null || userDocId.isEmpty) return;

    name.value = userName;
    docId.value = userDocId;
  }

  Future<void> _loadCounts() async {
    isLoading.value = true;
    userTotal.value = await _repository.getTotalUserCount('user');
    adminTotal.value = await _repository.getTotalUserCount('admin');
    isLoading.value = false;
  }

  void _listenToTotalMoney() {
    _moneySub = _repository.watchAllUsersTotalAmount().listen((total) {
      print('TOTAL MONEY = $total');
      totalTk.value = total;
    });
  }

  /// Pull-to-refresh handler — re-reads counts; the money total stays
  /// live via the stream subscription.
  Future<void> refresh() => _loadCounts();

  Stream<String> profileImageStream() {
    if (docId.value.isEmpty) return const Stream.empty();
    return _repository.watchProfileImage(docId.value);
  }

  Future<void> logout() async {
    await _repository.logout();
    await CacheHelper().setLoggedIn(false);
    Get.offAllNamed(AppRoutes.login);
  }
}
