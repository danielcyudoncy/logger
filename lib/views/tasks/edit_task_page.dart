// views/tasks/edit_task_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;
  const EditTaskPage({super.key, required this.task});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final TaskController taskController = Get.find<TaskController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedUserId;
  bool isCompleted = false;
  DateTime? completionTimestamp;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.task.title;
    descriptionController.text = widget.task.description;
    selectedUserId = widget.task.assignedTo;
    isCompleted = widget.task.isCompleted;
    completionTimestamp = widget.task.completionTimestamp;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _updateTask() {
    final updatedTask = widget.task.copyWith(
      title: titleController.text,
      description: descriptionController.text,
      assignedTo: selectedUserId ?? widget.task.assignedTo,
      isCompleted: isCompleted,
      completionTimestamp: isCompleted ? DateTime.now() : null,
    );
    taskController.updateTask(updatedTask);
    Get.back(); // Navigate back after update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Task Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<UserModel>>(
              future: authController.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error loading users: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }
                final users = snapshot.data!
                    .where((user) =>
                        user.role == UserRole.cameraman ||
                        user.role == UserRole.reporter)
                    .toList();
                return DropdownButtonFormField<String>(
                  value: selectedUserId,
                  decoration: const InputDecoration(labelText: 'Assign To'),
                  items: users.map((user) {
                    return DropdownMenuItem(
                      value: user.id,
                      child: Text(user.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUserId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Mark as Completed'),
              value: isCompleted,
              onChanged: (value) {
                setState(() {
                  isCompleted = value;
                  completionTimestamp = value ? DateTime.now() : null;
                });
              },
            ),
            if (completionTimestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                    'Completed on: ${completionTimestamp!.toLocal().toString()}'),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateTask,
              child: const Text('Update Task'),
            ),
          ],
        ),
      ),
    );
  }}