import 'dart:convert';
import 'package:http/http.dart' as http;

import 'token_store.dart';

/// Dilempar saat backend membalas error terstruktur (validasi/auth/dll).
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException(String rawMessage, this.statusCode, {this.errors})
      : message = _formatMessage(rawMessage, errors);

  static String _formatMessage(String rawMessage, Map<String, dynamic>? errors) {
    if (errors != null && errors.isNotEmpty) {
      final messages = <String>[];
      errors.forEach((key, value) {
        if (value is List) {
          messages.add(value.join(', '));
        } else {
          messages.add(value.toString());
        }
      });
      return messages.join('\n');
    }
    return rawMessage;
  }

  @override
  String toString() => message;
}

class ApiService {
  /// Tunnel localtonet ke backend Laravel lokal. Ganti kalau URL tunnel
  /// berubah (subdomain localtonet gratis biasanya baru tiap restart).
  static const String baseUrl = "https://xbncmdd6jn.localto.net/api";

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await TokenStore.instance.getToken();
    return {
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      'localtonet-skip-warning': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _handle(http.Response response) {
    final body = response.body.isEmpty ? {} : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body is Map && body['message'] != null
        ? body['message'] as String
        : 'Terjadi kesalahan (${response.statusCode})';
    final errors = body is Map && body['errors'] != null
        ? Map<String, dynamic>.from(body['errors'])
        : null;

    throw ApiException(message, response.statusCode, errors: errors);
  }

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );
    return _handle(response);
  }

  Future<dynamic> post(String endpoint, [Map<String, dynamic>? body]) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(response);
  }

  Future<dynamic> put(String endpoint, [Map<String, dynamic>? body]) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );
    return _handle(response);
  }
}
