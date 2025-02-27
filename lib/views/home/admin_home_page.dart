// views/home/admin_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/user_management_controller.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';

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
          Expanded(
            child: Obx(() {
              final users = userController.getAllUsers();
              final currentUser = authController.user.value;

              final filteredUsers = users
                  .where((user) =>
                      user.id !=
                      currentUser?.id) // Exclude only the logged-in admin
                  .toList();




              return filteredUsers.isEmpty
                  ? const Center(child: Text("No other users available."))
                  : ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return _userCard(user);
                      },
                    );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.createTask),
        child: const Icon(Icons.add),
      ),
    );
  }

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

  Widget _userCard(UserModel user) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(user.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(user.email),
      ),
    );
  }
}
