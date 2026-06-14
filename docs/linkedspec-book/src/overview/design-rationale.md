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

## 2. Concision matters, but not at the expense of trust

The `.spec` language is intentionally compact. A few lines of rules with attached actions should express a useful parser.

But concision must not hide what is happening. The project direction is toward:

- fewer accidental behaviors (explicit parse modes, explicit rule modes)
- more deterministic validation (reject malformed input early with clear messages)
- clearer runtime ownership (each module owns its state and its diagnostics)
- stronger documentation expectations (every surface explained, every contract explicit)

## 3. Actions are moving toward backend-neutral semantics

Historically, LinkedSpec tolerated raw Perl-shaped behavior inside `.spec` action blocks. The long-term direction is cleaner:

- less raw embedded Perl in `.spec` files
- more explicit helper DSL (`assign(...)`, `return(hash(...))`, `push_value(...)`)
- canonical ActionIR lowering (helpers lower to a structured intermediate representation)
- better portability to future non-Perl backends (Rust, etc.)

The goal is not "Perl, but cleaner." The goal is a backend-neutral `.spec` language.

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
- why the facade is thin (LinkedSpec.pm is 258 lines; real work lives in owner modules dispatched through `OwnerDispatch`)

Understanding the "why" makes the "what" easier to trust and easier to change later.
