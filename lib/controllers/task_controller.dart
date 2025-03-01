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
  }

  // ✅ Fetch all tasks (for Admins & Assignment Editors)
  Future<void> fetchAllTasks() async {
    try {
      isLoading.value = true;
      error.value = '';

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
      error.value = '';

      final List<Task> createdTasks = await _repository.getCreatedTasks(userId);
      final List<Task> assignedTasks =
          await _repository.getAssignedTasks(userId);

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

  // ✅ Fetch only unassigned tasks (for Admins & Editors)
  Future<void> fetchUnassignedTasks() async {
    try {
      isLoading.value = true;
      error.value = '';

      final List<Task> response = await _repository.getUnassignedTasks();
      tasks.assignAll(response);
    } catch (e) {
      error.value = 'Failed to fetch unassigned tasks: ${e.toString()}';
      Get.snackbar('Error', 'Failed to fetch unassigned tasks',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Create a Task
  Future<void> createTask(Task task) async {
    try {
      isLoading.value = true;
      error.value = '';

      if (kDebugMode) {
        print("Creating Task: ${task.toJson()}");
      }

      final Task? response = await _repository.createTask(task);

      if (response != null) {
        tasks.add(response);
        Get.snackbar("Success", "Task created successfully",
            snackPosition: SnackPosition.BOTTOM);

        if (kDebugMode) {
          print("Task created successfully in Supabase: ${response.toJson()}");
        }
      } else {
        if (kDebugMode) {
          print("Error: Task creation response was null.");
        }
      }
    } catch (e) {
      error.value = 'Failed to create task: ${e.toString()}';
      Get.snackbar('Error', 'Failed to create task: $e',
          snackPosition: SnackPosition.BOTTOM);
      if (kDebugMode) {
        print("Error creating task: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Assign Task to a Reporter
  Future<void> assignTask(
      String taskId, String reporterId, String reporterName) async {
    try {
      isLoading.value = true;
      error.value = '';

      final bool success = await _repository.updateTaskAssignment(
          taskId, reporterId, reporterName);

      if (success) {
        tasks.removeWhere((task) => task.id == taskId);
        Get.snackbar("Success", "Task assigned successfully",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      error.value = 'Failed to assign task: ${e.toString()}';
      Get.snackbar('Error', 'Failed to assign task',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Update Task (e.g., Cameraman Uploading Work)
  Future<void> updateTask(Task task) async {
    try {
      isLoading.value = true;
      error.value = '';

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

  // ✅ Toggle Task Completion (e.g., Mark as Completed)
  Future<void> toggleTaskCompletion(Task task) async {
    final Task updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      status: !task.isCompleted ? 'completed' : 'pending',
    );
    await updateTask(updatedTask);
  }

  // ✅ Delete Task
  Future<void> deleteTask(String taskId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _repository.deleteTask(taskId);
      tasks.removeWhere((task) => task.id == taskId);

      Get.snackbar('Success', 'Task deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      error.value = 'Failed to delete task: ${e.toString()}';
      Get.snackbar('Error', 'Failed to delete task',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Get Tasks by Status
  List<Task> getTasksByStatus(String status) {
    return tasks.where((task) => task.status == status).toList();
  }

  // ✅ Get Tasks Assigned to Specific User
  List<Task> getTasksByAssignee(String userId) {
    return tasks.where((task) => task.assignedTo == userId).toList();
  }

  // ✅ Fetch tasks assigned to a specific user (Cameraman or Reporter)
  Future<List<Task>> getTasksForUser(String userId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final List<Task> assignedTasks =
          await _repository.getAssignedTasks(userId);
      final List<Task> createdTasks = await _repository.getCreatedTasks(userId);

      return [...assignedTasks, ...createdTasks]; // ✅ Combine after awaiting
    } catch (e) {
      print("❌ Error fetching tasks for user: $e");
      return [];
    } finally {
      isLoading.value = false;
    }
  }
}
