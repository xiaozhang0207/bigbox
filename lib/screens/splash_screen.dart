import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/config_notification.dart';
import 'package:bigbox/configs/global.dart';
import 'package:bigbox/domain/models/user_model.dart';
import 'package:bigbox/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:styled_widget/styled_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    var locale = const Locale('mn', 'MN');
    Get.updateLocale(locale);
    locale = locale;
    isLoading = true;
    setState(() {});
    fetchData();
  }

  void fetchData() async {
    final SharedPreferences prefs = await _prefs;
    try {
      await ConfigNotification().initialise();
    } catch (e) {
      log('ERROR::::::::::: FirebaseMessaging.instance.requestPermission ::::: $e');
    }
    usr = UserModel.fromJson(jsonDecode(prefs.getString('usr') ?? "{}"));
    tkn = prefs.getString('token') ?? "";
    init();
  }

  void init() async {
    Timer(const Duration(seconds: 2), () async {
      if (tkn == '' || (usr.phone ?? "") == "") {
        Get.offAllNamed('/auth');
      } else {
        usr.deviceToken = deviceId;
        if (deviceId != '') {
          final SharedPreferences prefs = await _prefs;
          await AuthRepository().deviceTokenUpdate(token: deviceId);
          unawaited(prefs.setString('usr', jsonEncode(usr.toJson())));
        }
        Get.offAllNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    return ScafoldBuilder(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Image.asset(
              'assets/logo${light ? '' : '-white'}.png',
              width: 100,
            ).center(),
          ),
          const SafeArea(
            child: Text(
              'Шинэчлэл татаж байна',
              style: TextStyle(
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
