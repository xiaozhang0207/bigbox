// ignore_for_file: use_build_context_synchronously

import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/page_model.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/admin_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:styled_widget/styled_widget.dart';

class AddPageScreen extends StatefulWidget {
  final PageModel? page;
  final Function? localSetter;
  const AddPageScreen({
    super.key,
    this.page,
    this.localSetter,
  });

  @override
  State<AddPageScreen> createState() => _AddPageScreenState();
}

class _AddPageScreenState extends State<AddPageScreen> {
  TextEditingController title = TextEditingController();
  HtmlEditorController controller = HtmlEditorController();
  FocusNode titleFocus = FocusNode();
  bool isLoading = false;
  bool isEnabled = true;
  int step = 1;
  String body = '';

  void setStates() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    title.clear();
    isLoading = false;
    isEnabled = true;
    step = 1;
    body = '';
    unFocus();
    setStates();
    fetchData();
  }

  void fetchData() {
    if (widget.page != null) {
      body = widget.page!.data ?? '';
      isEnabled = widget.page!.isActive ?? false;
      title.text = widget.page!.type ?? '';
    }
  }

  void unFocus() {
    if (titleFocus.hasFocus) {
      titleFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.of(context).padding;
    final Size size = MediaQuery.of(context).size;
    final bool light = Theme.of(context).brightness == Brightness.light;
    return ScafoldBuilder(
      appbar: CustomAppBar(
        title: widget.page == null ? 'Хуудас үүсгэх' : 'Хуудас засах',
        leading: GestureDetector(
          onTap: () {
            if (isLoading) return;
            if (step == 1) {
              Get.back();
            } else {
              step = 1;
              setStates();
            }
          },
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: light ? AppTheme.black : AppTheme.lighterGray,
            size: 22,
          ),
        ),
      ),
      child: Container(
        color: AppTheme.transparent,
        child: Column(
          children: [
            Expanded(
              child: step == 1
                  ? Scrollable(
                      viewportBuilder:
                          (BuildContext context, ViewportOffset position) =>
                              HtmlEditor(
                        controller: controller,
                        otherOptions: const OtherOptions(
                          decoration: BoxDecoration(
                            border: Border.fromBorderSide(BorderSide(
                                color: Color.fromARGB(0, 255, 255, 255),
                                width: 0)),
                          ),
                          // height: 1000,
                        ),
                        htmlEditorOptions: HtmlEditorOptions(
                          hint: 'Your text here...',
                          inputType: HtmlInputType.text,
                          shouldEnsureVisible: true,
                          autoAdjustHeight: true,
                          darkMode: MediaQuery.of(context).platformBrightness ==
                              Brightness.dark,
                          initialText: body,
                        ),
                        htmlToolbarOptions: const HtmlToolbarOptions(
                          initiallyExpanded: true,
                          renderSeparatorWidget: true,
                          defaultToolbarButtons: [
                            StyleButtons(),
                            FontSettingButtons(fontSizeUnit: false),
                            FontButtons(clearAll: false),
                            ColorButtons(),
                            ListButtons(listStyles: false),
                            ParagraphButtons(
                              textDirection: false,
                              lineHeight: false,
                            ),
                            InsertButtons(
                              video: false,
                              audio: false,
                              table: true,
                              hr: true,
                              otherFile: false,
                              picture: false,
                            )
                          ],
                          toolbarPosition:
                              ToolbarPosition.aboveEditor, //by default
                          toolbarType: ToolbarType.nativeGrid,
                        ),
                        callbacks: Callbacks(
                          onBeforeCommand: (String? currentHtml) {},
                          onInit: () {
                            controller.setFullScreen();
                          },
                          onNavigationRequestMobile: (String url) {
                            return NavigationActionPolicy.ALLOW;
                          },
                        ),
                        plugins: const [],
                      ),
                    )
                  : Column(
                      children: [
                        InputWidget(
                          controller: title,
                          focus: titleFocus,
                          hasIcon: false,
                          lbl: 'Хуудасны гарчиг',
                          placeholder: 'Хуудасны гарчиг',
                          setState: setStates,
                          type: TextInputType.text,
                        ).padding(
                          top: 20,
                          bottom: 14,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ...List.generate(2, (index) {
                              return GestureDetector(
                                onTap: () {
                                  if (index == 0 && !isEnabled) {
                                    isEnabled = true;
                                  } else {
                                    isEnabled = false;
                                  }
                                  setStates();
                                },
                                child: Container(
                                  width: (size.width * .5) - 30,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.transparent,
                                    border: Border.all(
                                      width: 1,
                                      color: AppTheme.black.withOpacity(.1),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(180),
                                          color: (index == 0 && isEnabled)
                                              ? AppTheme.primary
                                              : index == 1 && !isEnabled
                                                  ? AppTheme.primary
                                                  : AppTheme.transparent,
                                          border: Border.all(
                                            width: 1,
                                            color: (index == 0 && !isEnabled) ||
                                                    (index == 1 && !isEnabled)
                                                ? AppTheme.primary
                                                : AppTheme.black
                                                    .withOpacity(.1),
                                          ),
                                        ),
                                      ),
                                      Text(['Идэвхтэй', 'Идэвхгүй'][index]),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ).padding(horizontal: step == 1 ? 0 : 20),
            ),
            ButtonWidget(
              title: 'Үргэлжлүүлэх',
              onPress: () async {
                if (step == 1) {
                  dynamic tmp = await controller.getText();
                  if (tmp == '') return;
                  body = tmp;
                  step = 2;
                  setStates();
                } else {
                  if (body == '' || isLoading || title.text == '') return;
                  isLoading = true;
                  setStates();
                  ResponseModel res = widget.page == null
                      ? await AdminRepository().addPage(
                          data: body,
                          type: title.text,
                          isActive: isEnabled,
                        )
                      : await AdminRepository().updatePage(
                          id: widget.page?.id ?? 0,
                          data: body,
                          type: title.text,
                          isActive: isEnabled ? 1 : 0,
                        );
                  if (res.status == 200) {
                    if (widget.localSetter != null) {
                      if (widget.page == null) {
                        widget.localSetter!(null);
                      } else {
                        widget.localSetter!(
                          PageModel(
                            id: widget.page?.id ?? 0,
                            type: title.text,
                            data: body,
                            isActive: isEnabled,
                          ),
                        );
                      }
                    }
                    title.clear();
                    Get.back();
                  }
                  SnackBar snackBar = SnackBar(
                    content: Text(res.message ??
                        (res.status == 200 ? 'Амжилттай' : 'Алдаа гарлаа')),
                    duration: const Duration(milliseconds: 1000),
                    backgroundColor: AppTheme.primary,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  isLoading = false;
                  setStates();
                }
              },
              hasIcon: false,
              isLoading: isLoading,
            ).padding(
              horizontal: 20,
              bottom: padding.bottom + 12,
              top: 14,
            ),
          ],
        ),
      ),
    );
  }
}
