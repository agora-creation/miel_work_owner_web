import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String _id = '';
  String _organizationId = '';
  String _groupId = '';
  List<String> userIds = [];
  String _name = '';
  String _lastMessage = '';
  bool _personal = false;
  int _priority = 0;
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get organizationId => _organizationId;
  String get groupId => _groupId;
  String get name => _name;
  String get lastMessage => _lastMessage;
  bool get personal => _personal;
  int get priority => _priority;
  DateTime get createdAt => _createdAt;

  ChatModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();
    if (data == null) return;
    _id = data['id'] ?? '';
    _organizationId = data['organizationId'] ?? '';
    _groupId = data['groupId'] ?? '';
    userIds = _convertUserIds(data['userIds']);
    _name = data['name'] ?? '';
    _lastMessage = data['lastMessage'] ?? '';
    _personal = data['personal'] ?? false;
    _priority = data['priority'] ?? 0;
    _createdAt = data['createdAt'].toDate() ?? DateTime.now();
  }

  List<String> _convertUserIds(List list) {
    List<String> ret = [];
    for (dynamic id in list) {
      ret.add('$id');
    }
    return ret;
  }
}
