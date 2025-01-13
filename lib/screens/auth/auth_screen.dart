import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/widget/primary_logo.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:styled_widget/styled_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    bool light = Theme.of(context).brightness == Brightness.light;
    return ScafoldBuilder(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PrimaryLogo(),
              ButtonWidget(
                title: 'Нэвтрэх',
                onPress: () {
                  Get.offAndToNamed('/login');
                },
                hasIcon: false,
                foreground: light ? AppTheme.lighterGray : AppTheme.black,
                color: light ? AppTheme.primary : AppTheme.light,
                txtColor: light ? AppTheme.light : AppTheme.dark,
              ).padding(bottom: 16),
              ButtonWidget(
                title: 'Бүртгүүлэх',
                onPress: () {
                  Get.offAndToNamed('/register');
                },
                hasIcon: false,
                color: light ? AppTheme.light : AppTheme.darkestGray,
                foreground: light ? AppTheme.primary : AppTheme.black,
                shadowColor: AppTheme.transparent,
                surfaceTintColor: AppTheme.light,
                txtColor: light ? AppTheme.primary : AppTheme.light,
                border: light ? AppTheme.primary : AppTheme.light,
              ),
            ],
          ).expanded(),
          Column(
            children: [
              const Text(
                'BigBox аппликешн ашиглалтын',
                style: TextStyle(
                  fontSize: 12,
                ),
              ).padding(bottom: 4),
              const Text(
                'Үйлчилгээний нөхцөл',
                style: TextStyle(
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ).padding(bottom: 12),
            ],
          ).safeArea(),
        ],
      ).padding(horizontal: 24),
    );
  }
}
