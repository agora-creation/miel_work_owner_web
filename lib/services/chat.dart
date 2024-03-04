import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miel_work_owner_web/models/chat.dart';

class ChatService {
  String collection = 'chat';
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

  Future<ChatModel?> selectData({
    required String organizationId,
  }) async {
    ChatModel? ret;
    await firestore
        .collection(collection)
        .where('organizationId', isEqualTo: organizationId)
        .where('groupId', isEqualTo: '')
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ret = ChatModel.fromSnapshot(value.docs.first);
      }
    });
    return ret;
  }
}
