import 'package:fluent_ui/fluent_ui.dart';
import 'package:miel_work_owner_web/common/functions.dart';
import 'package:miel_work_owner_web/common/style.dart';
import 'package:miel_work_owner_web/models/organization.dart';
import 'package:miel_work_owner_web/services/organization.dart';
import 'package:miel_work_owner_web/widgets/custom_button_sm.dart';
import 'package:miel_work_owner_web/widgets/custom_column_label.dart';
import 'package:miel_work_owner_web/widgets/custom_text_box.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OrganizationSource extends DataGridSource {
  final BuildContext context;
  final List<OrganizationModel> organizations;
  final Function() getData;

  OrganizationSource({
    required this.context,
    required this.organizations,
    required this.getData,
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
        DataGridCell(
          columnName: 'loginId',
          value: organization.loginId,
        ),
        DataGridCell(
          columnName: 'password',
          value: organization.password,
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
    cells.add(CustomColumnLabel('${row.getCells()[2].value}'));
    cells.add(CustomColumnLabel('${row.getCells()[3].value}'));
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
              getData: getData,
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
  final Function() getData;

  const ModDialog({
    required this.organization,
    required this.getData,
    super.key,
  });

  @override
  State<ModDialog> createState() => _ModDialogState();
}

class _ModDialogState extends State<ModDialog> {
  OrganizationService organizationService = OrganizationService();
  TextEditingController nameController = TextEditingController();
  TextEditingController loginIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.organization.name;
    loginIdController.text = widget.organization.loginId;
    passwordController.text = widget.organization.password;
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text(
        '団体 - 編集',
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
                controller: nameController,
                placeholder: '',
                keyboardType: TextInputType.text,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'ログインID',
              child: CustomTextBox(
                controller: loginIdController,
                placeholder: '',
                keyboardType: TextInputType.text,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'パスワード',
              child: CustomTextBox(
                controller: passwordController,
                placeholder: '',
                keyboardType: TextInputType.visiblePassword,
                maxLines: 1,
                obscureText: true,
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
            if (nameController.text == '') return;
            if (loginIdController.text == '') return;
            if (passwordController.text == '') return;
            organizationService.update({
              'id': widget.organization.id,
              'name': nameController.text,
              'loginId': loginIdController.text,
              'password': passwordController.text,
            });
            await widget.getData();
            if (!mounted) return;
            showMessage(context, '団体情報を編集しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
