import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miel_work_owner_web/models/user.dart';

class UserService {
  String collection = 'user';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String id() {
    return firestore.collection(collection).doc().id;
  }

  void create(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).set(values);
  }

  Future<bool> emailCheck({
    required String email,
  }) async {
    bool ret = false;
    await firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ret = true;
      }
    });
    return ret;
  }

  Future<UserModel?> selectData({
    required String id,
  }) async {
    UserModel? ret;
    await firestore
        .collection(collection)
        .where('id', isEqualTo: id)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ret = UserModel.fromSnapshot(value.docs.first);
      }
    });
    return ret;
  }

  Future<List<UserModel>> selectList({
    required List<String> userIds,
  }) async {
    List<UserModel> ret = [];
    await firestore
        .collection(collection)
        .orderBy('createdAt', descending: false)
        .get()
        .then((value) {
      for (DocumentSnapshot<Map<String, dynamic>> map in value.docs) {
        UserModel user = UserModel.fromSnapshot(map);
        if (userIds.contains(user.id)) {
          ret.add(user);
        }
      }
    });
    return ret;
  }
}
