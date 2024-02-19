import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miel_work_owner_web/models/organization.dart';

class OrganizationService {
  String collection = 'organization';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String id() {
    return firestore.collection(collection).doc().id;
  }

  void create(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).set(values);
  }

  void update(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).update(values);
  }

  Future<List<OrganizationModel>> selectList() async {
    List<OrganizationModel> ret = [];
    await firestore
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .get()
        .then((value) {
      for (DocumentSnapshot<Map<String, dynamic>> map in value.docs) {
        ret.add(OrganizationModel.fromSnapshot(map));
      }
    });
    return ret;
  }
}
