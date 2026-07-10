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

The current manifest contains 33 cases: exact long/short help, 20 strict usage
families, seven successful source/input/parser-control families, and four
operational-failure families. Success cases
lock named/file/inline source, literal/file input, explicit top rule, seek/consume,
nested canonical JSON, exact input bytes, empty stderr, exit `0`, and one record
newline. Failure cases lock compile-before-input order, stable one-line stderr,
empty stdout, exit `1`, and no output files. Trace families land in the final Perl leaf.

## Schema version 1

`manifest.json` contains an ordered `cases` array. Each case has:

- a unique lowercase `id` and a descriptive `family`;
- an `args` array appended verbatim to the selected backend command after placeholder
  expansion;
- a `files` array of `{ "source": ..., "path": ... }` records copied byte-for-byte
  into a fresh per-case workspace;
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
