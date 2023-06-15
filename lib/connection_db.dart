import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> join(String team, String password, String name) async {
  // try {
  final response = await http.get(Uri(
      scheme: 'http',
      host: '144.24.185.119',
      port: 1100,
      path: 'join/',
      queryParameters: {
        'team': team,
        'password': password,
        'name': name,
      }));
  if (response.statusCode == 200) {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name);
    prefs.setString('hash_id', json.decode(response.body)['hash_id']);
    return true;
  } else {
    return false;
  }
  // } on SocketException {
  //   return false;
  // } on Exception {
  //   return false;
  // }
}
