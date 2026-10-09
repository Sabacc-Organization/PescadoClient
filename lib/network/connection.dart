import 'dart:async';
import 'dart:convert';
import 'package:PescadoClient/main.dart';
import 'package:PescadoClient/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final timeoutDuration = Duration(seconds: 2);

http.Response timeoutCallback() {
  return http.Response("", 408);
}

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
    ).timeout(timeoutDuration, onTimeout: timeoutCallback).then(callback);
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
    ).timeout(timeoutDuration, onTimeout: timeoutCallback)
    .then((res) {
      if (200 <= res.statusCode && res.statusCode < 300) {
        post(context, data: {
          "username": username,
          "password": password,
        }, path: "/preferences",
        callback: (res2) {
          try {
            appwideData.setDarkMode((jsonDecode(res2.body) as Map<String, dynamic>)["dark"] as bool);
          } on FormatException {
            //
          }
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
    ).timeout(timeoutDuration, onTimeout: timeoutCallback)
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

  static void host(
    BuildContext context,
    {required String username,
    required String password,
    required List<String> players,
    required GameVariant variant,
    required FutureOr<Null> Function(http.Response) callback}
  ) {
    var appwideData = AppwideDataProvider.from(context, listen: false);
    final uri = Uri.https(appwideData.backendUrl, "/host");
    http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
        "players": players,
        "game_variant": variant.snakeSlug()
      })
    ).timeout(timeoutDuration, onTimeout: timeoutCallback,)
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
    ).timeout(timeoutDuration, onTimeout: timeoutCallback).then(callback);
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
    ).timeout(timeoutDuration, onTimeout: timeoutCallback);
  }

  static Future<http.Response> myGames(
    BuildContext context,
    {required String player,
    required String password}
  ) {
    var appwideData = AppwideDataProvider.from(context, listen: false);
    final uri = Uri.https(appwideData.backendUrl, "/");
    return http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": player,
        "password": password
      })
    ).timeout(timeoutDuration, onTimeout: timeoutCallback);
  }

  static Future<Player?> playerLookup(
    BuildContext context,
    {String? username,
    int? id}
  ) {
    var appwideData = AppwideDataProvider.from(context, listen: false);
    final uri = Uri.https(appwideData.backendUrl, "/playerLookup");
    return http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": ?username, "id": ?id})
    ).timeout(timeoutDuration, onTimeout: timeoutCallback)
    .then((res) {
      if (200 <= res.statusCode && res.statusCode < 300) {
        Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;
        return Player(username: cast<String>(json["username"])!, id: cast<int>(id));
      }
      return null;
    });
  }
}