import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/shared/widget/otp.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class InputWidget extends StatelessWidget {
  const InputWidget({
    super.key,
    required this.lbl,
    this.controller,
    this.focus,
    this.hasIcon = false,
    this.setState,
    this.type = TextInputType.name,
    this.obscureText = false,
    this.isPassword = false,
    this.passwordShow,
    this.onFinishOtp,
    this.onTap,
    this.input = 'field',
    this.maxLength,
    this.maxLines,
    this.icon,
    this.otpFocus,
    this.lblAlign,
    this.hasBorder,
    this.placeholder,
    this.suffixIcon,
    this.height,
    this.color,
    this.readonly,
    this.onEditingComplete,
  });
  final String lbl;
  final String? placeholder;
  final TextEditingController? controller;
  final FocusNode? focus;
  final bool? hasIcon;
  final Function? setState;
  final Function? onTap;
  final TextInputType? type;
  final bool? obscureText;
  final bool? isPassword;
  final bool? hasBorder;
  final Function? passwordShow;
  final Function? onFinishOtp;
  final String input;
  final int? maxLength;
  final int? maxLines;
  final double? height;
  final Widget? icon;
  final List<FocusNode>? otpFocus;
  final TextAlign? lblAlign;
  final Widget? suffixIcon;
  final Color? color;
  final bool? readonly;
  final bool? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (lbl != '')
          AnimatedSize(
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              height: (input != 'otp' && (controller?.text ?? '') == '') ||
                      (input == 'otp' && lbl == '')
                  ? 0
                  : 16,
              child: Text(
                lbl,
                textAlign: lblAlign ?? TextAlign.start,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.lighterGray
                      : AppTheme.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ).padding(
              bottom: (input != 'otp' && (controller?.text ?? '') == '') ||
                      (input == 'otp' && lbl == '')
                  ? 0
                  : lbl == ''
                      ? 0
                      : 12),
        SizedBox(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              if (input == 'otp')
                OtpTextField(
                  numberOfFields: 4,
                  borderColor: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkGray
                      : AppTheme.lighterGray,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkGray
                      : AppTheme.lighterGray,
                  focusedBorderColor: AppTheme.primary,
                  showFieldAsBox: true,
                  borderWidth: 1,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 50,
                  autoFocus: false,
                  filled: true,
                  contentPadding: (hasBorder ?? false)
                      ? const EdgeInsets.all(8)
                      : EdgeInsets.zero,
                  otpFocus: otpFocus ?? [],
                  obscureText: obscureText ?? false,
                  onCodeChanged: (String code) {
                    if (controller != null) {
                      if (code != '') {
                        controller!.text = '${controller!.text}$code';
                      } else {
                        controller!.text = controller!.text
                            .substring(0, controller!.text.length - 1);
                      }
                      if (controller!.text == '') {
                        focus?.unfocus();
                      }
                    }
                    if (setState != null) {
                      setState!();
                    }
                  },
                  onSubmit: (String verificationCode) {
                    if (controller != null) {
                      controller!.text = verificationCode;
                      if (setState != null) {
                        setState!();
                      }
                    }
                    if (onFinishOtp != null) {
                      onFinishOtp!();
                      if (setState != null) {
                        setState!();
                      }
                    }
                  }, // end onSubmit
                ),
              if (input != 'otp')
                Container(
                  height: height,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: (hasBorder ?? false)
                        ? AppTheme.transparent
                        : Theme.of(context).brightness == Brightness.dark
                            ? color ?? AppTheme.darkGray
                            : color ?? AppTheme.lighterGray,
                  ),
                  child: Row(
                    children: [
                      icon ?? const SizedBox(),
                      TextField(
                        controller: controller,
                        focusNode: focus,
                        keyboardType: type,
                        maxLength: maxLength,
                        maxLines: maxLines ?? 1,
                        readOnly: readonly ?? false,
                        onTapOutside: (p) {
                          if ((onEditingComplete ?? false) && onTap != null) {
                            onTap!(controller?.text ?? '');
                          }
                        },
                        onSubmitted: (txt) {
                          if (onTap != null) {
                            onTap!(txt);
                          }
                        },
                        onChanged: (str) {
                          if (setState != null) {
                            setState!();
                          }
                        },
                        obscureText: obscureText ?? false,
                        decoration: InputDecoration(
                          counterText: "",
                          contentPadding: (hasBorder ?? false)
                              ? const EdgeInsets.all(8)
                              : EdgeInsets.zero,
                          suffixIcon: !(isPassword ?? false)
                              ? suffixIcon
                              : IconButton(
                                  highlightColor:
                                      AppTheme.primary.withOpacity(.05),
                                  icon: Icon(
                                    (obscureText ?? false)
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppTheme.lighterGray
                                        : Theme.of(context).primaryColorDark,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (passwordShow != null) {
                                      passwordShow!();
                                    }
                                  },
                                ),
                          hintStyle: TextStyle(
                            fontSize: 12.0,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppTheme.lighterGray
                                    : AppTheme.darkGray,
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: (hasBorder ?? false)
                                  ? Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppTheme.darkGray
                                      : AppTheme.lighterGray
                                  : AppTheme.transparent,
                              width: (hasBorder ?? false) ? 1 : 0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: (hasBorder ?? false)
                                  ? AppTheme.primary
                                  : AppTheme.transparent,
                              width: (hasBorder ?? false) ? 1 : 0,
                            ),
                          ),
                          hintText: placeholder ?? lbl,
                        ),
                      ).expanded(),
                    ],
                  ),
                ),
              if (input != 'otp' &&
                  !(isPassword ?? false) &&
                  (hasIcon ?? false) &&
                  controller?.text != '')
                Positioned(
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.green,
                      borderRadius: BorderRadius.circular(180),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppTheme.light,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
