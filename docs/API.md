# MoonUUID API reference

This document is the compact public API map for MoonUUID 0.1.0. Public symbols
also carry source-level documentation comments, so `moon info` can generate the
compiler-facing interface.

## Core value

### `Uuid`

A UUID stored as two unsigned 64-bit words in RFC/network byte order.

Construction and inspection:

```moonbit
@moonuuid.from_u64s(high, low)
@moonuuid.high(uuid)
@moonuuid.low(uuid)
@moonuuid.nil()
@moonuuid.max()
@moonuuid.is_nil(uuid)
@moonuuid.is_max(uuid)
@moonuuid.variant(uuid)
@moonuuid.version(uuid)
```

`Uuid` implements equality, comparison and hashing.

### Variants

```moonbit
Variant::Ncs
Variant::Rfc9562
Variant::Microsoft
Variant::Future
```

## Text codecs

Strict canonical parser:

```moonbit
@moonuuid.parse(text)
@moonuuid.is_valid(text)
```

Interoperability parser:

```moonbit
@moonuuid.parse_permissive(text)
@moonuuid.is_valid_permissive(text)
```

Formatting:

```moonbit
@moonuuid.to_string(uuid)
@moonuuid.to_urn(uuid)
@moonuuid.to_braced_string(uuid)
```

`parse` accepts only canonical `8-4-4-4-12` text. `parse_permissive`
additionally accepts compact 32-hex, UUID URN and braced canonical forms.

## Binary codec

```moonbit
@moonuuid.to_bytes(uuid)
@moonuuid.from_bytes(bytes)
```

The binary representation is exactly 16 bytes in RFC/network order.

## UUIDv3

```moonbit
@moonuuid.v3(ns, name_bytes)
@moonuuid.v3_string(ns, name)
```

## UUIDv4

```moonbit
@moonuuid.v4()
@moonuuid.v4_with_entropy(provider)
@moonuuid.v4_from_entropy(entropy)
```

## UUIDv5

```moonbit
@moonuuid.v5(ns, name_bytes)
@moonuuid.v5_string(ns, name)
```

## UUIDv6

```moonbit
@moonuuid.v6_from_parts(timestamp_100ns, clock_seq, node)
@moonuuid.gregorian_ts_100ns(uuid)
@moonuuid.v6_clock_seq(uuid)
@moonuuid.v6_node(uuid)
```

## UUIDv7

```moonbit
@moonuuid.v7()
@moonuuid.v7_with(clock, entropy)
@moonuuid.v7_from_entropy(unix_ms, entropy)
@moonuuid.v7_from_parts(unix_ms, rand_a, rand_b)
@moonuuid.unix_ts_ms(uuid)
```

Monotonic generator:

```moonbit
let generator = @moonuuid.V7Generator::new()
generator.next()
generator.next_with(clock, entropy)
```

## UUIDv8

```moonbit
@moonuuid.v8_from_parts(custom_a, custom_b, custom_c)
@moonuuid.v8_custom_a(uuid)
@moonuuid.v8_custom_b(uuid)
@moonuuid.v8_custom_c(uuid)
@moonuuid.v8_sha256(ns, name_bytes)
@moonuuid.v8_sha256_string(ns, name)
```

## Standard namespaces

```moonbit
@moonuuid.namespace_dns()
@moonuuid.namespace_url()
@moonuuid.namespace_oid()
@moonuuid.namespace_x500()
```

## Error families

```text
ParseError
BytesError
GenerateError
V6Error
V7Error
V8Error
```

Errors are explicit rather than replaced with silent fallback behavior.

## Generated interface

Run:

```bash
moon info --target native
```

CI runs this as a release-readiness check.
