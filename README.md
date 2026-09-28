# MoonUUID

[![CI](https://github.com/wulisususu/MoonUUID/actions/workflows/ci.yml/badge.svg)](https://github.com/wulisususu/MoonUUID/actions/workflows/ci.yml)

**RFC 9562 UUID infrastructure for MoonBit.**  
UUIDv3 / v4 / v5 / v6 / v7 / v8, monotonic UUIDv7, secure platform entropy, deterministic provider injection, binary/text interoperability, and multi-backend CI.

MoonUUID is designed as a reusable ecosystem library rather than an application-specific framework. Typical consumers are Web services, database layers, event systems, CLIs, storage adapters and distributed applications that need a stable UUID primitive.

- Standard: [RFC 9562](https://www.rfc-editor.org/rfc/rfc9562.html)
- Module: `wulisususu/moonuuid`
- Version: `0.1.0`
- Release: published to Mooncakes; external registry smoke test passed
- License: Apache-2.0
- Targets: `wasm`, `wasm-gc`, `js`, `native`

## For reviewers

Start with the [reviewer evidence snapshot](docs/REVIEW_EVIDENCE.md). It links the independent-value argument, published Mooncakes package, external consumer smoke test, cross-target CI, RFC vectors, property-style tests and benchmarks into one verification path.

## Why MoonUUID?

MoonBit already has UUID implementations; MoonUUID does not claim an empty ecosystem. Its independent scope is **RFC 9562-oriented infrastructure with secure default generation and operational UUIDv7 semantics**: UUIDv6 support, injectable clock/entropy providers, no weak-random fallback, same-millisecond monotonicity, clock-rollback handling and explicit overflow behavior.

See [Differentiation](docs/DIFFERENTIATION.md) for a documented comparison with existing MoonBit UUID packages and [Compatibility](docs/COMPATIBILITY.md) for backend/runtime behavior.

## Install

MoonUUID `0.1.0` is published on Mooncakes and can be installed directly:

```bash
moon add wulisususu/moonuuid@0.1.0
```

Import the root package:

```moonbit
import {
  "wulisususu/moonuuid" @uuid
}
```

## Quick start

Generate a time-ordered UUIDv7:

```moonbit
match @uuid.v7() {
  Ok(id) => println(@uuid.to_string(id))
  Err(_) => println("secure entropy unavailable")
}
```

Generate deterministic resource IDs:

```moonbit
let id = @uuid.v5_string(
  @uuid.namespace_url(),
  "https://example.com/users/42",
)
println(@uuid.to_string(id))
```

Parse transport/storage forms without weakening the strict parser:

```moonbit
let strict = @uuid.parse(
  "017f22e2-79b0-7cc3-98c4-dc0c0c07398f",
)

let interoperable = @uuid.parse_permissive(
  "urn:uuid:017f22e2-79b0-7cc3-98c4-dc0c0c07398f",
)
```

For strict generation-order monotonicity inside one process:

```moonbit
let generator = @uuid.V7Generator::new()
let next_id = generator.next()
```

## What is implemented

| Capability | Status | Main API |
| --- | --- | --- |
| Canonical parse/format | ✅ | `parse`, `to_string` |
| Compact / URN / braced text | ✅ | `parse_permissive`, `to_urn`, `to_braced_string` |
| 16-byte network-order interop | ✅ | `to_bytes`, `from_bytes` |
| UUIDv3 | ✅ | `v3`, `v3_string` |
| UUIDv4 | ✅ | `v4`, `v4_with_entropy`, `v4_from_entropy` |
| UUIDv5 | ✅ | `v5`, `v5_string` |
| UUIDv6 | ✅ | `v6_from_parts` |
| UUIDv7 | ✅ | `v7`, `v7_with`, `v7_from_parts` |
| Monotonic UUIDv7 | ✅ | `V7Generator` |
| UUIDv8 custom fields | ✅ | `v8_from_parts` |
| SHA-256 UUIDv8 profile | ✅ | `v8_sha256`, `v8_sha256_string` |
| Standard namespaces | ✅ | DNS / URL / OID / X.500 |
| Nil / Max / version / variant | ✅ | inspection helpers |
| RFC vectors | ✅ | v3 / v4 / v5 / v6 / v7 / v8 |
| Cross-target CI | ✅ | wasm / wasm-gc / js / Linux native / Windows native |

## Realistic integration examples

Runnable examples live under [examples/](examples/) and are retained in the Mooncakes publication archive:

- **Web request ID** — generate UUIDv7 for an `X-Request-ID` style correlation identifier.
- **Database key** — generate a monotonic sequence of UUIDv7 values for index-friendly ordered keys.
- **Deterministic resource ID** — derive the same UUIDv5 from the same namespace and logical resource name.
- **Wire interoperability** — accept a UUID URN and round-trip it through the 16-byte representation.

Run them with:

```bash
moon run examples/web_request_id --target native
moon run examples/database_key --target native
moon run examples/deterministic_resource_id --target native
moon run examples/interop --target native
```

## UUIDv7 safety model

`v7()` uses MoonBit's wall clock and secure platform entropy. It does not silently substitute `Math.random`, a timestamp-only value or another weak PRNG.

`V7Generator` additionally handles:

- multiple IDs in the same millisecond;
- clock rollback;
- `rand_b` carry into `rand_a`;
- explicit overflow instead of knowingly producing duplicate/non-monotonic output.

Provider-injected APIs keep the bit-layout logic deterministic and testable.

## Portability

CI checks the same public library across:

- WebAssembly;
- WebAssembly GC;
- JavaScript;
- Linux native;
- Windows native.

Secure entropy availability is runtime-dependent. If a target cannot provide secure entropy, random generation returns an explicit error while deterministic parsing, formatting, name-based UUIDs and field constructors continue to work.

## Benchmarks

MoonUUID includes release-mode microbenchmarks for canonical parsing, canonical formatting, UUIDv4 construction, UUIDv5 derivation and UUIDv7 construction.

```bash
moon bench benchmarks --release --target native --deny-warn
```

See [docs/BENCHMARKS.md](docs/BENCHMARKS.md) for methodology and the recorded CI baseline.

## Documentation

- [Reviewer evidence snapshot](docs/REVIEW_EVIDENCE.md)
- [API reference](docs/API.md)
- [Why MoonUUID / ecosystem differentiation](docs/DIFFERENTIATION.md)
- [Compatibility matrix](docs/COMPATIBILITY.md)
- [Text and binary formats](docs/FORMATS.md)
- [UUIDv4 generation](docs/V4.md)
- [UUIDv7 and monotonic generation](docs/V7.md)
- [UUIDv6 / UUIDv8](docs/V6_V8.md)
- [Name-based UUIDs](docs/NAME_BASED.md)
- [Benchmarks](docs/BENCHMARKS.md)
- [Release / Mooncakes checklist](docs/RELEASE.md)
- [Contest reviewer guide](docs/CONTEST.md)

## Verification

The repository CI runs:

```bash
moon fmt --check
moon check --target <wasm|wasm-gc|js|native> --deny-warn
moon test --target <wasm|wasm-gc|js|native>
moon build --target <wasm|wasm-gc|js|native>
moon info --target native
moon package --list
moon bench benchmarks --release --target native --deny-warn
```

Windows native is checked and tested separately.

## Scope

MoonUUID is intentionally a UUID foundation library. It is not an ORM, database, tracing framework, distributed-ID service or workflow engine.

That boundary keeps the package useful to all of those higher-level systems without coupling it to any one of them.

## Release status

`0.1.0` is the first public release. It is published to Mooncakes as `wulisususu/moonuuid@0.1.0` and tagged as GitHub Release `v0.1.0` from the same commit.

The guarded publish workflow also creates a clean external MoonBit consumer, installs `wulisususu/moonuuid@0.1.0` from the registry with `moon add`, compiles it and runs a canonical UUID round-trip. This registry smoke test passed for the `0.1.0` release, so the package has been verified outside the source repository rather than only through in-repository examples.

See [docs/RELEASE.md](docs/RELEASE.md).

## License

Apache-2.0
