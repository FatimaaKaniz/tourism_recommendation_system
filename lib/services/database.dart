import 'package:tourism_recommendation_system/models/attraction_model.dart';
import 'package:tourism_recommendation_system/models/user_model.dart';
import 'package:tourism_recommendation_system/services/api_path.dart';

import 'firestore_service.dart';

abstract class Database {
  Future<void> deleteUser(MyUser user, String uid);

  Future<void> setUser(MyUser user, String uid);

  Future<void> updateUser(MyUser user, String uid);

  Stream<List<MyUser>> usersStream();

  Future<void> deleteAttraction(Attraction attraction, String attractionId);

  Future<void> setAttraction(Attraction attraction, String attractionId);

  Future<void> updateAttraction(Attraction attraction, String attractionId);

  Stream<List<Attraction>> attractionStream();

  String documentIdFromCurrentDate();
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
  Future<void> updateUser(MyUser user, String uid) async {
    await _service.deleteData(path: APIPath.user(uid));
    _service.setData(
      path: APIPath.user(uid),
      data: user.toMap(),
    );
  }

  @override
  Stream<List<MyUser>> usersStream() => _service.collectionStream(
        path: APIPath.users(),
        builder: (data, documentId) => MyUser.fromMap(data, documentId),
      );

  @override
  Future<void> deleteAttraction(Attraction attraction, String attractionId) =>
      _service.deleteData(
        path: APIPath.attraction(attractionId),
      );

  @override
  Future<void> setAttraction(Attraction attraction, String attractionId) =>
      _service.setData(
        path: APIPath.attraction(attractionId),
        data: attraction.toMap(),
      );

  @override
  Future<void> updateAttraction(
      Attraction attraction, String attractionId) async {
    await _service.deleteData(path: APIPath.attraction(attractionId));
    _service.setData(
      path: APIPath.attraction(attractionId),
      data: attraction.toMap(),
    );
  }

  @override
  Stream<List<Attraction>> attractionStream() => _service.collectionStream(
        path: APIPath.attractions(),
        builder: (data, documentId) => Attraction.fromMap(data, documentId),
      );

  String documentIdFromCurrentDate() => DateTime.now().toIso8601String();
}
