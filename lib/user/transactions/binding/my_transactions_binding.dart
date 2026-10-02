import 'package:get/get.dart';

import '../controller/my_transactions_controller.dart';
import '../data/my_transactions_repository_impl.dart';
import '../domain/repository/my_transactions_repository.dart';
import '../service/my_transactions_pdf_service.dart';

class MyTransactionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyTransactionsRepository>(
      () => MyTransactionsRepositoryImpl(),
    );
    Get.lazyPut<MyTransactionsPdfService>(
      () => MyTransactionsPdfService(Get.find<MyTransactionsRepository>()),
    );
    Get.lazyPut<MyTransactionsController>(
      () => MyTransactionsController(
        pdfService: Get.find<MyTransactionsPdfService>(),
      ),
    );
  }
}
