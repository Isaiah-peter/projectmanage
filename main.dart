import 'dart:convert';
import 'dart:io';
import 'package:ansi_styles/ansi_styles.dart';
import 'database.dart';

const String filename = 'task.json';

void main(List<String> arg) async {
  if (arg.isEmpty) {
    printUsage();
    return;
  }

  await ConnectDB();
  final command = arg[0];

  switch (command) {
    case 'add':
      if (arg.length < 4) {
        print(
          "Usage: add 'descriptions' dueDate(YYYY-DD-MM) 'priority(low|medium|high)'",
        );
        return;
      }
      await addTask(arg[1], arg[2], arg[3]);
      print(AnsiStyles.green("task succesfully added"));
      await closeDB();
      break;
    case 'list':
      var tasks = await getTasks();

      if (tasks.isEmpty) {
        print("No task found");
        return;
      }

      for (int i = 0; i < tasks.length; i++) {
        final t = tasks[i];
        final status =
            t['status'] == 'Done'
                ? AnsiStyles.green('[X]')
                : AnsiStyles.yellow('[ ]');
        final prio = colorPriority(t['priority']);
        print(
          '$i. $status ${t['description']} '
          '(${AnsiStyles.cyan(t['due'])}) $prio',
        );
      }

      await closeDB();
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

      await markDone(int.parse(arg[2]));
      print(AnsiStyles.green('task mark as done Nice Job'));
      await closeDB();
      break;

    case 'delete':
      if (arg.length < 2) {
        print("please provide the task number to be deleted");
        return;
      }

      await deleteTask(int.parse(arg[1]));
      print("task successfully deleted");
      await closeDB();
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
