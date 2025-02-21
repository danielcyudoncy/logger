// views/home/user_management_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class UserManagementPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: FutureBuilder<List<User>>(
        future: authController.getAllUsers().then((users) => users.cast<User>()), // Cast the result to List<User>
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.userMetadata?['name'] ?? 'No name'),
                subtitle: Text(user.email ?? 'No email'),
                trailing: DropdownButton<UserRole>(
                  value: UserRole.values.firstWhere(
                    (role) => role.toString() == user.role,
                    orElse: () => UserRole.values.first,
                  ),
                  onChanged: (newRole) {
                    if (newRole != null) {
                      authController.updateUserRole(user.id, newRole);
                    }
                  },
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toString().split('.').last),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }}