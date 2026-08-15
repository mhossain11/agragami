abstract class HomeRepository {
  Future<int> getUserTotalMoney(String userId);
  Future<int> getAllUsersTotalMoney();
}