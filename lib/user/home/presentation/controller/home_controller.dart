import 'package:get/get.dart';

import '../../domain/repository/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository repository;

  HomeController(this.repository);

  final RxBool isLoading = false.obs;
  final RxInt totalAmount = 0.obs;

  @override
  void onInit() {
    loadTotalMoney();
    super.onInit();
  }

  Future<void> loadTotalMoney() async {
    try {
      isLoading.value = true;

      totalAmount.value =
      await repository.getAllUsersTotalMoney();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}