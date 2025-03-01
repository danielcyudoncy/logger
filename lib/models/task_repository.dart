// repositories/task_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class TaskRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ✅ Create a new task
  Future<Task?> createTask(Task task) async {
    final response = await _supabase.from('tasks').insert(task.toJson()).select().maybeSingle();
    return response != null ? Task.fromJson(response) : null;
  }

  // ✅ Fetch all tasks
  Future<List<Task>> getAllTasks() async {
    final response = await _supabase.from('tasks').select('*').order('created_at', ascending: false);
    return response.map<Task>((json) => Task.fromJson(json)).toList();
  }

  // ✅ Fetch tasks created by a user
  Future<List<Task>> getCreatedTasks(String userId) async {
    final response = await _supabase.from('tasks').select('*').eq('created_by', userId);
    return response.map<Task>((json) => Task.fromJson(json)).toList();
  }

  // ✅ Fetch tasks assigned to a user
  Future<List<Task>> getAssignedTasks(String userId) async {
    final response = await _supabase.from('tasks').select('*').eq('assigned_to', userId);
    return response.map<Task>((json) => Task.fromJson(json)).toList();
  }

  // ✅ Fetch unassigned tasks (FIXED: replaced `is_()` and `isNull()` with `.filter()`)
  Future<List<Task>> getUnassignedTasks() async {
    final response = await _supabase.from('tasks').select('*').filter('assigned_to', 'is', null);
    return response.map<Task>((json) => Task.fromJson(json)).toList();
  }

  // ✅ Assign task to a reporter
  Future<bool> updateTaskAssignment(String taskId, String reporterId, String reporterName) async {
    final response = await _supabase.from('tasks').update({
      'assigned_to': reporterId,
      'assigned_to_name': reporterName,
      'status': 'Assigned',
    }).eq('id', taskId);
    return response.isEmpty; // Returns `true` if update was successful
  }

  // ✅ Update task details
  Future<Task?> updateTask(Task task) async {
    final response = await _supabase.from('tasks').update(task.toJson()).eq('id', task.id).select().maybeSingle();
    return response != null ? Task.fromJson(response) : null;
  }

  // ✅ Delete a task
  Future<void> deleteTask(String taskId) async {
    await _supabase.from('tasks').delete().eq('id', taskId);
  }

  // ✅ Listen for Real-Time Task Updates
  void listenForTaskUpdates(Function(List<Task>) onUpdate) {
    _supabase.from('tasks').stream(primaryKey: ['id']).listen((data) {
      final updatedTasks = data.map<Task>((json) => Task.fromJson(json)).toList();
      onUpdate(updatedTasks);
    });
  }
}
