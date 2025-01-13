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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController phone = TextEditingController();
  FocusNode pfocus = FocusNode();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    phone = TextEditingController();
    unFocus();
    isLoading = false;
    setStates();
  }

  void setStates() {
    if (mounted) setState(() {});
  }

  void unFocus() {
    if (pfocus.hasFocus) {
      pfocus.unfocus();
    }
  }

  @override
  void dispose() {
    super.dispose();
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
        appbar: const CustomAppBar(
          leading: SizedBox(),
          title: 'Бүртгүүлэх',
        ),
        child: SizedBox(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PrimaryLogo(),
                InputWidget(
                  controller: phone,
                  focus: pfocus,
                  hasIcon: false,
                  lbl: 'Утасны дугаар',
                  setState: setStates,
                  type: TextInputType.number,
                  obscureText: false,
                  icon: Image.asset(
                    'assets/icons/phone${light ? '' : '-white'}.png',
                    width: 22,
                  ).padding(right: 14),
                ).padding(vertical: 22),
                ButtonWidget(
                  title: 'Үргэлжлүүлэх',
                  onPress: () async {
                    if (isLoading) return;
                    if (phone.text.length != 8) {
                      return;
                    }
                    isLoading = true;
                    setStates();
                    ResponseModel res =
                        await AuthRepository().sendOtp(phone: phone.text);
                    isLoading = false;
                    setStates();
                    if (!(res.success ?? false)) {
                      showToast(res.message ?? 'Алдаа гарлаа',
                          AnimatedSnackBarType.warning);
                      return;
                    }
                    Get.toNamed('/otp', arguments: [
                      res.otp ?? "",
                      phone.text,
                      'register',
                    ]);
                  },
                  isLoading: isLoading,
                  hasIcon: false,
                  disable: (phone.text.length != 8),
                ).padding(bottom: 24, top: 12),
                Container(
                  width: size.width * .2,
                  height: .5,
                  color: light ? AppTheme.lighterGray : AppTheme.darkGray,
                ),
                GestureDetector(
                  onTap: () {
                    if (isLoading) return;
                    Get.offAndToNamed('/login');
                  },
                  child: Container(
                    width: size.width * .5,
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Нэвтрэх',
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
