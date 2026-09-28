# MoonUUID

[![CI](https://github.com/wulisususu/MoonUUID/actions/workflows/ci.yml/badge.svg)](https://github.com/wulisususu/MoonUUID/actions/workflows/ci.yml)

**MoonUUID** is an RFC 9562 UUID library for MoonBit.

The goal is deliberately concrete: provide the UUID primitives that Web services, databases, distributed systems, CLI tools, event pipelines and application frameworks repeatedly need, with one portable MoonBit API across `wasm`, `wasm-gc`, `js` and `native`.

Reference standard: [RFC 9562 — Universally Unique IDentifiers (UUIDs)](https://www.rfc-editor.org/rfc/rfc9562.html).

## Current status

v0.1 core foundation:

- 128-bit `Uuid` value represented by two `UInt64` words;
- canonical `8-4-4-4-12` parsing;
- uppercase and lowercase hexadecimal input;
- lowercase canonical formatting;
- UUID variant detection;
- RFC-layout version extraction;
- Nil UUID and Max UUID;
- validation helper;
- equality / ordering / hashing support;
- RFC 9562 Appendix A UUIDv4 and UUIDv7 test vectors;
- CI on `wasm`, `wasm-gc`, `js`, Linux native and Windows native.

Generation is intentionally the next layer. The parser and data model do not depend on an operating-system RNG or wall-clock API.

## Quick start

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

Nil and Max sentinels:

```moonbit
let none = @moonuuid.nil()
let end = @moonuuid.max()

assert_true(@moonuuid.is_nil(none))
assert_true(@moonuuid.is_max(end))
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

## Roadmap

### Gate 1 — Core representation and codec

- [x] `Uuid` 128-bit representation
- [x] canonical parser
- [x] canonical formatter
- [x] variant / version inspection
- [x] Nil / Max
- [x] RFC conformance vectors

### Gate 2 — Binary and text interoperability

- [ ] 16-byte conversion
- [ ] URN form
- [ ] braced form parsing
- [ ] strict vs permissive parsing modes

### Gate 3 — UUIDv4

- [ ] entropy-provider interface
- [ ] UUIDv4 bit layout
- [ ] deterministic test entropy source
- [ ] platform adapters

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

The core package stays deterministic and portable. Runtime concerns such as secure randomness and wall-clock access will be introduced behind explicit provider interfaces so that UUID logic remains testable on every MoonBit backend.

## License

Apache-2.0
