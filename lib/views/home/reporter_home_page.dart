// views/home/reporter_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';

class ReporterHomePage extends StatefulWidget {
  const ReporterHomePage({super.key});

  @override
  State<ReporterHomePage> createState() => _ReporterHomePageState();
}

class _ReporterHomePageState extends State<ReporterHomePage> {
  final AuthController authController =
      Get.put(AuthController(), permanent: true);
  final TaskController taskController =
      Get.put(TaskController(), permanent: true);

  String selectedFilter = "All"; // Default filter

  @override
  void initState() {
    super.initState();
    if (authController.user.value != null) {
      taskController.fetchTasksForUser(
          authController.user.value!.id); // ✅ Fetch reporter's tasks
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() =>
            Text('Welcome, ${authController.user.value?.name ?? "Reporter"}')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                taskController.fetchTasksForUser(authController.user.value!.id),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // ✅ Task Filters (All, Pending, Submitted, Approved, Rejected)
         Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // ✅ Allow horizontal scrolling
              child: Row(
                children: [
                  _filterButton("All"),
                  const SizedBox(width: 8),
                  _filterButton("Pending"),
                  const SizedBox(width: 8),
                  _filterButton("Submitted"),
                  const SizedBox(width: 8),
                  _filterButton("Approved"),
                  const SizedBox(width: 8),
                  _filterButton("Rejected"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ✅ Task List
          Expanded(
            child: Obx(() {
              final user = authController.user.value;
              if (user == null) {
                Get.offAllNamed('/login');
                return Container();
              }

              final allTasks = taskController.getTasksForUser(user.id);
              final tasks = _filterTasks(allTasks);

              if (tasks.isEmpty) {
                return const Center(child: Text("No tasks assigned to you."));
              }

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _taskCard(task);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ✅ Task Filter Button
  Widget _filterButton(String filter) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedFilter == filter ? Colors.blue : Colors.grey[300],
        foregroundColor: selectedFilter == filter ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Text(filter),
    );
  }

  // ✅ Task Card UI
  Widget _taskCard(Task task) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assigned by: ${task.createdByName}'),
            Text(
                'Assigned Cameraman: ${task.assignedToName}'), // ✅ Display assigned Cameraman
            if (task.dueDate != null)
              Text(
                'Due Date: ${DateFormat.yMMMd().format(task.dueDate!)}',
                style: const TextStyle(color: Colors.red),
              ),
            Row(
              children: [
                Icon(
                  task.status == "approved"
                      ? Icons.verified
                      : task.status == "rejected"
                          ? Icons.cancel
                          : task.isCompleted
                              ? Icons.check_circle
                              : Icons.pending,
                  color: task.status == "approved"
                      ? Colors.green
                      : task.status == "rejected"
                          ? Colors.red
                          : task.isCompleted
                              ? Colors.blue
                              : Colors.orange,
                ),
                const SizedBox(width: 5),
                Text(
                  task.status.capitalize ?? "Unknown",
                  style: TextStyle(
                    color: task.status == "approved"
                        ? Colors.green
                        : task.status == "rejected"
                            ? Colors.red
                            : Colors.black,
                  ),
                ),
              ],
            ),
            if (task.isCompleted && task.completionFile != null)
              TextButton(
                onPressed: () => _openFile(task.completionFile!),
                child: const Text("View Submitted Work",
                    style: TextStyle(color: Colors.blue)),
              ),
          ],
        ),
        trailing: task.isCompleted
            ? const Icon(Icons.check, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.upload_file, color: Colors.blue),
                onPressed: () => _submitWork(task),
              ),
      ),
    );
  }

  // ✅ Task Filtering Function
  List<Task> _filterTasks(List<Task> allTasks) {
    if (selectedFilter == "Pending") {
      return allTasks.where((task) => !task.isCompleted).toList();
    } else if (selectedFilter == "Submitted") {
      return allTasks
          .where((task) => task.isCompleted && task.status == "pending")
          .toList();
    } else if (selectedFilter == "Approved") {
      return allTasks.where((task) => task.status == "approved").toList();
    } else if (selectedFilter == "Rejected") {
      return allTasks.where((task) => task.status == "rejected").toList();
    }
    return allTasks;
  }

  // ✅ Open Submitted File Link
  void _openFile(String fileUrl) {
    Get.snackbar("Opening File", "Redirecting to: $fileUrl");
    // You can use url_launcher package here to open the link
  }

  // ✅ Submit Work Dialog
  void _submitWork(Task task) {
    TextEditingController linkController = TextEditingController();
    TextEditingController commentController = TextEditingController();

    Get.defaultDialog(
      title: "Submit Completed Work",
      content: Column(
        children: [
          const Text("Enter the file link or upload the work."),
          const SizedBox(height: 10),
          TextField(
            controller: linkController,
            decoration: const InputDecoration(labelText: "File Link"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: commentController,
            decoration: const InputDecoration(labelText: "Comments (Optional)"),
          ),
        ],
      ),
      textConfirm: "Submit",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (linkController.text.isEmpty) {
          Get.snackbar("Error", "Please enter a valid file link.");
          return;
        }

        Task updatedTask = task.copyWith(
          isCompleted: true,
          status: "pending",
          completionFile: linkController.text.trim(),
        );

        taskController.updateTask(updatedTask);
        Get.back();
        Get.snackbar("Success", "Work submitted successfully!");
      },
    );
  }
}
