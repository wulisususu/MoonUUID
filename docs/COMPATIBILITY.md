# Compatibility matrix

MoonUUID keeps deterministic UUID logic separate from host-provided clock and
entropy capabilities. This distinction matters across MoonBit backends.

## CI targets

The repository continuously checks the library on:

| Target | Check | Test | Build |
| --- | :---: | :---: | :---: |
| wasm | ✅ | ✅ | ✅ |
| wasm-gc | ✅ | ✅ | ✅ |
| JavaScript | ✅ | ✅ | ✅ |
| Linux native | ✅ | ✅ | ✅ |
| Windows native | ✅ | ✅ | — |

Windows native has a dedicated check/test job. The cross-target matrix builds
the native target on Linux.

## API behavior by capability

| Capability | wasm | wasm-gc | JavaScript | native |
| --- | --- | --- | --- | --- |
| Parse / format | ✅ deterministic | ✅ deterministic | ✅ deterministic | ✅ deterministic |
| 16-byte interop | ✅ deterministic | ✅ deterministic | ✅ deterministic | ✅ deterministic |
| v3 / v5 name-based | ✅ deterministic | ✅ deterministic | ✅ deterministic | ✅ deterministic |
| v6 / v8 field construction | ✅ deterministic | ✅ deterministic | ✅ deterministic | ✅ deterministic |
| `v4_from_entropy` | ✅ deterministic | ✅ deterministic | ✅ deterministic | ✅ deterministic |
| `v7_from_parts` / `v7_from_entropy` | ✅ deterministic | ✅ deterministic | ✅ deterministic | ✅ deterministic |
| Default `v4()` | host entropy dependent | host entropy dependent | secure host entropy required | secure platform entropy required |
| Default `v7()` | host clock + entropy dependent | host clock + entropy dependent | host clock + secure entropy required | platform clock + secure entropy required |
| Injected provider APIs | ✅ | ✅ | ✅ | ✅ |
| Monotonic `V7Generator` | ✅ when providers succeed | ✅ when providers succeed | ✅ | ✅ |

## Entropy rule

Default random generation does not promise that every possible host can expose
secure entropy. Instead, MoonUUID promises a stronger invariant:

> If secure entropy is not available through the active MoonBit runtime/host,
> random generation returns an explicit error rather than silently switching to
> a weaker source.

This keeps deterministic APIs portable while making the security boundary of
random generation visible to callers.

## Testing rule

Runtime-dependent APIs are paired with provider-injected forms. CI can therefore
verify UUID layout, monotonicity, rollback handling and error behavior without
depending on nondeterministic clocks or random values.
