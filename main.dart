import 'dart:convert';
import 'dart:io';
import 'package:ansi_styles/ansi_styles.dart';

const String filename = 'task.json';

void main(List<String> arg) async {
  if (arg.isEmpty) {
    printUsage();
    return;
  }

  final command = arg[0];
  final tasks = await loadTasks();

  switch (command) {
    case 'add':
      if (arg.length < 4) {
        print(
          "Usage: add 'descriptions' dueDate(YYYY-DD-MM) 'priority(low|medium|high)'",
        );
        return;
      }

      final task = {
        'description': arg[1],
        'dueDate': arg[2],
        'priority': arg[3],
        'done': false,
      };
      tasks.add(task);
      await saveTask(tasks);
      print(AnsiStyles.green("task succesfully added"));
      break;
    case 'list':
      String sortBy = '';
      if (arg.length > 1 && arg[1].startsWith('--sort=')) {
        sortBy = arg[1].split('=')[1];
      }

      if (tasks.isEmpty) {
        print("No task found");
        return;
      }

      if (arg.length > 1 && !arg[1].contains('=')) {
        listFliter(tasks, arg[1], arg[2]);
        return;
      }

      if (sortBy == 'dueDate') {
        tasks.sort(
          (a, b) => DateTime.parse(
            a['dueDate'],
          ).compareTo(DateTime.parse(b['dueDate'])),
        );
      } else if (sortBy == 'priority') {
        const order = {'high': 0, 'medium': 1, 'low': 2};
        tasks.sort(
          (a, b) => order[a['priority']]!.compareTo(order[b['priority']]!),
        );
      }

      for (int i = 0; i < tasks.length; i++) {
        final t = tasks[i];
        final status =
            t['done'] ? AnsiStyles.green('[X]') : AnsiStyles.yellow('[ ]');
        final prio = colorPriority(t['priority']);
        print(
          '$i. $status ${t['description']} '
          '(${AnsiStyles.cyan(t['dueDate'])}) $prio',
        );
      }
      break;

    case 'done':
      if (arg.length < 2) {
        print(
          AnsiStyles.yellow(
            "please provide the task number to be mark as done",
          ),
        );
        return;
      }

      final index = int.tryParse(arg[1]);
      if (index == null || index < 0 || index > tasks.length) {
        print("enter a valid task number between 0-${tasks.length}");
        return;
      }

      tasks[index]['done'] = true;
      await saveTask(tasks);
      print(AnsiStyles.green('task mark as done Nice Job'));
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

String colorPriority(String prio) {
  switch (prio) {
    case 'high':
      return AnsiStyles.red.bold('High');
    case 'medium':
      return AnsiStyles.yellow("Medium");

    default:
      return AnsiStyles.green("Low");
  }
}

void printUsage() {
  print(
    AnsiStyles.yellow('''
    Usage:
    dart run main.dart add "descriptions" "YYYY-DD-MM" "prority"
    dart run main.dart list
    dart run main.dart list high|low|medium
    dart run main.dart done [index]
    dart run main.dart delete [index]
  '''),
  );
}

void listFliter(List<Map<String, dynamic>> tasks, String filter, String value) {
  if (tasks.isEmpty) {
    print("No task found");
  } else {
    for (var task in tasks.where((t) => t['$filter'] == value)) {
      int i = 1;
      final status =
          task['done'] ? AnsiStyles.green('[X]') : AnsiStyles.yellow('[ ]');
      final prio = colorPriority(task['priority']);

      print(
        "$i. $status ${task['description']} ${AnsiStyles.cyan(task['dueDate'])} $prio",
      );

      i += 1;
    }
  }
}
