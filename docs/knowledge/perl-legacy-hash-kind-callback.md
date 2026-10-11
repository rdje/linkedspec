---
id: perl-legacy-hash-kind-callback
title: Legacy hash receiver normalization selects the caller's kind callback locally
answers:
  - "why did legacy hash receiver copy call an undefined package variable"
  - "does legacy hash normalization use the injected bare_symbol_kind callback"
  - "what happens when the legacy hash kind callback is missing or non CODE"
  - "when does legacy hash normalization select its kind callback"
  - "can the hash kind callback donate publication to its enclosing normalizer"
  - "where is the legacy hash kind callback repair verified"
date: 2026-10-11
status: bounded runtime consumer evidence and book proof verified; supplemental public compatibility passed
tags: [perl, actionir, callbacks, receivers, hash, aliases]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1 retains35 first-native cases:23 unchanged controls and12 intended selection/default repairs, plus two cold rows. Paired487 assertions have48 original REDs/439 controls/all487 current GREEN. Five syntax-valid faults reject48/3/9/5/3. Supplied61 suites/187 inputs/11664 assertions and full book89/three controls and six actual evidence RED/restorations pass. Supplemental standard syntax/public Phase0 passes1035; it has no full transitive input capsule. All546 predecessor bindings remain historical at770cffcc. Original draft/refused-wrapper observations are retained and their bounded corrections replay exactly."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-review.py"
  - "Use the original accepted leaf's Git input state when later changes supersede its exact module/test/book bindings. Capture/freezer/correction writers are one-shot; do not refresh observations."
---

The private legacy hash normalizer used an unbound package variable for its kind
callback. A valid injected hash callback therefore failed before being called
when package state was undefined. Conflicting package callbacks could also select
the wrong container family.

The normalizer now selects the actual CODE reference from its dependency map once,
before trim. Missing/non-CODE callbacks supply an undefined kind. A trim callback
may replace the map entry, but the current invocation retains its selected
callback. The caller's map and actual callback references remain intact.

Known hashes admit a single copy; known arrays decline hash normalization. An
unknown kind can still use the existing next-method family lookahead. Explicit
container, arity, terminal-chain and early-source guards keep their native results.
The callback receives the original match argument in scalar context, preserving
its write rejection and fatal-object identity. Its private capture separates
nested publication from the enclosing normalizer; known callback authority uses
the actual reference. Require-only use keeps the emission channel unloaded.

The separate public scalar-held copy repair remains accepted at770cffcc. This
bounded private repair does not admit complete helper/AST/language behavior or
the required hash callback capture owned by `.3.1.6.3`. Other optional/direct,
output/mapping, full-private and independent parent admissions retain their owners.

The match flag/write distinction has its own canonical fact card:
`docs/knowledge/perl-match-alias-writability.md`.
