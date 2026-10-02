import 'package:Agragami/user/money record/domain/model/money_record.dart';
import 'package:Agragami/user/transactions/controller/my_transactions_controller.dart';
import 'package:Agragami/user/transactions/domain/model/my_transactions_data.dart';
import 'package:Agragami/user/transactions/domain/repository/my_transactions_repository.dart';
import 'package:Agragami/user/transactions/screen/my_transactions_screen.dart';
import 'package:Agragami/user/transactions/service/my_transactions_pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

MoneyRecord record({
  required String id,
  double amount = 100,
  String method = 'Cash',
  DateTime? date,
}) {
  return MoneyRecord(
    id: id,
    receivedBy: 'Admin',
    amount: amount,
    paymentMethod: method,
    collectionDate: date,
    dateTime: date,
  );
}

MyTransactionsData sampleData(List<MoneyRecord> transactions) {
  return MyTransactionsData(
    name: 'Test Member',
    userId: 'AG001',
    email: 'member@example.com',
    phone: '01700000000',
    transactions: transactions,
  );
}

/// Offline fake - no Firebase, no network.
class FakeMyTransactionsRepository implements MyTransactionsRepository {
  FakeMyTransactionsRepository([MyTransactionsData? data]) : _data = data;

  final MyTransactionsData? _data;
  int loadCallCount = 0;

  @override
  Future<MyTransactionsData> loadMyTransactions() async {
    loadCallCount++;
    return _data ?? sampleData([]);
  }
}

void main() {
  group('sortTransactionsNewestFirst', () {
    test('sorts by date&time descending, newest first', () {
      final records = [
        record(id: 'old', date: DateTime(2026, 1, 5)),
        record(id: 'new', date: DateTime(2026, 9, 1)),
        record(id: 'mid', date: DateTime(2026, 5, 20)),
      ];

      sortTransactionsNewestFirst(records);

      expect(records.map((r) => r.id), ['new', 'mid', 'old']);
    });

    test('keeps records without a date at the end instead of dropping', () {
      final records = [
        record(id: 'noDate'),
        record(id: 'withDate', date: DateTime(2026, 3, 3)),
      ];

      sortTransactionsNewestFirst(records);

      expect(records.map((r) => r.id), ['withDate', 'noDate']);
      expect(records, hasLength(2));
    });
  });

  group('MyTransactionsData totals', () {
    test('adds up every transaction amount and counts them', () {
      final data = sampleData([
        record(id: 'a', amount: 1000),
        record(id: 'b', amount: 250.5),
        record(id: 'c', amount: 49.5),
      ]);

      expect(data.totalTransactionAmount, 1300.0);
      expect(data.totalTransactionCount, 3);
      expect(data.totalCollectedAmount, 1300.0);
    });

    test('zero transactions give zero totals', () {
      final data = sampleData([]);

      expect(data.totalTransactionAmount, 0);
      expect(data.totalTransactionCount, 0);
      expect(data.totalCollectedAmount, 0);
    });
  });

  group('MyTransactionsPdfService.generateUserMoneyPDF', () {
    test('takes no user id - loads data through the repository only', () async {
      final repository = FakeMyTransactionsRepository(sampleData([
        record(id: 'tx-1', amount: 500, date: DateTime(2026, 8, 1)),
      ]));
      final service = MyTransactionsPdfService(repository);

      // The method has NO user id parameter: the signed-in member is
      // resolved inside the repository (Firebase Auth session).
      final document = await service.generateUserMoneyPDF();
      final bytes = await document.save();

      expect(repository.loadCallCount, 1);
      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    });

    test('still builds a valid PDF when there are no transactions', () async {
      final service = MyTransactionsPdfService(
        FakeMyTransactionsRepository(sampleData([])),
      );

      final document = await service.generateUserMoneyPDF();
      final bytes = await document.save();

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    });
  });

  group('MyTransactionsScreen', () {
    testWidgets('shows Generate PDF and never asks for a user id',
        (tester) async {
      Get.put(
        MyTransactionsController(
          pdfService: MyTransactionsPdfService(
            FakeMyTransactionsRepository(sampleData([])),
          ),
        ),
      );
      addTearDown(Get.reset);

      await tester.pumpWidget(
        const GetMaterialApp(home: MyTransactionsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Generate PDF'), findsOneWidget);

      // Requirement: no way to enter, search or select another user.
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byType(DropdownButtonFormField<dynamic>), findsNothing);
      expect(find.byType(Autocomplete<dynamic>), findsNothing);

      // Actions only appear after a PDF has been generated.
      expect(find.text('View PDF'), findsNothing);
      expect(find.text('Download PDF'), findsNothing);
      expect(find.text('Share PDF'), findsNothing);
    });

    testWidgets('after Generate PDF shows View / Download / Share',
        (tester) async {
      final repository = FakeMyTransactionsRepository(sampleData([
        record(id: 'tx-1', amount: 100, date: DateTime(2026, 7, 1)),
      ]));
      Get.put(
        MyTransactionsController(
          pdfService: MyTransactionsPdfService(repository),
        ),
      );
      addTearDown(Get.reset);

      await tester.pumpWidget(
        const GetMaterialApp(home: MyTransactionsScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generate PDF'));
      await tester.pumpAndSettle();

      expect(find.text('View PDF'), findsOneWidget);
      expect(find.text('Download PDF'), findsOneWidget);
      expect(find.text('Share PDF'), findsOneWidget);
      expect(find.text('Your transaction PDF is ready. Choose an option below.'),
          findsOneWidget);

      // Exactly one repository load - and nobody passed it a user id.
      expect(repository.loadCallCount, 1);
    });
  });
}
