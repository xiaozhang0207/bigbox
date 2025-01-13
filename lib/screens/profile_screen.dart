// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/global.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/auth_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/input.dart';
import 'package:bigbox/utils/cached_image_initer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:styled_widget/styled_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController lastName = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController email = TextEditingController();
  FocusNode lastNameFocus = FocusNode();
  FocusNode firstNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  bool isLoading = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  void logout() async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove('usr');
    prefs.remove('token');
    // prefs.clear();
    Get.back();
    Get.offAllNamed('/login');
  }

  @override
  void initState() {
    super.initState();
    unFocus();
    lastName.text = usr.lastName ?? '';
    firstName.text = usr.firstName ?? '';
    email.text = usr.email ?? '';
    isLoading = false;
    setStates();
  }

  void unFocus() {
    if (lastNameFocus.hasFocus) lastNameFocus.unfocus();
    if (firstNameFocus.hasFocus) firstNameFocus.unfocus();
    if (emailFocus.hasFocus) emailFocus.unfocus();
  }

  void setStates() {
    if (mounted) setState(() {});
  }

  void onPress(
    bool? isProfile, {
    String? img,
  }) async {
    if (!(isProfile ?? false)) {
      if (lastName.text == '' || firstName.text == '' || email.text == '') {
        return;
      }
    } else {
      if ((img ?? '') == '') return;
    }
    Get.back();
    isLoading = true;
    setStates();
    ResponseModel res = (img ?? '') == ''
        ? await AuthRepository().updateInfo(
            lastName: lastName.text,
            firstName: firstName.text,
            email: email.text,
          )
        : await AuthRepository().changeCover(
            image: img ?? '',
          );
    if (res.status == 200 && (img ?? '') == '') {
      usr.lastName = lastName.text;
      usr.firstName = firstName.text;
      usr.email = email.text;
    } else {
      usr.avatar = res.data ?? '';
    }
    if (res.status == 200) {
      final SharedPreferences prefs = await _prefs;
      unawaited(prefs.setString('usr', jsonEncode(usr.toJson())));
    }
    SnackBar snackBar = SnackBar(
      content: Text(
          res.message ?? (res.status == 200 ? 'Амжилттай' : 'Алдаа гарлаа')),
      duration: const Duration(milliseconds: 1000),
      backgroundColor: AppTheme.primary,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    isLoading = false;
    setStates();
  }

  void formModal({
    required bool light,
    required Size size,
    required EdgeInsets padding,
    String? profile,
  }) {
    bool profileEdit = (profile ?? '') != '';
    if (isLoading) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      enableDrag: true,
      backgroundColor: light ? AppTheme.light : AppTheme.deepDarkGray,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return FractionallySizedBox(
            heightFactor: profileEdit ? .4 : 0.8,
            child: GestureDetector(
              onTap: unFocus,
              child: Container(
                color: AppTheme.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 6,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(180),
                            color: AppTheme.lightGray,
                          ),
                        ),
                        Column(
                          children: profileEdit
                              ? [
                                  if (profile != '')
                                    CachedImageIniter(
                                      profile ?? '',
                                      width: 120,
                                      height: 120,
                                      radius: 180,
                                    ).padding(right: 8),
                                ]
                              : [
                                  ...List.generate(3, (index) {
                                    return InputWidget(
                                      controller: [
                                        lastName,
                                        firstName,
                                        email
                                      ][index],
                                      focus: [
                                        lastNameFocus,
                                        firstNameFocus,
                                        emailFocus
                                      ][index],
                                      hasIcon: false,
                                      lbl: ['Овог:', 'Нэр:', 'Имэйл:'][index],
                                      placeholder: [
                                        'Овог:',
                                        'Нэр:',
                                        'Имэйл:'
                                      ][index],
                                      setState: () {
                                        setStates();
                                        setState(() => {});
                                      },
                                      type: TextInputType.text,
                                    ).padding(bottom: 20);
                                  }),
                                ],
                        ),
                      ],
                    ),
                    ButtonWidget(
                      title: 'Хадгалах',
                      onPress: () => onPress(
                        profileEdit,
                        img: profile ?? '',
                      ),
                      hasIcon: false,
                      isLoading: isLoading,
                      disable: !profileEdit &&
                          (lastName.text == '' ||
                              firstName.text == '' ||
                              email.text == ''),
                    ),
                  ],
                ).padding(
                  horizontal: 20,
                  top: 20,
                  bottom: padding.bottom + 12,
                ),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final Size size = MediaQuery.of(context).size;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return GestureDetector(
      onTap: () => unFocus(),
      child: ScafoldBuilder(
        appbar: const CustomAppBar(
          title: 'Profile',
          isCamera: true,
        ),
        child: SizedBox(
          width: size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CachedImageIniter(
                            usr.avatar == ''
                                ? defaultAvatar
                                : '$host${usr.avatar}',
                            width: 60,
                            height: 60,
                            radius: 180,
                          ).padding(right: 8),
                          Column(
                            crossAxisAlignment: ((usr.lastName ?? '') != '' ||
                                    (usr.firstName ?? '') != '')
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            mainAxisAlignment: ((usr.lastName ?? '') != '' ||
                                    (usr.firstName ?? '') != '')
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.center,
                            children: [
                              Text(
                                (usr.lastName ?? '') == '' &&
                                        (usr.firstName ?? '') == ''
                                    ? usr.phone ?? ''
                                    : '${(usr.firstName ?? '')} ${(usr.lastName ?? '')}',
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if ((usr.lastName ?? '') != '' ||
                                  (usr.firstName ?? '') != '')
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone_iphone_sharp,
                                      size: 16,
                                      color: light
                                          ? AppTheme.deepDarkGray
                                          : AppTheme.black,
                                    ),
                                    Text(
                                      '+976 ${usr.phone}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: light
                                            ? AppTheme.darkGray
                                            : AppTheme.black,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ).height(60),
                        ],
                      ),
                    ],
                  ).padding(bottom: 30),
                  ...List.generate(3, (index) {
                    return GestureDetector(
                      onTap: () async {
                        if (index == 2) {
                          Get.toNamed('/password');
                        } else if (index == 1) {
                          if (isLoading) return;
                          formModal(
                            light: light,
                            padding: padding,
                            size: size,
                          );
                        } else {
                          dynamic image = '';
                          if (isLoading) return;
                          bool galleryEnabled =
                              await Permission.photos.request().isGranted;
                          if (!galleryEnabled) {
                            openAppSettings();
                          } else {
                            final imagePicker = ImagePicker();
                            image = await imagePicker.pickImage(
                                source: ImageSource.gallery);
                            final bytes = File(image.path).readAsBytesSync();
                            image =
                                'data:image/png;base64, ${base64Encode(bytes)}';
                            formModal(
                              light: light,
                              padding: padding,
                              size: size,
                              profile: image,
                            );
                          }
                        }
                      },
                      child: Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: light ? AppTheme.light : AppTheme.darkestGray,
                          border: Border(
                            bottom: BorderSide(
                              width: 1,
                              color:
                                  light ? AppTheme.lighterGray : AppTheme.black,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkGray,
                                    borderRadius: BorderRadius.circular(180),
                                  ),
                                  child: Icon(
                                    [
                                      Icons.image,
                                      Icons.edit_square,
                                      Icons.password_rounded
                                    ][index],
                                    color: AppTheme.lighterGray,
                                    size: 16,
                                  ),
                                ),
                                Text(
                                  [
                                    'Зураг солих',
                                    'Хэрэглэгчийн мэдээлэл',
                                    'Нууц үг солих',
                                  ][index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: light
                                        ? AppTheme.black
                                        : AppTheme.lighterGray,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: light ? AppTheme.darkGray : AppTheme.black,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Миний бүртгэл',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.black.withOpacity(.4),
                    ),
                  ).padding(bottom: 22),
                  GestureDetector(
                    onTap: () => Get.toNamed('/delete-account'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: AppTheme.transparent,
                      child: const Text(
                        'Бүртгэл устгах',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: logout,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: AppTheme.transparent,
                      child: const Text(
                        'Гарах',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ).padding(top: 20),
            ],
          ).padding(
            horizontal: 20,
            bottom: padding.bottom + 12,
          ),
        ),
      ),
    );
  }
}
