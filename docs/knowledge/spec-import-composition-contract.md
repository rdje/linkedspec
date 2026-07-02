---
id: spec-import-composition-contract
title: Spec imports compose grammar material and remain separate from staged parse dispatch
answers:
  - "how should spec imports work"
  - "what is the difference between import and include in LinkedSpec"
  - "are imports the same as staged parse jobs"
  - "what syntax is planned for spec imports"
  - "how are imported rules named"
  - "how should import cycles be diagnosed"
  - "are spec imports language neutral"
  - "does include concatenate raw spec text"
date: 2026-07-02
status: current
tags: [architecture, imports, parser-composition, language-neutral, spec-language]
evidence: "ADR 0013 accepts the design-only spec import/composition contract: file-scope import \"path.spec\" as alias and include \"path.spec\" directives; import uses qualified alias.rule references; include performs a structured merge into the unqualified namespace; both preserve source provenance, reject collisions/cycles, and affect descriptor fingerprints. ADR 0013 explicitly says current shipped parsers do not yet accept the directives and that staged parse jobs remain a separate runtime payload parsing mechanism."
reverify: "rg -n 'import \"common/atoms.spec\" as atoms|include \"common/lifecycle.spec\"|qualified name|structured merge|current shipped parsers do not yet accept|0013|STAGED-LINKED-PARSING.2' docs/decisions docs/tasks docs/linkedspec-book/src ROADMAP_V2.md"
---

LinkedSpec's spec-file composition design is intentionally separate from staged parse
dispatch.

The planned file-scope syntax is:

```text
import "common/atoms.spec" as atoms
include "common/lifecycle.spec"
```

`import` loads another `.spec` behind an explicit alias, so imported rules are referenced
with qualified names such as `atoms.Identifier`. `include` is for structured composition
into the current unqualified namespace. It is not raw textual concatenation.

Imports and includes are grammar-composition declarations. They do not parse runtime
text extracted by an AST node. Runtime payload refinement belongs to staged parse jobs.

Diagnostics must be deterministic and language-neutral: duplicate aliases, duplicate
included rule names, ambiguous unqualified references, missing specs, and import cycles
are hard errors with source provenance. Cache keys and descriptor fingerprints include
the normalized identity and content digest of every composed spec.

This is currently an accepted design contract, not a shipped parser feature.
