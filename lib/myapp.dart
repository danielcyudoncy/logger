import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/routes/app_pages.dart';


import 'constants/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/task_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(TaskController());
      }),
      debugShowCheckedModeBanner: false,
    );
  }
}