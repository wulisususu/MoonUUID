# Contest reviewer guide

MoonUUID is a focused MoonBit ecosystem foundation library implementing RFC
9562 UUID primitives.

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

## Boundaries

MoonUUID deliberately does not contain an ORM, database driver, HTTP framework,
tracing system or distributed ID service. Those systems are consumers.

The project does not claim production adoption or fabricated user metrics.
Repository evidence is runnable, standards-based and machine-checkable; external
adoption can be measured after publication.
