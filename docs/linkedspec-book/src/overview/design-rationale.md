# Design Rationale

LinkedSpec makes a few strong bets.

## 1. Progressive extraction is a first-class parsing style

Many practical parsing jobs are not best modeled as one pure, contiguous, token-stream pass.

LinkedSpec leans into:

- anchor-first parsing
- staged interpretation
- recursive descent into interesting regions
- extraction-oriented workflows

That is why the project talks about parse modes, rule paragraphs, and nested dispatch so much. Those are not incidental details. They are part of the design center.

## 2. Concision matters, but not at the expense of trust

The `.spec` language is intentionally compact, but the project is moving toward stronger contracts, clearer diagnostics, and more explicit semantics.

That means:

- fewer accidental behaviors
- more deterministic validation
- clearer runtime ownership
- stronger documentation expectations

## 3. Actions are moving toward backend-neutral semantics

Historically, LinkedSpec tolerated more raw Perl-shaped behavior in `.spec` authoring. The long-term direction is stricter and cleaner:

- less raw embedded Perl
- more explicit helper DSL
- more canonical ActionIR lowering
- better portability to future non-Perl backends

## 4. Transparency matters

This project should be explainable.

Not only what it does, but why it does it that way:

- why parse modes exist
- why compiled state models exist
- why runtime context exists
- why diagnostics are structured
- why the facade is thin and ownership is pushed into modules

That is part of the purpose of this book.
