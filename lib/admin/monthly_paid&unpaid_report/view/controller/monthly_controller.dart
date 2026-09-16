
import 'package:get/get.dart';

import '../../model/monthly_report_model.dart';
import '../../service/monthly_service.dart';

class MonthlyPaidUnpaidController extends GetxController {
  final MonthlyService service =
      MonthlyService.instance;

  // Paid
  final RxList<MonthlyMoneyModel> report =
      <MonthlyMoneyModel>[].obs;

  // Unpaid
  final RxList<Map<String, dynamic>> unpaidUsers =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;

  final RxInt selectedYear =
      DateTime.now().year.obs;

  final RxInt selectedMonth =
      DateTime.now().month.obs;

  @override
  void onInit() {
    super.onInit();

    loadReport();
  }

  Future<void> loadReport() async {
    try {
      isLoading.value = true;

      final paid =
      await service.getMonthlyReport(
        year: selectedYear.value,
        month: selectedMonth.value,
      );

      final unpaid =
      await service.getUnpaidMembers(
        year: selectedYear.value,
        month: selectedMonth.value,
      );

      report.assignAll(paid);

      unpaidUsers.assignAll(unpaid);
    } catch (e) {
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

  int get paidCount => report.length;

  int get unpaidCount => unpaidUsers.length;

  int get totalMembers =>
      paidCount + unpaidCount;

  double get totalCollection {
    double total = 0;

    for (final item in report) {
      total += item.amount;
    }

    return total;
  }
}