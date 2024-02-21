import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationModel {
  String _id = '';
  String _name = '';
  String _adminUserId = '';
  List<String> userIds = [];
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get name => _name;
  String get adminUserId => _adminUserId;
  DateTime get createdAt => _createdAt;

  OrganizationModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();
    if (data == null) return;
    _id = data['id'] ?? '';
    _name = data['name'] ?? '';
    _adminUserId = data['adminUserId'] ?? '';
    userIds = _convertUserIds(data['userIds']);
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
