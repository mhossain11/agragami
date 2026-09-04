import 'package:Agragami/core/cachehelper/chechehelper.dart';
import 'package:Agragami/user/home/domain/models/userHomeModel.dart';
import 'package:Agragami/user/home/domain/repository/home_repository.dart';

import '../../../../core/services/firestore_service.dart';

class HomeRepositoryImpl implements HomeRepository{
  final FirestoreService firestoreService;
  HomeRepositoryImpl({
    required this.firestoreService});



  @override
  Future<HomeData> localCachedUserInfo() async{
    final name = CacheHelper().getString('names') ?? '';
    final docId = CacheHelper().getString('userDocId') ?? '';
    final userId = CacheHelper().getString('userId') ?? '';
    return HomeData(name: name, userDocId: docId,userId: userId);
  }

  @override
  Future<int> getAllUsersTotalAmount() async{
    int total = 0;
    try{
      final userSnapshot = await firestoreService.users.get();
      for(final userDoc in userSnapshot.docs){
        final moneySnapshot = await firestoreService.users.doc(userDoc.id).collection('Money').get();

        for(final moneyDoc in moneySnapshot.docs){
          final amount = moneyDoc.data()['amount'];

          if(amount is num){
            total += amount.toInt();
          }else if(amount is String){
            total += int.tryParse(amount)??0;
          }
        }
      }
    }catch(e){
      print('❌ Total money error: $e');
      rethrow;
    }

    return total;

  }

  @override
  Stream<String> watchProfileImage(String userDocId) {
   if(userDocId.isEmpty) return const Stream.empty();

   return firestoreService.users.doc(userDocId).snapshots().map((snap){
     if(!snap.exists) return '';
     final data = snap.data() as Map<String,dynamic>;
     return data['profileImage']?.toString() ?? '';
   });
  }

}