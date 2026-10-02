import 'package:Agragami/admin/home/controller/admin_home_controller.dart';
import 'package:Agragami/admin/home/data/admin_home_repository.dart';
import 'package:Agragami/auth/prasentation/controller/auth_controller.dart';
import 'package:Agragami/core/cachehelper/chechehelper.dart';
import 'package:Agragami/core/routes/app_pages.dart';
import 'package:Agragami/core/routes/app_routes.dart';
import 'package:Agragami/core/session/session_guard.dart';
import 'package:Agragami/user/home/domain/models/userHomeModel.dart';
import 'package:Agragami/user/home/domain/repository/home_repository.dart';
import 'package:Agragami/user/home/presentation/controller/home_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';

/// Session behaviour — launch-time session validation.
///
/// Spec:
///  1. Login succeeds -> session saved (userId, role, isLoggedIn) and the
///     user is taken to Home/Admin.
///  2. Background / foreground (paused, inactive, hidden, resumed, even
///     `detached`) -> NEVER logout, NEVER clear the session: same process,
///     the user returns exactly where they were.
///  3. Process death (swipe-away from Recent Apps, OOM kill, crash, reboot)
///     -> Android delivers no reliable callback, so validation happens at
///     LAUNCH: `SessionGuard.invalidatePreviousSession()` drops the cached
///     session (+ best-effort Firebase sign-out) and
///     `AppPages.getInitialRoute()` always returns the Login screen.
///
/// Nothing logs out from a lifecycle event — only the explicit logout
/// action or a fresh launch ends the session.
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

  group('launch-time session validation (kill / swipe-away -> Login)', () {
    test('cold start lands on Login even with a seeded admin session',
        () async {
      await seedSession(role: 'admin');
      expect(AppPages.getInitialRoute(), AppRoutes.login);
    });

    test('cold start lands on Login even with a seeded user session',
        () async {
      await seedSession(role: 'user');
      expect(AppPages.getInitialRoute(), AppRoutes.login);
    });

    test('without a session restart lands on the login screen', () async {
      SharedPreferences.setMockInitialValues({});
      await CacheHelper.init();
      expect(AppPages.getInitialRoute(), AppRoutes.login);
    });

    test(
        'invalidatePreviousSession clears the app session but keeps userId '
        'for login prefill', () async {
      await seedSession(role: 'user');

      await SessionGuard.invalidatePreviousSession();

      expect(CacheHelper().getLoggedIn(), isFalse,
          reason: 'stale login flag must not survive a cold start');
      expect(CacheHelper().getString('isRole'), isNull,
          reason: 'stale role must never auto-enter Home/Admin');
      expect(CacheHelper().getString('userId'), 'AG26M001',
          reason: 'userId is kept to prefill the login form');
      expect(CacheHelper().getString('userDocId'), 'doc-1',
          reason: 'userDocId is rewritten by the next login anyway');
    });

    test(
        'full flow: session survives while running, is dropped on next launch',
        () async {
      await seedSession(role: 'admin');
      await resetLifecycle();

      // Process still alive: background / destroy must keep everything.
      await sendLifecycle('AppLifecycleState.paused');
      await sendLifecycle('AppLifecycleState.detached');
      expect(CacheHelper().getLoggedIn(), isTrue,
          reason: 'while the process lives, the session stays valid');
      expect(CacheHelper().getString('isRole'), 'admin');

      // Next launch = fresh process = launch-time invalidation -> Login.
      await SessionGuard.invalidatePreviousSession();
      expect(CacheHelper().getLoggedIn(), isFalse);
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
    expect(CacheHelper().getString('isRole'), 'admin',
        reason: 'session data must stay untouched while running');

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
        reason: 'a lifecycle event must never clear the session');
    expect(CacheHelper().getString('isRole'), 'admin');

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
    expect(CacheHelper().getString('isRole'), 'user');

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
