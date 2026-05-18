// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_teleport_suppression.dart';

class TeleportResult {
  const TeleportResult({
    this.cluster,
    this.proxyAddress,
    this.user,
    this.role,
    this.nodeName,
    this.nodeKind,
    this.sessionId,
    this.recordingMode,
    this.mfa,
    this.deviceTrust,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? cluster;
  final String? proxyAddress;
  final String? user;
  final String? role;
  final String? nodeName;
  final String? nodeKind;
  final String? sessionId;
  final String? recordingMode;
  final bool? mfa;
  final bool? deviceTrust;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class TeleportCallResult<T> {
  const TeleportCallResult({required this.value, this.result});
  final T value;
  final TeleportResult? result;
}

Future<T> tracedTeleport<T>({
  required String operation,
  required Future<TeleportCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (teleportInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_teleport');
  final span = t.startSpan('teleport $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'teleport');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.cluster != null) {
        span.setStringAttribute('teleport.cluster', res.cluster!);
      }
      if (res.proxyAddress != null) {
        span.setStringAttribute('server.address', res.proxyAddress!);
      }
      if (res.user != null) {
        span.setStringAttribute('user.email', res.user!);
      }
      if (res.role != null) {
        span.setStringAttribute('teleport.role', res.role!);
      }
      if (res.nodeName != null) {
        span.setStringAttribute('teleport.node.name', res.nodeName!);
      }
      if (res.nodeKind != null) {
        span.setStringAttribute('teleport.node.kind', res.nodeKind!);
      }
      if (res.sessionId != null) {
        span.setStringAttribute('teleport.session.id', res.sessionId!);
      }
      if (res.recordingMode != null) {
        span.setStringAttribute(
          'teleport.session.recording_mode',
          res.recordingMode!,
        );
      }
      if (res.mfa != null) {
        span.setBoolAttribute('teleport.mfa', res.mfa!);
      }
      if (res.deviceTrust != null) {
        span.setBoolAttribute('teleport.device_trust', res.deviceTrust!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('teleport.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'teleport.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
