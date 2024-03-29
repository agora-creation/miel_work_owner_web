import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miel_work_owner_web/common/functions.dart';
import 'package:miel_work_owner_web/common/style.dart';
import 'package:miel_work_owner_web/models/organization.dart';
import 'package:miel_work_owner_web/providers/login.dart';
import 'package:miel_work_owner_web/providers/organization.dart';
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
              'ひろめWORK - 統括管理画面',
              style: TextStyle(
                color: kBlackColor,
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
      content: Padding(
        padding: const EdgeInsets.all(16),
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
                      'この『ひろめWORK』の利用契約を結んでいる団体を一覧表示しています。',
                      style: TextStyle(fontSize: 14),
                    ),
                    CustomButtonSm(
                      labelText: '契約団体を追加',
                      labelColor: kWhiteColor,
                      backgroundColor: kBlueColor,
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => const AddDialog(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: organizationService.streamList(),
                    builder: (context, snapshot) {
                      List<OrganizationModel> organizations = [];
                      if (snapshot.hasData) {
                        for (DocumentSnapshot<Map<String, dynamic>> doc
                            in snapshot.data!.docs) {
                          organizations
                              .add(OrganizationModel.fromSnapshot(doc));
                        }
                      }
                      if (organizations.isEmpty) {
                        return const Center(child: Text('契約している団体が存在しません'));
                      }
                      return CustomDataGrid(
                        source: OrganizationSource(
                          context: context,
                          organizations: organizations,
                        ),
                        columns: [
                          GridColumn(
                            columnName: 'name',
                            label: const CustomColumnLabel('団体名'),
                          ),
                          GridColumn(
                            columnName: 'edit',
                            label: const CustomColumnLabel('操作'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddDialog extends StatefulWidget {
  const AddDialog({super.key});

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final organizationProvider = Provider.of<OrganizationProvider>(context);
    return ContentDialog(
      title: const Text(
        '契約団体を追加する',
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
              label: '管理者のお名前',
              child: CustomTextBox(
                controller: userNameController,
                placeholder: '',
                keyboardType: TextInputType.text,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: '管理者のメールアドレス',
              child: CustomTextBox(
                controller: userEmailController,
                placeholder: '',
                keyboardType: TextInputType.emailAddress,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: '管理者のパスワード',
              child: CustomTextBox(
                controller: userPasswordController,
                placeholder: '',
                keyboardType: TextInputType.visiblePassword,
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
          labelText: '追加する',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error = await organizationProvider.create(
              name: nameController.text,
              userName: userNameController.text,
              userEmail: userEmailController.text,
              userPassword: userPasswordController.text,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            if (!mounted) return;
            showMessage(context, '契約団体を追加しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
