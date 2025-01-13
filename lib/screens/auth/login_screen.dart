import 'dart:async';
import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/global.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/models/user_model.dart';
import 'package:bigbox/domain/repositories/auth_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/input.dart';
import 'package:bigbox/shared/widget/primary_logo.dart';
import 'package:bigbox/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:styled_widget/styled_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  FocusNode ufocus = FocusNode();
  FocusNode pfocus = FocusNode();
  bool showPassword = false;
  bool isLoading = false;
  SharedPreferences? prefs;
  bool loginSaved = false;

  @override
  void initState() {
    super.initState();
    username = TextEditingController();
    password = TextEditingController();
    ufocus.unfocus();
    showPassword = false;
    isLoading = false;
    loginSaved = false;
    setStates();
    fetchData();
  }

  void fetchData() async {
    prefs = await _prefs;
    loginSaved = bool.parse(prefs?.getString('loginSaved') ?? "false");
    username.text = prefs?.getString('loginUsername') ?? "";
    password.text = prefs?.getString('loginPassword') ?? "";
    setStates();
  }

  void setStates() {
    if (mounted) setState(() {});
  }

  void unFocus() {
    if (ufocus.hasFocus) {
      ufocus.unfocus();
    }
    if (pfocus.hasFocus) {
      pfocus.unfocus();
    }
  }

  @override
  void dispose() {
    super.dispose();
    unFocus();
  }

  void login() async {
    if (isLoading) return;
    if (username.text.length != 8 || password.text == '') {
      return;
    }
    isLoading = true;
    setStates();
    ResponseModel res = await AuthRepository().signIn(
      phone: username.text,
      password: password.text,
    );
    if (!(res.success ?? false)) {
      showToast(res.message ?? 'Алдаа гарлаа', AnimatedSnackBarType.warning);
      isLoading = false;
      setStates();
      return;
    }
    tkn = res.data['token'] ?? '';
    usr = UserModel.fromJson(res.data['user']);
    usr.deviceToken = deviceId;
    if (deviceId != '') {
      await AuthRepository().deviceTokenUpdate(token: deviceId);
    }
    isLoading = false;
    setStates();
    unawaited(prefs?.setString('usr', jsonEncode(usr.toJson())));
    unawaited(prefs?.setString('token', tkn));
    if (loginSaved) {
      unawaited(prefs?.setString('loginSaved', 'true'));
      unawaited(prefs?.setString('loginUsername', username.text));
      unawaited(prefs?.setString('loginPassword', password.text));
    } else {
      unawaited(prefs?.setString('loginSaved', 'false'));
      unawaited(prefs?.setString('loginUsername', ''));
      unawaited(prefs?.setString('loginPassword', ''));
    }
    Get.offAllNamed('/home');
    showToast(res.message ?? 'Амжилттай', AnimatedSnackBarType.success);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool light = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      onTap: () => unFocus(),
      child: ScafoldBuilder(
        resizeToAvoidBottomInset: true,
        appbar: const CustomAppBar(
          leading: SizedBox(),
          title: 'Нэвтрэх',
        ),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PrimaryLogo(),
                InputWidget(
                  controller: username,
                  focus: ufocus,
                  hasIcon: false,
                  lbl: 'Утасны дугаар',
                  setState: setStates,
                  type: TextInputType.number,
                  obscureText: false,
                  icon: Image.asset(
                    'assets/icons/user${light ? '' : '-white'}.png',
                    width: 22,
                  ).padding(right: 14),
                ).padding(bottom: 16),
                InputWidget(
                  controller: password,
                  focus: pfocus,
                  lbl: 'Нууц үг',
                  icon: Icon(
                    Icons.lock,
                    color: light ? AppTheme.primary : AppTheme.light,
                  ).padding(right: 14),
                  isPassword: true,
                  setState: setStates,
                  obscureText: !showPassword,
                  passwordShow: () {
                    showPassword = !showPassword;
                    setStates();
                  },
                ).padding(bottom: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        loginSaved = !loginSaved;
                        setStates();
                      },
                      child: Container(
                        color: light ? AppTheme.light : AppTheme.deepDarkGray,
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color:
                                      light ? AppTheme.gray : AppTheme.primary,
                                ),
                              ),
                              child: !loginSaved
                                  ? const SizedBox()
                                  : Icon(
                                      Icons.check,
                                      color: light
                                          ? AppTheme.primary
                                          : AppTheme.light,
                                      size: 18,
                                    ),
                            ),
                            const Text(
                              'Бүртгэл сануулах',
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ).padding(left: 8),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (isLoading) return;
                        Get.toNamed('/password-recovery');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          'Нууц үг сэргээх',
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ).padding(left: 20),
                      ),
                    ),
                  ],
                ),
                ButtonWidget(
                  title: 'Нэвтрэх',
                  onPress: login,
                  hasIcon: false,
                  isLoading: isLoading,
                  disable: username.text.length != 8 || password.text == '',
                ).padding(bottom: 24, top: 12),
                Container(
                  width: size.width * .2,
                  height: .5,
                  color: light ? AppTheme.lighterGray : AppTheme.darkGray,
                ),
                GestureDetector(
                  onTap: () {
                    if (isLoading) return;
                    Get.offAndToNamed('/register');
                  },
                  child: Container(
                    width: size.width * .5,
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Бүртгүүлэх',
                      style: TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ).center(),
                  ),
                ),
              ],
            ).width(size.width).padding(horizontal: 24, top: size.height * .15),
          ),
        ),
      ),
    );
  }
}
