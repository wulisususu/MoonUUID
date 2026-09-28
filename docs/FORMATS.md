# UUID formats

MoonUUID separates strict canonical parsing from interoperability parsing.

## Strict parsing

`parse(text)` accepts exactly 36 ASCII code units in the canonical UUID shape:

```text
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

Hexadecimal digits may be uppercase or lowercase. Hyphens must appear at offsets 8, 13, 18 and 23.

This is the recommended parser for protocol fields and storage formats whose contract already specifies canonical UUID text.

## Permissive parsing

`parse_permissive(text)` accepts four explicit forms:

```text
919108f7-52d1-4320-9bac-f847db4148a8
919108f752d143209bacf847db4148a8
urn:uuid:919108f7-52d1-4320-9bac-f847db4148a8
{919108f7-52d1-4320-9bac-f847db4148a8}
```

The `urn:uuid:` prefix is matched case-insensitively. The UUID payload still follows the same hexadecimal and hyphen rules.

The permissive parser does not trim whitespace, accept arbitrary prefixes, or guess damaged input.

## Formatting

- `to_string(uuid)` returns lowercase canonical text.
- `to_urn(uuid)` returns `urn:uuid:` plus canonical text.
- `to_braced_string(uuid)` returns canonical text wrapped in braces.

Formatting is deterministic and does not preserve the input spelling.

## Binary form

`to_bytes(uuid)` returns exactly 16 immutable MoonBit `Bytes` in RFC/network order.

`from_bytes(data)` requires exactly 16 bytes and rejects every other length.

The binary API is intended for database adapters, serialization formats, protocol code, hashes and storage layers that should not round-trip through text.
