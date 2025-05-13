import 'dart:convert';
import 'dart:io';

const String filename = 'task.json';

void main(List<String> arg) async {
  if (arg.isEmpty) {
    print("Ussage: managetask.dart [list|add|delete|done]");
    return;
  }

  final command = arg[0];
  final tasks = await loadTasks();

  switch (command) {
    case 'add':
      if (arg.length < 2) {
        print("Please type your task after command e.g add .....");
        return;
      }

      final task = {'description': arg.sublist(1).join(' '), 'done': false};
      tasks.add(task);
      await saveTask(tasks);
      print("task succesfully added");
      break;
    case 'list':
      if (tasks.isEmpty) {
        print("No task found");
      }else{
        for(int i = 0; i < tasks.length; i++) {
          final task = tasks[i];
          final status = task['done'];
          print("$i. $status ${task['description']}");
        }
      }
      break;
    
    case 'done':
      if(arg.length < 2) {
        print("please provide the task number to be mark as done");
        return;
      }

      final index = int.tryParse(arg[1]);
      if(index == null || index < 0 || index > tasks.length) {
        print("enter a valid task number between 0-${tasks.length}");
        return;
      }

      tasks[index]['done'] = true;
      await saveTask(tasks);
      print('task mark as done Nice Job');
      break;
    
    case 'delete':
      if (arg.length < 2) {
        print("please provide the task number to be deleted");
        return;
      }

      final index = int.tryParse(arg[1]);
      if (index == null || index < 0 || index > tasks.length) {
        print("enter a valid task number between 0-${tasks.length}");
        return;
      }

      tasks.remove(index);
      await saveTask(tasks);
      print("task successfully deleted");
      break;
    
    default:
      print("unknown command: $command, please enter [add|list|done|delete]");
  }

}

Future<List<Map<String, dynamic>>> loadTasks() async {
  final file = File(filename);
  if (!await file.exists()) {
    return [];
  }

  final content = await file.readAsString();
  return List<Map<String, dynamic>>.from(jsonDecode(content));
}

Future<void> saveTask(List<Map<String, dynamic>> tasks) async {
  final file = File(filename);
  await file.writeAsString(jsonEncode(tasks));
}