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
  final TaskController taskController = Get.put(TaskController(), permanent: true);
  final AuthController authController = Get.put(AuthController(), permanent: true);

  final TextEditingController titleController = TextEditingController();
  DateTime? selectedDueDate;
  UserModel? selectedAssignee;
  List<UserModel> assignableUsers = [];
  late UserModel currentUser;
  bool canAssignTasks = false;

  @override
  void initState() {
    super.initState();
    currentUser = authController.user.value!;

    // ✅ Allow task assignment only for Admins, HoDs, and Assignment Editors
    canAssignTasks = currentUser.role == UserRole.admin ||
        currentUser.role == UserRole.headOfDepartment ||
        currentUser.role == UserRole.assignmentEditor;

    if (canAssignTasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchAssignableUsers(); // ✅ Prevents unnecessary looping
      });
    }
  }

  Future<void> _fetchAssignableUsers() async {
    final users = await authController.fetchAssignableUsers();
    if (mounted) {
      setState(() {
        assignableUsers = users;
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
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

            // ✅ Show "Assign To" dropdown only if the user can assign tasks
            if (canAssignTasks)
              DropdownButtonFormField<UserModel>(
                value: selectedAssignee,
                hint: const Text('Select Assignee'),
                decoration: const InputDecoration(labelText: 'Assign To'),
                items: assignableUsers.map((user) {
                  return DropdownMenuItem(
                    value: user,
                    child: Text('${user.name} (${user.roleToString()})'),
                  );
                }).toList(),
                onChanged: (UserModel? newValue) {
                  setState(() {
                    selectedAssignee = newValue;
                  });
                },
              ),

            const SizedBox(height: 16),

            // ✅ Due Date (Mandatory for All Users)
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
    if (titleController.text.isEmpty || selectedDueDate == null) {
      Get.snackbar(
        "Required Fields",
        "Please fill in all fields",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // ✅ If user cannot assign tasks, the task is assigned to themselves
    String assignedUserId = canAssignTasks
        ? selectedAssignee?.id ?? currentUser.id
        : currentUser.id;
    String assignedUserName =
        canAssignTasks ? selectedAssignee?.name ?? currentUser.name : currentUser.name;

    Task newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      description: "",
      assignedTo: assignedUserId,
      assignedToName: assignedUserName,
      createdBy: currentUser.id,
      createdByName: currentUser.name,
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
