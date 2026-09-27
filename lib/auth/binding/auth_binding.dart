import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/services/CacheService.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/firestore_service.dart';

import '../data/datasource/auth_remote_datasource.dart';
import '../data/repository_impl/auth_repository_impl.dart';
import '../domain/repository/auth_repository.dart';
import '../prasentation/controller/auth_controller.dart';
import '../prasentation/controller/auth_register_controller.dart';

class AuthBinding extends Bindings {

  @override
  void dependencies() {

    // =========================
    // Firebase Auth Service
    // =========================

    Get.lazyPut<FirebaseAuthService>(
          () => FirebaseAuthService(FirebaseAuth.instance),
    );

    // =========================
    // Firestore Service
    // =========================

    Get.lazyPut<FirestoreService>(
          () => FirestoreService.instance,);

    // =========================
    // Auth Remote DataSource
    // =========================

    Get.lazyPut<AuthRemoteDataSource>(
          () => AuthRemoteDataSource(
        authService: Get.find<FirebaseAuthService>(),
        firestore: Get.find<FirestoreService>(),
      ),
    );

    // =========================
    // Auth Repository
    // =========================

    Get.lazyPut<AuthRepository>(
          () => AuthRepositoryImpl(
        remote: Get.find<AuthRemoteDataSource>(),
        cacheService: Get.find<CacheService>(),
      ),
    );

    // =========================
    // Auth Controller
    // =========================

    Get.lazyPut<AuthController>(
          () => AuthController(Get.find<AuthRepository>(),),
    );

    // fenix: true -> RegisterScreen is pushed with Get.to() (no binding of
    // its own), so the controller is linked to the register route and its
    // factory was deleted on pop -> '"RegisterController" not found' on the
    // next visit. fenix keeps the factory alive across that pop.
    Get.lazyPut<RegisterController>(
          () => RegisterController(Get.find<AuthRepository>(),),
      fenix: true,
    );

  }
}