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

## 0.1.0 reference baseline

Recorded by GitHub Actions release-readiness run
[`36404884944`](https://github.com/wulisususu/MoonUUID/actions/runs/36404884944)
on 2026-09-28.

Environment:

- GitHub-hosted Ubuntu 24.04 runner;
- MoonBit compiler `v0.10.14+7d59c7ec9` (2026-09-18);
- native target;
- release mode;
- 10 samples × 100,000 runs for each operation.

| Benchmark | Mean ± σ | Observed range |
| --- | ---: | ---: |
| `parse_canonical` | 87.13 ns ± 0.88 ns | 85.65–88.55 ns |
| `format_canonical` | 301.09 ns ± 0.88 ns | 299.24–302.26 ns |
| `v4_from_entropy` | 32.21 ns ± 0.15 ns | 32.07–32.47 ns |
| `v5_string` | 877.92 ns ± 6.60 ns | 865.63–891.01 ns |
| `v7_from_parts` | 25.56 ns ± 0.15 ns | 25.45–25.96 ns |

These values are a CI regression baseline, not an SLA or a claim about every
machine. Future releases should compare against the same operation set and
record toolchain changes alongside any new baseline.
