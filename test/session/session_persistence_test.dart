import 'package:Agragami/admin/home/controller/admin_home_controller.dart';
import 'package:Agragami/admin/home/data/admin_home_repository.dart';
import 'package:Agragami/auth/prasentation/controller/auth_controller.dart';
import 'package:Agragami/core/cachehelper/chechehelper.dart';
import 'package:Agragami/core/routes/app_pages.dart';
import 'package:Agragami/core/routes/app_routes.dart';
import 'package:Agragami/user/home/domain/models/userHomeModel.dart';
import 'package:Agragami/user/home/domain/repository/home_repository.dart';
import 'package:Agragami/user/home/presentation/controller/home_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';

/// Session persistence checks.
///
/// Scenario: login once → do NOT log out → app goes to background / is
/// destroyed → next launch must still be logged in (straight to home).
///
/// Forced logout on lifecycle events (`paused` / `detached`) used to wipe
/// the session; these tests pin the fixed behaviour.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> seedSession({required String role}) async {
    SharedPreferences.setMockInitialValues({
      'isLoggedIn': true,
      'isRole': role,
      'names': 'Test Member',
      'userDocId': 'doc-1',
      'userId': 'AG26M001',
    });
    await CacheHelper.init();
  }

  /// Simulates the platform sending a lifecycle state (background/kill).
  Future<void> sendLifecycle(String state) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      'flutter/lifecycle',
      const StringCodec().encodeMessage(state),
      (_) {},
    );
    // Let unawaited async lifecycle handlers (if any) settle.
    await Future<void>.delayed(Duration.zero);
  }

  /// Lifecycle state is shared across tests in this file — reset first so
  /// every send actually produces a dispatch.
  Future<void> resetLifecycle() =>
      sendLifecycle('AppLifecycleState.resumed');

  group('restart routing', () {
    test('logged-in admin session restarts straight into admin home', () async {
      await seedSession(role: 'admin');
      expect(AppPages.getInitialRoute(), AppRoutes.adminHome);
    });

    test('logged-in user session restarts straight into user home', () async {
      await seedSession(role: 'user');
      expect(AppPages.getInitialRoute(), AppRoutes.home);
    });

    test('without a session restart lands on the login screen', () async {
      SharedPreferences.setMockInitialValues({});
      await CacheHelper.init();
      expect(AppPages.getInitialRoute(), AppRoutes.login);
    });
  });

  test('harness: lifecycle messages reach WidgetsBindingObserver', () async {
    await resetLifecycle();

    final probe = _RecordingObserver();
    WidgetsBinding.instance.addObserver(probe);

    await sendLifecycle('AppLifecycleState.paused');
    WidgetsBinding.instance.removeObserver(probe);

    expect(probe.states, contains(AppLifecycleState.paused));
  });

  test('AuthController does not auto-logout when app goes to background',
      () async {
    await seedSession(role: 'admin');
    await resetLifecycle();

    final repo = FakeAuthRepository();
    final controller = AuthController(repo);
    controller.onInit();

    await sendLifecycle('AppLifecycleState.paused');

    expect(repo.logoutCallCount, 0,
        reason: 'backgrounding must never force a logout');
    expect(CacheHelper().getLoggedIn(), isTrue);
    expect(AppPages.getInitialRoute(), AppRoutes.adminHome);

    controller.onClose();
  });

  test('AdminHomeController does not force-logout when app is destroyed',
      () async {
    await seedSession(role: 'admin');
    await resetLifecycle();

    final repo = _MockAdminHomeRepository();
    when(() => repo.getTotalUserCount(any())).thenAnswer((_) async => 0);
    when(() => repo.watchAllUsersTotalAmount())
        .thenAnswer((_) => const Stream<int>.empty());
    when(() => repo.watchProfileImage(any()))
        .thenAnswer((_) => const Stream<String>.empty());
    when(() => repo.logout()).thenAnswer((_) async {});

    final controller = AdminHomeController(repository: repo);
    controller.onInit();

    await sendLifecycle('AppLifecycleState.paused');
    await sendLifecycle('AppLifecycleState.detached');

    verifyNever(() => repo.logout());
    expect(CacheHelper().getLoggedIn(), isTrue,
        reason: 'destroying the app must keep the session for next launch');
    expect(AppPages.getInitialRoute(), AppRoutes.adminHome);

    controller.onClose();
  });

  test('HomeController does not force-logout when app is destroyed', () async {
    await seedSession(role: 'user');
    await resetLifecycle();

    final controller = HomeController(_FakeHomeRepository());
    controller.onInit();

    await sendLifecycle('AppLifecycleState.paused');
    await sendLifecycle('AppLifecycleState.detached');

    expect(CacheHelper().getLoggedIn(), isTrue);
    expect(AppPages.getInitialRoute(), AppRoutes.home);

    controller.onClose();
  });
}

class _RecordingObserver extends WidgetsBindingObserver {
  final List<AppLifecycleState> states = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    states.add(state);
  }
}

class _FakeHomeRepository implements HomeRepository {
  @override
  Future<HomeData> localCachedUserInfo() async => HomeData();

  @override
  Future<int> getAllUsersTotalAmount() async => 0;

  @override
  Stream<String> watchProfileImage(String userDocId) =>
      const Stream<String>.empty();
}

class _MockAdminHomeRepository extends Mock implements AdminHomeRepository {}
