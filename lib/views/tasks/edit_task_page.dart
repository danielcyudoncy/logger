// views/tasks/edit_task_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';

class EditTaskPage extends StatefulWidget {
  const EditTaskPage({super.key});

  @override
  EditTaskPageState createState() => EditTaskPageState();
}

class EditTaskPageState extends State<EditTaskPage> {
  final TaskController taskController = Get.find<TaskController>();
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedUserId;
  bool isCompleted = false;
  DateTime? dueDate;
  late Task task;

  @override
  void initState() {
    super.initState();
    if (Get.arguments == null) {
      Get.snackbar("Error", "No task data provided.");
      Get.back();
      return;
    }
    task = Get.arguments as Task;
    titleController.text = task.title;
    descriptionController.text = task.description;
    selectedUserId = task.assignedTo;
    isCompleted = task.isCompleted;
    dueDate = task.dueDate;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _updateTask() {
    final updatedTask = task.copyWith(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      assignedTo: selectedUserId ?? task.assignedTo,
      isCompleted: isCompleted,
      dueDate: dueDate,
    );

    taskController.updateTask(updatedTask);
    Get.back();
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
              future: authController.fetchAllUsers(),
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
            ListTile(
              title: Text(
                dueDate == null
                    ? 'Pick a Due Date'
                    : 'Due Date: ${DateFormat.yMMMd().format(dueDate!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    dueDate = pickedDate;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Mark as Completed'),
              value: isCompleted,
              onChanged: (value) {
                setState(() {
                  isCompleted = value;
                });
              },
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
  }
}
