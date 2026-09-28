# Changelog

All notable changes to MoonUUID are documented here.

## 0.1.0 - 2026-09-28

Initial release candidate.

### Added

- RFC 9562 UUID representation, parsing and formatting.
- Canonical, compact, URN and braced text interoperability.
- Exact 16-byte network-order conversion.
- Nil/Max values and variant/version inspection.
- UUIDv3 and UUIDv5 deterministic name-based generation.
- UUIDv4 secure-random generation with injectable entropy.
- UUIDv6 construction and field inspection.
- UUIDv7 generation with injectable clock/entropy.
- Stateful monotonic UUIDv7 with clock-rollback handling.
- UUIDv8 custom-field construction.
- SHA-256 name-based UUIDv8 illustrative profile.
- DNS, URL, OID and X.500 namespace UUIDs.
- RFC conformance tests, multi-backend CI, examples and benchmarks.
