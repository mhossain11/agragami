
import '../cachehelper/chechehelper.dart';

class CacheService {
  Future<CacheService> init() async {
    await CacheHelper.init();
    return this;
  }
  Future<void> saveUserData(
      Map<String, dynamic> user,
      String docId,
      ) async {

    await CacheHelper().setLoggedIn(true);

    await CacheHelper().setString(
      'isRole',
      user['role'],
    );

    await CacheHelper().setString(
      'names',
      user['name'],
    );

    await CacheHelper().setString(
      'userDocId',
      docId,
    );
  }
}