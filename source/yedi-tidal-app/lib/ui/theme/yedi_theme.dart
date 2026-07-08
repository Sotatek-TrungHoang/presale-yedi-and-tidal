import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

final yediColours = AppColours(
    landingIconBg: Color(0xFFEF9F1F),
    splashBackground: Color(0xFFF0E4D4),
    background: Color(0xFFF0E4D4),
    accent: Color(0xFFEF9F1F),
    primary: Color(0xFF000000),
    canvasBackground: Color(0xFFFFFFFF),
    bottomNavBackground: Color(0xFF000000),
    success: Color(0xFF1EA043),
    error: const Color(0xFFC62828));

final yediIcons = AppIcons(
  applicant: Icons.school,
  advertiser: Icons.apartment,
);

double yediBorderRadius = 8.0;
ThemeData yediTheme = ThemeData(
  brightness: Brightness.light,
  textTheme: GoogleFonts.soraTextTheme(const TextTheme(
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ))),
  scaffoldBackgroundColor: yediColours.background,
  // colorSchemeSeed: const Color(0xFFA5943F),
  canvasColor: yediColours.canvasBackground,
  colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: yediColours.primary,
      onPrimary: Colors.white,
      secondary: yediColours.primary,
      onSecondary: Colors.white,
      error: yediColours.error,
      onError: Colors.white,
      surface: yediColours.canvasBackground,
      onSurface: Colors.black),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    color: yediColours.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
  ),
  dividerTheme: DividerThemeData(
    color: Colors.black,
    thickness: 1,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: yediColours.bottomNavBackground,
    unselectedItemColor: Color(0xFF8C8C8C),
    selectedItemColor: Colors.white,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    enableFeedback: true,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: yediColours.canvasBackground,
    floatingLabelAlignment: FloatingLabelAlignment.start,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    floatingLabelStyle: const TextStyle(color: Colors.black),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    border: OutlineInputBorder(
        borderSide: const BorderSide(style: BorderStyle.none),
        borderRadius: BorderRadius.all(Radius.circular(yediBorderRadius))),
    enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(style: BorderStyle.none),
        borderRadius: BorderRadius.all(Radius.circular(yediBorderRadius))),
    outlineBorder: const BorderSide(style: BorderStyle.none),
    errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(style: BorderStyle.none),
        borderRadius: BorderRadius.all(Radius.circular(yediBorderRadius))),
    focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(style: BorderStyle.none),
        borderRadius: BorderRadius.all(Radius.circular(yediBorderRadius))),
    disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(style: BorderStyle.none),
        borderRadius: BorderRadius.all(Radius.circular(yediBorderRadius))),
    focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(style: BorderStyle.none),
        borderRadius: BorderRadius.all(Radius.circular(yediBorderRadius))),
  ),
  tabBarTheme: TabBarThemeData(
    tabAlignment: TabAlignment.fill,
    indicatorSize: TabBarIndicatorSize.tab,
    dividerHeight: 2,
    dividerColor: Colors.black,
    unselectedLabelStyle: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    labelStyle: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    labelPadding: EdgeInsets.symmetric(vertical: 8),
    indicator: UnderlineTabIndicator(
      insets: EdgeInsets.only(bottom: 2),
      borderSide: BorderSide(width: 4, color: yediColours.accent),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(yediBorderRadius)),
    textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.underline),
  )),
  bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: yediColours.background,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(yediBorderRadius),
              topRight: Radius.circular(yediBorderRadius)))),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: yediColours.accent,
    linearMinHeight: 4,
    linearTrackColor: Color(0xFFCCB79A),
    circularTrackColor: Color(0xFFCCB79A),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    elevation: 0,
    extendedTextStyle:
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(yediBorderRadius),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey.shade400,
          disabledForegroundColor: Colors.grey.shade100,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(yediBorderRadius)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          padding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16 * 2))),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(yediBorderRadius),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(yediBorderRadius)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          padding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16 * 2))),
);
