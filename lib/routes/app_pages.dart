// routes/app_pages.dart
import 'package:flutter/material.dart';
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
  static const initial = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginPage(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: Routes.ADMIN_HOME,
      page: () => AdminHomePage(),
    ),
    GetPage(
      name: Routes.ASSIGNMENT_EDITOR_HOME,
      page: () => AssignmentEditorHomePage(),
    ),
    GetPage(
      name: Routes.CAMERAMAN_HOME,
      page: () => CameramanHomePage(),
    ),
    GetPage(
      name: Routes.HEAD_OF_DEPARTMENT_HOME,
      page: () => HeadOfDepartmentHomePage(),
    ),
    GetPage(
      name: Routes.CREATE_TASK,
      page: () => CreateTask(),
    ),
    GetPage(
      name: Routes.USER_MANAGEMENT,
      page: () => UserManagementPage(),
    ),
    GetPage(
      name: Routes.EDIT_TASK,
      page: () {
        final task = Get.arguments;
        if (task == null) {
          Get.snackbar("Error", "No task data provided");
          return const Placeholder(); // Prevents crash
        }
        return tasks.EditTaskPage(task: task); // Use the prefixed import
      },
    ),
    GetPage(
      name: Routes.REPORTER_HOME,
      page: () => ReporterHomePage(),
    ),
  ];
}
