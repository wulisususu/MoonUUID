# Name-based UUIDs

MoonUUID implements RFC 9562 UUIDv3 and UUIDv5 and also exposes the RFC
Appendix B.2 illustrative SHA-256 UUIDv8 profile.

## UUIDv3

UUIDv3 computes:

```text
MD5(namespace_uuid_bytes || name_bytes)
```

The first 128 hash bits are used, then MoonUUID overwrites the RFC version and
variant fields.

```moonbit
let id = @moonuuid.v3_string(
  @moonuuid.namespace_dns(),
  "www.example.com",
)
```

RFC test vector:

```text
5df41881-3aed-3515-88a7-2f4a814cf09e
```

MD5 is used here only because it is part of the standardized UUIDv3 algorithm.
MoonUUID does not recommend MD5 for new security-sensitive designs.

## UUIDv5

UUIDv5 follows the same process with SHA-1:

```text
SHA-1(namespace_uuid_bytes || name_bytes)
```

Only the first 128 hash bits are used.

```moonbit
let id = @moonuuid.v5_string(
  @moonuuid.namespace_dns(),
  "www.example.com",
)
```

RFC test vector:

```text
2ed6657d-e927-568b-95e1-2665a8aea6a2
```

SHA-1 is present for RFC compatibility, not as a recommendation for new
cryptographic protocols.

## SHA-256 UUIDv8 profile

RFC 9562 notes that modern name-based schemes using SHA-256 or newer hashes
must live in UUIDv8 space rather than pretending to be UUIDv5.

MoonUUID therefore includes:

```moonbit
@moonuuid.v8_sha256(namespace, name_bytes)
@moonuuid.v8_sha256_string(namespace, name)
```

matching the RFC Appendix B.2 illustrative vector:

```text
5c146b14-3c52-8afd-938a-375d0df1fbf6
```

Because UUIDv8 is application-specific, this helper is documented as one
specific profile rather than a universal meaning for all UUIDv8 values.

## Name bytes and canonicalization

The byte-oriented APIs `v3`, `v5` and `v8_sha256` hash exactly the bytes
provided by the caller.

The `*_string` wrappers encode the MoonBit string as UTF-8 first.

DNS, URL, OID and X.500 can each have multiple textual or binary
representations. RFC 9562 intentionally leaves name-format conventions to the
application/namespace. MoonUUID therefore does not silently lowercase domains,
normalize URLs, alter OID punctuation, or rewrite X.500 names.
