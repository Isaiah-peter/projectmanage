import 'package:postgres/postgres.dart';

import './lib/gen/env.g.dart';

late final Connection conn;
Future<void> ConnectDB() async {
  final endpoint = Endpoint(
    host: Env.dbHost,
    port: Env.dbPort,
    database: Env.dbName,
    username: Env.dbUser,
    password: Env.dbPassword,
  );

  conn = await Connection.open(
    endpoint,
    settings: ConnectionSettings(sslMode: SslMode.disable),
  );
}

Future<void> closeDB() async {
  if (conn.isOpen) {
    await conn.close();
  }
}



Future<void> addTask(String desc, String due, String priority) async {
  await conn.execute(
    Sql.named('INSERT INTO tasks (description, due, priority, status) VALUES (@desc, @due, @priority, @status)'),
    parameters: {
      'desc': desc,
      'due': due,
      'priority': priority,
      'status': 'Pending',
    },
  );
}

Future<List<Map<String, dynamic>>> getTasks() async {
  final result = await conn.execute(Sql.named('SELECT * FROM tasks ORDER BY id'));
  return result
      .map(
        (row) => {
          'id': row[0],
          'description': row[1],
          'due': row[2].toString().split(' ')[0],
          'priority': row[3],
          'status': row[4],
        },
      )
      .toList();
}

Future<void> markDone(int id) async {
  await conn.execute(
    Sql.named('UPDATE tasks SET status = \'Done\' WHERE id = @id'),
    parameters: {'id': id},
  );
}

Future<void> deleteTask(int id) async {
  await conn.execute(
    Sql.named('DELETE FROM tasks WHERE id = @id'),
    parameters: {'id': id},
  );
}
