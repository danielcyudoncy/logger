// controllers/task_controller.dart
import 'package:get/get.dart';
import 'package:logger/controllers/auth_controller.dart';
import 'package:logger/models/task_repository.dart';
import '../models/task_model.dart';

class TaskController extends GetxController {
  final TaskRepository _repository = TaskRepository();
  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.find<AuthController>().user.value != null) {
      fetchTasksForUser(Get.find<AuthController>().user.value!.id);
    }
  }

  // ✅ Get All Tasks
  RxList<Task> getAllTasks() {
    return tasks;
  }

  // ✅ Fetch All Tasks for Admin & Assignment Editors
  Future<void> fetchAllTasks() async {
    try {
      isLoading.value = true;
      error.value = '';
      final fetchedTasks = await _repository.getAllTasks();
      tasks.assignAll(fetchedTasks);
    } catch (e) {
      error.value = 'Failed to fetch tasks: ${e.toString()}';
      Get.snackbar('Error', 'Failed to fetch tasks',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Fetch Tasks Assigned to a Specific User (Cameraman)
  Future<void> fetchTasksForUser(String userId) async {
    try {
      isLoading.value = true;
      error.value = '';
      final userTasks = await _repository.getTasksForUser(userId);
      tasks.assignAll(userTasks);
    } catch (e) {
      error.value = 'Failed to fetch tasks: ${e.toString()}';
      Get.snackbar('Error', 'Failed to fetch tasks',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Get Tasks for Cameraman
  List<Task> getTasksForUser(String userId) {
    return tasks.where((task) => task.assignedTo == userId).toList();
  }

  // ✅ Create a Task
  Future<void> createTask(Task task) async {
    try {
      isLoading.value = true;
      error.value = '';
      final newTask = await _repository.createTask(task);
      tasks.add(newTask!);
      Get.back();
      Get.snackbar('Success', 'Task created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      error.value = 'Failed to create task: ${e.toString()}';
      Get.snackbar('Error', 'Failed to create task',
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
      final updatedTask = await _repository.updateTask(task);
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = updatedTask!;
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

  // ✅ Mark Task as Completed
  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      status: !task.isCompleted ? 'completed' : 'pending',
    );
    await updateTask(updatedTask);
  }

  // ✅ Get Tasks by Status
  List<Task> getTasksByStatus(String status) {
    return tasks.where((task) => task.status == status).toList();
  }

  // ✅ Get Tasks Assigned to Specific User
  List<Task> getTasksByAssignee(String userId) {
    return tasks.where((task) => task.assignedTo == userId).toList();
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
}
