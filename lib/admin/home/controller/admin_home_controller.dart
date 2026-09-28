import 'dart:async';

import 'package:get/get.dart';

import '../../../core/cachehelper/chechehelper.dart';
import '../../../core/routes/app_routes.dart';
import '../data/admin_home_repository.dart';

class AdminHomeController extends GetxController {
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
  final userId = ''.obs;
  final profileImage = ''.obs;

  StreamSubscription<int>? _moneySub;
  StreamSubscription<String>? _profileSub;

  @override
  void onInit() {
    super.onInit();
    _loadCounts();
    _listenToTotalMoney();
    _loadProfileFromCache();
    _listenProfileImage();
  }

  @override
  void onClose() {
    _moneySub?.cancel();
    super.onClose();
  }

  // NOTE: Session must survive app background/kill — no forced logout on
  // lifecycle events. Logout happens only via the explicit logout action.

  void _loadProfileFromCache() {
    final cache = CacheHelper();
    final cachedName = cache.getString('names');
    final cachedDocId = cache.getString('userDocId');
    final cachedUserId = cache.getString('userId');


    if (cachedName != null && cachedName.isNotEmpty) {
      name.value = cachedName;
    }

    if (cachedDocId != null && cachedDocId.isNotEmpty) {
      docId.value = cachedDocId;
    }

    if (cachedUserId != null && cachedUserId.isNotEmpty) {
      userId.value = cachedUserId;
    }
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

  void _listenProfileImage() {
    if (docId.value.isEmpty) return;

    _profileSub =
        _repository.watchProfileImage(docId.value).listen((image) {
          profileImage.value = image;
        });
  }

  Future<void> logout() async {
    await _repository.logout();
    await CacheHelper().setLoggedIn(false);
    Get.offAllNamed(AppRoutes.login);
  }
}
