

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../../../core/services/firestore_service.dart';
import '../data/repository/home_repository_impl.dart';
import '../domain/repository/home_repository.dart';
import '../presentation/controller/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut<FirestoreService>(() => FirestoreService.instance,);
    Get.lazyPut<HomeRepository>(() => HomeRepositoryImpl(firestoreService: Get.find<FirestoreService>()));
    Get.lazyPut<HomeController>(() => HomeController(Get.find()));
  }
}