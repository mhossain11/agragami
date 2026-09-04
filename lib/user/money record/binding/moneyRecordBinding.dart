import 'package:get/get.dart';

import '../data/repo_impl/repository_impl.dart';
import '../domain/money_repository/moneyRecordRepository.dart';
import '../presentation/controller/money_controller.dart';


class MoneyRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoneyRecordRepository>(() =>
        MoneyRecordRepositoryImpl());
    Get.lazyPut<MoneyRecordController>(() =>
        MoneyRecordController(Get.find<MoneyRecordRepository>()));
  }
}