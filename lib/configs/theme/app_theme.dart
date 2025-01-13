import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color light = Colors.white;
  static const Color dark = Color.fromRGBO(77, 77, 77, 1);

  static const Color primary = Color(0xff0963ff);
  static const Color second = Color(0xff9CE9E4);
  static const Color primarySecond = Color.fromRGBO(156, 233, 228, 1);
  static const Color secondary = Color(0xfffecc5b);

  static const Color lighterGray = Color(0xfff2f2f2);
  static const Color lightGray = Color(0xffa8a8a8);
  static const Color gray = Color.fromRGBO(243, 243, 243, 1);
  static const Color darkGray = Color(0xff505256);
  static const Color darkestGray = Color(0xff3a3c41);
  static const Color deepDarkGray = Color.fromARGB(255, 65, 65, 65);
  static const Color textDark = Color(0xff24272C);
  static const Color transparent = Colors.transparent;
  static const Color black = Color(0xff000000);

  static const Color bg = Color(0xffffffff);

  static const Color red = Color(0xffD94344);
  static const Color blue = Color(0xff3d9ccb);
  static const Color orange = Color(0xffFF8C05);
  static const Color yellow = Color(0xffFFD335);
  static const Color green = Color.fromARGB(255, 27, 146, 71);

  static final ThemeData lightTheme = ThemeData(
    fontFamily: 'OpenSans',
    brightness: Brightness.light,
    scaffoldBackgroundColor: bg,
    primaryColor: light,
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      // Primary
      primary: primary,
      onPrimary: light,
      onPrimaryContainer: dark,
      primaryContainer: light,

      //Secondary
      secondary: secondary,
      onSecondary: light,
      secondaryContainer: dark,
      onSecondaryContainer: light,
      //Background
      background: light,
      //Error
      error: primary,
      // errorContainer: primaryAccent,
      inversePrimary: dark,
    ),
    appBarTheme: const AppBarTheme(
      color: bg,
      titleTextStyle: _titleLightLarge,
      iconTheme: IconThemeData(color: primary, size: 18),
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(color: darkGray),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: light,
        backgroundColor: primary,
        minimumSize: const Size(double.infinity, 52),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        elevation: 0,
        disabledForegroundColor: lightGray,
        disabledBackgroundColor: darkGray,
      ),
    ),
    textTheme: _lightTheme,
  );

  static final ThemeData darkTheme = ThemeData(
      fontFamily: 'OpenSans',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: dark,
      primaryColor: dark,
      appBarTheme: const AppBarTheme(
        color: dark,
        titleTextStyle: _titleLightLarge,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        // Primary
        primary: primary,
        onPrimary: dark,
        onPrimaryContainer: light,
        primaryContainer: dark,

        //Secondary
        secondary: secondary,
        onSecondary: secondary,
        secondaryContainer: light,
        onSecondaryContainer: dark,
        //Background
        background: dark,
        //Error
        error: primary,
        // errorContainer: primaryAccent,
        inversePrimary: dark,
      ),
      dividerTheme: const DividerThemeData(color: darkGray),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: light,
          backgroundColor: primary,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          elevation: 0,
          disabledForegroundColor: lightGray,
          disabledBackgroundColor: darkGray,
        ),
      ),
      textTheme: _darkTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: light,
          backgroundColor: primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          disabledForegroundColor: lightGray,
          disabledBackgroundColor: darkGray,
        ),
      ));

  static const TextTheme _lightTheme = TextTheme(
    displayLarge: _displayLightLarge,
    displayMedium: _displayLightMedium,
    displaySmall: _displayLightSmall,
    headlineLarge: _headlineLightLarge,
    headlineMedium: _headlineLightMedium,
    headlineSmall: _headlineLightSmall,
    bodyLarge: _bodyLightLarge,
    bodyMedium: _bodyLightMedium,
    bodySmall: _bodyLightSmall,
    titleSmall: _titleLightSmall,
    titleMedium: _titleLightMedium,
    titleLarge: _titleLightLarge,
  );

  static const TextTheme _darkTheme = TextTheme(
    displayLarge: _displayDarkLarge,
    displayMedium: _displayDarkMedium,
    displaySmall: _displayDarkSmall,
    headlineLarge: _headlineDarkLarge,
    headlineMedium: _headlineDarkMedium,
    headlineSmall: _headlineDarkSmall,
    bodyLarge: _bodyDarkLarge,
    bodyMedium: _bodyDarkMedium,
    bodySmall: _bodyDarkSmall,
    titleSmall: _titleDarkSmall,
    titleMedium: _titleDarkMedium,
    titleLarge: _titleDarkLarge,
  );

  static const headLarge = 26.0;

  static const headMedium = 18.0;

  static const headSmall = 16.0;

  static const titleSmallFontSize = 14.0;

  static const bodyLargeFontSize = 16.0;

  static const bodyMediumFontSize = 14.0;

  static const bodySmallFontSize = 12.0;

  // LIGHT TEXT THEME
  static const TextStyle _displayLightLarge = TextStyle(
    fontSize: headLarge,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: "OpenSans",
  );

  static const TextStyle _displayLightMedium = TextStyle(
    fontSize: headMedium,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: "OpenSans",
  );

  static const TextStyle _displayLightSmall = TextStyle(
    fontSize: headSmall,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: "OpenSans",
  );

  static const TextStyle _headlineLightLarge = TextStyle(
    fontSize: headLarge,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: "OpenSans",
  );

  static const TextStyle _headlineLightMedium = TextStyle(
    fontSize: headMedium,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: "OpenSans",
  );

  static const TextStyle _headlineLightSmall = TextStyle(
    fontSize: headSmall,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: "OpenSans",
  );

  static const TextStyle _bodyLightLarge = TextStyle(
    fontSize: bodyLargeFontSize,
    fontWeight: FontWeight.normal,
    color: Colors.black,
    fontFamily: "OpenSans",
  );

  static const TextStyle _bodyLightMedium = TextStyle(
    fontSize: bodyMediumFontSize,
    fontWeight: FontWeight.normal,
    color: Colors.black,
    fontFamily: "OpenSans",
  );

  static const TextStyle _bodyLightSmall = TextStyle(
    fontSize: bodySmallFontSize,
    fontWeight: FontWeight.normal,
    color: Colors.black,
    fontFamily: "OpenSans",
  );

  static const TextStyle _titleLightSmall = TextStyle(
    fontSize: titleSmallFontSize,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: "OpenSans",
  );

  static const TextStyle _titleLightMedium = TextStyle(
    fontSize: headSmall,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: "OpenSans",
  );

  static const TextStyle _titleLightLarge = TextStyle(
    fontSize: headMedium,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: "OpenSans",
  );

  // DARK TEXT THEME
  static const TextStyle _displayDarkLarge = TextStyle(
    fontSize: headLarge,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: "OpenSans",
  );

  static const TextStyle _displayDarkMedium = TextStyle(
    fontSize: headMedium,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: "OpenSans",
  );

  static const TextStyle _displayDarkSmall = TextStyle(
    fontSize: headSmall,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: "OpenSans",
  );

  static const TextStyle _headlineDarkLarge = TextStyle(
    fontSize: headLarge,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: "OpenSans",
  );

  static const TextStyle _headlineDarkMedium = TextStyle(
    fontSize: headMedium,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: "OpenSans",
  );

  static const TextStyle _headlineDarkSmall = TextStyle(
    fontSize: headSmall,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: "OpenSans",
  );

  static const TextStyle _bodyDarkLarge = TextStyle(
    fontSize: bodyLargeFontSize,
    fontWeight: FontWeight.normal,
    color: Colors.white,
    fontFamily: "OpenSans",
  );

  static const TextStyle _bodyDarkMedium = TextStyle(
    fontSize: bodyMediumFontSize,
    fontWeight: FontWeight.normal,
    color: Colors.white,
    fontFamily: "OpenSans",
  );

  static const TextStyle _bodyDarkSmall = TextStyle(
    fontSize: bodySmallFontSize,
    fontWeight: FontWeight.normal,
    color: Colors.white,
    fontFamily: "OpenSans",
  );

  static const TextStyle _titleDarkSmall = TextStyle(
    fontSize: titleSmallFontSize,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: "OpenSans",
  );

  static const TextStyle _titleDarkMedium = TextStyle(
    fontSize: headSmall,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: "OpenSans",
  );

  static const TextStyle _titleDarkLarge = TextStyle(
    fontSize: headMedium,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: "OpenSans",
  );

  // CUSTOM TEXTSTYLES

  static const TextStyle hintStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: gray,
    fontFamily: "OpenSans",
  );

  static const TextStyle subtitleGray14 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: gray,
    fontFamily: "OpenSans",
  );

  static const TextStyle subtitleLightGray14 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: lightGray,
    fontFamily: "OpenSans",
  );

  static const TextStyle subtitleDarkGray14 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: darkGray,
    fontFamily: "OpenSans",
  );

  static const TextStyle subtitleGray12 = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: gray,
    fontFamily: "OpenSans",
  );

  static const TextStyle subtitleLightGray12 = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: lightGray,
    fontFamily: "OpenSans",
  );

  static const TextStyle subtitleDarkGray12 = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: darkGray,
    fontFamily: "OpenSans",
  );

  static const TextStyle subtitleBlack12 = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: Colors.black,
    fontFamily: "OpenSans",
  );

  static const TextStyle subtitleWhite12 = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: Colors.white,
    fontFamily: "OpenSans",
  );
}
