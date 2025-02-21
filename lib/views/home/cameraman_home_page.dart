// views/home/cameraman_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../routes/app_routes.dart';

class CameramanHomePage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TaskController taskController = Get.find<TaskController>();

  CameramanHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cameraman Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.user.value;
        if (user == null) {
          Get.offAllNamed(Routes.LOGIN);
          return const Center(
              child:
                  CircularProgressIndicator()); // Show a loader while redirecting
        }

        final tasks = taskController.getTasksForUser(user.id);
        if (tasks.isEmpty) {
          return const Center(child: Text("No tasks assigned."));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text(task.description),
              trailing: Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  taskController.updateTask(task.copyWith(
                    isCompleted: value ?? false,
                  ));
                },
              ),
            );
          },
        );
      }),
    );
  }
}
