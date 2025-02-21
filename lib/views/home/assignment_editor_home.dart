// views/home/assignment_editor_home.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../routes/app_routes.dart';

class AssignmentEditorHomePage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TaskController taskController = Get.find<TaskController>();

   AssignmentEditorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Editor Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        final tasks = taskController.getAllTasks();
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text(task.description),
              trailing: Text('Assigned to: ${task.assignedTo}'),
              onTap: () => Get.toNamed(Routes.EDIT_TASK, arguments: task),
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