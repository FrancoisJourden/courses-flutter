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
        'authorization': 'bearer ${AuthAPI.token}'
      },
    );

    if (response.statusCode == 401) throw UnauthenticatedException();
    if (response.statusCode != 200) throw Exception();

    final Map<String, dynamic> data = jsonDecode(response.body);
    return Item(data['name'], data['unit'], data['category']);
  }


}
