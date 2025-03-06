// views/home/assignment_editor_home.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/user_management_controller.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';

class AssignmentEditorHomePage extends StatefulWidget {
  const AssignmentEditorHomePage({super.key});

  @override
  State<AssignmentEditorHomePage> createState() =>
      _AssignmentEditorHomePageState();
}

class _AssignmentEditorHomePageState extends State<AssignmentEditorHomePage> {
  final AuthController authController =
      Get.put(AuthController(), permanent: true);
  final TaskController taskController =
      Get.put(TaskController(), permanent: true);
  final UserManagementController userController =
      Get.put(UserManagementController(), permanent: true);

  String selectedFilter = "All"; // Default filter

  @override
  void initState() {
    super.initState();
    taskController.fetchAllTasks();
    userController.fetchAllUsers(); // Fetch reporters
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() =>
            Text('Welcome, ${authController.user.value?.name ?? "Editor"}')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              taskController.fetchAllTasks();
              userController.fetchAllUsers();
            },
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

          // ✅ Task Filters (All, Pending, Completed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _filterButton("All"),
                _filterButton("Pending"),
                _filterButton("Completed"),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ Task List
          Expanded(
            child: Obx(() {
              final allTasks =
                  taskController.tasks.toList(); // ✅ Use fetched tasks list
              final tasks = _filterTasks(allTasks);

              if (tasks.isEmpty) {
                return const Center(child: Text("No tasks available."));
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

      // ✅ Floating Buttons for Managing Tasks
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "assign_task",
            onPressed: () => _assignTaskDialog(),
            child: const Icon(Icons.assignment),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "refresh_tasks",
            onPressed: () => taskController.fetchAllTasks(),
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  // ✅ Task Filter Button
  Widget _filterButton(String filter) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedFilter == filter ? Colors.blue : Colors.grey[300],
        foregroundColor: selectedFilter == filter ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Text(filter),
    );
  }

  // ✅ Task Card UI
  Widget _taskCard(Task task) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assigned to: ${task.assignedToName}'),
            Text('Created by: ${task.createdByName}'),
            if (task.dueDate != null)
              Text(
                'Due Date: ${DateFormat.yMMMd().add_jm().format(task.dueDate!)}',
                style: const TextStyle(color: Colors.red),
              ),
            Row(
              children: [
                Icon(
                  task.isCompleted ? Icons.check_circle : Icons.pending,
                  color: task.isCompleted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 5),
                Text(
                  task.status,
                  style: TextStyle(
                      color: task.isCompleted ? Colors.green : Colors.red),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => Get.toNamed(Routes.editTask, arguments: task),
        ),
      ),
    );
  }

  // ✅ Task Filtering Function
  List<Task> _filterTasks(List<Task> allTasks) {
    if (selectedFilter == "Pending") {
      return allTasks.where((task) => !task.isCompleted).toList();
    } else if (selectedFilter == "Completed") {
      return allTasks.where((task) => task.isCompleted).toList();
    }
    return allTasks;
  }

  // ✅ Assign Task Dialog
  void _assignTaskDialog() {
    TextEditingController titleController = TextEditingController();
    DateTime? selectedDate;
    UserModel? selectedReporter;

    Get.defaultDialog(
      title: "Assign Task",
      content: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Task Title"),
          ),
          const SizedBox(height: 10),
          Obx(() {
            final reporters = userController.users
                .where((user) => user.role == UserRole.reporter)
                .toList(); // ✅ Fix: Use `users` directly
            return DropdownButton<UserModel>(
              hint: const Text("Select Reporter"),
              value: selectedReporter,
              items: reporters.map((UserModel user) {
                return DropdownMenuItem<UserModel>(
                  value: user,
                  child: Text(user.name),
                );
              }).toList(),
              onChanged: (UserModel? newValue) {
                setState(() {
                  selectedReporter = newValue;
                });
              },
            );
          }),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
            child: const Text("Select Due Date"),
          ),
        ],
      ),
      textConfirm: "Assign",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (titleController.text.isEmpty ||
            selectedReporter == null ||
            selectedDate == null) {
          Get.snackbar("Error", "Please fill all fields");
          return;
        }

        Task newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: titleController.text.trim(),
          description: "",
          assignedTo: selectedReporter!.id,
          assignedToName: selectedReporter!.name,
          createdBy: authController.user.value!.id,
          createdByName: authController.user.value!.name,
          isCompleted: false,
          status: "pending",
          dueDate: selectedDate,
        );

        taskController.createTask(newTask);
        Get.back();
      },
    );
  }
}
