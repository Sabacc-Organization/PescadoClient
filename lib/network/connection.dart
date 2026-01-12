import 'dart:async';
import 'dart:convert';
import 'package:PescadoClient/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SabaccConnectionManager {
  static void post(
    BuildContext context,
    {required Object data,
    required String path,
    required FutureOr<Null> Function(http.Response) callback}
  ) {
    var appwideData = AppwideDataProvider.from(context, listen: false);
    final uri = Uri.https(appwideData.backendUrl, path);
    http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data)
    ).timeout(Duration(seconds: 5)).then(callback);
  }

  static void login(
    BuildContext context,
    {required String username,
    required String password,
    required FutureOr<Null> Function(http.Response) callback}
  ) {
    var appwideData = AppwideDataProvider.from(context, listen: false);
    final uri = Uri.https(appwideData.backendUrl, "/login");
    http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password})
    ).timeout(Duration(seconds: 5))
    .then((res) {
      if (200 <= res.statusCode && res.statusCode < 300) {
        post(context, data: {
          "username": username,
          "password": password,
        }, path: "/preferences",
        callback: (res2) {
          appwideData.setDarkMode((jsonDecode(res2.body) as Map<String, dynamic>)["dark"] as bool);
        });
      }
      return res;
    })
    .then(callback);
  }

  static void register(
    BuildContext context,
    {required String username,
    required String password,
    required String confirmPassword,
    required FutureOr<Null> Function(http.Response) callback}
  ) {
    var appwideData = AppwideDataProvider.from(context, listen: false);
    final uri = Uri.https(appwideData.backendUrl, "/register");
    http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password, "confirmPassword": confirmPassword})
    ).timeout(Duration(seconds: 5))
    .then((res) {
      if (200 <= res.statusCode && res.statusCode < 300) {
        preferences(context, update: false, callback: (res2) {
          appwideData.setDarkMode((jsonDecode(res2.body) as Map<String, dynamic>)["dark"]);
        });
      }
      return res;
    })
    .then(callback);
  }

  static void preferences(
    BuildContext context,
    {required FutureOr<Null> Function(http.Response) callback,
    bool update = true}
  ) {
    var appwideData = AppwideDataProvider.from(context, listen: false);
    final uri = Uri.https(appwideData.backendUrl, "/preferences");
    http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": appwideData.username,
        "password": appwideData.password,
        if (update) "dark": appwideData.darkMode
      })
    ).timeout(Duration(seconds: 5)).then(callback);
  }

  static Future<http.Response> playerStats(
    BuildContext context,
    {required String player}
  ) {
    var appwideData = AppwideDataProvider.from(context, listen: false);
    final uri = Uri.https(appwideData.backendUrl, "/player");
    return http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": player})
    ).timeout(Duration(seconds: 5));
  }
}