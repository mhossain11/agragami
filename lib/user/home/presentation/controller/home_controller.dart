import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../domain/models/userHomeModel.dart';
import '../../domain/repository/home_repository.dart';

class HomeController extends GetxController {

  final HomeRepository repository;

  HomeController(this.repository);

  final isLoading = false.obs;

  /// True while ONLY the balance request is in flight - drives the small
  /// spinner in the balance card (no other Home widget rebuilds on it).
  final isBalanceLoading = false.obs;
  final homeData = HomeData().obs;

  StreamSubscription<String>? _profileImageSub;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }


  Future<void> _loadInitialData() async {
    isLoading.value = true;

    // Balance gets its own race: it starts NOW and never waits for
    // localCachedUserInfo(), the profile image or any other home data.
    final balanceFuture = _loadBalance();

    try {
      final cached = await repository.localCachedUserInfo();
      // If the balance (or the image stream) already landed while the
      // cache was resolving, keep it - a slower cache write must not
      // wipe a value that arrived first.
      final arrived = homeData.value;
      homeData.value = cached.copyWith(
        totalTk: arrived.totalTk,
        profileImage: arrived.profileImage,
      );

      _listenProfileImage(cached.userDocId);
    } catch (e) {
      debugPrint('Home load error => $e');
    } finally {
      isLoading.value = false;
    }

    await balanceFuture;
  }

  void _listenProfileImage(String userDocId) {
    _profileImageSub?.cancel();
    _profileImageSub = repository.watchProfileImage(userDocId).listen((url) {
      homeData.value = homeData.value.copyWith(profileImage: url);
    });
  }


  /// Loads ONLY the balance. Single owner of [isBalanceLoading]: a call
  /// arriving while one is already in flight is ignored (no duplicate
  /// Firestore request), and any failure is caught here so the rest of
  /// the Home screen keeps working.
  Future<void> _loadBalance() async {
    if (isBalanceLoading.value) return;
    isBalanceLoading.value = true;
    try {
      final total = await repository.getAllUsersTotalAmount();
      homeData.value = homeData.value.copyWith(totalTk: total);
    } catch (e) {
      debugPrint('Balance load error => $e');
    } finally {
      isBalanceLoading.value = false;
    }
  }

  /// Public balance refresh - same guarded path as the initial load.
  Future<void> refreshTotal() => _loadBalance();

  // NOTE: No forced logout on lifecycle events — backgrounding must keep
  // the session. Cold start (kill/swipe-away) lands on the Login screen by
  // design (see core/session/session_guard.dart); logout is explicit only.

  @override
  void onClose() {
    _profileImageSub?.cancel();
    super.onClose();
  }
}
