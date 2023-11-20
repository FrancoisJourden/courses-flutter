import 'dart:convert';

import 'package:courses_flutter/api/api.dart';
import 'package:courses_flutter/api/auth_api.dart';
import 'package:courses_flutter/model/item.dart';
import 'package:http/http.dart' as http;

class ItemApi {
  static Future<Item> get(int id) async {
    http.Response response = await http.get(
      Uri.parse("${API.apiUrl}/items/$id"),
      headers: {
        'Accept': 'application/json',
        'authorization': 'bearer ${AuthAPI.token}',
      },
    );

    if (response.statusCode == 401) throw UnauthenticatedException();
    if (response.statusCode != 200) throw Exception();

    final Map<String, dynamic> data = jsonDecode(response.body);
    return Item(id: data['id'], name: data['name'], unit: data['unit'], category: data['category']);
  }

  static Future<List<Item>> search(String query) async {
    String uri = "${API.apiUrl}/items/search/$query";

    if (uri.endsWith('/')) uri = uri.substring(0, uri.length - 1);

    http.Response response = await http.get(
      Uri.parse(uri),
      headers: {'Accept': 'application/json', 'authorization': 'bearer ${AuthAPI.token}'},
    );

    if (response.statusCode == 401) throw UnauthenticatedException();
    if (response.statusCode != 200) throw Exception();

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((item) => Item(
              id: item['id'],
              name: item['name'],
              unit: item['unit'],
              category: item['category'],
            ))
        .toList();
  }

  static Future<void> add(String name, String? unit, String? category) async {
    final body = {"name": name};
    if (unit != null) body['unit'] = unit;
    if (category != null) body['category'] = category;

    final response = await http.post(
      Uri.parse("${API.apiUrl}/items"),
      headers: {'Accept': 'application/json', 'authorization': 'bearer ${AuthAPI.token}'},
      body: body,
    );

    if (response.statusCode == 401) throw UnauthenticatedException();
    if (response.statusCode != 201) throw Exception();
  }
}
