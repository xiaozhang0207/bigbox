import 'dart:io';

import 'package:bigbox/configs/global.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/page_model.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/user_repository.dart';
import 'package:bigbox/screens/home/add_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:styled_widget/styled_widget.dart';

class DrawerWidget extends StatefulWidget {
  final Function? callback;
  const DrawerWidget({
    super.key,
    this.callback,
  });

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<PageModel> datas = [];
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
    fetchData();
  }

  void fetchData() async {
    datas = [];
    ResponseModel res = await UserRepository().getPages();
    if (res.status == 200) {
      if ((res.data ?? []).length > 0) {
        for (int i = 0; i < (res.data ?? []).length; i++) {
          PageModel currentPage = PageModel.fromJson(res.data[i]);
          if (currentPage.isActive ?? false) datas.add(currentPage);
        }
      }
    }
    setStates();
  }

  void setStates() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    EdgeInsets padding = MediaQuery.of(context).padding;
    bool light = Theme.of(context).brightness == Brightness.light;
    return Container(
      color: light ? AppTheme.light : AppTheme.black,
      padding: EdgeInsets.only(top: padding.top + 12),
      child: Column(
        children: [
          Container(
            width: size.width,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: light ? AppTheme.lighterGray : AppTheme.darkestGray,
                ),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                  ),
                ),
                const Text(
                  'Тохиргоо',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ).expanded(),
              ],
            ),
          ),
          SizedBox(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Мэдэгдэл
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      Get.toNamed('/notifications');
                    },
                    child: Container(
                      width: size.width,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: light ? AppTheme.light : AppTheme.darkestGray,
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
                                child: const Icon(
                                  Icons.notifications_active,
                                  color: AppTheme.lighterGray,
                                  size: 16,
                                ),
                              ),
                              Text(
                                'Мэдэгдэл',
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
                  ),
                  // Захиалга бүртгэх || Хуудас нэмэх
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      if (usr.permissionId == 1) {
                        Get.toNamed('/pages');
                      } else {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          enableDrag: false,
                          builder: (context) {
                            return AddItemScreen(
                              padding: MediaQuery.of(context).padding,
                              size: MediaQuery.of(context).size,
                              callback: widget.callback,
                            );
                          },
                        );
                      }
                    },
                    child: Container(
                      width: size.width,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: light ? AppTheme.light : AppTheme.darkestGray,
                        border: Border(
                          top: BorderSide(
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
                                child: const Icon(
                                  Icons.add,
                                  color: AppTheme.lighterGray,
                                  size: 16,
                                ),
                              ),
                              Text(
                                usr.permissionId == 1
                                    ? 'Хуудас'
                                    : 'Захиалга бүртгэх',
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
                  ),
                  // Профайл
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      Get.toNamed('/profile');
                    },
                    child: Container(
                      width: size.width,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: light ? AppTheme.light : AppTheme.darkestGray,
                        border: Border(
                          top: BorderSide(
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
                                child: const Icon(
                                  Icons.edit_document,
                                  color: AppTheme.lighterGray,
                                  size: 16,
                                ),
                              ),
                              Text(
                                'Профайл',
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
                  ),
                  // Эрээний хаяг
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      Get.toNamed('/base-address');
                    },
                    child: Container(
                      width: size.width,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: light ? AppTheme.light : AppTheme.darkestGray,
                        border: Border(
                          top: BorderSide(
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
                                child: const Icon(
                                  Icons.location_history_sharp,
                                  color: AppTheme.lighterGray,
                                  size: 16,
                                ),
                              ),
                              Text(
                                'Эрээний хаяг',
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
                  ),
                  // Хэрэглэгчийн жагсаалт
                  if (usr.permissionId == 1)
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.toNamed('/users');
                      },
                      child: Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: light ? AppTheme.light : AppTheme.darkestGray,
                          border: Border(
                            top: BorderSide(
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
                                  child: const Icon(
                                    Icons.supervised_user_circle_rounded,
                                    color: AppTheme.lighterGray,
                                    size: 16,
                                  ),
                                ),
                                Text(
                                  'Хэрэглэгчийн жагсаалт',
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
                    ),
                  // Нууц үг солих
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      Get.toNamed('/password');
                    },
                    child: Container(
                      width: size.width,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: light ? AppTheme.light : AppTheme.darkestGray,
                        border: Border(
                          top: BorderSide(
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
                                child: const Icon(
                                  Icons.lock_person_outlined,
                                  color: AppTheme.lighterGray,
                                  size: 16,
                                ),
                              ),
                              Text(
                                'Нууц үг солих',
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
                  ),
                  if (datas.isNotEmpty)
                    ...List.generate(datas.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          Get.back();
                          Get.toNamed(
                            '/get-page',
                            arguments: [datas[index]],
                          );
                        },
                        child: Container(
                          width: size.width,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color:
                                light ? AppTheme.light : AppTheme.darkestGray,
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: light
                                    ? AppTheme.lighterGray
                                    : AppTheme.black,
                              ),
                              top: BorderSide(
                                width: index != 0 ? 0 : 10,
                                color: light
                                    ? AppTheme.lighterGray
                                    : AppTheme.black,
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
                                    child: const Icon(
                                      Icons.content_paste_go_sharp,
                                      color: AppTheme.lighterGray,
                                      size: 16,
                                    ),
                                  ),
                                  Text(
                                    datas[index].type ?? '',
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
                                color:
                                    light ? AppTheme.darkGray : AppTheme.black,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  if (Platform.isIOS &&
                      (usr.permissionId ?? 0) < 3 &&
                      (usr.permissionId ?? 0) > 0)
                    Column(
                      children: [
                        Container(
                          width: size.width,
                          height: 12,
                          color: light ? AppTheme.lighterGray : AppTheme.black,
                        ),
                        // Принтер
                        GestureDetector(
                          onTap: () {
                            Get.back();
                            Get.toNamed('/demo-printer');
                          },
                          child: Container(
                            width: size.width,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            decoration: BoxDecoration(
                              color:
                                  light ? AppTheme.light : AppTheme.darkestGray,
                              border: Border(
                                top: BorderSide(
                                  width: 1,
                                  color: light
                                      ? AppTheme.lighterGray
                                      : AppTheme.black,
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
                                        borderRadius:
                                            BorderRadius.circular(180),
                                      ),
                                      child: const Icon(
                                        Icons.print,
                                        color: AppTheme.lighterGray,
                                        size: 16,
                                      ),
                                    ),
                                    Text(
                                      'Принтер',
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
                                  color: light
                                      ? AppTheme.darkGray
                                      : AppTheme.black,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  // Бүртгэл устгах
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      Get.toNamed('/delete-account');
                    },
                    child: Container(
                      width: size.width,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: light ? AppTheme.light : AppTheme.darkestGray,
                        border: Border(
                          bottom: BorderSide(
                            width: 4,
                            color:
                                light ? AppTheme.lighterGray : AppTheme.black,
                          ),
                          top: BorderSide(
                            width: 10,
                            color:
                                light ? AppTheme.lighterGray : AppTheme.black,
                          ),
                        ),
                      ),
                      child: Text(
                        'Бүртгэл устгах',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              light ? AppTheme.darkGray : AppTheme.lighterGray,
                        ),
                      ).center(),
                    ),
                  ),
                  // Гарах
                  GestureDetector(
                    onTap: logout,
                    child: Container(
                      width: size.width,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            light ? AppTheme.lighterGray : AppTheme.darkestGray,
                      ),
                      child: Text(
                        'Гарах',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              light ? AppTheme.primary : AppTheme.lighterGray,
                        ),
                      ).center(),
                    ),
                  ),
                ],
              ),
            ),
          ).expanded(),
        ],
      ),
    );
  }
}
