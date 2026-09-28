# Release and Mooncakes checklist

MoonUUID 0.1.0 is prepared as module `wulisususu/moonuuid`.

## Metadata

Before publishing, confirm `moon.mod` contains a semantic version, SPDX
license, repository URL, keywords and description. Mooncakes displays module
metadata together with the README.

The pinned MoonBit 0.10.14 toolchain rejects a `homepage` key, so the
repository URL and README are used as the project navigation surface.

## Archive policy

The Mooncakes archive intentionally keeps the reusable source, tests,
documentation, changelog, license **and runnable examples**.

A root `.moonignore` excludes only development-only GitHub workflow files and
benchmarks from the publication archive. Keeping `examples/` in the archive
means a registry user or reviewer can inspect concrete Web, database,
deterministic-ID and wire-interoperability consumers without returning to the
repository.

Inspect the archive:

```bash
moon package --list
```

CI does more than print this list: it asserts that the API documentation and all
four example programs are present and that `.github/` and `benchmarks/` do
not leak into the package.

Use `.moonignore`; the legacy manifest `include` / `exclude` fields are
deprecated in current MoonBit documentation.

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
moon check --frozen --target native --deny-warn
moon package --frozen --list
moon bench benchmarks --release --target native --deny-warn
```

Reviewer smoke tests:

```bash
moon run examples/web_request_id --target native
moon run examples/database_key --target native
moon run examples/deterministic_resource_id --target native
moon run examples/interop --target native
```

The `release-readiness` GitHub Actions job also uploads the generated
`_build/publish/*.zip` as the `moonuuid-0.1.0-package` artifact for manual
inspection before publication.

## Mooncakes account

Use `moon register` for a new account or `moon login` for an existing one.
The CLI stores the API token outside the repository; credentials must never be
committed.

For repository publishing, store only the raw Mooncakes token in the GitHub
Actions repository secret `MOONCAKES_TOKEN`. The manual publish workflow writes
the temporary `~/.moon/credentials.json` file with owner `wulisususu`, runs
the release, and removes the credential file before the step exits.

## Publish

The preferred release path is the manual GitHub Actions workflow
`.github/workflows/publish.yml`.

It requires the confirmation string:

```text
publish-0.1.0
```

The workflow then:

1. checks that `moon update` does not move the pinned dependency graph, then runs
   native formatting/check/test/interface verification, including a frozen
   build-plan check;
2. verifies the exact frozen Mooncakes archive contents;
3. publishes the verified source with `moon publish`;
4. creates a clean external consumer module and installs
   `wulisususu/moonuuid@0.1.0` from the registry with `moon add`;
5. checks and runs that consumer;
6. creates GitHub Release/tag `v0.1.0` only after the registry smoke test passes.

Local publication remains possible after `moon login`:

```bash
moon update
moon check --frozen --target native --deny-warn
moon package --frozen --list
moon publish
```

### Why the release does not run `moon publish --frozen`

`moon publish --frozen` cannot publish a module that depends on the registry.
Before uploading anything, the CLI re-verifies its own output: it extracts the
packaged archive into an empty directory and runs `moon check` inside that
copy. The fresh copy has no `.mooncakes` directory, so the pinned dependency
`moonbitlang/x@0.5.5` still has to be installed there, and `--frozen` rejects
exactly that:

```text
Failed to sync dependencies: `frozen` is set, so the build system cannot
change the modules directory, but new modules need to be installed
```

The CLI then aborts inside its own verification step with exit code 255, before
anything reaches Mooncakes.

The frozen guarantee is kept where it is meaningful instead: `moon update` must
not move the pinned graph (`git diff --exit-code -- moon.mod`), `moon check
--frozen` proves that the installed dependency set already satisfies the frozen
build plan, and `moon package --frozen --list` builds and lists the archive from
that same frozen plan. `moon.mod` pins `moonbitlang/x@0.5.5` exactly, so the
published archive cannot resolve a different dependency version.

The project inspects `moon package --frozen --list` plus the CI-uploaded
package archive as the pre-publish path: the CLI exposes `--dry-run` as a
common option but does not document what it means for `moon publish`, so the
workflow does not rely on it.

## Post-publish smoke test

The publish workflow performs the registry smoke test automatically. For a
manual verification:

```bash
moon update
moon add wulisususu/moonuuid@0.1.0
```

A successful registry install is not considered enough by itself: the workflow
also compiles and runs a fresh consumer that imports `wulisususu/moonuuid`,
parses an RFC UUIDv7 vector, and verifies its canonical round trip.

## GitHub release

The exact commit that successfully publishes and passes the external registry
smoke test is released as `v0.1.0`. The workflow keeps the Mooncakes version,
Git tag/GitHub Release and `moon.mod` version aligned.
