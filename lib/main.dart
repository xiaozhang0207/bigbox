import 'dart:io';

import 'package:bigbox/configs/firebase_options.dart';
import 'package:bigbox/configs/routes.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } else {
    await Firebase.initializeApp();
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.system);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return GetMaterialApp(
          title: 'Big Box',
          initialRoute: "/splash",
          getPages: routes,
          debugShowCheckedModeBanner: false,
          locale: Get.deviceLocale,
          darkTheme: AppTheme.darkTheme,
          theme: AppTheme.lightTheme,
        );
      },
    );
  }
}
