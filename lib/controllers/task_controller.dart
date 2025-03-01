// controllers/task_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/controllers/auth_controller.dart';
import 'package:logger/models/task_repository.dart';
import '../models/task_model.dart';

class TaskController extends GetxController {
  final TaskRepository _repository = TaskRepository();

  // ✅ Separate lists for created and assigned tasks
  final RxList<Task> userCreatedTasks = <Task>[].obs;
  final RxList<Task> userAssignedTasks = <Task>[].obs;
  final RxList<Task> tasks =
      <Task>[].obs; // Stores all tasks for Admins/Editors

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final user = Get.find<AuthController>().user.value;
    if (user != null) {
      fetchTasksForUser(user.id);
    }
    listenForTaskUpdates(); // ✅ Enable real-time updates
  }

  // ✅ Cameraman Creates Task
  Future<void> createTask(Task task) async {
    try {
      isLoading.value = true;
      error.value = '';

      final Task? response = await _repository.createTask(task);
      if (response != null) {
        tasks.add(response);
        Get.snackbar("Success", "Task created successfully",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      error.value = 'Failed to create task: ${e.toString()}';
      Get.snackbar('Error', 'Failed to create task: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Update Task
  Future<void> updateTask(Task task) async {
    try {
      isLoading.value = true;
      final Task? updatedTask = await _repository.updateTask(task);
      final int index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1 && updatedTask != null) {
        tasks[index] = updatedTask;
      }
      Get.snackbar('Success', 'Task updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      error.value = 'Failed to update task: ${e.toString()}';
      Get.snackbar('Error', 'Failed to update task',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Fetch all tasks (for Admins & Assignment Editors)
  Future<void> fetchAllTasks() async {
    try {
      isLoading.value = true;
      final List<Task> response = await _repository.getAllTasks();
      tasks.assignAll(response);
    } catch (e) {
      error.value = 'Failed to fetch tasks: ${e.toString()}';
      Get.snackbar('Error', 'Failed to fetch tasks',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Fetch tasks assigned to and created by a specific user (Cameraman/Reporter)
  Future<void> fetchTasksForUser(String userId) async {
    try {
      isLoading.value = true;
      final List<Task> createdTasks = await _repository.getCreatedTasks(userId);
      final List<Task> assignedTasks = await _repository.getAssignedTasks(userId);
      userCreatedTasks.assignAll(createdTasks);
      userAssignedTasks.assignAll(assignedTasks);
    } catch (e) {
      error.value = 'Failed to fetch tasks: ${e.toString()}';
      Get.snackbar('Error', 'Failed to fetch tasks',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Fetch tasks for a specific user
  Future<List<Task>> getTasksForUser(String userId) async {
    try {
      isLoading.value = true;
      final List<Task> assignedTasks = await _repository.getAssignedTasks(userId);
      final List<Task> createdTasks = await _repository.getCreatedTasks(userId);
      return [...assignedTasks, ...createdTasks]; // ✅ Combine lists
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error fetching tasks for user: $e");
      }
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Listen for Real-Time Task Updates
  void listenForTaskUpdates() {
    _repository.listenForTaskUpdates((List<Task> updatedTasks) {
      tasks.assignAll(updatedTasks);
    });
  }
}