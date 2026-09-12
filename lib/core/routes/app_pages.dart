import 'package:Agragami/user/home/binding/home_binding.dart';
import 'package:get/get.dart';


import '../../admin/home/binding/admin_home_binding.dart';
import '../../admin/home/view/admin_home_screen.dart';
import '../../auth/binding/auth_binding.dart';
import '../../auth/prasentation/screen/login_screen.dart';
import '../../user/home/presentation/screen/home_screen.dart';
import '../../user/money record/binding/moneyRecordBinding.dart';
import '../../user/money record/presentation/screen/user_money_record_screen.dart';
import '../cachehelper/chechehelper.dart';
import 'app_routes.dart';

class AppPages {

  static String getInitialRoute() {
    final isLoggedIn = CacheHelper().getLoggedIn();
    final role = CacheHelper().getString('isRole');

    if (isLoggedIn) {
      if (role == 'admin') {
        return AppRoutes.adminHome;
      }

      if (role == 'user') {
        return AppRoutes.home;
      }
    }

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

  ];
}