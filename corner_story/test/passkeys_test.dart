import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:corner_story/services/corner_passkeys.dart';
import 'package:passkeys/types.dart';

class TestDevice implements PasskeyDevice {
  bool cancelled = false;
  int prompts = 0;
  @override
  Future<Map<String, dynamic>> authenticate(
    Map<String, dynamic> options,
  ) async {
    prompts++;
    if (cancelled) {
      throw const PasskeyFlowException('Cancelled. Use email or try again.');
    }
    return {
      'id': 'device-credential',
      'response': {'signature': 'device-signature'},
    };
  }

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> options) =>
      authenticate(options);
}

void main() {
  test('missing Android credential provider explains the required Google Play update', () {
    final message = passkeyErrorMessage(
      UnhandledAuthenticatorException(
        'android-unhandledandroidx.credentials.TYPE_CREATE_CREDENTIAL_PROVIDER_CONFIGURATION_EXCEPTION',
        'createCredentialAsync no provider dependencies found',
        null,
      ),
    );
    expect(message, contains('Update Google Play services'));
    expect(message, contains('email'));
  });
  test(
    'cancellation never submits a verification or returns a login result',
    () async {
      final device = TestDevice()..cancelled = true;
      final requests = <http.Request>[];
      final service = CornerPasskeys(
        baseUrl: 'https://corner-api.flymind.org',
        headers: () => {},
        device: device,
        client: MockClient((request) async {
          requests.add(request);
          return http.Response('{"challenge":"server-challenge"}', 200);
        }),
      );
      await expectLater(service.signIn(), throwsA(isA<PasskeyFlowException>()));
      expect(requests.length, 1);
      expect(
        requests.single.url.path,
        endsWith('generate-authenticate-options'),
      );
    },
  );
  test(
    'server rejection is propagated and signed challenge cookie is sent back',
    () async {
      final service = CornerPasskeys(
        baseUrl: 'https://corner-api.flymind.org',
        headers: () => {},
        device: TestDevice(),
        client: MockClient((request) async {
          if (request.method == 'GET') {
            return http.Response(
              '{"challenge":"server-challenge"}',
              200,
              headers: {
                'set-cookie': '__Secure-better-auth.better-auth-passkey=signed-challenge; HttpOnly; Secure; Path=/',
              },
            );
          }
          expect(
            request.headers['cookie'],
            '__Secure-better-auth.better-auth-passkey=signed-challenge',
          );
          expect(request.headers['origin'], 'https://corner-api.flymind.org');
          expect(
            jsonDecode(request.body)['response']['id'],
            'device-credential',
          );
          return http.Response('{"message":"Invalid signature"}', 401);
        }),
      );
      await expectLater(
        service.signIn(),
        throwsA(predicate((e) => e.toString().contains('Invalid signature'))),
      );
    },
  );
  test(
    'registering requires an existing session before opening the device prompt',
    () async {
      final device = TestDevice();
      final service = CornerPasskeys(
        baseUrl: 'https://corner-api.flymind.org',
        headers: () => {},
        device: device,
        client: MockClient(
          (request) async =>
              http.Response('{"message":"Sign in required"}', 401),
        ),
      );
      await expectLater(
        service.register('My phone'),
        throwsA(isA<PasskeyFlowException>()),
      );
      expect(device.prompts, 0);
    },
  );
}
