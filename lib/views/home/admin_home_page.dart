// views/home/admin_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../routes/app_routes.dart';


class AdminHomePage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TaskController taskController = Get.find<TaskController>();

  AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => Get.toNamed(Routes.USER_MANAGEMENT),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        final tasks = taskController.getAllTasks(); // Remove .value
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text(task.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Assigned to: ${task.assignedTo}'),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Get.toNamed(Routes.EDIT_TASK, arguments: task),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      taskController.deleteTask(task.id);  // Ensure deleteTask method exists
                    },
                  ),
                  
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.CREATE_TASK),
        child: const Icon(Icons.add),
      ),
    );
  }
}