import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../model/monthly_report_model.dart';
import '../../service/monthly_service.dart';

class MonthlyController extends GetxController {
  MonthlyController({
    MonthlyService? service,
  }) : _service =
      service ?? MonthlyService.instance;

  final MonthlyService _service;

  final RxList<MonthlyMoneyModel> report =
      <MonthlyMoneyModel>[].obs;

  final RxBool isLoading = false.obs;

  final RxInt selectedYear =
      DateTime.now().year.obs;

  final RxInt selectedMonth =
      DateTime.now().month.obs;

  /// Cache + in-flight request protection.
  ///
  /// Key:
  /// yyyy-MM
  ///
  /// Example:
  /// 2026-10
  final Map<
      String,
      Future<List<MonthlyMoneyModel>>>
  _requests = {};

  int _sequence = 0;

  @override
  void onInit() {
    super.onInit();

    loadReport();
  }

  Future<void> loadReport({
    bool refresh = false,
  }) async {
    final year = selectedYear.value;
    final month = selectedMonth.value;

    final key =
        '$year-${month.toString().padLeft(2, '0')}';

    final requestId = ++_sequence;

    if (refresh) {
      _requests.remove(key);
    }

    isLoading.value = true;

    try {
      final rows = await _fetch(
        year,
        month,
        key,
        refresh: refresh,
      );

      // Ignore old request.
      if (requestId != _sequence) {
        return;
      }

      report.assignAll(rows);
    } catch (e) {
      if (requestId != _sequence) {
        return;
      }

      _requests.remove(key);

      report.clear();

      debugPrint(
        'Monthly report failed: $e'
            '${e is MonthlyReportException && e.cause != null ? ' | cause: ${e.cause}' : ''}',
      );

      Get.snackbar(
        'Monthly Report',
        e is MonthlyReportException
            ? e.toString()
            : 'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (requestId == _sequence) {
        isLoading.value = false;
      }
    }
  }

  void changeYear(int year) {
    if (selectedYear.value == year) {
      return;
    }

    selectedYear.value = year;

    loadReport();
  }

  void changeMonth(int month) {
    if (selectedMonth.value == month) {
      return;
    }

    selectedMonth.value = month;

    loadReport();
  }

  Future<void> refreshReport() async {
    await loadReport(
      refresh: true,
    );
  }

  Future<List<MonthlyMoneyModel>> _fetch(
      int year,
      int month,
      String key, {
        required bool refresh,
      }) {
    if (!refresh) {
      final cachedRequest =
      _requests[key];

      if (cachedRequest != null) {
        return cachedRequest;
      }
    }

    final future =
    _service.getMonthlyReport(
      year: year,
      month: month,
    );

    _requests[key] = future;

    return future;
  }

  @override
  void onClose() {
    _requests.clear();

    super.onClose();
  }
}