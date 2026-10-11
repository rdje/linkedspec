---
id: perl-scalar-bound-receiver-copy
title: Perl single-step receiver copy preserves a scalar binding's runtime container type
answers:
  - "does Perl meta copy preserve a hash stored in a scalar"
  - "why did single step receiver copy return an empty array for a hash"
  - "does empty hash receiver copy stay a hash on Perl"
  - "does Perl receiver copy share nested references"
  - "does scalar receiver copy consume typed AST fields"
  - "where is the scalar bound receiver copy repair verified"
date: 2026-10-10
status: accepted public repair at770cffcc; original proof requires its accepted Git input state
tags: [perl, actionir, ast, copy, containers, receivers]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0 retains identical50 assertions: original9 semantic REDs/41 controls/all50 current GREEN. Live Get and retained standalone source each execute14 cases; typed AST poisoning is independent. Three syntax-valid faults fail9/4/8 named assertions. Supplied61 suites/184 files, evidence5/original307 restoration and complete book89/three controls pass. Native probe/regression/channels remain unchanged; canonical admission is separate."
reverify: "Use accepted770cffcc Git inputs including the original live claim: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0-book-repair/review.py; separately book-repair/publish-claim.py under that wrapper. Defaults readonly. Original final review/publications replay from retained failed03 inputs via book-repair/replay.py; original runtime/CI source and observations stay exact. Capture/freezer/faults/evidence/publication writers are one-shot. Earlier regex proof requires accepted2b4e484a9 Git inputs including original live claim."
---

Ordinary bare assignment remembers a scalar value slot, which can contain either
an array or a hash. The AST hash-copy discriminator recognized an aggregate hash
binding or a later hash method. A scalar-bound variable with a single `.copy()`
therefore fell through to array wrapping and returned `[]` for hash values.

The bounded repair routes a variable known to be scalar-bound, with one copy call
and no arguments, through the existing aggregate function-form copy lowerer.
That lowerer dispatches from the runtime array/hash value. Empty hashes remain
hashes. Arrays and empty arrays retain their values; other scalar values keep
the existing empty-array result.

Both spellings create a distinct outer container and retain shared nested
references on Perl. The probe checks live and actual standalone execution before
serialization, so identity is observed rather than inferred from equal JSON.
Full generated source is retained in each actual observation channel. Typed AST
chain/receiver/call source fields are poisoned; their semantic fields still
produce the correct hash result.

Multi-step chains, legacy rule aggregate storage and wrong-arity diagnostics
retain their controls. The separate legacy hash kind callback repair has bounded
proof in `docs/knowledge/perl-legacy-hash-kind-callback.md`; required receiver capture and independent factory/private/
mapped admissions remain open. This proof covers the scalar-bound single-step
population and does not establish other receiver populations.
