import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:task_tracker/data/in_memory_pending_changes_repository.dart';
import 'package:task_tracker/data/in_memory_task_repository.dart';
import 'package:task_tracker/data/in_memory_user_repository.dart';
import 'package:task_tracker/data/task_store.dart';
import 'package:task_tracker/data/user_store.dart';
import 'package:task_tracker/models/task.dart';
import 'package:task_tracker/models/task_status.dart';
import 'package:task_tracker/services/api_client.dart';
import 'package:task_tracker/services/auth_token_store.dart';
import 'package:task_tracker/services/key_value_store.dart';
import 'package:task_tracker/services/local_identity.dart';
import 'package:task_tracker/services/server_sync_service.dart';

void main() {
  test('a task created while offline stays queued, then reaches the server once a batch drain succeeds', () async {
    // Simulates exactly the scenario this outbox exists for: the batch
    // endpoint starts out failing (standing in for "offline"/"server
    // unreachable"), then starts succeeding (standing in for "back
    // online") — without ever touching a real network or server.
    var batchShouldFail = true;
    var batchCallCount = 0;

    final client = MockClient((request) async {
      if (request.url.path == '/auth/login' || request.url.path == '/auth/refresh') {
        // ensureFreshAccessToken (called before every push) always hits
        // /auth/refresh rather than decoding the JWT's own expiry
        // client-side — see UserStore's design notes — so this needs
        // to succeed too, not just the initial login.
        return http.Response(
          jsonEncode({'accessToken': 'token', 'refreshToken': 'refresh', 'userId': 'u1', 'userName': 'alex'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (request.url.path == '/users/me') {
        // _applyAuthResponse fetches this right after login/refresh —
        // needs a full MeDto shape or User.fromServerJson throws.
        return http.Response(
          jsonEncode({
            'id': 'u1',
            'userName': 'alex',
            'fullName': null,
            'email': 'alex@example.com',
            'phone': null,
            'countryCode': null,
            'description': null,
            'searchPrivacy': 1,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (request.url.path == '/contacts') {
        return http.Response(jsonEncode([]), 200, headers: {'content-type': 'application/json'});
      }
      if (request.url.path == '/tasks/batch') {
        batchCallCount++;
        if (batchShouldFail) return http.Response('', 503);
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final items = (body['items'] as List).cast<Map<String, dynamic>>();
        return http.Response(
          jsonEncode({'results': items.map((i) => {'id': i['id'], 'success': true, 'error': null}).toList()}),
          202,
          headers: {'content-type': 'application/json'},
        );
      }
      // GET /tasks (the plain pull) — nothing new from the server in
      // this test, every time.
      return http.Response(jsonEncode([]), 200, headers: {'content-type': 'application/json'});
    });

    final apiClient = ApiClient(client: client);
    final userStore = UserStore(
      repository: InMemoryUserRepository(),
      apiClient: apiClient,
      tokenStore: AuthTokenStore(storage: InMemoryKeyValueStore()),
      localIdentity: LocalIdentity(storage: InMemoryKeyValueStore()),
    );
    await userStore.load();
    expect(await userStore.login('alex', 'whatever-the-mock-accepts-anything'), isTrue);

    final pendingChanges = InMemoryPendingChangesRepository();
    final taskStore = TaskStore(
      userStore: userStore,
      repository: InMemoryTaskRepository(),
      pendingChangesRepository: pendingChanges,
      syncService: ServerSyncService(userStore: userStore, apiClient: apiClient),
    );
    await taskStore.load();

    final task = Task(
      id: 'offline-task-1',
      title: 'Created while offline',
      description: '',
      createdAt: DateTime.now(),
      status: TaskStatus.assigned,
      updatedAt: DateTime.now(),
    );

    await taskStore.createTask(task);
    // createTask's own opportunistic push attempt runs in the
    // background (unawaited) — drive the drain explicitly so the test
    // doesn't depend on that background future's timing.
    await taskStore.pullFromServer();

    expect(batchCallCount, greaterThan(0));
    expect(
      (await pendingChanges.getAll()).map((c) => c.taskId),
      contains('offline-task-1'),
      reason: 'the failed push must leave the task queued, not drop it',
    );

    // "Back online."
    batchShouldFail = false;
    await taskStore.pullFromServer();

    expect(await pendingChanges.getAll(), isEmpty, reason: 'a successful drain must clear the outbox');
  });
}
