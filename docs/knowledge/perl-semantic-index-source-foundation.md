---
id: perl-semantic-index-source-foundation
title: Perl semantic-index construction is opaque, strict-UTF-8, and failure-preserving
answers:
  - "how does LinkedSpec semantic_index normalize source"
  - "is the Perl semantic index object immutable and opaque"
  - "what happens when semantic_index compilation fails"
  - "how are Perl semantic source spans calculated"
  - "can LinkedSpec semantic_index read a source path"
  - "which Perl semantic_index options are required"
date: 2026-09-06
status: current
tags: [perl, semantic-introspection, utf8, source-map, immutability, diagnostics]
evidence: perl/LinkedSpec/SemanticIndex.pm; perl/LinkedSpec/SemanticSourceMap.pm; t/semantic_index_perl_foundation.t; docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md
reverify: bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/semantic_index_perl_foundation.t
---

`LinkedSpec::semantic_index(\$source, logical_name => ..., source_detail_ceiling => ...)` copies and normalizes
decoded character input or strict UTF-8 bytes, never reads a path, and returns an opaque inside-out
`LinkedSpec::SemanticIndex`. It compiles once through the existing runtime-context/descriptor pipeline without
executing the parser. Language compilation failure still returns an immutable `failed_compilation` outcome with
the structured runtime diagnostic; malformed UTF-8 or constructor options throw a typed native error.

`LinkedSpec::SemanticSourceMap` derives zero-based half-open byte ranges and one-based line/Unicode-scalar columns
from the canonical bytes, rejects mid-codepoint boundaries, and supports cursor-ordered exact occurrence mapping.
Only clone-safe foundation projections cross the object boundary; descriptor coderefs/regex objects and decoded
source remain private. Later leaves retain private static/call/staged records, expose immutable queries, add
caller-owned observations, and compose the admitted Perl surface without widening this constructor. See
[[perl-semantic-static-projection]], [[perl-semantic-introspection-authority-map]], and
[[semantic-introspection-neutral-contract]], [[perl-semantic-introspection-admission]].

## September 6 index-owner reading

`SESSION-STARTUP-READING.3.2.42` reads SemanticIndex 1–395 completely. Index state stays
inside-out; construction keeps copied source/outcome/private projection, query delegation receives detached
data, and derived execution indexes preserve the original static instance. The three focused foundation,
call-projection, and query suites pass twenty tests collectively against unchanged source. Source mapping
and runtime-projection comprehension retain their separately owned subsequent checkpoint; this does not
claim full-codebase or newly completed backend admission.
