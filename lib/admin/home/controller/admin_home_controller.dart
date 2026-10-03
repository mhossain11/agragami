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

  /// Hidden Developer Screen unlock: after 3 taps on the ADMIN's
  /// Developer Screen the "Delete All Money Records" button appears on
  /// Admin Home. Starts false; once true it stays true for the rest of
  /// the app run (nothing is persisted). The user side never sets it.
  final showDeleteAllMoneyButton = false.obs;

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

  /// Tap counter for the hidden 3-tap unlock on the Developer Screen.
  /// Resets after every unlock - the flag itself never goes back.
  int _developerSecretTaps = 0;

  /// Called by the Developer Screen's secret tap area (admin session
  /// only). Returns the progress message to show:
  /// 'click 1' / 'click 2' on the first two taps, and 'delete button
  /// open' on the 3rd - which also sets [showDeleteAllMoneyButton] to
  /// true and resets the counter (the flag never goes back to false).
  String onDeveloperSecretTap() {
    _developerSecretTaps++;

    if (_developerSecretTaps >= 3) {
      _developerSecretTaps = 0;
      showDeleteAllMoneyButton.value = true;
      return 'delete button open';
    }

    return 'click $_developerSecretTaps';
  }

  /// Hides the "Delete All Money Records" button on Admin Home again
  /// (called from the Delete User screen). Also resets the tap counter,
  /// so the next unlock starts from a clean 3-tap cycle.
  void hideDeleteAllMoneyButton() {
    _developerSecretTaps = 0;
    showDeleteAllMoneyButton.value = false;
  }

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
