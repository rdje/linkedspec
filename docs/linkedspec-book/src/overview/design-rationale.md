# Design Rationale

LinkedSpec makes a few strong bets. Each one shapes the architecture, the DSL surface, and the project direction.

## 1. Progressive extraction is a first-class parsing style

Many practical parsing jobs are not best modeled as one pure, contiguous, token-stream pass. Real-world inputs often contain large uninteresting regions, variable formatting, and structure that emerges only after you find the right anchor.

LinkedSpec leans into:

- anchor-first parsing (find a strong signature, then parse inward)
- staged interpretation (coarse structure first, fine structure second)
- recursive descent into interesting regions
- extraction-oriented workflows (skip what you don't need)

That is why the project talks about parse modes (`seek` vs `consume`), rule paragraphs, and nested dispatch so much. Those are not incidental details — they are the design center.

The most explicit form of this bet is staged linked parsing. A stage-N spec should not be
forced to parse the whole language in one pass when the useful shape is "easy outer
anchors, hard inner island." The stage can capture the island text with source span and
semantic intent, then a later spec can parse that payload into a deeper AST. Different
payload fields from the same stage may route to different next-stage specs.

This is separate from spec-file inclusion. Inclusion or imports compose spec definitions.
Staged dispatch parses runtime text payloads carried by AST nodes. Both are useful, but
they solve different problems and must remain distinguishable in diagnostics and
descriptors.

## 2. Concision matters, but not at the expense of trust

The `.spec` language is intentionally compact. A few lines of rules with attached actions should express a useful parser.

But concision must not hide what is happening. The project direction is toward:

- fewer accidental behaviors (explicit parse modes, explicit rule modes)
- more deterministic validation (reject malformed input early with clear messages)
- clearer runtime ownership (each module owns its state and its diagnostics)
- stronger documentation expectations (every surface explained, every contract explicit)

## 3. Actions are moving toward backend-neutral semantics

Historically, LinkedSpec tolerated raw Perl-shaped behavior inside `.spec` action blocks. The long-term direction is cleaner:

- less raw embedded host-language code in `.spec` files
- more explicit helper DSL (`set(...)`, `return(hash(...))`, `push_value(...)`)
- canonical ActionIR lowering (helpers lower to a structured intermediate representation)
- portability across backends — the same helper DSL must execute identically in the Perl reference backend, the Rust backend, and any future backend

The goal is not "Perl, but cleaner." The goal is a backend-neutral `.spec` language: one contract, many execution platforms.

The same neutrality applies to staged parsing. The model is not "Perl can load another
parser" or "Rust can call another parser." It is a language-neutral parse-job contract
that any backend can implement: Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, or a later
target all receive the same source spans, parser identities, top-rule selection, result
stitching rules, and failure semantics.

## 4. The compiler is state-first, not hash-first

Internally, the compiler prefers explicit state models over loose hash access:

- `compiled_spec_state` — the rule-table source of truth
- `compiled_dependency_regex_state` — derived regex dispatch data
- `compiled_descriptor_state` — composed state for validation and projection

The outward descriptor (the public `spec`/`dependency_regex_map`/`meta` hash) is a projection, not the compiler's internal working model. This state-first design makes validation, diagnostics, and future backend work cleaner.

## 5. Transparency matters

This project should be explainable — not only what it does, but why:

- why parse modes exist (seek: match anywhere for progressive extraction; consume: match contiguously for strict parsing)
- why compiled state models exist (separate concerns, enable structured validation, project only at the boundary)
- why runtime context exists (carry structured last_error payloads, not raw Perl error strings)
- why diagnostics are structured (owner/stage attribution, rule labels, handler source labels)
- why a backend keeps a thin public facade over focused owner modules (a small public surface; the real work is isolated and replaceable, which keeps each backend's internals from leaking into the `.spec` contract)

Understanding the "why" makes the "what" easier to trust and easier to change later.
