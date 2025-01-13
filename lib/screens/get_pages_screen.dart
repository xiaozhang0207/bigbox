// ignore_for_file: use_build_context_synchronously

import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/page_model.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/admin_repository.dart';
import 'package:bigbox/domain/repositories/user_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:styled_widget/styled_widget.dart';

class GetPagesScreen extends StatefulWidget {
  const GetPagesScreen({
    super.key,
  });

  @override
  State<GetPagesScreen> createState() => _GetPagesScreenState();
}

class _GetPagesScreenState extends State<GetPagesScreen> {
  bool isLoading = false;
  List<PageModel> datas = [];
  final key = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    datas = [];
    isLoading = false;
    setStates();
    fetchData();
  }

  void fetchData() async {
    if (isLoading) return;
    datas = [];
    isLoading = true;
    setStates();
    ResponseModel res = await UserRepository().getPages();
    if (res.status == 200) {
      if ((res.data ?? []).length > 0) {
        for (int i = 0; i < (res.data ?? []).length; i++) {
          datas.add(PageModel.fromJson((res.data ?? [])[i]));
          key.currentState?.insertItem(0);
        }
      }
    }
    isLoading = false;
    setStates();
  }

  void setStates() {
    if (mounted) setState(() {});
  }

  void localSetter(PageModel? page) {
    if (page == null) {
      fetchData();
    } else {
      int findIndex = datas.indexWhere((el) => el.id == page.id);
      if (findIndex > -1) {
        datas[findIndex] = page;
      }
      setStates();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final bool light = Theme.of(context).brightness == Brightness.light;
    final Size size = MediaQuery.of(context).size;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return ScafoldBuilder(
      appbar: const CustomAppBar(
        title: 'Хуудаснууд',
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
                              return GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                    '/get-page',
                                    arguments: [datas[index]],
                                  );
                                },
                                child: Slidable(
                                  key: ValueKey(index),
                                  endActionPane: ActionPane(
                                    extentRatio: .5,
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        flex: 1,
                                        onPressed: (cntxt) {
                                          Get.toNamed(
                                            '/add-page',
                                            arguments: [
                                              datas[index],
                                              localSetter,
                                            ],
                                          );
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
                                        onPressed: (cntxt) async {
                                          if (isLoading) return;
                                          isLoading = true;
                                          setStates();
                                          ResponseModel res =
                                              await AdminRepository()
                                                  .deletePage(
                                                      id: datas[index].id ?? 0);
                                          isLoading = false;
                                          setStates();
                                          if (res.status == 200) {
                                            datas.removeAt(index);
                                            key.currentState?.removeItem(
                                                index,
                                                (context, animation) =>
                                                    const SizedBox());
                                          }
                                          SnackBar snackBar = SnackBar(
                                            content: Text(res.message ??
                                                (res.status == 200
                                                    ? 'Амжилттай'
                                                    : 'Алдаа гарлаа')),
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            backgroundColor: AppTheme.primary,
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 22),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color:
                                              AppTheme.black.withOpacity(.05),
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              datas[index].type ?? '',
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(180),
                                            color: ([
                                              AppTheme.green,
                                              AppTheme.red
                                            ][(datas[index].isActive ?? false)
                                                    ? 0
                                                    : 1])
                                                .withOpacity(.5),
                                          ),
                                          child: Text(
                                            ['Идэвхтэй', 'Идэвхгүй'][
                                                (datas[index].isActive ?? false)
                                                    ? 0
                                                    : 1],
                                            style:
                                                const TextStyle(fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
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
          ButtonWidget(
            title: 'Хуудас үүсгэх',
            hasIcon: false,
            onPress: () {
              Get.toNamed(
                '/add-page',
                arguments: [
                  null,
                  localSetter,
                ],
              );
            },
            isLoading: isLoading,
          ),
        ],
      ).padding(
        horizontal: 20,
        bottom: padding.bottom + 12,
        top: 12,
      ),
    );
  }
}
