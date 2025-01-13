import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/global.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/pagination_model.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/models/user_model.dart';
import 'package:bigbox/domain/repositories/admin_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/input.dart';
import 'package:bigbox/utils/cached_image_initer.dart';
import 'package:bigbox/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/route_manager.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:styled_widget/styled_widget.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final key = GlobalKey<AnimatedListState>();
  TextEditingController qry = TextEditingController();
  FocusNode qfocus = FocusNode();
  bool isLoading = false;
  final ScrollController xcrollController = ScrollController();
  int page = 1;
  int limit = 10;
  PaginationModel pagination = PaginationModel.fromJson({});
  List<UserModel> users = [];

  void setStates() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    unFocus();
    isLoading = true;
    setStates();
    fetchUsers(true);
    xcrollController.addListener(() async {
      if ((xcrollController.offset >=
              (xcrollController.position.maxScrollExtent - 100)) &&
          !isLoading &&
          page > 0 &&
          page < ((pagination.pageCount ?? 1) + 1)) {
        fetchUsers(false);
      }
    });
  }

  void fetchUsers(bool isReload) async {
    if (isReload) {
      page = 1;
      users = [];
      key.currentState?.removeAllItems((context, animation) {
        return const SizedBox();
      });
    }
    if (!isReload &&
        (isLoading ||
            (page > 1 && page >= ((pagination.pageCount ?? 1) + 1)) ||
            page == 0)) {
      return;
    }
    isLoading = true;
    setStates();
    ResponseModel res = await AdminRepository().userList(
      page: page,
      limit: limit,
    );
    if (res.status == 200) {
      pagination = PaginationModel.fromJson(res.data['pagination']);
      if ((pagination.pageCount ?? 1) >= page) {
        page++;
      } else {
        page = 0;
      }
      if ((res.data['data'] ?? []).length > 0) {
        for (int i = 0; i < (res.data['data'] ?? []).length; i++) {
          int findIndex = users.indexWhere(
              (element) => element.id == (res.data['data'] ?? [])[i]['id']);
          if (findIndex < 0) {
            users.add(UserModel.fromJson((res.data['data'] ?? [])[i]));
            key.currentState?.insertItem(0);
          } else {
            users[findIndex] = UserModel.fromJson((res.data['data'] ?? [])[i]);
          }
        }
      }
    }
    isLoading = false;
    setStates();
  }

  void unFocus() {
    if (qfocus.hasFocus) {
      qfocus.unfocus();
    }
  }

  @override
  void dispose() {
    super.dispose();
    xcrollController.removeListener(() {});
  }

  void getModal(
    int typed, {
    required bool light,
    required Size size,
    required UserModel user,
    required BuildContext context,
  }) {
    int permissionId = user.permissionId ?? 3;
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
        return StatefulBuilder(builder: (ctx, setter) {
          return FractionallySizedBox(
            heightFactor: 0.7,
            child: Column(
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
                    Text(
                      typed == 0 ? 'Хэрэглэгчийн төлөв солих' : 'Статус солих',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: light ? AppTheme.black : AppTheme.lighterGray,
                      ),
                    ).padding(bottom: 20),
                    Row(
                      children: [
                        Stack(
                          children: [
                            CachedImageIniter(
                              user.avatar == ''
                                  ? defaultAvatar
                                  : '$host${user.avatar}',
                              width: 100,
                              height: 100,
                              radius: 0,
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Icon(
                                !(user.status ?? false)
                                    ? Icons.lock
                                    : Icons.verified,
                                color: !(user.status ?? false)
                                    ? AppTheme.red
                                    : AppTheme.primary,
                                size: 18,
                              ),
                            ),
                            if (user.permissionId != 1)
                              Container(
                                width: 100,
                                height: 100,
                                color: AppTheme.lighterGray.withOpacity(.6),
                              ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: AppTheme.black.withOpacity(.1),
                                ),
                                top: BorderSide(
                                  width: 1,
                                  color: AppTheme.black.withOpacity(.1),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (user.firstName ?? '') == '' &&
                                              (user.lastName ?? '') == ''
                                          ? '***************'
                                          : '${user.firstName ?? ""} ${user.firstName ?? ""}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '+976 ${user.phone}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ).height(100).padding(left: 20),
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(180),
                                      color: user.permissionId == 1
                                          ? AppTheme.green
                                          : AppTheme.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ).height(100).width(size.width),
                    if (typed == 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ...List.generate(2, (index) {
                            return GestureDetector(
                              onTap: () {
                                setter(() {
                                  permissionId = index == 0 ? 1 : 3;
                                });
                              },
                              child: Container(
                                width: size.width / 2 - 30,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: index == 0 && permissionId == 1
                                        ? AppTheme.primary
                                        : index == 1 && permissionId == 3
                                            ? AppTheme.primary
                                            : AppTheme.black.withOpacity(.1),
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
                                        border: Border.all(
                                          width: 1,
                                          color: index == 0 && permissionId == 1
                                              ? AppTheme.primary
                                              : index == 1 && permissionId == 3
                                                  ? AppTheme.primary
                                                  : AppTheme.black
                                                      .withOpacity(.1),
                                        ),
                                        color: index == 0 && permissionId == 1
                                            ? AppTheme.primary
                                            : index == 1 && permissionId == 3
                                                ? AppTheme.primary
                                                : AppTheme.transparent,
                                      ),
                                    ),
                                    Text(
                                      index == 0
                                          ? 'Админ хэрэглэгч'
                                          : 'Энгийн хэрэглэгч',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ).padding(top: 14),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ).padding(top: 26, horizontal: 20),
                    if (typed != 0)
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(180),
                              border: Border.all(
                                width: 1,
                                color: !(user.status ?? false)
                                    ? AppTheme.primary
                                    : AppTheme.red,
                              ),
                              color: !(user.status ?? false)
                                  ? AppTheme.primary
                                  : AppTheme.red,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                !(user.status ?? false)
                                    ? 'Хэрэглэгчийн эрх нээх'
                                    : 'Хэрэглэгч хориглох',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                !(user.status ?? false)
                                    ? 'Тус үйлдлийг хийсний дараа хэрэглэгч өөрийн бүртгэлээр ACCESS хийх боломжтой болно.'
                                    : 'Тус үйлдлийг хийсний дараа хэрэглэгч өөрийн бүртгэлээр ACCESS хийх боломжгүй болно.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ).padding(left: 20).expanded(),
                        ],
                      ).padding(
                        horizontal: 20,
                        top: 25,
                      ),
                  ],
                ).expanded(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonWidget(
                      onPress: () => Get.back(),
                      title: 'Хаах',
                      color: AppTheme.red,
                      hasIcon: false,
                    ).expanded(),
                    const SizedBox(
                      width: 20,
                    ),
                    ButtonWidget(
                      onPress: () async {
                        isLoading = true;
                        setStates();
                        setter(() {});
                        ResponseModel res = ResponseModel();
                        if (typed == 0) {
                          res = await AdminRepository().changeUserPermission(
                            id: user.id ?? 0,
                            permission: permissionId,
                          );
                        } else {
                          res = await AdminRepository().changeUserStatus(
                            id: user.id ?? 0,
                          );
                        }
                        SnackBar snackBar = SnackBar(
                          content: Text(res.message ??
                              (res.status == 200
                                  ? 'Амжилттай'
                                  : 'Алдаа гарлаа')),
                          duration: const Duration(milliseconds: 400),
                          backgroundColor: AppTheme.primary,
                        );
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
                        Get.back();
                        if (res.status == 200) {
                          int findIndex =
                              users.indexWhere((el) => el.id == user.id);
                          if (typed == 0 && findIndex > -1) {
                            users[findIndex].permissionId = permissionId;
                          } else if (typed == 1 && findIndex > -1) {
                            users[findIndex].status =
                                !(users[findIndex].status ?? false);
                          }
                        }
                        isLoading = false;
                        setter(() {});
                        setStates();
                      },
                      isLoading: isLoading,
                      title: 'Хадгалах',
                      hasIcon: false,
                    ).expanded(),
                  ],
                ).padding(horizontal: 20, bottom: 30),
              ],
            ).width(size.width).padding(vertical: 20),
          );
        });
      },
    );
  }

  void searchUser(String txt) async {
    if (isLoading) return;
    if (txt == '') {
      fetchUsers(true);
      return;
    } else {
      ResponseModel res = await AdminRepository().searchByPhone(qry: txt);
      if (res.data['data'].isEmpty) {
        showToast('Илэрц олдсонгүй', AnimatedSnackBarType.warning);
        return;
      } else {
        users = [];
        key.currentState?.removeAllItems((context, animation) {
          return const SizedBox();
        });
        for (int i = 0; i < (res.data['data'] ?? []).length; i++) {
          users.add(UserModel.fromJson((res.data['data'] ?? [])[i]));
          key.currentState?.insertItem(0);
        }
      }
      setStates();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool light = Theme.of(context).brightness == Brightness.light;
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => unFocus(),
      child: ScafoldBuilder(
        appbar: const CustomAppBar(
          title: 'Хэрэглэгчийн жагсаалт',
          isCamera: true,
        ),
        child: SizedBox(
          child: LayoutBuilder(
            builder: (context, constraints) => RefreshIndicator(
              onRefresh: () async {
                qry.clear();
                fetchUsers(true);
                await Future.delayed(const Duration(seconds: 1));
              },
              child: isLoading && users.isEmpty
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
                      controller: xcrollController,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          children: [
                            Container(
                              color: light
                                  ? AppTheme.lighterGray
                                  : AppTheme.deepDarkGray,
                              margin: const EdgeInsets.only(bottom: 20),
                              child: InputWidget(
                                controller: qry,
                                focus: qfocus,
                                hasIcon: false,
                                lbl: '',
                                placeholder: 'Хайх',
                                setState: setStates,
                                type: TextInputType.streetAddress,
                                height: 50,
                                onTap: (String txt) => searchUser(txt),
                              ).padding(horizontal: 20),
                            ),
                            ...List.generate(users.length, (index) {
                              return Container(
                                margin: EdgeInsets.zero,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Slidable(
                                  key: ValueKey(index),
                                  endActionPane: ActionPane(
                                    extentRatio: 1,
                                    motion: const ScrollMotion(),
                                    children: [
                                      ...List.generate(2, (ind) {
                                        return SlidableAction(
                                          flex: 1,
                                          onPressed: (cntxt) {
                                            getModal(
                                              ind,
                                              light: light,
                                              size: size,
                                              user: users[index],
                                              context: context,
                                            );
                                          },
                                          backgroundColor: [
                                            light
                                                ? AppTheme.orange
                                                : AppTheme.orange
                                                    .withOpacity(.3),
                                            light
                                                ? AppTheme.primary
                                                : AppTheme.primary
                                                    .withOpacity(.3),
                                          ][ind],
                                          foregroundColor: Colors.white,
                                          icon: [
                                            Icons
                                                .perm_contact_calendar_outlined,
                                            Icons.account_circle_outlined,
                                          ][ind],
                                          // borderRadius: BorderRadius.circular(12),
                                          label: [
                                            'Хэрэглэгчийн төлөв',
                                            'Статус',
                                          ][ind],
                                          spacing: 4,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 0,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  child: GestureDetector(
                                    child: Container(
                                      width: double.infinity,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: light
                                            ? index % 2 == 1
                                                ? AppTheme.transparent
                                                : AppTheme.lighterGray
                                            : AppTheme.black.withOpacity(.8),
                                      ),
                                      child: Row(
                                        children: [
                                          Stack(
                                            children: [
                                              CachedImageIniter(
                                                users[index].avatar == ''
                                                    ? defaultAvatar
                                                    : '$host${users[index].avatar}',
                                                width: 100,
                                                height: 100,
                                                radius: 0,
                                              ),
                                              Positioned(
                                                right: 8,
                                                top: 8,
                                                child: Icon(
                                                  !(users[index].status ??
                                                          false)
                                                      ? Icons.lock
                                                      : Icons.verified,
                                                  color:
                                                      !(users[index].status ??
                                                              false)
                                                          ? AppTheme.red
                                                          : AppTheme.primary,
                                                  size: 18,
                                                ),
                                              ),
                                              if (users[index].permissionId !=
                                                  1)
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  color: light
                                                      ? AppTheme.lighterGray
                                                          .withOpacity(.6)
                                                      : AppTheme.black
                                                          .withOpacity(.3),
                                                ),
                                            ],
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                color: light
                                                    ? AppTheme.transparent
                                                    : AppTheme.deepDarkGray
                                                        .withOpacity(.9),
                                                border: Border(
                                                  bottom: BorderSide(
                                                    width: 1,
                                                    color: light
                                                        ? AppTheme.black
                                                            .withOpacity(.1)
                                                        : AppTheme.lighterGray
                                                            .withOpacity(.3),
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        (users[index].firstName ??
                                                                        '') ==
                                                                    '' &&
                                                                (users[index]
                                                                            .lastName ??
                                                                        '') ==
                                                                    ''
                                                            ? '***************'
                                                            : '${users[index].firstName ?? ""} ${users[index].firstName ?? ""}',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      Text(
                                                        '+976 ${users[index].phone}',
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                      .height(100)
                                                      .padding(left: 20),
                                                  Container(
                                                    width: 10,
                                                    height: 10,
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(180),
                                                        color: users[index]
                                                                    .permissionId ==
                                                                1
                                                            ? AppTheme.green
                                                            : AppTheme.red),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
