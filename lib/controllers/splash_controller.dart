// controllers/splash_controller.dart
import 'package:get/get.dart';
import '../models/user_model.dart'; // Fixed import path
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
      _navigateToHomePage(); // Navigate based on role
    } else {
      Get.offAllNamed(Routes.login); // Redirect to Login screen
    }
  }

  void _navigateToHomePage() {
    final user = authController.user.value;
    if (user == null) {
      Get.offAllNamed(Routes.login);
      return;
    }

    // ✅ Navigate users to their specific home page based on role
    switch (user.role) {
      case UserRole.admin:
        Get.offAllNamed(Routes.adminHome);
        break;
      case UserRole.assignmentEditor:
        Get.offAllNamed(Routes.assignmentEditorHome);
        break;
      case UserRole.cameraman:
        Get.offAllNamed(Routes.cameramanHome);
        break;
      case UserRole.reporter:
        Get.offAllNamed(Routes.reporterHome);
        break;
      case UserRole.headOfDepartment:
        Get.offAllNamed(Routes.headOfDepartmentHome);
        break;
      default:
        Get.offAllNamed(Routes.login);
    }
  }
}
