import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:get/get.dart';

void showToast(
  String txt,
  AnimatedSnackBarType? type,
) {
  if (Get.key.currentContext != null) {
    AnimatedSnackBar.material(
      txt,
      type: type ?? AnimatedSnackBarType.info,
      duration: const Duration(seconds: 2),
    ).show(Get.key.currentContext!);
  }
}
