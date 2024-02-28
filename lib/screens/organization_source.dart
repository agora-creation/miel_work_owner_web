import 'package:fluent_ui/fluent_ui.dart';
import 'package:miel_work_owner_web/common/functions.dart';
import 'package:miel_work_owner_web/common/style.dart';
import 'package:miel_work_owner_web/models/organization.dart';
import 'package:miel_work_owner_web/models/user.dart';
import 'package:miel_work_owner_web/services/organization.dart';
import 'package:miel_work_owner_web/services/user.dart';
import 'package:miel_work_owner_web/widgets/custom_button_sm.dart';
import 'package:miel_work_owner_web/widgets/custom_column_label.dart';
import 'package:miel_work_owner_web/widgets/custom_text_box.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OrganizationSource extends DataGridSource {
  final BuildContext context;
  final List<OrganizationModel> organizations;

  OrganizationSource({
    required this.context,
    required this.organizations,
  }) {
    buildDataGridRows();
  }

  List<DataGridRow> dataGridRows = [];

  void buildDataGridRows() {
    dataGridRows = organizations.map<DataGridRow>((organization) {
      return DataGridRow(cells: [
        DataGridCell(
          columnName: 'id',
          value: organization.id,
        ),
        DataGridCell(
          columnName: 'name',
          value: organization.name,
        ),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final int rowIndex = dataGridRows.indexOf(row);
    Color backgroundColor = Colors.transparent;
    if ((rowIndex % 2) == 0) {
      backgroundColor = kWhiteColor;
    }
    List<Widget> cells = [];
    OrganizationModel organization = organizations.singleWhere(
      (e) => e.id == '${row.getCells()[0].value}',
    );
    cells.add(CustomColumnLabel('${row.getCells()[1].value}'));
    cells.add(Row(
      children: [
        CustomButtonSm(
          labelText: '編集',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () => showDialog(
            context: context,
            builder: (context) => ModDialog(
              organization: organization,
            ),
          ),
        ),
        const SizedBox(width: 4),
        CustomButtonSm(
          labelText: '管理者選択',
          labelColor: kWhiteColor,
          backgroundColor: kOrangeColor,
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AdminDialog(
              organization: organization,
            ),
          ),
        ),
      ],
    ));
    return DataGridRowAdapter(color: backgroundColor, cells: cells);
  }

  @override
  Future<void> handleLoadMoreRows() async {
    await Future<void>.delayed(const Duration(seconds: 5));
    buildDataGridRows();
    notifyListeners();
  }

  @override
  Future<void> handleRefresh() async {
    await Future<void>.delayed(const Duration(seconds: 5));
    buildDataGridRows();
    notifyListeners();
  }

  @override
  Widget? buildTableSummaryCellWidget(
    GridTableSummaryRow summaryRow,
    GridSummaryColumn? summaryColumn,
    RowColumnIndex rowColumnIndex,
    String summaryValue,
  ) {
    Widget? widget;
    Widget buildCell(
      String value,
      EdgeInsets padding,
      Alignment alignment,
    ) {
      return Container(
        padding: padding,
        alignment: alignment,
        child: Text(value, softWrap: false),
      );
    }

    widget = buildCell(
      summaryValue,
      const EdgeInsets.all(4),
      Alignment.centerLeft,
    );
    return widget;
  }

  void updateDataSource() {
    notifyListeners();
  }
}

class ModDialog extends StatefulWidget {
  final OrganizationModel organization;

  const ModDialog({
    required this.organization,
    super.key,
  });

  @override
  State<ModDialog> createState() => _ModDialogState();
}

class _ModDialogState extends State<ModDialog> {
  OrganizationService organizationService = OrganizationService();
  TextEditingController organizationNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    organizationNameController.text = widget.organization.name;
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text(
        '団体情報を編集する',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLabel(
              label: '団体名',
              child: CustomTextBox(
                controller: organizationNameController,
                placeholder: '',
                keyboardType: TextInputType.text,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      actions: [
        CustomButtonSm(
          labelText: 'キャンセル',
          labelColor: kWhiteColor,
          backgroundColor: kGreyColor,
          onPressed: () => Navigator.pop(context),
        ),
        CustomButtonSm(
          labelText: '入力内容を保存',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error;
            if (organizationNameController.text == '') {
              error = '団体名を入力してください';
            }
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            organizationService.update({
              'id': widget.organization.id,
              'name': organizationNameController.text,
            });
            if (!mounted) return;
            showMessage(context, '団体情報を編集しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class AdminDialog extends StatefulWidget {
  final OrganizationModel organization;

  const AdminDialog({
    required this.organization,
    super.key,
  });

  @override
  State<AdminDialog> createState() => _AdminDialogState();
}

class _AdminDialogState extends State<AdminDialog> {
  OrganizationService organizationService = OrganizationService();
  UserService userService = UserService();
  List<UserModel> users = [];
  List<UserModel> selectedUsers = [];

  void _init() async {
    users = await userService.selectList(
      userIds: widget.organization.userIds,
    );
    for (UserModel user in users) {
      if (widget.organization.adminUserIds.contains(user.id)) {
        selectedUsers.add(user);
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text(
        '管理者を選択する',
        style: TextStyle(fontSize: 18),
      ),
      content: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          UserModel user = users[index];
          return Checkbox(
            checked: selectedUsers.contains(user),
            onChanged: (value) {
              if (selectedUsers.contains(user)) {
                selectedUsers.remove(user);
              } else {
                selectedUsers.add(user);
              }
              setState(() {});
            },
            content: Text(user.name),
          );
        },
      ),
      actions: [
        CustomButtonSm(
          labelText: 'キャンセル',
          labelColor: kWhiteColor,
          backgroundColor: kGreyColor,
          onPressed: () => Navigator.pop(context),
        ),
        CustomButtonSm(
          labelText: '入力内容を保存',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error;
            if (selectedUsers.isEmpty) {
              error = 'スタッフを一人以上選択してください';
            }
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            List<String> adminUserIds = [];
            for (UserModel user in selectedUsers) {
              adminUserIds.add(user.id);
            }
            organizationService.update({
              'id': widget.organization.id,
              'adminUserIds': adminUserIds,
            });
            if (!mounted) return;
            showMessage(context, '管理者を選択しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
