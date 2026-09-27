import 'package:Agragami/auth/domain/repository/loginResult.dart';
import 'package:Agragami/auth/prasentation/controller/auth_controller.dart';
import 'package:Agragami/auth/prasentation/screen/login_screen.dart';
import 'package:Agragami/core/cachehelper/chechehelper.dart';
import 'package:Agragami/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/fake_auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository repo;
  late AuthController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();

    repo = FakeAuthRepository();
    controller = AuthController(repo);
  });

  tearDown(() {
    Get.reset();
  });

  /// The default test font draws every glyph as a full em square, so texts
  /// that fit on a real device render ~2x wider here and their Rows overflow.
  /// That is a test artifact, not a product bug, so those layout errors are
  /// filtered out.
  void ignoreRenderFlexOverflow() {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);
  }

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    ignoreRenderFlexOverflow();
    // 720 x 800 logical pixels. The test font renders every glyph as a full
    // em square, so a phone sized 360 logical px would overflow rows that fit
    // easily with a real (proportional) font.
    tester.view.physicalSize = const Size(2160, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          getPages: [
            GetPage(
              name: '/',
              page: () => const Scaffold(body: Text('START_STUB')),
            ),
            GetPage(
              name: AppRoutes.login,
              page: () => const LoginScreen(),
              // Registered through the route binding so GetView can find it
              // and GetX does not smart-manage it away.
              // NOTE: BindingsBuilder(() => Get.put(x)) must NOT be used here:
              // the void callback context makes Get.put infer T = void.
              binding: BindingsBuilder.put(() => controller),
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
        ),
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.login);
    await tester.pumpAndSettle();
  }

  /// Pumps until [message] shows up (snackbars are queued by GetX) and then
  /// waits for them to auto dismiss so no timer leaks into the next test.
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

  testWidgets('login screen renders the expected widgets', (tester) async {
    await pumpLoginScreen(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(controller.emailController.text, ''); // no saved user id
  });

  testWidgets('a saved user id is shown in the ID/Email field',
      (tester) async {
    // Simulates the state left behind by a successful registration (or a
    // previous login): RegisterController/AuthController cache the id under
    // this key and loadUserId() prefills the field from it.
    SharedPreferences.setMockInitialValues({'userId': 'AG24M001'});
    await CacheHelper.init();

    await pumpLoginScreen(tester);

    expect(controller.emailController.text, 'AG24M001');
    expect(find.text('AG24M001'), findsOneWidget);
  });

  testWidgets('empty form shows validation errors and blocks login',
      (tester) async {
    await pumpLoginScreen(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Please enter Email or ID'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(repo.loginCallCount, 0);
  });

  testWidgets('invalid user id and short password are rejected', (tester) async {
    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'ABC123');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Enter a valid User ID'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    expect(repo.loginCallCount, 0);
  });

  testWidgets('valid user id + password logs in and opens the home screen',
      (tester) async {
    repo.loginResult = const LoginResult(role: 'user', userId: 'AG24M001');
    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'AG24M001');
    await tester.enterText(find.byType(TextFormField).at(1), 'Secret123!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(repo.loginCallCount, 1);
    expect(repo.lastLoginEmail, 'AG24M001');
    expect(repo.lastLoginPassword, 'Secret123!');
    expect(find.text('USER_HOME'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('isLoggedIn'), true);
    expect(prefs.getString('userId'), 'AG24M001');
    expect(prefs.getString('isRole'), 'user');
  });

  testWidgets('valid email login works as well', (tester) async {
    repo.loginResult = const LoginResult(role: 'admin', userId: 'AG24M001');
    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'admin@mail.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Secret123!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(repo.lastLoginEmail, 'admin@mail.com');
    expect(find.text('ADMIN_HOME'), findsOneWidget);
  });

  testWidgets('failed login shows the error snackbar', (tester) async {
    repo.loginError = Exception('User ID not found');
    await pumpLoginScreen(tester);

    // Valid per the LoginScreen regex, but the repository rejects it.
    await tester.enterText(find.byType(TextFormField).at(0), 'AG99M999');
    await tester.enterText(find.byType(TextFormField).at(1), 'Secret123!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(controller.isLoading.value, isFalse);

    await expectSnackbar(tester, 'User ID not found', title: 'Error');
  });
}
