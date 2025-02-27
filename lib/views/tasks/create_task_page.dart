// views/tasks/create_task_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final TaskController taskController =
      Get.put(TaskController(), permanent: true);
  final AuthController authController =
      Get.put(AuthController(), permanent: true);

  final TextEditingController titleController = TextEditingController();
  DateTime? selectedDueDate;
  UserModel? selectedAssignee;

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Widget _buildUserDropdown() {
    return Obx(() {
      final currentUser = authController.user.value;
      if (currentUser == null) return const SizedBox();

      return FutureBuilder<List<UserModel>>(
        future: authController.fetchAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];
          final assignableUsers = users.where((user) {
            switch (currentUser.role) {
              case UserRole.admin:
                return true;
              case UserRole.headOfDepartment:
                return user.role == UserRole.reporter ||
                    user.role == UserRole.cameraman ||
                    user.role == UserRole.assignmentEditor;
              case UserRole.assignmentEditor:
                return user.role == UserRole.reporter ||
                    user.role == UserRole.cameraman;
              default:
                return false;
            }
          }).toList();

          return DropdownButtonFormField<String>(
            value: selectedAssignee?.id,
            hint: const Text('Select User'),
            decoration: const InputDecoration(labelText: 'Assign To'),
            items: assignableUsers.map((user) {
              return DropdownMenuItem(
                value: user.id,
                child: Text('${user.name} (${user.roleToString()})'),
              );
            }).toList(),
            onChanged: (userId) {
              if (userId != null) {
                setState(() {
                  selectedAssignee =
                      assignableUsers.firstWhere((u) => u.id == userId);
                });
              }
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _buildUserDropdown(),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: Text(
                  selectedDueDate == null
                      ? 'Pick a Due Date'
                      : 'Due Date: ${selectedDueDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDueDate = pickedDate;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _createTask() {
    if (titleController.text.isEmpty ||
        selectedAssignee == null ||
        selectedDueDate == null) {
      Get.snackbar(
        "Required Fields",
        "Please fill in all fields",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    Task newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      description: "",
      assignedTo: selectedAssignee!.id,
      assignedToName: selectedAssignee!.name,
      createdBy: authController.user.value!.id,
      createdByName: authController.user.value!.name,
      isCompleted: false,
      status: "pending",
      dueDate: selectedDueDate,
    );

    taskController.createTask(newTask);
    Get.back();
    Get.snackbar(
      "Success",
      "Task created successfully!",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
