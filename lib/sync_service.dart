import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _serverUrlKey = 'rally_marshal_server_url';
const _defaultPort = 8765;

class SyncService {
  static String? _cachedUrl;

  static Future<String?> getServerUrl() async {
    if (_cachedUrl != null) return _cachedUrl;
    final prefs = await SharedPreferences.getInstance();
    _cachedUrl = prefs.getString(_serverUrlKey);
    return _cachedUrl;
  }

  static Future<void> setServerUrl(String? url) async {
    final trimmed = url?.trim();
    _cachedUrl = trimmed?.isEmpty == true ? null : trimmed;
    final prefs = await SharedPreferences.getInstance();
    if (_cachedUrl == null) {
      await prefs.remove(_serverUrlKey);
    } else {
      await prefs.setString(_serverUrlKey, _cachedUrl!);
    }
  }

  /// Sends an entry to the laptop server. Returns null on success, error message on failure.
  /// [tc] from Event Details is sent so the website can split times by TC.
  static Future<String?> sendEntry({
    required String time,
    required int carNumber,
    String tc = '',
  }) async {
    final baseUrl = await getServerUrl();
    if (baseUrl == null || baseUrl.isEmpty) return null; // no server configured, skip silently

    final uri = Uri.parse(baseUrl).replace(path: 'entry');
    if (uri.host.isEmpty) return 'Invalid server address';

    try {
      final body = jsonEncode({
        'time': time,
        'carNumber': carNumber,
        'tc': tc,
      });
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 300) return null;
      return 'Server error: ${response.statusCode}';
    } catch (e) {
      return e.toString();
    }
  }
}

int get defaultSyncPort => _defaultPort;
