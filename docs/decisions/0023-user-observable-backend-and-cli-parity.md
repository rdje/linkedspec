# 0023 - User-observable backend parity and one identical CLI interface

- Date: 2026-07-10
- Status: accepted
- Tags: architecture, portability, backends, cli, public-api, cross-variant-parity

## Context

ADR `0006` requires the same `.spec` files, features, runtime semantics, and compatibility across backends. ADR
`0021` schedules Dart, Julia, and Lua, and ADR `0022` makes native in-memory embedding primary while keeping CLIs
as thin adapters. A separate directive gave each backend its own CLI entrypoint.

Those records did not define an exact CLI schema or a machine-testable definition of “same feature set.” The gap
became visible during `JULIA-BACKEND-PARITY.7.3.0`: Perl `bin/linkedspec` parses arbitrary specs and inputs; Dart
and Julia expose corpus/status-oriented primary commands; the Rust workspace has no binary target. The director
clarified that parity is judged from the user's point of view. Every variant must expose the same features and
behavior, and every variant CLI must expose the same options, interpretations, positional arguments, and complete
interface.

Rust also exports `linkedspec_runtime::source_emitter` as a public crate module. Generated source is therefore a
user-observable capability, even though the interpreter remains the primary correctness oracle.

## Decision

1. **Parity is user-observable identity.** Every active backend must expose the same documented capabilities and
   observable behavior: `.spec` language, parser/runtime semantics, diagnostics, tracing, structured results,
   file/named/inline source behavior, and other public execution modes. A backend-specific implementation strategy
   is not a user-visible feature difference.
2. **Host APIs remain idiomatic but capability-equivalent.** Function names, types, ownership models, and error
   containers may follow the host language under ADR `0022`; the operations, accepted inputs, results, diagnostics,
   and behavior they make available must be equivalent.
3. **Completion claims are strict.** A corpus subset or interpreter milestone may be reported precisely, but a
   backend is not “full parity” or “complete” while any documented/exported user capability differs. Temporary
   development skew is allowed only inside an active owned task and must not be presented as a shipped parity claim.
4. **Distinct CLI names, one interface.** Each backend keeps its own primary executable name. The executable token
   and unavoidable host-language launch wrapper are the only permitted CLI differences. Everything after that
   token—commands, option names and meanings, positional arguments, validation, output, errors, trace routing, and
   exit status—must be identical.
5. **The canonical primary CLI is parser-oriented.** It has no subcommands and no positional arguments. It accepts:
   - source selection, exactly one: `--spec NAME`, `--spec-file PATH`, `--inline-spec TEXT`;
   - input selection, exactly one: `--input TEXT`, `--input-file PATH`;
   - parser controls: `--top-rule NAME`, `--parse-mode seek|consume`;
   - trace controls: `--trace LEVEL`, `--trace-file PATH`, `--trace-mode stdout|route|mirror`, `--trace-reset`,
     `--trace-emoji`;
   - help: `--help` or `-h`.
6. **Option interpretation is shared.** Trace levels accept the documented numeric form and the shared named levels
   and aliases: `none`/`quiet`, `low`, `medium`/`med`, `high`, `full`, and `debug`/`verbose`. Option order may vary;
   presence, validation, meaning, and combinations may not. Undocumented backend-specific options or subcommands
   are not part of the primary CLI.
7. **Output and exit behavior is shared.** Help and successful parsing exit `0`. Successful parsing writes one
   canonical JSON value plus one newline to stdout. Normalized spec/input/runtime failure exits `1`. Usage failure
   exits `2`. CLI-controlled stdout/stderr text, diagnostic fields/order, and trace routing are fixture-locked and
   identical after substituting only the executable token. Corpus runners and backend-status utilities are separate
   developer tools and may not extend the primary CLI.
8. **Conformance is executable.** A checked-in language-neutral CLI fixture suite drives each backend command with
   the same argument vectors and inputs, then compares normalized stdout, stderr, and exit status. Help, success,
   source/input selection errors, invalid modes/levels, compilation failure, input failure, runtime failure, and
   trace modes are required families.
9. **Public generated source is parity work.** Because Rust publicly exports source emission and generated
   execution, equivalent capability is required for Dart, Julia, Lua, and later active backends before they claim
   complete user-visible parity. `FUTURE-PARITY-BACKLOG.3` owns that work. It does not replace the interpreter
   corpus as the primary correctness oracle.
10. **A full capability matrix is required.** `FUTURE-PARITY-BACKLOG.1.6` derives a machine-readable matrix from
    the mdBook, public exports, Phase 0, and the language-neutral corpus, audits every active backend, and splits all
    residual gaps. New public features must add matrix entries and cross-backend proof.

## Consequences

- Existing Dart and Julia corpus/status commands remain useful as separate developer runners, not as the primary
  user CLI contract.
- Rust needs a primary CLI binary. Perl needs the normative fixture lock and any normalization needed to meet this
  decision exactly. Dart and Julia need parser-oriented primary commands that delegate to native libraries.
- The current 99/99 Rust/Dart/Julia interpreter corpus results remain valid and valuable, but they are scoped
  conformance evidence rather than proof of every user-visible capability.
- Generated-source deferral is still a valid implementation schedule. It is no longer compatible with a complete
  parity claim while Rust exposes that capability publicly.
- Lua and every future backend inherit both the native in-memory gate of ADR `0022` and this exact interface gate.

## Links

- Task owner: `docs/tasks/JULIA-BACKEND-PARITY.md` (`JULIA-BACKEND-PARITY.7.3.1`)
- Global repair owners: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`.1.5`, `.1.6`, `.3`)
- Original backend vision: `docs/decisions/0006-multi-backend-vision.md`
- Backend rollout order: `docs/decisions/0021-future-backend-rollout-order.md`
- Native in-memory contract: `docs/decisions/0022-native-in-memory-backend-embedding.md`
- Canonical primary trace: `docs/decisions/0024-canonical-primary-cli-trace-protocol.md`
- Strict primary UTF-8 text: `docs/decisions/0025-primary-cli-strict-utf8-text-boundary.md`
- Backend handoff: `docs/linkedspec-book/src/appendix/backend-handoff.md`
