import 'package:Agragami/admin/monthly_paid&unpaid_report/view/screen/monthlyReport_screen.dart';
import 'package:Agragami/admin/monthly_report/binding/moneyRecordBinding.dart';
import 'package:Agragami/admin/monthly_report/view/screen/monthlyReport_screen.dart';
import 'package:Agragami/user/home/binding/home_binding.dart';
import 'package:get/get.dart';


import '../../admin/home/binding/admin_home_binding.dart';
import '../../admin/home/view/admin_home_screen.dart';
import '../../admin/monthly_paid&unpaid_report/binding/moneyRecordBinding.dart';
import '../../admin/receipt/binding/admin_monthly_receipt_binding.dart';
import '../../admin/receipt/screen/admin_monthly_receipt_screen.dart';
import '../../auth/binding/auth_binding.dart';
import '../../auth/prasentation/screen/login_screen.dart';
import '../../user/home/presentation/screen/home_screen.dart';
import '../../user/money record/binding/moneyRecordBinding.dart';
import '../../user/money record/presentation/screen/user_money_record_screen.dart';
import '../../user/transactions/binding/my_transactions_binding.dart';
import '../../user/transactions/screen/my_transactions_screen.dart';
import 'app_routes.dart';

class AppPages {

  /// Cold start always lands on the Login screen.
  ///
  /// This is evaluated exactly once per process (from `main()` /
  /// `MyApp.build`), i.e. only after a **fresh app launch**. Therefore:
  ///
  ///   * swipe-away / OOM kill / crash / force stop / reboot → next launch
  ///     starts a new process → Login (previous session already dropped by
  ///     `SessionGuard.invalidatePreviousSession()`);
  ///   * Home button / app switcher → same process keeps running → this is
  ///     never re-evaluated → the user stays exactly where they were.
  ///
  /// The cached `isRole` is deliberately *not* consulted here: a stale role
  /// must never auto-enter Home/Admin, and not reading the cache removes
  /// any startup race between `CacheHelper.init()` and routing.
  static String getInitialRoute() {
    return AppRoutes.login;
  }

  static final List<GetPage> pages = [

    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.adminHome,
      page: () => const AdminHomeScreen(),
      binding: AdminHomeBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.moneyRecord,
      page: () => const UserMoneyRecordScreen(),
      binding: MoneyRecordBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.monthlyReport,
      page: () => MonthlyReportPage(),
      binding: MonthlyReportBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.monthlyPaidUnpaidReport,
      page: () => MonthlyPaidUnpaidReportPage(),
      binding: MonthlyPaidUnpaidReportBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.adminMonthlyReceipt,
      page: () => const AdminMonthlyReceiptScreen(),
      binding: AdminMonthlyReceiptBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.myTransactions,
      page: () => const MyTransactionsScreen(),
      binding: MyTransactionsBinding(),
      transition: Transition.fadeIn,
    ),

  ];
}