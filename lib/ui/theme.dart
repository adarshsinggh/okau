import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  static const Color _iconColor = Colors.deepPurple;
  static final Color _lightNavigationColor = Colors.black45;
  static final Color _darkNavigationColor = Colors.white70;

  static const Color _lightPrimaryColor = Colors.white;
  static const Color _lightPrimaryVariantColor = Color(0XFFFAFAFA);
  static const Color _lightSeconderyColor = Colors.deepPurple;
  static const Color _lightSeconderyVariantColor = Colors.deepPurpleAccent;
  static const Color _lightOnPrimaryColor = Colors.black54;
  static const Color _darkPrimaryColor = Colors.black87;
  static const Color _darkPrimaryVariantColor = Color(0XFF1C1C1C);
  static const Color _darkSeconderyColor = Colors.deepPurple;
  static const Color _darkSeconderyVariantColor = Colors.deepPurpleAccent;
  static const Color _darkOnPrimaryColor = Colors.white;

  static final ThemeData lightTheme = ThemeData(
      textSelectionTheme:const TextSelectionThemeData(
        cursorColor: Colors.grey, //thereby
      ),
      scaffoldBackgroundColor: _lightPrimaryColor,
      // accentColor: _lightSeconderyColor,
      primaryColor: _darkSeconderyColor,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.dark),
        elevation: 2,
        color: _lightPrimaryColor,
        titleTextStyle: TextStyle(
          color: _lightSeconderyColor,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(
          color: _lightSeconderyColor,
        ),
      ),
      colorScheme: const ColorScheme(
        primary: _lightPrimaryColor,
        primaryVariant: _lightPrimaryVariantColor,
        secondary: _lightSeconderyColor,
        onPrimary: _lightOnPrimaryColor,
        error: _lightSeconderyColor,
        background: _lightPrimaryColor,
        brightness: Brightness.light,
        onBackground: _lightOnPrimaryColor,
        onError: _lightPrimaryColor,
        onSecondary: _lightOnPrimaryColor,
        onSurface: _lightOnPrimaryColor,
        secondaryVariant: _lightSeconderyVariantColor,
        surface: _lightPrimaryColor,
      ),
      iconTheme: const IconThemeData(
        color: _iconColor,
      ),
      cardTheme: const CardTheme(
        color: _lightPrimaryColor,
        elevation: 3,
        shadowColor: Colors.black38,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: _lightSeconderyColor,
        unselectedLabelColor: _lightOnPrimaryColor,
      ),
      textTheme: _lightTextTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: MaterialStateProperty.resolveWith<double>(
            (Set<MaterialState> states) => 3.0,
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => _lightSeconderyColor,
          ),
          overlayColor: MaterialStateProperty.all(Colors.black26),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )),
        ),
      ),
      canvasColor: _lightPrimaryColor,
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => _lightSeconderyColor,
        ),
      ),
      unselectedWidgetColor: _lightSeconderyColor,
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => _lightSeconderyColor,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _lightSeconderyColor,
        splashColor: _lightPrimaryVariantColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: _lightSeconderyColor,
        selectedIconTheme: const IconThemeData(
          color: _lightSeconderyColor,
        ),
        unselectedIconTheme: IconThemeData(
          color: _lightNavigationColor,
        ),
        backgroundColor: _lightSeconderyColor,
      ),
      primaryIconTheme: IconThemeData(
        color: _lightNavigationColor,
      ));

  static const TextTheme _lightTextTheme = TextTheme(
    headline5: _lightScreenHeadingTextStyle,
    headline6: _lightScreenHeadingTextStyle,
    bodyText1: _lightScreenHeadingTextStyle,
    bodyText2: _lightScreenHeadingTextStyle,
    button: _lightbuttonTextStyle,
  );

  static const TextStyle _lightScreenHeadingTextStyle = TextStyle(
    fontFamily: 'Montserrat',
    color: _lightOnPrimaryColor,
    fontSize: 14,
  );
  // ignore: unnecessary_const
  static const TextStyle _lightbuttonTextStyle = const TextStyle(
    color: _lightSeconderyColor,
  );

  static final ThemeData darkTheme = ThemeData(
      scaffoldBackgroundColor: _darkPrimaryVariantColor,
      primaryColor: _darkSeconderyColor,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.dark, statusBarIconBrightness: Brightness.light),
        color: _darkPrimaryVariantColor,
        elevation: 0,
        titleTextStyle: TextStyle(color: _darkOnPrimaryColor, fontSize: 20),
        iconTheme: IconThemeData(
          color: _darkOnPrimaryColor,
        ),
      ),
      colorScheme: const ColorScheme(
        primary: _darkPrimaryColor,
        primaryVariant: _darkPrimaryVariantColor,
        secondary: _darkSeconderyColor,
        onPrimary: _darkOnPrimaryColor,
        error: _darkSeconderyColor,
        background: _darkPrimaryColor,
        brightness: Brightness.dark,
        onBackground: _darkOnPrimaryColor,
        onError: _darkPrimaryColor,
        onSecondary: _darkOnPrimaryColor,
        onSurface: _darkOnPrimaryColor,
        secondaryVariant: _darkSeconderyVariantColor,
        surface: _darkPrimaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: MaterialStateProperty.resolveWith<double>(
            (Set<MaterialState> states) => 3.0,
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => _darkSeconderyColor,
          ),
          overlayColor: MaterialStateProperty.all(Colors.black26),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => _darkSeconderyVariantColor,
          ),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => _darkSeconderyColor,
        ),
      ),
      canvasColor: _darkPrimaryColor,
      tabBarTheme: const TabBarTheme(
        labelColor: _darkSeconderyColor,
        unselectedLabelColor: _darkOnPrimaryColor,
      ),
      unselectedWidgetColor: _darkSeconderyColor,
      iconTheme: const IconThemeData(
        color: _iconColor,
      ),
      textTheme: _darkTextTheme,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkSeconderyColor,
        splashColor: _darkPrimaryVariantColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: _darkSeconderyColor,
        selectedIconTheme: const IconThemeData(
          color: _darkSeconderyColor,
        ),
        unselectedIconTheme: IconThemeData(
          color: _darkNavigationColor,
        ),
        backgroundColor: _darkSeconderyColor,
      ),
      primaryIconTheme: IconThemeData(
        color: _darkNavigationColor,
      ));

  static const TextTheme _darkTextTheme = TextTheme(
    headline5: _darkScreenHeadingTextStyle,
    headline6: _darkScreenHeadingTextStyle,
    bodyText1: _darkScreenHeadingTextStyle,
    bodyText2: _darkScreenHeadingTextStyle,
    button: _darkbuttonTextStyle,
  );

  static const TextStyle _darkScreenHeadingTextStyle = TextStyle(
    fontFamily: 'Montserrat',
    color: _darkOnPrimaryColor,
    fontSize: 14,
  );
  static const TextStyle _darkbuttonTextStyle = TextStyle(
    color: _darkSeconderyColor,
  );
}
