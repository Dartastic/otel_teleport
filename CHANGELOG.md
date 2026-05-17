# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedTeleport<T>(...)` — wraps a otel_teleport call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutTeleportInstrumentation()` / `Async()`.
