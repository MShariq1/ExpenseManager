import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uni_proj/controllers/auth_controller.dart';
import 'package:uni_proj/controllers/expense_controller.dart';
import 'package:uni_proj/models/user_model.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uni_proj/network/api_client.dart';
import 'package:uni_proj/repositories/auth_repository.dart';
import 'package:uni_proj/repositories/expense_repository.dart';
import 'package:uni_proj/models/expense_model.dart';

void main() {
  test('logs request and response details with credentials masked', () async {
    final logs = <String>[];
    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      logs.add(message ?? '');
    };
    addTearDown(() => debugPrint = original);
    final api = ApiClient(
      baseUrl: 'http://localhost/api',
      client: MockClient((request) async {
        expect(jsonDecode(request.body)['password'], 'private-password');
        return http.Response(
          '{"success":true,"message":"ok","data":{"token":"private-token"}}',
          200,
        );
      }),
    );
    addTearDown(api.close);
    await api.request(
      'POST',
      'login',
      query: {'page': '1'},
      body: {'email': 'demo@example.test', 'password': 'private-password'},
    );
    final output = logs.join('\n');
    expect(output, contains('http://localhost/api/login?page=1'));
    expect(output, contains('demo@example.test'));
    expect(output, contains('"status": 200'));
    expect(output, contains('[REDACTED]'));
    expect(output, isNot(contains('private-password')));
    expect(output, isNot(contains('private-token')));
  });

  test('logs configuration errors before sending a request', () async {
    final logs = <String>[];
    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      logs.add(message ?? '');
    };
    addTearDown(() => debugPrint = original);
    final api = ApiClient(
      baseUrl: '',
      client: MockClient((_) async {
        fail('Invalid configuration must not send a request');
      }),
    );
    addTearDown(api.close);
    await expectLater(
      api.request('POST', 'login'),
      throwsA(isA<ApiException>()),
    );
    expect(logs.join('\n'), contains('[API] ERROR'));
    expect(logs.join('\n'), contains('apiBaseUrl'));
  });

  test('newer list request wins and clearing rejects stale failures', () async {
    final responses = <Completer<http.Response>>[];
    final api = ApiClient(
      baseUrl: 'http://localhost/api',
      client: MockClient((_) {
        final response = Completer<http.Response>();
        responses.add(response);
        return response.future;
      }),
    );
    final auth = Get.put(AuthController(api: api));
    auth.currentUser.value = UserModel(
      id: 42,
      name: 'Demo',
      email: 'demo@example.test',
    );
    final controller = Get.put(ExpenseController());
    addTearDown(() => Get.reset());
    final older = controller.loadExpenses();
    await Future<void>.delayed(Duration.zero);
    final newer = controller.loadExpenses();
    await Future<void>.delayed(Duration.zero);
    responses[1].complete(
      http.Response('{"success":true,"message":"ok","data":[]}', 200),
    );
    await newer;
    responses[0].complete(
      http.Response('{"success":false,"message":"old failure"}', 500),
    );
    await older;
    expect(controller.error.value, isEmpty);
    final pending = controller.loadExpenses();
    await Future<void>.delayed(Duration.zero);
    controller.clear();
    responses[2].complete(
      http.Response('{"success":false,"message":"late failure"}', 500),
    );
    await pending;
    expect(controller.expenses, isEmpty);
    expect(controller.error.value, isEmpty);
    expect(controller.isLoading.value, isFalse);
  });
  test(
    'parses decimal strings/numbers, nullable location and calendar date',
    () {
      for (final amount in ['12.30', 12.3]) {
        final e = ExpenseModel.fromMap({
          'id': 7,
          'user_id': 42,
          'title': 'Lunch',
          'amount': amount,
          'location': null,
          'expense_date': '2026-10-26',
        });
        expect(e.amount, 12.3);
        expect(e.location, '');
        expect(e.expenseDate, '2026-10-26');
      }
      expect(
        () => ExpenseModel.fromMap({
          'id': 7,
          'user_id': 42,
          'title': 'X',
          'amount': 'NaN',
          'expense_date': '2026-02-30',
        }),
        throwsA(isA<ApiException>()),
      );
    },
  );
  test('login decodes actual returned user and sends JSON', () async {
    final api = ApiClient(
      baseUrl: 'http://localhost:3000/api',
      client: MockClient((r) async {
        expect(r.url.path, '/api/login');
        expect(jsonDecode(r.body), {
          'email': 'demo@example.test',
          'password': 'test-only',
        });
        expect(r.headers['content-type'], 'application/json');
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'ok',
            'data': {'id': 42, 'name': 'Demo', 'email': 'demo@example.test'},
          }),
          200,
        );
      }),
    );
    addTearDown(api.close);
    expect(
      (await AuthRepository(api).login('demo@example.test', 'test-only')).id,
      42,
    );
  });
  test('list and update use actual user and selected expense IDs', () async {
    final api = ApiClient(
      baseUrl: 'http://localhost:3000/api/',
      client: MockClient((r) async {
        if (r.method == 'GET') {
          expect(r.url.queryParameters['userId'], '42');
          return http.Response(
            '{"success":true,"message":"ok","data":[]}',
            200,
          );
        }
        expect(r.method, 'PUT');
        expect(r.url.path, '/api/expenses/7');
        final body = jsonDecode(r.body);
        expect(body['userId'], 42);
        expect(body['expenseDate'], '2026-10-26');
        return http.Response(
          '{"success":true,"message":"ok","data":{"id":7}}',
          200,
        );
      }),
    );
    addTearDown(api.close);
    final repo = ExpenseRepository(api);
    expect(await repo.getExpenses(42), isEmpty);
    await repo.save(
      id: 7,
      userId: 42,
      title: 'Lunch',
      amount: 12.3,
      location: '',
      expenseDate: '2026-10-26',
    );
  });
  test(
    'fails safely for invalid configuration, envelopes, bodies and status',
    () async {
      final missing = ApiClient(baseUrl: '');
      addTearDown(missing.close);
      await expectLater(
        missing.request('GET', 'expenses'),
        throwsA(isA<ApiException>()),
      );
      for (final response in [
        http.Response('<html>error</html>', 502),
        http.Response('', 200),
        http.Response('[]', 200),
        http.Response('{"success":true,"message":"ok"}', 200),
        http.Response('{"success":false,"message":"sensitive detail"}', 401),
      ]) {
        final api = ApiClient(
          baseUrl: 'http://localhost/api',
          client: MockClient((_) async => response),
        );
        addTearDown(api.close);
        await expectLater(
          api.request('GET', 'expenses'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message.contains('sensitive'),
              'sanitized',
              false,
            ),
          ),
        );
      }
    },
  );
  test(
    'timeout does not retry create, unavailable server yields useful error',
    () async {
      var calls = 0;
      final api = ApiClient(
        baseUrl: 'http://localhost/api',
        timeout: const Duration(milliseconds: 1),
        client: MockClient((_) async {
          calls++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return http.Response('{}', 200);
        }),
      );
      addTearDown(api.close);
      await expectLater(
        api.request('POST', 'expenses', body: {}),
        throwsA(isA<ApiException>()),
      );
      expect(calls, 1);
      final offline = ApiClient(
        baseUrl: 'http://localhost/api',
        client: MockClient((_) async => throw http.ClientException('offline')),
      );
      addTearDown(offline.close);
      await expectLater(
        offline.request('GET', 'expenses'),
        throwsA(isA<ApiException>()),
      );
    },
  );
}
