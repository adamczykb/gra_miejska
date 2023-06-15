import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> join(String team, String password, String name) async {
  try {
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
  } on SocketException {
    return false;
  } on Exception {
    return false;
  }
}

Future<String> get_story(String user_hash_id) async {
  try {
    final response = await http.get(Uri(
        scheme: 'http',
        host: '144.24.185.119',
        port: 1100,
        path: 'get_story/',
        queryParameters: {
          'user_hash_id': user_hash_id,
        }));
    if (response.statusCode == 200) {
      return json.decode(response.body)['response'];
    } else {
      return '';
    }
  } on SocketException {
    return '';
  } on Exception {
    return '';
  }
}

Future<List<Widget>> getLeaderboard(String user_hash_id) async {
  try {
    final response = await http.get(Uri(
        scheme: 'http',
        host: '144.24.185.119',
        port: 1100,
        path: 'get_leaderboard/',
        queryParameters: {
          'user_hash_id': user_hash_id,
        }));
    if (response.statusCode == 200) {
      return json
          .decode(response.body)['response']
          .map<Widget>((element) => Card(
              child: ListTile(
                  title: Text(
                      element['name'] +
                          ', punkty: ' +
                          element['score'].toString(),
                      style: TextStyle(
                          color:
                              element['users'] ? Colors.red : Colors.black)))))
          .toList();
    } else {
      return <Widget>[];
    }
  } on SocketException {
    return <Widget>[];
  } on Exception {
    return <Widget>[];
  }
}
