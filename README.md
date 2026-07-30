# LinkedSpec

LinkedSpec is a progressive-extraction parser DSL for describing how structured data should be captured from text.
It is designed for recursive and nested formats: specifications can place and restore cursor anchors, compose rules,
capture text between cursor positions, and stage parsing without hiding control flow in a generated black box.

One `.spec` contract is implemented by the Perl reference engine and native Rust, Dart, Julia, and Lua variants.
LinkedSpec is for language-tooling authors and developers who need expressive parsing with explicit cursor and capture
semantics across several runtimes.

## Why LinkedSpec

- Recursive rules express nested structures directly.
- Cursor-aware actions expose where matching starts, advances, and resumes.
- Captures can use matched text, entry spans, or explicit cursor intervals.
- Staged parsers can delegate a captured region to another generated parser.
- A shared conformance contract keeps the runtime variants aligned.

The [mdBook](docs/linkedspec-book/src/SUMMARY.md) explains the language, runtime model, examples, and current backend
status in depth.

## Quick start

Prerequisite: Perl 5 and a checkout of this repository. From the repository root:

```sh
perl bin/linkedspec --spec Lispish --input '(hello world)'
```

Expected output:

```text
["hello",["world"]]
```

Continue with the [user guide](USER_GUIDE.md) or the mdBook's
[Lispish walkthrough](docs/linkedspec-book/src/specs-and-corpora/lispish-spec-walkthrough.md). Backend-specific setup and commands
live in the [Rust](rust/README.md), [Dart](dart/README.md), [Julia](julia/README.md), and [Lua](lua/README.md) guides.

## Architecture at a glance

```text
.spec source -> contract validation -> parser compilation -> cursor-driven execution -> captured value
                                      \-> staged parser registry
```

The Perl implementation is the behavioral reference. Native variants implement the same public contract and are
admitted capability by capability through shared fixtures and conformance gates. See
[Architecture State](ARCHITECTURE_STATE.md) for the current owner graph and the mdBook's
[backend handoff](docs/linkedspec-book/src/appendix/backend-handoff.md) for variant status.

The checkout is relocatable: project paths are stored relative to the repository root and resolved at runtime.
Project-owned outputs, caches, logs, fixtures, and temporary workspaces stay on the repository's filesystem volume.
The governing decisions and verification commands are indexed in the [decision records](docs/decisions/INDEX.md) and
[Knowledge Map](KNOWLEDGE_MAP.md).

## Documentation

- [mdBook source](docs/linkedspec-book/src/SUMMARY.md) — canonical public manual, examples, and backend status.
- [User guide](USER_GUIDE.md) — detailed `.spec` authoring reference.
- [Roadmap](ROADMAP.md) and [roadmap companion](ROADMAP_V2.md) — direction and sequencing.
- [Task-tree index](docs/TASK_TREE.md) — active, proposed, blocked, and completed work.
- [Architecture State](ARCHITECTURE_STATE.md) — current implementation structure and ownership.
- [Toolbox](TOOLBOX.md) — diagnostics, trace tools, focused checks, and the canonical local gate.
- [Memory Architecture](MEMORY_ARCHITECTURE.md) — durable continuity and retrieval model.
- [README policy](README_POLICY.md) — what belongs on this landing page and how its size is governed.

## Repository layout

| Path | Purpose |
| --- | --- |
| `specs/` | LinkedSpec language specifications. |
| `perl/` | Perl reference implementation. |
| `rust/`, `dart/`, `julia/`, `lua/` | Native runtime variants and their local guides. |
| `bin/` | User-facing command-line entry points. |
| `t/`, `tests/`, `test_input/` | Regression, conformance, and input fixtures. |
| `tools/`, `scripts/` | Repository-rooted verification and maintenance tools. |
| `docs/linkedspec-book/` | Public mdBook source. |
| `docs/tasks/`, `docs/decisions/`, `docs/knowledge/` | Work, decisions, and durable facts. |

## Development and contribution

Read [AGENTS.md](AGENTS.md) and [SESSION_BOOTSTRAP.md](SESSION_BOOTSTRAP.md) before changing the repository. Every
change needs an owning task-tree leaf and follows the per-leaf [commit workflow](COMMIT.md).

Run the canonical local gate from the repository root:

```sh
bash tools/run_ci_local.sh
```

Focused checks and gate composition are documented in [TOOLBOX.md](TOOLBOX.md). Hosted GitHub Actions are
intentionally disabled; the local gate is authoritative.

## Status and support

Current delivery status belongs in the [roadmap](ROADMAP.md), [task-tree index](docs/TASK_TREE.md), and
[changelog](CHANGES.md). Report reproducible problems through the repository's
[GitHub issues](https://github.com/rdje/linkedspec/issues).

## License and notices

LinkedSpec does not currently declare a project-level license. Do not infer permission for the project from a
nested or vendored component's license. Those components retain their own notices; project-level licensing is an
explicitly tracked governance decision.
