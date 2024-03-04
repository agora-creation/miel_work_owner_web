import 'package:fluent_ui/fluent_ui.dart';
import 'package:miel_work_owner_web/models/chat.dart';
import 'package:miel_work_owner_web/models/organization.dart';
import 'package:miel_work_owner_web/models/user.dart';
import 'package:miel_work_owner_web/services/chat.dart';
import 'package:miel_work_owner_web/services/organization.dart';
import 'package:miel_work_owner_web/services/user.dart';

class OrganizationProvider with ChangeNotifier {
  final OrganizationService _organizationService = OrganizationService();
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();

  Future<String?> create({
    required String name,
    required String userName,
    required String userEmail,
    required String userPassword,
  }) async {
    String? error;
    if (name == '') return '団体名を入力してください';
    if (userName == '') return '管理者のお名前を入力してください';
    if (userEmail == '') return '管理者のメールアドレスを入力してください';
    if (userPassword == '') return '管理者のパスワードを入力してください';
    if (await _userService.emailCheck(email: userEmail)) {
      return '他のメールアドレスを入力してください';
    }
    try {
      String userId = _userService.id();
      _userService.create({
        'id': userId,
        'name': userName,
        'email': userEmail,
        'password': userPassword,
        'uid': '',
        'token': '',
        'createdAt': DateTime.now(),
      });
      String organizationId = _organizationService.id();
      _organizationService.create({
        'id': organizationId,
        'name': name,
        'adminUserIds': [userId],
        'userIds': [userId],
        'createdAt': DateTime.now(),
      });
      String id = _chatService.id();
      _chatService.create({
        'id': id,
        'organizationId': organizationId,
        'groupId': '',
        'userIds': [userId],
        'name': name,
        'lastMessage': '',
        'updatedAt': DateTime.now(),
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      error = '契約団体の追加に失敗しました';
    }
    return error;
  }

  Future<String?> update({
    required OrganizationModel organization,
    required String name,
  }) async {
    String? error;
    if (name == '') return '団体名を入力してください';
    try {
      _organizationService.update({
        'id': organization.id,
        'name': name,
      });
      ChatModel? chat = await _chatService.selectData(
        organizationId: organization.id,
      );
      if (chat != null) {
        _chatService.update({
          'id': chat.id,
          'name': name,
        });
      }
    } catch (e) {
      error = '契約団体の編集に失敗しました';
    }
    return error;
  }

  Future<String?> updateAdmin({
    required OrganizationModel organization,
    required List<UserModel> selectedUsers,
  }) async {
    String? error;
    if (selectedUsers.isEmpty) return 'スタッフを一人以上選択してください';
    List<String> adminUserIds = [];
    for (UserModel user in selectedUsers) {
      adminUserIds.add(user.id);
    }
    try {
      _organizationService.update({
        'id': organization.id,
        'adminUserIds': adminUserIds,
      });
    } catch (e) {
      error = '管理者を選択しました';
    }
    return error;
  }
}
