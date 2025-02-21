// controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final Rx<UserModel?> user = Rx<UserModel?>(null);
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

  Future<void> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        await _setUser(response.user!);
        _navigateToHomePage();
      } else {
        Get.snackbar('Error', 'Login failed. Invalid credentials.');
      }
    } catch (error) {
      Get.snackbar('Error', 'Login failed: ${error.toString()}');
    }
  }

  Future<void> register(
      String email, String password, String name, UserRole role) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role.toString().split('.').last},
      );

      if (response.user != null) {
        await _setUser(response.user!);
        _navigateToHomePage();
      } else {
        Get.snackbar('Error', 'Registration failed. Please try again.');
      }
    } catch (error) {
      Get.snackbar('Error', 'Registration failed: ${error.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      user.value = null;
      Get.offAllNamed(Routes.LOGIN);
    } catch (error) {
      Get.snackbar('Error', 'Logout failed: ${error.toString()}');
    }
  }

  Future<void> _setUser(authUser) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle(); // ✅ Returns `null` if no user found

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
      Get.snackbar("Error", "Failed to fetch user: ${error.toString()}");
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final List<dynamic> response = await _supabase.from('users').select();

      if (response.isEmpty) {
        return [];
      }

      return response
          .map<UserModel>(
            (json) => UserModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (error) {
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
        Get.offAllNamed(Routes.ADMIN_HOME);
        break;
      case UserRole.assignmentEditor:
        Get.offAllNamed(Routes.ASSIGNMENT_EDITOR_HOME);
        break;
      case UserRole.cameraman:
        Get.offAllNamed(Routes.CAMERAMAN_HOME);
        break;
      case UserRole.reporter:
        Get.offAllNamed(Routes.REPORTER_HOME);
        break;
      case UserRole.headOfDepartment:
        Get.offAllNamed(Routes.HEAD_OF_DEPARTMENT_HOME);
        break;
    }
  }
}
