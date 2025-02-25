// controllers/user_management_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserManagementController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    try {
      isLoading.value = true;
      final response = await _supabase.from('users').select();

      if (response.isEmpty) {
        users.clear();
        return;
      }

      users.assignAll(
        response
            .map<UserModel>((json) => UserModel.fromJson(json))
            .toList(), // ✅ Fixed
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching users: $e");
      }
      Get.snackbar("Error", "Failed to fetch users");
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> deleteUser(String userId) async {
    try {
      await _supabase.from('users').delete().eq('id', userId);
      users.removeWhere((user) => user.id == userId);
      Get.snackbar("Success", "User deleted successfully");
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting user: $e");
      }
      Get.snackbar("Error", "Failed to delete user");
    }
  }

  List<UserModel> getAllUsers() {
    return users.toList();
  }
}
