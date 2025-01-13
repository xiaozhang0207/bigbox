import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class PrimaryLogo extends StatelessWidget {
  final bool? disableTxt;
  const PrimaryLogo({
    super.key,
    this.disableTxt,
  });

  @override
  Widget build(BuildContext context) {
    bool light = Theme.of(context).brightness == Brightness.light;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logo${light ? '' : '-white'}.png',
          width: (disableTxt ?? false) ? 50 : 80,
        ).padding(bottom: 12),
        if (!(disableTxt ?? false))
          Text.rich(
            TextSpan(
              text: 'Cargo Track ',
              children: <InlineSpan>[
                TextSpan(
                  text: 'by BigBox.'.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: light ? AppTheme.primary : AppTheme.light,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppTheme.deepDarkGray
                  : AppTheme.lighterGray,
              fontWeight: FontWeight.w400,
            ),
          ).padding(bottom: 40),
      ],
    );
  }
}
