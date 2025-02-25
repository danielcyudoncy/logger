// views/home/cameraman_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';

class CameramanHomePage extends StatefulWidget {
  const CameramanHomePage({super.key});

  @override
  State<CameramanHomePage> createState() => _CameramanHomePageState();
}

class _CameramanHomePageState extends State<CameramanHomePage> {
  final AuthController authController =
      Get.put(AuthController(), permanent: true);
  final TaskController taskController =
      Get.put(TaskController(), permanent: true);

  @override
  void initState() {
    super.initState();
    taskController.fetchTasksForUser(authController.user.value!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() =>
            Text('Welcome, ${authController.user.value?.name ?? "Cameraman"}')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                taskController.fetchTasksForUser(authController.user.value!.id),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final tasks =
                  taskController.getTasksForUser(authController.user.value!.id);
              if (tasks.isEmpty) {
                return const Center(child: Text("No tasks assigned to you."));
              }
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _taskCard(task);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            taskController.fetchTasksForUser(authController.user.value!.id),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _taskCard(Task task) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(task.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assigned by: ${task.createdByName}'),
            if (task.dueDate != null)
              Text(
                  'Due Date: ${DateFormat.yMMMd().add_jm().format(task.dueDate!)}',
                  style: const TextStyle(color: Colors.red)),
          ],
        ),
        trailing: task.isCompleted
            ? const Icon(Icons.check, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.upload_file, color: Colors.blue),
                onPressed: () => _uploadCompletedWork(task)),
      ),
    );
  }

  void _uploadCompletedWork(Task task) {
    TextEditingController linkController = TextEditingController();
    Get.defaultDialog(
      title: "Upload Completed Work",
      content: TextField(
          controller: linkController,
          decoration: const InputDecoration(labelText: "File Link")),
      textConfirm: "Submit",
      textCancel: "Cancel",
      onConfirm: () {
        Task updatedTask =
            task.copyWith(isCompleted: true, status: "completed");
        taskController.updateTask(updatedTask);
        Get.back();
      },
    );
  }
}
