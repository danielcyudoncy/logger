// models/task_model.dart
class Task {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final String assignedToName;
  final String createdBy;
  final String createdByName;
  final bool isCompleted;
  final String status;
  final DateTime? dueDate;
  final String? completionFile; // ✅ Add this field

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedToName,
    required this.createdBy,
    required this.createdByName,
    required this.isCompleted,
    required this.status,
    this.dueDate,
    this.completionFile, // ✅ Initialize it as nullable
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      assignedTo: json['assigned_to'],
      assignedToName: json['assigned_to_name'] ?? 'Unknown',
      createdBy: json['created_by'],
      createdByName: json['created_by_name'] ?? 'Unknown',
      isCompleted: json['is_completed'] ?? false,
      status: json['status'] ?? 'pending',
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      completionFile: json['completion_file'], // ✅ Parse from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assigned_to': assignedTo,
      'assigned_to_name': assignedToName,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'is_completed': isCompleted,
      'status': status,
      'due_date': dueDate?.toIso8601String(),
      'completion_file': completionFile, // ✅ Convert to JSON
    };
  }

  // ✅ Method to update task properties
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? assignedToName,
    String? createdBy,
    String? createdByName,
    bool? isCompleted,
    String? status,
    DateTime? dueDate,
    String? completionFile, // ✅ Allow updating completion file
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      isCompleted: isCompleted ?? this.isCompleted,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completionFile: completionFile ?? this.completionFile,
    );
  }
}
