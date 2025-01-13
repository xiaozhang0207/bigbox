import 'dart:math';

import 'package:bigbox/configs/global.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/order_model.dart';
import 'package:bigbox/shared/input.dart';
import 'package:bigbox/shared/widget/empty.dart';
import 'package:bigbox/shared/widget/item_list.dart';
import 'package:bigbox/utils/cached_image_initer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:styled_widget/styled_widget.dart';

class UserMainScreen extends StatefulWidget {
  final GlobalKey animatedKey;
  final bool light;
  final Size size;
  final Function openDrawer;
  final List<dynamic> categories;
  final Function fetchData;
  final bool isLoading;
  final List<String> types;
  final ScrollController controller;
  final List<OrderModel> orders;
  final Function loaderSetter;
  final Function searchBy;
  final Function localSetter;
  const UserMainScreen({
    super.key,
    required this.light,
    required this.size,
    required this.openDrawer,
    required this.categories,
    required this.fetchData,
    required this.types,
    required this.isLoading,
    required this.controller,
    required this.animatedKey,
    required this.orders,
    required this.loaderSetter,
    required this.searchBy,
    required this.localSetter,
  });

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  TextEditingController qry = TextEditingController();
  FocusNode qfocus = FocusNode();
  double offset = 0.0;
  bool isLoading = false;

  List<String> tracks = [
    'https://cdn-icons-png.flaticon.com/512/2801/2801874.png',
    'https://cdn-icons-png.flaticon.com/512/10351/10351969.png',
    'https://cdn-icons-png.flaticon.com/512/1254/1254225.png',
    'https://cdn-icons-png.flaticon.com/512/1358/1358632.png',
    'https://cdn-icons-png.flaticon.com/512/2801/2801874.png',
  ];
  List<Color> colors = [
    AppTheme.red.withOpacity(.1),
    AppTheme.green.withOpacity(.1),
    AppTheme.orange.withOpacity(.1),
    AppTheme.blue.withOpacity(.1),
    const Color.fromARGB(255, 12, 47, 75).withOpacity(.1),
  ];
  int selectedType = 0;
  void setStates() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    isLoading = false;
    setStates();
    unFocus();
    widget.controller.addListener(_handleControllerNotification);
  }

  void unFocus() {
    if (qfocus.hasFocus) {
      qfocus.unfocus();
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_handleControllerNotification);
    unFocus();
  }

  void _handleControllerNotification() {
    offset = widget.controller.offset;
    setStates();
  }

  Image imageCompiler() {
    return Image.network(
      [
        'https://cdn-icons-png.flaticon.com/512/2801/2801874.png',
        'https://cdn-icons-png.flaticon.com/512/10351/10351969.png',
        'https://cdn-icons-png.flaticon.com/512/1254/1254225.png',
        'https://cdn-icons-png.flaticon.com/512/1358/1358632.png'
      ][Random().nextInt(3) + 1],
      width: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: AppTheme.primary,
      onRefresh: () async {
        widget.fetchData(true);
      },
      child: GestureDetector(
        onTap: () => unFocus(),
        child: Stack(
          children: [
            Container(
              width: widget.size.width,
              height: widget.size.height,
              padding: EdgeInsets.only(top: padding.top + 12),
              color: widget.light ? AppTheme.light : AppTheme.dark,
              child: SingleChildScrollView(
                controller: widget.controller,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
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
                                        color: widget.light
                                            ? AppTheme.deepDarkGray
                                            : AppTheme.black,
                                      ),
                                      Text(
                                        '+976 ${usr.phone}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: widget.light
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
                        GestureDetector(
                          onTap: () {
                            widget.openDrawer();
                          },
                          child: SizedBox(
                            child: Icon(
                              Icons.menu,
                              size: 32,
                              color: widget.light
                                  ? AppTheme.primary
                                  : AppTheme.light,
                            ),
                          ),
                        ),
                      ],
                    ).padding(horizontal: 20, bottom: 24),
                    InputWidget(
                      controller: qry,
                      focus: qfocus,
                      hasIcon: false,
                      lbl: '',
                      placeholder: 'Хайх',
                      setState: setStates,
                      type: TextInputType.streetAddress,
                      height: 36,
                      onTap: (txt) async {
                        if (widget.isLoading) return;
                        selectedType = 0;
                        setStates();
                        if (txt == '') {
                          widget.fetchData(true);
                          return;
                        }
                        unFocus();
                        await widget.searchBy(txt);
                      },
                    ).padding(horizontal: 20, bottom: 20),
                    SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ...List.generate(widget.categories.length, (index) {
                            return SizedBox(
                              width: ((widget.size.width - 40) * .25) - 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(180),
                                      color: widget.light
                                          ? AppTheme.lighterGray
                                          : AppTheme.black,
                                    ),
                                    child: Icon(
                                      widget.categories[index]['icon'] ??
                                          Icons.check,
                                      size: 24,
                                      color: widget.light
                                          ? AppTheme.darkGray
                                          : AppTheme.light,
                                    ).center(),
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        widget.categories[index]['title'] ?? '',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: widget.light
                                              ? AppTheme.darkGray
                                              : AppTheme.black,
                                        ),
                                      ),
                                      Text(
                                        widget.categories[index]['value'] ?? '',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: widget.light
                                              ? AppTheme.black
                                              : AppTheme.black,
                                        ),
                                      ),
                                    ],
                                  ).expanded(),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ).padding(horizontal: 20, bottom: 16).height(120),
                    Container(
                      width: widget.size.width,
                      height: 6,
                      color: widget.light
                          ? AppTheme.lighterGray
                          : AppTheme.darkGray,
                    ),
                    SizedBox(
                      width: widget.size.width,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...List.generate(widget.types.length, (index) {
                              return GestureDetector(
                                onTap: () {
                                  if (widget.isLoading) return;
                                  if (selectedType == index) {
                                    return;
                                  }
                                  selectedType = index;
                                  setStates();
                                  widget.fetchData(
                                    true,
                                    type: index == 0
                                        ? 'all'
                                        : index == 1
                                            ? 'pending'
                                            : index == 2
                                                ? 'going'
                                                : index == 3
                                                    ? 'inub'
                                                    : 'success',
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: EdgeInsets.only(
                                    left: index == 0 ? 20 : 0,
                                    right: 8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(180),
                                    border: Border.all(
                                      width: 1,
                                      color: widget.light
                                          ? AppTheme.gray
                                          : selectedType == index
                                              ? AppTheme.light
                                              : AppTheme.black,
                                    ),
                                    color: selectedType == index
                                        ? AppTheme.primary
                                        : widget.light
                                            ? AppTheme.lighterGray
                                            : AppTheme.darkestGray,
                                  ),
                                  child: Text(
                                    widget.types[index],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: selectedType == index
                                          ? AppTheme.light
                                          : widget.light
                                              ? AppTheme.black
                                              : AppTheme.gray,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ).padding(top: 12),
                    Container(
                      width: widget.size.width,
                      height: 6,
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      color: widget.light
                          ? AppTheme.lighterGray
                          : AppTheme.darkGray,
                    ),
                    if (widget.isLoading)
                      Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: AppTheme.primary,
                          size: 40,
                        ),
                      ).padding(top: 30),
                    if (!widget.isLoading && widget.orders.isEmpty)
                      const EmptyWidget(
                        title: 'Бүртгэлтэй бараа байхгүй байна.',
                      ).width(widget.size.width).padding(top: 30),
                    AnimatedList(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      // physics: const AlwaysScrollableScrollPhysics(),
                      physics: const NeverScrollableScrollPhysics(),
                      key: widget.animatedKey,
                      initialItemCount: widget.orders.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index, animation) {
                        return GestureDetector(
                          onTap: () => Get.toNamed(
                            '/order-detail',
                            arguments: [
                              widget.orders[index].id,
                              widget.localSetter,
                            ],
                          ),
                          child: SizedBox(
                            child: ItemList(
                              orders: widget.orders,
                              index: index,
                              animation: animation,
                              tap: () {},
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: offset >= padding.top - 20 ? 1 : 0,
              child: Container(
                color: widget.light ? AppTheme.light : AppTheme.black,
                width: widget.size.width,
                height: padding.top + 60,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/logo${widget.light ? '' : '-white'}.png',
                            width: 30,
                          ).padding(right: 8),
                          const Text(
                            'BigBox',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.openDrawer(),
                      child: SizedBox(
                        child: Icon(
                          Icons.menu,
                          size: 32,
                          color:
                              widget.light ? AppTheme.primary : AppTheme.light,
                        ),
                      ),
                    ),
                  ],
                ).padding(bottom: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
