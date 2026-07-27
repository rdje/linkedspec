---
id: perl-root-rule-selection-routes
title: "Perl loaded and generated roles resolve entry rules from ordered authored identity at execution"
answers:
  - "how does Perl generated source choose its entry rule"
  - "can generated Execute accept top_rule"
  - "can generated ExecuteWithTrace accept top_rule"
  - "can generated Get accept top_rule"
  - "does generated invocation top_rule override emission top_rule"
  - "where are generated Rule:: marker bits stored"
  - "does generated source widen the label family plan for is_top"
  - "what generated metadata describes entry rules"
  - "what error does an unknown generated top_rule return"
  - "what trace event records generated entry selection"
  - "which rule labels generated execution errors"
date: 2026-07-18
status: current admitted Perl library/generated/primary routes
tags: [perl, root-rule, top-rule, generated-source, loaded-spec, trace, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.1.2 makes `Compiler::_generated_source_entry_rule_rows` embed ordered `{label,is_top}` authored identity separately from the unchanged `{label,family}` generated plan. Generated `Execute`, `ExecuteWithTrace`, and `Get` call `LinkedSpec::EntryRuleSelection::select_entry_rule` for every execution. Invocation-local `top_rule` overrides an emission-time configured selector; omission uses first marker then first rule. Metadata publishes `entry_rule_contract` and `entry_rules` without rewriting `is_top`. Unknown selection dies as `generated_source_error` with `entry_rule_not_found` at `select_entry_rule` before handler entry. `generated_entry_selection` records effective label/family/basis, and subsequent trace plus execution errors use the effective label. `get_parser` and `SpecLoader::load_and_compile_spec` preserve the same resolver and runtime-context attribution. `.9.1.1.2.1.3` topology-checks the core/routes consumers and canonical registration, adds first-marker and markerless-default shared primary cases, and completes the Perl rollout row."
reverify: "PERL5LIB= prove -Iperl t/root_rule_selection_perl_routes.t t/generated_source_contract.t && bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py"
---

Generated Perl source preserves authored entry identity as a dedicated ordered metadata projection, not as part of
the family execution plan. This lets independently loaded artifacts recompute the default and accept an execution-
local selector while keeping source identity immutable. All generated execution roles and loaded library routes
therefore consume the same explicit > first marker > first rule contract as native execution.

The shared primary adapter consumes this same resolution path. Perl admission is complete at 65/65 reference
cases in both option environments; later backend and final public-admission leaves remain staged.

Related: [[perl-root-rule-selection-core]], [[perl-root-rule-selection-preflight]],
[[perl-root-rule-selection-admission]], and [[root-rule-selection-precedence]].
