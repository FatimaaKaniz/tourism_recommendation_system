import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:tourism_recommendation_system/models/attraction_model.dart';
import 'package:tourism_recommendation_system/models/user_model.dart';
import 'package:tourism_recommendation_system/services/api_path.dart';

import 'firestore_service.dart';

abstract class Database {
  Future<void> deleteUser(MyUser user, String uid);

  Future<void> setUser(MyUser user, String uid);

  Stream<List<MyUser>> usersStream();

  Future<void> deleteAttraction(Attraction attraction);

  Future<void> setAttraction(Attraction attraction, String attractionId);

  Future<void> updateAttraction(Attraction attraction);

  Stream<List<Attraction>> attractionStream();

  Stream<List<Attraction>> attractionStreamSortedBy(SortAttractionBy sortType,
      {bool isAscending = true});

  Stream<List<Attraction>> attractionStreamFilterByType({AttractionType? type});

  String documentIdFromCurrentDate();

  Future<String> uploadImage(File image, String path);

  Future<String> downloadImage(String path);

  Future<void> deleteImage(String path);
}

class FireStoreDatabase implements Database {
  FireStoreDatabase();

  final _service = FirestoreService.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

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

  @override
  Future<void> deleteAttraction(Attraction attraction) => _service.deleteData(
        path: APIPath.attraction(attraction.id!),
      );

  @override
  Future<void> setAttraction(Attraction attraction, String attractionId) =>
      _service.setData(
        path: APIPath.attraction(attractionId),
        data: attraction.toMap(),
      );

  @override
  Future<void> updateAttraction(Attraction attraction) async =>
      setAttraction(attraction, attraction.id!);

  @override
  Stream<List<Attraction>> attractionStream() => _service.collectionStream(
        path: APIPath.attractions(),
        builder: (data, documentId) => Attraction.fromMap(data, documentId),
      );

  @override
  Stream<List<Attraction>> attractionStreamFilterByType(
          {AttractionType? type}) =>
      _service.collectionStream(
        path: APIPath.attractions(),
        builder: (data, documentId) => Attraction.fromMap(data, documentId),
        queryBuilder: type != null
            ? (query) => query.where('attractionType', isEqualTo: type.name)
            : null,
      );

  @override
  Stream<List<Attraction>> attractionStreamSortedBy(SortAttractionBy sortType,
          {bool isAscending = true}) =>
      _service.collectionStream(
          path: APIPath.attractions(),
          builder: (data, documentId) => Attraction.fromMap(data, documentId),
          sort: (lhs, rhs) {
            switch (sortType) {
              case SortAttractionBy.country:
                {
                  return lhs.country!.compareTo(rhs.country!) *
                      (isAscending ? 1 : -1);
                }
              case SortAttractionBy.name:
                {
                  return lhs.name!.compareTo(rhs.name!) *
                      (isAscending ? 1 : -1);
                }
              case SortAttractionBy.attractionType:
                {
                  return lhs.attractionType!.name
                          .compareTo(rhs.attractionType!.name) *
                      (isAscending ? 1 : -1);
                }
            }
          });

  String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

  @override
  Future<void> deleteImage(String path) async {
    var storageRef = _storage.ref().child(path);
    await storageRef.delete();
  }

  @override
  Future<String> downloadImage(String path) async {
    var storageRef = _storage.ref().child(path);
    return storageRef.getDownloadURL();
  }

  @override
  Future<String> uploadImage(File image, String path) async {
    var storageRef = _storage.ref().child(path);
    var uploadTask = await storageRef.putFile(image);

    return uploadTask.ref.getDownloadURL();
  }
}
