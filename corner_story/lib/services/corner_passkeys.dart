import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';

import 'passkey_http.dart' if (dart.library.js_interop) 'passkey_http_web.dart';

abstract interface class PasskeyDevice {
  Future<Map<String, dynamic>> authenticate(Map<String, dynamic> options);
  Future<Map<String, dynamic>> register(Map<String, dynamic> options);
}

class PasskeyFlowException implements Exception {
  const PasskeyFlowException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CornerPasskeys {
  CornerPasskeys({
    required this.baseUrl,
    required this.headers,
    PasskeyDevice? device,
    http.Client? client,
  }) : device = device ?? SystemPasskeyDevice(),
       client = client ?? createPasskeyHttpClient();
  final String baseUrl;
  final Map<String, String> Function() headers;
  final PasskeyDevice device;
  final http.Client client;
  bool _busy = false;

  String? get unavailableReason {
    if (kIsWeb && Uri.base.host != Uri.parse(baseUrl).host) {
      return 'For passkeys, open $baseUrl/app/ in your browser. You can still sign in here with email.';
    }
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android) {
      return 'Passkeys are currently available on Android and the secure Web app. Use email on this device.';
    }
    return null;
  }

  Future<T> _ceremony<T>(Future<T> Function() action) async {
    if (_busy) {
      throw const PasskeyFlowException(
        'A passkey request is already in progress.',
      );
    }
    final reason = unavailableReason;
    // Injected devices allow platform-independent protocol tests.
    if (device is SystemPasskeyDevice && reason != null) {
      throw PasskeyFlowException(reason);
    }
    _busy = true;
    try {
      return await action();
    } on PasskeyFlowException {
      rethrow;
    } catch (error, stack) {
      if (kDebugMode) {
        final code = error is PlatformException
            ? error.code
            : error is UnhandledAuthenticatorException
            ? error.code
            : '';
        debugPrint('CornerPasskeys failure: ${error.runtimeType} $code');
        debugPrintStack(stackTrace: stack, maxFrames: 5);
      }
      throw PasskeyFlowException(passkeyErrorMessage(error));
    } finally {
      _busy = false;
    }
  }

  Future<http.Response> signIn() => _ceremony(() async {
    final options = await _request('generate-authenticate-options');
    final credential = await device.authenticate(
      jsonDecode(options.body) as Map<String, dynamic>,
    );
    return _request(
      'verify-authentication',
      body: {'response': credential},
      cookie: _challengeCookie(options),
    );
  });

  Future<void> register(String name) => _ceremony(() async {
    final options = await _request('generate-register-options');
    final credential = await device.register(
      jsonDecode(options.body) as Map<String, dynamic>,
    );
    await _request(
      'verify-registration',
      body: {'response': credential, 'name': name.trim()},
      cookie: _challengeCookie(options),
    );
  });

  Future<List<Map<String, dynamic>>> list() async {
    final response = await _request('list-user-passkeys');
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  Future<void> rename(String id, String name) async {
    await _request('update-passkey', body: {'id': id, 'name': name.trim()});
  }

  Future<void> delete(String id) async {
    await _request('delete-passkey', body: {'id': id});
  }

  String? _challengeCookie(http.Response response) {
    if (kIsWeb) return null; // Browser owns the HttpOnly cookie.
    final value = response.headers['set-cookie'] ?? '';
    final match = RegExp(r'(?:^|,\s*)([\w.-]*passkey)=([^;,\s]+)')
        .firstMatch(value);
    return match == null ? null : '${match[1]}=${match[2]}';
  }

  Future<http.Response> _request(
    String endpoint, {
    Map<String, dynamic>? body,
    String? cookie,
  }) async {
    final request = http.Request(
      body == null ? 'GET' : 'POST',
      Uri.parse('$baseUrl/api/auth/passkey/$endpoint'),
    );
    request.headers.addAll({
      'Content-Type': 'application/json',
      ...headers(),
      if (!kIsWeb) 'Origin': Uri.parse(baseUrl).origin,
      'Cookie': ?cookie,
    });
    if (body != null) request.body = jsonEncode(body);
    final response = await http.Response.fromStream(
      await client.send(request).timeout(const Duration(seconds: 30)),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Passkey request failed. Please try again or use email.';
      try {
        final data = jsonDecode(response.body) as Map;
        message = (data['message'] ?? data['error'] ?? message).toString();
      } catch (_) {}
      throw PasskeyFlowException(message);
    }
    return response;
  }
}

class SystemPasskeyDevice implements PasskeyDevice {
  PasskeyAuthenticator get _authenticator => PasskeyAuthenticator();
  @override
  Future<Map<String, dynamic>> authenticate(
    Map<String, dynamic> options,
  ) async {
    // Require a system biometric/PIN check; the server also checks the signed UV flag.
    final response = await _authenticator.authenticate(
      AuthenticateRequestType.fromJson({
        ...options,
        'userVerification': 'required',
      }, preferImmediatelyAvailableCredentials: false),
    );
    return response.toJson();
  }

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> options) async {
    final response = await _authenticator.register(
      RegisterRequestType.fromJson(options),
    );
    return response.toJson();
  }
}

String passkeyErrorMessage(Object error) {
  if (error is UnhandledAuthenticatorException &&
      error.code.contains('CREDENTIAL_PROVIDER_CONFIGURATION_EXCEPTION')) {
    return 'Update Google Play services and enable Google Password Manager on this device, then try again. You can continue using email.';
  }
  if (error is PasskeyAuthCancelledException ||
      error.toString().contains('NotAllowedError')) {
    return 'Passkey verification was cancelled or timed out. Try again or use email.';
  }
  if (error is NoCredentialsAvailableException) {
    return 'No matching passkey. Sign in with email first, then add a passkey in Privacy.';
  }
  if (error is ExcludeCredentialsCanNotBeRegisteredException) {
    return 'This device already has a passkey for your account.';
  }
  if (error is MissingGoogleSignInException ||
      error is SyncAccountNotAvailableException) {
    return 'Sign in to Google on this Android device and enable a screen lock to use passkeys.';
  }
  if (error is DomainNotAssociatedException) {
    return 'This app signing certificate is not associated with the passkey domain. Use email and update the app.';
  }
  if (error is DeviceNotSupportedException ||
      error is PasskeyUnsupportedException ||
      error is NoCreateOptionException) {
    return 'Passkeys are unavailable. Enable a credential provider and screen lock, or use email.';
  }
  return 'Could not complete passkey verification. Try again or use email.';
}
