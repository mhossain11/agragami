import 'package:Agragami/auth/domain/repository/loginResult.dart';
import 'package:Agragami/auth/prasentation/controller/auth_controller.dart';
import 'package:Agragami/core/cachehelper/chechehelper.dart';
import 'package:Agragami/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository repo;
  late AuthController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();

    repo = FakeAuthRepository();
    controller = AuthController(repo);
    controller.onInit(); // not registered with GetX: the harness uses it directly
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  /// Pumps until [message] shows up (GetX queues snackbars) and then waits
  /// for it to auto dismiss so no timer leaks into the next test.
  Future<void> expectSnackbar(
    WidgetTester tester,
    String message, {
    String? title,
  }) async {
    var found = false;
    for (var i = 0; i < 30 && !found; i++) {
      found = find.text(message).evaluate().isNotEmpty;
      if (!found) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
    expect(find.text(message), findsOneWidget);
    if (title != null) {
      expect(find.text(title), findsOneWidget);
    }

    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
  }

  Widget harness() {
    return GetMaterialApp(
      initialRoute: AppRoutes.login,
      getPages: [
        GetPage(
          name: AppRoutes.login,
          page: () => Scaffold(
            body: Form(
              key: controller.loginFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.emailController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter Email or ID';
                      }
                      if (value.contains('@') &&
                          !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: controller.passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: controller.login,
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
        GetPage(
          name: AppRoutes.home,
          page: () => const Scaffold(body: Text('USER_HOME')),
        ),
        GetPage(
          name: AppRoutes.adminHome,
          page: () => const Scaffold(body: Text('ADMIN_HOME')),
        ),
      ],
    );
  }

  Future<void> submit(
    WidgetTester tester, {
    String email = '',
    String password = '',
  }) async {
    if (email.isNotEmpty) {
      await tester.enterText(find.byType(TextFormField).at(0), email);
    }
    if (password.isNotEmpty) {
      await tester.enterText(find.byType(TextFormField).at(1), password);
    }
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
  }

  testWidgets('invalid form does not call repository and shows errors',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Please enter Email or ID'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(repo.loginCallCount, 0);
  });

  testWidgets('valid form logs in, caches session and opens user home',
      (tester) async {
    repo.loginResult = const LoginResult(role: 'user', userId: 'AG24M001');

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await submit(
      tester,
      email: '  rahim@mail.com ',
      password: 'Secret123!',
    );

    expect(repo.loginCallCount, 1);
    expect(repo.lastLoginEmail, 'rahim@mail.com');
    expect(repo.lastLoginPassword, 'Secret123!');
    expect(find.text('USER_HOME'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('isLoggedIn'), true);
    expect(prefs.getString('userId'), 'AG24M001');
    expect(prefs.getString('isRole'), 'user');
    expect(controller.isLoading.value, isFalse);
  });

  testWidgets('admin role is redirected to admin home', (tester) async {
    repo.loginResult = const LoginResult(role: 'admin', userId: 'AG24M001');

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await submit(tester, email: 'admin@mail.com', password: 'Secret123!');

    expect(find.text('ADMIN_HOME'), findsOneWidget);
    expect(find.text('USER_HOME'), findsNothing);
  });

  testWidgets('repository error shows snackbar and resets loading',
      (tester) async {
    repo.loginError = Exception('User ID not found');

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await submit(tester, email: 'AG00X001', password: 'Secret123!');

    expect(find.text('USER_HOME'), findsNothing);
    expect(controller.isLoading.value, isFalse);

    await expectSnackbar(tester, 'User ID not found', title: 'Error');
  });

  testWidgets('null repository result shows "Login Failed"', (tester) async {
    repo.loginResult = null;

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await submit(tester, email: 'rahim@mail.com', password: 'Secret123!');

    expect(controller.isLoading.value, isFalse);

    await expectSnackbar(
      tester,
      'Something went wrong',
      title: 'Login Failed',
    );
  });

  testWidgets('logout clears the session and returns to login', (tester) async {
    repo.loginResult = const LoginResult(role: 'user', userId: 'AG24M001');

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();
    await submit(tester, email: 'rahim@mail.com', password: 'Secret123!');
    expect(find.text('USER_HOME'), findsOneWidget);

    await controller.logout();
    await tester.pumpAndSettle();

    expect(repo.logoutCallCount, 1);
    expect(find.text('Login'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('isLoggedIn'), isNull);
    expect(prefs.getString('isRole'), isNull);
  });
}
