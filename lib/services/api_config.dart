import 'package:flutter/foundation.dart';

/// Base URL for the backend, resolved per-platform so local dev actually
/// reaches the docker-compose stack:
/// - Android emulator can't use `localhost` for the host machine — it
///   needs the special `10.0.2.2` alias.
/// - Web, iOS simulator, and desktop all share the host's network
///   directly, so plain `localhost` works.
///
/// This is a dev-only default. A real deployment (behind Caddy/HTTPS —
/// see TaskTrackerServer/docker) should make this configurable rather
/// than hardcoded; that's a natural next step once there's an actual
/// domain to point at.
String get apiBaseUrl {
  if (kIsWeb) return 'http://localhost:8080';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8080';
  return 'http://localhost:8080';
}
