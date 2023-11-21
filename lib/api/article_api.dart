import 'dart:convert';

import 'package:courses_flutter/api/api.dart';
import 'package:courses_flutter/api/auth_api.dart';
import 'package:courses_flutter/model/article.dart';
import 'package:http/http.dart' as http;

class ArticleAPI {
  static Future<List<Article>> getList({String? status}) async {
    Map<String, String> body = {};

    if (status != null) body['status'] = status;

    http.Response response = await http.get(
      Uri(scheme: API.apiScheme, host: API.apiHost, path: "/api/articles", queryParameters: body),
      headers: {
        'Accept': 'application/json',
        'authorization': 'bearer ${AuthAPI.token}',
      },
    );

    if (response.statusCode == 401) throw UnauthenticatedException();
    if (response.statusCode != 200) throw Exception();

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => Article(
              id: e['id'],
              itemId: e['item_id'],
              quantity: e['quantity'],
              taken: e['taken'] == null ? null : DateTime.tryParse(e['taken']),
              canceled: e['canceled'] == null ? null : DateTime.tryParse(e['canceled']),
            ))
        .toList();
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

  static Future<void> validate(int id) async {
    http.Response response = await http.put(
      Uri.parse("${API.apiUrl}/articles/validate/$id"),
      headers: {'authorization': 'bearer ${AuthAPI.token}'},
    );

    if (response.statusCode == 401) throw UnauthenticatedException();
    if (response.statusCode != 200) throw Exception();
  }

  static Future<void> cancel(int id) async {
    http.Response response = await http.put(
      Uri.parse("${API.apiUrl}/articles/cancel/$id"),
      headers: {'authorization': 'bearer ${AuthAPI.token}'},
    );

    if (response.statusCode == 401) throw UnauthenticatedException();
    if (response.statusCode != 200) throw Exception();
  }
}
