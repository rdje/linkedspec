---
id: post-parity-structured-text-program
title: Real Unicode text formats drive LinkedSpec evolution only after current backend parity
answers:
  - what happens after all current LinkedSpec backends reach parity
  - will LinkedSpec parse the Unicode structured text catalog
  - how many eligible structured text catalog rows are planned
  - do format parsers start before Lua parity is complete
  - how do real formats drive new spec language features
  - are spec files the sole source of truth for format parsers
  - are format parsers dynamically created from spec files
  - may generated host parsers become authoritative
  - may a backend host parser hide a missing spec feature
  - is HTML parsed as XML in the format program
  - does parsing Jsonnet Dhall CUE Pkl Nickel or Nix include evaluation
  - how will structured text parsers prove Unicode accuracy and speed
  - must dynamic format parsers trace construction and runtime execution
  - can a structured text parser trace selected rules only
  - may a dynamic spec parser have an optional backend native accelerator
  - does native acceleration replace the dynamic spec parser
  - are binary formats and packaged containers in the structured text program
date: 2026-07-15
status: current
tags: [roadmap, formats, parser, ast, unicode, performance, conformance, parity, FUTURE-PARITY-BACKLOG]
evidence: "Director/engineer agreement on 2026-07-15; ADR 0034; FUTURE-PARITY-BACKLOG.18.0; exact 91-row ownership in docs/tasks/STRUCTURED-TEXT-FORMAT-PROGRAM.md; public architecture chapter architecture/structured-format-program.md. No parser/compiler/runtime behavior or format implementation changes in the ratification slice."
evidence_update_2026_07_15_observability: "ADR 0037 and FUTURE-PARITY-BACKLOG.18.2 make correlated compile/runtime trace, exact emission-only rule filters, bounded payloads, and traced/untraced parity proof a future readiness contract under STRUCTURED-TEXT-FORMAT-PROGRAM.2.7."
evidence_update_2026_07_15_native_acceleration: "ADR 0038, FUTURE-PARITY-BACKLOG.18.3, and NATIVE-PARSER-ACCELERATOR govern an optional measured backend-native derivative after a dynamic format parser is correct. The dynamic parser remains primary, oracle, and fallback; the acceleration horizon is separate and non-blocking for the 91-format program."
reverify: "rg -n '91|Parity first|Formats drive general features|HTML is not XML|Parsing scope stays honest' docs/tasks/STRUCTURED-TEXT-FORMAT-PROGRAM.md docs/decisions/0034-post-parity-structured-text-requirements-program.md docs/linkedspec-book/src/architecture/structured-format-program.md"
---

# Post-Parity Structured-Text Requirements Program

ADR `0034` adopts the 91 eligible rows in the director-provided 10 July 2026 Unicode structured-text catalog as
LinkedSpec's post-parity requirements program. No format implementation begins until Perl, Rust, Dart, Julia, and
Lua have full feature and behavior parity and the remaining cross-backend parity owners close.

The catalog is not merely a parser wish list. Each format's composed `.spec` graph is the sole executable source
of truth: every backend dynamically constructs/compiles that parser and can immediately use it on documents.
Generated host source or compiled caches are reproducible fingerprinted derivatives, never parallel grammar
owners. Each authoritative format and conformance corpus pressures the universal `.spec` language. When a format
exposes a missing general mechanism, that format pauses while the
mechanism gains a neutral contract, implementation and exact proof on all current backends, book documentation,
and recurring gates. Host-language callbacks, opaque native parsers, and backend-only `.spec` dialects may not
hide the missing capability.

Derived formats reuse syntax foundations: JSON serializations reuse JSON; XML vocabularies reuse XML; YAML
serializations reuse YAML; RDFa/Microdata reuse an HTML tree; GFM reuses CommonMark; related RDF formats reuse
Turtle/RDF terms. Conditional conventions such as CSV, INI, dotenv, generic Markdown, and JUnit XML use explicit
named profiles. Ordinary HTML is an independent WHATWG tokenizer/tree-construction/error-recovery seed, not an
XML derivative; XHTML reuses XML.

Completion requires pinned authoritative sources/corpora, source-aware AST/trivia and portable diagnostic
contracts, exact five-backend execution, adversarial Unicode proof, differential oracles where practical, public
examples, and correctness-preserving performance/resource measurements. Parsing CUE, Dhall, Jsonnet, Nickel, Pkl,
Nix, schemas, or IDLs to AST does not silently include evaluation, validation, compilation, package loading, or
binary codecs. Binary/database/container formats remain outside this text program.

ADR `0037` additionally requires every dynamic format parser to expose correlated construction and runtime trace
through its normal API. An exact rule-label filter focuses emitted events without changing behavior, and shared
fixtures prove traced/untraced identity. The executable contract remains parity-gated under
`STRUCTURED-TEXT-FORMAT-PROGRAM.2.7`.

ADR `0038` permits a later optional backend-native acceleration tier only after a realistic dynamic format parser
is complete and measured. Such an artifact is a fingerprinted disposable derivative of normalized compiled state,
must preserve the complete AST/diagnostic/Unicode/recovery/trace contract, and must demonstrate an objective
benefit including build/load and break-even costs. The dynamic parser remains the always-available primary path,
oracle, and fallback. This separate horizon does not block format completion or require acceleration on Perl.

## Links

- Decisions: ADRs `0034`, `0037`, and `0038`.
- Parent owner: [[FUTURE-PARITY-BACKLOG]] `.18.0`.
- Detailed execution tree: [[STRUCTURED-TEXT-FORMAT-PROGRAM]].
- Optional non-blocking acceleration tree: [[NATIVE-PARSER-ACCELERATOR]].
- Existing doctrines: ADRs `0011`, `0012`, `0016`, `0023`, `0025`, and `0026`.
