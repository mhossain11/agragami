import 'dart:async';

import 'package:Agragami/user/home/domain/models/userHomeModel.dart';
import 'package:Agragami/user/home/domain/repository/home_repository.dart';
import 'package:Agragami/user/home/presentation/controller/home_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Offline fake - no Firebase, no network. The total future is
/// injectable so tests can control exactly when (and whether) the
/// balance request resolves.
class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({
    this.cacheData = const HomeData(
      name: 'Cached Member',
      userDocId: 'doc1',
      userId: 'AG001',
    ),
    this.cacheDelay = Duration.zero,
    Future<int> Function()? total,
  }) : _total = total ?? (() async => 1234);

  final HomeData cacheData;
  final Duration cacheDelay;
  final Future<int> Function() _total;

  int cacheCalls = 0;
  int totalCalls = 0;

  @override
  Future<HomeData> localCachedUserInfo() async {
    cacheCalls++;
    if (cacheDelay > Duration.zero) {
      await Future.delayed(cacheDelay);
    }
    return cacheData;
  }

  @override
  Future<int> getAllUsersTotalAmount() {
    totalCalls++;
    return _total();
  }

  @override
  Stream<String> watchProfileImage(String userDocId) => const Stream.empty();
}

void main() {
  test('balance loads WITHOUT waiting for the cache and is never wiped by it',
      () async {
    final repository = FakeHomeRepository(
      cacheDelay: const Duration(milliseconds: 300),
      total: () async => 5000,
    );
    Get.put(HomeController(repository));
    addTearDown(Get.reset);

    // Cache is still resolving - the balance must already be there
    // (balance must not wait for localCachedUserInfo / profile image).
    await Future.delayed(const Duration(milliseconds: 100));
    final early = Get.find<HomeController>();
    expect(early.homeData.value.totalTk, 5000);
    expect(early.isBalanceLoading.value, false);
    expect(early.homeData.value.name, '');

    // Cache lands later - it must NOT wipe the balance that arrived first.
    await Future.delayed(const Duration(milliseconds: 400));
    final controller = Get.find<HomeController>();
    expect(controller.homeData.value.name, 'Cached Member');
    expect(controller.homeData.value.totalTk, 5000);
    expect(repository.totalCalls, 1);
    expect(repository.cacheCalls, 1);
  });

  test('refreshTotal does not fire duplicate balance requests', () async {
    final completer = Completer<int>();
    final repository = FakeHomeRepository(total: () => completer.future);
    Get.put(HomeController(repository));
    addTearDown(Get.reset);

    await Future.delayed(const Duration(milliseconds: 50));
    final controller = Get.find<HomeController>();
    expect(controller.isBalanceLoading.value, true); // still in flight

    // Refresh tapped while the first request is running -> ignored.
    await controller.refreshTotal();
    expect(repository.totalCalls, 1);

    completer.complete(777);
    await Future.delayed(const Duration(milliseconds: 50));
    expect(controller.homeData.value.totalTk, 777);
    expect(controller.isBalanceLoading.value, false);

    // After it finished, a refresh must work normally.
    await controller.refreshTotal();
    expect(repository.totalCalls, 2);
  });

  test('balance failure is contained - the rest of Home keeps working',
      () async {
    final repository = FakeHomeRepository(
      total: () async => throw Exception('boom'),
    );
    Get.put(HomeController(repository));
    addTearDown(Get.reset);

    await Future.delayed(const Duration(milliseconds: 100));
    final controller = Get.find<HomeController>();

    expect(controller.isBalanceLoading.value, false); // state reset
    expect(controller.homeData.value.totalTk, 0); // value untouched
    expect(controller.homeData.value.name, 'Cached Member'); // Home intact
    expect(controller.homeData.value.userDocId, 'doc1');
    expect(repository.totalCalls, 1);
  });

  test('isBalanceLoading flips while the balance request runs', () async {
    final completer = Completer<int>();
    final repository = FakeHomeRepository(total: () => completer.future);
    Get.put(HomeController(repository));
    addTearDown(Get.reset);

    final controller = Get.find<HomeController>();
    await Future.delayed(const Duration(milliseconds: 30));
    expect(controller.isBalanceLoading.value, true);

    completer.complete(42);
    await Future.delayed(const Duration(milliseconds: 50));
    expect(controller.isBalanceLoading.value, false);
    expect(controller.homeData.value.totalTk, 42);
  });
}
