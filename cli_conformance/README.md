# LinkedSpec Primary CLI Conformance Fixtures

This directory is the backend-neutral, byte-exact contract for every LinkedSpec
primary command. Backend executable names and unavoidable host launch wrappers may
differ; the argument vectors, behavior, stdout, stderr, and exit status may not.

Run the current Perl reference case from the repository root:

```bash
PERL5LIB= perl tools/run_cli_conformance.pl \
  --display-command 'perl bin/linkedspec' \
  -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec
```

Use `--case ID` before the separator to select one or more manifest cases. Everything
after `--` is an arbitrary command array, so later Rust, Dart, Julia, Lua, and other
backends consume this same manifest without backend-specific fixture copies.

`bash tools/run_primary_cli_matrix.sh` runs all 63 cases through all five current commands in default and POSIX
environments. Pass one or more `--case ID` arguments to that matrix driver for a contract-owned focused gate; for
example, the recurring diagnostic-output gate uses
`bash tools/run_primary_cli_matrix.sh --case success_diagnostic_helpers_quiet`. Omitting `--case` remains the full
5x2x63 matrix. The recurring logical gate selects
`bash tools/run_primary_cli_matrix.sh --case success_logical_helpers_eager`; that case records eager effects and
the same canonical boolean result across all five commands and both environments.

The current manifest contains 63 cases: exact long/short help, 20 strict usage families, nine successful
source/input/parser-control/quiet-diagnostic/logical-helper families, four baseline operational failures, 20
canonical trace families, and eight strict UTF-8 behavior cases. Success cases lock named/file/inline source,
literal/file input, explicit top rule, seek/consume, canonical JSON, exact input bytes, quiet diagnostic helpers,
eager logical-helper effects, empty stderr, exit `0`, and one record newline. Failure cases lock compile-before-
input order, stable one-line stderr,
empty stdout, exit `1`, and no output files. Trace cases lock deterministic UTF-8
phase records, stdout/route/mirror, reset/persistence/append, every named level and alias,
a numeric threshold, default file routing, emoji, UTF-8 byte counts, percent-escaped
user fields, and compile/input/invocation failures.

The UTF-8 family proves decoded inline/file source, recursively encoded nested
Unicode JSON, composed/decomposed literal input without normalization, input-file
U+FEFF plus CRLF/LF preservation, non-stripping of a leading spec BOM, stable
invalid-spec/input byte phases, and exact Unicode input/result trace byte counts.
Unicode is the logical text model; UTF-8 is the selected process/file encoding.
UTF-16 and UTF-32 are not implicit alternatives in this primary command.

## Schema version 1

`manifest.json` contains an ordered `cases` array. Each case has:

- a unique lowercase `id` and a descriptive `family`;
- an `args` array appended verbatim to the selected backend command after placeholder
  expansion;
- a `files` array of records with `path` plus exactly one of checked-in `source`
  or explicit `bytes_hex`, materialized byte-for-byte into a fresh per-case workspace;
- an `expect` object with an integer `exit`, `stdout` and `stderr` objects, plus
  an expected workspace `files` array;
- exactly one `file` or inline `text` source for each expected channel.

An expected channel may also define a `variables` object. Its uppercase keys
fill placeholders in that channel's shared template without changing behavior
per backend. Custom variables may use the reserved runner placeholders in their
values, but may not override `COMMAND`, `REPO_ROOT`, `WORKSPACE`, or `CASE_ID`.

Each expected workspace-file record has a relative `path` and a `content` object
using the same exact `file`/`text` form. This is how later routed/mirrored trace
cases lock generated trace-file bytes without adding a backend-specific harness.

Paths are relative to this directory, may not traverse upward, and are validated
before any command runs. Duplicate ids, duplicate destination paths, unknown keys,
invalid types, absent fixture files, and unsupported schema versions are hard runner
errors.

`bytes_hex` is a non-empty lowercase even-length hexadecimal string. It exists for
exact non-text inputs such as malformed UTF-8 fixtures; it avoids opaque checked-in
binary blobs and never performs placeholder expansion. Defining both `source` and
`bytes_hex`, neither one, uppercase hex, odd-length hex, or non-hex characters is a
schema error before the backend command launches.

## Placeholders and exactness

The runner expands these explicit placeholders in command arguments, fixture argument
vectors, and expected channel bytes:

- `{{COMMAND}}` — the `--display-command` text; this is the only user-interface
  variation allowed between backend help/diagnostic fixtures;
- `{{REPO_ROOT}}` — the absolute checkout root, primarily for the launch command;
- `{{WORKSPACE}}` — the isolated directory for the current case;
- `{{CASE_ID}}` — the current manifest id.

After expansion, stdout and stderr are captured separately as raw bytes and compared
exactly. Newlines, Unicode/emoji bytes, trace-file contents represented by later cases,
and exit status are therefore contract data rather than loose pattern matches.
