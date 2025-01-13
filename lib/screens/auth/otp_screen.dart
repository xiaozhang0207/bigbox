import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/auth_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/input.dart';
import 'package:bigbox/shared/widget/primary_logo.dart';
import 'package:bigbox/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:styled_widget/styled_widget.dart';

class OtpScreen extends StatefulWidget {
  final String? otp;
  final String phone;
  final String type;
  const OtpScreen({
    super.key,
    this.otp,
    required this.phone,
    required this.type,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController password = TextEditingController();
  TextEditingController rePassword = TextEditingController();
  TextEditingController otp = TextEditingController();
  late List<FocusNode> otpFocus = [];
  FocusNode passwordFocus = FocusNode();
  FocusNode rePasswordFocus = FocusNode();
  bool showPassword = false;
  bool showRePassword = false;
  bool isLoading = false;
  bool otpDone = false;

  void setStates() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    password.clear();
    rePassword.clear();
    isLoading = false;
    otpFocus = [
      FocusNode(),
      FocusNode(),
      FocusNode(),
      FocusNode(),
    ];
    otpDone = false;
    unFocus();
    setStates();
  }

  void unFocus() {
    if (passwordFocus.hasFocus) {
      passwordFocus.unfocus();
    }
    if (rePasswordFocus.hasFocus) {
      rePasswordFocus.unfocus();
    }
    for (int i = 0; i < otpFocus.length; i++) {
      if (otpFocus[i].hasFocus) {
        otpFocus[i].unfocus();
      }
    }
  }

  void checkOtp() {
    unFocus();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool light = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      onTap: () => unFocus(),
      child: ScafoldBuilder(
        resizeToAvoidBottomInset: true,
        appbar: CustomAppBar(
          title: !otpDone ? 'OTP баталгаажуулалт' : 'Нууц үг үүсгэх',
          leading: GestureDetector(
            onTap: () {
              if (isLoading) return;
              Get.back();
            },
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: light ? AppTheme.deepDarkGray : AppTheme.lighterGray,
              size: 22,
            ),
          ),
        ),
        child: SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const PrimaryLogo(),
                if (!otpDone)
                  InputWidget(
                    controller: otp,
                    otpFocus: otpFocus,
                    hasIcon: true,
                    lbl: 'OTP КОД',
                    setState: setStates,
                    type: TextInputType.number,
                    input: 'otp',
                    lblAlign: TextAlign.center,
                    obscureText: false,
                    onFinishOtp: () {
                      if (otp.text == widget.otp) {
                        otpDone = true;
                        setStates();
                      } else {
                        showToast('Баталгаажуулах код буруу байна.',
                            AnimatedSnackBarType.warning);
                      }
                    },
                  ),
                if (otpDone)
                  Column(
                    children: [
                      InputWidget(
                        controller: password,
                        focus: passwordFocus,
                        lbl: 'Шинэ нууц үг',
                        isPassword: true,
                        setState: setStates,
                        obscureText: !showPassword,
                        passwordShow: () {
                          showPassword = !showPassword;
                          setStates();
                        },
                      ).padding(top: 22),
                      InputWidget(
                        controller: rePassword,
                        focus: rePasswordFocus,
                        lbl: 'Нууц үг дахин оруулах',
                        isPassword: true,
                        setState: setStates,
                        obscureText: !showRePassword,
                        passwordShow: () {
                          showRePassword = !showRePassword;
                          setStates();
                        },
                      ).padding(top: 22),
                      ButtonWidget(
                        title: widget.type == 'register'
                            ? 'Бүртгүүлэх'
                            : 'Нууц үг сэргээх',
                        isLoading: isLoading,
                        onPress: () async {
                          if (isLoading) return;
                          if (password.text.length < 8 ||
                              rePassword.text.length < 8) {
                            showToast('Нууц үг багадаа 8 тэмдэгт байх ёстой',
                                AnimatedSnackBarType.warning);
                            return;
                          }
                          if (password.text != rePassword.text) {
                            showToast('Нууц үг таарахгүй байна',
                                AnimatedSnackBarType.warning);
                            return;
                          }
                          ResponseModel res = widget.type == 'register'
                              ? await AuthRepository().signUp(
                                  phone: widget.phone,
                                  otp: widget.otp ?? "",
                                  password: password.text)
                              : await AuthRepository().recoveryPassword(
                                  phone: widget.phone,
                                  otp: widget.otp ?? '',
                                  password: password.text);
                          if (res.status == 200 && (res.success ?? false)) {
                            Get.offAllNamed('/auth');
                          }
                          showToast(
                              res.message ?? "",
                              res.status == 200
                                  ? AnimatedSnackBarType.success
                                  : AnimatedSnackBarType.warning);
                        },
                        hasIcon: false,
                        disable: (password.text.length < 8 ||
                            rePassword.text.length < 8 ||
                            password.text != rePassword.text),
                      ).padding(top: 24),
                    ],
                  ),
              ],
            ).width(size.width).padding(horizontal: 24, top: size.height * .15),
          ),
        ),
      ),
    );
  }
}
