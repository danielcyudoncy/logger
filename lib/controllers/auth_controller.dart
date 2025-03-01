// controllers/auth_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();

  // State Management
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isOnline = false.obs;

  // Dependencies
  late final SupabaseClient _supabase;
  final Connectivity _connectivity = Connectivity();

  // Cache Management
  final RxMap<String, UserModel> _userCache = RxMap<String, UserModel>();

  AuthController() {
    _supabase = Supabase.instance.client;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeAuthState();
    _monitorConnectionStatus();
  }

  Future<void> _setUser(User authUser) async {
    try {
      final userId = authUser.id;
      final response =
          await _supabase.from('users').select().eq('id', userId).maybeSingle();

      if (response == null) {
        await _supabase.from('users').insert({
          'id': userId,
          'name': authUser.userMetadata?['name'] ?? 'Unknown',
          'email': authUser.email ?? '',
          'role': 'reporter',
          'is_online': true,
        });
      }

      user.value = UserModel(
        id: userId,
        email: authUser.email ?? '',
        name: response?['name'] ?? 'Unknown',
        role: _parseUserRole(response?['role']),
      );

      _userCache[userId] = user.value!;
    } catch (error) {
      if (kDebugMode) {
        print("Error setting user: $error");
      }
      Get.snackbar("Error", "Failed to set user: ${error.toString()}");
    }
  }

  void _monitorConnectionStatus() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult status) {
      isOnline.value = status != ConnectivityResult.none;
      _updateUserOnlineStatus();
    });
  }

  Future<void> _updateUserOnlineStatus() async {
    if (user.value != null) {
      await _supabase
          .from('users')
          .update({'is_online': isOnline.value}).eq('id', user.value!.id);
    }
  }

  void _initializeAuthState() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _setUser(session.user);
      } else if (event == AuthChangeEvent.signedOut) {
        _clearUserData();
      }
    });
  }

  Future<void> login(String email, String password) async {
    await _handleError(() async {
      isLoading.value = true;

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        final userData = await _fetchUserData(response.user!.id);
        if (userData == null) throw 'User not found in database';

        user.value = UserModel.fromJson(userData);
        _userCache[user.value!.id] = user.value!;
        _navigateToHomePage();
      }
    });
  }

  Future<void> register(
      String email, String password, String name, UserRole role) async {
    await _handleError(() async {
      isLoading.value = true;

      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        throw 'Email is already registered';
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        await _supabase.from('users').insert({
          'id': userId,
          'name': name,
          'email': email,
          'role': role.toString().split('.').last,
          'is_online': true,
        });

        await _setUser(response.user!);
        _navigateToHomePage();
      }
    });
  }

Future<List<UserModel>> fetchOnlineUsers() async {
    return await _handleError<List<UserModel>>(() async {
      final List<dynamic> response =
          await _supabase.from('users').select().eq('is_online', true);

      return response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .toList();
    });
  }

  Future<List<UserModel>> fetchUsersForHoD() async {
    return await _handleError<List<UserModel>>(() async {
      if (user.value == null) return [];

      final List<dynamic> response = await _supabase.from('users').select();

      return response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .where((user) =>
              user.role == UserRole.assignmentEditor ||
              user.role == UserRole.cameraman ||
              user.role == UserRole.reporter)
          .toList();
    });
  }

Future<List<UserModel>> fetchAssignableUsers() async {
    return await _handleError<List<UserModel>>(() async {
      if (user.value == null) return [];

      final List<dynamic> response = await _supabase.from('users').select();

      return response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .where((user) =>
              user.role == UserRole.assignmentEditor ||
              user.role == UserRole.cameraman ||
              user.role == UserRole.reporter)
          .toList();
    });
  }


  Future<void> logout() async {
    final currentUser = user.value;

    if (currentUser != null) {
      try {
        await _supabase
            .from('users')
            .update({'is_online': false}).eq('id', currentUser.id);
      } catch (e) {
        if (kDebugMode) {
          print("Error updating is_online status: $e");
        }
      }
    }

    await _supabase.auth.signOut();

    // ✅ Clear user safely
    user.value = null;
    _userCache.clear();

    // ✅ Remove controllers correctly
    Get.delete<AuthController>();
    Get.offAllNamed(Routes.login);
  }

  Future<void> deleteUser(String userId) async {
    try {
      isLoading.value = true;
      await _supabase.from('users').delete().match({'id': userId});
      Get.snackbar('Success', 'User deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      isLoading.value = true;
      await _supabase.from('users').update(
          {'role': newRole.toString().split('.').last}).match({'id': userId});
      Get.snackbar('Success', 'User role updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update role: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    return await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }


  Future<T> _handleError<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error) {
      if (kDebugMode) {
        print('Operation failed: $error');
      }
      Get.snackbar('Error', error.toString(),
          snackPosition: SnackPosition.BOTTOM);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void _clearUserData() {
    user.value = null;
    _userCache.clear();
  }

  UserRole _parseUserRole(String? roleString) {
    try {
      return UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == roleString,
        orElse: () => UserRole.reporter,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing user role: $roleString');
      }
      return UserRole.reporter;
    }
  }

  void _navigateToHomePage() {
    if (user.value == null) return;

    final routes = {
      UserRole.admin: Routes.adminHome,
      UserRole.assignmentEditor: Routes.assignmentEditorHome,
      UserRole.cameraman: Routes.cameramanHome,
      UserRole.reporter: Routes.reporterHome,
      UserRole.headOfDepartment: Routes.headOfDepartmentHome,
    };

    final route = routes[user.value!.role];
    if (route != null) {
      Get.offAllNamed(route);
    } else {
      Get.snackbar('Error', 'Unknown role. Contact support.');
    }
  }
}
