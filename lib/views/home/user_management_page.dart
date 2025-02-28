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
  final TextEditingController searchController = TextEditingController();

  List<UserModel> allUsers = [];
  List<UserModel> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    final users = await authController.fetchAssignableUsers();
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

  List<UserRole> _getAllowedRoles(UserRole currentUserRole) {
    switch (currentUserRole) {
      case UserRole.admin:
        return UserRole.values; // Admin can assign all roles
      case UserRole.headOfDepartment:
        return [
          UserRole.assignmentEditor,
          UserRole.cameraman,
          UserRole.reporter
        ]; // HoD can only manage these roles
      case UserRole.assignmentEditor:
        return [UserRole.cameraman, UserRole.reporter]; // Editor manages these
      default:
        return [];
    }
  }

  void _confirmDelete(UserModel user) {
    Get.defaultDialog(
      title: "Delete User?",
      middleText: "Are you sure you want to delete ${user.name}?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await authController.deleteUser(user.id);
        await _fetchUsers();
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh users',
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              onChanged: _searchUsers,
              decoration: InputDecoration(
                labelText: 'Search Users',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('No users found'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            child: Text(user.name[0].toUpperCase()),
                          ),
                          title: Text(user.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.email),
                              Text('Role: ${user.roleToString()}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_getAllowedRoles(
                                      authController.user.value!.role)
                                  .isNotEmpty)
                                DropdownButton<UserRole>(
                                  value: user.role,
                                  onChanged: (newRole) async {
                                    if (newRole != null) {
                                      await authController.updateUserRole(
                                        user.id,
                                        newRole,
                                      );
                                      await _fetchUsers();
                                    }
                                  },
                                  items: _getAllowedRoles(
                                          authController.user.value!.role)
                                      .map((role) {
                                    return DropdownMenuItem(
                                      value: role,
                                      child: Text(role
                                          .toString()
                                          .split('.')
                                          .last
                                          .capitalizeFirst!),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(width: 10),
                              if (authController.user.value!.role ==
                                      UserRole.admin ||
                                  authController.user.value!.role ==
                                      UserRole.headOfDepartment)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Delete user',
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
}
