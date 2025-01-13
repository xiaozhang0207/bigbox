import 'dart:async';
import 'dart:typed_data';

import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/configs/global.dart';
import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:bigbox/shared/button.dart';
import 'package:bigbox/shared/widget/global_loader.dart';
import 'package:charset_converter/charset_converter.dart';
// import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:styled_widget/styled_widget.dart';

class DemoPrinterScreen extends StatefulWidget {
  const DemoPrinterScreen({super.key});

  @override
  State<DemoPrinterScreen> createState() => _DemoPrinterScreenState();
}

class _DemoPrinterScreenState extends State<DemoPrinterScreen> {
  bool isConnected = false;
  bool isScanned = false;
  bool isLoading = false;
  bool btnLoading = false;
  List<BluetoothDevice> devicesList = [];
  String tips = 'no device connect';
  GlobalKey globalKey = GlobalKey();
  String selectedPrinter = '';
  BluetoothDevice? pickedDevice;

  // PrinterBluetoothManager printerManager = PrinterBluetoothManager();

  @override
  void initState() {
    super.initState();
    selectedPrinter = "";
    isLoading = false;
    btnLoading = false;
    setStates();
    fetchDevices();
  }

  void fetchDevices() async {
    bool isPermittedBluetooth = await Permission.bluetooth.isGranted;

    if (!isPermittedBluetooth) {
      await Permission.bluetooth.request();
    } else {
      await BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 10));
      BluetoothPrintPlus.scanResults.listen((event) {
        if (mounted) {
          setState(() {
            devicesList = event;
            if (!isConnected && printerSdk != '' && devicesList.isNotEmpty) {
              int findIndex = devicesList.indexWhere((item) => item.address == printerSdk);
              if (findIndex < 0) {
                isConnected = false;
                printerSdk = '';
                selectedPrinter = '';
              } else {
                selectedPrinter = devicesList[findIndex].address ?? '';
                isConnected = true;
                pickedDevice = devicesList[findIndex];
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
    isLoading = false;
    setStates();
  }

  Future<void> startScan() async {
    bool isPermittedBluetooth = await Permission.bluetooth.isGranted;
    if (isPermittedBluetooth && !isScanned) {
      setState(() {
        devicesList = [];
      });
      BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 4));
      isScanned = true;
      setStates();
    }
  }

  void setStates() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    BluetoothPrintPlus.stopScan();
    super.dispose();
  }

  Future<Uint8List> getEncoded(String text) async {
    final encoded = await CharsetConverter.encode("CP866", text);
    return encoded;
  }

  // Future<List<int>> demoReceipt(
  //     PaperSize paper, CapabilityProfile profile) async {
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
  //     'TEL: +976 89920322',
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
  //     'No: 00-01-1234',
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

  Future<void> printTicket() async {
    if (btnLoading) {
      return;
    }
    btnLoading = true;
    setStates();
    // const PaperSize paper = PaperSize.mm58;
    // // TP806L
    // // XP-N160I
    // final profile = await CapabilityProfile.load(name: 'TP806L');

    // final PosPrintResult res =
    //     await printerManager.printTicket((await demoReceipt(paper, profile)));
    // print('res: ${res.msg}');
    btnLoading = false;
    setStates();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        ScafoldBuilder(
          appbar: CustomAppBar(
            title: 'Принтер тохиргоо(${devicesList.length})',
          ),
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (devicesList.isNotEmpty)
                  Container(
                    // alignment: const Alignment(0, 0),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.primary,
                    ),
                    child: Text(
                      selectedPrinter == '' ||
                              devicesList.isEmpty ||
                              devicesList.indexWhere((item) =>
                                      item.address == selectedPrinter) <
                                  0
                          ? 'Төхөөрөмж сонгох'
                          : devicesList[devicesList.indexWhere((item) =>
                                      item.address == selectedPrinter)]
                                  .name ??
                              '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.light,
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...List.generate(devicesList.length, (index) {
                          return Slidable(
                            key: ValueKey(index),
                            endActionPane: ActionPane(
                              extentRatio: .25,
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  flex: 1,
                                  onPressed: (cntxt) async {
                                    if (devicesList[index].address ==
                                        selectedPrinter) {
                                      return;
                                    }
                                    isLoading = false;
                                    setStates();
                                    await BluetoothPrintPlus.connect(devicesList[index]);
                                    selectedPrinter = devicesList[index].address;
                                    printerSdk = selectedPrinter;
                                    pickedDevice = devicesList[index];
                                    isLoading = false;
                                    isConnected = true;
                                    setStates();
                                  },
                                  backgroundColor: AppTheme.green,
                                  foregroundColor: Colors.white,
                                  icon: Icons.check,
                                  // borderRadius: BorderRadius.circular(12),
                                  label: 'Холбох',
                                  spacing: 4,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 0,
                                  ),
                                ),
                              ],
                            ),
                            child: Container(
                              width: size.width,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        devicesList[index].name ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        devicesList[index].address ?? '',
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      ).padding(top: 8),
                                    ],
                                  ),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: selectedPrinter ==
                                              devicesList[index].address
                                          ? AppTheme.primary
                                          : AppTheme.primary.withOpacity(.15),
                                      borderRadius: BorderRadius.circular(180),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: selectedPrinter ==
                                              devicesList[index].address
                                          ? AppTheme.light
                                          : AppTheme.black.withOpacity(.5),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).padding(bottom: 20);
                        }),
                      ],
                    ),
                  ),
                ),
                if (!isLoading && (selectedPrinter != '' || !isScanned))
                  ButtonWidget(
                    hasIcon: false,
                    onPress: () async {
                      if (isConnected) {
                        if (selectedPrinter == '') {
                          return;
                        } else {}
                        printTicket();
                      } else {
                        startScan();
                      }
                    },
                    disable: !isConnected ? false : selectedPrinter == '',
                    isLoading: btnLoading,
                    title:
                        isConnected ? 'Тест хуудас хэвлэх' : 'Төхөөрөмж хайх',
                  ).padding(horizontal: 20, bottom: 30, top: 20),
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            // alignment: const Alignment(0, 0),
            color: Colors.black.withOpacity(.4),
            child: const GlobalLoader(),
          ),
      ],
    );
  }
}
