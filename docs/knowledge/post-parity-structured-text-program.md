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
  - are binary formats and packaged containers in the structured text program
date: 2026-07-15
status: current
tags: [roadmap, formats, parser, ast, unicode, performance, conformance, parity, FUTURE-PARITY-BACKLOG]
evidence: "Director/engineer agreement on 2026-07-15; ADR 0034; FUTURE-PARITY-BACKLOG.18.0; exact 91-row ownership in docs/tasks/STRUCTURED-TEXT-FORMAT-PROGRAM.md; public architecture chapter architecture/structured-format-program.md. No parser/compiler/runtime behavior or format implementation changes in the ratification slice."
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

## Links

- Decision: ADR `0034`.
- Parent owner: [[FUTURE-PARITY-BACKLOG]] `.18.0`.
- Detailed execution tree: [[STRUCTURED-TEXT-FORMAT-PROGRAM]].
- Existing doctrines: ADRs `0011`, `0012`, `0016`, `0023`, `0025`, and `0026`.
