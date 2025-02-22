import 'package:get/get.dart';
import '../routes/app_routes.dart';
import 'auth_controller.dart';

class SplashController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // 3-second delay
    if (authController.user.value != null) {
      Get.offAllNamed(Routes.ADMIN_HOME); // Redirect logged-in users
    } else {
      Get.offAllNamed(Routes.LOGIN); // Redirect to Login screen
    }
  }
}
