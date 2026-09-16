import 'package:Agragami/admin/monthly_report/view/controller/monthly_controller.dart';
import 'package:get/get.dart';
import '../service/monthly_service.dart';


class MonthlyReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MonthlyService>(() => MonthlyService());

    Get.lazyPut<MonthlyController>(() => MonthlyController());
  }
}