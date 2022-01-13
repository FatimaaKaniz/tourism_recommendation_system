import 'package:tourism_recommendation_system/models/user_model.dart';
import 'package:tourism_recommendation_system/services/api_path.dart';

import 'firestore_service.dart';

abstract class Database {
  Future<void> deleteUser(MyUser user, String uid);

  Future<void> setUser(MyUser user, String uid);

  Stream<List<MyUser>> usersStream();
}

class FireStoreDatabase implements Database {
  FireStoreDatabase();

  final _service = FirestoreService.instance;


  @override
  Future<void> deleteUser(MyUser user, String uid) => _service.deleteData(
        path: APIPath.user(uid),
      );

  @override
  Future<void> setUser(MyUser user, String uid) => _service.setData(
        path: APIPath.user(uid),
        data: user.toMap(),
      );


  @override
  Stream<List<MyUser>> usersStream() => _service.collectionStream(
    path: APIPath.users(),
    builder: (data, documentId) => MyUser.fromMap(data, documentId),
  );
}
