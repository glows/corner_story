import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'corner_passkeys.dart';

class CornerAuthService {
  CornerAuthService._();
  static final instance = CornerAuthService._();
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'corner_better_auth_token';
  late final passkeys = CornerPasskeys(
    baseUrl: baseUrl,
    headers: () => authHeaders,
  );

  String? _token;
  Future<void>? _googleInitialization;
  String? get token => _token;
  bool get isSignedIn => _token != null;

  String get baseUrl {
    const configured = String.fromEnvironment('CORNER_API_BASE_URL');
    if (configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'/$'), '');
    }
    return 'https://corner-api.flymind.org';
  }

  Map<String, String> get authHeaders => {
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<bool> restoreSession() async {
    _token = await _storage.read(key: _tokenKey);
    if (_token == null) return false;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/get-session'),
        headers: authHeaders,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['user'] != null) return true;
      }
    } catch (_) {
      // A network failure does not invalidate the saved session.
      return true;
    }
    await signOutLocal();
    return false;
  }

  Future<void> requestEmailCode(String email) async {
    await _post('/api/auth/email-otp/send-verification-otp', {
      'email': email.trim(),
      'type': 'sign-in',
    });
  }

  Future<void> signInWithPasskey() async {
    final response = await passkeys.signIn();
    await _storeToken(response);
  }

  Future<void> verifyEmailCode(String email, String code) async {
    final response = await _post('/api/auth/sign-in/email-otp', {
      'email': email.trim(),
      'otp': code.trim(),
    });
    await _storeToken(response);
  }

  Future<void> signInWithGoogle() async {
    const webClientId = String.fromEnvironment('CORNER_GOOGLE_WEB_CLIENT_ID');
    const iosClientId = String.fromEnvironment('CORNER_GOOGLE_IOS_CLIENT_ID');
    if (webClientId.isEmpty ||
        (!kIsWeb && Platform.isIOS && iosClientId.isEmpty)) {
      throw const CornerAuthException(
        'Google Sign-In is not configured for this app.',
      );
    }
    if (kIsWeb || !GoogleSignIn.instance.supportsAuthenticate()) {
      throw const CornerAuthException(
        'Google Sign-In is unavailable on this platform.',
      );
    }
    _googleInitialization ??= GoogleSignIn.instance.initialize(
      serverClientId: webClientId,
      clientId: Platform.isIOS ? iosClientId : null,
    );
    await _googleInitialization;
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const CornerAuthException(
        'Google did not provide an identity token.',
      );
    }
    final response = await _post('/api/auth/sign-in/social', {
      'provider': 'google',
      'idToken': {'token': idToken},
    });
    await _storeToken(response);
  }

  Future<void> _storeToken(http.Response response) async {
    final token = response.headers['set-auth-token'];
    if (token == null || token.isEmpty) {
      throw const CornerAuthException(
        'The server did not return a session token.',
      );
    }
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> signOut() async {
    if (_token != null) {
      try {
        await _post('/api/auth/sign-out', {});
      } catch (_) {
        // Always remove the local credential.
      }
    }
    await signOutLocal();
  }

  Future<void> signOutLocal() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
  }

  Future<http.Response> _post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json', ...authHeaders},
      body: jsonEncode(body),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Request failed. Please try again.';
      try {
        final data = jsonDecode(response.body);
        if (data is Map) {
          message = (data['message'] ?? data['error'] ?? message).toString();
        }
      } catch (_) {}
      throw CornerAuthException(message);
    }
    return response;
  }
}

class CornerAuthException implements Exception {
  const CornerAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
