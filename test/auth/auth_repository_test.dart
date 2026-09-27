import 'dart:io';

import 'package:Agragami/auth/data/datasource/auth_remote_datasource.dart';
import 'package:Agragami/auth/data/repository_impl/auth_repository_impl.dart';
import 'package:Agragami/auth/domain/model/register_model.dart';
import 'package:Agragami/core/cachehelper/chechehelper.dart';
import 'package:Agragami/core/services/CacheService.dart';
import 'package:Agragami/core/services/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class - mocked for testing
class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class - mocked for testing
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

const validId = 'AG24M001';
const loginPassword = 'Secret123!';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRemoteDataSource remote;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(File(''));
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();

    remote = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(
      remote: remote,
      cacheService: CacheService(),
    );
  });

  MockUserCredential stubAuthenticatedUser({required String uid}) {
    final credential = MockUserCredential();
    final user = MockUser();
    when(() => credential.user).thenReturn(user);
    when(() => user.uid).thenReturn(uid);
    return credential;
  }

  MockDocumentSnapshot stubUserDoc({
    required String uid,
    required Map<String, dynamic>? data,
    String? docId,
  }) {
    final doc = MockDocumentSnapshot();
    when(() => doc.exists).thenReturn(data != null);
    when(() => doc.id).thenReturn(docId ?? 'doc-$uid');
    when(() => doc.data()).thenReturn(data);
    when(() => remote.getUserByUid(uid)).thenAnswer((_) async => doc);
    return doc;
  }

  // =====================================================================
  // LOGIN
  // =====================================================================

  group('AuthRepositoryImpl.login', () {
    test('with email: logs in, reads firestore doc and caches session',
        () async {
      final credential = stubAuthenticatedUser(uid: 'uid-1');
      when(() => remote.login(email: 'rahim@mail.com', password: loginPassword))
          .thenAnswer((_) async => credential);
      stubUserDoc(
        uid: 'uid-1',
        data: {
          'role': 'user',
          'user_id': validId,
          'name': 'Rahim',
          'email': 'rahim@mail.com',
        },
      );

      final result = await repository.login(
        email: '  rahim@mail.com ',
        password: loginPassword,
      );

      expect(result, isNotNull);
      expect(result!.role, 'user');
      expect(result.userId, validId);

      verify(() => remote.login(
            email: 'rahim@mail.com',
            password: loginPassword,
          )).called(1);
      verifyNever(() => remote.findUserByUserId('rahim@mail.com'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isLoggedIn'), true);
      expect(prefs.getString('isRole'), 'user');
      expect(prefs.getString('names'), 'Rahim');
      expect(prefs.getString('userDocId'), 'doc-uid-1');
    });

    test('with user id: resolves the email first, then logs in', () async {
      final querySnap = MockQuerySnapshot();
      final queryDoc = MockQueryDocumentSnapshot();
      when(() => queryDoc.data()).thenReturn({'email': 'resolved@mail.com'});
      when(() => queryDoc['email']).thenReturn('resolved@mail.com');
      when(() => querySnap.docs).thenReturn([queryDoc]);
      when(() => remote.findUserByUserId(validId))
          .thenAnswer((_) async => querySnap);

      final credential = stubAuthenticatedUser(uid: 'uid-2');
      when(() =>
              remote.login(email: 'resolved@mail.com', password: loginPassword))
          .thenAnswer((_) async => credential);
      stubUserDoc(
        uid: 'uid-2',
        data: {
          'role': 'admin',
          'user_id': validId,
          'name': 'Admin',
          'email': 'resolved@mail.com',
        },
      );

      final result = await repository.login(
        email: validId,
        password: loginPassword,
      );

      verify(() => remote.findUserByUserId(validId)).called(1);
      verify(() => remote.login(
            email: 'resolved@mail.com',
            password: loginPassword,
          )).called(1);
      expect(result!.role, 'admin');
      expect(result.userId, validId);
    });

    test('with unknown user id: throws "User ID not found"', () async {
      final querySnap = MockQuerySnapshot();
      when(() => querySnap.docs).thenReturn([]);
      when(() => remote.findUserByUserId('AG00X001'))
          .thenAnswer((_) async => querySnap);

      await expectLater(
        repository.login(email: 'AG00X001', password: loginPassword),
        throwsA(predicate((e) => e.toString().contains('User ID not found'))),
      );

      verifyNever(() => remote.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('when firestore user doc is missing: throws "User data not found"',
        () async {
      final credential = stubAuthenticatedUser(uid: 'uid-3');
      when(() => remote.login(email: 'rahim@mail.com', password: loginPassword))
          .thenAnswer((_) async => credential);
      stubUserDoc(uid: 'uid-3', data: null);

      await expectLater(
        repository.login(email: 'rahim@mail.com', password: loginPassword),
        throwsA(predicate((e) => e.toString().contains('User data not found'))),
      );
    });

    test('user doc without role/name: logs in and caches without crashing',
        () async {
      // Regression: saveUserData passed the raw (possibly null) role/name to
      // the non-nullable CacheHelper.setString and crashed the login.
      final credential = stubAuthenticatedUser(uid: 'uid-4');
      when(() => remote.login(email: 'rahim@mail.com', password: loginPassword))
          .thenAnswer((_) async => credential);
      stubUserDoc(
        uid: 'uid-4',
        data: {
          'user_id': validId,
          'email': 'rahim@mail.com',
        },
      );

      final result = await repository.login(
        email: 'rahim@mail.com',
        password: loginPassword,
      );

      expect(result, isNotNull);
      expect(result!.role, 'user'); // login() falls back to 'user'

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isLoggedIn'), true);
      // Missing in the doc -> not written (the login flow stores the role
      // separately through AuthController).
      expect(prefs.getString('isRole'), isNull);
      expect(prefs.getString('names'), isNull);
      expect(prefs.getString('userDocId'), 'doc-uid-4');
    });

    test('firebase auth failure is propagated', () async {
      when(() => remote.login(email: 'rahim@mail.com', password: loginPassword))
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));

      await expectLater(
        repository.login(email: 'rahim@mail.com', password: loginPassword),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  // =====================================================================
  // REGISTER
  // =====================================================================

  RegisterRequest buildRequest({
    String userId = validId,
    String email = 'rahim@mail.com',
  }) {
    return RegisterRequest(
      userId: userId,
      name: 'Rahim',
      email: email,
      fatherName: 'Abdul Karim',
      motherName: 'Amina',
      password: loginPassword,
      role: 'user',
      phone: '01712345678',
      address: 'Dhaka',
      birthdate: '2005-01-01',
      blood: 'A+',
      nid: '1234567890',
      nomineeName: 'Karim',
      nomineeRelation: 'Father',
      profileImage: File('profile.png'),
    );
  }

  group('AuthRepositoryImpl.register', () {
    test('duplicate user id returns an error without creating an account',
        () async {
      when(() => remote.checkUserRole(validId))
          .thenAnswer((_) async => {'exists': true, 'role': 'user'});

      final result = await repository.register(buildRequest());

      expect(result, 'User ID already exists');
      verifyNever(() => remote.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
      verifyNever(() => remote.createUser(uid: any(named: 'uid'), data: any(named: 'data')));
    });

    test('success: uploads image, writes firestore doc and marks user done',
        () async {
      when(() => remote.checkUserRole(validId))
          .thenAnswer((_) async => {'exists': false, 'role': null});

      final credential = stubAuthenticatedUser(uid: 'uid-9');
      when(() =>
              remote.register(email: 'rahim@mail.com', password: loginPassword))
          .thenAnswer((_) async => credential);
      when(() => remote.uploadProfileImage(
            imageFile: any(named: 'imageFile'),
            userId: validId,
          )).thenAnswer((_) async => 'https://img.example/$validId.jpg');
      when(() => remote.createUser(uid: 'uid-9', data: any(named: 'data')))
          .thenAnswer((_) async {});
      when(() => remote.addUserDoneField(validId)).thenAnswer((_) async {});

      final result = await repository.register(buildRequest());

      expect(result, 'success');

      final created = verify(
        () => remote.createUser(
          uid: 'uid-9',
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;

      expect(created['uid'], 'uid-9');
      expect(created['name'], 'Rahim');
      expect(created['email'], 'rahim@mail.com');
      expect(created['role'], 'user');
      expect(created['user_id'], validId);
      expect(created['phone'], '01712345678');
      expect(created['profileImage'], 'https://img.example/$validId.jpg');
      expect(created['created_at'], isNotNull);

      verify(() => remote.uploadProfileImage(
            imageFile: any(named: 'imageFile'),
            userId: validId,
          )).called(1);
      verify(() => remote.addUserDoneField(validId)).called(1);

      // Nothing failed -> no rollback must happen.
      verifyNever(() => remote.deleteCurrentUser());
      verifyNever(() => remote.deleteUserDocument(uid: 'uid-9'));
    });

    test('firebase "email already in use" error is propagated', () async {
      when(() => remote.checkUserRole(validId))
          .thenAnswer((_) async => {'exists': false, 'role': null});
      when(() =>
              remote.register(email: 'rahim@mail.com', password: loginPassword))
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      expect(
        () => repository.register(buildRequest()),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('failed firestore write rolls back the auth account', () async {
      when(() => remote.checkUserRole(validId))
          .thenAnswer((_) async => {'exists': false, 'role': null});

      final credential = stubAuthenticatedUser(uid: 'uid-9');
      when(() =>
              remote.register(email: 'rahim@mail.com', password: loginPassword))
          .thenAnswer((_) async => credential);
      when(() => remote.uploadProfileImage(
            imageFile: any(named: 'imageFile'),
            userId: validId,
          )).thenAnswer((_) async => 'https://img.example/$validId.jpg');
      when(() => remote.createUser(uid: 'uid-9', data: any(named: 'data')))
          .thenThrow(Exception('firestore down'));
      when(() => remote.deleteCurrentUser()).thenAnswer((_) async {});

      await expectLater(
        repository.register(buildRequest()),
        throwsA(predicate((e) => e.toString().contains('firestore down'))),
      );

      // The doc was never written, so only the auth account is removed -
      // otherwise "email already in use" blocked every retry.
      verifyNever(() => remote.deleteUserDocument(uid: 'uid-9'));
      verify(() => remote.deleteCurrentUser()).called(1);
    });

    test('failed "mark done" step rolls back doc and auth account', () async {
      when(() => remote.checkUserRole(validId))
          .thenAnswer((_) async => {'exists': false, 'role': null});

      final credential = stubAuthenticatedUser(uid: 'uid-9');
      when(() =>
              remote.register(email: 'rahim@mail.com', password: loginPassword))
          .thenAnswer((_) async => credential);
      when(() => remote.uploadProfileImage(
            imageFile: any(named: 'imageFile'),
            userId: validId,
          )).thenAnswer((_) async => 'https://img.example/$validId.jpg');
      when(() => remote.createUser(uid: 'uid-9', data: any(named: 'data')))
          .thenAnswer((_) async {});
      when(() => remote.addUserDoneField(validId))
          .thenThrow(Exception('done flag failed'));
      when(() => remote.deleteUserDocument(uid: 'uid-9'))
          .thenAnswer((_) async {});
      when(() => remote.deleteCurrentUser()).thenAnswer((_) async {});

      await expectLater(
        repository.register(buildRequest()),
        throwsA(predicate((e) => e.toString().contains('done flag failed'))),
      );

      // Without this the leftover doc made every retry answer
      // "User ID already exists".
      verify(() => remote.deleteUserDocument(uid: 'uid-9')).called(1);
      verify(() => remote.deleteCurrentUser()).called(1);
    });
  });

  // =====================================================================
  // LOGOUT
  // =====================================================================

  group('AuthRepositoryImpl.logout', () {
    test('calls firebase sign out', () async {
      final authService = MockFirebaseAuthService();
      when(() => remote.authService).thenReturn(authService);
      when(() => authService.logout()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => authService.logout()).called(1);
    });
  });
}
