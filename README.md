# MoonUUID

[![CI](https://github.com/wulisususu/MoonUUID/actions/workflows/ci.yml/badge.svg)](https://github.com/wulisususu/MoonUUID/actions/workflows/ci.yml)

**MoonUUID** is an RFC 9562 UUID library for MoonBit.

The goal is deliberately concrete: provide the UUID primitives that Web services, databases, distributed systems, CLI tools, event pipelines and application frameworks repeatedly need, with one portable MoonBit API across `wasm`, `wasm-gc`, `js` and `native`.

Reference standard: [RFC 9562 — Universally Unique IDentifiers (UUIDs)](https://www.rfc-editor.org/rfc/rfc9562.html).

## Current status

v0.1 foundation:

- 128-bit `Uuid` value represented by two `UInt64` words;
- strict canonical `8-4-4-4-12` parser;
- permissive parser for canonical, compact, UUID URN and braced forms;
- lowercase canonical, URN and braced formatting;
- exact 16-byte network-order encode/decode;
- UUID variant detection and RFC-layout version extraction;
- Nil UUID and Max UUID;
- UUIDv4 generation from secure platform entropy;
- injectable UUIDv4 entropy provider for hosts and deterministic tests;
- no weak-random fallback when secure entropy is unavailable;
- equality / ordering / hashing support;
- RFC 9562 Appendix A UUIDv4 and UUIDv7 test vectors;
- CI on `wasm`, `wasm-gc`, `js`, Linux native and Windows native.

## Quick start

Generate UUIDv4:

```moonbit
match @moonuuid.v4() {
  Ok(id) => println(@moonuuid.to_string(id))
  Err(_) => println("secure entropy unavailable")
}
```

Strict canonical parsing:

```moonbit
match @moonuuid.parse("017F22E2-79B0-7CC3-98C4-DC0C0C07398F") {
  Ok(id) => {
    println(@moonuuid.to_string(id))
    // 017f22e2-79b0-7cc3-98c4-dc0c0c07398f

    println(@moonuuid.version(id))
    // Some(7)
  }
  Err(_) => println("invalid UUID")
}
```

Interoperability parsing:

```moonbit
let id = @moonuuid.parse_permissive(
  "urn:uuid:919108f7-52d1-4320-9bac-f847db4148a8",
)

let compact = @moonuuid.parse_permissive(
  "919108f752d143209bacf847db4148a8",
)
```

Binary round trip:

```moonbit
match @moonuuid.parse("919108f7-52d1-4320-9bac-f847db4148a8") {
  Ok(id) => {
    let bytes : Bytes = @moonuuid.to_bytes(id)
    let decoded = @moonuuid.from_bytes(bytes)
    ignore(decoded)
  }
  Err(_) => ()
}
```

## Why this project

UUID is infrastructure, not an application-specific abstraction. Typical consumers include:

- request / correlation IDs in Web APIs;
- database primary keys and object IDs;
- event and message identifiers;
- trace identifiers;
- durable IDs in CLI and developer tools;
- framework and library internals.

RFC 9562 supersedes RFC 4122 and defines the current UUID layout, variants, versions, Nil / Max values, and UUIDv6 / UUIDv7 / UUIDv8.

## Generation safety

`v4()` delegates to MoonBit's platform secure entropy API `@env.rand`.

If the current runtime cannot supply secure entropy, generation returns `EntropyUnavailable`; MoonUUID does **not** fall back to `Math.random`, timestamps or another weak source.

For custom hosts and reproducible testing, use `v4_with_entropy(provider)` or the deterministic `v4_from_entropy(bytes)`.

More details: [docs/V4.md](docs/V4.md).

## Text formats

MoonUUID deliberately exposes two parsing modes:

| API | Accepted input |
| --- | --- |
| `parse` | canonical `8-4-4-4-12` only |
| `parse_permissive` | canonical, 32-hex compact, `urn:uuid:`, `{canonical}` |

More details: [docs/FORMATS.md](docs/FORMATS.md).

## Roadmap

### Gate 1 — Core representation and codec

- [x] `Uuid` 128-bit representation
- [x] canonical parser
- [x] canonical formatter
- [x] variant / version inspection
- [x] Nil / Max
- [x] RFC conformance vectors

### Gate 2 — Binary and text interoperability

- [x] 16-byte conversion
- [x] URN form
- [x] braced form parsing and formatting
- [x] compact 32-hex parsing
- [x] strict vs permissive parsing modes

### Gate 3 — UUIDv4

- [x] entropy-provider interface
- [x] UUIDv4 bit layout
- [x] deterministic test entropy source
- [x] platform secure-entropy adapter via `@env.rand`
- [x] explicit unsupported-runtime failure without weak fallback

### Gate 4 — UUIDv7

- [ ] Unix-millisecond timestamp encoding
- [ ] random `rand_a` / `rand_b`
- [ ] injectable clock
- [ ] monotonic generation strategy
- [ ] RFC 9562 Appendix A conformance

### Gate 5 — Wider RFC 9562 coverage

- [ ] UUIDv3 / UUIDv5 namespace generation
- [ ] UUIDv6
- [ ] UUIDv8 construction primitives
- [ ] standard namespace constants

## Scope

MoonUUID is a UUID library. It is not an ORM, database, distributed-ID service, tracing framework, or workflow engine.

The deterministic codec and bit-layout logic remains portable. Runtime entropy enters only through an explicit provider boundary.

## License

Apache-2.0
