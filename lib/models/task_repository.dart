// models/task_repository.dart
import 'package:flutter/foundation.dart';
import 'package:logger/models/task_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Task>> getAllTasks() async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('*')
          .order('created_at', ascending: false);

      // ✅ No need to check for null, just check if empty
      if (response.isEmpty) {
        return [];
      }

      return response
          .map<Task>((json) => Task.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching tasks: $e");
      }
      return [];
    }
  }

  Future<List<Task>> getTasksForUser(String userId) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('*')
          .eq('assigned_to', userId)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return response
          .map<Task>((json) => Task.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user tasks: $e");
      }
      return [];
    }
  }

  Future<Task?> createTask(Task task) async {
    try {
      final response =
          await _supabase.from('tasks').insert(task.toJson()).select().single();

      // ✅ No need to check for null, just return the parsed Task
      return Task.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error creating task: $e");
      }
      return null;
    }
  }

  Future<Task?> updateTask(Task task) async {
    try {
      final response = await _supabase
          .from('tasks')
          .update(task.toJson())
          .eq('id', task.id)
          .select()
          .single();

      return Task.fromJson({
        ...response,
        'assigned_to_name': response['assigned_to_user']?['name'] ?? 'Unknown',
        'created_by_name': response['created_by_user']?['name'] ?? 'Unknown',
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error updating task: $e");
      }
      return null;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _supabase.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting task: $e");
      }
    }
  }
}
