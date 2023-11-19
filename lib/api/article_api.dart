import 'dart:convert';

import 'package:courses_flutter/api/api.dart';
import 'package:courses_flutter/api/auth_api.dart';
import 'package:courses_flutter/model/article.dart';
import 'package:http/http.dart' as http;

class ArticleAPI {
  static Future<List<Article>> getList() async {
    http.Response response = await http.get(
      Uri.parse("${API.apiUrl}/articles"),
      headers: {
        'Accept': 'application/json',
        'authorization': 'bearer ${AuthAPI.token}',
      },
    );

    if (response.statusCode == 401) throw UnauthenticatedException();
    if (response.statusCode != 200) throw Exception();

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Article(e['id'], e['item_id'], e['quantity'],)).toList();
  }

  static Future<void> add(int itemId, int quantity) async {
    http.Response response = await http.post(
      Uri.parse("${API.apiUrl}/articles/$itemId"),
      headers: {'authorization': 'bearer ${AuthAPI.token}'},
      body: {'quantity': quantity.toString()},
    );

    if (response.statusCode == 401) throw UnauthenticatedException();
    if (response.statusCode != 201) throw Exception();
  }
}
