import '../../../core/services/firestore_service.dart';
import '../../monthly_report/model/monthly_report_model.dart';
import '../../monthly_report/service/monthly_service.dart' as report;

class MonthlyService {
  MonthlyService();

  static final MonthlyService instance = MonthlyService();

  final FirestoreService firestoreService = FirestoreService.instance;

  // =====================================================
  // PAID REPORT
  //
  // Delegates to the shared monthly_report implementation:
  // ONE collectionGroup('Money') query, month filtered and sorted
  // server-side. There is deliberately no second copy of that logic.
  // =====================================================

  Future<List<MonthlyMoneyModel>> getMonthlyReport({
    required int year,
    required int month,
  }) {
    return report.MonthlyService.instance.getMonthlyReport(
      year: year,
      month: month,
    );
  }

  // =====================================================
  // UNPAID MEMBERS
  //
  // payment_status lives on the user documents, so one users scan is
  // inherent to this list (it never touches Money documents).
  // =====================================================

  Future<List<Map<String, dynamic>>> getUnpaidMembers({
    required int year,
    required int month,
  }) async {
    final List<Map<String, dynamic>> result = [];

    final paymentMonth =
        '$year-${month.toString().padLeft(2, '0')}';

    final usersSnapshot =
    await firestoreService.users.get();

    for (final userDoc in usersSnapshot.docs) {
      final userData = userDoc.data();

      final paymentStatus =
      userData['payment_status'];

      bool isPaid = false;

      if (paymentStatus is Map) {
        isPaid = paymentStatus[paymentMonth] == true;
      }

      // Paid না হলে unpaid
      if (!isPaid) {
        result.add({
          'userDocumentId': userDoc.id,

          'userId':
          userData['user_id']?.toString() ??
              userDoc.id,

          'userName':
          userData['name']?.toString() ??
              '',

          // WhatsApp number
          'phone':
          userData['phone']?.toString() ??
              '',
        });
      }
    }

    return result;
  }
}
