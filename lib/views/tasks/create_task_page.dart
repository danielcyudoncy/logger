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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ Task Title Input
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 16),

            // ✅ Assign Task to User
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

                final users = snapshot.data!;
                return DropdownButtonFormField<UserModel>(
                  value: selectedAssignee,
                  decoration: const InputDecoration(labelText: 'Assign To'),
                  items: users.map((user) {
                    return DropdownMenuItem(
                      value: user,
                      child: Text(user.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAssignee = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // ✅ Select Due Date
            ListTile(
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
            const SizedBox(height: 24),

            // ✅ Create Task Button
            ElevatedButton(
              onPressed: _createTask, // ✅ Calls the function to create a task
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Create Task Function
  void _createTask() {
    if (titleController.text.isEmpty ||
        selectedAssignee == null ||
        selectedDueDate == null) {
      Get.snackbar("Error", "Please fill in all fields.");
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
    Get.snackbar("Success", "Task created successfully!");
  }
}
