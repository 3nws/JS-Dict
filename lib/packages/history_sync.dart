import "dart:convert";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:jsdict/singletons.dart";

class HistorySync {
  String url = getPreferences().getString("syncUrl") ?? "";

  final http.Client _client;

  HistorySync() : _client = http.Client();

  HistorySync.client(http.Client client) : _client = client;

  Future<bool> _post(String query) async {
    try {
      final response = await _client.post(Uri.parse(url.trim()),
          headers: {
            "Content-Type": "application/json",
            "email": getPreferences().getString("syncEmail") ?? "",
            "password": getPreferences().getString("syncPassword") ?? ""
          },
          body: json.encode({"text": query}));
      if (response.statusCode != 200) {
        debugPrint("Could not send history data!");
      }

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendQuery(String query) async {
    await _post(query);
  }
}
