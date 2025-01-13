// ignore_for_file: use_build_context_synchronously

import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/log_model.dart';
import 'package:bigbox/domain/models/pagination_model.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/admin_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/widget/primary_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:styled_widget/styled_widget.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final key = GlobalKey<AnimatedListState>();
  final ScrollController xcrollController = ScrollController();
  PaginationModel pagination = PaginationModel.fromJson({});
  bool isLoading = false;
  int page = 1;
  int limit = 10;
  List<LogModel> datas = [];
  List<LogModel> picks = [];

  void setStates() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    picks = [];
    setStates();
    fetchData(true);
    xcrollController.addListener(() async {
      if ((xcrollController.offset >=
              (xcrollController.position.maxScrollExtent - 100)) &&
          !isLoading &&
          page > 0 &&
          page < ((pagination.pageCount ?? 1) + 1)) {
        fetchData(false);
      }
    });
  }

  void fetchData(bool isReload) async {
    if (isReload) {
      page = 1;
      datas = [];
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
    ResponseModel res = await AdminRepository().orderHistory(
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
          int findIndex = datas.indexWhere(
              (element) => element.date == (res.data['data'] ?? [])[i]['date']);
          if (findIndex < 0) {
            datas.add(LogModel.fromJson((res.data['data'] ?? [])[i]));
            key.currentState?.insertItem(0);
          } else {
            datas[findIndex] = LogModel.fromJson((res.data['data'] ?? [])[i]);
          }
        }
      }
    }
    isLoading = false;
    setStates();
  }

  void removeItems(LogModel? log) async {
    if (isLoading || (log == null && picks.isEmpty)) return;
    isLoading = true;
    setStates();
    List<String> tmp = [];
    if (log != null) {
      tmp.add(log.date);
    } else {
      for (int i = 0; i < picks.length; i++) {
        tmp.add(picks[i].date);
      }
    }
    ResponseModel res = await AdminRepository().deleteOrdersHistory(logs: tmp);
    if (res.status == 200) {
      if (log != null) {
        int findIndex = datas.indexWhere((el) => el.date == log.date);
        if (findIndex > -1) {
          datas.removeAt(findIndex);
          key.currentState
              ?.removeItem(findIndex, (context, animation) => const SizedBox());
        }
      } else {
        for (int i = 0; i < picks.length; i++) {
          int findIndex = datas.indexWhere((el) => el.date == picks[i].date);
          if (findIndex > -1) {
            datas.removeAt(findIndex);
            key.currentState?.removeItem(
                findIndex, (context, animation) => const SizedBox());
          }
        }
        picks = [];
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
  }

  @override
  Widget build(BuildContext context) {
    // bool light = Theme.of(context).brightness == Brightness.light;
    EdgeInsets padding = MediaQuery.of(context).padding;
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => () {},
      child: ScafoldBuilder(
        appbar: const CustomAppBar(
          title: 'Үйл ажиллагааны түүх',
          isCamera: true,
        ),
        child: SizedBox(
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) => RefreshIndicator(
                  onRefresh: () async {
                    fetchData(true);
                    if (datas.isNotEmpty) {
                      await Future.delayed(const Duration(seconds: 1));
                    }
                  },
                  child: isLoading && datas.isEmpty
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
                            child: datas.isEmpty
                                ? Column(
                                    children: [
                                      const PrimaryLogo(
                                        disableTxt: true,
                                      ),
                                      const Text(
                                        'Үйл ажиллагааны түүх олдсонгүй!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ).padding(horizontal: size.width * .25),
                                    ],
                                  ).width(size.width)
                                : AnimatedList(
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    key: key,
                                    initialItemCount: datas.length,
                                    shrinkWrap: true,
                                    itemBuilder: (BuildContext context,
                                        int index,
                                        Animation<double> animation) {
                                      return GestureDetector(
                                        onTap: () {
                                          int findIndex = picks.indexWhere(
                                              (el) =>
                                                  el.date == datas[index].date);
                                          if (findIndex > -1) {
                                            picks.removeAt(findIndex);
                                          } else {
                                            picks.add(datas[index]);
                                          }
                                          setStates();
                                        },
                                        child: Container(
                                          margin: EdgeInsets.zero,
                                          decoration: const BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          child: Slidable(
                                            key: ValueKey(index),
                                            endActionPane: ActionPane(
                                              extentRatio: .25,
                                              motion: const ScrollMotion(),
                                              children: [
                                                SlidableAction(
                                                  flex: 1,
                                                  onPressed: (cntxt) {
                                                    removeItems(datas[index]);
                                                  },
                                                  backgroundColor: AppTheme.red,
                                                  foregroundColor: Colors.white,
                                                  icon:
                                                      Icons.auto_delete_rounded,
                                                  label: 'Устгах',
                                                  spacing: 4,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            child: SizeTransition(
                                              sizeFactor: animation,
                                              key: ValueKey(index),
                                              child: Container(
                                                color: AppTheme.transparent,
                                                width: size.width,
                                                height: 100,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      height: 100,
                                                      child: Text(
                                                        datas[index]
                                                            .date
                                                            .split('-')[0],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                      height: 100,
                                                      child: Stack(
                                                        alignment:
                                                            AlignmentDirectional
                                                                .topCenter,
                                                        children: [
                                                          if (index + 1 <
                                                              datas.length)
                                                            Container(
                                                              width: 1,
                                                              height: 100,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                border: Border(
                                                                  right:
                                                                      BorderSide(
                                                                    width: 1,
                                                                    color: AppTheme
                                                                        .lighterGray,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          Container(
                                                            width: 20,
                                                            height: 20,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: AppTheme
                                                                  .lighterGray,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          180),
                                                              border:
                                                                  Border.all(
                                                                width: 1,
                                                                color: AppTheme
                                                                    .lighterGray,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ).width(30),
                                                    ),
                                                    SizedBox(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    datas[index]
                                                                        .total,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  ).padding(
                                                                      right: 8),
                                                                  const Text(
                                                                    'Захиалга',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Text(
                                                                '${datas[index].date.split('-')[1]} сар',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ).padding(top: 8),
                                                            ],
                                                          ),
                                                          Container(
                                                            width: 20,
                                                            height: 20,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          180),
                                                              color: picks.contains(
                                                                      datas[
                                                                          index])
                                                                  ? AppTheme
                                                                      .primary
                                                                  : AppTheme
                                                                      .transparent,
                                                              border:
                                                                  Border.all(
                                                                width: 1,
                                                                color: picks.contains(
                                                                        datas[
                                                                            index])
                                                                    ? AppTheme
                                                                        .primary
                                                                    : AppTheme
                                                                        .lighterGray,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ).padding(horizontal: 20),
                                                    ).expanded(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                ),
              ).expanded(),
              if (picks.isNotEmpty)
                ButtonWidget(
                  onPress: () => removeItems(null),
                  title: 'Устгах (${picks.length})',
                  color: AppTheme.red,
                  hasIcon: false,
                  isLoading: isLoading,
                ).padding(bottom: padding.bottom, horizontal: 20),
            ],
          ).padding(top: 30),
        ),
      ),
    );
  }
}
