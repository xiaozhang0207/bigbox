import 'package:bigbox/domain/models/order_model.dart';
import 'package:bigbox/screens/add_page_screen.dart';
import 'package:bigbox/screens/auth/auth_screen.dart';
import 'package:bigbox/screens/auth/login_screen.dart';
import 'package:bigbox/screens/auth/otp_screen.dart';
import 'package:bigbox/screens/auth/password_recovery_screen.dart';
import 'package:bigbox/screens/auth/register_screen.dart';
import 'package:bigbox/screens/base_address_screen.dart';
import 'package:bigbox/screens/create_password_screen.dart';
import 'package:bigbox/screens/delete_account_screen.dart';
import 'package:bigbox/screens/demo_printer.dart';
import 'package:bigbox/screens/get_page_screen.dart';
import 'package:bigbox/screens/get_pages_screen.dart';
import 'package:bigbox/screens/home/edit_item_screen.dart';
import 'package:bigbox/screens/home/main_screen.dart';
import 'package:bigbox/screens/home/register_scan_screen.dart';
import 'package:bigbox/screens/logs_screen.dart';
import 'package:bigbox/screens/notification_screen.dart';
import 'package:bigbox/screens/order_detail_screen.dart';
import 'package:bigbox/screens/profile_screen.dart';
import 'package:bigbox/screens/splash_screen.dart';
import 'package:bigbox/screens/ub_screen.dart';
import 'package:bigbox/screens/users_screen.dart';
import 'package:get/route_manager.dart';

List<GetPage> routes = [
  GetPage(name: "/splash", page: () => const SplashScreen()),
  GetPage(name: "/home", page: () => const MainScreen()),
  GetPage(name: "/auth", page: () => const AuthScreen()),
  GetPage(name: "/login", page: () => const LoginScreen()),
  GetPage(name: "/register", page: () => const RegisterScreen()),
  GetPage(
      name: "/password-recovery", page: () => const PasswordRecoveryScreen()),
  GetPage(
      name: "/otp",
      page: () => OtpScreen(
            otp: Get.arguments?[0] ?? '',
            phone: Get.arguments?[1] ?? '',
            type: Get.arguments?[2] ?? '',
          )),
  GetPage(name: "/demo-printer", page: () => DemoPrinterScreen()),
  GetPage(
      name: "/edit-order",
      page: () => EditItem(
            order: Get.arguments?[0] ?? OrderModel(),
            type: Get.arguments?[1] ?? '',
            localSetter: Get.arguments?[2] ?? () {},
          )),
  GetPage(name: "/users", page: () => const UsersScreen()),
  GetPage(name: "/logs", page: () => const LogsScreen()),
  GetPage(
      name: "/order-detail",
      page: () => OrderDetailScreen(
            id: Get.arguments?[0] ?? 0,
            localSetter: Get.arguments?[1] ?? (OrderModel order) {},
          )),
  GetPage(name: "/password", page: () => const CreatePasswordScreen()),
  GetPage(name: "/base-address", page: () => const BaseAddressScreen()),
  GetPage(
      name: "/add-page",
      page: () => AddPageScreen(
            page: Get.arguments?[0],
            localSetter: Get.arguments?[1] ?? () {},
          )),
  GetPage(name: "/pages", page: () => const GetPagesScreen()),
  GetPage(
      name: "/get-page",
      page: () => GetPageScreen(
            page: Get.arguments?[0],
          )),
  GetPage(name: "/delete-account", page: () => const DeleteAccountScreen()),
  GetPage(name: "/profile", page: () => const ProfileScreen()),
  GetPage(name: "/notifications", page: () => const NotificationScreen()),
  GetPage(name: "/register-scan", page: () => const RegisterScanScreen()),
  GetPage(name: "/in-ub", page: () => const UbScreen()),
];
