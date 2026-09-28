# Release and Mooncakes checklist

MoonUUID 0.1.0 is prepared as module `wulisususu/moonuuid`.

## Metadata

Before publishing, confirm `moon.mod` contains a semantic version, SPDX
license, repository URL, keywords and description. Mooncakes displays module metadata together with the README. The pinned MoonBit
0.10.14 toolchain rejects a `homepage` key, so the repository URL and README are
used as the project navigation surface.

## Archive policy

A root `.moonignore` excludes development-only examples, benchmarks and GitHub
workflow files from the publication archive while retaining source,
documentation, tests, changelog and license.

Inspect the archive:

```bash
moon package --list
```

Use `.moonignore`; the legacy manifest `include` / `exclude` fields are
deprecated.

## Release verification

```bash
moon update
moon fmt --check
moon check --target wasm --deny-warn
moon check --target wasm-gc --deny-warn
moon check --target js --deny-warn
moon check --target native --deny-warn
moon test --target wasm
moon test --target wasm-gc
moon test --target js
moon test --target native
moon build --target wasm
moon build --target wasm-gc
moon build --target js
moon build --target native
moon info --target native
moon package --list
moon bench benchmarks --release --target native --deny-warn
```

Reviewer smoke tests:

```bash
moon run examples/web_request_id --target native
moon run examples/database_key --target native
moon run examples/deterministic_resource_id --target native
moon run examples/interop --target native
```

## Mooncakes account

Use `moon register` for a new account or `moon login` for an existing one.
Credentials must never be committed.

## Publish

After version/changelog review and green CI:

```bash
moon publish
```

The current MoonBit CLI documentation for `moon publish` documents
`--frozen` but does not currently list a `--dry-run` option, so this project
does not make an undocumented dry-run flag a mandatory release step.

## Post-publish smoke test

```bash
moon new moonuuid-smoke
cd moonuuid-smoke
moon add wulisususu/moonuuid@0.1.0
```

Import `wulisususu/moonuuid`, generate or parse one UUID, and run
`moon check`.

## GitHub release

After Mooncakes publication succeeds, tag the exact commit as `v0.1.0`, create
a GitHub Release, and keep the Mooncakes version, Git tag and `moon.mod`
version identical.
