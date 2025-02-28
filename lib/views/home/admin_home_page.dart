import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AuthController authController =
      Get.put(AuthController(), permanent: true);

  List<UserModel> onlineUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchOnlineUsers();
  }

  Future<void> _fetchOnlineUsers() async {
    final users = await authController.fetchOnlineUsers();
    setState(() {
      onlineUsers = users;
    });
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
            onPressed: _fetchOnlineUsers, // ✅ Refresh online users
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: onlineUsers.isEmpty
          ? const Center(child: Text("No users online."))
          : ListView.builder(
              itemCount: onlineUsers.length,
              itemBuilder: (context, index) {
                final user = onlineUsers[index];
                return ListTile(
                  leading: const Icon(Icons.circle, color: Colors.green), // ✅ Online Indicator
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user.email),
                );
              },
            ),
    );
  }
}
