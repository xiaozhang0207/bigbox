// ignore_for_file: use_build_context_synchronously

import 'package:bigbox/configs/global.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/order_model.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/admin_repository.dart';
import 'package:bigbox/domain/repositories/user_repository.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/input.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:styled_widget/styled_widget.dart';

class AddItemScreen extends StatefulWidget {
  final EdgeInsets padding;
  final Size size;
  final String? barcode;
  final Function? callback;
  final OrderModel? data;
  const AddItemScreen({
    super.key,
    required this.padding,
    required this.size,
    this.barcode,
    this.callback,
    this.data,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  TextEditingController code = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController price = TextEditingController();
  FocusNode cfocus = FocusNode();
  FocusNode nfocus = FocusNode();
  FocusNode pfocus = FocusNode();
  FocusNode pricefocus = FocusNode();
  bool isLoading = false;
  bool readonly = false;
  int type = 0;
  List<dynamic> list = [];
  OrderModel? data;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      code.text = widget.barcode ?? '';
      if ((widget.barcode ?? '') != '') {
        readonly = true;
      }
      if (usr.permissionId == 3) {
        phone.text = usr.phone!;
      }
    }
    data = widget.data;
    type = data?.type ?? 0;
    list = [];
    isLoading = false;
    setStates();
    unFocus();
    fetchData();
  }

  void setStates() {
    if (mounted) setState(() {});
  }

  void fetchData() {
    if (usr.permissionId == 1 && data != null) {
      phone.text = data?.phone ?? '';
      name.text = data?.title ?? '';
      if (type == -1) {
        list = [];
      } else if (type == 0) {
        list = [
          {"index": 1, "lbl": 'Эрээнд ирсэн'},
          {"index": 2, "lbl": 'Улаанбаатарт ирсэн'},
          {"index": 3, "lbl": 'Хүргэлтэнд бүртгэгдсэн'},
          {"index": 4, "lbl": 'Хүргэгдсэн'}
        ];
      } else if (type == 1) {
        list = [
          {"index": 2, "lbl": 'Улаанбаатарт ирсэн'},
          {"index": 3, "lbl": 'Хүргэлтэнд бүртгэгдсэн'},
          {"index": 4, "lbl": 'Хүргэгдсэн'}
        ];
      } else if (type == 2) {
        list = [
          {"index": 3, "lbl": 'Хүргэлтэнд бүртгэгдсэн'},
          {"index": 4, "lbl": 'Хүргэгдсэн'}
        ];
      } else if (type == 3) {
        list = [
          {"index": 4, "lbl": 'Хүргэгдсэн'}
        ];
      }
      setStates();
    }
  }

  void unFocus() {
    if (cfocus.hasFocus) {
      cfocus.unfocus();
    }
    if (nfocus.hasFocus) {
      nfocus.unfocus();
    }
    if (pfocus.hasFocus) {
      pfocus.unfocus();
    }
    if (pricefocus.hasFocus) {
      pricefocus.unfocus();
    }
  }

  void searchByBarCode(String txt) async {
    if (isLoading || usr.permissionId != 1 || txt == '') return;
    ResponseModel res = await AdminRepository().searchByBarcode(token: txt);
    isLoading = true;
    setStates();
    data =
        (res.data ?? []).length > 0 ? OrderModel.fromJson(res.data[0]) : null;
    if (data != null) {
      phone.text = data?.phone ?? '';
      name.text = data?.title ?? '';
      type = data?.type ?? 0;
      fetchData();
    } else {
      phone.clear();
      name.clear();
      type = 0;
    }
    isLoading = false;
    setStates();
  }

  @override
  void dispose() {
    super.dispose();
    unFocus();
  }

  void complete() async {
    unFocus();
    if (isLoading || code.text == '' || phone.text == '') {
      return;
    }
    ResponseModel? res;
    isLoading = true;
    setStates();
    if (usr.permissionId == 3) {
      res = await UserRepository().createOrder(
        barcode: code.text,
        phone: phone.text,
        title: name.text,
      );
    } else if (usr.permissionId == 1) {
      if (data == null) {
        res = await AdminRepository().addNewOrder(
          barcode: code.text,
          phone: phone.text,
          title: name.text,
          price: ((price.text == '' ? 0 : int.parse(price.text)) * 1.0).toInt(),
        );
      } else {
        if (data != null) {
          res = await AdminRepository().updateOrder(
            id: data!.id!,
            barcode: code.text,
            phone: phone.text,
            title: name.text,
            type: type,
            containerNo: data!.containerNo!,
            price: ((data?.price ?? 0) * 1.0).toInt(),
            deliveryAddress: data?.deliveryAddress ?? '',
          );
        }
      }
    }
    isLoading = false;
    setStates();
    SnackBar snackBar = SnackBar(
      content: Text(
          res?.message ?? (res?.status == 200 ? 'Амжилттай' : 'Алдаа гарлаа')),
      duration: const Duration(milliseconds: 400),
      backgroundColor: AppTheme.primary,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    if (res?.status != 200) return;
    if (widget.callback != null) {
      widget.callback!();
    }
    phone.clear();
    code.clear();
    name.clear();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    bool light = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      onTap: () => unFocus(),
      child: Stack(
        children: [
          Container(
            width: widget.size.width,
            height: widget.size.height,
            padding: const EdgeInsets.only(
              top: 60,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Text(
                        'Буцах',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Column(
                      children: [
                        Text(
                          'Big Box',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Захиалга бүртгэх',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => complete(),
                      child: const Text(
                        'Хадгалах',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ).padding(horizontal: 20, bottom: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          color: light ? AppTheme.lighterGray : AppTheme.black,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ...List.generate(
                                  4,
                                  (index) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${index == 0 ? 'Track Дугаар' : index == 1 ? 'Утас' : index == 2 ? 'Үнэ' : 'Барааны нэр'} ${index < 2 ? index == 0 && readonly ? '' : '- required' : ''}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ).padding(
                                        left: 20,
                                        top: 20,
                                        bottom: 12,
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: light
                                              ? AppTheme.light
                                              : AppTheme.dark,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    width: 1,
                                                    color: AppTheme.primary,
                                                  ),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.add_comment_rounded,
                                                size: 18,
                                              ),
                                            ),
                                            Focus(
                                              onFocusChange: (value) {
                                                if (index == 0 &&
                                                    code.text != '' &&
                                                    !value) {
                                                  searchByBarCode(code.text);
                                                }
                                              },
                                              child: InputWidget(
                                                controller: index == 0
                                                    ? code
                                                    : index == 1
                                                        ? phone
                                                        : index == 2
                                                            ? price
                                                            : name,
                                                focus: index == 0
                                                    ? cfocus
                                                    : index == 1
                                                        ? pfocus
                                                        : index == 2
                                                            ? pricefocus
                                                            : nfocus,
                                                hasIcon: false,
                                                lbl: '',
                                                readonly: index == 0
                                                    ? readonly
                                                    : index == 1
                                                        ? usr.permissionId == 3
                                                            ? true
                                                            : false
                                                        : false,
                                                placeholder: '',
                                                setState: setStates,
                                                type: index == 1
                                                    ? TextInputType.phone
                                                    : index == 2
                                                        ? TextInputType.number
                                                        : TextInputType
                                                            .streetAddress,
                                                height: 30,
                                                color: AppTheme.transparent,
                                              ),
                                            ).expanded(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (usr.permissionId == 1 && data != null)
                                  GestureDetector(
                                    onTap: () {
                                      BottomPicker(
                                        items: [
                                          ...List.generate(list.length,
                                              (index) {
                                            return Center(
                                              child: Text(
                                                  list[index]['lbl'] ?? ''),
                                            );
                                          }),
                                        ],
                                        buttonWidth: widget.size.width - 40,
                                        buttonSingleColor: AppTheme.primary,
                                        onSubmit: (p0) {
                                          type = list[p0]['index'] ?? 0;
                                        },
                                        pickerTitle: const Text(
                                          'Хүргэлтийн төлөв',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.black,
                                          ),
                                        ),
                                        buttonContent: const Text(
                                          'Сонгох',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.lighterGray,
                                          ),
                                        ).center(),
                                        titlePadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 12),
                                        titleAlignment: Alignment.center,
                                        pickerTextStyle: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        closeIconColor: AppTheme.primary,
                                      ).show(context);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Төлөв: ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: type == -1
                                                ? AppTheme.green
                                                : type == 1
                                                    ? AppTheme.red
                                                    : type == 2
                                                        ? AppTheme.orange
                                                        : type == 3
                                                            ? AppTheme.blue
                                                            : AppTheme
                                                                .secondary,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            type == -1
                                                ? 'Хүргэгдсэн'
                                                : type == 0
                                                    ? 'Хүлээгдэж буй'
                                                    : type == 1
                                                        ? 'Эрээнд хүргэгдсэн'
                                                        : type == 2
                                                            ? 'Улаанбаатарт хүргэгдсэн'
                                                            : 'Хүргэлтэнд бүртгэгдсэн',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ).padding(horizontal: 20, top: 16),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ButtonWidget(
                        title: 'Хадгалах',
                        onPress: () {
                          complete();
                        },
                        hasIcon: false,
                        isLoading: isLoading,
                      ).padding(horizontal: 20, top: 12),
                    ],
                  ).padding(
                    bottom: widget.padding.bottom + 10,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              width: widget.size.width,
              height: widget.size.height,
              color: AppTheme.black.withOpacity(.5),
              child: Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: AppTheme.primary,
                  size: 40,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
