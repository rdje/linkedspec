---
id: rust-legacy-shipped-spec-oracle-smokes
title: RUST-PARITY.7.3.6 added seven RTL/plugin/legacy shipped-spec safety smokes and left richer mismatches as follow-up blockers
answers:
  - "what did RUST-PARITY.7.3.6 add"
  - "which RTL plugin legacy shipped spec smokes are in the Rust oracle corpus"
  - "how many Rust oracle fixtures after RUST-PARITY.7.3.6"
  - "why are richer pplugin tkgui sdce tablegrep simenv vhdl ds_vhistory verilog fixtures not promoted"
  - "which shipped spec candidates remain follow-up blockers after RUST-PARITY.7.3.6"
  - "does pplugin_empty prove plugin runtime parity"
date: 2026-09-08
status: historical July promotion evidence; September reading scope clarified
tags: [rust, oracle, corpus, parity, shipped-specs, legacy, plugin, RUST-PARITY]
evidence: "RUST-PARITY.7.3.6 probed RTL/plugin/legacy candidates through the Perl reference and a temporary Rust parity probe before fixture promotion. Seven JSON-safe Rust-green smokes were added to tools/gen_oracle_corpus.pl and checked into rust/linkedspec-runtime/tests/corpus/: regdef_nested_register_fields, tablegrep_simple_term, simenv_multiline_value, vhdl_library_use, ds_vhistory_version_entry, pplugin_empty, and tkgui_empty. `perl -c -Iperl tools/gen_oracle_corpus.pl`, `perl -Iperl tools/gen_oracle_corpus.pl`, Rust `corpus_oracle`, and Rust `parse_all_shipped_specs` passed; corpus size was 88 fixtures. Richer candidates were kept out at that time: pplugin real subdefs returned coderefs that JSON could not encode, tkgui body returns still hit raw Perl pair-return action parsing, sdce slice/capture segmentation diverged, recursive tablegrep groups over-reported child terms in Rust, simenv single-line values lost verbatim payload, VHDL entity port clauses collapsed to null, ds_vhistory branch entries classified as version entries, and verilog returned Perl 0 versus Rust empty accumulator. SPEC-SOURCE-TERSE-CLOSEOUT.1 later changed pplugin.spec to return body text instead of coderefs; richer pplugin Rust parity remains separate from this historical smoke leaf."
evidence_update_2026_09_08: "Startup .3.3.43 physically reads the complete manifest, SimEnv and plugin-empty inputs: current manifest has 105 unique cases, while 88 is the historical promotion count. Empty input proves only the exercised empty path; historical richer-case outcomes below were not rerun. A distinct current SimEnv variable-dispatch defect is owned by startup .76."
evidence_update_2026_09_08_corpus_reading: "Startup .3.3.49 reconciles 202 baseline scopes across 68 manifest-owned cases, including 67 decoded JSON files and the explicit empty TkGui input. The stored tablegrep smoke is one TERM, TkGui expects an empty object, and VHDL captures library/use tags with intervening newlines. This source/oracle review does not rerun those cases or broaden the historical smoke promotion."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test corpus_oracle -- --nocapture && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime parse_all_shipped_specs -- --nocapture"
---

# Rust Legacy Shipped-Spec Oracle Smokes

`RUST-PARITY.7.3.6` is a fixture-promotion leaf, not a broad legacy/plugin
implementation leaf.

Fixtures promoted by the July leaf:

- `regdef_nested_register_fields`
- `tablegrep_simple_term`
- `simenv_multiline_value`
- `vhdl_library_use`
- `ds_vhistory_version_entry`
- `pplugin_empty`
- `tkgui_empty`

The July promotion produced **88 fixtures**. September 8 manifest reading finds **105 unique cases**; this is
an inventory check, not a new Rust execution claim.

The following richer-case outcomes are historical evidence, not a September re-execution. The pplugin reason changed after
`SPEC-SOURCE-TERSE-CLOSEOUT.1`: the spec now returns body text instead of coderefs, but a richer
Rust oracle case still needs separate parser/runtime parity ownership.

- `tkgui` body returns still depend on a raw Perl pair-return action that Rust did not parse in that probe.
- `sdce` brace/slice capture segmentation diverges.
- recursive `tablegrep` groups over-report child terms in Rust.
- `simenv` single-line values lost the verbatim payload in the historical Rust probe.
- VHDL entity port clauses collapse to `null` under that historical Rust execution.
- `ds_vhistory` branch entries are classified as version entries.
- placeholder `verilog` returns Perl `0` while Rust returns an empty accumulator.

`pplugin_empty` is only syntax reachability for the empty parser path. It is not plugin
runtime parity and does not move dynamic `.plg` loading into the backend-neutral target
architecture.

The separately reproduced SimEnv bare-variable callee mismatch is owned by `SESSION-STARTUP-READING.76`; see
[[simenv-variable-dispatch-mismatch]]. These two SimEnv findings are not interchangeable.
