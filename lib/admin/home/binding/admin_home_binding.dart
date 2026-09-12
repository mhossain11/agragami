import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../notification/service/note_service.dart';
import '../controller/admin_home_controller.dart';
import '../data/admin_home_repository.dart';


class AdminHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminHomeRepository>(
      () => AdminHomeRepository(
        firestoreService: FirestoreService.instance,
        authService: FirebaseAuthService(FirebaseAuth.instance),
      ),
    );

    Get.lazyPut<NoteService>(() => NoteService());

    Get.lazyPut<AdminHomeController>(
      () => AdminHomeController(repository: Get.find<AdminHomeRepository>()),
    );
  }
}
