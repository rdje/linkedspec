---
id: staged-prototype-function-body-selection
title: The first staged parsing prototype targets user-function body payloads
answers:
  - "what is the first staged parsing prototype payload"
  - "why choose function bodies for staged parsing first"
  - "what does STAGED-LINKED-PARSING.5.1 select"
  - "must staged function prototype tests assert AST shape"
  - "what AST shape must the function body prototype predict"
  - "how many function definition variations should staged parsing test"
  - "what variations should test the function_definition rule"
  - "can function definition AST tests use a small spec file"
  - "are staged parsing prototypes implementation language neutral"
  - "can a backend implementation define staged parsing semantics"
date: 2026-07-02
status: current
tags: [architecture, staged-parsing, user-functions, language-neutral, task-tree]
evidence: "STAGED-LINKED-PARSING.5.1 splits the broad prototype leaf and selects user-defined function body text as the first payload family. specs/spec.spec already has function_definition and extracts the braced body as text; current Perl/Rust user-function bridges provide behavior to preserve while staged parsing replaces bridge debt. The follow-up seam audit must derive the predicted returned function_definition AST shape before code, inventory a broad function-definition variation matrix, and choose the dedicated small spec/top rule for focused AST-shape tests; the proof leaf must assert that shape directly across those variations. ADR 0016 requires every staged artifact to remain implementation-language neutral: .spec syntax, AST metadata, source provenance, parse-job scheduling, registry/cache identity, diagnostics, fixtures, and docs are the contract; backend mechanics are adapters."
reverify: "rg -n 'STAGED-LINKED-PARSING\\.5\\.1|function-body|function body|function_definition|0016|implementation-language neutral' docs/tasks/STAGED-LINKED-PARSING.md docs/decisions docs/linkedspec-book/src ROADMAP_V2.md specs/spec.spec"
---

The first staged linked parsing prototype target is user-defined function body text.
This is deliberately narrow: `specs/spec.spec` already extracts
`fn name(args) { body }` as a bounded text island, and current Perl/Rust bridges already
define the behavior that the staged path must preserve.

That selection does not make a backend bridge the contract. The prototype must define
payload text, source provenance, parse-job metadata, registry dispatch, diagnostics, and
result stitching in neutral `.spec`/AST terms. Perl5, Raku, Rust, Julia, Lua, Dart, Zig,
Go, and future implementations must be able to implement the same observable behavior.

The follow-up leaves start with a read-only seam audit, then provenance plumbing,
parse-job sidecar representation, minimal registry/dispatch, and an end-to-end
function-body proof with parity gates.

The proof must assert the predicted returned `function_definition` AST shape across many
function-definition variations. Runtime behavior alone is not enough evidence for the
staged prototype. A dedicated small spec file/top rule should be used for the focused
AST-shape suite when that makes the test harness tighter.
