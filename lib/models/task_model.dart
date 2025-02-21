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
  final DateTime? completionTimestamp;
  final String status;
  final DateTime? dueDate; // ✅ Add dueDate field

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedToName,
    required this.createdBy,
    required this.createdByName,
    required this.isCompleted,
    this.completionTimestamp,
    required this.status,
    this.dueDate, // ✅ Add this to the constructor
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      assignedTo: json['assignedTo'] as String,
      assignedToName: json['assignedToName'] as String,
      createdBy: json['createdBy'] as String,
      createdByName: json['createdByName'] as String,
      isCompleted: json['isCompleted'] as bool,
      completionTimestamp: json['completionTimestamp'] != null
          ? DateTime.parse(json['completionTimestamp'])
          : null,
      status: json['status'] ?? 'pending',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null, // ✅ Parse dueDate
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'isCompleted': isCompleted,
      'completionTimestamp': completionTimestamp?.toIso8601String(),
      'status': status,
      'dueDate': dueDate?.toIso8601String(), // ✅ Convert dueDate to String
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? assignedToName,
    String? createdBy,
    String? createdByName,
    bool? isCompleted,
    DateTime? completionTimestamp,
    String? status,
    DateTime? dueDate, // ✅ Add this to copyWith()
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
      completionTimestamp: completionTimestamp ?? this.completionTimestamp,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate, // ✅ Ensure dueDate is updated
    );
  }
}
