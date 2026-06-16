# Knowledge Map

> **AUTO-GENERATED — DO NOT EDIT.** Regenerate with `knowledge-map/scripts/gen_knowledge_map.sh`.
> Source of truth = YAML front-matter in: `docs/knowledge docs/decisions`. Edit the fact files, never this map.
> A fact is any `.md` whose front-matter has a non-empty `answers:` list.
> **27** facts · **131** question keys.

## Questions → fact

- "are PPlugin and PluginBridge part of the target architecture" -> [pplugin-pluginbridge-transition-machinery](docs/knowledge/pplugin-pluginbridge-transition-machinery.md) · 2026-06-12 · reverify: `grep -n 'transition.removal.machinery\|plugin-hosting framework' ARCHITECTURE_STATE.md`
- "are return_a return_m return_ma return_imatch deprecated" -> [medium-term-alias-retirement-deferred](docs/knowledge/medium-term-alias-retirement-deferred.md) · 2026-06-12 · reverify: `grep -c 'return_a(' t/phase0_regression.t`
- "are there compatibility-surface rules left" -> [method-like-dsl-migration-status](docs/knowledge/method-like-dsl-migration-status.md) · 2026-06-12 · reverify: `grep -c 'compatibility_surface.*0' docs/tasks/METHOD-LIKE-DSL-MIGRATION.md`
- "can a spec introduce a compatibility-surface rule" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "does bare rule: with => child mean ordered sequence" -> [blind-call-rule-label-contract](docs/knowledge/blind-call-rule-label-contract.md) · 2026-06-12 · reverify: `grep -n 'blind.call.*mode.driven' ROADMAP_V2.md`
- "does perl/LinkedSpec/ActionRewriter.pm still exist" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "does spec.spec run alongside bootstrap" -> [bootstrapspec-vs-spec-spec-dual-path](docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md) · 2026-06-13 · reverify: `grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm`
- "does the Perl version go away" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "dual-path parse" -> [bootstrapspec-vs-spec-spec-dual-path](docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md) · 2026-06-13 · reverify: `grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm`
- "how are handler variants built in SpecEntry" -> [specentry-perl-coupling-inventory](docs/knowledge/specentry-perl-coupling-inventory.md) · 2026-06-12 · reverify: `|`
- "how are scanner rules organized in linkedspec" -> [scanner-rule-family-architecture](docs/knowledge/scanner-rule-family-architecture.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/Scanner/*.pm`
- "how do ActionIR owners resolve their dependencies" -> [ownerdispatch-shared-seam](docs/knowledge/ownerdispatch-shared-seam.md) · 2026-06-12 · reverify: `grep -l 'OwnerDispatch' perl/LinkedSpec/*.pm perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "how do I add a new backend emitter" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "how do I configure trace output" -> [trace-verbosity-and-formatting](docs/knowledge/trace-verbosity-and-formatting.md) · 2026-06-12 · reverify: `grep -n 'DUMP_NONE\|DUMP_DEBUG\|configure_trace' perl/LinkedSpec.pm`
- "how do I run CI / the regression gate" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "how do backends stay in lockstep" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "how do variant builders work" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "how does -> edge dispatch work in Perl" -> [rust-edge-semantics-bug](docs/knowledge/rust-edge-semantics-bug.md) · 2026-06-15 · reverify: `cd rust && cargo test; grep -n dependency_regex_map perl/LinkedSpec/Compiler.pm`
- "how does ActionIR lowering work" -> [actionir-lowering-stack](docs/knowledge/actionir-lowering-stack.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "how does EmitContext dispatch into ActionIR owners" -> [emitcontext-owner-registry](docs/knowledge/emitcontext-owner-registry.md) · 2026-06-12 · reverify: `grep -c '_actionir_owner_package\|owner_pkgs' perl/LinkedSpec/RuleIR/EmitContext.pm`
- "how does HandlerIR enable multi-backend portability" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "how does HandlerIR help portability" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "how does LinkedSpec.pm dispatch into owner modules" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "how does RuntimeContext anchor chdir-safety for runtime state" -> [runtimecontext-boundary](docs/knowledge/runtimecontext-boundary.md) · 2026-06-12 · reverify: `grep -l 'RuntimeContext' perl/LinkedSpec/*.pm perl/LinkedSpec/RuleIR/*.pm | wc -l`
- "how does SpecEntry depend on LinkedRE::or" -> [specentry-perl-coupling-inventory](docs/knowledge/specentry-perl-coupling-inventory.md) · 2026-06-12 · reverify: `|`
- "how does SpecEntry generate runtime handlers" -> [specentry-backend-portability-ceiling](docs/knowledge/specentry-backend-portability-ceiling.md) · 2026-06-12 · reverify: `grep -n 'backend-portability ceiling\|eval' ARCHITECTURE_STATE.md | head -3`
- "how does _actionir_owner_package work" -> [emitcontext-owner-registry](docs/knowledge/emitcontext-owner-registry.md) · 2026-06-12 · reverify: `grep -c '_actionir_owner_package\|owner_pkgs' perl/LinkedSpec/RuleIR/EmitContext.pm`
- "how does a parent read a child rule's return value in Rust" -> [rust-retv-propagation](docs/knowledge/rust-retv-propagation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- "how does blind-call work in linkedspec" -> [blind-call-rule-label-contract](docs/knowledge/blind-call-rule-label-contract.md) · 2026-06-12 · reverify: `grep -n 'blind.call.*mode.driven' ROADMAP_V2.md`
- "how does call(child) resolve a rule name in Rust" -> [rust-retv-propagation](docs/knowledge/rust-retv-propagation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- "how does descriptor assembly work" -> [compilerstate-internal-model](docs/knowledge/compilerstate-internal-model.md) · 2026-06-12 · reverify: `test -f perl/LinkedSpec/CompilerState.pm && grep -l CompilerState perl/LinkedSpec/Compiler.pm perl/LinkedSpec/Validation.pm`
- "how does helper code get from .spec to emitted Perl" -> [actionir-lowering-stack](docs/knowledge/actionir-lowering-stack.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "how does lazy owner loading work in linkedspec" -> [ownerdispatch-shared-seam](docs/knowledge/ownerdispatch-shared-seam.md) · 2026-06-12 · reverify: `grep -l 'OwnerDispatch' perl/LinkedSpec/*.pm perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "how does return(expr) work in the Rust runtime vs the accumulator" -> [rust-retv-propagation](docs/knowledge/rust-retv-propagation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- "how does spec.spec relate to the bootstrap grammar" -> [bootstrapspec-vs-spec-spec-dual-path](docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md) · 2026-06-13 · reverify: `grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm`
- "how does the JSON backend prove pluggability" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "how does the Rust engine propagate retv" -> [rust-retv-propagation](docs/knowledge/rust-retv-propagation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- "how does top_rule flow through the compile pipeline" -> [runtimecontext-boundary](docs/knowledge/runtimecontext-boundary.md) · 2026-06-12 · reverify: `grep -l 'RuntimeContext' perl/LinkedSpec/*.pm perl/LinkedSpec/RuleIR/*.pm | wc -l`
- "how does trace work in linkedspec" -> [trace-verbosity-and-formatting](docs/knowledge/trace-verbosity-and-formatting.md) · 2026-06-12 · reverify: `grep -n 'DUMP_NONE\|DUMP_DEBUG\|configure_trace' perl/LinkedSpec.pm`
- "how is $@ preserved across owner dispatch" -> [ownerdispatch-shared-seam](docs/knowledge/ownerdispatch-shared-seam.md) · 2026-06-12 · reverify: `grep -l 'OwnerDispatch' perl/LinkedSpec/*.pm perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "how is the regression test organized" -> [phase0-regression-structure](docs/knowledge/phase0-regression-structure.md) · 2026-06-12 · reverify: `wc -l t/phase0_regression.t`
- "how long does phase0 take to run" -> [phase0-regression-structure](docs/knowledge/phase0-regression-structure.md) · 2026-06-12 · reverify: `wc -l t/phase0_regression.t`
- "how many handler variant builders are in SpecEntry" -> [specentry-perl-coupling-inventory](docs/knowledge/specentry-perl-coupling-inventory.md) · 2026-06-12 · reverify: `|`
- "how many specs use convention-based accumulators" -> [accumulator-convention-healthy](docs/knowledge/accumulator-convention-healthy.md) · 2026-06-12 · reverify: `grep -c 'push(Child)' specs/*.spec; grep -c 'push_value' specs/*.spec`
- "how should .spec language changes land" -> [spec-spec-self-hosted-grammar](docs/knowledge/spec-spec-self-hosted-grammar.md) · 2026-06-05 · reverify: `ls specs/spec.spec`
- "how should the Rust compiler build regex alternations" -> [rust-edge-semantics-bug](docs/knowledge/rust-edge-semantics-bug.md) · 2026-06-15 · reverify: `cd rust && cargo test; grep -n dependency_regex_map perl/LinkedSpec/Compiler.pm`
- "is ActionRewriter a live module in linkedspec" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "is GitHub Actions CI running for linkedspec" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "is LinkedSpec still a plugin-hosting framework" -> [pplugin-pluginbridge-transition-machinery](docs/knowledge/pplugin-pluginbridge-transition-machinery.md) · 2026-06-12 · reverify: `grep -n 'transition.removal.machinery\|plugin-hosting framework' ARCHITECTURE_STATE.md`
- "is LinkedSpec.pm the implementation center" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "is it safe to use LX on a repeated (AND+) rule" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "is push(Child) without an explicit target deprecated" -> [accumulator-convention-healthy](docs/knowledge/accumulator-convention-healthy.md) · 2026-06-12 · reverify: `grep -c 'push(Child)' specs/*.spec; grep -c 'push_value' specs/*.spec`
- "is spec.spec the active frontend" -> [bootstrapspec-vs-spec-spec-dual-path](docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md) · 2026-06-13 · reverify: `grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm`
- "is there a self-hosted .spec grammar" -> [spec-spec-self-hosted-grammar](docs/knowledge/spec-spec-self-hosted-grammar.md) · 2026-06-05 · reverify: `ls specs/spec.spec`
- "parser infinite loop with Late Exit lifecycle marker" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "should I use push_value or push(Child)" -> [accumulator-convention-healthy](docs/knowledge/accumulator-convention-healthy.md) · 2026-06-12 · reverify: `grep -c 'push(Child)' specs/*.spec; grep -c 'push_value' specs/*.spec`
- "should new code use plugin dispatch" -> [pplugin-pluginbridge-transition-machinery](docs/knowledge/pplugin-pluginbridge-transition-machinery.md) · 2026-06-12 · reverify: `grep -n 'transition.removal.machinery\|plugin-hosting framework' ARCHITECTURE_STATE.md`
- "what Perl coupling points exist in SpecEntry.pm" -> [specentry-perl-coupling-inventory](docs/knowledge/specentry-perl-coupling-inventory.md) · 2026-06-12 · reverify: `|`
- "what Perl variables are assumed by generated handlers" -> [specentry-perl-coupling-inventory](docs/knowledge/specentry-perl-coupling-inventory.md) · 2026-06-12 · reverify: `|`
- "what are the ActionIR sub-owners" -> [actionir-lowering-stack](docs/knowledge/actionir-lowering-stack.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "what are the HandlerIR node kinds" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "what are the fields of a HandlerIR node" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "what are the verbosity levels" -> [trace-verbosity-and-formatting](docs/knowledge/trace-verbosity-and-formatting.md) · 2026-06-12 · reverify: `grep -n 'DUMP_NONE\|DUMP_DEBUG\|configure_trace' perl/LinkedSpec.pm`
- "what arithmetic function forms were settled" -> [spec-format-brainstorm-rounds-1-3](docs/knowledge/spec-format-brainstorm-rounds-1-3.md) · 2026-06-15 · reverify: `cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md`
- "what backends will LinkedSpec support" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "what control flow syntax was agreed" -> [spec-format-brainstorm-rounds-1-3](docs/knowledge/spec-format-brainstorm-rounds-1-3.md) · 2026-06-15 · reverify: `cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md`
- "what did the accumulator audit find" -> [accumulator-convention-healthy](docs/knowledge/accumulator-convention-healthy.md) · 2026-06-12 · reverify: `grep -c 'push(Child)' specs/*.spec; grep -c 'push_value' specs/*.spec`
- "what does SpecEntry eval" -> [specentry-perl-coupling-inventory](docs/knowledge/specentry-perl-coupling-inventory.md) · 2026-06-12 · reverify: `|`
- "what does execute_rule return in the Rust engine" -> [rust-retv-propagation](docs/knowledge/rust-retv-propagation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- "what does green CI mean here" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "what does phase0_regression.t cover" -> [phase0-regression-structure](docs/knowledge/phase0-regression-structure.md) · 2026-06-12 · reverify: `wc -l t/phase0_regression.t`
- "what does the phase0 regression gate enforce about specs" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "what format changes were brainstormed for .spec files" -> [spec-format-brainstorm-rounds-1-3](docs/knowledge/spec-format-brainstorm-rounds-1-3.md) · 2026-06-15 · reverify: `cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md`
- "what happened with the medium-term alias retirement" -> [medium-term-alias-retirement-deferred](docs/knowledge/medium-term-alias-retirement-deferred.md) · 2026-06-12 · reverify: `grep -c 'return_a(' t/phase0_regression.t`
- "what helpers are available in the DSL" -> [method-like-dsl-migration-status](docs/knowledge/method-like-dsl-migration-status.md) · 2026-06-12 · reverify: `grep -c 'compatibility_surface.*0' docs/tasks/METHOD-LIKE-DSL-MIGRATION.md`
- "what is BootstrapSpec::Core vs spec.spec" -> [bootstrapspec-vs-spec-spec-dual-path](docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md) · 2026-06-13 · reverify: `grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm`
- "what is CompilerState and why was it extracted" -> [compilerstate-internal-model](docs/knowledge/compilerstate-internal-model.md) · 2026-06-12 · reverify: `test -f perl/LinkedSpec/CompilerState.pm && grep -l CompilerState perl/LinkedSpec/Compiler.pm perl/LinkedSpec/Validation.pm`
- "what is HandlerIR" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "what is OwnerDispatch and why do all owners use it" -> [ownerdispatch-shared-seam](docs/knowledge/ownerdispatch-shared-seam.md) · 2026-06-12 · reverify: `grep -l 'OwnerDispatch' perl/LinkedSpec/*.pm perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "what is RuntimeContext and why is it important" -> [runtimecontext-boundary](docs/knowledge/runtimecontext-boundary.md) · 2026-06-12 · reverify: `grep -l 'RuntimeContext' perl/LinkedSpec/*.pm perl/LinkedSpec/RuleIR/*.pm | wc -l`
- "what is deferred in the DSL migration" -> [method-like-dsl-migration-status](docs/knowledge/method-like-dsl-migration-status.md) · 2026-06-12 · reverify: `grep -c 'compatibility_surface.*0' docs/tasks/METHOD-LIKE-DSL-MIGRATION.md`
- "what is dependency_regex_map" -> [rust-edge-semantics-bug](docs/knowledge/rust-edge-semantics-bug.md) · 2026-06-15 · reverify: `cd rust && cargo test; grep -n dependency_regex_map perl/LinkedSpec/Compiler.pm`
- "what is language_agnostic_ready_ratio and what value is required" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "what is specs/spec.spec" -> [spec-spec-self-hosted-grammar](docs/knowledge/spec-spec-self-hosted-grammar.md) · 2026-06-05 · reverify: `ls specs/spec.spec`
- "what is the AND++LX hang" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "what is the ActionIR pipeline" -> [actionir-lowering-stack](docs/knowledge/actionir-lowering-stack.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "what is the EmitContext owner registry" -> [emitcontext-owner-registry](docs/knowledge/emitcontext-owner-registry.md) · 2026-06-12 · reverify: `grep -c '_actionir_owner_package\|owner_pkgs' perl/LinkedSpec/RuleIR/EmitContext.pm`
- "what is the accumulator convention in linkedspec" -> [accumulator-convention-healthy](docs/knowledge/accumulator-convention-healthy.md) · 2026-06-12 · reverify: `grep -c 'push(Child)' specs/*.spec; grep -c 'push_value' specs/*.spec`
- "what is the backend roadmap for LinkedSpec" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "what is the biggest portability blocker" -> [specentry-backend-portability-ceiling](docs/knowledge/specentry-backend-portability-ceiling.md) · 2026-06-12 · reverify: `grep -n 'backend-portability ceiling\|eval' ARCHITECTURE_STATE.md | head -3`
- "what is the difference between => child and -> child" -> [blind-call-rule-label-contract](docs/knowledge/blind-call-rule-label-contract.md) · 2026-06-12 · reverify: `grep -n 'blind.call.*mode.driven' ROADMAP_V2.md`
- "what is the difference between PrimitiveBasicRules and LegacyRules" -> [scanner-rule-family-architecture](docs/knowledge/scanner-rule-family-architecture.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/Scanner/*.pm`
- "what is the future direction for declare assign push set_key" -> [spec-format-brainstorm-rounds-1-3](docs/knowledge/spec-format-brainstorm-rounds-1-3.md) · 2026-06-15 · reverify: `cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md`
- "what is the language-agnostic architecture vision" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "what is the method-like DSL migration status" -> [method-like-dsl-migration-status](docs/knowledge/method-like-dsl-migration-status.md) · 2026-06-12 · reverify: `grep -c 'compatibility_surface.*0' docs/tasks/METHOD-LIKE-DSL-MIGRATION.md`
- "what is the plugin modernization status" -> [pplugin-pluginbridge-transition-machinery](docs/knowledge/pplugin-pluginbridge-transition-machinery.md) · 2026-06-12 · reverify: `grep -n 'transition.removal.machinery\|plugin-hosting framework' ARCHITECTURE_STATE.md`
- "what is the practical compile/runtime spine" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "what is the role of .spec files across backends" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "what is the scanner rule family split" -> [scanner-rule-family-architecture](docs/knowledge/scanner-rule-family-architecture.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/Scanner/*.pm`
- "what is the status of -> edge semantics" -> [spec-format-brainstorm-rounds-1-3](docs/knowledge/spec-format-brainstorm-rounds-1-3.md) · 2026-06-15 · reverify: `cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md`
- "what is the test migration problem" -> [medium-term-alias-retirement-deferred](docs/knowledge/medium-term-alias-retirement-deferred.md) · 2026-06-12 · reverify: `grep -c 'return_a(' t/phase0_regression.t`
- "what is wrong with the Rust -> edge implementation" -> [rust-edge-semantics-bug](docs/knowledge/rust-edge-semantics-bug.md) · 2026-06-15 · reverify: `cd rust && cargo test; grep -n dependency_regex_map perl/LinkedSpec/Compiler.pm`
- "what must every shipped .spec satisfy" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "what owns compiled_rule_order and redefined_rule_labels" -> [compilerstate-internal-model](docs/knowledge/compilerstate-internal-model.md) · 2026-06-12 · reverify: `test -f perl/LinkedSpec/CompilerState.pm && grep -l CompilerState perl/LinkedSpec/Compiler.pm perl/LinkedSpec/Validation.pm`
- "what owns parser-source chunk capture" -> [runtimecontext-boundary](docs/knowledge/runtimecontext-boundary.md) · 2026-06-12 · reverify: `grep -l 'RuntimeContext' perl/LinkedSpec/*.pm perl/LinkedSpec/RuleIR/*.pm | wc -l`
- "what rule label should I use for blind-call" -> [blind-call-rule-label-contract](docs/knowledge/blind-call-rule-label-contract.md) · 2026-06-12 · reverify: `grep -n 'blind.call.*mode.driven' ROADMAP_V2.md`
- "what was decided about function composability" -> [spec-format-brainstorm-rounds-1-3](docs/knowledge/spec-format-brainstorm-rounds-1-3.md) · 2026-06-15 · reverify: `cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md`
- "what would it take to port LinkedSpec to another language" -> [specentry-backend-portability-ceiling](docs/knowledge/specentry-backend-portability-ceiling.md) · 2026-06-12 · reverify: `grep -n 'backend-portability ceiling\|eval' ARCHITECTURE_STATE.md | head -3`
- "where are ActionIR owner packages registered" -> [emitcontext-owner-registry](docs/knowledge/emitcontext-owner-registry.md) · 2026-06-12 · reverify: `grep -c '_actionir_owner_package\|owner_pkgs' perl/LinkedSpec/RuleIR/EmitContext.pm`
- "where did LinkedSpec::ActionRewriter go" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "where did call_spec_handler_subst / rewrite_action_code_for_compat move" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "where do new scanner rules go" -> [scanner-rule-family-architecture](docs/knowledge/scanner-rule-family-architecture.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/Scanner/*.pm`
- "where does build_dep_map live" -> [ownerdispatch-shared-seam](docs/knowledge/ownerdispatch-shared-seam.md) · 2026-06-12 · reverify: `grep -l 'OwnerDispatch' perl/LinkedSpec/*.pm perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "where does last_error live" -> [runtimecontext-boundary](docs/knowledge/runtimecontext-boundary.md) · 2026-06-12 · reverify: `grep -l 'RuntimeContext' perl/LinkedSpec/*.pm perl/LinkedSpec/RuleIR/*.pm | wc -l`
- "where does log_output go" -> [trace-verbosity-and-formatting](docs/knowledge/trace-verbosity-and-formatting.md) · 2026-06-12 · reverify: `grep -n 'DUMP_NONE\|DUMP_DEBUG\|configure_trace' perl/LinkedSpec.pm`
- "where does migration-summary shaping live" -> [compilerstate-internal-model](docs/knowledge/compilerstate-internal-model.md) · 2026-06-12 · reverify: `test -f perl/LinkedSpec/CompilerState.pm && grep -l CompilerState perl/LinkedSpec/Compiler.pm perl/LinkedSpec/Validation.pm`
- "where does the memory-arch and knowledge-map check run" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "where does the real implementation live in linkedspec" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "where is compiled-spec state defined" -> [compilerstate-internal-model](docs/knowledge/compilerstate-internal-model.md) · 2026-06-12 · reverify: `test -f perl/LinkedSpec/CompilerState.pm && grep -l CompilerState perl/LinkedSpec/Compiler.pm perl/LinkedSpec/Validation.pm`
- "where is the LinkedSpec language defined in LinkedSpec itself" -> [spec-spec-self-hosted-grammar](docs/knowledge/spec-spec-self-hosted-grammar.md) · 2026-06-05 · reverify: `ls specs/spec.spec`
- "where is the helper-rewrite compatibility entrypoint now" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "which grammar actually parses .spec files" -> [bootstrapspec-vs-spec-spec-dual-path](docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md) · 2026-06-13 · reverify: `grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm`
- "why can't LinkedSpec target non-Perl backends" -> [specentry-backend-portability-ceiling](docs/knowledge/specentry-backend-portability-ceiling.md) · 2026-06-12 · reverify: `grep -n 'backend-portability ceiling\|eval' ARCHITECTURE_STATE.md | head -3`
- "why did phase0 fail on my new spec" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "why did scalar(retv) resolve to undef in the Rust runtime" -> [rust-retv-propagation](docs/knowledge/rust-retv-propagation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- "why did spec.spec hang while parsing" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "why do return_a return_m return_ma return_imatch still exist" -> [medium-term-alias-retirement-deferred](docs/knowledge/medium-term-alias-retirement-deferred.md) · 2026-06-12 · reverify: `grep -c 'return_a(' t/phase0_regression.t`
- "why does the generated parser hang on an AND+ rule with LX" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "why is .github/workflows/ci.yml guarded off (workflow_dispatch / if false)" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "why is LinkedSpec.pm so small" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "why is the test file so large" -> [phase0-regression-structure](docs/knowledge/phase0-regression-structure.md) · 2026-06-12 · reverify: `wc -l t/phase0_regression.t`

## Facts (by id)

### accumulator-convention-healthy
_The implicit-target push(Child) accumulator convention is healthy and idiomatic; 95.5% of accumulator ops already use explicit targets with push_value preferred_

- **answers:** is push(Child) without an explicit target deprecated | what is the accumulator convention in linkedspec | should I use push_value or push(Child) | what did the accumulator audit find | how many specs use convention-based accumulators
- **date:** 2026-06-12 · **status:** current
- **evidence:** `docs/tasks/ACCUMULATOR-CONVENTION-AUDIT.md (3 leaves, done 2026-06-11): 88 total accumulator ops across 19 specs; only 4 convention-based (4.5%) across 3 specs`
- **reverify:** `grep -c 'push(Child)' specs/*.spec; grep -c 'push_value' specs/*.spec`
- **source:** [`docs/knowledge/accumulator-convention-healthy.md`](docs/knowledge/accumulator-convention-healthy.md)

### actionir-lowering-stack
_The ActionIR lowering stack has 12+ sub-owners (Scanner, CanonicalEvents, Diagnostics, StatementSplit, RewritePipeline, MethodLowering, FlowExpr, ValueExpr, ArrayPipeline, ControlFlow, DeclareMethod, Contracts) replacing what was once a giant mixed-semantics file_

- **answers:** how does ActionIR lowering work | what are the ActionIR sub-owners | how does helper code get from .spec to emitted Perl | what is the ActionIR pipeline
- **date:** 2026-06-12 · **status:** current
- **evidence:** `ARCHITECTURE_STATE.md §ActionIR Reading: 12+ sub-owners documented; EmitContext owner registry maps all 13 keys`
- **reverify:** `ls perl/LinkedSpec/ActionIR/*.pm | wc -l`
- **source:** [`docs/knowledge/actionir-lowering-stack.md`](docs/knowledge/actionir-lowering-stack.md)

### actionrewriter-removed-phase1
_ActionRewriter.pm was deleted in Phase 1; the helper-rewrite compat entrypoint is now in RuleIR::EmitContext_

- **answers:** does perl/LinkedSpec/ActionRewriter.pm still exist | where did LinkedSpec::ActionRewriter go | where is the helper-rewrite compatibility entrypoint now | where did call_spec_handler_subst / rewrite_action_code_for_compat move | is ActionRewriter a live module in linkedspec
- **date:** 2026-06-05 · **status:** current
- **evidence:** `commit 4f8e0b6 (PHASE1-PARSER-CORE-ISOLATION.2) deleted the 118-line forwarding shim; zero references remain under perl/`
- **reverify:** `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- **source:** [`docs/knowledge/actionrewriter-removed-phase1.md`](docs/knowledge/actionrewriter-removed-phase1.md)

### andplusplus-lx-parser-hang
_GOTCHA — an LX lifecycle marker on an AND+ rule hangs the generated parser (loop re-entry)_

- **answers:** why does the generated parser hang on an AND+ rule with LX | why did spec.spec hang while parsing | what is the AND++LX hang | is it safe to use LX on a repeated (AND+) rule | parser infinite loop with Late Exit lifecycle marker
- **date:** 2026-06-05 · **status:** current
- **evidence:** `docs/tasks/PHASE7-SELF-HOSTED-SPEC.md (PHASE7-SELF-HOSTED-SPEC.4): spec_file::AND+ with LX hung; fixed by replacing LX with E`
- **reverify:** `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- **source:** [`docs/knowledge/andplusplus-lx-parser-hang.md`](docs/knowledge/andplusplus-lx-parser-hang.md)

### blind-call-rule-label-contract
_Blind-call (=> child) is driven by the rule label, not the edge kind alone; :AND is the preferred sequential spelling_

- **answers:** how does blind-call work in linkedspec | what is the difference between => child and -> child | does bare rule: with => child mean ordered sequence | what rule label should I use for blind-call
- **date:** 2026-06-12 · **status:** current
- **evidence:** `ROADMAP_V2.md Deferred Future Note: 'blind-call should remain mode-driven by the rule label'; specs/spec.spec uses explicit rule labels for blind-call`
- **reverify:** `grep -n 'blind.call.*mode.driven' ROADMAP_V2.md`
- **source:** [`docs/knowledge/blind-call-rule-label-contract.md`](docs/knowledge/blind-call-rule-label-contract.md)

### bootstrapspec-vs-spec-spec-dual-path
_BootstrapSpec::Core remains the primary parse path; spec.spec is wired as a dual-path side-channel parse via run_bootstrap_parse()_

- **answers:** which grammar actually parses .spec files | is spec.spec the active frontend | what is BootstrapSpec::Core vs spec.spec | how does spec.spec relate to the bootstrap grammar | does spec.spec run alongside bootstrap | dual-path parse
- **date:** 2026-06-13 · **status:** current
- **evidence:** `MEDIUM-IMPACT.3.5: BootstrapSpec.pm _build_spec_spec_parser() lazy-builds + caches spec.spec parser; run_bootstrap_parse() runs spec.spec alongside bootstrap (diagnostic side channel). Bootstrap always primary.`
- **reverify:** `grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm`
- **source:** [`docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md`](docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md)

### compilerstate-internal-model
_CompilerState owns the internal compiled-spec, dependency-regex, and descriptor state records; Compiler.pm and Validation.pm no longer carry raw state logic_

- **answers:** where is compiled-spec state defined | what is CompilerState and why was it extracted | how does descriptor assembly work | where does migration-summary shaping live | what owns compiled_rule_order and redefined_rule_labels
- **date:** 2026-06-12 · **status:** current
- **evidence:** `perl/LinkedSpec/CompilerState.pm extracted from Compiler.pm; ARCHITECTURE_STATE.md §What the Main Owners Do documents the extraction`
- **reverify:** `test -f perl/LinkedSpec/CompilerState.pm && grep -l CompilerState perl/LinkedSpec/Compiler.pm perl/LinkedSpec/Validation.pm`
- **source:** [`docs/knowledge/compilerstate-internal-model.md`](docs/knowledge/compilerstate-internal-model.md)

### emitcontext-owner-registry
_RuleIR::EmitContext centralizes the ActionIR owner-package registry and default-dependency lookup for the bridge from RuleIR into ActionIR scanning and lowering_

- **answers:** how does EmitContext dispatch into ActionIR owners | where are ActionIR owner packages registered | what is the EmitContext owner registry | how does _actionir_owner_package work
- **date:** 2026-06-12 · **status:** current
- **evidence:** `perl/LinkedSpec/RuleIR/EmitContext.pm: _actionir_owner_package maps 13 owner keys to package names; _call_actionir_owner_with_deps appends default dependency bundles automatically`
- **reverify:** `grep -c '_actionir_owner_package\|owner_pkgs' perl/LinkedSpec/RuleIR/EmitContext.pm`
- **source:** [`docs/knowledge/emitcontext-owner-registry.md`](docs/knowledge/emitcontext-owner-registry.md)

### handler-ir-design
_HandlerIR — structured handler representation separating structural decisions from code generation_

- **answers:** what is HandlerIR | how does HandlerIR enable multi-backend portability | what are the HandlerIR node kinds | how do I add a new backend emitter | what are the fields of a HandlerIR node | how do variant builders work | how does the JSON backend prove pluggability
- **date:** 2026-06-14 · **status:** accepted
- **evidence:** `perl/LinkedSpec/HandlerVariantEmitter.pm — 10 variant builders return HandlerIR hashrefs; _emit_handler dispatches via %BACKEND_EMITTERS; _emit_handler_json proves pluggability`
- **reverify:** `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- **source:** [`docs/knowledge/handler-ir-design.md`](docs/knowledge/handler-ir-design.md)

### hosted-ci-disabled-run-local-gate
_Hosted GitHub Actions CI is disabled; run the local gate tools/run_ci_local.sh_

- **answers:** is GitHub Actions CI running for linkedspec | how do I run CI / the regression gate | why is .github/workflows/ci.yml guarded off (workflow_dispatch / if false) | what does green CI mean here | where does the memory-arch and knowledge-map check run
- **date:** 2026-06-05 · **status:** current
- **evidence:** `.github/workflows/ci.yml uses workflow_dispatch + job if: false; docs/decisions/0004-hosted-ci-disabled-local-gate.md`
- **reverify:** `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- **source:** [`docs/knowledge/hosted-ci-disabled-run-local-gate.md`](docs/knowledge/hosted-ci-disabled-run-local-gate.md)

### language-agnostic-backend-vision
_LinkedSpec language-agnostic backend vision — Perl stays primary; Rust/Julia/Dart backends consume same .spec files in lockstep_

- **answers:** what backends will LinkedSpec support | what is the language-agnostic architecture vision | how do backends stay in lockstep | does the Perl version go away | what is the role of .spec files across backends | how does HandlerIR help portability | what is the backend roadmap for LinkedSpec
- **date:** 2026-06-12 · **status:** accepted
- **evidence:** `User-specified vision during MEDIUM-IMPACT.1.3 HandlerIR work. Speculated backends: Rust, Julia, Dart. JS+Wasm reach via Rust or Dart. All backends consume identical .spec files.`
- **reverify:** `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- **source:** [`docs/knowledge/language-agnostic-backend-vision.md`](docs/knowledge/language-agnostic-backend-vision.md)

### linkedspec-pm-is-thin-facade
_LinkedSpec.pm is a thin lazy façade; the real compile spine is ParserFactory -> Runtime -> Compiler_

- **answers:** where does the real implementation live in linkedspec | is LinkedSpec.pm the implementation center | what is the practical compile/runtime spine | how does LinkedSpec.pm dispatch into owner modules | why is LinkedSpec.pm so small
- **date:** 2026-06-05 · **status:** current
- **evidence:** `perl/LinkedSpec.pm is ~258 lines; static imports are essentially File::Basename + LinkedSpec::OwnerDispatch`
- **reverify:** `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- **source:** [`docs/knowledge/linkedspec-pm-is-thin-facade.md`](docs/knowledge/linkedspec-pm-is-thin-facade.md)

### medium-term-alias-retirement-deferred
_Medium-term alias retirement (return_a, return_m, return_ma, return_imatch/return_im) is deferred; ~692 test references across complex Perl quoting contexts block automated migration_

- **answers:** why do return_a return_m return_ma return_imatch still exist | what happened with the medium-term alias retirement | are return_a return_m return_ma return_imatch deprecated | what is the test migration problem
- **date:** 2026-06-12 · **status:** current
- **evidence:** `COMPAT-ALIAS-RETIREMENT.2/.3 deferred 2026-06-12; short-term aliases (tail/drop_last/flatten/array_values) successfully retired in .1`
- **reverify:** `grep -c 'return_a(' t/phase0_regression.t`
- **source:** [`docs/knowledge/medium-term-alias-retirement-deferred.md`](docs/knowledge/medium-term-alias-retirement-deferred.md)

### method-like-dsl-migration-status
_The method-like DSL migration track is mostly done — all 19 shipped specs at zero compatibility-surface rules, 100+ helpers across 10 families, cross-nesting parity deferred, compat aliases partially retired_

- **answers:** what is the method-like DSL migration status | are there compatibility-surface rules left | what helpers are available in the DSL | what is deferred in the DSL migration
- **date:** 2026-06-12 · **status:** current
- **evidence:** `METHOD-LIKE-DSL-MIGRATION tree completed (5 leaves, 2026-05-17); COMPAT-ALIAS-RETIREMENT.1 done (4 short-term aliases retired); ROADMAP_V2.md Method-like track: mostly done`
- **reverify:** `grep -c 'compatibility_surface.*0' docs/tasks/METHOD-LIKE-DSL-MIGRATION.md`
- **source:** [`docs/knowledge/method-like-dsl-migration-status.md`](docs/knowledge/method-like-dsl-migration-status.md)

### ownerdispatch-shared-seam
_LinkedSpec::OwnerDispatch is the shared seam for lazy owner loading, callback resolution, and $@ preservation_

- **answers:** how does lazy owner loading work in linkedspec | what is OwnerDispatch and why do all owners use it | how is $@ preserved across owner dispatch | where does build_dep_map live | how do ActionIR owners resolve their dependencies
- **date:** 2026-06-12 · **status:** current
- **evidence:** `perl/LinkedSpec/OwnerDispatch.pm (220 lines); 12+ owner modules spend this seam directly; build_dep_map and build_dep_bundle centralize dependency assembly`
- **reverify:** `grep -l 'OwnerDispatch' perl/LinkedSpec/*.pm perl/LinkedSpec/ActionIR/*.pm | wc -l`
- **source:** [`docs/knowledge/ownerdispatch-shared-seam.md`](docs/knowledge/ownerdispatch-shared-seam.md)

### phase0-all-target-actionir-ready-invariant
_Every shipped .spec must compile ActionIR-ready (ratio == 1.0000, zero compatibility-surface rules)_

- **answers:** what must every shipped .spec satisfy | what does the phase0 regression gate enforce about specs | what is language_agnostic_ready_ratio and what value is required | can a spec introduce a compatibility-surface rule | why did phase0 fail on my new spec
- **date:** 2026-06-05 · **status:** current
- **evidence:** `docs/decisions/0002-all-target-actionir-ready-invariant.md; t/phase0_regression.t asserts language_agnostic_ready_ratio == 1.0000 with zero blocked / compatibility-surface rules`
- **reverify:** `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- **source:** [`docs/knowledge/phase0-all-target-actionir-ready-invariant.md`](docs/knowledge/phase0-all-target-actionir-ready-invariant.md)

### phase0-regression-structure
_phase0_regression.t is a 44,000+ line single-file regression gate covering 19 shipped specs, all ActionIR lowering paths, scanner families, lifecycle blocks, and plugin migration checks_

- **answers:** what does phase0_regression.t cover | how is the regression test organized | how long does phase0 take to run | why is the test file so large
- **date:** 2026-06-12 · **status:** current
- **evidence:** `t/phase0_regression.t is 44,000+ lines; 1004 subtests; runs in ~3 min; covers spec compilation, ActionIR lowering, scanner, lifecycle, plugin migration`
- **reverify:** `wc -l t/phase0_regression.t`
- **source:** [`docs/knowledge/phase0-regression-structure.md`](docs/knowledge/phase0-regression-structure.md)

### pplugin-pluginbridge-transition-machinery
_PPlugin and PluginBridge are transition/removal machinery, not the target architecture; dynamic plugin loading is legacy-removal territory_

- **answers:** are PPlugin and PluginBridge part of the target architecture | should new code use plugin dispatch | what is the plugin modernization status | is LinkedSpec still a plugin-hosting framework
- **date:** 2026-06-12 · **status:** current
- **evidence:** `ARCHITECTURE_STATE.md §Current Strategic Judgments: 'LinkedSpec is no longer best understood as a plugin-hosting framework'; PLUGIN-MODERNIZATION tree completed (5 leaves, 2026-05-17)`
- **reverify:** `grep -n 'transition.removal.machinery\|plugin-hosting framework' ARCHITECTURE_STATE.md`
- **source:** [`docs/knowledge/pplugin-pluginbridge-transition-machinery.md`](docs/knowledge/pplugin-pluginbridge-transition-machinery.md)

### runtimecontext-boundary
_RuntimeContext is one of the cleanest architectural boundaries; owns shared runtime state, structured error payloads, and handler attribution_

- **answers:** what is RuntimeContext and why is it important | where does last_error live | how does top_rule flow through the compile pipeline | what owns parser-source chunk capture | how does RuntimeContext anchor chdir-safety for runtime state
- **date:** 2026-06-12 · **status:** current
- **evidence:** `perl/LinkedSpec/RuntimeContext.pm; spent by Runtime, ParserFactory, Compiler, SpecEntry; ARCHITECTURE_STATE.md calls it 'one of the cleanest and highest-value seams in the project'`
- **reverify:** `grep -l 'RuntimeContext' perl/LinkedSpec/*.pm perl/LinkedSpec/RuleIR/*.pm | wc -l`
- **source:** [`docs/knowledge/runtimecontext-boundary.md`](docs/knowledge/runtimecontext-boundary.md)

### rust-edge-semantics-bug
_Rust -> edge dispatch is broken — associates edges with parent regexes instead of building dependency_regex_map from child rule regexes like Perl_

- **answers:** how does -> edge dispatch work in Perl | what is wrong with the Rust -> edge implementation | how should the Rust compiler build regex alternations | what is dependency_regex_map
- **date:** 2026-06-15 · **status:** confirmed
- **evidence:** `Full Perl pipeline analysis 2026-06-15: BootstrapSpec::Core.pm, Compiler.pm build_dependency_regex_map, HandlerVariantEmitter.pm _linkedre_or_expr and _emit_default_handler. Rust compiler.rs associates edges with current_regex_idx-1 (parent regexes) instead of building alternation from child regexes.`
- **reverify:** `cd rust && cargo test; grep -n dependency_regex_map perl/LinkedSpec/Compiler.pm`
- **source:** [`docs/knowledge/rust-edge-semantics-bug.md`](docs/knowledge/rust-edge-semantics-bug.md)

### rust-retv-propagation
_Rust engine propagates child-return (retv) via a per-invocation return channel on RuntimeContext; execute_rule returns the rule's value and set_retv is called after -> / => dispatch_

- **answers:** how does the Rust engine propagate retv | how does a parent read a child rule's return value in Rust | why did scalar(retv) resolve to undef in the Rust runtime | what does execute_rule return in the Rust engine | how does return(expr) work in the Rust runtime vs the accumulator | how does call(child) resolve a rule name in Rust
- **date:** 2026-06-16 · **status:** confirmed
- **evidence:** `RUST-PARITY.5.1 (2026-06-16): rust/linkedspec-runtime/src/engine.rs execute_rule + acode/bcode dispatch + return/call helpers; rust/linkedspec-runtime/src/runtime.rs return_value channel + set_retv. Matches book appendix/runtime-semantics.md §3.3/§5.4/§6.1. 186/186 tests green.`
- **reverify:** `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- **source:** [`docs/knowledge/rust-retv-propagation.md`](docs/knowledge/rust-retv-propagation.md)

### scanner-rule-family-architecture
_Scanner rule families are deliberately split into PrimitiveBasicRules, PrimitivePipelineRules, FlowRules, and LegacyRules by complexity and lifecycle_

- **answers:** how are scanner rules organized in linkedspec | what is the difference between PrimitiveBasicRules and LegacyRules | where do new scanner rules go | what is the scanner rule family split
- **date:** 2026-06-12 · **status:** current
- **evidence:** `perl/LinkedSpec/ActionIR/Scanner/ contains 6 files; ScannerCore dispatches to all 4 rule families via a central registry`
- **reverify:** `ls perl/LinkedSpec/ActionIR/Scanner/*.pm`
- **source:** [`docs/knowledge/scanner-rule-family-architecture.md`](docs/knowledge/scanner-rule-family-architecture.md)

### spec-format-brainstorm-rounds-1-3
_Brainstorm outcomes Rounds 1–3 for .spec format evolution — variables, types, control flow, edge syntax, arithmetic (no decisions finalized)_

- **answers:** what format changes were brainstormed for .spec files | what is the future direction for declare assign push set_key | what was decided about function composability | what control flow syntax was agreed | what arithmetic function forms were settled | what is the status of -> edge semantics
- **date:** 2026-06-15 · **status:** brainstorming
- **evidence:** `Conversation transcript 2026-06-15. Three rounds of brainstorming completed. No code changes made. No decisions finalized.`
- **reverify:** `cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md`
- **source:** [`docs/knowledge/spec-format-brainstorm-rounds-1-3.md`](docs/knowledge/spec-format-brainstorm-rounds-1-3.md)

### spec-spec-self-hosted-grammar
_specs/spec.spec is the self-hosted .spec grammar and the preferred surface for .spec evolution_

- **answers:** is there a self-hosted .spec grammar | what is specs/spec.spec | how should .spec language changes land | where is the LinkedSpec language defined in LinkedSpec itself
- **date:** 2026-06-05 · **status:** current
- **evidence:** `specs/spec.spec exists and compiles at language_agnostic_ready_ratio == 1.0000; docs/tasks/PHASE7-SELF-HOSTED-SPEC.md (5 leaves, done)`
- **reverify:** `ls specs/spec.spec`
- **source:** [`docs/knowledge/spec-spec-self-hosted-grammar.md`](docs/knowledge/spec-spec-self-hosted-grammar.md)

### specentry-backend-portability-ceiling
_SpecEntry emits Perl source strings and eval()s them — this is the strongest backend-portability ceiling in the project_

- **answers:** why can't LinkedSpec target non-Perl backends | what is the biggest portability blocker | how does SpecEntry generate runtime handlers | what would it take to port LinkedSpec to another language
- **date:** 2026-06-12 · **status:** current
- **evidence:** `ARCHITECTURE_STATE.md §Main Hotspots and Risks: 'SpecEntry still relies on generated Perl source plus eval; strongest backend-portability ceiling; still a likely long-term refactor target'`
- **reverify:** `grep -n 'backend-portability ceiling\|eval' ARCHITECTURE_STATE.md | head -3`
- **source:** [`docs/knowledge/specentry-backend-portability-ceiling.md`](docs/knowledge/specentry-backend-portability-ceiling.md)

### specentry-perl-coupling-inventory
_SpecEntry.pm Perl coupling inventory — every eval site, generated-code pattern, and LinkedRE dependency across 10 handler-variant builders_

- **answers:** what Perl coupling points exist in SpecEntry.pm | how are handler variants built in SpecEntry | what does SpecEntry eval | how does SpecEntry depend on LinkedRE::or | what Perl variables are assumed by generated handlers | how many handler variant builders are in SpecEntry
- **date:** 2026-06-12 · **status:** current
- **evidence:** `|`
- **reverify:** `|`
- **source:** [`docs/knowledge/specentry-perl-coupling-inventory.md`](docs/knowledge/specentry-perl-coupling-inventory.md)

### trace-verbosity-and-formatting
_LinkedSpec::Trace owns all trace state — verbosity, indentation, formatting, and output routing — with UVM-style verbosity levels and lazy Data::Dumper loading_

- **answers:** how does trace work in linkedspec | what are the verbosity levels | how do I configure trace output | where does log_output go
- **date:** 2026-06-12 · **status:** current
- **evidence:** `perl/LinkedSpec/Trace.pm; LinkedSpec.pm re-exports trace globals via typeglob aliasing; verbosity constants DUMP_NONE through DUMP_DEBUG defined in LinkedSpec.pm`
- **reverify:** `grep -n 'DUMP_NONE\|DUMP_DEBUG\|configure_trace' perl/LinkedSpec.pm`
- **source:** [`docs/knowledge/trace-verbosity-and-formatting.md`](docs/knowledge/trace-verbosity-and-formatting.md)
