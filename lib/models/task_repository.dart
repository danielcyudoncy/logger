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
          .select() // ✅ Fetches ALL tasks, regardless of status
          .order('due_date', ascending: true);

      return response.map<Task>((json) => Task.fromJson(json)).toList();
    } catch (e) {
      print("❌ Error fetching all tasks: $e");
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
      final response = await Supabase.instance.client
          .from('tasks') // ✅ Ensure this matches your table name in Supabase
          .insert({
            'id': task.id,
            'title': task.title,
            'description': task.description,
            'assigned_to': task.assignedTo,
            'assigned_to_name': task.assignedToName,
            'created_by': task.createdBy,
            'created_by_name': task.createdByName,
            'is_completed': task.isCompleted,
            'status': task.status,
            'due_date': task.dueDate
                ?.toIso8601String(), // ✅ Ensure date is saved correctly
          })
          .select()
          .single();

      if (kDebugMode) {
        print("Task inserted: $response");
      }

      return Task.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error inserting task into Supabase: $e");
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

  // repositories/task_repository.dart
 Future<List<Task>> getUnassignedTasks() async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('assigned_to', 'unassigned') // ✅ Only fetch unassigned tasks
          .or('created_by_role.eq.cameraman,created_by_role.eq.reporter') // ✅ Fetch tasks from Cameramen & Reporters
          .order('due_date', ascending: true);

      return response.map<Task>((json) => Task.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error fetching unassigned tasks: $e");
      }
      return [];
    }
  }

  Future<bool> updateTaskAssignment(
      String taskId, String reporterId, String reporterName) async {
    try {
      await _supabase.from('tasks').update({
        'assigned_to': reporterId,
        'assigned_to_name': reporterName,
        'status': 'assigned'
      }).eq('id', taskId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error updating task assignment: $e");
      }
      return false;
    }
  }

Future<List<Task>> getCreatedTasks(String userId) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('created_by', userId) // ✅ Fetch only tasks the user created
          .order('due_date', ascending: true);

      return response.map<Task>((json) => Task.fromJson(json)).toList();
    } catch (e) {
      print("❌ Error fetching created tasks: $e");
      return [];
    }
  }

  Future<List<Task>> getAssignedTasks(String userId) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('assigned_to', userId) // ✅ Fetch only tasks assigned to the user
          .order('due_date', ascending: true);

      return response.map<Task>((json) => Task.fromJson(json)).toList();
    } catch (e) {
      print("❌ Error fetching assigned tasks: $e");
      return [];
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
