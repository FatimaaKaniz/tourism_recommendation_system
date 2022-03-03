
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  FirestoreService._();
  static final instance = FirestoreService._();
  Future<void> setData({required String? path, required Map<String, dynamic>?data}) async{
    final reference = FirebaseFirestore.instance.doc(path!);
    await reference.set(data!);
  }

  Future<void> deleteData({required String path}) async{
    final reference = FirebaseFirestore.instance.doc(path);
    print('Delete $path');
    await reference.delete();
  }

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query query = FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data() as Map<String, dynamic>, snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }
}