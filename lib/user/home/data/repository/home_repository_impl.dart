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
      // ONE round trip instead of 1 + N serial queries: every Money doc
      // app-wide via a single collection-group read (the exact doc set
      // the old per-user loop walked) - and the user documents are never
      // downloaded at all. No filters/order, so no extra index needed.
      final moneySnapshot =
          await firestoreService.firestore.collectionGroup('Money').get();

      for(final moneyDoc in moneySnapshot.docs){
        final amount = moneyDoc.data()['amount'];

        if(amount is num){
          total += amount.toInt();
        }else if(amount is String){
          total += int.tryParse(amount)??0;
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