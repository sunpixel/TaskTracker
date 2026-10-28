import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Thrown for any non-2xx response. [statusCode] 401 specifically means
/// the access token is missing/expired/invalid — callers (ServerSyncService)
/// use that to trigger a refresh-and-retry.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thin, stateless REST wrapper — doesn't know about tokens beyond
/// attaching whichever one it's handed per call. Token lifecycle
/// (refresh-on-401, storage) is ServerSyncService's job, not this one's.
class ApiClient {
  final http.Client _http;

  ApiClient({http.Client? client}) : _http = client ?? http.Client();

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$apiBaseUrl$path').replace(queryParameters: query);

  Map<String, String> _headers([String? token]) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // --- Auth ---

  /// [phone], if given, should already be digits-only (the national
  /// number, no dial code) — see `utils/input_validators.dart`.
  /// [countryCode] is that enum's ordinal (see `models/country_code.dart`),
  /// required by the server whenever [phone] is non-null.
  Future<Map<String, dynamic>> signup({
    required String userName,
    required String email,
    required String password,
    String? fullName,
    String? phone,
    int? countryCode,
  }) async {
    final res = await _http.post(
      _uri('/auth/signup'),
      headers: _headers(),
      body: jsonEncode({
        'userName': userName,
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
        'countryCode': countryCode,
      }),
    );
    return _decodeMap(res);
  }

  Future<Map<String, dynamic>> login({required String userName, required String password}) async {
    final res = await _http.post(
      _uri('/auth/login'),
      headers: _headers(),
      body: jsonEncode({'userName': userName, 'password': password}),
    );
    return _decodeMap(res);
  }

  Future<Map<String, dynamic>> refresh({required String refreshToken}) async {
    final res = await _http.post(
      _uri('/auth/refresh'),
      headers: _headers(),
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    return _decodeMap(res);
  }

  /// Best-effort — failures are swallowed by the caller; logging out
  /// locally should never be blocked by a network hiccup.
  Future<void> logout({required String refreshToken}) async {
    final res = await _http.post(
      _uri('/auth/logout'),
      headers: _headers(),
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    _checkOk(res);
  }

  // --- Users ---

  Future<Map<String, dynamic>> getMe({required String accessToken}) async {
    final res = await _http.get(_uri('/users/me'), headers: _headers(accessToken));
    return _decodeMap(res);
  }

  /// [searchPrivacy] is the enum's ordinal (see `models/search_privacy.dart`).
  Future<Map<String, dynamic>> updatePrivacy({required String accessToken, required int searchPrivacy}) async {
    final res = await _http.put(
      _uri('/users/me/privacy'),
      headers: _headers(accessToken),
      body: jsonEncode({'searchPrivacy': searchPrivacy}),
    );
    return _decodeMap(res);
  }

  /// [query] can be a username (partial or exact, depending on the
  /// target's privacy setting) or a phone number (exact match only) —
  /// the server auto-detects which based on its shape.
  Future<List<dynamic>> searchUsers({required String accessToken, required String query}) async {
    final res = await _http.get(_uri('/users/search', {'query': query}), headers: _headers(accessToken));
    return _decodeList(res);
  }

  // --- Tasks ---

  Future<List<dynamic>> getTasks({required String accessToken, DateTime? since}) async {
    final res = await _http.get(
      _uri('/tasks', since != null ? {'since': since.toUtc().toIso8601String()} : null),
      headers: _headers(accessToken),
    );
    return _decodeList(res);
  }

  Future<void> createTask({required String accessToken, required Map<String, dynamic> body}) async {
    final res = await _http.post(_uri('/tasks'), headers: _headers(accessToken), body: jsonEncode(body));
    _checkOk(res);
  }

  Future<void> updateTask({
    required String accessToken,
    required String id,
    required Map<String, dynamic> body,
  }) async {
    final res = await _http.put(_uri('/tasks/$id'), headers: _headers(accessToken), body: jsonEncode(body));
    _checkOk(res);
  }

  Future<void> quickToggleTask({required String accessToken, required String id}) async {
    final res = await _http.patch(_uri('/tasks/$id/quick-toggle'), headers: _headers(accessToken));
    _checkOk(res);
  }

  Future<void> deleteTask({required String accessToken, required String id}) async {
    final res = await _http.delete(_uri('/tasks/$id'), headers: _headers(accessToken));
    _checkOk(res);
  }

  // --- Contacts ---

  Future<List<dynamic>> getContacts({required String accessToken}) async {
    final res = await _http.get(_uri('/contacts'), headers: _headers(accessToken));
    return _decodeList(res);
  }

  Future<Map<String, dynamic>> addContact({required String accessToken, required String contactUserName}) async {
    final res = await _http.post(
      _uri('/contacts'),
      headers: _headers(accessToken),
      body: jsonEncode({'contactUserName': contactUserName}),
    );
    return _decodeMap(res);
  }

  Future<void> removeContact({required String accessToken, required String contactId}) async {
    final res = await _http.delete(_uri('/contacts/$contactId'), headers: _headers(accessToken));
    _checkOk(res);
  }

  // --- helpers ---

  Map<String, dynamic> _decodeMap(http.Response res) {
    _checkOk(res);
    if (res.body.isEmpty) return {};
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  List<dynamic> _decodeList(http.Response res) {
    _checkOk(res);
    if (res.body.isEmpty) return [];
    return jsonDecode(res.body) as List<dynamic>;
  }

  void _checkOk(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    var message = res.reasonPhrase ?? 'Request failed';
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map && decoded['error'] != null) message = decoded['error'].toString();
    } catch (_) {
      // Body wasn't JSON (or was empty) — stick with the reason phrase.
    }
    throw ApiException(res.statusCode, message);
  }
}
