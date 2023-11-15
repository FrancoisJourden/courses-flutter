import 'dart:convert';

import 'package:courses_flutter/model/User.dart';
import 'package:http/http.dart' as http;

class InvalidAuthException implements Exception {}
class UnknownAuthException implements Exception {}

class API {
  static const String apiUrl = "";

  static User? user;
  static String? token;

  static login(String email, String password) async {
    http.Response response = await http.post(
      Uri.parse("$apiUrl/login"),
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );

    switch (response.statusCode) {
      case 401: throw InvalidAuthException();
      case 200: _loginSuccess(response);
      default: throw UnknownAuthException();
    }
  }

  static _loginSuccess(http.Response response){
    final data = jsonDecode(response.body);
    token = data['authorisation']['token'];
    user = User.fromJson(data['user']);
  }

}
