import 'package:fluent_ui/fluent_ui.dart';
import 'package:miel_work_owner_web/common/functions.dart';
import 'package:miel_work_owner_web/common/style.dart';
import 'package:miel_work_owner_web/models/organization.dart';
import 'package:miel_work_owner_web/providers/login.dart';
import 'package:miel_work_owner_web/screens/login.dart';
import 'package:miel_work_owner_web/screens/organization_source.dart';
import 'package:miel_work_owner_web/services/organization.dart';
import 'package:miel_work_owner_web/widgets/custom_button_sm.dart';
import 'package:miel_work_owner_web/widgets/custom_column_label.dart';
import 'package:miel_work_owner_web/widgets/custom_data_grid.dart';
import 'package:miel_work_owner_web/widgets/custom_text_box.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OrganizationService organizationService = OrganizationService();
  List<OrganizationModel> organizations = [];

  Future _getData() async {
    List<OrganizationModel> tmpOrganizations =
        await organizationService.selectList();
    setState(() {
      organizations = tmpOrganizations;
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'みえるWORK - 統括管理者用',
              style: TextStyle(
                color: kWhiteColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            CustomButtonSm(
              labelText: 'ログアウト',
              labelColor: kWhiteColor,
              backgroundColor: kGreyColor,
              onPressed: () async {
                await loginProvider.logout();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  FluentPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '団体一覧',
                        style: TextStyle(fontSize: 16),
                      ),
                      CustomButtonSm(
                        labelText: '新規登録',
                        labelColor: kWhiteColor,
                        backgroundColor: kBlueColor,
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AddDialog(
                            getData: _getData,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 650,
                    child: CustomDataGrid(
                      source: OrganizationSource(
                        context: context,
                        organizations: organizations,
                        getData: _getData,
                      ),
                      columns: [
                        GridColumn(
                          columnName: 'name',
                          label: const CustomColumnLabel('団体名'),
                        ),
                        GridColumn(
                          columnName: 'loginId',
                          label: const CustomColumnLabel('ログインID'),
                        ),
                        GridColumn(
                          columnName: 'password',
                          label: const CustomColumnLabel('パスワード'),
                        ),
                        GridColumn(
                          columnName: 'edit',
                          label: const CustomColumnLabel('操作'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddDialog extends StatefulWidget {
  final Function() getData;

  const AddDialog({
    required this.getData,
    super.key,
  });

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  OrganizationService organizationService = OrganizationService();
  TextEditingController nameController = TextEditingController();
  TextEditingController loginIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text(
        '団体 - 新規登録',
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
          labelText: '登録する',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            if (nameController.text == '') return;
            if (loginIdController.text == '') return;
            if (passwordController.text == '') return;
            String id = organizationService.id();
            organizationService.create({
              'id': id,
              'name': nameController.text,
              'loginId': loginIdController.text,
              'password': passwordController.text,
              'createdAt': DateTime.now(),
            });
            await widget.getData();
            if (!mounted) return;
            showMessage(context, '団体情報を新規登録しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
