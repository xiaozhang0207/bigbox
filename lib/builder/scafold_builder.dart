import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ScafoldBuilder extends StatelessWidget {
  const ScafoldBuilder({
    super.key,
    required this.child,
    this.appbar,
    this.resizeToAvoidBottomInset,
    this.color,
    this.endDrawer,
    this.scaffoldKey,
  });
  final Widget child;
  final PreferredSizeWidget? appbar;
  final bool? resizeToAvoidBottomInset;
  final Color? color;
  final Widget? endDrawer;
  final Key? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: color ??
          (Theme.of(context).brightness == Brightness.dark
              ? AppTheme.deepDarkGray
              : AppTheme.bg),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? false,
      appBar: appbar,
      endDrawer: endDrawer,
      body: child,
    );
  }
}
