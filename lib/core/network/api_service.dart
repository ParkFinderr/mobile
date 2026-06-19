import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://backend-api-services-173368161554.asia-southeast2.run.app';
  static const String _tokenKey = 'jwt_token';

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> get(String endpoint, {bool requireAuth = false}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body, bool requireAuth = false}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    return http.post(url, headers: headers, body: body != null ? jsonEncode(body) : null);
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body, bool requireAuth = false}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    return http.put(url, headers: headers, body: body != null ? jsonEncode(body) : null);
  }

  Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body, bool requireAuth = false}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    return http.patch(url, headers: headers, body: body != null ? jsonEncode(body) : null);
  }

  Future<http.Response> delete(String endpoint, {bool requireAuth = false}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    return http.delete(url, headers: headers);
  }

  Future<http.Response> multipartPost(
    String endpoint, {
    required List<int> fileBytes,
    required String fileName,
    String fieldName = 'image',
    bool requireAuth = false,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', url);

    if (requireAuth) {
      final token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }
    request.headers['Accept'] = 'application/json';

    final multipartFile = http.MultipartFile.fromBytes(
      fieldName,
      fileBytes,
      filename: fileName,
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }
}
