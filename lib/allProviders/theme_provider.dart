import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider({ThemeMode mode = ThemeMode.system}) : _themeMode = mode;

  void toggleMode(bool isOn) async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool('theme', isOn);
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }
}

class MyTheme {
  static const colorPrimaryLight = Color(0xFFffffff);
  static const colorPrimaryVariantLight = Color(0xFFbcc3cb);
  static const colorSecondaryLight = Color(0xFF7c828f);
  static const colorSecondaryVariantLight = Color(0xFF4db1dd);

  static const colorPrimaryDark = Color(0xFF141a32);
  static const colorPrimaryVariantDark = Color(0xFF5a6583);
  static const colorSecondaryDark = Color(0xFF809cf5);
  static const colorSecondaryVariantDark = Color(0xFFd2d2d7);
  static const colorDarkBackground = Color(0xFF3E65FC);

  static final lightTheme = ThemeData(
      colorScheme: const ColorScheme.light().copyWith(
          primary: colorPrimaryLight,
          primaryVariant: colorPrimaryVariantLight,
          secondary: colorSecondaryLight,
          secondaryVariant: colorSecondaryVariantLight),
      scaffoldBackgroundColor: colorPrimaryLight,
      appBarTheme: const AppBarTheme(
          backgroundColor: colorPrimaryLight,
          centerTitle: true,
          titleTextStyle: TextStyle(
              color: Color(0xFF29315A),
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
          iconTheme: IconThemeData(color: Color(0xFF29315A))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0)),
              shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0))),
              backgroundColor:
                  MaterialStateProperty.all<Color>(colorSecondaryLight),
              foregroundColor: MaterialStateProperty.all<Color>(
                  colorSecondaryVariantLight))),
      textTheme: const TextTheme(
          subtitle1:
              TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 14),
          headline4: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: BorderSide.none), filled: true, fillColor: Colors.grey.withOpacity(0.1)),
      iconTheme: const IconThemeData(color: Color(0xFF29315A), opacity: 0.8));

  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: colorPrimaryDark,
    appBarTheme: const AppBarTheme(
        backgroundColor: colorPrimaryDark,
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: colorPrimaryLight,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic),
        iconTheme: IconThemeData(color: colorPrimaryLight)),
    iconTheme: const IconThemeData(color: Colors.white, opacity: 0.8),
    colorScheme: const ColorScheme.dark().copyWith(
        primary: colorPrimaryDark,
        primaryVariant: colorPrimaryVariantDark,
        secondary: colorSecondaryDark,
        secondaryVariant: colorSecondaryVariantDark,
        background: colorDarkBackground),
    switchTheme: SwitchThemeData(
        trackColor: MaterialStateProperty.all<Color>(Colors.grey),
        thumbColor: MaterialStateProperty.all<Color>(Colors.white)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0))),
          backgroundColor: MaterialStateProperty.all<Color>(colorSecondaryDark),
          foregroundColor:
              MaterialStateProperty.all<Color>(colorSecondaryVariantDark)),
    ),
    textTheme: const TextTheme(
        subtitle1: TextStyle(
            color: Colors.white, fontWeight: FontWeight.normal, fontSize: 14),
        headline4: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
    inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1)),
  );
}
