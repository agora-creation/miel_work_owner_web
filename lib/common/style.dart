import 'package:fluent_ui/fluent_ui.dart';

const kBackgroundColor = Color(0xFFFFD54F);
const kWhiteColor = Color(0xFFFFFFFF);
const kBlackColor = Color(0xFF333333);
const kGreyColor = Color(0xFF9E9E9E);
const kGrey600Color = Color(0xFF757575);
const kGrey300Color = Color(0xFFE0E0E0);
const kGrey200Color = Color(0xFFEEEEEE);
const kRedColor = Color(0xFFF44336);
const kRed300Color = Color(0xFFE57373);
const kBlueColor = Color(0xFF2196F3);
const kCyanColor = Color(0xFF00BCD4);
const kOrangeColor = Color(0xFFFF9800);

FluentThemeData customTheme() {
  return FluentThemeData(
    fontFamily: 'SourceHanSansJP-Regular',
    activeColor: kWhiteColor,
    cardColor: kWhiteColor,
    scaffoldBackgroundColor: kBackgroundColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    navigationPaneTheme: const NavigationPaneThemeData(
      backgroundColor: kBackgroundColor,
      highlightColor: kBackgroundColor,
    ),
    checkboxTheme: CheckboxThemeData(
      checkedDecoration: ButtonState.all<Decoration>(
        BoxDecoration(
          color: kBlueColor,
          border: Border.all(color: kBlueColor),
        ),
      ),
      uncheckedDecoration: ButtonState.all<Decoration>(
        BoxDecoration(
          color: kWhiteColor,
          border: Border.all(color: kGrey600Color),
        ),
      ),
    ),
  );
}
