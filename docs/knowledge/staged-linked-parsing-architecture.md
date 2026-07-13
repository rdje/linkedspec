---
id: staged-linked-parsing-architecture
title: Staged linked parsing is LinkedSpec's language-neutral parser-composition model
answers:
  - "what is staged linked parsing"
  - "why is LinkedSpec called LinkedSpec"
  - "can one spec parse extracted text with another spec"
  - "can a stage spawn multiple next-stage parsers"
  - "does stage N map to only one stage N+1 spec"
  - "what is a parse job"
  - "are spec imports the same as staged parse dispatch"
  - "is staged parsing Perl-specific"
  - "is staged parsing language neutral"
  - "how should extracted text islands be parsed"
  - "what should a next-stage parse record contain"
  - "how is a parse job annotated"
  - "how are staged parse jobs dispatched"
  - "does spec.spec remain the first .spec grammar"
  - "what is the import composition contract for staged parsing"
  - "what is the difference between progressive and staged parsing"
  - "does current staged parsing support arbitrary in-parse parser invocation"
date: 2026-07-02
status: current
tags: [architecture, staged-parsing, parser-composition, language-neutral, spec-spec]
evidence: "ADR 0012 adopts staged linked parsing as core architecture: stage-N specs may emit AST nodes carrying raw extracted text, source span, payload kind, and parse intent; each payload can become a parse job naming parser spec identity, optional top rule, parent AST path, insertion policy, and failure policy; one stage may spawn many different next-stage specs. ADR 0013 separately accepts the design-only spec import/composition contract: file-scope import aliases and structured includes compose grammar material, while staged parse jobs parse runtime payload text. ADR 0014 accepts the design-only parse_job(text_expr, options) annotation plus source-aware sidecar metadata schema. ADR 0015 accepts the design-only deterministic registry/dispatch queue. The contract is implementation-language neutral across Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, or future backends. For .spec language evolution, specs/spec.spec remains the first authoritative grammar; hardcoded bootstrap grammar is bridge debt, not a competing permanent owner."
reverify: "rg -n 'staged linked parsing|parse job|text islands|Spec imports|implementation-language neutral|Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go|0012|STAGED-LINKED-PARSING' docs/decisions docs/tasks docs/linkedspec-book/src ROADMAP_V2.md"
---

LinkedSpec's parser-composition model is staged and linked. A stage parses the
structure whose anchors are easy and reliable, emits AST nodes that may contain
raw text payloads, and records enough provenance to parse those payloads later.

A later stage is not necessarily one global `N+1` grammar. The stage-N AST can
spawn multiple parse jobs, and each payload kind can route to a different spec.
A parse job should carry at least:

- job id
- parent AST path
- node kind
- payload kind
- parser spec identity
- optional top rule
- source text and source span
- result insertion policy
- failure/diagnostic policy

The accepted design-only authoring marker is `parse_job(text_expr, options)`. It creates
a marker value in the AST and a backend-neutral metadata sidecar. Current shipped parsers
do not yet accept or execute that helper.

The accepted dispatch design resolves parse jobs through a neutral registry, orders them
by parent AST path, source span, and job id, caches compiled parsers by content and
capability fingerprints, and diagnoses active-chain cycles.

Spec imports/composition and staged parse dispatch are different. Imports compose
grammar material. Staged dispatch parses runtime payload text that a previous parser
extracted.

The accepted import/composition design uses future file-scope directives such as
`import "common/atoms.spec" as atoms` and `include "common/lifecycle.spec"`. Imported
rules are qualified through the alias; included rules merge structurally into the current
namespace. This is a design contract until the parser implementation lands.

This model is language-neutral. It is not a Perl5 or Rust trick. Any backend that
implements LinkedSpec should preserve the same parse-job contract and diagnostics,
whether the implementation is Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, or a later
language.

For `.spec` language evolution, `specs/spec.spec` is the first authoritative grammar.
Other `.spec` parsing stages derive from that self-hosted path rather than a competing
permanent bootstrap grammar.

The director's 2026-07-12 clarification distinguishes progressive composition from the
post-AST staged queue. Progressive parsing is the intended ability of an active parser
to capture text relative to reliable cursor anchors and invoke an appropriate loaded
spec parser over that text. Staged parsing selects extracted fields from a returned AST
level and refines them through later spec parsers. ADR 0012's parse graph remains the
neutral umbrella, but the current implementation proves only the narrow function-body
`body_parse_job` family; arbitrary in-parse composition, multiple public parser families,
and recursive queues remain future work under `FUTURE-PARITY-BACKLOG.14.2-.14.4`.
