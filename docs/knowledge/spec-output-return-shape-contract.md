---
id: spec-output-return-shape-contract
title: "A LinkedSpec parser returns the top rule value directly; output shape is the author's choice and tagged arrays are optional"
answers:
  - "what does a LinkedSpec parser return"
  - "what is the output return shape contract"
  - "does .spec impose an AST output schema"
  - "is tagged array output required"
  - "how do return and accumulator determine top level output"
date: 2026-07-08
status: confirmed
tags: [spec-language, runtime-semantics, output-shape, return, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.3 expanded mdBook runtime-semantics section 5 with verified scalar, array, and tagged-pair examples. SPEC-LANG-REFERENCE.7 promotes the durable retrieval point: the parser returns exactly the top rule value, explicit return(...) is the portable return channel, and LinkedSpec imposes no AST schema."
---

# Spec Output / Return Shape Contract

**Confirmed 2026-07-08 (`SPEC-LANG-REFERENCE.7`).** A compiled `.spec`
parser returns the value produced by the top rule directly. There is no required
wrapper or schema at the `.spec` language level.

The portable return channel is explicit `return(...)` in an action or lifecycle
block. If a rule should surface an accumulator, it should return a snapshot
directly, for example `return(copy(array(items)))`.

Output shape is the author's choice:

- scalar values are valid parser outputs;
- arrays and hashes are valid parser outputs;
- nested arrays/hashes are valid parser outputs;
- the older `"?Rule:"` tagged-array convention is optional and has no engine
  meaning.

For cross-variant testing, the Perl reference output is the behavioral oracle.
The Rust oracle card explains its one-level runner wrapper separately; that is a
test-harness reconciliation detail, not a `.spec` output-schema requirement.

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] (leaf `.7`; original book work `.3`)
- Book contract: `docs/linkedspec-book/src/appendix/runtime-semantics.md`
- Related: [[rust-perl-output-oracle]], [[blind-call-collection-shape]]
