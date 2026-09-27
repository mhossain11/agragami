import 'dart:io';

import 'package:Agragami/auth/binding/auth_binding.dart';
import 'package:Agragami/auth/domain/repository/auth_repository.dart';
import 'package:Agragami/auth/prasentation/controller/auth_controller.dart';
import 'package:Agragami/auth/prasentation/controller/auth_register_controller.dart';
import 'package:Agragami/auth/prasentation/screen/login_screen.dart';
import 'package:Agragami/auth/prasentation/screen/register_screen.dart';
import 'package:Agragami/core/cachehelper/chechehelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth_repository.dart';

const validId = 'AG24M001';

/// Finds the project root (directory that contains pubspec.yaml) so that
/// assets can be read no matter where the test process was started.
Directory projectRoot() {
  var dir = Directory.current;
  while (!File('${dir.path}${Platform.pathSeparator}pubspec.yaml').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return dir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository repo;
  late RegisterController controller;
  late File profileImage;

  setUpAll(() {
    final file = File(
      '${projectRoot().path}${Platform.pathSeparator}assets'
      '${Platform.pathSeparator}images${Platform.pathSeparator}profile.png',
    );
    if (!file.existsSync()) {
      throw StateError('Test profile image not found: ${file.path}');
    }
    profileImage = file;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();

    repo = FakeAuthRepository();
    controller = RegisterController(repo);
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> pumpRegisterScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GetMaterialApp(
          home: const Scaffold(body: Text('LOGIN_STUB')),
          getPages: [
            GetPage(
              name: '/register',
              page: () => const RegisterScreen(),
              // Route binding keeps GetX from smart-managing the controller
              // away and lets GetView resolve it.
              // NOTE: BindingsBuilder(() => Get.put(x)) must NOT be used here:
              // the void callback context makes Get.put infer T = void.
              binding: BindingsBuilder.put(() => controller),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/register');
    await tester.pumpAndSettle();
  }

  Future<void> openForm(WidgetTester tester) async {
    repo.checkUserIdResult = {'role': 'user', 'authDocId': 'a', 'userDocId': 'b'};
    await tester.enterText(find.byType(TextFormField).first, validId);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Find ID'));
    await tester.pumpAndSettle();
  }

  /// Fills every field that has a validator and attaches the profile image.
  Future<void> fillValidForm(WidgetTester tester) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'Rahim'); // name
    await tester.enterText(fields.at(2), 'rahim@mail.com'); // email
    await tester.enterText(fields.at(5), '01712345678'); // phone
    await tester.enterText(fields.at(7), '1234567890'); // nid
    await tester.enterText(fields.at(10), 'Karim'); // nominee name
    await tester.enterText(fields.at(11), 'Father'); // nominee relation
    await tester.enterText(fields.at(12), 'Secret123!'); // password
    await tester.enterText(fields.at(13), 'Secret123!'); // confirm password

    controller.profileImage.value = profileImage;
    await tester.pump();
  }

  Future<void> tapSignUp(WidgetTester tester) async {
    final signUp = find.widgetWithText(ElevatedButton, 'Sign Up');
    await tester.ensureVisible(signUp);
    await tester.pumpAndSettle();
    await tester.tap(signUp);
    await tester.pumpAndSettle();
  }

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

  testWidgets('Find ID without user id shows an error snackbar',
      (tester) async {
    await pumpRegisterScreen(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Find ID'));
    await tester.pumpAndSettle();

    expect(repo.checkedUserIds, isEmpty);
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsNothing);

    await expectSnackbar(tester, 'Please enter User ID');
  });

  testWidgets('known user id expands the registration form', (tester) async {
    await pumpRegisterScreen(tester);
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsNothing);

    await openForm(tester);

    expect(repo.checkedUserIds, [validId]);
    expect(controller.selectedRole.value, 'user');
    expect(controller.showForm.value, isTrue);
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('unknown user id keeps the form hidden and shows snackbar',
      (tester) async {
    await pumpRegisterScreen(tester);

    repo.checkUserIdResult = null;
    await tester.enterText(find.byType(TextFormField).first, 'AG00X001');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Find ID'));
    await tester.pumpAndSettle();

    expect(controller.showForm.value, isFalse);
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsNothing);

    await expectSnackbar(tester, 'User ID not found');
  });

  testWidgets('sign up with a profile image registers the user and goes back',
      (tester) async {
    await pumpRegisterScreen(tester);
    await openForm(tester);

    await fillValidForm(tester);
    await tapSignUp(tester);

    expect(repo.registeredRequests, hasLength(1));
    final request = repo.registeredRequests.single;
    expect(request.userId, validId);
    expect(request.name, 'Rahim');
    expect(request.email, 'rahim@mail.com');
    expect(request.role, 'user');
    expect(request.profileImage.path, profileImage.path);

    await tester.pumpAndSettle();

    expect(controller.isLoading.value, isFalse);

    // The fresh id is cached so the login screen can prefill its ID/Email
    // field (AuthController.loadUserId reads this key).
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('userId'), validId);

    // Success: the register route is popped back to the login screen and the
    // success snackbar stays visible on top of it.
    expect(find.byType(RegisterScreen), findsNothing);
    expect(find.text('LOGIN_STUB'), findsOneWidget);

    await expectSnackbar(tester, 'Registration Successful', title: 'Success');
  });

  testWidgets('duplicate user id is reported by a snackbar', (tester) async {
    repo.registerResult = 'User ID already exists';

    await pumpRegisterScreen(tester);
    await openForm(tester);

    await fillValidForm(tester);
    await tapSignUp(tester);

    expect(find.text('LOGIN_STUB'), findsNothing); // still on register screen
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);

    await expectSnackbar(tester, 'User ID already exists', title: 'Failed');
  });

  // Regression test for '"RegisterController" not found' in the real app:
  // AuthBinding runs only once (on the /login route) and RegisterScreen is
  // pushed with a plain Get.to(), so it has no binding of its own. The
  // controller is therefore first instantiated while the register route is
  // current, and GetX links it to that route. Without `fenix: true` in
  // AuthBinding, popping the route deleted the lazyPut factory for good and
  // every later visit crashed.
  testWidgets('RegisterScreen can be reopened after being popped',
      (tester) async {
    // Pre-seed the repository so AuthBinding never reaches Firebase in tests.
    // fenix keeps the factory alive across the register-route pop; in the real
    // app AuthRepository stays linked to /login because AuthController (built
    // there) resolves it first.
    Get.lazyPut<AuthRepository>(() => repo, fenix: true);
    AuthBinding().dependencies();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GetMaterialApp(
          home: const Scaffold(body: Text('LOGIN_STUB')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> openRegister() async {
      Get.to(() => const RegisterScreen());
      await tester.pumpAndSettle();
    }

    // First visit.
    await openRegister();
    expect(find.widgetWithText(ElevatedButton, 'Find ID'), findsOneWidget);
    expect(find.text('LOGIN_STUB'), findsNothing);

    // Leave the screen: GetX disposes the route and its linked controllers.
    Get.back();
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsNothing);
    expect(find.text('LOGIN_STUB'), findsOneWidget);

    // Second visit - this used to throw '"RegisterController" not found'.
    await openRegister();
    expect(find.widgetWithText(ElevatedButton, 'Find ID'), findsOneWidget);
  });

  // End-to-end for the registration flow: signup -> user id saved -> the
  // login screen's ID/Email field shows it.
  testWidgets('after signup the saved user id shows in the login ID/Email field',
      (tester) async {
    // The default test font draws every glyph as a full em square, so
    // LoginScreen's rows overflow here although they fit on a device. That is
    // a test artifact, so those layout errors are filtered out (same as in
    // widget_test.dart).
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    // 360 x 800 logical pixels - the viewport the register tests use, where
    // every form button stays inside the screen.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // Wired like the app: the real login screen sits below the register
    // screen that gets pushed from it.
    final loginController = AuthController(repo);
    Get.put<AuthController>(loginController);
    Get.put<RegisterController>(controller);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GetMaterialApp(
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Same navigation as the login screen's "Sign Up" link (Get.to). Pushed
    // programmatically because under the test font that row overflows the
    // screen and the button cannot be tapped.
    Get.to(() => const RegisterScreen());
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);

    await openForm(tester);
    await fillValidForm(tester);
    await tapSignUp(tester);

    // Back on login with the fresh id prefilled in ID/Email.
    expect(find.byType(RegisterScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(loginController.emailController.text, validId);
    expect(find.text(validId), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('userId'), validId);

    await expectSnackbar(tester, 'Registration Successful', title: 'Success');
  });
}
