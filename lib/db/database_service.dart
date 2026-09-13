import 'package:mysql_client/mysql_client.dart';

class DatabaseService {
  static Future<MySQLConnection> getConnection() async {
    final conn = await MySQLConnection.createConnection(
      host: '10.0.2.2',
      port: 3306,
      userName: 'app_user',
      password: 'app123',
      databaseName: 'student_finance_app',
      secure: false,
    );

    await conn.connect();
    return conn;
  }
}
