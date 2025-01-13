import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:styled_widget/styled_widget.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required this.title,
    required this.onPress,
    this.radius = 8,
    this.hasIcon = true,
    this.isLoading = false,
    this.disable = false,
    this.color,
    this.hasColor,
    this.shadowColor,
    this.txtColor,
    this.border,
    this.surfaceTintColor,
    this.foreground,
    this.fontSize,
    this.vertical,
    this.icon,
    this.onLong,
  });
  final String title;
  final Function onPress;
  final Function? onLong;
  final double radius;
  final bool hasIcon;
  final bool isLoading;
  final bool disable;
  final Color? color;
  final Color? foreground;
  final Color? shadowColor;
  final Color? txtColor;
  final Color? border;
  final Color? surfaceTintColor;
  final bool? hasColor;
  final double? fontSize;
  final double? vertical;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onLongPress: () {
        if (isLoading) {
          return;
        }
        if (onLong != null) {
          onLong!();
        }
      },
      onPressed: () {
        if (isLoading) {
          return;
        }
        onPress();
      },
      style: ElevatedButton.styleFrom(
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor ?? AppTheme.transparent,
        padding: vertical == null
            ? const EdgeInsets.symmetric(horizontal: 20)
            : EdgeInsets.zero,
        backgroundColor: !(hasColor ?? true)
            ? AppTheme.transparent
            : color ??
                (disable
                    ? Theme.of(context).brightness == Brightness.light
                        ? AppTheme.lightGray
                        : AppTheme.darkGray
                    : Theme.of(context).brightness == Brightness.light
                        ? AppTheme.primary.withOpacity(isLoading ? .8 : 1)
                        : AppTheme.black.withOpacity(.6)),
        foregroundColor: disable
            ? Theme.of(context).brightness == Brightness.light
                ? AppTheme.lighterGray
                : AppTheme.darkGray
            : foreground ?? AppTheme.lighterGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius), // <-- Radius
          side: BorderSide(
            width: border == null ? 0 : 1,
            color: border ?? AppTheme.transparent,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            hasIcon ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
        crossAxisAlignment: vertical == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: vertical == null
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (!isLoading) icon ?? const SizedBox(),
              if (isLoading)
                LoadingAnimationWidget.threeArchedCircle(
                  color: txtColor ?? AppTheme.light,
                  size: 16,
                ).padding(right: 10),
              Text(
                isLoading ? 'Уншиж байна' : title,
                style: TextStyle(
                  fontSize: fontSize ?? 14,
                  color: disable
                      ? Theme.of(context).brightness == Brightness.light
                          ? txtColor ?? AppTheme.gray
                          : txtColor ?? AppTheme.lightGray
                      : Theme.of(context).brightness == Brightness.light
                          ? txtColor ?? AppTheme.light
                          : color != null
                              ? txtColor ?? AppTheme.lighterGray
                              : Theme.of(context).brightness == Brightness.dark
                                  ? AppTheme.lighterGray
                                  : AppTheme.lightGray,
                ),
              ),
            ],
          ),
          if (hasIcon)
            Icon(
              Icons.arrow_forward_ios_sharp,
              color: disable
                  ? Theme.of(context).brightness == Brightness.light
                      ? AppTheme.gray
                      : AppTheme.lightGray
                  : Theme.of(context).brightness == Brightness.light
                      ? AppTheme.light
                      : AppTheme.lightGray,
              size: 20,
            ),
        ],
      ).padding(vertical: vertical ?? 12),
    );
  }
}
