import 'package:logger/models/task_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Task>> getAllTasks() async {
    final response = await _supabase
        .from('tasks')
        .select('*')
        .order('created_at', ascending: false);

    return response.map<Task>((json) => Task.fromJson(json)).toList();
  }

  Future<List<Task>> getTasksForUser(String userId) async {
    final response = await _supabase
        .from('tasks')
        .select('*')
        .eq('assigned_to', userId)
        .order('created_at', ascending: false);

    return response.map<Task>((json) => Task.fromJson(json)).toList();
  }

  Future<Task> createTask(Task task) async {
    final response =
        await _supabase.from('tasks').insert(task.toJson()).select().single();

    return Task.fromJson(response);
  }

  Future<Task> updateTask(Task task) async {
    final response = await _supabase
        .from('tasks')
        .update(task.toJson())
        .eq('id', task.id)
        .select('''
          *,
          assigned_to_user:profiles!assigned_to(name),
          created_by_user:profiles!created_by(name)
        ''').single();

    return Task.fromJson({
      ...response,
      'assigned_to_name': response['assigned_to_user']['name'],
      'created_by_name': response['created_by_user']['name'],
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _supabase.from('tasks').delete().eq('id', taskId);
  }
}
