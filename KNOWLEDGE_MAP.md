# Knowledge Map

> **AUTO-GENERATED — DO NOT EDIT.** Regenerate with `knowledge-map/scripts/gen_knowledge_map.sh`.
> Source of truth = YAML front-matter in: `docs/knowledge docs/decisions`. Edit the fact files, never this map.
> A fact is any `.md` whose front-matter has a non-empty `answers:` list.
> **40** facts · **223** question keys.

## Questions → fact

- "Bareword found where operator expected at LinkedSpec::generated_handler AND_ACODE" -> [and-return-edge-codegen-defect](docs/knowledge/and-return-edge-codegen-defect.md) · 2026-06-19 · reverify: `perl -Iperl -e 'require LinkedSpec; my $s=\"Top::AND\\n /a/\\n /b/\\n -> Top[0] { assign(scalar(x), 1) }\\n -> Top[1] { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},parse_mode=>q{consume},runtime_ctx_ref=>\\%c); my $in=q{ab}; my $a=$p->(\\$in); print defined($a)?qq{ast def (FIXED)\\n}:qq{ast UNDEF (defect present)\\n}'  # now prints 'ast def (FIXED)'`
- "are PPlugin and PluginBridge part of the target architecture" -> [pplugin-pluginbridge-transition-machinery](docs/knowledge/pplugin-pluginbridge-transition-machinery.md) · 2026-06-12 · reverify: `grep -n 'transition.removal.machinery\|plugin-hosting framework' ARCHITECTURE_STATE.md`
- "are action-edge fluent continuations lowered in the Rust variant" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "are cursor_pos / match_start_pos / length char-based or byte-based in Rust" -> [rust-char-based-offsets](docs/knowledge/rust-char-based-offsets.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'byte_to_char_offset\\|char_substr\\|match_start_byte' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs | head`
- "are return_a return_m return_ma return_imatch deprecated" -> [medium-term-alias-retirement-deferred](docs/knowledge/medium-term-alias-retirement-deferred.md) · 2026-06-12 · reverify: `grep -c 'return_a(' t/phase0_regression.t`
- "are tail drop_last flatten array_values recognized helpers" -> [rust-retired-array-aliases-not-added](docs/knowledge/rust-retired-array-aliases-not-added.md) · 2026-06-16 · reverify: `grep -c '\"flat\" =>' rust/linkedspec-runtime/src/engine.rs; grep -cE '\"tail\"|\"drop_last\"|\"flatten\"|\"array_values\"' rust/linkedspec-runtime/src/engine.rs`
- "are the phase0 capture/mark back-half failures stale or real" -> [and-return-edge-codegen-defect](docs/knowledge/and-return-edge-codegen-defect.md) · 2026-06-19 · reverify: `perl -Iperl -e 'require LinkedSpec; my $s=\"Top::AND\\n /a/\\n /b/\\n -> Top[0] { assign(scalar(x), 1) }\\n -> Top[1] { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},parse_mode=>q{consume},runtime_ctx_ref=>\\%c); my $in=q{ab}; my $a=$p->(\\$in); print defined($a)?qq{ast def (FIXED)\\n}:qq{ast UNDEF (defect present)\\n}'  # now prints 'ast def (FIXED)'`
- "are there compatibility-surface rules left" -> [method-like-dsl-migration-status](docs/knowledge/method-like-dsl-migration-status.md) · 2026-06-12 · reverify: `grep -c 'compatibility_surface.*0' docs/tasks/METHOD-LIKE-DSL-MIGRATION.md`
- "can a spec introduce a compatibility-surface rule" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "do capture_take_* helpers advance the mark in the Rust engine" -> [rust-mark-based-capture-family](docs/knowledge/rust-mark-based-capture-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_from\"\\|\"capture_len_from\"\\|\"capture_between\"\\|\"mark_copy\"\\|fn span_text' linkedspec-runtime/src/engine.rs | head`
- "do single-colon name : /re/ rules work in the Rust compiler" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "do the anonymous capture_take_* helpers advance the capture cursor in the Rust engine" -> [rust-anonymous-capture-slice-family](docs/knowledge/rust-anonymous-capture-slice-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_slice\"\\|\"capture_slice_until_cursor\"\\|\"capture_take\"\\|\"capture_rest\"\\|\"capture_take_rest\"' linkedspec-runtime/src/engine.rs | head`
- "does => child wrap each child result in a tag like ['?Rule:',[]]" -> [blind-call-collection-shape](docs/knowledge/blind-call-collection-shape.md) · 2026-06-21 · reverify: `perl -Iperl -MLinkedSpec -e 'my $s=qq{Choice::OR+\\n => First\\n => Second\\n\\nFirst:\\n /a/ -> First { return(1) }\\n\\nSecond:\\n /b/ -> Second { return(1) }\\n}; my $p=LinkedSpec::Get(\\$s); my $in=q{ab}; use Data::Dumper; print Dumper($p->(\\$in))'`
- "does a child rule's match clobber the parent's match in Rust" -> [rust-entry-match-separation](docs/knowledge/rust-entry-match-separation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'SavedMatchState\\|entry_groups\\|match_groups' linkedspec-runtime/src/engine.rs | head`
- "does a regex on a rule header line register in the Rust parser" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "does bare rule: with => child mean ordered sequence" -> [blind-call-rule-label-contract](docs/knowledge/blind-call-rule-label-contract.md) · 2026-06-12 · reverify: `grep -n 'blind.call.*mode.driven' ROADMAP_V2.md`
- "does capture_from read to the start or the end of the match in the Rust engine" -> [rust-mark-based-capture-family](docs/knowledge/rust-mark-based-capture-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_from\"\\|\"capture_len_from\"\\|\"capture_between\"\\|\"mark_copy\"\\|fn span_text' linkedspec-runtime/src/engine.rs | head`
- "does capture_slice read to the start or the end of the match in the Rust engine" -> [rust-anonymous-capture-slice-family](docs/knowledge/rust-anonymous-capture-slice-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_slice\"\\|\"capture_slice_until_cursor\"\\|\"capture_take\"\\|\"capture_rest\"\\|\"capture_take_rest\"' linkedspec-runtime/src/engine.rs | head`
- "does perl/LinkedSpec/ActionRewriter.pm still exist" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "does spec.spec run alongside bootstrap" -> [bootstrapspec-vs-spec-spec-dual-path](docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md) · 2026-06-13 · reverify: `grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm`
- "does strict_syntax reject unused rules in the Rust variant" -> [rust-strict-syntax-validation](docs/knowledge/rust-strict-syntax-validation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'fn validate_with_options\\|fn check_unused_rules\\|strict_syntax' linkedspec-core/src/validation.rs`
- "does the .spec parser/compiler/runtime core depend on RTLUtils or FSMGen or VHDL::ConstantEval" -> [rtlutils-regex-hang](docs/knowledge/rtlutils-regex-hang.md) · 2026-06-18 · reverify: `! test -e perl/RTLUtils.pm && ! test -e perl/FSMGen.pm && echo 'subsystem retired (LEGACY-VHDL-RETIRE)'   # back-half hang persists: HTML::PathLinks::link_path_tokens (subtest 131) until its own fix track`
- "does the Perl reference recognize tail drop_last flatten array_values" -> [rust-retired-array-aliases-not-added](docs/knowledge/rust-retired-array-aliases-not-added.md) · 2026-06-16 · reverify: `grep -c '\"flat\" =>' rust/linkedspec-runtime/src/engine.rs; grep -cE '\"tail\"|\"drop_last\"|\"flatten\"|\"array_values\"' rust/linkedspec-runtime/src/engine.rs`
- "does the Perl version go away" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "does the Rust engine reproduce tclite or Lispish output yet" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "does the Rust engine use byte or char offsets" -> [rust-char-based-offsets](docs/knowledge/rust-char-based-offsets.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'byte_to_char_offset\\|char_substr\\|match_start_byte' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs | head`
- "does the Rust variant have a strict_syntax validation mode" -> [rust-strict-syntax-validation](docs/knowledge/rust-strict-syntax-validation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'fn validate_with_options\\|fn check_unused_rules\\|strict_syntax' linkedspec-core/src/validation.rs`
- "dual-path parse" -> [bootstrapspec-vs-spec-spec-dual-path](docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md) · 2026-06-13 · reverify: `grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm`
- "entry_group vs match_group in a dispatched child rule" -> [spec-top-rule-no-regex-two-rule-minimum](docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md) · 2026-06-17 · reverify: `perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=\"demo_top::  -> word_pair  .push\\nLX {return(array_copy(a(demo_top)))}\\n\\nword_pair : /(\\\\w+) (\\\\w+)/  I.return(concat(entry_group(0), \\\"-\\\", entry_group(1)))\\n\"; my $p=LinkedSpec::Get(\\$s); print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\\"hello world\\\")),\"\\n\"'  # => [\"hello-world\"]`
- "how are handler variants built in SpecEntry" -> [specentry-perl-coupling-inventory](docs/knowledge/specentry-perl-coupling-inventory.md) · 2026-06-12 · reverify: `|`
- "how are scanner rules organized in linkedspec" -> [scanner-rule-family-architecture](docs/knowledge/scanner-rule-family-architecture.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/Scanner/*.pm`
- "how big is the legacy VHDL/RTL/FSM generation subsystem" -> [rtlutils-regex-hang](docs/knowledge/rtlutils-regex-hang.md) · 2026-06-18 · reverify: `! test -e perl/RTLUtils.pm && ! test -e perl/FSMGen.pm && echo 'subsystem retired (LEGACY-VHDL-RETIRE)'   # back-half hang persists: HTML::PathLinks::link_path_tokens (subtest 131) until its own fix track`
- "how do ActionIR owners resolve their dependencies" -> [ownerdispatch-shared-seam](docs/knowledge/ownerdispatch-shared-seam.md) · 2026-06-12 · reverify: `grep -l 'OwnerDispatch' perl/LinkedSpec/*.pm perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "how do I add a new backend emitter" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "how do I configure trace output" -> [trace-verbosity-and-formatting](docs/knowledge/trace-verbosity-and-formatting.md) · 2026-06-12 · reverify: `grep -n 'DUMP_NONE\|DUMP_DEBUG\|configure_trace' perl/LinkedSpec.pm`
- "how do I regenerate the oracle corpus fixtures" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "how do I run CI / the regression gate" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "how do I run strict validation in the Rust variant" -> [rust-strict-syntax-validation](docs/knowledge/rust-strict-syntax-validation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'fn validate_with_options\\|fn check_unused_rules\\|strict_syntax' linkedspec-core/src/validation.rs`
- "how do I write a minimal worked .spec example for the book" -> [spec-top-rule-no-regex-two-rule-minimum](docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md) · 2026-06-17 · reverify: `perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=\"demo_top::  -> word_pair  .push\\nLX {return(array_copy(a(demo_top)))}\\n\\nword_pair : /(\\\\w+) (\\\\w+)/  I.return(concat(entry_group(0), \\\"-\\\", entry_group(1)))\\n\"; my $p=LinkedSpec::Get(\\$s); print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\\"hello world\\\")),\"\\n\"'  # => [\"hello-world\"]`
- "how do backends stay in lockstep" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "how do variant builders work" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "how does -> edge dispatch work in Perl" -> [rust-edge-semantics-bug](docs/knowledge/rust-edge-semantics-bug.md) · 2026-06-15 · reverify: `cd rust && cargo test; grep -n dependency_regex_map perl/LinkedSpec/Compiler.pm`
- "how does ActionIR lowering work" -> [actionir-lowering-stack](docs/knowledge/actionir-lowering-stack.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "how does EmitContext dispatch into ActionIR owners" -> [emitcontext-owner-registry](docs/knowledge/emitcontext-owner-registry.md) · 2026-06-12 · reverify: `grep -c '_actionir_owner_package\|owner_pkgs' perl/LinkedSpec/RuleIR/EmitContext.pm`
- "how does HandlerIR enable multi-backend portability" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "how does HandlerIR help portability" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "how does LinkedSpec.pm dispatch into owner modules" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "how does RuntimeContext anchor chdir-safety for runtime state" -> [runtimecontext-boundary](docs/knowledge/runtimecontext-boundary.md) · 2026-06-12 · reverify: `grep -l 'RuntimeContext' perl/LinkedSpec/*.pm perl/LinkedSpec/RuleIR/*.pm | wc -l`
- "how does Rust match Perl's char-based positions" -> [rust-char-based-offsets](docs/knowledge/rust-char-based-offsets.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'byte_to_char_offset\\|char_substr\\|match_start_byte' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs | head`
- "how does SpecEntry depend on LinkedRE::or" -> [specentry-perl-coupling-inventory](docs/knowledge/specentry-perl-coupling-inventory.md) · 2026-06-12 · reverify: `|`
- "how does SpecEntry generate runtime handlers" -> [specentry-backend-portability-ceiling](docs/knowledge/specentry-backend-portability-ceiling.md) · 2026-06-12 · reverify: `grep -n 'backend-portability ceiling\|eval' ARCHITECTURE_STATE.md | head -3`
- "how does _actionir_owner_package work" -> [emitcontext-owner-registry](docs/knowledge/emitcontext-owner-registry.md) · 2026-06-12 · reverify: `grep -c '_actionir_owner_package\|owner_pkgs' perl/LinkedSpec/RuleIR/EmitContext.pm`
- "how does a normal rule surface a computed value to the parser output" -> [spec-top-rule-no-regex-two-rule-minimum](docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md) · 2026-06-17 · reverify: `perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=\"demo_top::  -> word_pair  .push\\nLX {return(array_copy(a(demo_top)))}\\n\\nword_pair : /(\\\\w+) (\\\\w+)/  I.return(concat(entry_group(0), \\\"-\\\", entry_group(1)))\\n\"; my $p=LinkedSpec::Get(\\$s); print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\\"hello world\\\")),\"\\n\"'  # => [\"hello-world\"]`
- "how does a parent read a child rule's return value in Rust" -> [rust-retv-propagation](docs/knowledge/rust-retv-propagation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- "how does blind-call work in linkedspec" -> [blind-call-rule-label-contract](docs/knowledge/blind-call-rule-label-contract.md) · 2026-06-12 · reverify: `grep -n 'blind.call.*mode.driven' ROADMAP_V2.md`
- "how does call(child) resolve a rule name in Rust" -> [rust-retv-propagation](docs/knowledge/rust-retv-propagation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- "how does capture_take differ from capture_take_until_cursor in the Rust engine" -> [rust-anonymous-capture-slice-family](docs/knowledge/rust-anonymous-capture-slice-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_slice\"\\|\"capture_slice_until_cursor\"\\|\"capture_take\"\\|\"capture_rest\"\\|\"capture_take_rest\"' linkedspec-runtime/src/engine.rs | head`
- "how does descriptor assembly work" -> [compilerstate-internal-model](docs/knowledge/compilerstate-internal-model.md) · 2026-06-12 · reverify: `test -f perl/LinkedSpec/CompilerState.pm && grep -l CompilerState perl/LinkedSpec/Compiler.pm perl/LinkedSpec/Validation.pm`
- "how does helper code get from .spec to emitted Perl" -> [actionir-lowering-stack](docs/knowledge/actionir-lowering-stack.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "how does lazy owner loading work in linkedspec" -> [ownerdispatch-shared-seam](docs/knowledge/ownerdispatch-shared-seam.md) · 2026-06-12 · reverify: `grep -l 'OwnerDispatch' perl/LinkedSpec/*.pm perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "how does return(expr) work in the Rust runtime vs the accumulator" -> [rust-retv-propagation](docs/knowledge/rust-retv-propagation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- "how does spec.spec relate to the bootstrap grammar" -> [bootstrapspec-vs-spec-spec-dual-path](docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md) · 2026-06-13 · reverify: `grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm`
- "how does the JSON backend prove pluggability" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "how does the Rust engine convert between byte and char offsets" -> [rust-char-based-offsets](docs/knowledge/rust-char-based-offsets.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'byte_to_char_offset\\|char_substr\\|match_start_byte' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs | head`
- "how does the Rust engine emulate Perl IMATCH and LMATCH" -> [rust-entry-match-separation](docs/knowledge/rust-entry-match-separation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'SavedMatchState\\|entry_groups\\|match_groups' linkedspec-runtime/src/engine.rs | head`
- "how does the Rust engine implement capture_len_from / capture_until_cursor_from / capture_rest_from" -> [rust-mark-based-capture-family](docs/knowledge/rust-mark-based-capture-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_from\"\\|\"capture_len_from\"\\|\"capture_between\"\\|\"mark_copy\"\\|fn span_text' linkedspec-runtime/src/engine.rs | head`
- "how does the Rust engine implement capture_slice_until_cursor / capture_take / capture_rest" -> [rust-anonymous-capture-slice-family](docs/knowledge/rust-anonymous-capture-slice-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_slice\"\\|\"capture_slice_until_cursor\"\\|\"capture_take\"\\|\"capture_rest\"\\|\"capture_take_rest\"' linkedspec-runtime/src/engine.rs | head`
- "how does the Rust engine propagate retv" -> [rust-retv-propagation](docs/knowledge/rust-retv-propagation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- "how does the Rust engine separate entry_* from match_*" -> [rust-entry-match-separation](docs/knowledge/rust-entry-match-separation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'SavedMatchState\\|entry_groups\\|match_groups' linkedspec-runtime/src/engine.rs | head`
- "how does the Rust parser handle .push / .return on action edges" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "how does the Rust variant test output parity against the Perl reference" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "how does the anonymous capture-slice family work in the Rust engine" -> [rust-anonymous-capture-slice-family](docs/knowledge/rust-anonymous-capture-slice-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_slice\"\\|\"capture_slice_until_cursor\"\\|\"capture_take\"\\|\"capture_rest\"\\|\"capture_take_rest\"' linkedspec-runtime/src/engine.rs | head`
- "how does the mark-based capture family work in the Rust engine" -> [rust-mark-based-capture-family](docs/knowledge/rust-mark-based-capture-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_from\"\\|\"capture_len_from\"\\|\"capture_between\"\\|\"mark_copy\"\\|fn span_text' linkedspec-runtime/src/engine.rs | head`
- "how does top_rule flow through the compile pipeline" -> [runtimecontext-boundary](docs/knowledge/runtimecontext-boundary.md) · 2026-06-12 · reverify: `grep -l 'RuntimeContext' perl/LinkedSpec/*.pm perl/LinkedSpec/RuleIR/*.pm | wc -l`
- "how does trace work in linkedspec" -> [trace-verbosity-and-formatting](docs/knowledge/trace-verbosity-and-formatting.md) · 2026-06-12 · reverify: `grep -n 'DUMP_NONE\|DUMP_DEBUG\|configure_trace' perl/LinkedSpec.pm`
- "how is $@ preserved across owner dispatch" -> [ownerdispatch-shared-seam](docs/knowledge/ownerdispatch-shared-seam.md) · 2026-06-12 · reverify: `grep -l 'OwnerDispatch' perl/LinkedSpec/*.pm perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "how is the regression test organized" -> [phase0-regression-structure](docs/knowledge/phase0-regression-structure.md) · 2026-06-12 · reverify: `wc -l t/phase0_regression.t`
- "how is the top-level rule handled in the engine" -> [spec-top-rule-no-regex-two-rule-minimum](docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md) · 2026-06-17 · reverify: `perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=\"demo_top::  -> word_pair  .push\\nLX {return(array_copy(a(demo_top)))}\\n\\nword_pair : /(\\\\w+) (\\\\w+)/  I.return(concat(entry_group(0), \\\"-\\\", entry_group(1)))\\n\"; my $p=LinkedSpec::Get(\\$s); print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\\"hello world\\\")),\"\\n\"'  # => [\"hello-world\"]`
- "how long does phase0 take to run" -> [phase0-regression-structure](docs/knowledge/phase0-regression-structure.md) · 2026-06-12 · reverify: `wc -l t/phase0_regression.t`
- "how many handler variant builders are in SpecEntry" -> [specentry-perl-coupling-inventory](docs/knowledge/specentry-perl-coupling-inventory.md) · 2026-06-12 · reverify: `|`
- "how many rules does a .spec need" -> [spec-top-rule-no-regex-two-rule-minimum](docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md) · 2026-06-17 · reverify: `perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=\"demo_top::  -> word_pair  .push\\nLX {return(array_copy(a(demo_top)))}\\n\\nword_pair : /(\\\\w+) (\\\\w+)/  I.return(concat(entry_group(0), \\\"-\\\", entry_group(1)))\\n\"; my $p=LinkedSpec::Get(\\$s); print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\\"hello world\\\")),\"\\n\"'  # => [\"hello-world\"]`
- "how many specs use convention-based accumulators" -> [accumulator-convention-healthy](docs/knowledge/accumulator-convention-healthy.md) · 2026-06-12 · reverify: `grep -c 'push(Child)' specs/*.spec; grep -c 'push_value' specs/*.spec`
- "how should .spec language changes land" -> [spec-spec-self-hosted-grammar](docs/knowledge/spec-spec-self-hosted-grammar.md) · 2026-06-05 · reverify: `ls specs/spec.spec`
- "how should I structure a valid .spec (top rule + normal rules)" -> [spec-top-rule-no-regex-two-rule-minimum](docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md) · 2026-06-17 · reverify: `perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=\"demo_top::  -> word_pair  .push\\nLX {return(array_copy(a(demo_top)))}\\n\\nword_pair : /(\\\\w+) (\\\\w+)/  I.return(concat(entry_group(0), \\\"-\\\", entry_group(1)))\\n\"; my $p=LinkedSpec::Get(\\$s); print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\\"hello world\\\")),\"\\n\"'  # => [\"hello-world\"]`
- "how should the Rust compiler build regex alternations" -> [rust-edge-semantics-bug](docs/knowledge/rust-edge-semantics-bug.md) · 2026-06-15 · reverify: `cd rust && cargo test; grep -n dependency_regex_map perl/LinkedSpec/Compiler.pm`
- "is ActionRewriter a live module in linkedspec" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "is GitHub Actions CI running for linkedspec" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "is LinkedSpec still a plugin-hosting framework" -> [pplugin-pluginbridge-transition-machinery](docs/knowledge/pplugin-pluginbridge-transition-machinery.md) · 2026-06-12 · reverify: `grep -n 'transition.removal.machinery\|plugin-hosting framework' ARCHITECTURE_STATE.md`
- "is LinkedSpec.pm the implementation center" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "is it safe to use LX on a repeated (AND+) rule" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "is mark_copy one argument or two arguments" -> [rust-mark-based-capture-family](docs/knowledge/rust-mark-based-capture-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_from\"\\|\"capture_len_from\"\\|\"capture_between\"\\|\"mark_copy\"\\|fn span_text' linkedspec-runtime/src/engine.rs | head`
- "is match_start_pos / entry_start_pos implemented in the Rust runtime" -> [rust-char-based-offsets](docs/knowledge/rust-char-based-offsets.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'byte_to_char_offset\\|char_substr\\|match_start_byte' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs | head`
- "is push(Child) without an explicit target deprecated" -> [accumulator-convention-healthy](docs/knowledge/accumulator-convention-healthy.md) · 2026-06-12 · reverify: `grep -c 'push(Child)' specs/*.spec; grep -c 'push_value' specs/*.spec`
- "is spec.spec the active frontend" -> [bootstrapspec-vs-spec-spec-dual-path](docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md) · 2026-06-13 · reverify: `grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm`
- "is the top rule flagged as unused in strict mode" -> [rust-strict-syntax-validation](docs/knowledge/rust-strict-syntax-validation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'fn validate_with_options\\|fn check_unused_rules\\|strict_syntax' linkedspec-core/src/validation.rs`
- "is there a self-hosted .spec grammar" -> [spec-spec-self-hosted-grammar](docs/knowledge/spec-spec-self-hosted-grammar.md) · 2026-06-05 · reverify: `ls specs/spec.spec`
- "is there still a RETURN_A or RETURN_M canonical action-IR node" -> [actionir-return-node-retired-to-return](docs/knowledge/actionir-return-node-retired-to-return.md) · 2026-06-21 · reverify: `perl -Iperl -e 'use LinkedSpec; my $s=qq{Top::&\\nI { return_undef() }\\n /a/ -> Top { return(1) }\\n}; my $d=LinkedSpec::Get(\\$s,return_descriptor=>1); use Data::Dumper; print Dumper($d->{spec}{Top}{meta}{action_rewriter}{canonical_action_ir_nodes})'`
- "parser infinite loop with Late Exit lifecycle marker" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "should I fix the RTLUtils regex hang or retire the subsystem" -> [rtlutils-regex-hang](docs/knowledge/rtlutils-regex-hang.md) · 2026-06-18 · reverify: `! test -e perl/RTLUtils.pm && ! test -e perl/FSMGen.pm && echo 'subsystem retired (LEGACY-VHDL-RETIRE)'   # back-half hang persists: HTML::PathLinks::link_path_tokens (subtest 131) until its own fix track`
- "should I use push_value or push(Child)" -> [accumulator-convention-healthy](docs/knowledge/accumulator-convention-healthy.md) · 2026-06-12 · reverify: `grep -c 'push(Child)' specs/*.spec; grep -c 'push_value' specs/*.spec`
- "should a new backend implement the retired compatibility aliases" -> [rust-retired-array-aliases-not-added](docs/knowledge/rust-retired-array-aliases-not-added.md) · 2026-06-16 · reverify: `grep -c '\"flat\" =>' rust/linkedspec-runtime/src/engine.rs; grep -cE '\"tail\"|\"drop_last\"|\"flatten\"|\"array_values\"' rust/linkedspec-runtime/src/engine.rs`
- "should new code use plugin dispatch" -> [pplugin-pluginbridge-transition-machinery](docs/knowledge/pplugin-pluginbridge-transition-machinery.md) · 2026-06-12 · reverify: `grep -n 'transition.removal.machinery\|plugin-hosting framework' ARCHITECTURE_STATE.md`
- "should the Rust backend implement tail drop_last flatten array_values" -> [rust-retired-array-aliases-not-added](docs/knowledge/rust-retired-array-aliases-not-added.md) · 2026-06-16 · reverify: `grep -c '\"flat\" =>' rust/linkedspec-runtime/src/engine.rs; grep -cE '\"tail\"|\"drop_last\"|\"flatten\"|\"array_values\"' rust/linkedspec-runtime/src/engine.rs`
- "should the top-level rule carry a regex" -> [spec-top-rule-no-regex-two-rule-minimum](docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md) · 2026-06-17 · reverify: `perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=\"demo_top::  -> word_pair  .push\\nLX {return(array_copy(a(demo_top)))}\\n\\nword_pair : /(\\\\w+) (\\\\w+)/  I.return(concat(entry_group(0), \\\"-\\\", entry_group(1)))\\n\"; my $p=LinkedSpec::Get(\\$s); print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\\"hello world\\\")),\"\\n\"'  # => [\"hello-world\"]`
- "what Perl coupling points exist in SpecEntry.pm" -> [specentry-perl-coupling-inventory](docs/knowledge/specentry-perl-coupling-inventory.md) · 2026-06-12 · reverify: `|`
- "what Perl variables are assumed by generated handlers" -> [specentry-perl-coupling-inventory](docs/knowledge/specentry-perl-coupling-inventory.md) · 2026-06-12 · reverify: `|`
- "what are the ActionIR sub-owners" -> [actionir-lowering-stack](docs/knowledge/actionir-lowering-stack.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "what are the HandlerIR node kinds" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "what are the endpoints of the mark-based capture readers" -> [rust-mark-based-capture-family](docs/knowledge/rust-mark-based-capture-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_from\"\\|\"capture_len_from\"\\|\"capture_between\"\\|\"mark_copy\"\\|fn span_text' linkedspec-runtime/src/engine.rs | head`
- "what are the fields of a HandlerIR node" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "what are the verbosity levels" -> [trace-verbosity-and-formatting](docs/knowledge/trace-verbosity-and-formatting.md) · 2026-06-12 · reverify: `grep -n 'DUMP_NONE\|DUMP_DEBUG\|configure_trace' perl/LinkedSpec.pm`
- "what arithmetic function forms were settled" -> [spec-format-brainstorm-rounds-1-3](docs/knowledge/spec-format-brainstorm-rounds-1-3.md) · 2026-06-15 · reverify: `cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md`
- "what backends will LinkedSpec support" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "what blocks the SPEC-FORMAT-TERSE implementation leaves" -> [rtlutils-regex-hang](docs/knowledge/rtlutils-regex-hang.md) · 2026-06-18 · reverify: `! test -e perl/RTLUtils.pm && ! test -e perl/FSMGen.pm && echo 'subsystem retired (LEGACY-VHDL-RETIRE)'   # back-half hang persists: HTML::PathLinks::link_path_tokens (subtest 131) until its own fix track`
- "what canonical action-IR node does a return lower to in linkedspec" -> [actionir-return-node-retired-to-return](docs/knowledge/actionir-return-node-retired-to-return.md) · 2026-06-21 · reverify: `perl -Iperl -e 'use LinkedSpec; my $s=qq{Top::&\\nI { return_undef() }\\n /a/ -> Top { return(1) }\\n}; my $d=LinkedSpec::Get(\\$s,return_descriptor=>1); use Data::Dumper; print Dumper($d->{spec}{Top}{meta}{action_rewriter}{canonical_action_ir_nodes})'`
- "what control flow syntax was agreed" -> [spec-format-brainstorm-rounds-1-3](docs/knowledge/spec-format-brainstorm-rounds-1-3.md) · 2026-06-15 · reverify: `cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md`
- "what depends on RTLUtils FSMGen VHDL::ConstantEval" -> [rtlutils-regex-hang](docs/knowledge/rtlutils-regex-hang.md) · 2026-06-18 · reverify: `! test -e perl/RTLUtils.pm && ! test -e perl/FSMGen.pm && echo 'subsystem retired (LEGACY-VHDL-RETIRE)'   # back-half hang persists: HTML::PathLinks::link_path_tokens (subtest 131) until its own fix track`
- "what did the accumulator audit find" -> [accumulator-convention-healthy](docs/knowledge/accumulator-convention-healthy.md) · 2026-06-12 · reverify: `grep -c 'push(Child)' specs/*.spec; grep -c 'push_value' specs/*.spec`
- "what does SpecEntry eval" -> [specentry-perl-coupling-inventory](docs/knowledge/specentry-perl-coupling-inventory.md) · 2026-06-12 · reverify: `|`
- "what does a repeated AND group return" -> [blind-call-collection-shape](docs/knowledge/blind-call-collection-shape.md) · 2026-06-21 · reverify: `perl -Iperl -MLinkedSpec -e 'my $s=qq{Choice::OR+\\n => First\\n => Second\\n\\nFirst:\\n /a/ -> First { return(1) }\\n\\nSecond:\\n /b/ -> Second { return(1) }\\n}; my $p=LinkedSpec::Get(\\$s); my $in=q{ab}; use Data::Dumper; print Dumper($p->(\\$in))'`
- "what does execute_rule return in the Rust engine" -> [rust-retv-propagation](docs/knowledge/rust-retv-propagation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- "what does green CI mean here" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "what does input_end_line and input_end_col compute in the Rust engine" -> [rust-retired-array-aliases-not-added](docs/knowledge/rust-retired-array-aliases-not-added.md) · 2026-06-16 · reverify: `grep -c '\"flat\" =>' rust/linkedspec-runtime/src/engine.rs; grep -cE '\"tail\"|\"drop_last\"|\"flatten\"|\"array_values\"' rust/linkedspec-runtime/src/engine.rs`
- "what does mark_input_start / mark_input_end store in the Rust engine" -> [rust-mark-based-capture-family](docs/knowledge/rust-mark-based-capture-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_from\"\\|\"capture_len_from\"\\|\"capture_between\"\\|\"mark_copy\"\\|fn span_text' linkedspec-runtime/src/engine.rs | head`
- "what does phase0_regression.t cover" -> [phase0-regression-structure](docs/knowledge/phase0-regression-structure.md) · 2026-06-12 · reverify: `wc -l t/phase0_regression.t`
- "what does strict_syntax do in the Rust validator" -> [rust-strict-syntax-validation](docs/knowledge/rust-strict-syntax-validation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'fn validate_with_options\\|fn check_unused_rules\\|strict_syntax' linkedspec-core/src/validation.rs`
- "what does the :: vs : colon mean for a rule (top vs normal)" -> [spec-top-rule-no-regex-two-rule-minimum](docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md) · 2026-06-17 · reverify: `perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=\"demo_top::  -> word_pair  .push\\nLX {return(array_copy(a(demo_top)))}\\n\\nword_pair : /(\\\\w+) (\\\\w+)/  I.return(concat(entry_group(0), \\\"-\\\", entry_group(1)))\\n\"; my $p=LinkedSpec::Get(\\$s); print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\\"hello world\\\")),\"\\n\"'  # => [\"hello-world\"]`
- "what does the phase0 regression gate enforce about specs" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "what format changes were brainstormed for .spec files" -> [spec-format-brainstorm-rounds-1-3](docs/knowledge/spec-format-brainstorm-rounds-1-3.md) · 2026-06-15 · reverify: `cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md`
- "what happened to return_a / return_m / return_ma / return_imatch / return_im / return_array" -> [actionir-return-node-retired-to-return](docs/knowledge/actionir-return-node-retired-to-return.md) · 2026-06-21 · reverify: `perl -Iperl -e 'use LinkedSpec; my $s=qq{Top::&\\nI { return_undef() }\\n /a/ -> Top { return(1) }\\n}; my $d=LinkedSpec::Get(\\$s,return_descriptor=>1); use Data::Dumper; print Dumper($d->{spec}{Top}{meta}{action_rewriter}{canonical_action_ir_nodes})'`
- "what happened with the medium-term alias retirement" -> [medium-term-alias-retirement-deferred](docs/knowledge/medium-term-alias-retirement-deferred.md) · 2026-06-12 · reverify: `grep -c 'return_a(' t/phase0_regression.t`
- "what helpers are available in the DSL" -> [method-like-dsl-migration-status](docs/knowledge/method-like-dsl-migration-status.md) · 2026-06-12 · reverify: `grep -c 'compatibility_surface.*0' docs/tasks/METHOD-LIKE-DSL-MIGRATION.md`
- "what is BootstrapSpec::Core vs spec.spec" -> [bootstrapspec-vs-spec-spec-dual-path](docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md) · 2026-06-13 · reverify: `grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm`
- "what is CompilerState and why was it extracted" -> [compilerstate-internal-model](docs/knowledge/compilerstate-internal-model.md) · 2026-06-12 · reverify: `test -f perl/LinkedSpec/CompilerState.pm && grep -l CompilerState perl/LinkedSpec/Compiler.pm perl/LinkedSpec/Validation.pm`
- "what is HandlerIR" -> [handler-ir-design](docs/knowledge/handler-ir-design.md) · 2026-06-14 · reverify: `grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15`
- "what is OwnerDispatch and why do all owners use it" -> [ownerdispatch-shared-seam](docs/knowledge/ownerdispatch-shared-seam.md) · 2026-06-12 · reverify: `grep -l 'OwnerDispatch' perl/LinkedSpec/*.pm perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "what is RTLUTILS-REGEX-HANG" -> [rtlutils-regex-hang](docs/knowledge/rtlutils-regex-hang.md) · 2026-06-18 · reverify: `! test -e perl/RTLUtils.pm && ! test -e perl/FSMGen.pm && echo 'subsystem retired (LEGACY-VHDL-RETIRE)'   # back-half hang persists: HTML::PathLinks::link_path_tokens (subtest 131) until its own fix track`
- "what is RuntimeContext and why is it important" -> [runtimecontext-boundary](docs/knowledge/runtimecontext-boundary.md) · 2026-06-12 · reverify: `grep -l 'RuntimeContext' perl/LinkedSpec/*.pm perl/LinkedSpec/RuleIR/*.pm | wc -l`
- "what is deferred in the DSL migration" -> [method-like-dsl-migration-status](docs/knowledge/method-like-dsl-migration-status.md) · 2026-06-12 · reverify: `grep -c 'compatibility_surface.*0' docs/tasks/METHOD-LIKE-DSL-MIGRATION.md`
- "what is dependency_regex_map" -> [rust-edge-semantics-bug](docs/knowledge/rust-edge-semantics-bug.md) · 2026-06-15 · reverify: `cd rust && cargo test; grep -n dependency_regex_map perl/LinkedSpec/Compiler.pm`
- "what is language_agnostic_ready_ratio and what value is required" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "what is specs/spec.spec" -> [spec-spec-self-hosted-grammar](docs/knowledge/spec-spec-self-hosted-grammar.md) · 2026-06-05 · reverify: `ls specs/spec.spec`
- "what is the AND / OR / AND+ blind-call output shape" -> [blind-call-collection-shape](docs/knowledge/blind-call-collection-shape.md) · 2026-06-21 · reverify: `perl -Iperl -MLinkedSpec -e 'my $s=qq{Choice::OR+\\n => First\\n => Second\\n\\nFirst:\\n /a/ -> First { return(1) }\\n\\nSecond:\\n /b/ -> Second { return(1) }\\n}; my $p=LinkedSpec::Get(\\$s); my $in=q{ab}; use Data::Dumper; print Dumper($p->(\\$in))'`
- "what is the AND++LX hang" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "what is the ActionIR pipeline" -> [actionir-lowering-stack](docs/knowledge/actionir-lowering-stack.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "what is the EmitContext owner registry" -> [emitcontext-owner-registry](docs/knowledge/emitcontext-owner-registry.md) · 2026-06-12 · reverify: `grep -c '_actionir_owner_package\|owner_pkgs' perl/LinkedSpec/RuleIR/EmitContext.pm`
- "what is the Perl↔Rust output oracle" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "what is the SCALAR(0x...)Top / near \")Top\" codegen error" -> [and-return-edge-codegen-defect](docs/knowledge/and-return-edge-codegen-defect.md) · 2026-06-19 · reverify: `perl -Iperl -e 'require LinkedSpec; my $s=\"Top::AND\\n /a/\\n /b/\\n -> Top[0] { assign(scalar(x), 1) }\\n -> Top[1] { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},parse_mode=>q{consume},runtime_ctx_ref=>\\%c); my $in=q{ab}; my $a=$p->(\\$in); print defined($a)?qq{ast def (FIXED)\\n}:qq{ast UNDEF (defect present)\\n}'  # now prints 'ast def (FIXED)'`
- "what is the accumulator convention in linkedspec" -> [accumulator-convention-healthy](docs/knowledge/accumulator-convention-healthy.md) · 2026-06-12 · reverify: `grep -c 'push(Child)' specs/*.spec; grep -c 'push_value' specs/*.spec`
- "what is the anonymous capture cursor in the Rust engine" -> [rust-anonymous-capture-slice-family](docs/knowledge/rust-anonymous-capture-slice-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_slice\"\\|\"capture_slice_until_cursor\"\\|\"capture_take\"\\|\"capture_rest\"\\|\"capture_take_rest\"' linkedspec-runtime/src/engine.rs | head`
- "what is the backend roadmap for LinkedSpec" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "what is the biggest portability blocker" -> [specentry-backend-portability-ceiling](docs/knowledge/specentry-backend-portability-ceiling.md) · 2026-06-12 · reverify: `grep -n 'backend-portability ceiling\|eval' ARCHITECTURE_STATE.md | head -3`
- "what is the canonical replacement for the retired return_* helpers" -> [actionir-return-node-retired-to-return](docs/knowledge/actionir-return-node-retired-to-return.md) · 2026-06-21 · reverify: `perl -Iperl -e 'use LinkedSpec; my $s=qq{Top::&\\nI { return_undef() }\\n /a/ -> Top { return(1) }\\n}; my $d=LinkedSpec::Get(\\$s,return_descriptor=>1); use Data::Dumper; print Dumper($d->{spec}{Top}{meta}{action_rewriter}{canonical_action_ir_nodes})'`
- "what is the difference between => child and -> child" -> [blind-call-rule-label-contract](docs/knowledge/blind-call-rule-label-contract.md) · 2026-06-12 · reverify: `grep -n 'blind.call.*mode.driven' ROADMAP_V2.md`
- "what is the difference between PrimitiveBasicRules and LegacyRules" -> [scanner-rule-family-architecture](docs/knowledge/scanner-rule-family-architecture.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/Scanner/*.pm`
- "what is the difference between entry_* and match_* in the Rust runtime" -> [rust-entry-match-separation](docs/knowledge/rust-entry-match-separation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'SavedMatchState\\|entry_groups\\|match_groups' linkedspec-runtime/src/engine.rs | head`
- "what is the difference between validate and validate_with_options in Rust" -> [rust-strict-syntax-validation](docs/knowledge/rust-strict-syntax-validation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'fn validate_with_options\\|fn check_unused_rules\\|strict_syntax' linkedspec-core/src/validation.rs`
- "what is the entry match for a dispatched child rule in Rust" -> [rust-entry-match-separation](docs/knowledge/rust-entry-match-separation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'SavedMatchState\\|entry_groups\\|match_groups' linkedspec-runtime/src/engine.rs | head`
- "what is the future direction for declare assign push set_key" -> [spec-format-brainstorm-rounds-1-3](docs/knowledge/spec-format-brainstorm-rounds-1-3.md) · 2026-06-15 · reverify: `cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md`
- "what is the language-agnostic architecture vision" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "what is the method-like DSL migration status" -> [method-like-dsl-migration-status](docs/knowledge/method-like-dsl-migration-status.md) · 2026-06-12 · reverify: `grep -c 'compatibility_surface.*0' docs/tasks/METHOD-LIKE-DSL-MIGRATION.md`
- "what is the plugin modernization status" -> [pplugin-pluginbridge-transition-machinery](docs/knowledge/pplugin-pluginbridge-transition-machinery.md) · 2026-06-12 · reverify: `grep -n 'transition.removal.machinery\|plugin-hosting framework' ARCHITECTURE_STATE.md`
- "what is the practical compile/runtime spine" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "what is the role of .spec files across backends" -> [language-agnostic-backend-vision](docs/knowledge/language-agnostic-backend-vision.md) · 2026-06-12 · reverify: `grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10`
- "what is the scanner rule family split" -> [scanner-rule-family-architecture](docs/knowledge/scanner-rule-family-architecture.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/Scanner/*.pm`
- "what is the single-regex rule 0-regex compiler gap in the Rust variant" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "what is the status of -> edge semantics" -> [spec-format-brainstorm-rounds-1-3](docs/knowledge/spec-format-brainstorm-rounds-1-3.md) · 2026-06-15 · reverify: `cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md`
- "what is the test migration problem" -> [medium-term-alias-retirement-deferred](docs/knowledge/medium-term-alias-retirement-deferred.md) · 2026-06-12 · reverify: `grep -c 'return_a(' t/phase0_regression.t`
- "what is wrong with the Rust -> edge implementation" -> [rust-edge-semantics-bug](docs/knowledge/rust-edge-semantics-bug.md) · 2026-06-15 · reverify: `cd rust && cargo test; grep -n dependency_regex_map perl/LinkedSpec/Compiler.pm`
- "what must every shipped .spec satisfy" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "what owns compiled_rule_order and redefined_rule_labels" -> [compilerstate-internal-model](docs/knowledge/compilerstate-internal-model.md) · 2026-06-12 · reverify: `test -f perl/LinkedSpec/CompilerState.pm && grep -l CompilerState perl/LinkedSpec/Compiler.pm perl/LinkedSpec/Validation.pm`
- "what owns parser-source chunk capture" -> [runtimecontext-boundary](docs/knowledge/runtimecontext-boundary.md) · 2026-06-12 · reverify: `grep -l 'RuntimeContext' perl/LinkedSpec/*.pm perl/LinkedSpec/RuleIR/*.pm | wc -l`
- "what rule label should I use for blind-call" -> [blind-call-rule-label-contract](docs/knowledge/blind-call-rule-label-contract.md) · 2026-06-12 · reverify: `grep -n 'blind.call.*mode.driven' ROADMAP_V2.md`
- "what sets ctx.capture_start in the Rust runtime" -> [rust-anonymous-capture-slice-family](docs/knowledge/rust-anonymous-capture-slice-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_slice\"\\|\"capture_slice_until_cursor\"\\|\"capture_take\"\\|\"capture_rest\"\\|\"capture_take_rest\"' linkedspec-runtime/src/engine.rs | head`
- "what shape does a blind-call collection return in linkedspec" -> [blind-call-collection-shape](docs/knowledge/blind-call-collection-shape.md) · 2026-06-21 · reverify: `perl -Iperl -MLinkedSpec -e 'my $s=qq{Choice::OR+\\n => First\\n => Second\\n\\nFirst:\\n /a/ -> First { return(1) }\\n\\nSecond:\\n /b/ -> Second { return(1) }\\n}; my $p=LinkedSpec::Get(\\$s); my $in=q{ab}; use Data::Dumper; print Dumper($p->(\\$in))'`
- "what was decided about function composability" -> [spec-format-brainstorm-rounds-1-3](docs/knowledge/spec-format-brainstorm-rounds-1-3.md) · 2026-06-15 · reverify: `cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md`
- "what would it take to port LinkedSpec to another language" -> [specentry-backend-portability-ceiling](docs/knowledge/specentry-backend-portability-ceiling.md) · 2026-06-12 · reverify: `grep -n 'backend-portability ceiling\|eval' ARCHITECTURE_STATE.md | head -3`
- "where are ActionIR owner packages registered" -> [emitcontext-owner-registry](docs/knowledge/emitcontext-owner-registry.md) · 2026-06-12 · reverify: `grep -c '_actionir_owner_package\|owner_pkgs' perl/LinkedSpec/RuleIR/EmitContext.pm`
- "where did LinkedSpec::ActionRewriter go" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "where did call_spec_handler_subst / rewrite_action_code_for_compat move" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "where do new scanner rules go" -> [scanner-rule-family-architecture](docs/knowledge/scanner-rule-family-architecture.md) · 2026-06-12 · reverify: `ls perl/LinkedSpec/ActionIR/Scanner/*.pm`
- "where does build_dep_map live" -> [ownerdispatch-shared-seam](docs/knowledge/ownerdispatch-shared-seam.md) · 2026-06-12 · reverify: `grep -l 'OwnerDispatch' perl/LinkedSpec/*.pm perl/LinkedSpec/ActionIR/*.pm | wc -l`
- "where does capture_from stop in the Rust runtime" -> [rust-mark-based-capture-family](docs/knowledge/rust-mark-based-capture-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_from\"\\|\"capture_len_from\"\\|\"capture_between\"\\|\"mark_copy\"\\|fn span_text' linkedspec-runtime/src/engine.rs | head`
- "where does capture_slice stop in the Rust runtime" -> [rust-anonymous-capture-slice-family](docs/knowledge/rust-anonymous-capture-slice-family.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_slice\"\\|\"capture_slice_until_cursor\"\\|\"capture_take\"\\|\"capture_rest\"\\|\"capture_take_rest\"' linkedspec-runtime/src/engine.rs | head`
- "where does last_error live" -> [runtimecontext-boundary](docs/knowledge/runtimecontext-boundary.md) · 2026-06-12 · reverify: `grep -l 'RuntimeContext' perl/LinkedSpec/*.pm perl/LinkedSpec/RuleIR/*.pm | wc -l`
- "where does log_output go" -> [trace-verbosity-and-formatting](docs/knowledge/trace-verbosity-and-formatting.md) · 2026-06-12 · reverify: `grep -n 'DUMP_NONE\|DUMP_DEBUG\|configure_trace' perl/LinkedSpec.pm`
- "where does migration-summary shaping live" -> [compilerstate-internal-model](docs/knowledge/compilerstate-internal-model.md) · 2026-06-12 · reverify: `test -f perl/LinkedSpec/CompilerState.pm && grep -l CompilerState perl/LinkedSpec/Compiler.pm perl/LinkedSpec/Validation.pm`
- "where does the memory-arch and knowledge-map check run" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "where does the real implementation live in linkedspec" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "where is compiled-spec state defined" -> [compilerstate-internal-model](docs/knowledge/compilerstate-internal-model.md) · 2026-06-12 · reverify: `test -f perl/LinkedSpec/CompilerState.pm && grep -l CompilerState perl/LinkedSpec/Compiler.pm perl/LinkedSpec/Validation.pm`
- "where is the LinkedSpec language defined in LinkedSpec itself" -> [spec-spec-self-hosted-grammar](docs/knowledge/spec-spec-self-hosted-grammar.md) · 2026-06-05 · reverify: `ls specs/spec.spec`
- "where is the catastrophic regex that hangs phase0" -> [rtlutils-regex-hang](docs/knowledge/rtlutils-regex-hang.md) · 2026-06-18 · reverify: `! test -e perl/RTLUtils.pm && ! test -e perl/FSMGen.pm && echo 'subsystem retired (LEGACY-VHDL-RETIRE)'   # back-half hang persists: HTML::PathLinks::link_path_tokens (subtest 131) until its own fix track`
- "where is the cross-variant test corpus" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "where is the helper-rewrite compatibility entrypoint now" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "where is the top-level parser input-boundary validation regression" -> [runtime-input-boundary-validation-regression](docs/knowledge/runtime-input-boundary-validation-regression.md) · 2026-06-19 · reverify: `perl -Iperl -e 'require LinkedSpec; my $s=\"Top:: /foo/ -> Top { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},runtime_ctx_ref=>\\%c); my @bad=(1,2); my $r=eval { $p->(\\@bad) }; print qq{err=$@\\n}; print q{last_error=}, ($c{last_error}{detail}//q{<none>}), qq{\\n}'  # now: err + last_error = 'Top-level parser expects a SCALAR reference input; got ARRAY'`
- "which grammar actually parses .spec files" -> [bootstrapspec-vs-spec-spec-dual-path](docs/knowledge/bootstrapspec-vs-spec-spec-dual-path.md) · 2026-06-13 · reverify: `grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm`
- "why can't LinkedSpec target non-Perl backends" -> [specentry-backend-portability-ceiling](docs/knowledge/specentry-backend-portability-ceiling.md) · 2026-06-12 · reverify: `grep -n 'backend-portability ceiling\|eval' ARCHITECTURE_STATE.md | head -3`
- "why did entry_text and match_text return the same value in the Rust runtime" -> [rust-entry-match-separation](docs/knowledge/rust-entry-match-separation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'SavedMatchState\\|entry_groups\\|match_groups' linkedspec-runtime/src/engine.rs | head`
- "why did phase0 fail on my new spec" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "why did scalar(retv) resolve to undef in the Rust runtime" -> [rust-retv-propagation](docs/knowledge/rust-retv-propagation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- "why did spec.spec hang while parsing" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "why did substr panic on multibyte UTF-8 input in the Rust runtime" -> [rust-char-based-offsets](docs/knowledge/rust-char-based-offsets.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'byte_to_char_offset\\|char_substr\\|match_start_byte' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs | head`
- "why do capture/mark/cursor/entry helpers return undef or empty []" -> [and-return-edge-codegen-defect](docs/knowledge/and-return-edge-codegen-defect.md) · 2026-06-19 · reverify: `perl -Iperl -e 'require LinkedSpec; my $s=\"Top::AND\\n /a/\\n /b/\\n -> Top[0] { assign(scalar(x), 1) }\\n -> Top[1] { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},parse_mode=>q{consume},runtime_ctx_ref=>\\%c); my $in=q{ab}; my $a=$p->(\\$in); print defined($a)?qq{ast def (FIXED)\\n}:qq{ast UNDEF (defect present)\\n}'  # now prints 'ast def (FIXED)'`
- "why do method_like phase0 tests asserting RETURN_A fail" -> [actionir-return-node-retired-to-return](docs/knowledge/actionir-return-node-retired-to-return.md) · 2026-06-21 · reverify: `perl -Iperl -e 'use LinkedSpec; my $s=qq{Top::&\\nI { return_undef() }\\n /a/ -> Top { return(1) }\\n}; my $d=LinkedSpec::Get(\\$s,return_descriptor=>1); use Data::Dumper; print Dumper($d->{spec}{Top}{meta}{action_rewriter}{canonical_action_ir_nodes})'`
- "why do phase0 tests expect [1,1] instead of [['?First:',[]],['?Second:',[]]]" -> [blind-call-collection-shape](docs/knowledge/blind-call-collection-shape.md) · 2026-06-21 · reverify: `perl -Iperl -MLinkedSpec -e 'my $s=qq{Choice::OR+\\n => First\\n => Second\\n\\nFirst:\\n /a/ -> First { return(1) }\\n\\nSecond:\\n /b/ -> Second { return(1) }\\n}; my $p=LinkedSpec::Get(\\$s); my $in=q{ab}; use Data::Dumper; print Dumper($p->(\\$in))'`
- "why do return_a return_m return_ma return_imatch still exist" -> [medium-term-alias-retirement-deferred](docs/knowledge/medium-term-alias-retirement-deferred.md) · 2026-06-12 · reverify: `grep -c 'return_a(' t/phase0_regression.t`
- "why do retv-based inline grammars diverge between Perl and Rust" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "why does an AND rule with a return edge fail to compile" -> [and-return-edge-codegen-defect](docs/knowledge/and-return-edge-codegen-defect.md) · 2026-06-19 · reverify: `perl -Iperl -e 'require LinkedSpec; my $s=\"Top::AND\\n /a/\\n /b/\\n -> Top[0] { assign(scalar(x), 1) }\\n -> Top[1] { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},parse_mode=>q{consume},runtime_ctx_ref=>\\%c); my $in=q{ab}; my $a=$p->(\\$in); print defined($a)?qq{ast def (FIXED)\\n}:qq{ast UNDEF (defect present)\\n}'  # now prints 'ast def (FIXED)'`
- "why does get_parser runtime_ctx_ref not record invalid input ref" -> [runtime-input-boundary-validation-regression](docs/knowledge/runtime-input-boundary-validation-regression.md) · 2026-06-19 · reverify: `perl -Iperl -e 'require LinkedSpec; my $s=\"Top:: /foo/ -> Top { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},runtime_ctx_ref=>\\%c); my @bad=(1,2); my $r=eval { $p->(\\@bad) }; print qq{err=$@\\n}; print q{last_error=}, ($c{last_error}{detail}//q{<none>}), qq{\\n}'  # now: err + last_error = 'Top-level parser expects a SCALAR reference input; got ARRAY'`
- "why does multi_rule_parsers return [] instead of the action payload" -> [and-return-edge-codegen-defect](docs/knowledge/and-return-edge-codegen-defect.md) · 2026-06-19 · reverify: `perl -Iperl -e 'require LinkedSpec; my $s=\"Top::AND\\n /a/\\n /b/\\n -> Top[0] { assign(scalar(x), 1) }\\n -> Top[1] { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},parse_mode=>q{consume},runtime_ctx_ref=>\\%c); my $in=q{ab}; my $a=$p->(\\$in); print defined($a)?qq{ast def (FIXED)\\n}:qq{ast UNDEF (defect present)\\n}'  # now prints 'ast def (FIXED)'`
- "why does parser_invalid_input die with a raw 'Not a SCALAR reference' error" -> [runtime-input-boundary-validation-regression](docs/knowledge/runtime-input-boundary-validation-regression.md) · 2026-06-19 · reverify: `perl -Iperl -e 'require LinkedSpec; my $s=\"Top:: /foo/ -> Top { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},runtime_ctx_ref=>\\%c); my @bad=(1,2); my $r=eval { $p->(\\@bad) }; print qq{err=$@\\n}; print q{last_error=}, ($c{last_error}{detail}//q{<none>}), qq{\\n}'  # now: err + last_error = 'Top-level parser expects a SCALAR reference input; got ARRAY'`
- "why does t/phase0_regression.t hang" -> [rtlutils-regex-hang](docs/knowledge/rtlutils-regex-hang.md) · 2026-06-18 · reverify: `! test -e perl/RTLUtils.pm && ! test -e perl/FSMGen.pm && echo 'subsystem retired (LEGACY-VHDL-RETIRE)'   # back-half hang persists: HTML::PathLinks::link_path_tokens (subtest 131) until its own fix track`
- "why does tclite return [] in the Rust engine" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "why does tclite still return [] after the header-line-regex fix" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "why does the Rust engine output wrap the Perl reference value one level" -> [rust-perl-output-oracle](docs/knowledge/rust-perl-output-oracle.md) · 2026-06-17 · reverify: `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- "why does the Rust validator reject undefined rule references by default" -> [rust-strict-syntax-validation](docs/knowledge/rust-strict-syntax-validation.md) · 2026-06-16 · reverify: `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'fn validate_with_options\\|fn check_unused_rules\\|strict_syntax' linkedspec-core/src/validation.rs`
- "why does the generated parser hang on an AND+ rule with LX" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "why is .github/workflows/ci.yml guarded off (workflow_dispatch / if false)" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "why is LinkedSpec.pm so small" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "why is flat added to the Rust engine but not flatten" -> [rust-retired-array-aliases-not-added](docs/knowledge/rust-retired-array-aliases-not-added.md) · 2026-06-16 · reverify: `grep -c '\"flat\" =>' rust/linkedspec-runtime/src/engine.rs; grep -cE '\"tail\"|\"drop_last\"|\"flatten\"|\"array_values\"' rust/linkedspec-runtime/src/engine.rs`
- "why is runtime_ctx last_error empty on invalid input ref" -> [runtime-input-boundary-validation-regression](docs/knowledge/runtime-input-boundary-validation-regression.md) · 2026-06-19 · reverify: `perl -Iperl -e 'require LinkedSpec; my $s=\"Top:: /foo/ -> Top { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},runtime_ctx_ref=>\\%c); my @bad=(1,2); my $r=eval { $p->(\\@bad) }; print qq{err=$@\\n}; print q{last_error=}, ($c{last_error}{detail}//q{<none>}), qq{\\n}'  # now: err + last_error = 'Top-level parser expects a SCALAR reference input; got ARRAY'`
- "why is the test file so large" -> [phase0-regression-structure](docs/knowledge/phase0-regression-structure.md) · 2026-06-12 · reverify: `wc -l t/phase0_regression.t`
- "why must I not put a regex on the top rule" -> [spec-top-rule-no-regex-two-rule-minimum](docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md) · 2026-06-17 · reverify: `perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=\"demo_top::  -> word_pair  .push\\nLX {return(array_copy(a(demo_top)))}\\n\\nword_pair : /(\\\\w+) (\\\\w+)/  I.return(concat(entry_group(0), \\\"-\\\", entry_group(1)))\\n\"; my $p=LinkedSpec::Get(\\$s); print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\\"hello world\\\")),\"\\n\"'  # => [\"hello-world\"]`

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

### actionir-return-node-retired-to-return
_The canonical action-IR return node is RETURN; RETURN_A/RETURN_M and the return_a/return_m/return_array helpers are retired (→ RAW_PERL fallback)_

- **answers:** what canonical action-IR node does a return lower to in linkedspec | is there still a RETURN_A or RETURN_M canonical action-IR node | what happened to return_a / return_m / return_ma / return_imatch / return_im / return_array | why do method_like phase0 tests asserting RETURN_A fail | what is the canonical replacement for the retired return_* helpers
- **date:** 2026-06-21 · **status:** current
- **evidence:** `probe: a lifecycle/action spec with return(1)/return_undef() yields canonical_action_ir_nodes containing 'RETURN' (hits RETURN=>4), never 'RETURN_A'; a `.return_a().return_m()` chain lowers to canonical_action_ir_nodes ['RAW_PERL'] with fallback_count=2 and ACODE undef; call_spec_handler_subst('Top','return_array(...)'/'return_a()'/'return_m()') returns the input unchanged (unrecognized)`
- **reverify:** `perl -Iperl -e 'use LinkedSpec; my $s=qq{Top::&\\nI { return_undef() }\\n /a/ -> Top { return(1) }\\n}; my $d=LinkedSpec::Get(\\$s,return_descriptor=>1); use Data::Dumper; print Dumper($d->{spec}{Top}{meta}{action_rewriter}{canonical_action_ir_nodes})'`
- **source:** [`docs/knowledge/actionir-return-node-retired-to-return.md`](docs/knowledge/actionir-return-node-retired-to-return.md)

### actionrewriter-removed-phase1
_ActionRewriter.pm was deleted in Phase 1; the helper-rewrite compat entrypoint is now in RuleIR::EmitContext_

- **answers:** does perl/LinkedSpec/ActionRewriter.pm still exist | where did LinkedSpec::ActionRewriter go | where is the helper-rewrite compatibility entrypoint now | where did call_spec_handler_subst / rewrite_action_code_for_compat move | is ActionRewriter a live module in linkedspec
- **date:** 2026-06-05 · **status:** current
- **evidence:** `commit 4f8e0b6 (PHASE1-PARSER-CORE-ISOLATION.2) deleted the 118-line forwarding shim; zero references remain under perl/`
- **reverify:** `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- **source:** [`docs/knowledge/actionrewriter-removed-phase1.md`](docs/knowledge/actionrewriter-removed-phase1.md)

### and-return-edge-codegen-defect
_An AND rule with multiple indexed edges and a return(...) edge emits invalid handler Perl (SCALAR(0x…)Rule) — real codegen defect, not stale tests_

- **answers:** why does an AND rule with a return edge fail to compile | what is the SCALAR(0x...)Top / near \")Top\" codegen error | why do capture/mark/cursor/entry helpers return undef or empty [] | why does multi_rule_parsers return [] instead of the action payload | are the phase0 capture/mark back-half failures stale or real | Bareword found where operator expected at LinkedSpec::generated_handler AND_ACODE
- **date:** 2026-06-19 · **status:** resolved
- **evidence:** `PHASE0-BACKHALF-TRIAGE.1 (2026-06-19): 63 of 173 back-half failures; bisection V1–V4 + dumped generated source. FIXED by PHASE0-BACKHALF-TRIAGE.3 (2026-06-21): full phase0 dropped 173→111 failing (62 cleared, all cluster-D + named-G AND-codegen tests now pass; zero regressions).`
- **reverify:** `perl -Iperl -e 'require LinkedSpec; my $s=\"Top::AND\\n /a/\\n /b/\\n -> Top[0] { assign(scalar(x), 1) }\\n -> Top[1] { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},parse_mode=>q{consume},runtime_ctx_ref=>\\%c); my $in=q{ab}; my $a=$p->(\\$in); print defined($a)?qq{ast def (FIXED)\\n}:qq{ast UNDEF (defect present)\\n}'  # now prints 'ast def (FIXED)'`
- **source:** [`docs/knowledge/and-return-edge-codegen-defect.md`](docs/knowledge/and-return-edge-codegen-defect.md)

### andplusplus-lx-parser-hang
_GOTCHA — an LX lifecycle marker on an AND+ rule hangs the generated parser (loop re-entry)_

- **answers:** why does the generated parser hang on an AND+ rule with LX | why did spec.spec hang while parsing | what is the AND++LX hang | is it safe to use LX on a repeated (AND+) rule | parser infinite loop with Late Exit lifecycle marker
- **date:** 2026-06-05 · **status:** current
- **evidence:** `docs/tasks/PHASE7-SELF-HOSTED-SPEC.md (PHASE7-SELF-HOSTED-SPEC.4): spec_file::AND+ with LX hung; fixed by replacing LX with E`
- **reverify:** `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- **source:** [`docs/knowledge/andplusplus-lx-parser-hang.md`](docs/knowledge/andplusplus-lx-parser-hang.md)

### blind-call-collection-shape
_A blind-call / repeated-rule collection surfaces each child's own return value (e.g. [1,1]); the auto-tag ['?Rule:',[]] shape is retired_

- **answers:** what shape does a blind-call collection return in linkedspec | does => child wrap each child result in a tag like ['?Rule:',[]] | what is the AND / OR / AND+ blind-call output shape | why do phase0 tests expect [1,1] instead of [['?First:',[]],['?Second:',[]]] | what does a repeated AND group return
- **date:** 2026-06-21 · **status:** current
- **evidence:** `cluster-A repro: Choice::OR+/::AND/::|/AND+/AND{N,M} with children '/a/ -> First { return(1) }' return [1,1] / 1 / [[1,1],...]; t/phase0_regression.t subtests 144/149/152/153/156/163/166 re-blessed in PHASE0-BACKHALF-TRIAGE.2.1`
- **reverify:** `perl -Iperl -MLinkedSpec -e 'my $s=qq{Choice::OR+\\n => First\\n => Second\\n\\nFirst:\\n /a/ -> First { return(1) }\\n\\nSecond:\\n /b/ -> Second { return(1) }\\n}; my $p=LinkedSpec::Get(\\$s); my $in=q{ab}; use Data::Dumper; print Dumper($p->(\\$in))'`
- **source:** [`docs/knowledge/blind-call-collection-shape.md`](docs/knowledge/blind-call-collection-shape.md)

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

### rtlutils-regex-hang
_The phase0 hang is a catastrophic regex in the Perl-only legacy VHDL subsystem (RTLUtils/FSMGen/VHDL::ConstantEval) — self-contained, zero core dependency, slated for retirement_

- **answers:** what is RTLUTILS-REGEX-HANG | why does t/phase0_regression.t hang | where is the catastrophic regex that hangs phase0 | does the .spec parser/compiler/runtime core depend on RTLUtils or FSMGen or VHDL::ConstantEval | what depends on RTLUtils FSMGen VHDL::ConstantEval | should I fix the RTLUtils regex hang or retire the subsystem | what blocks the SPEC-FORMAT-TERSE implementation leaves | how big is the legacy VHDL/RTL/FSM generation subsystem
- **date:** 2026-06-18 · **status:** accepted
- **evidence:** `git grep sweep + module inspection + pristine-HEAD worktree run 2026-06-18 (LEGACY-VHDL-RETIRE.1/.2/.3). Hang confirmed at the add_header smoke (subtest 110); subsystem retired; a second pre-existing back-half hang (HTML::PathLinks::link_path_tokens, subtest 131) found.`
- **reverify:** `! test -e perl/RTLUtils.pm && ! test -e perl/FSMGen.pm && echo 'subsystem retired (LEGACY-VHDL-RETIRE)'   # back-half hang persists: HTML::PathLinks::link_path_tokens (subtest 131) until its own fix track`
- **source:** [`docs/knowledge/rtlutils-regex-hang.md`](docs/knowledge/rtlutils-regex-hang.md)

### runtime-input-boundary-validation-regression
_The Runtime.pm comment-skip wrapper derefs input before the SCALAR-ref guard, so invalid top-level parser input dies with a raw error instead of the friendly boundary message_

- **answers:** why does parser_invalid_input die with a raw 'Not a SCALAR reference' error | why is runtime_ctx last_error empty on invalid input ref | where is the top-level parser input-boundary validation regression | why does get_parser runtime_ctx_ref not record invalid input ref
- **date:** 2026-06-19 · **status:** resolved
- **evidence:** `PHASE0-BACKHALF-TRIAGE.1 (2026-06-19): 2 of 173 back-half failures; agent-identified Runtime.pm:~126 + commit d7294d0. FIXED by PHASE0-BACKHALF-TRIAGE.4 (2026-06-21): wrapper now gates its pos()/skip block behind `ref($input_ref) eq 'SCALAR'` and always delegates to the inner parser; invalid input now yields the friendly boundary error + populated last_error.`
- **reverify:** `perl -Iperl -e 'require LinkedSpec; my $s=\"Top:: /foo/ -> Top { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},runtime_ctx_ref=>\\%c); my @bad=(1,2); my $r=eval { $p->(\\@bad) }; print qq{err=$@\\n}; print q{last_error=}, ($c{last_error}{detail}//q{<none>}), qq{\\n}'  # now: err + last_error = 'Top-level parser expects a SCALAR reference input; got ARRAY'`
- **source:** [`docs/knowledge/runtime-input-boundary-validation-regression.md`](docs/knowledge/runtime-input-boundary-validation-regression.md)

### runtimecontext-boundary
_RuntimeContext is one of the cleanest architectural boundaries; owns shared runtime state, structured error payloads, and handler attribution_

- **answers:** what is RuntimeContext and why is it important | where does last_error live | how does top_rule flow through the compile pipeline | what owns parser-source chunk capture | how does RuntimeContext anchor chdir-safety for runtime state
- **date:** 2026-06-12 · **status:** current
- **evidence:** `perl/LinkedSpec/RuntimeContext.pm; spent by Runtime, ParserFactory, Compiler, SpecEntry; ARCHITECTURE_STATE.md calls it 'one of the cleanest and highest-value seams in the project'`
- **reverify:** `grep -l 'RuntimeContext' perl/LinkedSpec/*.pm perl/LinkedSpec/RuleIR/*.pm | wc -l`
- **source:** [`docs/knowledge/runtimecontext-boundary.md`](docs/knowledge/runtimecontext-boundary.md)

### rust-anonymous-capture-slice-family
_Rust engine implements the full anonymous capture-slice family (capture_slice/_len, capture_slice_until_cursor/_len, capture_take/_len, capture_take_until_cursor/_len, capture_rest/_len, capture_take_rest/_len) on the anonymous capture cursor (ctx.capture_start = Perl $IPOS); capture_slice/capture_slice_len now end at the START of the current match, not the cursor_

- **answers:** does capture_slice read to the start or the end of the match in the Rust engine | where does capture_slice stop in the Rust runtime | how does the Rust engine implement capture_slice_until_cursor / capture_take / capture_rest | what is the anonymous capture cursor in the Rust engine | do the anonymous capture_take_* helpers advance the capture cursor in the Rust engine | how does capture_take differ from capture_take_until_cursor in the Rust engine | what sets ctx.capture_start in the Rust runtime | how does the anonymous capture-slice family work in the Rust engine
- **date:** 2026-06-16 · **status:** confirmed
- **evidence:** `RUST-PARITY.5.5.4 (2026-06-16): rust/linkedspec-runtime/src/engine.rs call_helper arms for capture_slice (fixed), capture_slice_len (fixed), capture_slice_until_cursor(+_len), capture_take(+_len), capture_take_until_cursor(+_len), capture_rest(+_len), capture_take_rest(+_len); reuses span_text/span_char_len. Authoritative contract: perl/LinkedSpec/ActionIR/Contracts.pm ~366-656. 233/233 tests green (223 baseline + 10 helpers_5_5_4_*).`
- **reverify:** `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_slice\"\\|\"capture_slice_until_cursor\"\\|\"capture_take\"\\|\"capture_rest\"\\|\"capture_take_rest\"' linkedspec-runtime/src/engine.rs | head`
- **source:** [`docs/knowledge/rust-anonymous-capture-slice-family.md`](docs/knowledge/rust-anonymous-capture-slice-family.md)

### rust-char-based-offsets
_Rust engine keeps internal positions as byte offsets but exposes char offsets to the DSL (Perl parity); substr/input_slice char-slice, cursor/match/entry positions and lengths convert via byte_to_char_offset_

- **answers:** does the Rust engine use byte or char offsets | why did substr panic on multibyte UTF-8 input in the Rust runtime | are cursor_pos / match_start_pos / length char-based or byte-based in Rust | how does the Rust engine convert between byte and char offsets | is match_start_pos / entry_start_pos implemented in the Rust runtime | how does Rust match Perl's char-based positions
- **date:** 2026-06-16 · **status:** confirmed
- **evidence:** `RUST-PARITY.5.3 (2026-06-16): rust/linkedspec-runtime/src/engine.rs byte_to_char_offset/char_substr + substr/input_slice/cursor_*/capture_*/mark_pos/entry_*/match_*/length helpers; rust/linkedspec-runtime/src/runtime.rs entry_*/match_*_byte span fields. 196/196 tests green (189 baseline + 7 chars_5_3_*).`
- **reverify:** `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'byte_to_char_offset\\|char_substr\\|match_start_byte' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs | head`
- **source:** [`docs/knowledge/rust-char-based-offsets.md`](docs/knowledge/rust-char-based-offsets.md)

### rust-edge-semantics-bug
_Rust -> edge dispatch is broken — associates edges with parent regexes instead of building dependency_regex_map from child rule regexes like Perl_

- **answers:** how does -> edge dispatch work in Perl | what is wrong with the Rust -> edge implementation | how should the Rust compiler build regex alternations | what is dependency_regex_map
- **date:** 2026-06-15 · **status:** confirmed
- **evidence:** `Full Perl pipeline analysis 2026-06-15: BootstrapSpec::Core.pm, Compiler.pm build_dependency_regex_map, HandlerVariantEmitter.pm _linkedre_or_expr and _emit_default_handler. Rust compiler.rs associates edges with current_regex_idx-1 (parent regexes) instead of building alternation from child regexes.`
- **reverify:** `cd rust && cargo test; grep -n dependency_regex_map perl/LinkedSpec/Compiler.pm`
- **source:** [`docs/knowledge/rust-edge-semantics-bug.md`](docs/knowledge/rust-edge-semantics-bug.md)

### rust-entry-match-separation
_Rust engine separates entry_* (the dispatcher's match) from match_* (the rule's own match) by emulating Perl's per-handler IMATCH/LMATCH lexicals with save/restore on the shared RuntimeContext_

- **answers:** how does the Rust engine separate entry_* from match_* | what is the difference between entry_* and match_* in the Rust runtime | does a child rule's match clobber the parent's match in Rust | what is the entry match for a dispatched child rule in Rust | why did entry_text and match_text return the same value in the Rust runtime | how does the Rust engine emulate Perl IMATCH and LMATCH
- **date:** 2026-06-16 · **status:** confirmed
- **evidence:** `RUST-PARITY.5.2 (2026-06-16): rust/linkedspec-runtime/src/engine.rs execute_rule SavedMatchState save/restore + match-set seed. Matches Perl source: SpecEntry::_build_handler_preamble (IMATCH=$$info{match}), HandlerVariantEmitter::_build_lmatch_extraction (LMATCH=$$minfo{match}), MethodLowering.pm:332 (child invoked with parent $minfo as $info). 189/189 tests green (186 baseline + 3 match_5_2_*).`
- **reverify:** `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'SavedMatchState\\|entry_groups\\|match_groups' linkedspec-runtime/src/engine.rs | head`
- **source:** [`docs/knowledge/rust-entry-match-separation.md`](docs/knowledge/rust-entry-match-separation.md)

### rust-mark-based-capture-family
_Rust engine implements the mark-based capture family (capture_*_from / capture_between / mark_copy / mark_input_*) with Perl parity; the non-cursor readers (capture_from/capture_len_from/capture_take_len_from) end at the START of the current match, not the cursor_

- **answers:** does capture_from read to the start or the end of the match in the Rust engine | where does capture_from stop in the Rust runtime | how does the Rust engine implement capture_len_from / capture_until_cursor_from / capture_rest_from | what are the endpoints of the mark-based capture readers | do capture_take_* helpers advance the mark in the Rust engine | is mark_copy one argument or two arguments | what does mark_input_start / mark_input_end store in the Rust engine | how does the mark-based capture family work in the Rust engine
- **date:** 2026-06-16 · **status:** confirmed
- **evidence:** `RUST-PARITY.5.5.3 (2026-06-16): rust/linkedspec-runtime/src/engine.rs call_helper arms for capture_from (fixed), capture_len_from, capture_until_cursor_from(+_len), capture_take_until_cursor_from(+_len), capture_take_len_from, capture_rest_from(+_len), capture_take_rest_from(+_len), capture_between, capture_len_between, mark_input_start, mark_input_end, mark_copy; span_text/span_char_len helpers. Authoritative contract: perl/LinkedSpec/ActionIR/Contracts.pm ~690-1047. 223/223 tests green (207 baseline + 16 helpers_5_5_3_*).`
- **reverify:** `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_from\"\\|\"capture_len_from\"\\|\"capture_between\"\\|\"mark_copy\"\\|fn span_text' linkedspec-runtime/src/engine.rs | head`
- **source:** [`docs/knowledge/rust-mark-based-capture-family.md`](docs/knowledge/rust-mark-based-capture-family.md)

### rust-perl-output-oracle
_The Perl↔Rust output oracle — a timeout-guarded Perl generator (tools/gen_oracle_corpus.pl) emits canonical-JSON fixtures into rust/linkedspec-runtime/tests/corpus/, and a Rust fixture-runner (tests/corpus_oracle.rs) asserts engine.execute(input) == [reference]; the Rust engine wraps the Perl top-rule value one level_

- **answers:** what is the Perl↔Rust output oracle | how does the Rust variant test output parity against the Perl reference | where is the cross-variant test corpus | how do I regenerate the oracle corpus fixtures | why does the Rust engine output wrap the Perl reference value one level | does the Rust engine reproduce tclite or Lispish output yet | why does tclite return [] in the Rust engine | what is the single-regex rule 0-regex compiler gap in the Rust variant | do single-colon name : /re/ rules work in the Rust compiler | why do retv-based inline grammars diverge between Perl and Rust | why does tclite still return [] after the header-line-regex fix | how does the Rust parser handle .push / .return on action edges | are action-edge fluent continuations lowered in the Rust variant | does a regex on a rule header line register in the Rust parser
- **date:** 2026-06-17 · **status:** confirmed
- **evidence:** `RUST-PARITY.7.1 (2026-06-17): tools/gen_oracle_corpus.pl (Perl, alarm-timeout-guarded, JSON::PP->canonical(1)) emits tests/corpus/<case>/{input.spec,input.txt,expected.json}; rust/linkedspec-runtime/tests/corpus_oracle.rs enumerates them and asserts engine.execute(input) == json!([expected]). Proven green on 2 authored grammars (scalar + nested-array). RUST-PARITY.7.5.1 (2026-06-17): fixed the header-line-regex bug (parser.rs:86 (\\S*)->([^\\s/]*)) so header-line regexes register and bracket pairs resolve open[0]/close[1] (4 unit tests; cargo test 242 passed). But the oracle proved this NECESSARY-NOT-SUFFICIENT for tclite: it still returns [] because action-edge fluent continuations (-> command_subst .push / .return(...)) are dropped — the parser attaches .method chains only to blind (=>) edges, so the compiler discards them after a -> edge (compiler.rs:171). That second blocker is RUST-PARITY.7.5.3. Lispish (uses { } blocks) needs only .7.5.1 + .7.5.2 (scalaref).`
- **reverify:** `cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus`
- **source:** [`docs/knowledge/rust-perl-output-oracle.md`](docs/knowledge/rust-perl-output-oracle.md)

### rust-retired-array-aliases-not-added
_The retired aliases tail/drop_last/flatten/array_values are NOT added to the Rust backend — parity means matching the Perl reference's recognized helper surface, and the reference no longer recognizes them_

- **answers:** should the Rust backend implement tail drop_last flatten array_values | does the Perl reference recognize tail drop_last flatten array_values | are tail drop_last flatten array_values recognized helpers | why is flat added to the Rust engine but not flatten | should a new backend implement the retired compatibility aliases | what does input_end_line and input_end_col compute in the Rust engine
- **date:** 2026-06-16 · **status:** current
- **evidence:** `RUST-PARITY.5.5.2 (2026-06-16): tail/drop_last/flatten/array_values absent from Perl helper-recognition regexes (BootstrapSpec/Core.pm:82, FlowExpr.pm:81,270, MethodLowering.pm:1627,1635), unused in 20 shipped specs, 0 phase0 locks; retired in COMPAT-ALIAS-RETIREMENT.1. Rust engine.rs adds only canonical flat + input_end_line/input_end_col.`
- **reverify:** `grep -c '\"flat\" =>' rust/linkedspec-runtime/src/engine.rs; grep -cE '\"tail\"|\"drop_last\"|\"flatten\"|\"array_values\"' rust/linkedspec-runtime/src/engine.rs`
- **source:** [`docs/knowledge/rust-retired-array-aliases-not-added.md`](docs/knowledge/rust-retired-array-aliases-not-added.md)

### rust-retv-propagation
_Rust engine propagates child-return (retv) via a per-invocation return channel on RuntimeContext; execute_rule returns the rule's value and set_retv is called after -> / => dispatch_

- **answers:** how does the Rust engine propagate retv | how does a parent read a child rule's return value in Rust | why did scalar(retv) resolve to undef in the Rust runtime | what does execute_rule return in the Rust engine | how does return(expr) work in the Rust runtime vs the accumulator | how does call(child) resolve a rule name in Rust
- **date:** 2026-06-16 · **status:** confirmed
- **evidence:** `RUST-PARITY.5.1 (2026-06-16): rust/linkedspec-runtime/src/engine.rs execute_rule + acode/bcode dispatch + return/call helpers; rust/linkedspec-runtime/src/runtime.rs return_value channel + set_retv. Matches book appendix/runtime-semantics.md §3.3/§5.4/§6.1. 186/186 tests green.`
- **reverify:** `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs`
- **source:** [`docs/knowledge/rust-retv-propagation.md`](docs/knowledge/rust-retv-propagation.md)

### rust-strict-syntax-validation
_The Rust variant has a strict_syntax validation mode (validate_with_options(spec, strict_syntax)); strict promotes the unused-rule warning to a hard error (undefined refs are already fatal in every mode), and the top rule is NOT exempt from the unused check_

- **answers:** does the Rust variant have a strict_syntax validation mode | how do I run strict validation in the Rust variant | what does strict_syntax do in the Rust validator | is the top rule flagged as unused in strict mode | why does the Rust validator reject undefined rule references by default | what is the difference between validate and validate_with_options in Rust | does strict_syntax reject unused rules in the Rust variant
- **date:** 2026-06-16 · **status:** confirmed
- **evidence:** `RUST-PARITY.6 (2026-06-16): rust/linkedspec-core/src/validation.rs adds validate_with_options(spec, strict_syntax: bool) + check_unused_rules; validate(spec) = validate_with_options(spec, false). Perl reference: perl/LinkedSpec/Validation.pm validate_dsl_syntax(..., strict_syntax => 1), lines ~705-741. Semantics verified empirically (Top:: -> Child strict => 'Unused rule(s): Top'; Top:: -> Ghost strict => 'Undefined rule reference(s): Ghost'). 237/237 tests green (233 baseline + 4).`
- **reverify:** `cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'fn validate_with_options\\|fn check_unused_rules\\|strict_syntax' linkedspec-core/src/validation.rs`
- **source:** [`docs/knowledge/rust-strict-syntax-validation.md`](docs/knowledge/rust-strict-syntax-validation.md)

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

### spec-top-rule-no-regex-two-rule-minimum
_A .spec is written as a top (::) entry rule with NO regex (the _INITIAL dispatch loop) plus >=1 normal (:) rule that carries the regex(es); a well-formed spec needs >=2 rules. Never put a regex on the top rule._

- **answers:** how should I structure a valid .spec (top rule + normal rules) | should the top-level rule carry a regex | why must I not put a regex on the top rule | how many rules does a .spec need | how is the top-level rule handled in the engine | what does the :: vs : colon mean for a rule (top vs normal) | how do I write a minimal worked .spec example for the book | how does a normal rule surface a computed value to the parser output | entry_group vs match_group in a dispatched child rule
- **date:** 2026-06-17 · **status:** confirmed
- **evidence:** `Authoring doctrine (user-established + the whole shipped corpus): a .spec top (::) rule is the _INITIAL entry/dispatch loop and carries NO regex of its own; the regex(es) live on the normal (:) rules it dispatches to. All 20 shipped specs/*.spec are written this way (every top rule has no regex). A well-formed .spec therefore has >=2 rules: the :: entry rule + >=1 normal : rule. Basis: BootstrapSpec/Core.pm:417 (:: -> target _INITIAL), RuleIR.pm:193-195 (_INITIAL -> top_rule). Verified 2-rule worked-example idiom via LinkedSpec::Get: `demo::  -> value  .push` / `LX { return(array_copy(a(demo))) }` + `value : /(\\w+) (\\w+)/  I.return(concat(entry_group(0),\"-\",entry_group(1)))` on `hello world` => [\"hello-world\"] (output = top rule's one-element accumulator snapshot; the dispatched child reads entry_group(N), not match_group(N)). RETRACTION (2026-06-17): an earlier version of this card claimed a regex-on-top / single-rule spec 'silently returns []'. That mechanism claim was inaccurate and is withdrawn; the genuinely broken shape to avoid in examples is the explicit ::AND ... -> Rule[N] { return(...) } form (AND mode + slot index), which drops its edge return -> [] (the .10.1 AND_SINGLE_ACODE finding in HandlerVariantEmitter.pm). The doctrine stands on its own: write 2-rule, no regex on top -- do not reason about what a malformed regex-on-top spec returns.`
- **reverify:** `perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=\"demo_top::  -> word_pair  .push\\nLX {return(array_copy(a(demo_top)))}\\n\\nword_pair : /(\\\\w+) (\\\\w+)/  I.return(concat(entry_group(0), \\\"-\\\", entry_group(1)))\\n\"; my $p=LinkedSpec::Get(\\$s); print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\\"hello world\\\")),\"\\n\"'  # => [\"hello-world\"]`
- **source:** [`docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md`](docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md)

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
