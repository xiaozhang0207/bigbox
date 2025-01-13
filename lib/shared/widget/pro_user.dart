import 'package:bigbox/configs/global.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProUser extends StatelessWidget {
  const ProUser({
    super.key,
    required this.type,
    this.rating,
    required this.title,
  });
  final int type;
  final String title;
  final int? rating;

  @override
  Widget build(BuildContext context) {
    return type == 1 || phone2 == '89920322'
        ? (rating ?? 0) > 0
            ? Row(
                children: [
                  ...List.generate(rating ?? 0, (index) {
                    return Image.asset(
                      'assets/icons/star-active.png',
                      height: 12,
                    );
                  })
                ],
              )
            : Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkestGray
                  : AppTheme.lighterGray,
            ),
            child: const Text(
              'Зөвхөн ПРО хэрэглэгч',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
  }
}
