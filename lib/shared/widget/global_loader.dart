import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GlobalLoader extends StatelessWidget {
  const GlobalLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return AnimatedContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      duration: const Duration(milliseconds: 0),
      width: size.width,
      height: size.height,
      color: Colors.black.withOpacity(isLight ? .5 : .8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(
            color: AppTheme.gray.withOpacity(.5),
          ),
        ],
      ),
    );
  }
}
