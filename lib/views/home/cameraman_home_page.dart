// views/home/cameraman_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';

class CameramanHomePage extends StatefulWidget {
  const CameramanHomePage({super.key});

  @override
  State<CameramanHomePage> createState() => _CameramanHomePageState();
}

class _CameramanHomePageState extends State<CameramanHomePage> {
  final AuthController authController = Get.find<AuthController>();
  final TaskController taskController = Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() {
    final user = authController.user.value;
    if (user != null) {
      taskController.fetchTasksForUser(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() =>
            Text('Welcome, ${authController.user.value?.name ?? "Cameraman"}')),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchTasks),
          IconButton(
              icon: const Icon(Icons.logout), onPressed: authController.logout),
        ],
      ),
      body: Obx(() {
        if (taskController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ✅ Section for Created Tasks
            _sectionHeader("Tasks Created"),
            taskController.userCreatedTasks.isEmpty
                ? _emptyState("No tasks created.")
                : _taskList(taskController.userCreatedTasks),

            const SizedBox(height: 20),

            // ✅ Section for Assigned Tasks
            _sectionHeader("Tasks Assigned"),
            taskController.userAssignedTasks.isEmpty
                ? _emptyState("No tasks assigned.")
                : _taskList(taskController.userAssignedTasks),
          ],
        );
      }),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(message,
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ),
    );
  }

  Widget _taskList(List<Task> tasks) {
    return Column(
      children: tasks.map((task) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(task.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Due: ${task.dueDate}'),
          ),
        );
      }).toList(),
    );
  }
}
