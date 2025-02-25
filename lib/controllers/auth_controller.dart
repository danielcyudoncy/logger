// controllers/auth_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    _initializeAuthState();
  }

  void _initializeAuthState() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _setUser(session.user);
      } else if (event == AuthChangeEvent.signedOut) {
        user.value = null;
      }
    });
  }
  Future<void> deleteUser(String userId) async {
    try {
      await _supabase.from('users').delete().eq('id', userId);
      Get.snackbar("Success", "User deleted successfully");
    } catch (error) {
      Get.snackbar("Error", "Failed to delete user: ${error.toString()}");
    }
  }


  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _supabase.auth
          .signInWithPassword(email: email, password: password);
      if (response.session != null) {
        await _setUser(response.user!);
        _navigateToHomePage();
      } else {
        Get.snackbar('Error', 'Invalid login credentials');
      }
    } catch (error) {
      Get.snackbar('Error', 'Login failed: ${error.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(
      String email, String password, String name, UserRole role) async {
    try {
      isLoading.value = true;
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role.toString().split('.').last},
      );

      if (response.user != null) {
        await _setUser(response.user!);
        _navigateToHomePage();
      } else {
        Get.snackbar('Error', 'Registration failed. Try again.');
      }
    } catch (error) {
      Get.snackbar('Error', 'Registration failed: ${error.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      user.value = null;
      Get.offAllNamed(Routes.login);
    } catch (error) {
      if (kDebugMode) {
        print("Logout Error: $error");
      }
      Get.snackbar('Error', 'Logout failed: ${error.toString()}');
    }
  }

  Future<void> _setUser(User authUser) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (response == null) {
        Get.snackbar("Error", "User not found in database.");
        return;
      }

      user.value = UserModel(
        id: authUser.id,
        email: authUser.email ?? '',
        name: response['name'] ?? 'Unknown',
        role: _parseUserRole(response['role']),
      );
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching user: $error");
      }
      Get.snackbar("Error", "Failed to fetch user: ${error.toString()}");
    }
  }

  // ✅ Renamed to `fetchAllUsers()` so `edit_task_page.dart` works
  Future<List<UserModel>> fetchAllUsers() async {
    try {
      final List<dynamic> response = await _supabase.from('users').select();

      if (response.isEmpty) {
        return [];
      }

      return response
          .map<UserModel>(
              (json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print("Get Users Error: $error");
      }
      Get.snackbar("Error", "Failed to fetch users: ${error.toString()}");
      return [];
    }
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _supabase.from('users').update(
          {'role': newRole.toString().split('.').last}).eq('id', userId);
      Get.snackbar('Success', 'User role updated successfully');
    } catch (error) {
      if (kDebugMode) {
        print("Update Role Error: $error");
      }
      Get.snackbar('Error', 'Failed to update role: ${error.toString()}');
    }
  }

  UserRole _parseUserRole(String? roleString) {
    switch (roleString) {
      case 'admin':
        return UserRole.admin;
      case 'assignmentEditor':
        return UserRole.assignmentEditor;
      case 'cameraman':
        return UserRole.cameraman;
      case 'reporter':
        return UserRole.reporter;
      case 'headOfDepartment':
        return UserRole.headOfDepartment;
      default:
        return UserRole.cameraman; // Default role if parsing fails
    }
  }

  void _navigateToHomePage() {
    if (user.value == null) return;

    switch (user.value!.role) {
      case UserRole.admin:
        Get.offAllNamed(Routes.adminHome);
        break;
      case UserRole.assignmentEditor:
        Get.offAllNamed(Routes.assignmentEditorHome);
        break;
      case UserRole.cameraman:
        Get.offAllNamed(Routes.cameramanHome);
        break;
      case UserRole.reporter:
        Get.offAllNamed(Routes.reporterHome);
        break;
      case UserRole.headOfDepartment:
        Get.offAllNamed(Routes.headOfDepartmentHome);
        break;
    }
  }
}
