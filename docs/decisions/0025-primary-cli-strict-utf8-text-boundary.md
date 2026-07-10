# 0025 - Primary CLI source, input, arguments, JSON, and trace are strict UTF-8 text

- Date: 2026-07-10
- Status: accepted
- Tags: architecture, cli, utf8, unicode, files, json, portability, cross-variant-parity

## Context

ADR `0023` requires exact user-observable primary CLI behavior across backend
languages. ADR `0024` already defines canonical UTF-8 trace records, but the
success/source/input boundary was only fixture-locked with ASCII and newline
bytes.

Trace signoff exposed the missing rule. Perl receives shell `@ARGV` and ordinary
file reads as byte-oriented strings. Passing UTF-8 argv `xé` through
`input_text()` emitted JSON bytes for `xÃ©` (`78 c3 83 c2 a9`) rather than `xé`
(`78 c3 a9`). Direct `LinkedSpec::Get` probes with decoded strings proved that
both Unicode input/result and a Unicode regex compile and execute correctly, so
the defect is the primary adapter boundary rather than the parser engine.

Julia primary request state is `String`-based and reads files as `String`; Rust's
native APIs use `&str`/`String` and its normal text-file seam is `read_to_string`.
A byte-preserving Perl-only interpretation would therefore guarantee divergence.

## Decision

1. **The primary CLI is a UTF-8 text interface.** Source text, input text, option
   values, JSON, stderr/help, and canonical trace are Unicode scalar text encoded
   as UTF-8 at the process/file boundary.
2. **Valid argv text is an interface precondition.** Host launchers pass argument
   strings to the adapter. OS-specific invalid-byte argv that cannot be represented
   as host text is outside the portable primary interface and neutral fixtures.
3. **Source and input files are strict UTF-8.** Invalid byte sequences are not
   replaced or interpreted as Latin-1. Invalid spec bytes project to the stable
   compilation failure; invalid input bytes project to the stable input-load
   failure. Host decoder wording and paths remain private.
4. **Text is otherwise preserved.** Adapters perform no Unicode normalization, no
   BOM removal, no newline conversion, and no trimming. A UTF-8 BOM is U+FEFF data;
   composed and decomposed sequences remain distinct; file newline bytes decode to
   their corresponding code points unchanged.
5. **Canonical JSON is UTF-8.** Logical string values are encoded once, recursively
   key-sorted under ADR `0023`, and followed by exactly one record newline. No
   adapter may double-encode already UTF-8 data or emit host encoding warnings.
6. **Trace counts encoded bytes.** ADR `0024` high/full byte fields count the UTF-8
   encoding that crosses the process boundary, not host characters or a second
   encoding of existing bytes.
7. **One manifest locks the rule.** Valid literal/file Unicode, preservation, JSON,
   trace counts, invalid source/input bytes, phase stderr, exit, and generated files
   belong in the shared neutral fixture suite. The runner may materialize explicit
   hex bytes so invalid UTF-8 needs no opaque checked-in binary blob.

## Consequences

- Perl must strictly decode option values and file contents at the correct command
  phase before passing text to native APIs.
- Rust, Dart, Julia, Lua, and later primary adapters inherit the same text contract.
- Binary parsing is not a primary CLI text feature. A future byte-stream capability
  would require a distinct typed API/option contract rather than accidental host
  byte strings.
- Parser cursor/regex parity over non-ASCII text remains subject to normal shared
  semantic fixtures; this decision only prevents adapter encoding drift.

## Links

- Parent interface: ADR `0023`
- Trace protocol: ADR `0024`
- Task owner: `FUTURE-PARITY-BACKLOG.1.5.1.6`
- Gap fact: `docs/knowledge/primary-cli-utf8-process-boundary-gap.md`
- Fixture runner: `cli_conformance/manifest.json`, `tools/run_cli_conformance.pl`
