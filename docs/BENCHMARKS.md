# Benchmarks

MoonUUID uses MoonBit's built-in benchmark harness.

```bash
moon bench benchmarks --release --target native --deny-warn
```

## Operations measured

1. canonical UUID parsing;
2. canonical UUID formatting;
3. deterministic UUIDv4 construction from 16 bytes;
4. UUIDv5 name-based derivation;
5. deterministic UUIDv7 field construction.

These operations cover common library hot paths without mixing network,
filesystem or OS entropy latency into the microbenchmarks.

## Methodology

- release-mode compilation;
- `@bench.T::bench` adaptive iteration counts;
- `@bench.T::keep` to prevent pure results being optimized away;
- fixed deterministic inputs;
- no wall-clock or secure-RNG calls inside measured closures.

Absolute timings depend on runner hardware and MoonBit version. The primary use
is regression detection, not a universal performance guarantee.

## Reference baseline

The first release-hardening CI run will be recorded here after the benchmark job
completes. CI logs remain the source of truth for the exact toolchain and runner.
