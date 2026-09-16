import 'package:get/get.dart';

import '../../model/monthly_report_model.dart';
import '../../service/monthly_service.dart';

class MonthlyController extends GetxController {
  final MonthlyService service =
      MonthlyService.instance;

  final RxList<MonthlyMoneyModel> report =
      <MonthlyMoneyModel>[].obs;

  final RxBool isLoading = false.obs;

  final RxInt selectedYear =
      DateTime.now().year.obs;

  final RxInt selectedMonth =
      DateTime.now().month.obs;

  @override
  void onInit() {
    super.onInit();

    // প্রথমবার page open হলেই report load হবে
    loadReport();
  }

  Future<void> loadReport() async {
    try {
      isLoading.value = true;

      print(
        'Loading report: '
            '${selectedYear.value}-${selectedMonth.value}',
      );

      final data =
      await service.getMonthlyReport(
        year: selectedYear.value,
        month: selectedMonth.value,
      );

      print(
        'Report found: ${data.length}',
      );

      report.assignAll(data);
    } catch (e, stackTrace) {
      print('Monthly Report Error: $e');
      print(stackTrace);

      Get.snackbar(
        'Error',
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeYear(int year) {
    selectedYear.value = year;
    loadReport();
  }

  void changeMonth(int month) {
    selectedMonth.value = month;
    loadReport();
  }
}