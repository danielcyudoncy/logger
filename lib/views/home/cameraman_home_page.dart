// views/home/cameraman_home_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';

class CameramanHomePage extends StatefulWidget {
  const CameramanHomePage({super.key});

  @override
  State<CameramanHomePage> createState() => _CameramanHomePageState();
}

class _CameramanHomePageState extends State<CameramanHomePage> {
  final AuthController authController = Get.find<AuthController>();
  final TaskController taskController = Get.find<TaskController>();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() {
    final user = authController.user.value;
    if (user != null) {
      taskController.fetchTasksForUser(user.id);
    }
  }

  // Function to pick a date
  Future<void> _pickDate() async {
    DateTime initialDate = selectedDate ?? DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Function to pick a time
  Future<void> _pickTime() async {
    TimeOfDay initialTime = selectedTime ?? TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  // This function will navigate to the create task screen (or open a dialog/modal)
  void _createTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create New Task"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const TextField(
                  decoration: InputDecoration(hintText: "Task Title"),
                ),
                const SizedBox(height: 10),
                const TextField(
                  decoration:
                      InputDecoration(hintText: "Task Description"),
                ),
                const SizedBox(height: 10),
                // Date Picker
                ListTile(
                  title: Text(
                    selectedDate == null
                        ? "Pick a date"
                        : "${selectedDate!.toLocal()}".split(' ')[0],
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 10),
                // Time Picker
                ListTile(
                  title: Text(
                    selectedTime == null
                        ? "Pick a time"
                        : selectedTime!.format(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: _pickTime,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Implement task creation logic here (save to database)

                // After task creation, reload tasks for the user
                final user = authController.user.value;
                if (user != null) {
                  taskController.fetchTasksForUser(user.id);
                }

                Navigator.pop(context);
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() =>
            Text('Welcome, ${authController.user.value?.name ?? "Cameraman"}')),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchTasks),
          IconButton(
              icon: const Icon(Icons.logout), onPressed: authController.logout),
        ],
      ),
      body: Obx(() {
  if (taskController.isLoading.value) {
    return const Center(child: CircularProgressIndicator());
  }

  if (kDebugMode) {
    print("User Created Tasks: ${taskController.userCreatedTasks}");
  }

  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _sectionHeader("Tasks Created"),
      taskController.userCreatedTasks.isEmpty
          ? _emptyState("No tasks created.")
          : _taskList(taskController.userCreatedTasks),
    
            const SizedBox(height: 20),

            // ✅ Section for Assigned Tasks
            _sectionHeader("Tasks Assigned"),
            taskController.userAssignedTasks.isEmpty
                ? _emptyState("No tasks assigned.")
                : _taskList(taskController.userAssignedTasks),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _createTask,
        tooltip: 'Create Task', // Open task creation UI or navigate to create task screen
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(message,
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ),
    );
  }

  Widget _taskList(List<Task> tasks) {
    return Column(
      children: tasks.map((task) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(task.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Due: ${task.dueDate}'),
          ),
        );
      }).toList(),
    );
  }
}
