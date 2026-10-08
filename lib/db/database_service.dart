import 'package:mysql_client/mysql_client.dart';

class DatabaseService {
  static Future<MySQLConnection> getConnection() async {
    // final conn = await MySQLConnection.createConnection(
    //   host: '10.0.2.2',
    //   port: 3306,
    //   userName: 'app_user',
    //   password: 'app123', 
    //   databaseName: 'student_finance_app',
    //   secure: false,
    // );

    final conn = await MySQLConnection.createConnection(
      host: 'mysql-19e02cc5-shariqh311-9c73.a.aivencloud.com',
      port: 27448,
      userName: 'avnadmin',
      password: '',
      databaseName: 'student_finance_app',
      secure: true,
    );

    await conn.connect();
    return conn;
  }
}
