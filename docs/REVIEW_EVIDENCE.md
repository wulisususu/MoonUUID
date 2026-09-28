# Reviewer evidence snapshot

This page is the shortest verification path for MoonUUID as a MoonBit
foundation-library submission.

## One-sentence position

**MoonUUID is RFC 9562 UUID infrastructure for MoonBit with secure generation,
cross-backend portability and operationally defined monotonic UUIDv7 behavior.**

It does not claim that MoonBit previously had no UUID implementation. Its
independent scope is documented in [DIFFERENTIATION.md](DIFFERENTIATION.md).

## Release proof

- Module: `wulisususu/moonuuid`
- Published version: `0.1.0`
- Install command: `moon add wulisususu/moonuuid@0.1.0`
- GitHub Release/tag: `v0.1.0`
- Release commit: `376775dec4990f82b12a927d647caf5432d16d98`
- Successful publish workflow: Actions run `36425691895`

The publish workflow did not stop after a successful upload. It created a clean
MoonBit consumer outside the repository, installed
`wulisususu/moonuuid@0.1.0` from Mooncakes, compiled it and ran an RFC UUIDv7
canonical round trip.

The observed dependency tree in that clean consumer was:

```text
smoke/moonuuid_consumer@0.0.0
└─ wulisususu/moonuuid -> wulisususu/moonuuid@0.1.0
   └─ moonbitlang/x -> moonbitlang/x@0.5.5
```

The executed smoke program printed:

```text
017f22e2-79b0-7cc3-98c4-dc0c0c07398f
```

This proves registry consumption, compilation and execution; it is not a claim
of third-party production adoption.

## Foundation-library evidence

| Reviewer question | Repository evidence |
| --- | --- |
| Is it reusable outside one application? | Root package exposes UUID primitives without HTTP, DB, UI or application dependencies. |
| Is there a clear standards contract? | RFC 9562 vectors cover v3/v4/v5/v6/v7/v8 behavior. |
| Does it solve more than formatting? | Secure entropy policy, provider injection, UUIDv6, UUIDv7 monotonic state, rollback and overflow handling. |
| Can another package consume it? | Published Mooncakes 0.1.0 plus clean external consumer smoke test. |
| Is behavior portable? | wasm, wasm-gc, JavaScript, Linux native and Windows native CI. |
| Is correctness only example-based? | RFC vectors, boundary tests and deterministic corpus/property-style tests. |
| Is performance observable? | Native release-mode benchmarks are checked in and run by release-readiness CI. |
| Is the package release-ready? | Archive contents, public interface, examples, benchmark and publication path are CI-checked. |

## Independent value

Existing MoonBit UUID packages are acknowledged rather than ignored.

MoonUUID's independent value is concentrated in:

- RFC 9562-oriented v3/v4/v5/v6/v7/v8 coverage;
- secure default entropy with explicit failure instead of weak-random fallback;
- injectable clock and entropy providers for deterministic tests;
- stateful monotonic UUIDv7;
- same-millisecond ordering;
- clock-rollback handling;
- `rand_b` carry into `rand_a`;
- explicit monotonic overflow behavior;
- strict parser separated from permissive interoperability parsing;
- one API verified across MoonBit's major backends.

See [DIFFERENTIATION.md](DIFFERENTIATION.md) for the documented ecosystem
comparison and [COMPATIBILITY.md](COMPATIBILITY.md) for backend/runtime
semantics.

## Fast verification

For a reviewer who already has MoonBit installed:

```bash
moon update
moon check --target native --deny-warn
moon test --target native
moon run examples/web_request_id --target native
moon run examples/database_key --target native
```

To verify that the released package can be consumed independently, create a
fresh MoonBit project and add:

```bash
moon add wulisususu/moonuuid@0.1.0
```

For the full repository verification path:

```bash
moon fmt --check
moon check --target wasm --deny-warn
moon check --target wasm-gc --deny-warn
moon check --target js --deny-warn
moon check --target native --deny-warn
moon test --target wasm
moon test --target wasm-gc
moon test --target js
moon test --target native
moon info --target native
moon package --list
moon bench benchmarks --release --target native --deny-warn
```

## Evidence map

- Public API: [API.md](API.md)
- Ecosystem differentiation: [DIFFERENTIATION.md](DIFFERENTIATION.md)
- Backend compatibility: [COMPATIBILITY.md](COMPATIBILITY.md)
- Contest framing: [CONTEST.md](CONTEST.md)
- Release and registry verification: [RELEASE.md](RELEASE.md)
- Benchmark methodology/results: [BENCHMARKS.md](BENCHMARKS.md)
- Runnable consumers: [../examples/](../examples/)
- Property-style invariant tests: [../property_test.mbt](../property_test.mbt)
- CI definition: [../.github/workflows/ci.yml](../.github/workflows/ci.yml)
- Release workflow: [../.github/workflows/publish.yml](../.github/workflows/publish.yml)

## Deliberate boundaries

MoonUUID is not an ORM, database driver, Web framework, tracing system,
distributed ID service or workflow engine.

Those are intended consumers of the library.

MoonUUID also does not claim real production users, production traffic or
external adoption metrics that have not been observed. Its current external
evidence is the published Mooncakes package and the successful clean-consumer
registry smoke test.
