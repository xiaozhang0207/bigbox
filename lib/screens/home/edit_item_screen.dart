// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/order_model.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/admin_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/input.dart';
import 'package:bigbox/shared/widget/primary_logo.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:styled_widget/styled_widget.dart';

class EditItem extends StatefulWidget {
  final OrderModel order;
  final String type;
  final Function localSetter;
  const EditItem({
    super.key,
    required this.order,
    required this.type,
    required this.localSetter,
  });

  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  String rnumber = '';
  String type = '';
  TextEditingController code = TextEditingController();
  TextEditingController container = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController delivery = TextEditingController();
  FocusNode codeFocus = FocusNode();
  FocusNode containerFocus = FocusNode();
  FocusNode priceFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode deliveryFocus = FocusNode();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    type = widget.type;
    rnumber = rn();
    code.clear();
    container.clear();
    price.clear();
    name.clear();
    delivery.clear();
    isLoading = false;
    setStates();
    unFocus();
    fetchData();
  }

  void setStates() {
    if (mounted) setState(() {});
  }

  String rn() {
    var rng = Random();
    var code = rng.nextInt(900000) + 100000;
    return code.toString().substring(0, 4);
  }

  void unFocus() {
    if (codeFocus.hasFocus) {
      codeFocus.unfocus();
    }
    if (containerFocus.hasFocus) {
      containerFocus.unfocus();
    }
    if (priceFocus.hasFocus) {
      priceFocus.unfocus();
    }
    if (nameFocus.hasFocus) {
      nameFocus.unfocus();
    }
    if (deliveryFocus.hasFocus) {
      deliveryFocus.unfocus();
    }
  }

  void fetchData() async {
    if (widget.type == 'containerNo') {
      List<String> txt = (widget.order.containerNo ?? '').split('-');
      code.text = txt.isNotEmpty ? txt[0] : '';
      container.text = txt.length > 1 ? txt[1] : '';
      rnumber = txt.length > 2 ? txt[2] : rn();
    } else if (widget.type == 'price') {
      price.text = (widget.order.price ?? 0).toString();
    } else if (widget.type == 'title') {
      name.text = widget.order.title ?? '';
    } else if (widget.type == 'deliveryAddress') {
      delivery.text = widget.order.deliveryAddress ?? '';
    }
    setStates();
  }

  @override
  void dispose() {
    super.dispose();
    unFocus();
  }

  void onPress() async {
    if (isLoading) return;
    unFocus();
    isLoading = true;
    setStates();
    ResponseModel res = ResponseModel();
    if (type == 'containerNo') {
      if (code.text == '' || container.text == '' || rnumber == '') {
        isLoading = false;
        setStates();
        return;
      }
      res = await AdminRepository().updateOrderDynamic(
        values: {
          "id": widget.order.id ?? 0,
          "barcode": widget.order.barCode ?? '',
          "phone": widget.order.phone ?? '',
          "containerNo": '${code.text}-${container.text}-$rnumber',
        },
      );
      if (res.status == 200 && res.data != null) {
        await widget.localSetter(OrderModel.fromJson(res.data));
      }
    } else if (type == 'price') {
      if (price.text == '') {
        isLoading = false;
        setStates();
        return;
      }
      res = await AdminRepository().updateOrderDynamic(
        values: {
          "id": widget.order.id ?? 0,
          "barcode": widget.order.barCode ?? '',
          "phone": widget.order.phone ?? '',
          "price": (double.parse(price.text)).toInt(),
        },
      );
      if (res.status == 200 && res.data != null) {
        await widget.localSetter(OrderModel.fromJson(res.data));
      }
    } else if (type == 'title') {
      if (name.text == '') {
        isLoading = false;
        setStates();
        return;
      }
      res = await AdminRepository().updateOrderDynamic(
        values: {
          "id": widget.order.id ?? 0,
          "barcode": widget.order.barCode ?? '',
          "phone": widget.order.phone ?? '',
          "title": name.text,
        },
      );
      if (res.status == 200 && res.data != null) {
        await widget.localSetter(OrderModel.fromJson(res.data));
      }
    } else if (type == 'deliveryAddress') {
      if (delivery.text == '') {
        isLoading = false;
        setStates();
        return;
      }
      res = await AdminRepository().updateOrderDynamic(
        values: {
          "id": widget.order.id ?? 0,
          "barcode": widget.order.barCode ?? '',
          "phone": widget.order.phone ?? '',
          "deliveryAddress": delivery.text,
        },
      );
      if (res.status == 200 && res.data != null) {
        await widget.localSetter(OrderModel.fromJson(res.data));
      }
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
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    bool light = Theme.of(context).brightness == Brightness.light;
    EdgeInsets padding = MediaQuery.of(context).padding;
    Size size = MediaQuery.of(context).size;
    int cType = (widget.order.type ?? 0);
    String currentType = cType == -1
        ? 'Хүргэгдсэн'
        : cType == 1
            ? 'Эрээнд ирсэн'
            : cType == 2
                ? 'Улаанбаатар ирсэн'
                : cType == 3
                    ? 'Хүргэлтэнд бүртгүүлсэн'
                    : 'Хүлээгдэж буй';
    return GestureDetector(
      onTap: () => unFocus(),
      child: ScafoldBuilder(
        appbar: CustomAppBar(
          title: type == 'containerNo'
              ? 'Агуулхын дугаар'
              : type == 'price'
                  ? 'Төлбөр'
                  : type == 'title'
                      ? 'Бүртгэлийн нэр'
                      : type == 'type'
                          ? 'Төлөв солих'
                          : 'Хүргэлтийн хаяг',
        ),
        child: Column(
          children: [
            Column(
              children: widget.type == 'containerNo'
                  ? [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            code.text == '' ? 'XX' : code.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            '-',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            container.text == '' ? 'XX' : container.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            '-',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            rnumber,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ).padding(top: 20, bottom: 20),
                      InputWidget(
                        controller: code,
                        focus: codeFocus,
                        hasIcon: false,
                        lbl: 'Агуулхын дугаар',
                        placeholder: 'Агуулхын дугаар',
                        setState: setStates,
                        type: TextInputType.number,
                      ),
                      InputWidget(
                        controller: container,
                        focus: containerFocus,
                        hasIcon: false,
                        lbl: 'Эгнээ дугаар',
                        placeholder: 'Эгнээ дугаар',
                        setState: setStates,
                        type: TextInputType.number,
                      ).padding(top: 20),
                    ]
                  : widget.type == 'price'
                      ? [
                          InputWidget(
                            controller: price,
                            focus: priceFocus,
                            hasIcon: false,
                            lbl: 'Үнэ шинэчлэх',
                            placeholder: 'Үнэ',
                            setState: () {
                              if (price.text == '') {
                                setStates();
                                return;
                              }
                              price.text = price.text.replaceAll('.', '');
                              price.text =
                                  double.parse(price.text).toInt().toString();
                              setStates();
                            },
                            type: TextInputType.number,
                          ).padding(top: 20),
                        ]
                      : widget.type == 'title'
                          ? [
                              InputWidget(
                                controller: name,
                                focus: nameFocus,
                                hasIcon: false,
                                lbl: 'Бүртгэлд нэр өгөх',
                                placeholder: 'Бүртгэлд нэр өгөх',
                                setState: setStates,
                                type: TextInputType.text,
                              ).padding(top: 20),
                            ]
                          : widget.type == 'type'
                              ? [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 50,
                                        child: PrimaryLogo(
                                          disableTxt: true,
                                        ),
                                      ).padding(right: 16),
                                      const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'BigBox',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            'Бараанд хяналт тавих',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      const SizedBox(height: 50),
                                      Container(
                                        width: size.width,
                                        height: 1,
                                        color: AppTheme.lighterGray,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ...List.generate(5, (index) {
                                            return Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(180),
                                                color: (widget.order.type ??
                                                            0) ==
                                                        -1
                                                    ? AppTheme.primary
                                                    : (widget.order.type ??
                                                                0) >=
                                                            index
                                                        ? (widget.order.type ??
                                                                    0) ==
                                                                index
                                                            ? AppTheme.light
                                                            : AppTheme.primary
                                                        : AppTheme.lighterGray,
                                                border: (widget.order.type ??
                                                            0) !=
                                                        index
                                                    ? null
                                                    : Border.all(
                                                        width: 2,
                                                        color:
                                                            AppTheme.primary),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color:
                                              AppTheme.primary.withOpacity(.2),
                                          borderRadius:
                                              BorderRadius.circular(180),
                                        ),
                                        child: Text(
                                          currentType,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).padding(bottom: 20),
                                  ...List.generate(5, (index) {
                                    return GestureDetector(
                                      onTap: () {
                                        if ((widget.order.type ?? 0) >= index ||
                                            (widget.order.type ?? 0) == -1) {
                                          SnackBar snackBar = const SnackBar(
                                            content: Text(
                                                'Төлөв солих үедээ бууруулж солих боломжгүй.'),
                                            duration:
                                                Duration(milliseconds: 1000),
                                            backgroundColor: AppTheme.primary,
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                          return;
                                        }
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: false,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20.0)),
                                          ),
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          enableDrag: true,
                                          backgroundColor: light
                                              ? AppTheme.light
                                              : AppTheme.deepDarkGray,
                                          builder: (context) {
                                            return StatefulBuilder(
                                                builder: (context, setter) {
                                              return FractionallySizedBox(
                                                heightFactor: 0.7,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Container(
                                                          width: 80,
                                                          height: 6,
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 24),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        180),
                                                            color: AppTheme
                                                                .lightGray,
                                                          ),
                                                        ),
                                                        Text(
                                                          widget.order
                                                                  .containerNo ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        Text(
                                                          widget.order
                                                                  .barCode ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      'Хүргэлтийн "${[
                                                        'Хүлээгдэж буй',
                                                        'Эрээнд ирсэн',
                                                        'Улаанбаатарт ирсэн',
                                                        'Хүргэлтэнд бүртгүүлсэн',
                                                        'Хүргэгдсэн'
                                                      ][index]}" төлөвт шилжүүлэх үү?',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ).padding(bottom: 20),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        ButtonWidget(
                                                          onPress: () {
                                                            Get.back();
                                                          },
                                                          isLoading: isLoading,
                                                          title: 'Цуцлах',
                                                          hasIcon: false,
                                                          color: AppTheme.red,
                                                        ).expanded(),
                                                        const SizedBox(
                                                            width: 20),
                                                        ButtonWidget(
                                                          onPress: () async {
                                                            if (isLoading) {
                                                              return;
                                                            }
                                                            isLoading = true;
                                                            setStates();
                                                            setter(() => {});

                                                            ResponseModel res =
                                                                await AdminRepository()
                                                                    .updateOrderDynamic(
                                                              values: {
                                                                "id": widget
                                                                        .order
                                                                        .id ??
                                                                    0,
                                                                "barcode": widget
                                                                        .order
                                                                        .barCode ??
                                                                    '',
                                                                "phone": widget
                                                                        .order
                                                                        .phone ??
                                                                    '',
                                                                "type": index,
                                                              },
                                                            );
                                                            if (res.status ==
                                                                    200 &&
                                                                res.data !=
                                                                    null) {
                                                              await widget.localSetter(
                                                                  OrderModel
                                                                      .fromJson(
                                                                          res.data));
                                                            }

                                                            isLoading = false;
                                                            setStates();
                                                            setter(() => {});
                                                            Get.back();
                                                            SnackBar snackBar =
                                                                SnackBar(
                                                              content: Text(res
                                                                      .message ??
                                                                  (res.status ==
                                                                          200
                                                                      ? 'Амжилттай'
                                                                      : 'Алдаа гарлаа')),
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1000),
                                                              backgroundColor:
                                                                  AppTheme
                                                                      .primary,
                                                            );
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    snackBar);
                                                            Get.back();
                                                          },
                                                          isLoading: isLoading,
                                                          title: 'Үргэлжлүүлэх',
                                                          hasIcon: false,
                                                        ).expanded(),
                                                      ],
                                                    ).padding(bottom: 20),
                                                  ],
                                                ).width(size.width).padding(
                                                    top: 12,
                                                    horizontal: 20,
                                                    bottom: 30),
                                              );
                                            });
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: size.width - 40,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            width: 1,
                                            color: AppTheme.lighterGray,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: (widget.order.type ??
                                                            0) ==
                                                        -1
                                                    ? AppTheme.primary
                                                    : (widget.order.type ??
                                                                0) >=
                                                            index
                                                        ? AppTheme.primary
                                                        : AppTheme.lighterGray,
                                                border: Border.all(
                                                  width: 1,
                                                  color: (widget.order.type ??
                                                              0) ==
                                                          -1
                                                      ? AppTheme.primary
                                                      : (widget.order.type ??
                                                                  0) >=
                                                              index
                                                          ? AppTheme.primary
                                                          : AppTheme
                                                              .lighterGray,
                                                ),
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  index == 0
                                                      ? 'Хүлээгдэж буй'
                                                      : index == 1
                                                          ? 'Эрээнд ирсэн'
                                                          : index == 2
                                                              ? 'Улаанбаатарт ирсэн'
                                                              : index == 3
                                                                  ? 'Хүргэлтэнд бүртгүүлсэн'
                                                                  : 'Хүргэгдсэн',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  [
                                                    'Барааны төлөв эрээнд ирэх үед дараагийн төлөвт шилжүүлээрэй.',
                                                    'Захиалгыг системд бүртгэсний дараа ЭРЭЭН-УБ ачаа гарах үед идэвхжүүлээрэй.',
                                                    'УБ-д захиалга ирсний дараа хэрэглэгчдэд мэдэгдэх үүднээс идэвхжүүлээрэй.',
                                                    'Хэрэглэгч өөрийн хүсэлтээр захиалга идэвхжүүлэх үед энэ ажиллах бөгөөд бусад үед тухайн төлөвийг алгасах болно.',
                                                    'Хэрэглэгчийн гарт хүргэх үед энэ төлөвийг идэвхжүүлээрэй.'
                                                  ][index],
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ).padding(left: 12).expanded(),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ]
                              : [
                                  InputWidget(
                                    controller: delivery,
                                    focus: deliveryFocus,
                                    hasIcon: false,
                                    maxLines: 20,
                                    lbl: 'Хүргэлтийн хаяг',
                                    placeholder: 'Хүргэлтийн хаяг',
                                    setState: setStates,
                                    type: TextInputType.text,
                                  ).padding(top: 20),
                                ],
            ).expanded(),
            if (widget.type != 'type')
              ButtonWidget(
                title: 'Хадгалах',
                onPress: onPress,
                hasIcon: false,
                isLoading: isLoading,
              ),
          ],
        ).padding(horizontal: 20, bottom: padding.bottom + 20),
      ),
    );
  }
}
