---
id: perl-root-rule-selection-preflight
title: "Perl root selection loses authored marker identity between bootstrap tokens and compiled metadata"
answers:
  - "where does Perl currently select the root rule"
  - "why does Perl choose an ordinary rule before a later Rule:: marker"
  - "where does Perl preserve Rule:: during bootstrap parsing"
  - "does the Perl descriptor expose authored is_top"
  - "does Perl generated source preserve authored root markers"
  - "when does Perl reject an unknown top_rule"
  - "does LinkedSpec::Get forward strict_syntax to validation"
  - "how should Perl root rule selection be implemented safely"
  - "which Perl leaves own root selection implementation"
  - "how will shared CLI root selection fixtures migrate"
date: 2026-07-18
status: confirmed pre-implementation map; behavior remains unchanged through FUTURE-PARITY-BACKLOG.9.1.1.2.1.0
tags: [perl, root-rule, top-rule, bootstrap, validation, descriptor, generated-source, strict-syntax, cli, FUTURE-PARITY-BACKLOG]
evidence: "Read-only TOOLBOX probes and exact owner retrieval under `.9.1.1.2.1.0` establish the complete pre-edit path. `validate_spec_content` rejects a one-or-more-rule markerless source. Bootstrap preserves definition order and emits `ELABEL` for `Rule:` plus `ELABEL_INITIAL` for every `Rule::`. RuleIR temporarily records the marker, but SpecEntry metadata omits authored `is_top`; Compiler then sets the effective label to explicit `top_rule` or parsed row zero. The descriptor preserves definition order but has no per-rule `is_top`. Generated-source v2 preserves only label/family plan rows and hardcodes the compiler-selected label in direct and traced execution. An unknown explicit selector compiles and fails only when the returned parser resolves its handler, at `resolve_top_rule_handler` without the target portable code. Direct `Validation::validate_dsl_syntax(..., strict_syntax => 1)` still computes defined minus authored-edge references and rejects an unreferenced marked Top, while `LinkedSpec::Get(strict_syntax => 1)` does not forward that option to the validator. The dependency-safe rollout is `.1.1` validation/resolver/metadata, `.1.2` loaded/generated/trace/diagnostic routes, then `.1.3` composed admission and reference-first shared CLI bytes."
evidence_update_2026_07_18_signoff: "Focused existing root CLI cases pass 2/2 in default and POSIX environments; generated-source proof passes 6/6. Root checker remains 8/3/3/5 at 1/6 with 24 mutations. Knowledge Map is 595/4,248; canonical CI passes cursor admission 288, reference primary 63x2, and Phase 0 1,031/1,031 in 632 seconds."
reverify: "perl -Iperl -MLinkedSpec -MLinkedSpec::BootstrapSpec -MLinkedSpec::Validation -e 'my $s=qq{Earlier:\\n /a/\\nMarked::\\n /b/\\n}; my ($ok,$p)=LinkedSpec::BootstrapSpec::run_bootstrap_parse(\\$s); print join(q{,}, map { $_->[0][0] } @$p), qq{\\n}; my %ctx; LinkedSpec::Get(\\$s, runtime_ctx_ref=>\\%ctx); print qq{$ctx{top_rule}\\n}' ; rg -n \"found_top_rule|ELABEL_INITIAL|selected_top_rule|top_rule_literal|strict_syntax\" perl/LinkedSpec/Validation.pm perl/LinkedSpec/RuleIR.pm perl/LinkedSpec/Compiler.pm"
---

# Perl root-selection seam map

The current path has four distinct identities that must not be collapsed:

1. `Validation::validate_spec_content` recognizes at least one rule but separately requires at least one authored
   `::`. This is the only block on the markerless fallback; comment-only or zero-rule input already fails first.
2. `BootstrapSpec::run_bootstrap_parse` returns source-ordered rows. A single-colon header begins with `ELABEL`; each
   double-colon header begins with `ELABEL_INITIAL`. Multiple markers are therefore already distinguishable without
   reparsing source text.
3. `RuleIR::_collect_rule_ir` maps `ELABEL_INITIAL` to temporary `top_rule`, and `SpecEntry::compile_spec_entry`
   writes that label into runtime context. It does not put authored marker identity into `rule_meta`. After all rows
   compile, `Compiler::run_get_pipeline` deliberately replaces runtime context with the requested `top_rule`, when
   present, or the first parsed row. That final replacement is why an earlier ordinary rule defeats a later marker.
4. `CompilerState` preserves definition order, but the outward descriptor has no per-rule `is_top`. Generated-source
   v2 retains ordered label/family rows only; its `Execute` and `ExecuteWithTrace` roles embed one selected label and
   cannot recompute marker precedence or accept an entry selector in invocation options.

`get_parser` is not a separate selector implementation: `ParserFactory` forwards its normalized option hash through
`Runtime::run_get` to the compiler, then returns the same parser route. The primary command similarly passes
`--top-rule` at compile time. Its medium request trace correctly records the requested label or `<default>` before
compilation; runtime context and handler trace currently use the compiler's effective label.

Unknown explicit selection is late today. Compilation and descriptor return can succeed with a missing requested
label. Only parser invocation discovers that no descriptor row exists, records `runtime_parser` /
`resolve_top_rule_handler`, and dies without `entry_rule_not_found` or `select_entry_rule`. The primary command still
normalizes that die to exit 1 and `linkedspec: parser invocation failed`, which the target preserves while improving
the structured inner diagnostic and guaranteeing no user handler runs.

Strict-unused remains a direct validator contract. `Validation::validate_dsl_syntax(..., strict_syntax => 1)` uses
`defined_rules - used_rules`, where used rules come only from authored edges; a marked but unreferenced `Top` is
therefore unused. The compiler calls the same validator with only `on_failure`, so `LinkedSpec::Get(strict_syntax =>
1)` currently ignores that option. Root-selection work must preserve the direct validator semantics and must not
silently turn the unsupported compiler option into a new API.

The safe implementation order is correspondingly fixed. `.1.1` removes only the marker-required envelope gate,
adds one post-parse resolver, validates explicit labels before user execution, and projects immutable authored
`is_top` plus ordered identity. `.1.2` makes `Get`, `get_parser`, returned parsers, independently loaded emitted
source, direct/traced generated roles, runtime context, and structured diagnostics consume that resolver. `.1.3`
adds the topology-checked Perl admission, advances only the Perl rollout row, and migrates shared primary cases to
the reference target first. As in the cursor rollout, later backend leaves are allowed a documented staged mismatch
until they consume the same shared bytes; canonical reference gates remain green at every commit.

Related: [[root-rule-selection-precedence]], [[perl-rule-local-cursor-rollout-boundaries]], and
[[FUTURE-PARITY-BACKLOG]].
