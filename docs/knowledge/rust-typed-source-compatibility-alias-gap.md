---
id: rust-typed-source-compatibility-alias-gap
title: Rust treats five of the seven neutral source-boundary compatibility aliases as unknown helpers while Perl executes their canonical projections
answers:
  - "does Rust execute all seven typed source location compatibility aliases"
  - "which typed source compatibility aliases are missing in Rust"
  - "does Rust capture_from_rule_start match Perl"
  - "does Rust capture_len_from_rule_start match Perl"
  - "does Rust capture_rest_length match Perl"
  - "does Rust capture_slice_here match Perl"
  - "does Rust capture_slice_length match Perl"
  - "why can Rust typed source projection not preserve all alias behavior unchanged"
date: 2026-08-01
status: confirmed parity gap; director ordered Perl-equivalent Rust repair after neutral target correction
tags: [rust, perl, source-location, helpers, aliases, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.2.2.0: exact source inventory finds all 92 canonical helper names in rust/linkedspec-runtime/src/engine.rs, but only entry_named_map and match_named_map among the seven neutral compatibility aliases. The Rust primary executable compiles each of capture_from_rule_start(), capture_len_from_rule_start(), capture_rest_length(), capture_slice_here(), and capture_slice_length() and returns JSON null. LinkedSpec::call_spec_handler_subst lowers those same five Perl calls through span_text/span_length/capture_boundary_write_position typed projections; LinkedSpec::Get returns numeric 0 for the same minimal matched fixture. Repair would therefore change observable Rust behavior rather than merely re-route an unchanged result."
evidence_update_2026_08_07: "The director confirms Rust must implement Perl-equivalent behavior. Exact Perl contract records and the mdBook prove the neutral JSON/checker mislabel capture_from_rule_start as capture_from and capture_len_from_rule_start as capture_len_from: both aliases are zero-argument anonymous-boundary forms and their correct targets are capture_slice and capture_slice_len. FUTURE-PARITY-BACKLOG.14.2.2.0.1 owns the neutral correction, .0.2 the five-alias Rust repair, and .0.3 the typed-source RED."
reverify: "rg -n 'capture_from_rule_start|capture_len_from_rule_start|capture_rest_length|capture_slice_here|capture_slice_length|entry_named_map|match_named_map' rust; perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(q{Top}, q{return(capture_from_rule_start())}), qq{\\n}'"
---

# Rust typed-source compatibility-alias gap

The neutral typed-source contract lists seven callable compatibility aliases. Rust currently executes only
`entry_named_map()` and `match_named_map()` as aliases. The other five spellings compile as generic calls but reach
the unknown-helper fallback and return `undef`/JSON `null`:

- `capture_from_rule_start()`;
- `capture_len_from_rule_start()`;
- `capture_rest_length()`;
- `capture_slice_here()`; and
- `capture_slice_length()`.

The Perl reference does not return `undef` for those calls. It lowers them to the canonical `capture_from`,
`capture_len_from`, `capture_rest_len`, `start_capture_slice`, and `capture_slice_len` projection families. In the
minimal whole-input match used by the audit, all five Perl calls return numeric zero while Rust returns null.

This matters to the typed-source rollout boundary. ADR `0056` section 9 and
`FUTURE-PARITY-BACKLOG.14.2.0` require all seven aliases to project through the algebra while preserving external
results and prohibit new DSL behavior in `.14.2`. Rust cannot both acquire the five Perl-compatible results and
preserve its current null results. The owning Rust RED audit therefore stops for a director scope decision before
freezing the projection expectations or changing runtime behavior. On 2026-08-07 the director resolved that
choice: Rust must match Perl. The audit also proved the first two neutral target labels are wrong; their correct
preferred targets are `capture_slice()` and `capture_slice_len()`. The neutral correction must land before the
Rust parity implementation, which must land before the typed-source RED.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.14.2.2.0`.
- Neutral plan: [[typed-source-location-neutral-contract-plan]].
- Runtime rollout: [[typed-source-location-runtime-rollout-plan]].
