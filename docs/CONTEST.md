# Contest reviewer guide

MoonUUID is a focused MoonBit ecosystem foundation library implementing RFC
9562 UUID primitives.

## Reviewer entry point

For the shortest evidence path, start with [REVIEW_EVIDENCE.md](REVIEW_EVIDENCE.md). It connects the release, independent-consumer smoke test, differentiation, CI, tests and benchmarks without requiring a full repository read.

## Problem

UUIDs appear repeatedly in Web APIs, database records, event streams, tracing,
CLI tools, storage formats and framework internals. Without a reusable library,
each application has to reimplement parsing, formatting, version/variant bits,
secure random generation, time-ordered UUIDv7 behavior and name-based hashing.

MoonUUID centralizes that work behind one MoonBit API.

## Why this is a foundation library

| Consumer | MoonUUID role |
| --- | --- |
| Web service | request/correlation UUIDv7 |
| Database/ORM | sortable monotonic UUIDv7 key |
| Event system | UUIDv4 or UUIDv7 event identifier |
| Resource registry | deterministic UUIDv5 |
| Protocol/storage adapter | canonical/URN/bytes conversion |
| Legacy UUID system | UUIDv3/v5/v6 compatibility |
| Custom scheme | UUIDv8 field construction |

## Three-minute verification

```bash
moon update
moon check --target native --deny-warn
moon test --target native
moon run examples/web_request_id --target native
moon run examples/database_key --target native
moon run examples/deterministic_resource_id --target native
moon run examples/interop --target native
moon bench benchmarks --release --target native --deny-warn
```

## Evidence

- RFC 9562 vectors are executable tests.
- Cross-target CI covers wasm, wasm-gc, JavaScript and native.
- Windows native receives a separate check/test job.
- Secure entropy failures are explicit; there is no weak-random fallback.
- UUIDv7 tests cover same-millisecond calls, clock rollback and counter carry.
- Runnable examples demonstrate four distinct consumer scenarios.
- Benchmarks use MoonBit's benchmark harness and release-mode compilation.
- `moon package --list` is part of release-readiness CI.
- `wulisususu/moonuuid@0.1.0` is published to Mooncakes.
- The release workflow creates a clean external consumer, installs the published package with `moon add`, compiles it and runs an RFC UUIDv7 canonical round-trip.
- GitHub Release `v0.1.0`, the Mooncakes package version and the release commit are aligned.

## Boundaries

MoonUUID deliberately does not contain an ORM, database driver, HTTP framework,
tracing system or distributed ID service. Those systems are consumers.

The project does not claim production adoption or fabricated user metrics.
The current external evidence is deliberately narrower and machine-checkable:
the published Mooncakes package is installable by a fresh consumer and passes a
compile-and-run smoke test. Broader third-party adoption is not claimed.
