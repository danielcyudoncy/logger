// models/user_model.dart
import 'task_model.dart';

enum UserRole { admin, assignmentEditor, cameraman, reporter, headOfDepartment }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isOnline; // ✅ Track online status
  final String? profilePicture;
  final List<Task> assignedTasks; // ✅ Store assigned tasks

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isOnline = false, // Default to offline
    this.profilePicture,
    this.assignedTasks = const [], // Default to an empty list
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? 'No Email',
      role: _parseUserRole(json['role'] as String?),
      isOnline: json['is_online'] as bool? ?? false,
      profilePicture: json['profile_picture'],
      assignedTasks: (json['tasks'] as List<dynamic>?)
              ?.map((taskJson) => Task.fromJson(taskJson as Map<String, dynamic>))
              .toList() ??
          [], // ✅ Parse tasks from JSON
    );
  }

  

  static UserRole _parseUserRole(String? roleString) {
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
        return UserRole.reporter; // Default role
    }
  }

  String roleToString() {
    return role.toString().split('.').last;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': roleToString(),
      'is_online': isOnline,
      'tasks': assignedTasks.map((task) => task.toJson()).toList(), // ✅ Convert tasks to JSON
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? profilePicture,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
    );}
}
