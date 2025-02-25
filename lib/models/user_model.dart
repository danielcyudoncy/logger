// models/user_model.dart
enum UserRole { admin, assignmentEditor, cameraman, reporter, headOfDepartment }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '', // ✅ Default to empty string if missing
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? 'No Email',
      role: _parseUserRole(json['role'] as String?),
    );
  }

  static UserRole _parseUserRole(String? roleString) {
    if (roleString == null) return UserRole.cameraman; // ✅ Default role

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
        return UserRole.cameraman; // ✅ Safe fallback
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
    };
  }
}
