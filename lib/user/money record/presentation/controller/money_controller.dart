
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/model/money_record.dart';
import '../../domain/money_repository/moneyRecordRepository.dart';

class MoneyRecordController extends GetxController {
  final MoneyRecordRepository repository;

  MoneyRecordController(this.repository);

  final isLoading = true.obs;
  final userDocId = ''.obs;
  final records = <MoneyRecord>[].obs;

  // recordId -> ওই record এর মাস পর্যন্ত cumulative total
  final Map<String, double> _monthlyCumulative = {};

  double get sumOfAmounts =>
      records.fold(0.0, (sum, r) => sum + r.amount);

  double totalForRecord(String recordId) =>
      _monthlyCumulative[recordId] ?? 0;

  StreamSubscription<List<MoneyRecord>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final docId = await repository.getCachedUserDocId();

    if (docId.isEmpty) {
      debugPrint('Error: userDocId not found in cache!');
      isLoading.value = false;
      return;
    }

    userDocId.value = docId;

    _sub = repository.watchMoneyRecords(docId).listen((data) {
      records.value = data;
      _computeMonthlyCumulativeTotals();
      isLoading.value = false;
    });
  }

  void _computeMonthlyCumulativeTotals() {
    // 1️⃣ প্রতিটা মাসের sum বের করা
    final monthSums = <String, double>{};

    for (final r in records) {
      final key = r.dateTime != null
          ? DateFormat('yyyy-MM').format(r.dateTime!)
          : 'unknown';
      monthSums[key] = (monthSums[key] ?? 0) + r.amount;
    }

    // 2️⃣ মাসগুলো chronologically sort করে cumulative sum বের করা
    final sortedMonthKeys = monthSums.keys.toList()..sort();

    final cumulativeByMonth = <String, double>{};
    double running = 0;

    for (final key in sortedMonthKeys) {
      running += monthSums[key]!;
      cumulativeByMonth[key] = running;
    }

    // 3️⃣ প্রতিটা record কে তার মাসের cumulative total assign করা
    _monthlyCumulative.clear();
    for (final r in records) {
      final key = r.dateTime != null
          ? DateFormat('yyyy-MM').format(r.dateTime!)
          : 'unknown';
      _monthlyCumulative[r.id] = cumulativeByMonth[key] ?? 0;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}