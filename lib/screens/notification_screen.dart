import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/notification_model.dart';
import 'package:bigbox/domain/models/pagination_model.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/user_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/widget/primary_logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:styled_widget/styled_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  TextEditingController qry = TextEditingController();
  FocusNode qfocus = FocusNode();
  bool isLoading = false;
  final ScrollController xcrollController = ScrollController();
  int page = 1;
  int limit = 10;
  PaginationModel pagination = PaginationModel.fromJson({});
  List<NotificationModel> datas = [];

  void setStates() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
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
    }
    if (!isReload &&
        (isLoading ||
            (page > 1 && page >= ((pagination.pageCount ?? 1) + 1)) ||
            page == 0)) {
      return;
    }
    isLoading = true;
    setStates();
    ResponseModel res = await UserRepository().getNotificationList(
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
              (element) => element.id == (res.data['data'] ?? [])[i]['id']);
          if (findIndex < 0) {
            datas.add(NotificationModel.fromJson((res.data['data'] ?? [])[i]));
          } else {
            datas[findIndex] =
                NotificationModel.fromJson((res.data['data'] ?? [])[i]);
          }
        }
      }
    }
    isLoading = false;
    setStates();
  }

  @override
  void dispose() {
    super.dispose();
    xcrollController.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ScafoldBuilder(
      appbar: const CustomAppBar(
        title: 'Мэдэгдэл',
        isCamera: true,
      ),
      child: SizedBox(
        child: LayoutBuilder(
          builder: (context, constraints) => RefreshIndicator(
            onRefresh: () async {
              qry.clear();
              fetchData(true);
              await Future.delayed(const Duration(seconds: 1));
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
                    controller: xcrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        children: [
                          ...List.generate(datas.length, (index) {
                            return GestureDetector(
                              onTap: () async {
                                if (!datas[index].isShow) {
                                  ResponseModel res = await UserRepository()
                                      .seenNotifications(
                                          ids: [datas[index].id]);
                                  if (res.status == 200) {
                                    datas[index].isShow = true;
                                  }
                                }
                                setStates();
                                if ((datas[index].oId ?? 0) > 0) {
                                  Get.toNamed(
                                    '/order-detail',
                                    arguments: [
                                      datas[index].id,
                                      null,
                                    ],
                                  );
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.zero,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 1,
                                        color: AppTheme.lighterGray,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const PrimaryLogo(
                                            disableTxt: true,
                                          ).width(22).padding(
                                                left: 20,
                                                right: 12,
                                              ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                datas[index].type,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                datas[index].body,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('yyyy-MM-dd HH:mm')
                                                    .format(
                                                        datas[index].createdAt),
                                                textAlign: TextAlign.end,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ).expanded(),
                                        ],
                                      ).expanded(),
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.only(
                                          right: 20,
                                          left: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: datas[index].isShow
                                              ? AppTheme.green
                                              : AppTheme.red,
                                          borderRadius:
                                              BorderRadius.circular(180),
                                        ),
                                      ),
                                    ],
                                  ).padding(vertical: 14),
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
    );
  }
}
