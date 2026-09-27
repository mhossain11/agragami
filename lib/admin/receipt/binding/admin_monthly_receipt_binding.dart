import 'package:get/get.dart';

import '../../../user/money record/data/repo_impl/repository_impl.dart';
import '../../../user/money record/domain/money_repository/moneyRecordRepository.dart';
import '../../save_money/service/saving_money_service.dart';
import '../controller/admin_monthly_receipt_controller.dart';
import '../service/printer_service_factory.dart';
import '../service/receipt_print_service.dart';
import '../service/thermal_printer_service.dart';

class AdminMonthlyReceiptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoneyRecordRepository>(() => MoneyRecordRepositoryImpl());
    Get.lazyPut<SavingMoneyService>(() => SavingMoneyService());
    Get.lazyPut<ThermalPrinterService>(() => createThermalPrinterService());
    Get.lazyPut<ReceiptPrintService>(
      () => ReceiptPrintService(Get.find<ThermalPrinterService>()),
    );
    Get.lazyPut<AdminMonthlyReceiptController>(
      () => AdminMonthlyReceiptController(
        moneyRecordRepository: Get.find<MoneyRecordRepository>(),
        savingMoneyService: Get.find<SavingMoneyService>(),
        receiptPrintService: Get.find<ReceiptPrintService>(),
        printerService: Get.find<ThermalPrinterService>(),
      ),
    );
  }
}
