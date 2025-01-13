import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/global.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/order_model.dart';
import 'package:bigbox/domain/models/pagination_model.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/admin_repository.dart';
import 'package:bigbox/domain/repositories/user_repository.dart';
import 'package:bigbox/screens/home/add_item_screen.dart';
import 'package:bigbox/screens/home/scan_screen.dart';
import 'package:bigbox/screens/home/user_main_screen.dart';
import 'package:bigbox/shared/drawer.dart';
import 'package:bigbox/shared/input.dart';
import 'package:bigbox/shared/widget/item_list.dart';
import 'package:bigbox/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/route_manager.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:styled_widget/styled_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final key = GlobalKey<AnimatedListState>();
  TextEditingController qry = TextEditingController();
  FocusNode qfocus = FocusNode();
  int selectedTab = 1;
  Function? callback;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController xcrollController = ScrollController();
  final List<String> tracks = [
    'https://cdn-icons-png.flaticon.com/512/2801/2801874.png',
    'https://cdn-icons-png.flaticon.com/512/10351/10351969.png',
    'https://cdn-icons-png.flaticon.com/512/1254/1254225.png',
    'https://cdn-icons-png.flaticon.com/512/1358/1358632.png',
    'https://cdn-icons-png.flaticon.com/512/2801/2801874.png',
  ];
  final List<Color> colors = [
    AppTheme.red.withOpacity(.1),
    AppTheme.green.withOpacity(.1),
    AppTheme.orange.withOpacity(.1),
    AppTheme.blue.withOpacity(.1),
    const Color.fromARGB(255, 12, 47, 75).withOpacity(.1),
  ];
  List<dynamic> categories = [
    {
      "icon": Icons.card_membership_outlined,
      "title": "Нийт",
      "value": "0",
    },
    {
      "icon": Icons.cottage_rounded,
      "title": "Эрээнд ирсэн",
      "value": "0",
    },
    {
      "icon": Icons.pin_drop,
      "title": "Улаанбаатарт ирсэн",
      "value": "0",
    },
    {
      "icon": Icons.domain_verification_rounded,
      "title": "Хүлээн авсан",
      "value": "0",
    }
  ];
  List<String> types = [
    'Бүгд',
    'Хүлээгдэж буй',
    'Замдаа явж буй',
    'Ирсэн',
    'Хүлээлгэж өгсөн'
  ];
  List<OrderModel> orders = [];
  int page = 1;
  int limit = 10;
  PaginationModel pagination = PaginationModel.fromJson({});
  bool isLoading = true;
  String currentType = 'all';
  int layout = 0;

  @override
  void initState() {
    super.initState();
    selectedTab = 1;
    callback = null;
    unFocus();
    orders = [];
    isLoading = true;
    currentType = 'all';
    layout = 0;
    setStates();
    fetchData();
    xcrollController.addListener(() async {
      if ((xcrollController.offset >=
              (xcrollController.position.maxScrollExtent - 100)) &&
          !isLoading &&
          page > 0 &&
          page < ((pagination.pageCount ?? 1) + 1)) {
        fetchOrders(false);
      }
    });
  }

  void unFocus() {
    if (qfocus.hasFocus) {
      qfocus.unfocus();
    }
  }

  void setStates() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    unFocus();
  }

  void fetchData() async {
    if (usr.permissionId == 3) {
      ResponseModel res = await UserRepository().getHome();
      if (res.status == 200) {
        categories[0]['value'] = (res.data['total'] ?? 0).toString();
        categories[1]['value'] = (res.data['ereen'] ?? 0).toString();
        categories[2]['value'] = (res.data['ub'] ?? 0).toString();
        categories[3]['value'] = (res.data['success'] ?? 0).toString();
        setStates();
      }
    }
    fetchOrders(true);
  }

  void fetchOrders(bool isReload, {String? type}) async {
    if (isReload) {
      page = 1;
      orders = [];
    }
    if (!isReload &&
        (isLoading ||
            (page > 1 && page >= ((pagination.pageCount ?? 1) + 1)) ||
            page == 0)) {
      return;
    }
    isLoading = true;
    setStates();
    ResponseModel? res;
    if ((type ?? '') != '') {
      orders = [];
      currentType = usr.permissionId != 1
          ? (type ?? 'all')
          : (selectedTab == 1 ? 'pending' : 'success');
      setStates();
    }
    if (usr.permissionId == 3) {
      res = await UserRepository().homeList(
        page: page,
        limit: limit,
        type: type ?? currentType,
      );
    } else if (usr.permissionId == 1) {
      res = await AdminRepository().ordersList(
        page: page,
        limit: limit,
        status: type ?? currentType,
      );
    }
    if (res?.status == 200) {
      pagination = PaginationModel.fromJson(res?.data['pagination']);
      if ((pagination.pageCount ?? 1) >= page) {
        page++;
      } else {
        page = 0;
      }
      if ((res?.data['data'] ?? []).length > 0) {
        for (int i = 0; i < (res?.data['data'] ?? []).length; i++) {
          int findIndex = orders.indexWhere(
              (element) => element.id == (res?.data['data'] ?? [])[i]['id']);
          if (findIndex < 0) {
            orders.add(OrderModel.fromJson((res?.data['data'] ?? [])[i]));
            key.currentState?.insertItem(0);
          } else {
            orders[findIndex] =
                OrderModel.fromJson((res?.data['data'] ?? [])[i]);
          }
        }
      }
    }
    isLoading = false;
    setStates();
  }

  void searchBy(String txt) async {
    if (txt == '') return;
    isLoading = true;
    setStates();
    if (usr.permissionId == 3) {
      ResponseModel res = await UserRepository().searchByBarcode(token: txt);
      if (res.status == 200) {
        if ((res.data ?? []).length > 0) {
          List<OrderModel> tmps = [];
          for (int i = 0; i < res.data.length; i++) {
            tmps.add(OrderModel.fromJson(res.data[i]));
          }
          orders = [];
          orders = tmps;
        } else {
          showToast('Захиалга олдсонгүй', AnimatedSnackBarType.warning);
          isLoading = false;
          setStates();
          return;
        }
      }
    }
    isLoading = false;
    setStates();
  }

  void localSetter(OrderModel? value) {
    if (value != null) {
      final int findIndex = orders.indexWhere((el) => el.id == value.id);
      if (findIndex > -1) {
        orders[findIndex] = value;
        if ((orders[findIndex].type ?? 0) == -1 && selectedTab == 1) {
          orders.removeAt(findIndex);
        }
      }
      setStates();
    }
  }

  void searchResult(String txt) async {
    unFocus();
    if (txt == '') {
      fetchOrders(true);
      return;
    }
    isLoading = true;
    setStates();
    ResponseModel res = await AdminRepository().searchByBarcode(token: txt);
    orders = [];
    if ((res.data ?? []).length > 0) {
      List<OrderModel> tmps = [];
      for (int i = 0; i < res.data.length; i++) {
        tmps.add(OrderModel.fromJson(res.data[i]));
      }
      orders = tmps;
      // if (order.type == -1) {
      //   selectedTab = 2;
      // } else {
      //   selectedTab = 1;
      // }
    } else {
      showToast('Бүртгэл олдсонгүй', AnimatedSnackBarType.warning);
    }
    isLoading = false;
    setStates();
  }

  void qrResult(List<OrderModel> order) async {
    qry.clear();
    if (order.isEmpty) {
      showToast('Бүртгэл олдсонгүй', AnimatedSnackBarType.warning);
      return;
    }
    orders = order;
    // if (order.type == -1) {
    //   selectedTab = 2;
    // } else {
    //   selectedTab = 1;
    // }
    setStates();
  }

  void clickItem(int index, int ind) {
    Get.toNamed('/edit-order', arguments: [
      orders[index],
      [
        'containerNo',
        'price',
        'title',
        'type',
        'deliveryAddress',
      ][ind],
      localSetter,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool light = Theme.of(context).brightness == Brightness.light;
    EdgeInsets padding = MediaQuery.of(context).padding;
    return GestureDetector(
      onTap: () => unFocus(),
      child: ScafoldBuilder(
        scaffoldKey: scaffoldKey,
        resizeToAvoidBottomInset: false,
        endDrawer: DrawerWidget(
          callback: usr.permissionId == 3 ? fetchData : callback,
        ),
        child: usr.permissionId != 1
            ? Stack(
                children: [
                  UserMainScreen(
                    size: size,
                    light: light,
                    openDrawer: () {
                      scaffoldKey.currentState?.openEndDrawer();
                    },
                    localSetter: localSetter,
                    categories: categories,
                    fetchData: fetchOrders,
                    types: types,
                    isLoading: isLoading,
                    controller: xcrollController,
                    animatedKey: key,
                    orders: orders,
                    loaderSetter: (bool status) {
                      isLoading = status;
                      setStates();
                    },
                    searchBy: searchBy,
                  ),
                  Positioned(
                    right: 20,
                    bottom: padding.bottom + 30,
                    child: GestureDetector(
                      onTap: () {
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
                              callback: () {
                                fetchOrders(true);
                              },
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: const Alignment(0, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(180),
                          color: AppTheme.primary,
                          border: Border.all(
                            width: 1,
                            color: light ? AppTheme.dark : AppTheme.light,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppTheme.lighterGray,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                color: light ? AppTheme.light : AppTheme.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
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
                                      callback: () => fetchOrders(true),
                                    );
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.add,
                                size: 26,
                              ),
                            ),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/logo${light ? '' : '-white'}.png',
                                  width: 20,
                                ).padding(right: 12),
                                Text(
                                  'BigBox',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: light
                                        ? AppTheme.primary
                                        : AppTheme.light,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () =>
                                  scaffoldKey.currentState?.openEndDrawer(),
                              child: const Icon(
                                Icons.settings,
                                size: 20,
                              ),
                            ),
                          ],
                        ).padding(horizontal: 20, top: 12, bottom: 8),
                        InputWidget(
                          controller: qry,
                          focus: qfocus,
                          hasIcon: false,
                          lbl: '',
                          placeholder: 'Хайх',
                          setState: setStates,
                          type: TextInputType.streetAddress,
                          height: 36,
                          onTap: searchResult,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              unFocus();
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                enableDrag: false,
                                builder: (context) {
                                  return ScanScreen(
                                    isSearch: true,
                                    type: 0,
                                    onFinish: qrResult,
                                    padding: MediaQuery.of(context).padding,
                                    size: MediaQuery.of(context).size,
                                  );
                                },
                              );
                            },
                            child: const Icon(
                              Icons.qr_code,
                              size: 18,
                            ),
                          ),
                        ).padding(horizontal: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                size: 22,
                                color: AppTheme.primary,
                              ),
                              highlightColor: light
                                  ? AppTheme.lighterGray
                                  : AppTheme.deepDarkGray,
                              tooltip: '',
                              onPressed: () {
                                if (isLoading) return;
                                qry.clear();
                                fetchOrders(true);
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.2,
                                  color: AppTheme.primary,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (selectedTab != 1) {
                                          selectedTab = 1;
                                          setStates();
                                          fetchOrders(true, type: 'pending');
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        color: selectedTab == 1
                                            ? AppTheme.primary
                                            : AppTheme.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        child: Text(
                                          'Хүлээгдэж буй',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: selectedTab == 1
                                                ? AppTheme.light
                                                : AppTheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (selectedTab != 2) {
                                          selectedTab = 2;
                                          setStates();
                                          fetchOrders(true, type: 'success');
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        color: selectedTab == 2
                                            ? AppTheme.primary
                                            : AppTheme.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        child: Text(
                                          'Гүйцэтгэсэн',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: selectedTab == 2
                                                ? AppTheme.light
                                                : AppTheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                layout != 0
                                    ? Icons.list
                                    : Icons.grid_on_outlined,
                                size: 22,
                                color: AppTheme.primary,
                              ),
                              highlightColor: light
                                  ? AppTheme.lighterGray
                                  : AppTheme.deepDarkGray,
                              tooltip: '',
                              onPressed: () {
                                if (layout == 0) {
                                  layout = 1;
                                } else {
                                  layout = 0;
                                }
                                setStates();
                              },
                            ),
                          ],
                        ).padding(horizontal: 20, vertical: 8),
                      ],
                    ).padding(top: MediaQuery.of(context).padding.top),
                    Expanded(
                      child: Container(
                        width: size.width,
                        height: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        color: light ? AppTheme.lighterGray : AppTheme.dark,
                        child: isLoading && orders.isEmpty
                            ? Center(
                                child: LoadingAnimationWidget.threeArchedCircle(
                                  color: AppTheme.primary,
                                  size: 40,
                                ),
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) =>
                                    RefreshIndicator(
                                  onRefresh: () async {
                                    fetchOrders(true);
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                  },
                                  child: SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    controller: xcrollController,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth,
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: orders.isNotEmpty
                                          ? layout != 0
                                              ? GridView.count(
                                                  shrinkWrap: true,
                                                  primary: true,
                                                  padding: EdgeInsets.zero,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  crossAxisSpacing: 16.0,
                                                  mainAxisSpacing: 16.0,
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 1.5,
                                                  children: <Widget>[
                                                    ...List.generate(
                                                        orders.length, (index) {
                                                      int orderType =
                                                          orders[index].type ??
                                                              0;
                                                      return GestureDetector(
                                                        onLongPress: () {
                                                          showModalBottomSheet(
                                                            context: context,
                                                            isScrollControlled:
                                                                false,
                                                            shape:
                                                                const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.vertical(
                                                                      top: Radius
                                                                          .circular(
                                                                              20.0)),
                                                            ),
                                                            clipBehavior: Clip
                                                                .antiAliasWithSaveLayer,
                                                            enableDrag: true,
                                                            backgroundColor: light
                                                                ? AppTheme.light
                                                                : AppTheme
                                                                    .deepDarkGray,
                                                            builder: (context) {
                                                              return Column(
                                                                children: [
                                                                  Container(
                                                                    width: 80,
                                                                    height: 6,
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            24),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              180),
                                                                      color: AppTheme
                                                                          .lightGray,
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Get.back();
                                                                      Get.toNamed(
                                                                          '/edit-order',
                                                                          arguments: [
                                                                            orders[index],
                                                                            'containerNo',
                                                                            localSetter,
                                                                          ]);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      color: AppTheme
                                                                          .transparent,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.qr_code,
                                                                            size:
                                                                                28,
                                                                          ).padding(
                                                                              right: 24),
                                                                          Text(
                                                                            'Агуулхын дугаар',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: light ? AppTheme.black : AppTheme.lighterGray,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Get.back();
                                                                      Get.toNamed(
                                                                          '/edit-order',
                                                                          arguments: [
                                                                            orders[index],
                                                                            'price',
                                                                            localSetter,
                                                                          ]);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      color: AppTheme
                                                                          .transparent,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.account_balance_wallet_rounded,
                                                                            size:
                                                                                28,
                                                                          ).padding(
                                                                              right: 24),
                                                                          Text(
                                                                            'Төлбөр',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: light ? AppTheme.black : AppTheme.lighterGray,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ).padding(
                                                                              top: 24),
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Get.back();
                                                                      Get.toNamed(
                                                                          '/edit-order',
                                                                          arguments: [
                                                                            orders[index],
                                                                            'title',
                                                                            localSetter,
                                                                          ]);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      color: AppTheme
                                                                          .transparent,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.edit,
                                                                            size:
                                                                                28,
                                                                          ).padding(
                                                                              right: 24),
                                                                          Text(
                                                                            'Нэр солих',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: light ? AppTheme.black : AppTheme.lighterGray,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ).padding(
                                                                              top: 24),
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Get.back();
                                                                      Get.toNamed(
                                                                          '/edit-order',
                                                                          arguments: [
                                                                            orders[index],
                                                                            'type',
                                                                            localSetter,
                                                                          ]);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      color: AppTheme
                                                                          .transparent,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.toggle_off,
                                                                            size:
                                                                                28,
                                                                          ).padding(
                                                                              right: 24),
                                                                          Text(
                                                                            'Төлөв солих',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: light ? AppTheme.black : AppTheme.lighterGray,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ).padding(
                                                                              top: 24),
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Get.back();
                                                                      Get.toNamed(
                                                                          '/edit-order',
                                                                          arguments: [
                                                                            orders[index],
                                                                            'deliveryAddress',
                                                                            localSetter,
                                                                          ]);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      color: AppTheme
                                                                          .transparent,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.pin_drop_outlined,
                                                                            size:
                                                                                28,
                                                                          ).padding(
                                                                              right: 24),
                                                                          Text(
                                                                            'Хүргэлтийн хаяг',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: light ? AppTheme.black : AppTheme.lighterGray,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ).padding(
                                                                              top: 24),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                                  .width(size
                                                                      .width)
                                                                  .padding(
                                                                      top: 12,
                                                                      horizontal:
                                                                          20,
                                                                      bottom:
                                                                          30);
                                                            },
                                                          );
                                                        },
                                                        onTap: () =>
                                                            Get.toNamed(
                                                          '/order-detail',
                                                          arguments: [
                                                            orders[index].id,
                                                            localSetter,
                                                          ],
                                                        ),
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          height: 200,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: light
                                                                ? AppTheme
                                                                    .transparent
                                                                : AppTheme.black
                                                                    .withOpacity(
                                                                        .1),
                                                            border: Border.all(
                                                              width: 1,
                                                              color: AppTheme
                                                                  .black
                                                                  .withOpacity(
                                                                      light
                                                                          ? .05
                                                                          : .1),
                                                            ),
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            10),
                                                                color: colors[orderType ==
                                                                        0
                                                                    ? 0
                                                                    : orderType ==
                                                                            -1
                                                                        ? 1
                                                                        : orderType ==
                                                                                1
                                                                            ? 2
                                                                            : orderType == 2
                                                                                ? 3
                                                                                : 4],
                                                                child: Image
                                                                    .network(
                                                                  tracks[orderType ==
                                                                          0
                                                                      ? 0
                                                                      : orderType ==
                                                                              -1
                                                                          ? 1
                                                                          : orderType == 1
                                                                              ? 2
                                                                              : orderType == 2
                                                                                  ? 3
                                                                                  : 4],
                                                                  width: 20,
                                                                ),
                                                              ),
                                                              Column(
                                                                children: [
                                                                  Text(
                                                                    (orders[index].containerNo ??
                                                                                '') ==
                                                                            ''
                                                                        ? 'Бүртгээгүй'
                                                                        : orders[index].containerNo ??
                                                                            '',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    orders[index]
                                                                            .barCode ??
                                                                        '',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          9,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ).padding(top: 4),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            6,
                                                                        vertical:
                                                                            2),
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            6),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12),
                                                                      color: colors[orderType ==
                                                                              0
                                                                          ? 0
                                                                          : orderType == -1
                                                                              ? 1
                                                                              : orderType == 1
                                                                                  ? 2
                                                                                  : orderType == 2
                                                                                      ? 3
                                                                                      : 4],
                                                                    ),
                                                                    child: Text(
                                                                      orderType ==
                                                                              0
                                                                          ? 'Хүлээгдэж буй'
                                                                          : orderType == 1
                                                                              ? 'Эрээнд ирсэн'
                                                                              : orderType == 2
                                                                                  ? 'Улаанбаатарт ирсэн'
                                                                                  : orderType == 3
                                                                                      ? 'Хүргэлтэнд бүртгүүлсэн'
                                                                                      : 'Хүлээн авсан',
                                                                      maxLines:
                                                                          1,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            9,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .arrow_forward_ios_rounded,
                                                                    size: 12,
                                                                    color: light
                                                                        ? AppTheme
                                                                            .primary
                                                                        : AppTheme
                                                                            .lighterGray,
                                                                  ),
                                                                ],
                                                              ).padding(
                                                                  horizontal: 6,
                                                                  top: 6),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                )
                                              : LayoutBuilder(
                                                  builder:
                                                      (context, constraints) =>
                                                          RefreshIndicator(
                                                    onRefresh: () async {
                                                      fetchOrders(true);
                                                      await Future.delayed(
                                                          const Duration(
                                                              seconds: 1));
                                                    },
                                                    child: Column(
                                                      children: [
                                                        ...List.generate(
                                                            orders.length,
                                                            (index) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Get.toNamed(
                                                              '/order-detail',
                                                              arguments: [
                                                                orders[index]
                                                                    .id,
                                                                localSetter,
                                                              ],
                                                            ),
                                                            child: SizedBox(
                                                              child: ItemList(
                                                                orders: orders,
                                                                index: index,
                                                                tap: () {},
                                                                clickItem:
                                                                    clickItem,
                                                                isAdmin: true,
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                          // : ClipRRect(
                                          //     child: AnimatedList(
                                          //       padding: EdgeInsets.zero,
                                          //       physics:
                                          //           const NeverScrollableScrollPhysics(),
                                          //       key: key,
                                          //       initialItemCount:
                                          //           orders.length,
                                          //       shrinkWrap: true,
                                          //       itemBuilder: (context,
                                          //           index, animation) {
                                          //     return GestureDetector(
                                          //       onTap: () =>
                                          //           Get.toNamed(
                                          //         '/order-detail',
                                          //         arguments: [
                                          //           orders[index].id,
                                          //           localSetter,
                                          //         ],
                                          //       ),
                                          //       child: SizedBox(
                                          //         child: ItemList(
                                          //           orders: orders,
                                          //           index: index,
                                          //           animation:
                                          //               animation,
                                          //           tap: () {},
                                          //           clickItem:
                                          //               clickItem,
                                          //           isAdmin: true,
                                          //         ),
                                          //       ),
                                          //     );
                                          //   },
                                          // ),
                                          //   )
                                          : Column(
                                              mainAxisAlignment: orders.isEmpty
                                                  ? MainAxisAlignment.center
                                                  : MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.max,
                                              children: orders.isEmpty
                                                  ? [
                                                      Text(
                                                        'Захиалга бүртгэх',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: light
                                                              ? AppTheme.primary
                                                                  .withOpacity(
                                                                      .6)
                                                              : AppTheme
                                                                  .lighterGray,
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        size: 40,
                                                        color: light
                                                            ? AppTheme.primary
                                                                .withOpacity(.6)
                                                            : AppTheme
                                                                .lighterGray,
                                                      ),
                                                    ]
                                                  : [],
                                            ).padding(
                                              top: orders.isEmpty ? 100 : 0),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Container(
                      color: light ? AppTheme.lighterGray : AppTheme.dark,
                      height: 110,
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: size.width,
                              height: 88,
                              color: light ? AppTheme.light : AppTheme.black,
                              padding: EdgeInsets.only(
                                left: size.width * .1,
                                right: size.width * .1,
                                bottom: MediaQuery.of(context).padding.bottom,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => Get.toNamed('/users'),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person,
                                          color: light
                                              ? AppTheme.primary
                                              : AppTheme.light,
                                        ),
                                        const Text(
                                          'Хэрэглэгчид',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ).padding(top: 10),
                                  ),
                                  GestureDetector(
                                    onTap: () => Get.toNamed('/logs')
                                        ?.then((res) => fetchOrders(true)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: light
                                              ? AppTheme.primary
                                              : AppTheme.light,
                                        ),
                                        const Text(
                                          'Цэвэрлэх',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ).padding(top: 10),
                                  ),
                                ],
                              ).height(
                                  95 - MediaQuery.of(context).padding.bottom),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            child: Container(
                              width: size.width,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              color: AppTheme.black.withOpacity(.1),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Нийт бараа: ${qry.text != '' ? orders.length : pagination.total ?? 0}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                  if (qry.text != '')
                                    Text(
                                      'Улаанбаатарт ирсэн: ${orders.where((item) => item.type == 2).toList().length}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 14,
                            child: ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: false,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20.0)),
                                  ),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  enableDrag: true,
                                  backgroundColor: light
                                      ? AppTheme.light
                                      : AppTheme.deepDarkGray,
                                  builder: (context) {
                                    return FractionallySizedBox(
                                      heightFactor: 0.9,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 6,
                                            margin: const EdgeInsets.only(
                                                bottom: 24),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(180),
                                              color: AppTheme.lightGray,
                                            ),
                                          ),
                                          ...List.generate(5, (index) {
                                            return GestureDetector(
                                              onTap: () {
                                                if (index == 2) {
                                                  Get.offAndToNamed(
                                                      '/register-scan');
                                                  return;
                                                } else {
                                                  Get.back();
                                                }
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                  ),
                                                  clipBehavior: Clip
                                                      .antiAliasWithSaveLayer,
                                                  enableDrag: false,
                                                  builder: (context) {
                                                    return ScanScreen(
                                                      padding:
                                                          MediaQuery.of(context)
                                                              .padding,
                                                      type: index,
                                                      size:
                                                          MediaQuery.of(context)
                                                              .size,
                                                      callback: () =>
                                                          fetchOrders(true),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    bottom: 24,
                                                    top: index == 0 ? 24 : 0),
                                                color: AppTheme.transparent,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      [
                                                        Icons.add,
                                                        Icons
                                                            .location_history_rounded,
                                                        Icons
                                                            .local_print_shop_outlined,
                                                        Icons.delivery_dining,
                                                        Icons.check,
                                                      ][index],
                                                      size: 28,
                                                    ).padding(right: 24),
                                                    Text(
                                                      [
                                                        'Шинэ захиалга бүртгэх',
                                                        'Эрээнд бүртгэх',
                                                        'Улаанбаатарт бүртгэх',
                                                        'Хүргэлтэнд бүртгэх',
                                                        'Хүлээлгэж өгсөн',
                                                      ][index],
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: light
                                                            ? AppTheme.black
                                                            : AppTheme
                                                                .lighterGray,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                          // GestureDetector(
                                          //   onTap: () {
                                          //     Get.back();
                                          //     Get.toNamed('/register-scan');
                                          //   },
                                          //   child: Container(
                                          //     margin: const EdgeInsets.only(
                                          //       bottom: 24,
                                          //     ),
                                          //     color: AppTheme.transparent,
                                          //     child: Row(
                                          //       children: [
                                          //         const Icon(
                                          //           Icons.qr_code,
                                          //           size: 28,
                                          //         ).padding(right: 24),
                                          //         Text(
                                          //           'Тавцан бүртгэх',
                                          //           style: TextStyle(
                                          //             fontSize: 16,
                                          //             fontWeight:
                                          //                 FontWeight.w500,
                                          //             color: light
                                          //                 ? AppTheme.black
                                          //                 : AppTheme
                                          //                     .lighterGray,
                                          //           ),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ).width(size.width).padding(
                                          top: 12, horizontal: 20, bottom: 30),
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(180),
                                  side: BorderSide(
                                    width: 2,
                                    color:
                                        light ? AppTheme.light : AppTheme.black,
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                foregroundColor: AppTheme.lighterGray,
                                backgroundColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? AppTheme.primary
                                    : AppTheme.primary,
                                maximumSize: const Size(60, 60),
                                minimumSize: const Size(60, 60),
                              ),
                              child: const Text(
                                'SCAN',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.light,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
