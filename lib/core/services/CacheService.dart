
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

    // Audit Log ke liye zaroori: admin screens (Create/Edit ID, Save Money,
    // Money Delete, Note, Notification) getName() me 'email' aur 'adminId'
    // padhti hain. Ye dono key kabhi login par cached nahi thi (email sirf
    // profile-save par jaata tha, adminId key to ek commit me delete hi kar
    // di gayi thi) - isliye getName() wahi crash/return karta tha aur Log me
    // email/user_id hamesha blank jaate the. Email Firestore doc se lo
    // (login field me user ID bhi type hoti hai), adminId = userDoc['user_id']
    // (jo pehle yahin cache hoti thi).
    final email = user['email']?.toString();
    if (email != null && email.isNotEmpty) {
      await CacheHelper().setString('email', email);
    }

    final adminId = user['user_id']?.toString();
    if (adminId != null && adminId.isNotEmpty) {
      await CacheHelper().setString('adminId', adminId);
    }

    await CacheHelper().setString(
      'userDocId',
      docId,
    );
  }
}