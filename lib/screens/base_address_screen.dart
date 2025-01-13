// ignore_for_file: use_build_context_synchronously

import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/global.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/address_model.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/admin_repository.dart';
import 'package:bigbox/domain/repositories/user_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:styled_widget/styled_widget.dart';

class BaseAddressScreen extends StatefulWidget {
  const BaseAddressScreen({super.key});

  @override
  State<BaseAddressScreen> createState() => _BaseAddressScreenState();
}

class _BaseAddressScreenState extends State<BaseAddressScreen> {
  TextEditingController type = TextEditingController();
  TextEditingController address = TextEditingController();
  FocusNode tFocus = FocusNode();
  FocusNode aFocus = FocusNode();
  bool isLoading = false;
  List<AddressModel> datas = [];
  final key = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    datas = [];
    isLoading = false;
    setStates();
    unFocus();
    fetchData();
  }

  void setStates() {
    if (mounted) setState(() {});
  }

  void unFocus() {
    if (tFocus.hasFocus) {
      tFocus.unfocus();
    }
    if (aFocus.hasFocus) {
      aFocus.unfocus();
    }
  }

  void fetchData() async {
    if (isLoading) return;
    datas = [];
    isLoading = true;
    setStates();
    ResponseModel res = await UserRepository().getMainAddress();
    if (res.status == 200) {
      if ((res.data ?? []).length > 0) {
        for (int i = 0; i < (res.data ?? []).length; i++) {
          datas.add(AddressModel.fromJson((res.data ?? [])[i]));
          key.currentState?.insertItem(0);
        }
      }
    }
    isLoading = false;
    setStates();
  }

  void addAddress(
    AddressModel? addr, {
    bool? isRemove,
  }) async {
    if (usr.permissionId != 1) return;
    bool isRemoved = (isRemove ?? false);
    if (isLoading ||
        ((!isRemoved && type.text == '') ||
            (!isRemoved && address.text == ''))) {
      return;
    }
    if (!isRemoved) Get.back();
    unFocus();
    ResponseModel res = !isRemoved
        ? addr == null
            ? await AdminRepository().addAddress(
                type: type.text,
                address: address.text,
              )
            : await AdminRepository().updateAddress(
                id: addr.id ?? 0,
                type: type.text,
                address: address.text,
              )
        : await AdminRepository().deleteAddress(id: addr?.id ?? 0);
    if (res.status == 200) {
      fetchData();
      type.clear();
      address.clear();
    }
    SnackBar snackBar = SnackBar(
      content: Text(
          res.message ?? (res.status == 200 ? 'Амжилттай' : 'Алдаа гарлаа')),
      duration: const Duration(milliseconds: 1000),
      backgroundColor: AppTheme.primary,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void addressModal({
    required bool light,
    required Size size,
    required EdgeInsets padding,
    AddressModel? addr,
  }) {
    if (usr.permissionId != 1) return;
    if (isLoading) return;
    unFocus();
    if (addr == null) {
      type.clear();
      address.clear();
    }
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        enableDrag: true,
        backgroundColor: light ? AppTheme.light : AppTheme.deepDarkGray,
        builder: (ctx) {
          return GestureDetector(
            onTap: () => unFocus(),
            child: StatefulBuilder(
              builder: (ctx, setter) {
                return FractionallySizedBox(
                  heightFactor: 0.85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
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
                            Text(
                              addr == null ? 'Хаяг нэмэх' : 'Хаяг засах',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: light
                                    ? AppTheme.black
                                    : AppTheme.lighterGray,
                              ),
                            ).padding(bottom: 20),
                            InputWidget(
                              controller: type,
                              focus: tFocus,
                              hasIcon: false,
                              lbl: 'Хаягийн төрөл',
                              placeholder: 'Хаягийн төрөл',
                              setState: () {
                                setStates();
                                setter(() => {});
                              },
                              type: TextInputType.text,
                            ).padding(top: 20),
                            InputWidget(
                              controller: address,
                              focus: aFocus,
                              hasIcon: false,
                              maxLines: 10,
                              lbl: 'Хаягийн мэдээлэл',
                              placeholder: 'Хаягийн мэдээлэл',
                              setState: () {
                                setStates();
                                setter(() => {});
                              },
                              type: TextInputType.text,
                            ).padding(top: 20),
                          ],
                        ).padding(all: 20),
                      ).expanded(),
                      ButtonWidget(
                        title: 'Хадгалах',
                        onPress: () => addAddress(addr),
                        hasIcon: false,
                        isLoading: isLoading,
                        disable: type.text == '' || address.text == '',
                      ).padding(horizontal: 20, bottom: padding.bottom + 12),
                    ],
                  ),
                );
              },
            ),
          );
        });
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
          title: 'Эрээний хаяг',
          isCamera: true,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: LayoutBuilder(
                builder: (context, constraints) => RefreshIndicator(
                  onRefresh: () async {
                    fetchData();
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: isLoading
                      ? SizedBox(
                          width: size.width,
                          height: size.height * 0.4,
                          child: LoadingAnimationWidget.threeArchedCircle(
                            color: AppTheme.primary,
                            size: 40,
                          ).center(),
                        )
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                              minHeight: constraints.maxHeight,
                            ),
                            child: AnimatedList(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              key: key,
                              initialItemCount: datas.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index, animation) {
                                return Slidable(
                                  key: ValueKey(index),
                                  endActionPane: ActionPane(
                                    extentRatio: .5,
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        flex: 1,
                                        onPressed: (cntxt) {
                                          type.text = datas[index].type ?? '';
                                          address.text =
                                              datas[index].address ?? '';
                                          setStates();
                                          addressModal(
                                              light: light,
                                              size: size,
                                              padding: padding,
                                              addr: datas[index]);
                                          // removeItems(datas[index]);
                                        },
                                        backgroundColor: AppTheme.primary,
                                        foregroundColor: Colors.white,
                                        icon: Icons.update,
                                        label: 'Засах',
                                        spacing: 4,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 0,
                                        ),
                                      ),
                                      SlidableAction(
                                        flex: 1,
                                        onPressed: (cntxt) {
                                          addAddress(
                                            datas[index],
                                            isRemove: true,
                                          );
                                        },
                                        backgroundColor: AppTheme.red,
                                        foregroundColor: Colors.white,
                                        icon: Icons.auto_delete_rounded,
                                        label: 'Устгах',
                                        spacing: 4,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20, bottom: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: light
                                              ? AppTheme.lighterGray
                                              : AppTheme.black.withOpacity(.1),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.maps_home_work_rounded,
                                          size: 24,
                                          color: light
                                              ? AppTheme.primary
                                              : AppTheme.lighterGray,
                                        ).padding(right: 20),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              datas[index].type ?? '',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              datas[index].address ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                        text: (datas[index]
                                                                .address ??
                                                            '')))
                                                    .then((_) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(const SnackBar(
                                                          content: Text(
                                                              'Агуулхын хаяг хуулагдлаа.')));
                                                });
                                              },
                                              child: Container(
                                                color: AppTheme.transparent,
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.copy,
                                                      size: 12,
                                                    ).padding(right: 8),
                                                    const Text(
                                                      'Текст хуулах',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ).padding(top: 8),
                                          ],
                                        ).expanded(),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ),
            ).expanded(),
            if (usr.permissionId == 1)
              ButtonWidget(
                title: 'Хаяг нэмэх',
                onPress: () {
                  addressModal(
                    light: light,
                    size: size,
                    padding: padding,
                  );
                },
                hasIcon: false,
                isLoading: isLoading,
              ).padding(
                horizontal: 30,
                bottom: padding.bottom + 12,
              ),
          ],
        ),
      ),
    );
  }
}
