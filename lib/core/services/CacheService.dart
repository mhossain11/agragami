
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

    // Firestore doc mein role/name missing ho sakta hai. Pehle ye values
    // directly setString() ko jaati rahi hain (String non-nullable hai), jo
    // runtime crash karati thin - ab sirf non-empty value par hi likha jaata
    // hai. (Login flow mein role ko AuthController alag se bhi save karta hai.)
    final role = user['role']?.toString();
    if (role != null && role.isNotEmpty) {
      await CacheHelper().setString('isRole', role);
    }

    final name = user['name']?.toString();
    if (name != null && name.isNotEmpty) {
      await CacheHelper().setString('names', name);
    }

    await CacheHelper().setString(
      'userDocId',
      docId,
    );
  }
}