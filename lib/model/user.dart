class User {
  String name;
  String email;

  User(this.name, this.email);

  static User fromJson(Map<String, dynamic> data) => User(data['name'], data['email']);
}
