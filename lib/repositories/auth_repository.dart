// REAL DB CODE COMMENTED FOR NOW
// import '../db/database_service.dart';
import '../mock/mock_data.dart';
import '../models/user_model.dart';

class AuthRepository {
  Future<UserModel?> login(String email, String password) async {
    // MOCK DATA VERSION
    final matchingUsers = MockData.users.where(
      (user) => user['email'] == email && user['password'] == password,
    );

    if (matchingUsers.isEmpty) return null;

    return MockData.userFromMockMap(matchingUsers.first);

    // REAL DB CODE COMMENTED FOR NOW
    // final conn = await DatabaseService.getConnection();
    //
    // final result = await conn.execute(
    //   '''
    //   SELECT id, name, email FROM users
    //   WHERE email = :email AND password = :password
    //   LIMIT 1
    //   ''',
    //   {
    //     'email': email,
    //     'password': password,
    //   },
    // );
    //
    // await conn.close();
    //
    // if (result.rows.isEmpty) return null;
    //
    // return UserModel.fromMap(result.rows.first.assoc());
  }

  Future<bool> register(String name, String email, String password) async {
    // MOCK DATA VERSION
    final emailAlreadyExists = MockData.users.any(
      (user) => user['email'] == email,
    );

    if (emailAlreadyExists) return false;

    MockData.users.add({
      'id': MockData.nextUserId(),
      'name': name,
      'email': email,
      'password': password,
    });

    return true;

    // REAL DB CODE COMMENTED FOR NOW
    // final conn = await DatabaseService.getConnection();
    //
    // await conn.execute(
    //   '''
    //   INSERT INTO users(name, email, password)
    //   VALUES(:name, :email, :password)
    //   ''',
    //   {
    //     'name': name,
    //     'email': email,
    //     'password': password,
    //   },
    // );
    //
    // await conn.close();
    // return true;
  }
}
