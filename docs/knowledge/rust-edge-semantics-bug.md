---
id: rust-edge-semantics-bug
title: Rust -> edge dispatch is broken — associates edges with parent regexes instead of building dependency_regex_map from child rule regexes like Perl
answers:
  - "how does -> edge dispatch work in Perl"
  - "what is wrong with the Rust -> edge implementation"
  - "how should the Rust compiler build regex alternations"
  - "what is dependency_regex_map"
date: 2026-06-15
status: confirmed
tags: [rust, bug, edge-semantics, compiler, engine]
evidence: "Full Perl pipeline analysis 2026-06-15: BootstrapSpec::Core.pm, Compiler.pm build_dependency_regex_map, HandlerVariantEmitter.pm _linkedre_or_expr and _emit_default_handler. Rust compiler.rs associates edges with current_regex_idx-1 (parent regexes) instead of building alternation from child regexes."
reverify: "cd rust && cargo test; grep -n dependency_regex_map perl/LinkedSpec/Compiler.pm"
---

# Rust `->` Edge Semantics Bug

**Confirmed 2026-06-15 through full Perl pipeline analysis.**

## What Perl does (correct)

1. Bootstrap parses `-> re_term { code }` → `['ACODE', {relabel=>'re_term', reidx=>0, code=>'...'}]`
2. RuleIR collects ACODE entries with `{relabel, reidx, code}`
3. Compiler builds `dependency_refs` from ACODE entries: `{label=>child_label, idx=>child_regex_idx}`
4. `build_dependency_regex_map` collects each child rule's regex at the specified index into a combined LinkedRE alternation
5. Generated handler calls: `LinkedRE::or($STRING, $$descr{dependency_regex_map}{$label}, $info)` — matches against the alternation of ALL child regexes
6. `$$minfo{index}` identifies which child's regex matched
7. ACODE dispatch block: `if ($$minfo{index} == 0) { call('re_term'); code } elsif ...`

**Key insight**: Rules like `grep::` with only `->` edges and zero explicit `/regex/` patterns STILL have a non-empty dependency_regex_map — it contains the child rules' entrypoint regexes.

## What Rust does (broken)

1. Compiler collects regex patterns from explicit `BodyElementKind::Regex` entries only
2. Each `->` edge is associated with `current_regex_idx - 1` (the "preceding regex" in the current rule)
3. Rules with only `->` edges have `regex_patterns = []` — empty alternation
4. Engine matches empty alternation → nothing ever matches → no edge ever fires

## Fix direction

Rewrite `compiler.rs` to build `regex_patterns` from child rule dependency refs (mirroring Perl's `build_dependency_regex_map`). Repurpose `AcodeEntry.regex_idx` to align with the alternation position of the child's regex.

## Links

- Task tree: [[RUST-EDGE-SEMANTICS]]
- Perl key files: `perl/LinkedSpec/BootstrapSpec/Core.pm` (lines 529-594), `perl/LinkedSpec/Compiler.pm` (lines 345-420), `perl/LinkedSpec/HandlerVariantEmitter.pm` (lines 355-380)
- Rust files to fix: `rust/linkedspec-core/src/compiler.rs`, `rust/linkedspec-runtime/src/engine.rs`
