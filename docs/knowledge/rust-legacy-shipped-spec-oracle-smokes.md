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
date: 2026-07-04
status: confirmed
tags: [rust, oracle, corpus, parity, shipped-specs, legacy, plugin, RUST-PARITY]
evidence: "RUST-PARITY.7.3.6 probed RTL/plugin/legacy candidates through the Perl reference and a temporary Rust parity probe before fixture promotion. Seven JSON-safe Rust-green smokes were added to tools/gen_oracle_corpus.pl and checked into rust/linkedspec-runtime/tests/corpus/: regdef_nested_register_fields, tablegrep_simple_term, simenv_multiline_value, vhdl_library_use, ds_vhistory_version_entry, pplugin_empty, and tkgui_empty. `perl -c -Iperl tools/gen_oracle_corpus.pl`, `perl -Iperl tools/gen_oracle_corpus.pl`, Rust `corpus_oracle`, and Rust `parse_all_shipped_specs` passed; corpus size is 88 fixtures. Richer candidates were kept out: pplugin real subdefs return coderefs that JSON cannot encode, tkgui body returns still hit raw Perl pair-return action parsing, sdce slice/capture segmentation diverges, recursive tablegrep groups over-report child terms in Rust, simenv single-line values lose verbatim payload, VHDL entity port clauses collapse to null, ds_vhistory branch entries classify as version entries, and verilog returns Perl 0 versus Rust empty accumulator."
reverify: "perl -c -Iperl tools/gen_oracle_corpus.pl && perl -Iperl tools/gen_oracle_corpus.pl && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime parse_all_shipped_specs -- --nocapture"
---

# Rust Legacy Shipped-Spec Oracle Smokes

`RUST-PARITY.7.3.6` is a fixture-promotion leaf, not a broad legacy/plugin
implementation leaf.

Green fixtures now active in the Rust oracle corpus:

- `regdef_nested_register_fields`
- `tablegrep_simple_term`
- `simenv_multiline_value`
- `vhdl_library_use`
- `ds_vhistory_version_entry`
- `pplugin_empty`
- `tkgui_empty`

The corpus has **88 fixtures** after this slice.

Non-promoted blockers remain explicit follow-up evidence:

- real `pplugin` subdefinitions return Perl coderefs, which the canonical JSON oracle cannot encode.
- `tkgui` body returns still depend on a raw Perl pair-return action that Rust does not parse today.
- `sdce` brace/slice capture segmentation diverges.
- recursive `tablegrep` groups over-report child terms in Rust.
- `simenv` single-line values currently lose the verbatim payload in Rust.
- VHDL entity port clauses collapse to `null` under current Rust execution.
- `ds_vhistory` branch entries are classified as version entries.
- placeholder `verilog` returns Perl `0` while Rust returns an empty accumulator.

`pplugin_empty` is only syntax reachability for the empty parser path. It is not plugin
runtime parity and does not move dynamic `.plg` loading into the backend-neutral target
architecture.
