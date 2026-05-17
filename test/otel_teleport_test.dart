// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_teleport/otel_teleport.dart';
import 'package:test/test.dart';

void main() {
  group('otel_teleport', () {
    test('suppression toggles in zone', () async {
      expect(teleportInstrumentationSuppressed(), isFalse);
      await runWithoutTeleportInstrumentationAsync(() async {
        expect(teleportInstrumentationSuppressed(), isTrue);
      });
      expect(teleportInstrumentationSuppressed(), isFalse);
    });

    test('TeleportResult fields default null', () {
      const r = TeleportResult();
      expect(r.statusCode, isNull);
    });
  });
}
