// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/auth_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/input.dart';
import 'package:bigbox/shared/widget/primary_logo.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:styled_widget/styled_widget.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  TextEditingController password = TextEditingController();
  TextEditingController rePassword = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  FocusNode rePasswordFocus = FocusNode();
  bool showPassword = false;
  bool showRePassword = false;
  bool isLoading = false;

  void setStates() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    password.clear();
    rePassword.clear();
    isLoading = false;
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
  }

  void recovery() async {
    if (isLoading ||
        password.text == '' ||
        rePassword.text == '' ||
        (password.text != rePassword.text)) return;
    isLoading = true;
    setStates();
    ResponseModel res =
        await AuthRepository().changePassword(password: password.text);
    String msg = (res.message ?? '').replaceAll('Invalid data: ', '');
    msg = !msg.contains('message')
        ? res.status == 200
            ? 'Амжилттай'
            : 'Алдаа гарлаа'
        : jsonDecode(msg)[0]?['message'] ?? 'Алдаа гарлаа';
    SnackBar snackBar = SnackBar(
      content: Text(msg),
      duration: const Duration(milliseconds: 1000),
      backgroundColor: AppTheme.primary,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    isLoading = false;
    setStates();
    if (res.status == 200) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return GestureDetector(
      onTap: () => unFocus(),
      child: ScafoldBuilder(
        appbar: const CustomAppBar(
          title: 'Нууц үг үүсгэх',
          isCamera: true,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const PrimaryLogo(),
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
                  ],
                ),
              ),
            ).expanded(),
            ButtonWidget(
              title: 'Хадгалах',
              onPress: recovery,
              isLoading: isLoading,
              hasIcon: false,
            ),
          ],
        ).padding(
          horizontal: 20,
          bottom: padding.bottom + 12,
        ),
      ),
    );
  }
}
