import '../models/userHomeModel.dart';

abstract class HomeRepository {

  Future<HomeData> localCachedUserInfo();
  Future<int> getAllUsersTotalAmount();
  Stream<String> watchProfileImage(String userDocId);
}