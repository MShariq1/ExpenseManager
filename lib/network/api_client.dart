import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Edit this URL to point to your backend.
// iOS simulator: localhost; Android emulator: 10.0.2.2.
// Physical phone: use your Mac's reachable LAN IP or hostname.
const String apiBaseUrl = 'http://10.0.2.2:3000/api';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client;
  final Duration timeout;
  final String baseUrl;
  ApiClient({
    http.Client? client,
    String? baseUrl,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       baseUrl = baseUrl ?? apiBaseUrl;

  Uri _uri(String path, Map<String, String>? query) {
    final base = Uri.tryParse(baseUrl);
    if (base == null ||
        !['http', 'https'].contains(base.scheme) ||
        base.host.isEmpty ||
        base.hasQuery ||
        base.hasFragment ||
        base.userInfo.isNotEmpty) {
      throw const ApiException(
        'Set a valid apiBaseUrl in lib/network/api_client.dart',
      );
    }
    return Uri.parse(
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/$path',
    ).replace(queryParameters: query);
  }

  Future<dynamic> request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final stopwatch = Stopwatch()..start();
    _log('REQUEST', {
      'method': method,
      'baseUrl': baseUrl,
      'path': path,
      'query': query,
      'body': body,
    });
    try {
      final uri = _uri(path, query);
      final request = http.Request(method, uri)
        ..headers.addAll({
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        });
      if (body != null) request.body = jsonEncode(body);
      _log('SENDING', {
        'method': method,
        'url': uri.toString(),
        'headers': request.headers,
      });
      final response = await (() async {
        return http.Response.fromStream(await _client.send(request));
      })().timeout(timeout);
      _log('RESPONSE', {
        'method': method,
        'url': uri.toString(),
        'status': response.statusCode,
        'elapsedMs': stopwatch.elapsedMilliseconds,
        'headers': response.headers,
        'body': _responseBody(response.body),
      });
      dynamic json;
      try {
        json = jsonDecode(response.body);
      } on FormatException {
        throw ApiException(
          'Server returned an invalid or empty response. Check the API URL.',
          response.statusCode,
        );
      }
      if (json is! Map<String, dynamic> ||
          json['success'] is! bool ||
          json['message'] is! String) {
        throw const ApiException('Unexpected API response format.');
      }
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] != true) {
        // Do not echo arbitrary server bodies or database diagnostics.
        final message = switch (response.statusCode) {
          401 => 'Invalid email or password.',
          409 => 'Email already exists. Try signing in.',
          404 => 'Record or API route not found. Refresh and try again.',
          400 => 'Invalid input. Check the form fields.',
          _ => 'Server request failed. Please try again later.',
        };
        throw ApiException(message, response.statusCode);
      }
      if (!json.containsKey('data')) {
        throw const ApiException('API response is missing data.');
      }
      return json['data'];
    } on TimeoutException catch (error, stack) {
      _logError(method, path, stopwatch, error, stack);
      throw const ApiException(
        'Request timed out. Refresh the list before repeating a save; it may already have succeeded.',
      );
    } on http.ClientException catch (error, stack) {
      _logError(method, path, stopwatch, error, stack);
      throw const ApiException(
        'Cannot reach the server. Check the API URL, network and backend.',
      );
    } catch (error, stack) {
      _logError(method, path, stopwatch, error, stack);
      rethrow;
    }
  }

  void _logError(
    String method,
    String path,
    Stopwatch timer,
    Object error,
    StackTrace stack,
  ) {
    _log('ERROR', {
      'method': method,
      'path': path,
      'elapsedMs': timer.elapsedMilliseconds,
      'error': error.toString(),
      'stack': stack.toString(),
    });
  }

  dynamic _responseBody(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      return body;
    }
  }

  // Keep diagnostics out of release builds and redact credentials recursively.
  void _log(String event, Map<String, dynamic> details) {
    if (!kDebugMode) return;
    debugPrint('[API] $event');
    const JsonEncoder.withIndent(
      '  ',
    ).convert(_redact(details)).split('\n').forEach(debugPrint);
  }

  dynamic _redact(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(
          key.toString(),
          RegExp(
                r'password|token|authorization|cookie|secret|api[-_]?key',
                caseSensitive: false,
              ).hasMatch(key.toString())
              ? '[REDACTED]'
              : _redact(item),
        ),
      );
    }
    if (value is List) return value.map(_redact).toList();
    return value;
  }

  void close() => _client.close();
}

Map<String, dynamic> objectData(dynamic value) {
  if (value is! Map<String, dynamic>) {
    throw const ApiException('Expected an API object.');
  }
  return value;
}
