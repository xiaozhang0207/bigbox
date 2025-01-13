// ignore_for_file: invalid_return_type_for_catch_error, use_build_context_synchronously

import 'dart:convert';

import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/global.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/order_model.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/user_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/input.dart';
import 'package:bigbox/shared/widget/primary_logo.dart';
import 'package:bigbox/utils/unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailScreen extends StatefulWidget {
  final int id;
  final Function? localSetter;
  const OrderDetailScreen({
    super.key,
    required this.id,
    this.localSetter,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderModel order = OrderModel();
  bool isLoading = false;
  TextEditingController delivery = TextEditingController();
  FocusNode deliveryFocus = FocusNode();
  void setStates() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    order = OrderModel();
    isLoading = false;
    setStates();
    fetchData();
    unFocus();
  }

  void unFocus() {
    if (deliveryFocus.hasFocus) {
      deliveryFocus.unfocus();
    }
  }

  void fetchData() async {
    isLoading = true;
    setStates();
    ResponseModel res = await UserRepository().orderDetail(id: widget.id);
    if (res.status == 200) {
      order = OrderModel.fromJson(res.data);
      if (widget.localSetter != null) {
        widget.localSetter!(order);
      }
      delivery.text = order.deliveryAddress ?? '';
    }
    isLoading = false;
    setStates();
  }

  void showLocation({
    required bool light,
    required Size size,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      clipBehavior: Clip.antiAlias,
      enableDrag: true,
      backgroundColor: light ? AppTheme.light : AppTheme.deepDarkGray,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Column(
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
              ).padding(horizontal: 20),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...List.generate(5, (index) {
                        return Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(180),
                            color: order.type == -1
                                ? AppTheme.primary
                                : (order.type ?? 0) >= index
                                    ? order.type == index
                                        ? AppTheme.light
                                        : AppTheme.primary
                                    : AppTheme.lighterGray,
                            border: order.type != index
                                ? null
                                : Border.all(width: 2, color: AppTheme.primary),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ).padding(horizontal: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(.2),
                      borderRadius: BorderRadius.circular(180),
                    ),
                    child: Text(
                      [
                        'Хүргэгдсэн',
                        'Хүлээгдэж буй',
                        'Эрээнд ирсэн',
                        'Улаанбаатарт ирсэн',
                        'Хүргэлтэнд бүртгүүлсэн'
                      ][(order.type ?? -1) + 1],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ).padding(bottom: 20, horizontal: 20),
              ...List.generate(5, (index) {
                return Container(
                  width: size.width - 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
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
                          borderRadius: BorderRadius.circular(12),
                          color: (order.type ?? 0) == -1
                              ? AppTheme.primary
                              : (order.type ?? 0) >= index
                                  ? AppTheme.primary
                                  : AppTheme.lighterGray,
                          border: Border.all(
                            width: 1,
                            color: (order.type ?? 0) == -1
                                ? AppTheme.primary
                                : (order.type ?? 0) >= index
                                    ? AppTheme.primary
                                    : AppTheme.lighterGray,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                );
              }),
            ],
          ).width(size.width).padding(vertical: 20),
        );
      },
    );
  }

  void copyClipboard() {
    Clipboard.setData(ClipboardData(text: (order.barCode ?? ''))).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Track дугаар хууллаа.')));
    });
  }

  void localSetter(OrderModel? value) {
    if (value != null) {
      order = value;
      if (widget.localSetter != null) {
        widget.localSetter!(order);
      }
      setStates();
    }
  }

  void postDelivery() async {
    if ((!(order.hasDelivery ?? false) == true && delivery.text == '') ||
        isLoading) return;
    Get.back();
    ResponseModel res = await UserRepository().createDelivery(
      id: order.id ?? 0,
      deliveryStatus: !(order.hasDelivery ?? false),
      deliveryAddress: delivery.text,
    );
    if (res.status == 200) {
      order.hasDelivery = !(order.hasDelivery ?? false);
      order.deliveryAddress = delivery.text;
      if (widget.localSetter != null) {
        widget.localSetter!(order);
      }
      SnackBar snackBar = SnackBar(
        content: Text(
            res.message ?? (res.status == 200 ? 'Амжилттай' : 'Алдаа гарлаа')),
        duration: const Duration(milliseconds: 1000),
        backgroundColor: AppTheme.primary,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setStates();
  }

  void createOrder({
    required bool light,
    required Size size,
  }) async {
    unFocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      clipBehavior: Clip.antiAlias,
      enableDrag: true,
      backgroundColor: light ? AppTheme.light : AppTheme.deepDarkGray,
      builder: (ctx) {
        return GestureDetector(
          onTap: () => unFocus(),
          child: FractionallySizedBox(
            heightFactor: 0.8,
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                    ).padding(horizontal: 20),
                    Text(
                      (order.hasDelivery ?? false)
                          ? 'Хүргэлт цуцлах'
                          : 'Хүргэлтэнд бүртгүүлэх',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ).width(size.width).padding(horizontal: 20, vertical: 12),
                    InputWidget(
                      controller: delivery,
                      focus: deliveryFocus,
                      hasIcon: false,
                      maxLines: 14,
                      lbl: 'Хүргэлтийн хаяг',
                      placeholder: 'Хүргэлтийн хаяг',
                      setState: setStates,
                      type: TextInputType.text,
                    ).padding(horizontal: 20),
                  ],
                ),
                Row(
                  children: [
                    ButtonWidget(
                      hasIcon: false,
                      title: 'Цуцлах',
                      color: AppTheme.red,
                      onPress: () => Get.back(),
                    ).expanded(),
                    const SizedBox(width: 20),
                    ButtonWidget(
                      hasIcon: false,
                      title: 'Хадгалах',
                      onPress: postDelivery,
                    ).expanded(),
                  ],
                ).padding(horizontal: 20, bottom: 12),
              ],
            ).width(size.width).padding(vertical: 20),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool light = Theme.of(context).brightness == Brightness.light;
    EdgeInsets padding = MediaQuery.of(context).padding;
    Size size = MediaQuery.of(context).size;
    return ScafoldBuilder(
      appbar: CustomAppBar(
        title: order.containerNo == ''
            ? order.barCode ?? ''
            : order.containerNo ?? '',
      ),
      child: isLoading
          ? SizedBox(
              width: size.width,
              height: size.height * 0.4,
              child: LoadingAnimationWidget.threeArchedCircle(
                color: AppTheme.primary,
                size: 40,
              ).center(),
            )
          : LayoutBuilder(
              builder: (context, constraints) => RefreshIndicator(
                onRefresh: () async {
                  fetchData();
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        if ((order.title ?? '') != '')
                          Text(
                            order.title ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                              .width(size.width)
                              .padding(horizontal: 20, top: 12, bottom: 10),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: light
                                  ? AppTheme.lighterGray
                                  : AppTheme.black.withOpacity(.1),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: AlignmentDirectional.topCenter,
                                children: [
                                  Container(
                                    width: 1,
                                    height: 120,
                                    color: light
                                        ? AppTheme.lighterGray
                                        : AppTheme.black.withOpacity(.1),
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    margin: const EdgeInsets.only(top: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(180),
                                      color: light
                                          ? AppTheme.primary
                                          : AppTheme.orange,
                                    ),
                                  ),
                                ],
                              ).padding(horizontal: 20),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        [
                                          'Хүргэгдсэн',
                                          'Хүлээгдэж буй',
                                          'Эрээнд ирсэн',
                                          'Улаанбаатарт ирсэн',
                                          'Хүргэлтэнд бүртгүүлсэн'
                                        ][(order.type ?? -1) + 1],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => showLocation(
                                          light: light,
                                          size: size,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(180),
                                          ),
                                          backgroundColor: AppTheme.lighterGray,
                                          maximumSize: const Size(25, 25),
                                          minimumSize: const Size(25, 25),
                                        ),
                                        child: const Icon(
                                          Icons.more_horiz,
                                          size: 16,
                                          color: AppTheme.black,
                                        ).paddingZero,
                                      ),
                                    ],
                                  ),
                                  const Text(
                                      'Хэрэглэгчид хүргэлтийн төлөв шинэчлэгдэх үед үргэлж мэдэгдэх болно.'),
                                ],
                              ).expanded(),
                            ],
                          ),
                        ),
                        Text('Захиалгын огноо: ${DateFormat('yyyy-MM-dd hh:mm a').format(order.createdAt ?? DateTime.now())}')
                            .width(size.width)
                            .padding(horizontal: 20),
                        if ((order.qr ?? '') != '')
                          GestureDetector(
                            onDoubleTap: copyClipboard,
                            child: Image.memory(
                              const Base64Decoder().convert(
                                (order.qr ?? '')
                                    .replaceAll('data:image/png;base64,', ''),
                              ),
                              width: size.width * .5,
                            ),
                          ),
                        GestureDetector(
                          onDoubleTap: copyClipboard,
                          child: Text(
                            order.barCode ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ).padding(bottom: 12),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: (order.hasDelivery ?? false)
                                          ? light
                                              ? AppTheme.primary
                                              : AppTheme.orange
                                          : AppTheme.lighterGray,
                                    ),
                                  ),
                                  child: (order.hasDelivery ?? false)
                                      ? Icon(
                                          Icons.check,
                                          color: light
                                              ? AppTheme.primary
                                              : AppTheme.orange,
                                          size: 16,
                                        )
                                      : const SizedBox(),
                                ),
                                const Text('Хүргэлттэй эсэх'),
                              ],
                            ),
                            Text('₮${unit(order.price ?? 0)}'),
                          ],
                        ).padding(top: 6, horizontal: 20),
                        if (order.hasDelivery ?? false)
                          Text('Хүргэлтийн хаяг: ${order.deliveryAddress ?? ''}')
                              .width(size.width)
                              .padding(horizontal: 20, top: 12),
                        Container(
                          width: size.width,
                          height: 1,
                          margin: const EdgeInsets.only(
                            top: 20,
                          ),
                          color: AppTheme.lighterGray,
                        ),
                        Column(
                          children: usr.permissionId != 1
                              ? [
                                  if ((order.type ?? 0) != -1)
                                    GestureDetector(
                                      onTap: () => createOrder(
                                        light: light,
                                        size: size,
                                      ),
                                      child: Container(
                                        color: AppTheme.transparent,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delivery_dining_outlined,
                                              size: 28,
                                              color: light
                                                  ? AppTheme.primary
                                                  : AppTheme.orange,
                                            ).padding(right: 24),
                                            Text(
                                              (order.hasDelivery ?? false)
                                                  ? 'Хүргэлт цуцлах'
                                                  : 'Хүргэлтэнд бүртгүүлэх',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: light
                                                    ? AppTheme.black
                                                    : AppTheme.lighterGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).padding(horizontal: 20),
                                ]
                              : [
                                  GestureDetector(
                                    onTap: () async {
                                      if (order.phone == '') {
                                        return;
                                      }
                                      await canLaunchUrl(Uri(
                                              scheme: 'tel', path: order.phone))
                                          .then((bool result) {
                                        launchUrl(Uri(
                                            scheme: 'tel',
                                            path: '+976 ${order.phone}'));
                                      }).catchError((e) => ScaffoldMessenger.of(
                                                  context)
                                              .showSnackBar(const SnackBar(
                                                  content:
                                                      Text('Алдаа гарлаа'))));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      color: AppTheme.transparent,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.call,
                                            color: light
                                                ? AppTheme.primary
                                                : AppTheme.orange,
                                            size: 28,
                                          ).padding(right: 20),
                                          Text(
                                            '+976 ${order.phone ?? ''}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: light
                                                  ? AppTheme.black
                                                  : AppTheme.lighterGray,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).padding(bottom: 16),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed('/edit-order', arguments: [
                                        order,
                                        'containerNo',
                                        localSetter,
                                      ]);
                                    },
                                    child: Container(
                                      color: AppTheme.transparent,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.qr_code,
                                            size: 28,
                                            color: light
                                                ? AppTheme.primary
                                                : AppTheme.orange,
                                          ).padding(right: 24),
                                          Text(
                                            'Агуулхын дугаар',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: light
                                                  ? AppTheme.black
                                                  : AppTheme.lighterGray,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).padding(horizontal: 20),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed('/edit-order', arguments: [
                                        order,
                                        'price',
                                        localSetter,
                                      ]);
                                    },
                                    child: Container(
                                      color: AppTheme.transparent,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons
                                                .account_balance_wallet_rounded,
                                            size: 28,
                                            color: light
                                                ? AppTheme.primary
                                                : AppTheme.orange,
                                          ).padding(right: 24),
                                          Text(
                                            'Төлбөр',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: light
                                                  ? AppTheme.black
                                                  : AppTheme.lighterGray,
                                            ),
                                          ),
                                        ],
                                      ).padding(top: 24),
                                    ),
                                  ).padding(horizontal: 20),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed('/edit-order', arguments: [
                                        order,
                                        'title',
                                        localSetter,
                                      ]);
                                    },
                                    child: Container(
                                      color: AppTheme.transparent,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 28,
                                            color: light
                                                ? AppTheme.primary
                                                : AppTheme.orange,
                                          ).padding(right: 24),
                                          Text(
                                            'Нэр солих',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: light
                                                  ? AppTheme.black
                                                  : AppTheme.lighterGray,
                                            ),
                                          ),
                                        ],
                                      ).padding(top: 24),
                                    ),
                                  ).padding(horizontal: 20),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed('/edit-order', arguments: [
                                        order,
                                        'type',
                                        localSetter,
                                      ]);
                                    },
                                    child: Container(
                                      color: AppTheme.transparent,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.toggle_off,
                                            size: 28,
                                            color: light
                                                ? AppTheme.primary
                                                : AppTheme.orange,
                                          ).padding(right: 24),
                                          Text(
                                            'Төлөв солих',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: light
                                                  ? AppTheme.black
                                                  : AppTheme.lighterGray,
                                            ),
                                          ),
                                        ],
                                      ).padding(top: 24),
                                    ),
                                  ).padding(horizontal: 20),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed('/edit-order', arguments: [
                                        order,
                                        'deliveryAddress',
                                        localSetter,
                                      ]);
                                    },
                                    child: Container(
                                      color: AppTheme.transparent,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.pin_drop_outlined,
                                            size: 28,
                                            color: light
                                                ? AppTheme.primary
                                                : AppTheme.orange,
                                          ).padding(right: 24),
                                          Text(
                                            'Хүргэлтийн хаяг',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: light
                                                  ? AppTheme.black
                                                  : AppTheme.lighterGray,
                                            ),
                                          ),
                                        ],
                                      ).padding(top: 24),
                                    ),
                                  ).padding(horizontal: 20),
                                ],
                        ).padding(top: 16, bottom: padding.bottom + 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
