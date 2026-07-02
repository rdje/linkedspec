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
  - "does spec.spec remain the first .spec grammar"
date: 2026-07-02
status: current
tags: [architecture, staged-parsing, parser-composition, language-neutral, spec-spec]
evidence: "ADR 0012 adopts staged linked parsing as core architecture: stage-N specs may emit AST nodes carrying raw extracted text, source span, payload kind, and parse intent; each payload can become a parse job naming parser spec identity, optional top rule, parent AST path, insertion policy, and failure policy; one stage may spawn many different next-stage specs. The mdBook overview, design rationale, compiler pipeline, and backend handoff now explain that spec imports/composition are separate from staged parse dispatch. The contract is implementation-language neutral across Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, or future backends. For .spec language evolution, specs/spec.spec remains the first authoritative grammar; hardcoded bootstrap grammar is bridge debt, not a competing permanent owner."
reverify: "rg -n 'staged linked parsing|parse job|text islands|Spec imports|implementation-language neutral|Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go|0012|STAGED-LINKED-PARSING' docs/decisions docs/tasks docs/linkedspec-book/src ROADMAP_V2.md"
---

LinkedSpec's parser-composition model is staged and linked. A stage parses the
structure whose anchors are easy and reliable, emits AST nodes that may contain
raw text payloads, and records enough provenance to parse those payloads later.

A later stage is not necessarily one global `N+1` grammar. The stage-N AST can
spawn multiple parse jobs, and each payload kind can route to a different spec.
A parse job should carry at least:

- parser spec identity
- optional top rule
- source text and source span
- parent AST path
- payload kind
- result insertion policy
- failure/diagnostic policy

Spec imports/composition and staged parse dispatch are different. Imports compose
grammar material. Staged dispatch parses runtime payload text that a previous parser
extracted.

This model is language-neutral. It is not a Perl5 or Rust trick. Any backend that
implements LinkedSpec should preserve the same parse-job contract and diagnostics,
whether the implementation is Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, or a later
language.

For `.spec` language evolution, `specs/spec.spec` is the first authoritative grammar.
Other `.spec` parsing stages derive from that self-hosted path rather than a competing
permanent bootstrap grammar.
