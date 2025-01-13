import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/shared/widget/primary_logo.dart';
import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    required this.title,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const PrimaryLogo(
          disableTxt: true,
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightGray,
          ),
        ),
      ],
    );
  }
}
