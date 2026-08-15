import 'package:get/get.dart';


import '../../admin/home/screen/adminhome_screen.dart';
import '../../auth/login/binding/auth_binding.dart';
import '../../auth/login/prasentation/screen/login_screen.dart';
import '../../user/home/presentation/screen/home_screen.dart';
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
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),

  ];
}