/*
import '../../domain/repository/home_repository.dart';
import '../datasource/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remote;

  HomeRepositoryImpl(this.remote);

  @override
  Future<int> getUserTotalMoney(String userId) async {
    int total = 0;

    final snapshot = await remote.getUserMoney(userId);

    for (var doc in snapshot.docs) {
      total += _parseAmount(doc.data()['amount']);
    }

    return total;
  }

  @override
  Future<int> getAllUsersTotalMoney() async {
    int total = 0;

    final users = await remote.getUsers();

    for (var user in users.docs) {
      final money = await remote.getUserMoney(user.id);

      for (var doc in money.docs) {
        total += _parseAmount(doc.data()['amount']);
      }
    }

    return total;
  }

  int _parseAmount(dynamic amount) {
    if (amount is num) return amount.toInt();
    if (amount is String) return int.tryParse(amount) ?? 0;
    return 0;
  }
}*/
