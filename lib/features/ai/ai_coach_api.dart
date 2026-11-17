import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');
const _developmentApiBaseUrl = 'http://169.58.165.98:8001/api/v1';

class AiCoachMessage {
  const AiCoachMessage({
    required this.role,
    required this.content,
    this.imageBytes,
  });

  final String role;
  final String content;
  final Uint8List? imageBytes;

  Map<String, String> toJson() => {'role': role, 'content': content};
}

class AiCoachException implements Exception {
  const AiCoachException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AiCoachApi {
  factory AiCoachApi({
    String baseUrl = _configuredApiBaseUrl,
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  }) => AiCoachApi._(_validateBaseUrl(baseUrl), secureStorage);

  AiCoachApi._(this._baseUrl, this._secureStorage);

  static const _installationIdKey = 'recalie_ai_installation_id';
  static const _sessionTokenKey = 'recalie_ai_session_token';

  final String _baseUrl;
  final FlutterSecureStorage _secureStorage;
  http.Client? _activeClient;

  static String _validateBaseUrl(String value) {
    var resolved = value.trim();
    if (resolved.isEmpty) {
      if (kReleaseMode) {
        throw const AiCoachException(
          'API_BASE_URL is required for release builds and must use HTTPS.',
        );
      }
      resolved = _developmentApiBaseUrl;
    }
    final uri = Uri.tryParse(resolved);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const AiCoachException('API_BASE_URL must be a complete URL.');
    }
    if (kReleaseMode && uri.scheme != 'https') {
      throw const AiCoachException(
        'Release builds require an HTTPS API_BASE_URL.',
      );
    }
    return resolved.replaceAll(RegExp(r'/$'), '');
  }

  Future<String> send({
    required String message,
    required List<AiCoachMessage> history,
    Uint8List? imageBytes,
    String imageMimeType = '',
  }) async {
    var token = await _secureStorage.read(key: _sessionTokenKey);
    token ??= await _createSession();
    var response = await _postChat(
      token,
      message,
      history,
      imageBytes: imageBytes,
      imageMimeType: imageMimeType,
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      await _secureStorage.delete(key: _sessionTokenKey);
      token = await _createSession();
      response = await _postChat(
        token,
        message,
        history,
        imageBytes: imageBytes,
        imageMimeType: imageMimeType,
      );
    }
    final decoded = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded is Map<String, dynamic> ? decoded['detail'] : null;
      throw AiCoachException(
        detail is String && detail.isNotEmpty
            ? detail
            : 'The AI Coach could not process that request.',
      );
    }
    final reply = decoded is Map<String, dynamic> ? decoded['reply'] : null;
    if (reply is! String || reply.trim().isEmpty) {
      throw const AiCoachException(
        'The AI Coach returned an invalid response.',
      );
    }
    return reply.trim();
  }

  Future<http.Response> _postChat(
    String token,
    String message,
    List<AiCoachMessage> history, {
    Uint8List? imageBytes,
    String imageMimeType = '',
  }) async {
    final recentHistory = history.length <= 20
        ? history
        : history.sublist(history.length - 20);
    return _post('/ai/chat/', {
      'message': message,
      'history': recentHistory.map((e) => e.toJson()).toList(),
      if (imageBytes != null) 'image_base64': base64Encode(imageBytes),
      if (imageBytes != null) 'image_mime_type': imageMimeType,
    }, authorization: 'Bearer $token');
  }

  Future<String> _createSession() async {
    var installationId = await _secureStorage.read(key: _installationIdKey);
    if (installationId == null || installationId.isEmpty) {
      installationId = _randomUuid();
      await _secureStorage.write(
        key: _installationIdKey,
        value: installationId,
      );
    }
    final response = await _post('/ai/session/', {
      'installation_id': installationId,
    });
    final decoded = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded is Map<String, dynamic> ? decoded['detail'] : null;
      throw AiCoachException(
        detail is String && detail.isNotEmpty
            ? detail
            : 'Could not create a secure AI session.',
      );
    }
    final token = decoded is Map<String, dynamic> ? decoded['token'] : null;
    if (token is! String || token.isEmpty) {
      throw const AiCoachException(
        'The AI server returned an invalid session.',
      );
    }
    await _secureStorage.write(key: _sessionTokenKey, value: token);
    return token;
  }

  Future<http.Response> _post(
    String path,
    Map<String, dynamic> body, {
    String? authorization,
  }) async {
    final client = http.Client();
    _activeClient?.close();
    _activeClient = client;
    try {
      return await client
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': ?authorization,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 70));
    } catch (_) {
      throw const AiCoachException(
        'Could not reach the Recalie AI server. Check your connection and try again.',
      );
    } finally {
      if (identical(_activeClient, client)) _activeClient = null;
      client.close();
    }
  }

  dynamic _decode(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      return null;
    }
  }

  String _randomUuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  void cancel() {
    _activeClient?.close();
    _activeClient = null;
  }

  void close() => cancel();
}
