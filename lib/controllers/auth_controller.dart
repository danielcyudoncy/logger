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

  // ✅ Fixed `register()`: Now Checks If Email Exists Before Registering
  Future<void> register(
      String email, String password, String name, UserRole role) async {
    try {
      isLoading.value = true;

      // ✅ Check if email already exists in `users` table
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        Get.snackbar('Error', 'Email is already registered. Please log in.');
        return;
      }

      // ✅ Register the user in Supabase Auth
      final response =
          await _supabase.auth.signUp(email: email, password: password);

      if (response.user != null) {
        final userId = response.user!.id;

        // ✅ Manually save user data in the `users` table
        await _supabase.from('users').insert({
          'id': userId,
          'name': name,
          'email': email,
          'role': role.toString().split('.').last,
        });

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

  // ✅ Fixed `login()`: Now Fetches User Details After Login
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final response = await _supabase.auth
          .signInWithPassword(email: email, password: password);

      if (response.session != null && response.user != null) {
        final userId = response.user!.id;

        // ✅ Fetch user details from `users` table after login
        final userData = await _supabase
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (userData == null) {
          Get.snackbar('Error', 'User not found in database.');
          return;
        }

        user.value = UserModel(
          id: userId,
          email: response.user!.email ?? '',
          name: userData['name'] ?? 'Unknown',
          role: _parseUserRole(userData['role']),
        );

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

  // ✅ Fixed `_setUser()`: Ensures User Exists in Database
  Future<void> _setUser(User authUser) async {
    try {
      final userId = authUser.id;

      // ✅ Fetch user from `users` table
      final response =
          await _supabase.from('users').select().eq('id', userId).maybeSingle();

      // ✅ If user does not exist, insert them (fixes missing users)
      if (response == null) {
        await _supabase.from('users').insert({
          'id': userId,
          'name': authUser.userMetadata?['name'] ?? 'Unknown',
          'email': authUser.email ?? '',
          'role': 'reporter', // Default role if missing
        });
      }

      user.value = UserModel(
        id: userId,
        email: authUser.email ?? '',
        name: response?['name'] ?? 'Unknown',
        role: _parseUserRole(response?['role']),
      );
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching user: $error");
      }
      Get.snackbar("Error", "Failed to fetch user: ${error.toString()}");
    }
  }

  // ✅ Fixed `fetchAllUsers()`: Improved Error Handling
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

  // ✅ User Deletion Now Works Correctly
  Future<void> deleteUser(String userId) async {
    try {
      await _supabase.from('users').delete().eq('id', userId);
      Get.snackbar("Success", "User deleted successfully");
    } catch (error) {
      Get.snackbar("Error", "Failed to delete user: ${error.toString()}");
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true; // ✅ Show loading indicator

      await _supabase.auth.signOut(); // ✅ Supabase Logout

      user.value = null; // ✅ Clear user data

      Get.offAllNamed(Routes.login); // ✅ Navigate to login screen
    } catch (error) {
      if (kDebugMode) {
        print("Logout Error: $error");
      }
      Get.snackbar('Error', 'Logout failed: ${error.toString()}');
    } finally {
      isLoading.value = false; // ✅ Stop loading
    }
  }

  // ✅ Fixed `updateUserRole()`: Improved Logging
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

  // ✅ Role Parsing (Ensures Default Role)
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
        return UserRole.reporter; // Default role if parsing fails
    }
  }

  // ✅ Navigate User Based on Role
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
        default:
        Get.snackbar('Error', 'Unknown role. Contact support.');
    }
  }
}
