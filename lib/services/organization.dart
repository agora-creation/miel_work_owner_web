import 'package:cloud_firestore/cloud_firestore.dart';

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

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList() {
    return FirebaseFirestore.instance
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
