import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title = '',
    this.fnc,
    this.leading,
    this.header,
    this.actions,
    this.isCamera,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);
  final String title;
  final Function? fnc;
  final Widget? leading;
  final Widget? header;
  final bool? isCamera;
  final List<Widget>? actions;

  @override
  final Size preferredSize; // default is 56.0
  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: (widget.isCamera ?? false)
          ? AppTheme.transparent
          : Theme.of(context).brightness == Brightness.dark
              ? AppTheme.deepDarkGray
              : AppTheme.bg,
      title: widget.header ??
          Text(widget.title,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.lighterGray
                    : AppTheme.dark,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              )),
      elevation: 0,
      leading: !(widget.isCamera ?? false)
          ? const SizedBox()
          : widget.leading ??
              SizedBox(
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.lighterGray
                        : AppTheme.deepDarkGray,
                    size: 20,
                  ),
                  onPressed: () => widget.fnc != null
                      ? widget.fnc!()
                      : Navigator.pop(context),
                ),
              ),
      actions: widget.actions,
    );
  }
}
