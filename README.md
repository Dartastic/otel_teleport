# otel_teleport

Dartastic OpenTelemetry bridge for Teleport (zero-trust access for servers, DBs, k8s, apps).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_teleport/otel_teleport.dart';

await tracedTeleport<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return TeleportCallResult(value: r, result: TeleportResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutTeleportInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
