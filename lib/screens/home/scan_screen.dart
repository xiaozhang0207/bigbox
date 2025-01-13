// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/order_model.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/admin_repository.dart';
import 'package:bigbox/screens/home/add_item_screen.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanScreen extends StatefulWidget {
  final EdgeInsets padding;
  final Size size;
  final int type;
  final bool? isSearch;
  final Function? onFinish;
  final Function? callback;
  const ScanScreen({
    super.key,
    required this.padding,
    required this.size,
    required this.type,
    this.isSearch,
    this.onFinish,
    this.callback,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  int selectedIndex = 2;
  bool hasLight = false;
  bool isLoading = false;
  bool cameraAccepted = false;
  bool isLocked = false;
  final MobileScannerController controller = MobileScannerController(
    formats: const [
      BarcodeFormat.aztec,
      BarcodeFormat.codabar,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.itf,
      BarcodeFormat.qrCode,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );
  StreamSubscription<Object?>? _subscription;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = false;
      hasLight = false;
      cameraAccepted = false;
      isLocked = false;
    });
    checkPermission();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen(_handleBarcode);

    // Finally, start the scanner itself.
    unawaited(controller.start());
  }

  void _handleBarcode(BarcodeCapture value) async {
    if (value.barcodes.isNotEmpty) {
      String scannedValue = value.barcodes[0].displayValue ?? '';
      if (scannedValue != '') {
        if (isLoading || scannedValue == '') return;
        setState(() {
          isLoading = true;
        });
        await controller.stop();
        ResponseModel res = await AdminRepository().searchByBarcode(
          token: scannedValue,
        );
        List<OrderModel> tmps = [];
        for (int i = 0; i < res.data.length; i++) {
          tmps.add(OrderModel.fromJson(res.data[i]));
        }
        int findIndex = tmps.indexWhere((e) => e.barCode == scannedValue);
        if (widget.type == 0 && findIndex > -1 && !(widget.isSearch ?? false)) {
          showToast('Бүртгэлтэй бараа байна.', AnimatedSnackBarType.warning);
          setState(() {
            isLoading = false;
          });
          unawaited(controller.start());
          return;
        }
        if (findIndex > -1) {
          if (widget.type == 1) {
            if ((tmps[findIndex].type ?? 0) != 0) {
              String sms = findIndex < 0
                  ? '"Хүлээгдэж буй" төлөвт тухайн захиалга олдсонгүй.'
                  : '"Хүлээгдэж буй" төлөвт тухайн захиалга олдсонгүй. Захиалгын төлөв: ${[
                      'Хүргэгдсэн',
                      'Хүлээгдэж буй',
                      'Эрээнд ирсэн',
                      'Улаанбаатар ирсэн',
                      'Захиалганд бүртгүүлсэн',
                    ][(tmps[findIndex].type ?? 0) + 1]}';
              showToast(sms, AnimatedSnackBarType.warning);
              unawaited(controller.start());
              setState(() {
                isLoading = false;
              });
              return;
            } else {
              isLoading = true;
              setStates();
              await updateData(tmps[findIndex], 1);
              await Future.delayed(const Duration(seconds: 3), () async {
                isLoading = false;
                setStates();
                unawaited(controller.start());
              });
            }
            return;
          } else if (widget.type == 2) {
            if ((tmps[findIndex].type ?? 0) != 1) {
              String sms = findIndex < 0
                  ? '"Эрээнд ирсэн" төлөвт тухайн захиалга олдсонгүй.'
                  : '"Эрээнд ирсэн" төлөвт тухайн захиалга олдсонгүй. Захиалгын төлөв: ${[
                      'Хүргэгдсэн',
                      'Хүлээгдэж буй',
                      'Эрээнд ирсэн',
                      'Улаанбаатар ирсэн',
                      'Захиалганд бүртгүүлсэн',
                    ][(tmps[findIndex].type ?? 0) + 1]}';
              showToast(sms, AnimatedSnackBarType.warning);
              unawaited(controller.start());
              setState(() {
                isLoading = false;
              });
              return;
            } else {
              isLoading = true;
              setStates();
              await updateData(tmps[findIndex], 2);
              await Future.delayed(const Duration(seconds: 1), () async {
                isLoading = false;
                setStates();
                unawaited(controller.start());
              });
            }
            return;
          } else if (widget.type == 3) {
            if ((tmps[findIndex].type ?? 0) != 2) {
              String sms = findIndex < 0
                  ? '"Улаанбаатар ирсэн" төлөвт тухайн захиалга олдсонгүй.'
                  : '"Улаанбаатар ирсэн" төлөвт тухайн захиалга олдсонгүй. Захиалгын төлөв: ${[
                      'Хүргэгдсэн',
                      'Хүлээгдэж буй',
                      'Эрээнд ирсэн',
                      'Улаанбаатар ирсэн',
                      'Захиалганд бүртгүүлсэн',
                    ][(tmps[findIndex].type ?? 0) + 1]}';
              showToast(sms, AnimatedSnackBarType.warning);
              isLoading = false;
              setStates();
              unawaited(controller.start());
              return;
            } else {
              isLoading = true;
              setStates();
              await updateData(tmps[findIndex], 3);
              await Future.delayed(const Duration(seconds: 1), () async {
                isLoading = false;
                setStates();
                unawaited(controller.start());
              });
            }
            return;
          } else if (widget.type == 4) {
            if ((tmps[findIndex].type ?? 0) != 2 &&
                (tmps[findIndex].type ?? 0) != 3) {
              String sms = findIndex < 0
                  ? '"Улаанбаатар ирсэн" төлөвт тухайн захиалга олдсонгүй.'
                  : '"Улаанбаатар ирсэн" төлөвт тухайн захиалга олдсонгүй. Захиалгын төлөв: ${[
                      'Хүргэгдсэн',
                      'Хүлээгдэж буй',
                      'Эрээнд ирсэн',
                      'Улаанбаатар ирсэн',
                      'Захиалганд бүртгүүлсэн',
                    ][(tmps[findIndex].type ?? 0) + 1]}';
              showToast(sms, AnimatedSnackBarType.warning);
              isLoading = false;
              setStates();
              unawaited(controller.start());
              return;
            } else {
              isLoading = true;
              setStates();
              if ((tmps[findIndex].type ?? 0) != -1) {
                await updateData(tmps[findIndex], 4);
              }
              await Future.delayed(const Duration(seconds: 1), () async {
                isLoading = false;
                setStates();
                unawaited(controller.start());
              });
            }
            return;
          }
        } else {
          if (![0, 1].contains(widget.type)) {
            showToast(
                'Идэвхтэй захиалга олдсонгүй', AnimatedSnackBarType.warning);
            await Future.delayed(const Duration(seconds: 2), () async {
              isLoading = false;
              setStates();
              unawaited(controller.start());
            });
            return;
          }
        }
        if ([0, 1].contains(widget.type)) {
          setState(() {
            isLoading = false;
            isLocked = true;
          });
          await controller.stop();
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
                padding: widget.padding,
                size: widget.size,
                barcode: scannedValue,
                data: findIndex > -1
                    ? OrderModel.fromJson(res.data[findIndex])
                    : null,
                callback: widget.callback,
              );
            },
          ).then((value) async {
            isLocked = false;
            setStates();
            unawaited(controller.start());
          });
        }
      }
    }
  }

  void checkPermission() async {
    cameraAccepted = await Permission.camera.request().isGranted;
    setStates();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        checkPermission();
        _subscription = controller.barcodes.listen(_handleBarcode);
        break;
      case AppLifecycleState.inactive:
        checkPermission();
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
        break;
      case AppLifecycleState.paused:
        checkPermission();
        break;
      case AppLifecycleState.detached:
        checkPermission();
        break;
      case AppLifecycleState.hidden:
        checkPermission();
    }
  }

  void setStates() {
    if (mounted) setState(() {});
  }

  void changeIndicator() {
    if (selectedIndex >= 3) {
      selectedIndex = 1;
    } else {
      selectedIndex += 1;
    }
    setState(() {});
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    await controller.dispose();
  }

  Future<void> updateData(OrderModel data, int n) async {
    if (data.id == 0) {
      return;
    }
    int addedType = n < 0
        ? 4
        : n > 3
            ? 4
            : n;
    ResponseModel res = await AdminRepository().updateOrder(
      id: data.id!,
      barcode: data.barCode ?? '',
      phone: data.phone ?? '',
      title: data.title ?? '',
      type: addedType,
      containerNo: data.containerNo!,
      price: ((data.price ?? 0) * 1.0).toInt(),
      deliveryAddress: data.deliveryAddress ?? '',
    );
    showToast(
        res.status == 200 ? 'Амжилттай' : 'Алдаа гарлаа',
        res.status == 200
            ? AnimatedSnackBarType.success
            : AnimatedSnackBarType.warning);
    SnackBar snackBar = SnackBar(
      content: Text(
          res.message ?? (res.status == 200 ? 'Амжилттай' : 'Алдаа гарлаа')),
      duration: const Duration(milliseconds: 400),
      backgroundColor: AppTheme.primary,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    Size size = MediaQuery.of(context).size;
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: selectedIndex == 2
          ? 200
          : selectedIndex == 1
              ? size.height
              : 200,
      height: selectedIndex == 2
          ? 100
          : selectedIndex == 1
              ? size.height
              : 200,
    );
    EdgeInsets padding = MediaQuery.of(context).padding;
    return SizedBox(
      child: !cameraAccepted
          ? Container(
              width: widget.size.width,
              padding: EdgeInsets.only(
                top: 80,
                bottom: widget.padding.bottom + 12,
                left: 20,
                right: 20,
              ),
              color: light ? AppTheme.light : AppTheme.deepDarkGray,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Камер зөвшөөрөх',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 20,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 1,
                        color: AppTheme.orange,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 32,
                          color: AppTheme.orange,
                        ).padding(right: 20),
                        RichText(
                          text: TextSpan(
                              text: 'Хэрэглэгч та цаашид ашиглах ',
                              children: const [
                                TextSpan(
                                  text: 'QR УНШИХ  ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: 'төхөөрөмж нь '),
                                TextSpan(
                                  text: 'камерний ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                    text: 'тусламжтай хийгддэг үйлдэл тул та '),
                                TextSpan(
                                  text: 'ЗӨВШӨӨРӨХ ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: 'шаардлагатай.'),
                              ],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: light
                                    ? AppTheme.black
                                    : AppTheme.lighterGray,
                              )),
                        ).expanded(),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ButtonWidget(
                        title: 'Буцах',
                        onPress: () => Get.back(),
                        hasIcon: false,
                        color: AppTheme.red,
                      ).expanded(),
                      const SizedBox(width: 20),
                      ButtonWidget(
                        title: 'Эрх тохируулах',
                        onPress: () => openAppSettings(),
                        hasIcon: false,
                      ).expanded(),
                    ],
                  ),
                ],
              ),
            )
          : isLocked
              ? const SizedBox()
              : Stack(
                  children: [
                    SizedBox(
                      width: widget.size.width,
                      height: widget.size.height,
                      child: MobileScanner(
                        fit: BoxFit.cover,
                        scanWindow: scanWindow,
                        controller: controller,
                        overlayBuilder: (context, constraints) {
                          return Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: selectedIndex == 2
                                  ? 200
                                  : selectedIndex == 1
                                      ? size.height
                                      : 200,
                              height: selectedIndex == 2
                                  ? 100
                                  : selectedIndex == 1
                                      ? size.height
                                      : 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  width: 4,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // ValueListenableBuilder(
                      //   valueListenable: controller,
                      //   builder: (context, value, child) {
                      //     if (!value.isInitialized ||
                      //         !value.isRunning ||
                      //         value.error != null) {
                      //       return const SizedBox();
                      //     }

                      //     return CustomPaint(
                      //       painter: ScannerOverlay(scanWindow: scanWindow),
                      //     );
                      //   },
                      // ),
                      // child: AiBarcodeScanner(
                      //   onDispose: () {
                      //     debugPrint('Barcode Scanner disposed!');
                      //   },
                      //   showSuccess: false,
                      //   showError: false,
                      //   bottomSheetBuilder: (context, controller) {
                      //     return const SizedBox();
                      //   },
                      //   // cutOutSize: size.width * .6,
                      //   cutOutWidth: size.width *
                      //       ([1, 2].contains(selectedIndex) ? .6 : 1),
                      //   cutOutHeight: selectedIndex == 2
                      //       ? 120
                      //       : selectedIndex == 1
                      //           ? 200
                      //           : size.height,
                      //   cutOutSize: 0,
                      //   cutOutBottomOffset: 0,
                      //   fit: BoxFit.cover,
                      //   overlayColor: const Color.fromARGB(206, 0, 0, 0),
                      //   appBarBuilder: (context, controller) {
                      //     return const CustomAppBar(isCamera: true);
                      //   },
                      //   controller: MobileScannerController(
                      //     detectionSpeed: DetectionSpeed.noDuplicates,
                      //     formats: [
                      //       BarcodeFormat.aztec,
                      //       BarcodeFormat.codabar,
                      //       BarcodeFormat.code128,
                      //       BarcodeFormat.code39,
                      //       BarcodeFormat.code93,
                      //       BarcodeFormat.ean13,
                      //       BarcodeFormat.ean8,
                      //       BarcodeFormat.itf,
                      //       BarcodeFormat.qrCode,
                      //       BarcodeFormat.upcA,
                      //       BarcodeFormat.upcE,
                      //     ],
                      //   ),
                      //   onDetect: (capture) async {
                      //     String? scannedValue =
                      //         capture.barcodes.first.rawValue;
                      //     if (scannedValue != '') {}
                      //     if (isLoading || (scannedValue ?? '') == '') return;
                      //     setState(() {
                      //       isLoading = true;
                      //     });
                      //     ResponseModel res =
                      //         await AdminRepository().searchByBarcode(
                      //       token: scannedValue!,
                      //     );
                      //     List<OrderModel> tmps = [];
                      //     for (int i = 0; i < res.data.length; i++) {
                      //       tmps.add(OrderModel.fromJson(res.data[i]));
                      //     }
                      //     int findIndex =
                      //         tmps.indexWhere((e) => e.barCode == scannedValue);
                      //     if (widget.type == 0 &&
                      //         findIndex > -1 &&
                      //         !(widget.isSearch ?? false)) {
                      //       showToast('Бүртгэлтэй бараа байна.',
                      //           AnimatedSnackBarType.warning);
                      //       return;
                      //     }
                      //     if (findIndex > -1) {
                      //       if (widget.type == 1) {
                      //         if ((tmps[findIndex].type ?? 0) != 0) {
                      //           String sms = findIndex < 0
                      //               ? '"Хүлээгдэж буй" төлөвт тухайн захиалга олдсонгүй.'
                      //               : '"Хүлээгдэж буй" төлөвт тухайн захиалга олдсонгүй. Захиалгын төлөв: ${[
                      //                   'Хүргэгдсэн',
                      //                   'Хүлээгдэж буй',
                      //                   'Эрээнд ирсэн',
                      //                   'Улаанбаатар ирсэн',
                      //                   'Захиалганд бүртгүүлсэн',
                      //                 ][(tmps[findIndex].type ?? 0) + 1]}';
                      //           showToast(sms, AnimatedSnackBarType.warning);
                      //           return;
                      //         } else {
                      //           isLoading = true;
                      //           setStates();
                      //           await updateData(tmps[findIndex], 1);
                      //           await Future.delayed(const Duration(seconds: 3),
                      //               () {
                      //             isLoading = false;
                      //             setStates();
                      //           });
                      //         }
                      //         return;
                      //       } else if (widget.type == 2) {
                      //         if ((tmps[findIndex].type ?? 0) != 1) {
                      //           String sms = findIndex < 0
                      //               ? '"Эрээнд ирсэн" төлөвт тухайн захиалга олдсонгүй.'
                      //               : '"Эрээнд ирсэн" төлөвт тухайн захиалга олдсонгүй. Захиалгын төлөв: ${[
                      //                   'Хүргэгдсэн',
                      //                   'Хүлээгдэж буй',
                      //                   'Эрээнд ирсэн',
                      //                   'Улаанбаатар ирсэн',
                      //                   'Захиалганд бүртгүүлсэн',
                      //                 ][(tmps[findIndex].type ?? 0) + 1]}';
                      //           showToast(sms, AnimatedSnackBarType.warning);
                      //           return;
                      //         } else {
                      //           isLoading = true;
                      //           setStates();
                      //           await updateData(tmps[findIndex], 2);
                      //           await Future.delayed(const Duration(seconds: 1),
                      //               () {
                      //             isLoading = false;
                      //             setStates();
                      //           });
                      //         }
                      //         return;
                      //       } else if (widget.type == 3) {
                      //         if ((tmps[findIndex].type ?? 0) != 2) {
                      //           String sms = findIndex < 0
                      //               ? '"Улаанбаатар ирсэн" төлөвт тухайн захиалга олдсонгүй.'
                      //               : '"Улаанбаатар ирсэн" төлөвт тухайн захиалга олдсонгүй. Захиалгын төлөв: ${[
                      //                   'Хүргэгдсэн',
                      //                   'Хүлээгдэж буй',
                      //                   'Эрээнд ирсэн',
                      //                   'Улаанбаатар ирсэн',
                      //                   'Захиалганд бүртгүүлсэн',
                      //                 ][(tmps[findIndex].type ?? 0) + 1]}';
                      //           showToast(sms, AnimatedSnackBarType.warning);
                      //           return;
                      //         } else {
                      //           isLoading = true;
                      //           setStates();
                      //           await updateData(tmps[findIndex], 3);
                      //           await Future.delayed(const Duration(seconds: 1),
                      //               () {
                      //             isLoading = false;
                      //             setStates();
                      //           });
                      //         }
                      //         return;
                      //       } else if (widget.type == 4) {
                      //         if ((tmps[findIndex].type ?? 0) != 2 &&
                      //             (tmps[findIndex].type ?? 0) != 3) {
                      //           String sms = findIndex < 0
                      //               ? '"Улаанбаатар ирсэн" төлөвт тухайн захиалга олдсонгүй.'
                      //               : '"Улаанбаатар ирсэн" төлөвт тухайн захиалга олдсонгүй. Захиалгын төлөв: ${[
                      //                   'Хүргэгдсэн',
                      //                   'Хүлээгдэж буй',
                      //                   'Эрээнд ирсэн',
                      //                   'Улаанбаатар ирсэн',
                      //                   'Захиалганд бүртгүүлсэн',
                      //                 ][(tmps[findIndex].type ?? 0) + 1]}';
                      //           showToast(sms, AnimatedSnackBarType.warning);
                      //           return;
                      //         } else {
                      //           isLoading = true;
                      //           setStates();
                      //           if ((tmps[findIndex].type ?? 0) != -1) {
                      //             await updateData(tmps[findIndex], 4);
                      //           }
                      //           await Future.delayed(const Duration(seconds: 1),
                      //               () {
                      //             isLoading = false;
                      //             setStates();
                      //           });
                      //         }
                      //         return;
                      //       }
                      //     } else {
                      //       if (![0, 1].contains(widget.type)) {
                      //         showToast('Идэвхтэй захиалга олдсонгүй',
                      //             AnimatedSnackBarType.warning);
                      //         await Future.delayed(const Duration(seconds: 2),
                      //             () {
                      //           isLoading = false;
                      //           setStates();
                      //         });
                      //         return;
                      //       }
                      //     }

                      //     if ((widget.isSearch ?? false)) {
                      //       Get.back();
                      //       widget.onFinish!(tmps);
                      //       return;
                      //     }
                      //     if ([0, 1].contains(widget.type)) {
                      //       setState(() {
                      //         isLoading = false;
                      //         isLocked = true;
                      //       });
                      //       showModalBottomSheet(
                      //         context: context,
                      //         isScrollControlled: true,
                      //         shape: const RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.zero,
                      //         ),
                      //         clipBehavior: Clip.antiAliasWithSaveLayer,
                      //         enableDrag: false,
                      //         builder: (context) {
                      //           return AddItemScreen(
                      //             padding: widget.padding,
                      //             size: widget.size,
                      //             barcode: scannedValue,
                      //             data: findIndex > -1
                      //                 ? OrderModel.fromJson(res.data[findIndex])
                      //                 : null,
                      //             callback: widget.callback,
                      //           );
                      //         },
                      //       ).then((value) {
                      //         isLocked = false;
                      //         setStates();
                      //       });
                      //     }
                      //   },
                      //   hideGalleryIcon: true,
                      //   hideGalleryButton: true,
                      //   validator: (p0) {
                      //     if (p0.barcodes.isEmpty) {
                      //       return false;
                      //     }
                      //     return true;
                      //   },
                      //   extendBodyBehindAppBar: true,
                      //   borderColor: AppTheme.primary,
                      //   borderWidth: 5,
                      //   borderRadius: 10,
                      // ),
                    ),
                    Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: padding.bottom + 30,
                        top: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                (widget.isSearch ?? false)
                                    ? 'Хайх'
                                    : [
                                        'Шинэ захиалга бүртгэх',
                                        'Эрээнд бүртгэх',
                                        'Улаанбаатарт бүртгэх',
                                        'Хүргэлтэнд бүртгэх',
                                        'Хүлээлгэж өгсөн',
                                      ][widget.type],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ).padding(left: 40).expanded(),
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  color: Colors.transparent,
                                  child: const Icon(Icons.close),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.back();
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
                                        padding: widget.padding,
                                        size: widget.size,
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 30),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      width: 1,
                                      color: AppTheme.lighterGray,
                                    ),
                                  ),
                                  child: const Text(
                                    'Гараар шивэх',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.lighterGray,
                                    ),
                                  ).center(),
                                ),
                              ),
                              if (!isLoading)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(),
                                    // GestureDetector(
                                    //   onTap: () {
                                    //     setState(() {
                                    //       hasLight = !hasLight;
                                    //     });
                                    //   },
                                    //   child: Icon(
                                    //     !hasLight
                                    //         ? Icons.flash_on
                                    //         : Icons.flash_off,
                                    //     size: 32,
                                    //     color: AppTheme.light,
                                    //   ),
                                    // ),
                                    GestureDetector(
                                      onTap: changeIndicator,
                                      child: Container(
                                        width: 60,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              width: 1,
                                              color: AppTheme.light,
                                            )),
                                        child: Text(
                                          selectedIndex.toString(),
                                          style: const TextStyle(
                                            color: AppTheme.light,
                                          ),
                                        ).center(),
                                      ),
                                    ),
                                    const SizedBox(),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ).padding(top: padding.top + 20),
                    ),
                    if (isLoading)
                      Container(
                        width: widget.size.width,
                        height: widget.size.height,
                        color: AppTheme.black.withOpacity(.5),
                        child: Center(
                          child: LoadingAnimationWidget.threeArchedCircle(
                            color: AppTheme.primary,
                            size: 40,
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
