// views/tasks/create_task_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';

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
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDueDate;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _createTask() {
    if (titleController.text.isEmpty || selectedDueDate == null) {
      Get.snackbar("Error", "Please fill all fields",
          snackPosition: SnackPosition.TOP);
      return;
    }

    final user = authController.user.value;
    if (user == null) return;

    Task newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      assignedTo: "unassigned", // Cameramen/Reporters don't assign users
      assignedToName: "Unassigned",
      createdBy: user.id,
      createdByName: user.name,
      isCompleted: false,
      status: "pending",
      dueDate: selectedDueDate,
    );

    taskController.createTask(newTask);
    Get.back();
    Get.snackbar("Success", "Task created successfully!",
        snackPosition: SnackPosition.TOP);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  labelText: 'Task Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                  labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
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
            ElevatedButton(
              onPressed: _createTask,
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}
