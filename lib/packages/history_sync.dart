import "dart:convert";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:jsdict/singletons.dart";

class HistorySync {
  String url = getPreferences().getString("syncUrl") ?? "";
  String bulkUrl = getPreferences().getString("syncBulkUrl") ?? "";

  final http.Client _client;

  HistorySync() : _client = http.Client();

  HistorySync.client(http.Client client) : _client = client;

  Future<bool> _post(Map<String, dynamic> data, {bool bulk = false}) async {
    try {
      final response =
          await _client.post(Uri.parse(!bulk ? url.trim() : bulkUrl.trim()),
              headers: {
                "Content-Type": "application/json",
                "email": getPreferences().getString("syncEmail") ?? "",
                "password": getPreferences().getString("syncPassword") ?? ""
              },
              body: json.encode(data));
      if (response.statusCode != 200) {
        debugPrint("Could not send history data!");
      }

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendQuery(String query) async {
    await _post({"text": query});
  }

  Future<void> sendHistory(List<String> history) async {
    await _post({
      "entries": [
        ...history.map((e) => {"text": e})
      ]
    }, bulk: true);
  }
}
