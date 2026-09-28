# Differentiation from existing MoonBit UUID packages

MoonUUID is not based on the assumption that MoonBit has no UUID implementation.
The ecosystem already contains UUID work. The purpose of this document is to
make MoonUUID's independent scope explicit and reviewable.

This comparison reflects the publicly documented APIs inspected on 2026-09-28.
"Not documented" means the behavior is not part of the public surface reviewed
here; it is not a claim that another project could never implement it.

## Ecosystem context

### `moonbitlang/x/uuid`

The experimental `moonbitlang/x/uuid` package describes itself as an RFC 4122
UUID implementation. Its public surface provides UUID parsing/formatting,
bytes conversion, variant/version inspection and version-bit adjustment.

Its README explicitly states that the package does not assume random
generation: callers provide their own random bytes.

### `uuidm`

The community `uuidm` project documents RFC 9562 UUIDv3, UUIDv4, UUIDv5,
UUIDv7 and UUIDv8 support and standard namespaces.

Its README also documents that random generation uses a simple linear
congruential generator and recommends a cryptographically secure random number
generator for cryptographic applications.

## MoonUUID's independent scope

| Area | `moonbitlang/x/uuid` documented surface | `uuidm` documented surface | MoonUUID |
| --- | --- | --- | --- |
| Standards focus | RFC 4122 | RFC 9562 | RFC 9562 |
| Parsing / formatting | Yes | Yes | Yes, strict and permissive APIs are separated |
| 16-byte interop | Yes | Yes | Yes, exact network-order round trip |
| Name-based UUIDs | Version support / caller construction | v3 / v5 | v3 / v5 plus standard namespaces |
| UUIDv4 generation | Caller supplies bytes | v4 | secure platform entropy; explicit failure if unavailable |
| UUIDv6 | Not documented | Not documented | deterministic v6 construction and inspection |
| UUIDv7 | Not documented | v7 / sequence helpers | v7 plus stateful monotonic generator |
| UUIDv8 | Not documented | v8 helpers | custom-field constructor plus SHA-256 illustrative profile |
| Entropy policy | caller-owned | README documents simple LCG | secure platform entropy; no weak fallback |
| Clock / entropy injection | caller-owned bytes | not documented as a provider API | explicit injectable providers |
| Same-ms monotonic v7 | not documented | sequence helper documented | explicit monotonic state machine |
| Clock rollback behavior | not documented | not documented | timestamp pinning + payload increment |
| Counter overflow behavior | not documented | not documented | explicit `MonotonicOverflow` |
| Multi-backend release gate | outside this package comparison | outside this package comparison | wasm / wasm-gc / js / Linux native / Windows native CI |

## Why this is not only another UUID formatter

MoonUUID concentrates on the parts that become important when UUIDs are used as
infrastructure rather than display strings:

1. **Secure generation semantics.** Random UUID APIs never silently downgrade
   to a weak PRNG when secure entropy is unavailable.
2. **Testable runtime boundaries.** Clock and entropy providers are injectable,
   so time/random behavior can be verified with deterministic inputs.
3. **Operational UUIDv7 semantics.** A stateful generator handles repeated
   generation in one millisecond, clock rollback, 74-bit payload carry and
   exhaustion.
4. **RFC 9562 breadth.** The package exposes v3/v4/v5, v6 field construction,
   v7 generation and v8 construction in one API.
5. **Cross-target evidence.** The same public library is continuously checked on
   MoonBit's wasm, wasm-gc, JavaScript and native targets.

## Intended relationship to the ecosystem

MoonUUID does not need another UUID package to be absent in order to have
independent value. Multiple packages can make different trade-offs.

The intended consumers are Web frameworks, database/ORM layers, event systems,
tracing libraries, storage adapters and CLIs that specifically need one or more
of these properties:

- RFC 9562-oriented APIs;
- secure default random generation;
- explicit failure instead of weak entropy fallback;
- injectable clock/entropy for deterministic testing;
- monotonic UUIDv7 with rollback and overflow behavior;
- UUIDv6 construction;
- verified behavior across MoonBit backends.

The project therefore positions itself as **RFC 9562 UUID infrastructure with
secure generation and operational UUIDv7 semantics**, not as a claim that
MoonBit previously had no UUID implementation.
