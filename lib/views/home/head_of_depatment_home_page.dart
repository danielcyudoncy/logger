// views/home/head_of_depatment_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';

class HeadOfDepartmentHomePage extends StatefulWidget {
  const HeadOfDepartmentHomePage({super.key});

  @override
  State<HeadOfDepartmentHomePage> createState() =>
      _HeadOfDepartmentHomePageState();
}

class _HeadOfDepartmentHomePageState extends State<HeadOfDepartmentHomePage> {
  final AuthController authController =
      Get.put(AuthController(), permanent: true);
  final TaskController taskController =
      Get.put(TaskController(), permanent: true);

  String selectedFilter = "All"; // Default filter

  @override
  void initState() {
    super.initState();
    if (authController.user.value != null) {
      taskController.fetchTasksForUser(
          authController.user.value!.id); // ✅ Fetch tasks assigned to HoD
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
            'Welcome, ${authController.user.value?.name ?? "Head of Department"}')),
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
                  taskController.getTasksForUser(authController.user.value!.id);
              final tasks = _filterTasks(allTasks);

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

      // ✅ Floating Button to Assign Task to Cameraman
      floatingActionButton: FloatingActionButton(
        onPressed: () => _assignTaskDialog(),
        child: const Icon(Icons.add),
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
            Text('Created by: ${task.createdByName}'),
            if (task.dueDate != null)
              Text(
                'Due Date: ${DateFormat.yMMMd().format(task.dueDate!)}',
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
    UserModel? selectedCameraman;

    Get.defaultDialog(
      title: "Assign Task",
      content: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Task Title"),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<UserModel>>(
            future: authController.fetchAllUsers(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text("No cameramen found.");
              }
              final cameramen = snapshot.data!
                  .where((user) => user.role == UserRole.cameraman)
                  .toList();
              return DropdownButton<UserModel>(
                hint: const Text("Select Cameraman"),
                value: selectedCameraman,
                items: cameramen.map((UserModel user) {
                  return DropdownMenuItem<UserModel>(
                    value: user,
                    child: Text(user.name),
                  );
                }).toList(),
                onChanged: (UserModel? newValue) {
                  selectedCameraman = newValue;
                },
              );
            },
          ),
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
                selectedDate = picked;
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
            selectedCameraman == null ||
            selectedDate == null) {
          Get.snackbar("Error", "Please fill all fields");
          return;
        }

        Task newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: titleController.text.trim(),
          description: "",
          assignedTo: selectedCameraman!.id,
          assignedToName: selectedCameraman!.name,
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
