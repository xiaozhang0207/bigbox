// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/global.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/domain/models/order_model.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:bigbox/domain/repositories/admin_repository.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/input.dart';
// import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:styled_widget/styled_widget.dart';

class RegisterScanScreen extends StatefulWidget {
  const RegisterScanScreen({super.key});

  @override
  State<RegisterScanScreen> createState() => _RegisterScanScreenState();
}

class _RegisterScanScreenState extends State<RegisterScanScreen>
    with WidgetsBindingObserver {
  String rnumber = '';
  TextEditingController code = TextEditingController();
  TextEditingController container = TextEditingController();
  TextEditingController z = TextEditingController(text: '001');
  // PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<BluetoothDevice> devices = [];
  BluetoothDevice? pickedDevice;

  bool isConnected = false;
  bool isScanned = false;
  bool isLoading = false;
  bool btnLoading = false;

  String selectedPrinter = '';

  FocusNode codeFocus = FocusNode();
  FocusNode containerFocus = FocusNode();

  bool cameraAccepted = false;

  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 500,
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

  @override
  void initState() {
    super.initState();
    fetchData();
    checkPermission();
    WidgetsBinding.instance.addObserver(this);
    unawaited(controller.start());
  }

  void _handleBarcode(String code) async {
    if (code.isEmpty || btnLoading) {
      return;
    }
    btnLoading = true;
    setStates();
    await controller.stop();
    OrderModel? order = await fetchItem(code);
    if (order == null) {
      SnackBar snackBar = const SnackBar(
        content: Text('Бүртгэл олдсонгүй!'),
        duration: Duration(milliseconds: 400),
        backgroundColor: AppTheme.primary,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      await updateData(order);
      await printTicket(order);
      int n = int.parse(container.text);
      rnumber = rn();
      container.text = '${n + 1}';
    }
    setStates();
    await Future.delayed(const Duration(seconds: 1), () {
      btnLoading = false;
      setStates();
      unawaited(controller.start());
    });
  }

  void fetchData() async {
    rnumber = rn();
    code.clear();
    container.clear();
    cameraAccepted = false;
    setStates();

    bool isPermittedBluetooth = await Permission.bluetooth.isGranted;
    if (!isPermittedBluetooth) {
      await Permission.bluetooth.request();
    } else {
      await BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 10));
      BluetoothPrintPlus.scanResults.listen((event) {
        if (mounted) {
          setState(() {
            devices = event;
            if (!isConnected && printerSdk != '' && devices.isNotEmpty) {
              int findIndex = devices.indexWhere((item) => item.address == printerSdk);
              print(devices);
              if (findIndex < 0) {
                isConnected = false;
                printerSdk = '';
                selectedPrinter = '';
              } else {
                selectedPrinter = devices[findIndex].address ?? '';
                isConnected = true;
                pickedDevice = devices[findIndex];
              }
            }
          });
        }
         setStates();
      },onError:(error){
        // _showAlert(context, 'error: $error');
      });
      isLoading = true;
      setStates();
    }
  }
  
  /// Prints a ticket with the specified content including price, phone number, and coordinates.
  /// 
  /// This function constructs a CPCL command to print a ticket with various details.
  /// It handles the command creation, formatting, and sending to the printer.
  /// 
  /// Parameters:
  /// - [price]: The price to be printed on the ticket.
  /// - [phone]: The phone number to be printed on the ticket.
  /// - [x]: The x-coordinate to be formatted and printed.
  /// - [y]: The y-coordinate to be formatted and printed.
  /// - [zIndex]: The y-coordinate to be formatted and code.
  /// 
  /// The function checks if the button is already loading to prevent duplicate actions.
  /// It formats the coordinates, constructs the CPCL command, and sends it to the printer.
  /// If an error occurs during the process, it catches the exception and ensures the button
  /// loading state is reset. The function also increments a counter and updates the UI state.
  Future<void> printTicketWithContent(String price, String phone, String x, String y, String? zIndex) async {
    try {
      if (btnLoading) {
        return;
      }
      btnLoading = true;
      setStates();
      final cpclCommand = CpclCommand();
      await cpclCommand.cleanCommand();
      await cpclCommand.size(width: 600, height: 400);
      await cpclCommand.text(
        content: 'phone:$phone',
        x: 5,
        y: 10,
        xMulti: 2,
        yMulti: 2,
      );

      String formattedX = x.padLeft(3, '0');
      String formattedY = y.padLeft(3, '0');

      await cpclCommand.text(
        content: '$formattedX-$formattedY-',
        x: 50,
        y: 120,
        xMulti: 2,
        yMulti: 2,
      );
      if(zIndex != null) z.text = zIndex;
      await cpclCommand.text(
        content: z.text,
        x: 230,
        y: 100,
        xMulti: 4,
        yMulti: 4, 
        rotation: Rotation.r_270,
      );
      final now = DateTime.now();
      final formattedDate = DateFormat('MM/dd').format(now);
      await cpclCommand.text(
        content: 'date:$formattedDate',
        x: 5,
        y: 235,
        xMulti: 2,
        yMulti: 2,
      );
      await cpclCommand.text(
        content: 'price:$price',
        x: 220,
        y: 235,
        xMulti: 2,
        yMulti: 2,
      );

      await cpclCommand.print();
      final cmd = await cpclCommand.getCommand();
      if (cmd == null) return;
      await BluetoothPrintPlus.write(cmd);
      btnLoading = false;
      setStates();
    } catch (e) {
      // _showAlert(context, '$e');
    } finally {
      btnLoading = false;
      z.text = (int.parse(z.text) + 1).toString();
      unFocus();
      setStates();
    }
  }


  String rn() {
    var rng = Random();
    var code = rng.nextInt(900000) + 100000;
    return code.toString().substring(0, 4);
  }

  void unFocus() {
    if (codeFocus.hasFocus) {
      codeFocus.unfocus();
    }
    if (containerFocus.hasFocus) {
      containerFocus.unfocus();
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
        break;
      case AppLifecycleState.inactive:
        checkPermission();
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

  Future startScan() async {
    bool isPermittedBluetooth = await Permission.bluetooth.isGranted;
    if (isPermittedBluetooth && !isScanned) {
      devices = [];
      BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 4));
      isScanned = true;
      setStates();
    }
  }

  void setStates() {
    if (mounted) setState(() {});
  }

  // Future<List<int>> receiptPrint(
  //   PaperSize paper,
  //   CapabilityProfile profile,
  //   OrderModel order,
  // ) async {
  //   final Generator ticket = Generator(paper, profile);
  //   List<int> bytes = [];
  //   // PC857
  //   bytes += ticket.setGlobalCodeTable('PC857');
  //   // bytes += ticket.setGlobalCodeTable('CP1257');
  //   bytes += ticket.text(
  //     DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
  //     styles: const PosStyles(
  //       align: PosAlign.center,
  //       width: PosTextSize.size1,
  //       fontType: PosFontType.fontB,
  //     ),
  //     containsChinese: false,
  //   );
  //   bytes += ticket.hr(len: 36);
  //   bytes += ticket.emptyLines(2);

  //   bytes += ticket.text(
  //     'TEL: +976 ${order.phone}',
  //     styles: const PosStyles(
  //       align: PosAlign.center,
  //       height: PosTextSize.size1,
  //       width: PosTextSize.size1,
  //       bold: true,
  //       fontType: PosFontType.fontB,
  //     ),
  //     containsChinese: false,
  //   );
  //   bytes += ticket.text(
  //     'No: ${'${code.text}-${container.text}-$rnumber'}',
  //     styles: const PosStyles(
  //       align: PosAlign.center,
  //       height: PosTextSize.size8,
  //       width: PosTextSize.size8,
  //       fontType: PosFontType.fontB,
  //     ),
  //     containsChinese: true,
  //   );
  //   bytes += ticket.emptyLines(2);
  //   bytes += ticket.hr(len: 36);
  //   bytes += ticket.text(
  //     'BIGBOX Cargo',
  //     styles: const PosStyles(
  //       align: PosAlign.right,
  //       height: PosTextSize.size1,
  //       width: PosTextSize.size8,
  //       fontType: PosFontType.fontB,
  //     ),
  //     containsChinese: false,
  //   );
  //   bytes += ticket.emptyLines(9);
  //   ticket.feed(0);
  //   ticket.cut();
  //   return bytes;
  // }

  // Future<List<int>> blankReciept(
  //   PaperSize paper,
  //   CapabilityProfile profile,
  //   int line,
  // ) async {
  //   final Generator ticket = Generator(paper, profile);
  //   List<int> bytes = [];
  //   // PC857
  //   bytes += ticket.setGlobalCodeTable('PC857');
  //   bytes += ticket.emptyLines(line);
  //   ticket.feed(0);
  //   ticket.cut();
  //   return bytes;
  // }

  Future<void> printTicket(OrderModel order) async {
    if (btnLoading) {
      return;
    }
    // const PaperSize paper = PaperSize.mm58;
    // // TP806L
    // // XP-N160I
    // final profile = await CapabilityProfile.load(name: 'TP806L');

    // await printerManager.printTicket((await receiptPrint(
    //   paper,
    //   profile,
    //   order,
    // )));
  }

  // Future<void> blank({int? line}) async {
  //   if (btnLoading) {
  //     return;
  //   }
  //   const PaperSize paper = PaperSize.mm58;
  //   // TP806L
  //   // XP-N160I
  //   final profile = await CapabilityProfile.load(name: 'TP806L');

  //   await printerManager.printTicket((await blankReciept(
  //     paper,
  //     profile,
  //     line ?? 1,
  //   )));
  //   setStates();
  // }

  Future<OrderModel?> fetchItem(String qry) async {
    if (qry == '') {
      return null;
    }
    ResponseModel res = await AdminRepository().searchByBarcode(
      token: qry,
    );
    await Future.delayed(const Duration(seconds: 1), () {
      btnLoading = false;
      setStates();
    });
    List<OrderModel> tmps = [];
    for (int i = 0; i < res.data.length; i++) {
      tmps.add(OrderModel.fromJson(res.data[i]));
    }
    if (tmps.isEmpty) {
      return null;
    } else {
      return tmps[0];
    }
  }

  Future<void> updateData(OrderModel data) async {
    if (data.id == 0 || btnLoading) {
      return;
    }
    ResponseModel res = await AdminRepository().updateOrder(
      id: data.id!,
      barcode: data.barCode!,
      phone: data.phone ?? '',
      title: data.title ?? '',
      type: data.type ?? 0,
      containerNo: '${code.text}-${container.text}-$rnumber',
      price: ((data.price ?? 0) * 1.0).toInt(),
      deliveryAddress: data.deliveryAddress ?? '',
    );
    SnackBar snackBar = SnackBar(
      content: Text(
          res.message ?? (res.status == 200 ? 'Амжилттай' : 'Алдаа гарлаа')),
      duration: const Duration(milliseconds: 400),
      backgroundColor: AppTheme.primary,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Future<void> dispose() async {
    unFocus();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    await controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final bottomCenterOffset =
        Offset(0, size.height * 0.55 // Дэлгэцийн доод 25% дээр төвлөрөх
            );

    final scanWindow = Rect.fromCenter(
      center: Offset(
        MediaQuery.of(context).size.width / 2, // Дэлгэцийн өргөний төв
        bottomCenterOffset.dy, // Дэл��эцийн доод 25% төв
      ),
      width: 200,
      height: 100,
    );
    return GestureDetector(
      onTap: () => unFocus(),
      child: ScafoldBuilder(
        appbar: CustomAppBar(
          title: 'Улаанбаатарт бүртгэх',
          isCamera: true,
          actions: [
            GestureDetector(
              onTap: () {
                Get.toNamed('/demo-printer')?.then((e) async {
                  isConnected = false;
                  setStates();
                  if (!isConnected && printerSdk != '' && devices.isNotEmpty) {
                    int findIndex = devices
                        .indexWhere((item) => item.address == printerSdk);
                    if (findIndex < 0) {
                      isConnected = false;
                      printerSdk = '';
                      selectedPrinter = '';
                    } else {
                      selectedPrinter = devices[findIndex].address ?? '';
                      isConnected = true;
                      pickedDevice = devices[findIndex];
                    }
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(
                  Icons.print,
                  size: 24,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        child: Stack(
          children: [
            Stack(
              children: [
                if (code.text != '' && container.text != '' && isConnected)
                  Container(
                    width: size.width,
                    height: size.height,
                    // width: size.width,
                    // height: 300,
                    color: AppTheme.light,
                    child: MobileScanner(
                      fit: BoxFit.cover,
                      scanWindow: scanWindow,
                      controller: controller,
                      onDetect: (barcodes) {
                        _handleBarcode(barcodes.barcodes[0].displayValue ?? '');
                      },
                      overlayBuilder: (context, constraints) {
                        final screenHeight = constraints.maxHeight;
                        final overlayOffset = screenHeight *
                            0.65; // Дэлгэцийн доод 25%-д байрлуулах

                        return Positioned(
                          top: overlayOffset -
                              50, // Контейнерийн өндөр (100) таллаж байрлуулах
                          left: (constraints.maxWidth - 200) /
                              2, // Контейнерийн өргөнийг төвлөрүүлэх
                          child: Container(
                            width: 200,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                width: 4,
                                color: AppTheme.primary, // Хүрээний өнгө
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // child: AiBarcodeScanner(
                    //   appBarBuilder: (context, controller) {
                    //     return const CustomAppBar(isCamera: true);
                    //   },
                    //   bottomSheetBuilder: (context, controller) {
                    //     return const SizedBox();
                    //   },
                    //   hideGalleryButton: true,
                    //   cutOutWidth: size.width * .8,
                    //   cutOutHeight: 200,
                    //   fit: BoxFit.cover,
                    //   cutOutSize: 0,
                    //   cutOutBottomOffset: 0,
                    //   showError: false,
                    //   showSuccess: false,
                    //   // scanWindow: Rect.fromCenter(
                    //   //   center: const Offset(0, 0),
                    //   //   width: size.width,
                    //   //   height: size.height,
                    //   // ),
                    //   controller: MobileScannerController(
                    //     detectionSpeed: DetectionSpeed.unrestricted,
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
                    //     if (btnLoading) {
                    //       return;
                    //     }
                    //     String code = capture.barcodes.first.rawValue ?? '';
                    //     OrderModel? order = await fetchItem(code);
                    //     if (order == null) {
                    //       SnackBar snackBar = const SnackBar(
                    //         content: Text('Бүртгэл олдсонгүй!'),
                    //         duration: Duration(milliseconds: 400),
                    //         backgroundColor: AppTheme.primary,
                    //       );
                    //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    //     } else {
                    //       await updateData(order);
                    //       await printTicket(order);
                    //       int n = int.parse(container.text);
                    //       rnumber = rn();
                    //       container.text = '${n + 1}';
                    //     }
                    //     setStates();
                    //     await Future.delayed(const Duration(seconds: 1), () {
                    //       btnLoading = false;
                    //       setStates();
                    //     });
                    //   },
                    // ),
                  ),
                if (btnLoading)
                  Container(
                    width: size.width,
                    height: size.height,
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
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  color: AppTheme.light,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bluethooth төхөөрөмж:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(pickedDevice?.name ?? 'Холбогдоогүй'),
                        ],
                      ).padding(horizontal: 20, vertical: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            code.text == '' ? 'XX' : code.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            '-',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            container.text == '' ? 'XX' : container.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            '-',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            rnumber,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ).padding(top: 20, bottom: 20),
                      InputWidget(
                        controller: code,
                        focus: codeFocus,
                        hasIcon: false,
                        lbl: 'Агуулхын дугаар',
                        placeholder: 'Агуулхын дугаар',
                        setState: setStates,
                        type: TextInputType.number,
                      ).padding(horizontal: 20),
                      InputWidget(
                        controller: container,
                        focus: containerFocus,
                        hasIcon: false,
                        lbl: 'Эгнээ дугаар',
                        placeholder: 'Эгнээ дугаар',
                        setState: setStates,
                        type: TextInputType.number,
                      ).padding(top: 20, horizontal: 20, bottom: 20),
                    ],
                  ),
                ),
                // if (isConnected)
                //   Container(
                //     color: AppTheme.light,
                //     child: ButtonWidget(
                //       title: 'Blank',
                //       hasIcon: false,
                //       onPress: () {
                //         blank(line: 5);
                //       },
                //       onLong: () {
                //         blank(line: 5);
                //       },
                //     ).padding(horizontal: 20, bottom: 40, top: 12),
                //   ),
                // if (!isConnected)
                Container(
                  color: AppTheme.light,
                  child: ButtonWidget(
                    title: 'Төхөөрөмж холбох',
                    hasIcon: false,
                    onPress: () async {
                      // Get.toNamed('/demo-printer')?.then((e) async {
                      //   isConnected = false;
                      //   setStates();
                      //   if (!isConnected &&
                      //       printerSdk != '' &&
                      //       devices.isNotEmpty) {
                      //     int findIndex = devices
                      //         .indexWhere((item) => item.address == printerSdk);
                      //     if (findIndex < 0) {
                      //       isConnected = false;
                      //       printerSdk = '';
                      //       selectedPrinter = '';
                      //     } else {
                      //       selectedPrinter = devices[findIndex].address ?? '';
                      //       isConnected = true;
                      //       
                      //     }
                      //   }
                      // });
                      int findIndex = devices.indexWhere((item) => item.address == printerSdk);
                      pickedDevice = devices[findIndex];
                      await printTicketWithContent(
                        '10000',
                        '99999999',
                        '100',
                        '100',
                      );
                    },
                  ).padding(horizontal: 20, bottom: 40, top: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
