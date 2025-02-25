// views/home/user_management_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final AuthController authController =
      Get.put(AuthController(), permanent: true);
  TextEditingController searchController = TextEditingController();
  List<UserModel> allUsers = [];
  List<UserModel> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final users = await authController.fetchAllUsers();
    setState(() {
      allUsers = users;
      filteredUsers = users;
    });
  }

  void _searchUsers(String query) {
    setState(() {
      filteredUsers = allUsers
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers, // ✅ Refresh users list
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              onChanged: _searchUsers,
              decoration: InputDecoration(
                labelText: "Search Users",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // ✅ User List
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('No users found.'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ✅ Role Dropdown
                              DropdownButton<UserRole>(
                                value: user.role,
                                onChanged: (newRole) {
                                  if (newRole != null) {
                                    authController.updateUserRole(
                                        user.id, newRole);
                                    _fetchUsers(); // ✅ Refresh after updating role
                                  }
                                },
                                items: UserRole.values.map((role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child:
                                        Text(role.toString().split('.').last),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(width: 10),

                              // ✅ Delete User Button
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(user),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ✅ Confirm Delete Dialog
  void _confirmDelete(UserModel user) {
    Get.defaultDialog(
      title: "Delete User?",
      middleText: "Are you sure you want to delete ${user.name}?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await authController.deleteUser(user.id);
        _fetchUsers(); // ✅ Refresh user list
        Get.back();
      },
    );
  }
}
