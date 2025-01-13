// ignore_for_file: use_build_context_synchronously

import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/global.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/auth_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:styled_widget/styled_widget.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLoading = false;
  TextEditingController reason = TextEditingController();
  FocusNode focus = FocusNode();
  int page = 1;
  int selectedReason = 0;
  List<String> reasons = [
    'Цаашид ашиглах шаардлагагүй болсон',
    'Програм алдаатай учираас ашиглахад хүндрэлтэй',
    'Хариуцлагагүй',
    'Залилан хийж байх магадлалтай',
    'Төхөөрөмжөө сольсон',
    'Бусад',
  ];

  void setStates() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    isLoading = false;
    page = 1;
    unFocus();
    selectedReason = 0;
    setStates();
  }

  void unFocus() {
    if (focus.hasFocus) {
      focus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    // final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => unFocus(),
      child: ScafoldBuilder(
        appbar: const CustomAppBar(
          title: 'Бүртгэл устгах',
          isCamera: true,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  children: page == 2
                      ? [
                          ...List.generate(reasons.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                if (selectedReason == index) return;
                                selectedReason = index;
                                setStates();
                              },
                              child: Container(
                                color: AppTheme.transparent,
                                margin: const EdgeInsets.only(bottom: 25),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 25,
                                      height: 25,
                                      margin: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        color: selectedReason == index
                                            ? light
                                                ? AppTheme.primary
                                                : AppTheme.red
                                            : AppTheme.transparent,
                                        borderRadius:
                                            BorderRadius.circular(180),
                                        border: Border.all(
                                          width: 1,
                                          color: selectedReason == index
                                              ? light
                                                  ? AppTheme.primary
                                                  : AppTheme.red
                                              : light
                                                  ? AppTheme.black
                                                      .withOpacity(.1)
                                                  : AppTheme.lighterGray,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      reasons[index],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ).expanded(),
                                  ],
                                ),
                              ),
                            );
                          }),
                          if (selectedReason == 5)
                            InputWidget(
                              controller: reason,
                              focus: focus,
                              hasIcon: false,
                              maxLines: 12,
                              lbl: 'Тайлбар оруулах уу?',
                              placeholder: 'Тайлбар оруулах уу?',
                              setState: setStates,
                              type: TextInputType.text,
                            ),
                        ]
                      : [
                          const Text(
                            'Та өөрийн бүртгэлийг устгах уу?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ).padding(top: 12, bottom: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 20,
                            ),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                width: 1,
                                color: AppTheme.red,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 32,
                                  color: AppTheme.red,
                                ).padding(right: 20),
                                RichText(
                                  text: TextSpan(
                                      text: 'Таны бүртгэлтэй ',
                                      children: [
                                        TextSpan(
                                          text: '+976 ${usr.phone} ',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const TextSpan(
                                            text:
                                                'хаяг устах үед танд бүртгэлтэй бүх мэдээлэл '),
                                        const TextSpan(
                                          text: 'ажлын 3 ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const TextSpan(text: 'хоногт '),
                                        const TextSpan(
                                          text: 'УСТГАГДАХ ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const TextSpan(text: 'болно.'),
                                      ],
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: light
                                            ? AppTheme.black
                                            : AppTheme.lighterGray,
                                      )),
                                ).expanded(),
                              ],
                            ),
                          ),
                          const Text(
                            'Таны бүртгэл устгагдах үед дараах материалууд давхар устах болно:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ).padding(bottom: 20),
                          ...List.generate(4, (index) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 23,
                                  height: 23,
                                  margin: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(180),
                                    color: AppTheme.black,
                                  ),
                                  child: Text(
                                    (index + 1).toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.lighterGray,
                                    ),
                                  ).center(),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: [
                                      'Утасны дугаар. ',
                                      'Захиалгын мэдээлэл. ',
                                      'Хувийн мэдээлэл. ',
                                      'Серверт хуулсан зураг. ',
                                    ][index],
                                    children: [
                                      TextSpan(
                                        text: [
                                          'Таны бүртгэлтэй дугаар системд давхарддагүй тул бүртгэлээс арилгах үед та хэзээ ч дахин бүртгүүлэх боломжтой.',
                                          'BigBox - с авсан бүх бүртгэлийн мэдээлэл нь архивийн сангаас хамт устгагдна.',
                                          'Өөрийн Овог, Нэр, Имэйл хаяг болон төхөөрөмжний DeviceId гэх мэт тантай холбоотой бүх мэдээлэл устах болно.',
                                          'Өөрийн профайл зургыг шинэчлэх үед хуулсан файлууд мөн адил устгагдна.',
                                        ][index],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: light
                                          ? AppTheme.black
                                          : AppTheme.lighterGray,
                                    ),
                                  ),
                                ).expanded(),
                              ],
                            ).padding(bottom: 20);
                          }),
                        ],
                ),
              ),
            ).expanded(),
            ButtonWidget(
              title: 'Үргэлжлүүлэх',
              onPress: () async {
                if (isLoading) return;
                if (page == 1) {
                  page = 2;
                  setStates();
                } else {
                  isLoading = true;
                  setStates();
                  ResponseModel res = await AuthRepository().accountOff();
                  isLoading = false;
                  setStates();
                  final SharedPreferences prefs = await _prefs;
                  prefs.clear();
                  Get.back();
                  Get.offAllNamed('/login');
                  SnackBar snackBar = SnackBar(
                    content: Text(res.message ?? 'Хүсэлт илгээгдлээ.'),
                    duration: const Duration(milliseconds: 1000),
                    backgroundColor: AppTheme.primary,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              hasIcon: false,
              isLoading: isLoading,
              color: AppTheme.red,
            ).padding(top: 12),
          ],
        ).padding(
          horizontal: 20,
          bottom: padding.bottom + 12,
          top: 12,
        ),
      ),
    );
  }
}
