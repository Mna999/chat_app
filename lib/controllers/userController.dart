import 'package:chat_app/models/user.dart';
import 'package:chat_app/repo/usersRepo.dart';

class UserController {
  UsersRepo repo = UsersRepo();

  Future<void> saveUser(User user) async {
    await repo.saveUser(user);
  }

  Future<User> loadUser() async {
    final userJson = await repo.loadUser();
    User val = User.fromJson(userJson);
    return val;
  }

  Future<void> saveUserDate(User user) async {
    await repo.saveUserDate(user);
  }

  Future<List<User>> searchUser(String username, User me) async {
    List<Map<String, dynamic>> jsonList = await repo.search(username);
    List<User> res = jsonList
        .map((e) {
          User user = User.fromJson(e);
          if (user.id != me.id) return user;
          return null;
        })
        .whereType<User>()
        .toList();

    return res;
  }

  Future<bool> usernameExists(String username) async {
    final res = await repo.search(username);
    return res.isNotEmpty;
  }

  Future<User> getUserById(String id) async {
    Map<String, dynamic> json = await repo.getUserById(id);
    User user = User.fromJson(json);
    return user;
  }

  Stream<User> streamUser(String id) {
    return repo.userStream(id).map((event) => User.fromJson(event));
  }
}
