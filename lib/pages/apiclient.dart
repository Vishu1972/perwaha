import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<Album> fetchAlbum() async {
  final response = await http.get(
    Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?id=524901&appid='),
    // Send authorization headers to the backend.
    headers: {
      HttpHeaders.authorizationHeader: 'f8da32a5f1ef7d226be6327b6b236013',
    },
  );
  final responseJson = jsonDecode(response.body);

  return Album.fromJson(responseJson);
}

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}
