// views/home/reporter_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';

class ReporterHomePage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TaskController taskController = Get.find<TaskController>();

  ReporterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporter Home'),
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
          Get.offAllNamed('/login');
          return Container();
        }

        final tasks = taskController.getTasksForUser(user.id);
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description: ${task.description}'),
                  Text('Assigned Cameraman: ${task.assignedToName}'),
                ],
              ),
              trailing: Switch(
                value: task.isCompleted,
                onChanged: (value) {
                  final updatedTask = task.copyWith(isCompleted: value);
                  taskController.updateTask(updatedTask);
                },
              ),
            );
          },
        );
      }),
    );
  }
}
