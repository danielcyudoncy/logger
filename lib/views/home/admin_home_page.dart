// views/home/admin_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../routes/app_routes.dart';
import '../../controllers/user_management_controller.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AuthController authController =
      Get.put(AuthController(), permanent: true);
  final TaskController taskController =
      Get.put(TaskController(), permanent: true);
  final UserManagementController userController =
      Get.put(UserManagementController(), permanent: true);

  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    taskController.fetchAllTasks();
    userController.fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() =>
            Text('Welcome, ${authController.user.value?.name ?? "Admin"}')),
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

          // ✅ Task Filters
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
              final allTasks = taskController.getAllTasks().toList();
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

          const Divider(),

          // ✅ User Management Section
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "User Management",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: Obx(() {
              final users = userController.getAllUsers();
              if (users.isEmpty) {
                return const Center(child: Text("No users found."));
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _userCard(user);
                },
              );
            }),
          ),
        ],
      ),

      // ✅ Floating Action Button for Adding Task
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.createTask),
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
  Widget _taskCard(task) {
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
  List _filterTasks(List allTasks) {
    if (selectedFilter == "Pending") {
      return allTasks.where((task) => !task.isCompleted).toList();
    } else if (selectedFilter == "Completed") {
      return allTasks.where((task) => task.isCompleted).toList();
    }
    return allTasks;
  }

  // ✅ User Card UI (With Delete Button)
  Widget _userCard(user) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Role: ${user.role.toString().split('.').last}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDeleteUser(user.id),
        ),
      ),
    );
  }

  // ✅ Confirm Before Deleting User
  void _confirmDeleteUser(String userId) {
    Get.defaultDialog(
      title: "Delete User?",
      middleText: "Are you sure you want to delete this user?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () {
        userController.deleteUser(userId);
        Get.back();
      },
    );
  }
}
