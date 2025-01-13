import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:styled_widget/styled_widget.dart';

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

class ItemList extends StatelessWidget {
  final List<OrderModel> orders;
  final int index;
  final Animation<double>? animation;
  final Function tap;
  final bool? isAdmin;
  final Function? clickItem;
  const ItemList({
    super.key,
    required this.orders,
    required this.index,
    this.animation,
    required this.tap,
    this.isAdmin,
    this.clickItem,
  });
  @override
  Widget build(BuildContext context) {
    bool light = Theme.of(context).brightness == Brightness.light;

    if ((orders.length - 1) < index) {
      return const SizedBox();
    }
    OrderModel order = orders[index];
    int type = order.type ?? 0;
    return Column(
      children: [
        if (!(isAdmin ?? false))
          sizeMake(
            index: index,
            light: light,
            child: GestureDetector(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                  left: 1,
                  right: 1,
                  top: 1,
                  bottom: 1,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: light
                      ? AppTheme.lighterGray
                      : AppTheme.black.withOpacity(.8),
                  // borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 156, 156, 156),
                      offset: Offset(0, 0),
                      blurRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(right: 10),
                          color: colors[type == 0
                              ? 0
                              : type == -1
                                  ? 1
                                  : type == 1
                                      ? 2
                                      : type == 2
                                          ? 3
                                          : 4],
                          child: Image.network(
                            tracks[type == 0
                                ? 0
                                : type == -1
                                    ? 1
                                    : type == 1
                                        ? 2
                                        : type == 2
                                            ? 3
                                            : 4],
                            width: 20,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (order.containerNo ?? '') == ''
                                  ? 'Баталгаажаагүй'
                                  : (order.containerNo ?? ''),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                            ),
                            Row(
                              children: [
                                Text(
                                  orders[index].barCode ?? '',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: colors[type == 0
                                        ? 0
                                        : type == -1
                                            ? 1
                                            : type == 1
                                                ? 2
                                                : type == 2
                                                    ? 3
                                                    : 4],
                                  ),
                                  child: Text(
                                    type == 0
                                        ? 'Хүлээгдэж буй'
                                        : type == 1
                                            ? 'Эрээнд ирсэн'
                                            : type == 2
                                                ? 'Улаанбаатарт ирсэн'
                                                : type == 3
                                                    ? 'Хүргэлтэнд бүртгүүлсэн'
                                                    : 'Хүлээн авсан',
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ).padding(top: 4),
                          ],
                        ),
                      ],
                    ).expanded(),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (isAdmin ?? false)
          Slidable(
            key: ValueKey(index),
            endActionPane: ActionPane(
              extentRatio: 1,
              motion: const ScrollMotion(),
              children: [
                ...List.generate(5, (ind) {
                  return SlidableAction(
                    flex: 1,
                    onPressed: (cntxt) {
                      if (clickItem == null) {
                        return;
                      }
                      clickItem!(index, ind);
                    },
                    backgroundColor: [
                      light ? AppTheme.green : AppTheme.green.withOpacity(.3),
                      light ? AppTheme.orange : AppTheme.orange.withOpacity(.3),
                      light ? AppTheme.yellow : AppTheme.yellow.withOpacity(.3),
                      light ? AppTheme.red : AppTheme.red.withOpacity(.3),
                      light
                          ? AppTheme.primary
                          : AppTheme.primary.withOpacity(.3),
                    ][ind],
                    foregroundColor: Colors.white,
                    icon: [
                      Icons.qr_code,
                      Icons.account_balance_wallet_rounded,
                      Icons.edit,
                      Icons.toggle_off,
                      Icons.pin_drop_outlined,
                    ][ind],
                    // borderRadius: BorderRadius.circular(12),
                    label: [
                      'QR',
                      'Price',
                      'Name',
                      'Status',
                      'Address',
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
            child: sizeMake(
              index: index,
              light: light,
              animation: animation,
              child: GestureDetector(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    left: 1,
                    right: 1,
                    top: 1,
                    bottom: 1,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: light
                        ? AppTheme.lighterGray
                        : AppTheme.black.withOpacity(.8),
                    // borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 156, 156, 156),
                        offset: Offset(0, 0),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(right: 10),
                            color: colors[type == 0
                                ? 0
                                : type == -1
                                    ? 1
                                    : type == 1
                                        ? 2
                                        : type == 2
                                            ? 3
                                            : 4],
                            child: Image.network(
                              tracks[type == 0
                                  ? 0
                                  : type == -1
                                      ? 1
                                      : type == 1
                                          ? 2
                                          : type == 2
                                              ? 3
                                              : 4],
                              width: 20,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (order.containerNo ?? '') == ''
                                    ? 'Баталгаажаагүй'
                                    : (order.containerNo ?? ''),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                              ),
                              Row(
                                children: [
                                  Text(
                                    orders[index].barCode ?? '',
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    margin: const EdgeInsets.only(left: 6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: colors[type == 0
                                          ? 0
                                          : type == -1
                                              ? 1
                                              : type == 1
                                                  ? 2
                                                  : type == 2
                                                      ? 3
                                                      : 4],
                                    ),
                                    child: Text(
                                      type == 0
                                          ? 'Хүлээгдэж буй'
                                          : type == 1
                                              ? 'Эрээнд ирсэн'
                                              : type == 2
                                                  ? 'Улаанбаатарт ирсэн'
                                                  : type == 3
                                                      ? 'Хүргэлтэнд бүртгүүлсэн'
                                                      : 'Хүлээн авсан',
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ).padding(top: 4),
                            ],
                          ),
                        ],
                      ).expanded(),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 14),
      ],
    );
  }
}

Widget sizeMake(
    {Animation<double>? animation,
    required int index,
    required bool light,
    required Widget child}) {
  if (animation == null) {
    return child;
  }
  return SizeTransition(
    sizeFactor: animation,
    child: SizeTransition(
      sizeFactor: animation,
      key: ValueKey(index),
      child: child,
    ),
  );
}
