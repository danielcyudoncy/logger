// routes/app_pages.dart
import 'package:get/get.dart';
import 'package:logger/views/auth/login_page.dart';
import 'package:logger/views/auth/register_page.dart';
import 'package:logger/views/home/admin_home_page.dart';
import 'package:logger/views/home/assignment_editor_home.dart';
import 'package:logger/views/home/cameraman_home_page.dart';
import 'package:logger/views/home/head_of_depatment_home_page.dart';
import 'package:logger/views/home/reporter_home_page.dart';
import 'package:logger/views/home/user_management_page.dart';
import 'package:logger/views/splash/splash_screen.dart';
import 'package:logger/views/tasks/create_task_page.dart';
import 'package:logger/views/tasks/edit_task_page.dart' as tasks;
import 'app_routes.dart'; // Import the Routes class

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () =>  SplashScreen(),
    ),
    GetPage(
      name: Routes.login,
      page: () =>  const LoginPage(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: Routes.adminHome,
      page: () => const AdminHomePage(),
    ),
    GetPage(
      name: Routes.assignmentEditorHome,
      page: () => const AssignmentEditorHomePage(),
    ),
    GetPage(
      name: Routes.cameramanHome,
      page: () => const CameramanHomePage(),
    ),
    GetPage(
      name: Routes.headOfDepartmentHome,
      page: () => const HeadOfDepartmentHomePage(),
    ),
    GetPage(
      name: Routes.createTask,
      page: () =>  const CreateTaskPage(),
    ),
    GetPage(
      name: Routes.userManagement,
      page: () =>  const UserManagementPage(),
    ),
    GetPage(
      name: Routes.editTask,
      page: () =>
          const tasks.EditTaskPage(), // ✅ Pass Get.arguments inside EditTaskPage
    ),
    GetPage(
      name: Routes.reporterHome,
      page: () =>  const ReporterHomePage(),
    ),
  ];
}
