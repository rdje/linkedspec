# 0026 - Native spec resolution uses explicit ordered roots and strict UTF-8 loading

- Date: 2026-07-11
- Status: accepted
- Tags: architecture, resolution, files, utf8, unicode, diagnostics, portability, cross-variant-parity

## Context

ADR `0022` makes native in-memory embedding the primary product and ADR `0023` requires user-observable feature
identity across variants. The mdBook's file-oriented role exists natively only on Perl. Rust, Dart, and Julia can
resolve files for their primary CLIs, but their host libraries do not expose that composition.

The implementation audit also found incompatible fallback behavior. Rust and Dart stop after an exact cwd path,
cwd `<name>.spec`, and repository `specs/<name>.spec`. Julia additionally performs a sorted/pruned recursive
repository scan. Perl delegates a bare miss to `PathSearch`, which recursively caches cwd plus repository
directories, deduplicates through a hash, and selects the first hash-key match. That last precedence is not a
deterministic contract another backend can reproduce.

## Decision

1. The native file-oriented role has two explicit request kinds:
   - `name` resolves a portable logical spec identity;
   - `path` opens one filesystem path exactly.
2. A name is non-empty Unicode scalar text with no surrounding Unicode whitespace or Unicode control characters.
   It is a relative forward-slash identity: nested components are allowed; absolute forms, backslashes, empty
   components, `.` components, and `..` components are rejected. Arbitrary host paths belong in `path` requests.
3. Name candidates are evaluated in this order:
   - requested value relative to the caller's cwd;
   - the same cwd value with `.spec` appended unless already present;
   - `<search-root>/<value-or-value.spec>` for each explicit search root in declared order.
   Candidate deduplication preserves the first lexical occurrence. Search roots are direct only; no recursive walk
   or implicit registry/global scan occurs.
4. Path requests resolve an absolute value unchanged or a relative value against cwd. They do not append `.spec`
   and do not consult search roots.
5. The first regular-file candidate wins. Existing directories/non-regular candidates do not mask a later regular
   file. If no regular file wins, report the first existing non-regular candidate; otherwise report not found.
   Implementations need not canonicalize or dereference a path merely to choose it, so observable precedence does
   not depend on host filesystem canonicalization.
6. Loaded files are Unicode scalar text encoded as strict UTF-8, extending ADR `0025` from the primary CLI into the
   native file API. Preserve BOM as U+FEFF, code points, normalization form, newlines, and surrounding text. Do not
   replace malformed bytes, normalize, trim, remove BOM, convert newlines, or auto-detect/transcode UTF-16/UTF-32.
7. The pipeline order is validate request, resolve path, read bytes, decode text, parse, validate, compile. Success
   retains request kind/value, resolved path, and exact source text alongside the backend-native compiled value.
8. Failures project an idiomatic host error with the neutral `spec_pipeline_error` record: required `type`, `stage`,
   `code`, `summary`, `request_kind`, and `requested`, plus optional `resolved_path` and `detail`. Stable stages and
   codes live in `capability_conformance/native_spec_resolution_contract.json`; host exception/OS wording remains
   private detail.
9. Native APIs may use idiomatic names and types, but they consume the same executable fixture directly without a
   CLI or subprocess. Primary CLIs should delegate to those APIs while preserving ADR `0023` exactly.
10. Perl's implicit `PathSearch` remains a legacy compatibility extension for existing callers. It is not part of
    this portable API, must not be copied by new variants, and remains subject to the roadmap's deterministic
    hardening track.

## Consequences

- Rust, Dart, Julia, Lua, and later variants gain one safe, deterministic public resolution model instead of
  reproducing Perl's process-global search accident.
- Applications can make discovery policy reviewable by constructing ordered roots explicitly. Package/CLI
  adapters may supply their shipped `specs/` directory as one such root.
- A user who has UTF-16 or UTF-32 source must transcode it explicitly before calling the file API, or pass already
  decoded Unicode text to the in-memory compile API. "Unicode support" does not imply accepting every encoding at
  this boundary.
- Nested named identities cannot escape their roots through traversal components. Filesystem-specific values,
  including Windows paths, remain supported through the exact `path` request kind.
- The shared fixture can test every backend's resolution, file-kind, decoding, identity, and error projection
  independently of its command adapter.

## Links

- Task owner: `FUTURE-PARITY-BACKLOG.1.6.4`
- Executable contract: `capability_conformance/native_spec_resolution_contract.json`
- Checker: `tools/check_native_spec_resolution_contract.pl`
- Native embedding: ADR `0022`
- Exact public parity: ADR `0023`
- UTF-8 boundary: ADR `0025`
- Prior ordered-root direction: ADRs `0013` and `0015`
