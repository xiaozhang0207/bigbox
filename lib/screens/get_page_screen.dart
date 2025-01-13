import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/domain/models/page_model.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:styled_widget/styled_widget.dart';

class GetPageScreen extends StatelessWidget {
  final PageModel page;
  const GetPageScreen({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return ScafoldBuilder(
      appbar: CustomAppBar(
        title: page.type ?? '',
        isCamera: true,
      ),
      child: SizedBox(
        child: SingleChildScrollView(
          child: Html(
            data: page.data ?? '',
            style: {
              'p': Style(
                fontSize: FontSize(12),
              ),
              'span': Style(
                fontSize: FontSize(12),
              ),
              'img': Style(
                width: Width(MediaQuery.of(context).size.width - 80),
              ),
            },
          ).padding(bottom: 16.0, horizontal: 14),
        ),
      ),
    );
  }
}
