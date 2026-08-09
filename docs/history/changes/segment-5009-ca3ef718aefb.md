- Result:
  - syntax OK
  - PASS (`Files=1, Tests=181`)
## 2026-03-11 - Phase 1A Slice: Lazy-Load `BootstrapSpec`, `SpecEntry`, and `Validation` Through `Compiler`
## Summary
Reduced internal compile-path load-time coupling again by making `LinkedSpec::Compiler` load `BootstrapSpec`, `SpecEntry`, and `Validation` only when `spec_descr(...)` or `run_get_pipeline(...)` actually needs them, so require-only consumers of `Compiler.pm` no longer import those owner modules up front.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored compiler owner loading:
  - removed eager `use LinkedSpec::BootstrapSpec ();`,
  - removed eager `use LinkedSpec::SpecEntry ();`,
  - removed eager `use LinkedSpec::Validation ();`,
  - added `LinkedSpec::Compiler::_require_pkg(...)`,
  - added owner helpers for default bootstrap-parse, spec-entry, and validation loading.
- Preserved behavior:
  - `LinkedSpec::Compiler::spec_descr(...)` still uses the same default `SpecEntry` owner path when no callback override is provided,
  - `LinkedSpec::Compiler::run_get_pipeline(...)` still uses the same default bootstrap parse and validation paths,
  - injected callbacks continue to work unchanged.
- Updated focused regression coverage:
  - added `compiler_require_avoids_owner_load_until_run_get_pipeline`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=180`)
## 2026-03-11 - Phase 1A Slice: Lazy-Load `Compiler` Through `Runtime`
## Summary
Reduced internal compile-path load-time coupling by making `LinkedSpec::Runtime` load `LinkedSpec::Compiler` only when `run_get(...)` actually runs, so require-only consumers of `Runtime.pm` no longer import the compiler pipeline up front.

## Changed Files
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored runtime owner loading:
  - removed the eager `use LinkedSpec::Compiler ();` import from `Runtime.pm`,
  - added `LinkedSpec::Runtime::_require_pkg(...)`,
  - updated `run_get(...)` to lazy-load `LinkedSpec::Compiler` unless `run_get_pipeline(...)` is already available.
- Preserved behavior:
  - `LinkedSpec::Runtime::run_get(...)` still returns runnable parser coderefs,
  - the compiler pipeline still initializes through `LinkedSpec::Compiler::run_get_pipeline(...)`,
  - façade and parser-factory callers now inherit the same narrower runtime load surface automatically.
- Updated focused regression coverage:
  - added `runtime_require_avoids_compiler_load_until_run_get`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=179`)
## 2026-03-11 - Phase 1A Slice: Lazy-Load `ParserFactory` and `PluginBridge` Through the Facade
## Summary
Reduced the remaining façade load-time coupling by making `LinkedSpec.pm` lazy-load `ParserFactory` and `PluginBridge` at `get_parser(...)` and `AUTOLOAD`, so plain `require LinkedSpec` no longer imports those owner modules up front.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored façade owner loading:
  - removed eager `use LinkedSpec::ParserFactory ();`,
  - removed eager `use LinkedSpec::PluginBridge ();`,
  - updated `LinkedSpec::get_parser(...)` to lazy-load `ParserFactory` unless `run_get_parser(...)` is already available,
  - updated `LinkedSpec::AUTOLOAD` to lazy-load `PluginBridge` unless `_dispatch_autoload(...)` is already available.
- Preserved behavior:
  - `get_parser(...)` still returns runnable parser coderefs,
  - `AUTOLOAD` still routes plugin calls through `LinkedSpec::PluginBridge`,
  - existing trap-based tests still work because the façade only lazy-loads when the owner symbol is not already present.
- Updated focused regression coverage:
  - added `linkedspec_require_avoids_parser_factory_load_until_get_parser`,
  - added `linkedspec_require_avoids_plugin_bridge_load_until_autoload`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=178`)
## 2026-03-11 - Phase 1A Slice: Lazy-Load Compile Pipeline Owners Through the Facade
## Summary
Reduced another large load-time coupling in `LinkedSpec.pm` by making the façade lazy-load `Runtime`, `Compiler`, and `ActionRewriter` on demand, instead of importing the compile pipeline and ActionIR stack eagerly on `require LinkedSpec`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored façade owner loading:
  - added `LinkedSpec::_require_pkg(...)`,
  - updated `LinkedSpec::Get(...)` to lazy-load `LinkedSpec::Runtime`,
  - updated `LinkedSpec::spec_descr(...)` to lazy-load `LinkedSpec::Compiler`,
  - updated `LinkedSpec::call_spec_handler_subst(...)` to lazy-load `LinkedSpec::ActionRewriter`.
- Reduced eager imports:
  - removed `use LinkedSpec::Runtime ();`,
  - removed `use LinkedSpec::Compiler ();`,
  - removed `use LinkedSpec::ActionRewriter ();` from `LinkedSpec.pm`.
- Preserved behavior:
  - `Get(...)`, `spec_descr(...)`, and `call_spec_handler_subst(...)` still return the same outputs,
  - `require LinkedSpec` now keeps the compile pipeline and ActionIR stack unloaded until one of those façade entrypoints is actually used.
- Updated focused regression coverage:
  - added `linkedspec_require_avoids_compile_pipeline_load_until_get`,
  - added `linkedspec_require_avoids_compiler_load_until_spec_descr`,
  - added `linkedspec_require_avoids_action_rewriter_load_until_compat_helper`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=176`)
## 2026-03-11 - Phase 1A Slice: Lazy-Load `Resolver` Through `ParserFactory`
## Summary
Reduced another load-time coupling in the `LinkedSpec` façade by making `LinkedSpec::ParserFactory` lazy-load its callback-owner packages when default deps are resolved, so `LinkedSpec.pm` no longer imports `LinkedSpec::Resolver` just to keep `get_parser(...)` working.

## Changed Files
- Updated: `perl/LinkedSpec/ParserFactory.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored parser-factory owner loading:
  - added `LinkedSpec::ParserFactory::_require_pkg(...)`,
  - updated `LinkedSpec::ParserFactory::_require_pkg_cb(...)` to lazy-load callback owner packages before resolving `can(...)`.
- Reduced façade load-time coupling:
  - removed `use LinkedSpec::Resolver ();` from `LinkedSpec.pm`.
- Preserved behavior:
  - `LinkedSpec::get_parser(...)` still returns runnable parser coderefs,
  - `LinkedSpec::Resolver` stays unloaded on `require LinkedSpec` and loads on demand when `get_parser(...)` resolves parser-factory defaults.
- Updated focused regression coverage:
  - added `linkedspec_require_avoids_resolver_load_until_get_parser`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=173`)
## 2026-03-11 - Backbone Item 3 Slice: Remove Final ParserFactory `Deps` Builder
## Summary
Continued the ActionIR and parser-core cleanup track by moving the last parser-factory default dep builder into `LinkedSpec::ParserFactory`, which removes the final active use of `LinkedSpec::Deps` and lets that module disappear entirely.

## Changed Files
- Updated: `perl/LinkedSpec/ParserFactory.pm`
- Deleted: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored parser-factory dependency ownership:
  - added `_require_pkg_cb(...)` and `_require_pkg_value(...)` to `LinkedSpec::ParserFactory`,
  - moved `_default_deps()` to build the trace/resolution/compile callback map locally inside `ParserFactory`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::parser_factory_deps_for_package(...)`,
  - deleted `perl/LinkedSpec/Deps.pm` because nothing in the active `LinkedSpec::*` surface depends on it any longer.
- Preserved behavior:
  - `LinkedSpec::get_parser(...)` still resolves specs through `Resolver`, applies trace options through `Trace`, and compiles through `Runtime::run_get(...)`,
  - require-only `LinkedSpec::ParserFactory` consumers do not eager-load the old `LinkedSpec::Deps` module or the owner modules behind `_default_deps()`.
- Updated focused regression coverage:
  - added `get_parser_avoids_removed_deps_parser_factory_dep_builder`,
  - added `parser_factory_require_avoids_linkedspec_deps_load`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=172`)
## 2026-03-11 - Backbone Item 3 Slice: Drop ActionRewriter `Deps` Import
## Summary
Continued the ActionIR cleanup track by removing `LinkedSpec::ActionRewriter`'s last load-time dependency on `LinkedSpec::Deps`, so require-only ActionRewriter consumers now stay on the extracted ActionIR owner modules without pulling the remaining parser-factory wiring into `%INC`.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale ActionRewriter load-time coupling:
  - deleted `use LinkedSpec::Deps ();` from `LinkedSpec::ActionRewriter`.
- Removed dead dependency plumbing:
  - deleted `LinkedSpec::Deps::declare_method_deps_for_package(...)` because it is no longer used by the active path.
- Preserved behavior:
  - `LinkedSpec::ActionRewriter` still loads its direct ActionIR owner modules and exposes the same rewrite/lowering entrypoints,
  - the remaining active `LinkedSpec::Deps` surface stays limited to parser-factory wiring.
- Updated focused regression coverage:
  - added `action_rewriter_require_avoids_linkedspec_deps_load`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=170`)
## 2026-03-11 - Backbone Item 3 Slice: Move MethodLowering Default Dep Builder into `MethodLowering`
## Summary
Continued the ActionIR cleanup track by moving method-lowering default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::MethodLowering`, so the active method-lowering owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored method-lowering dependency ownership:
  - added `LinkedSpec::ActionIR::MethodLowering::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::MethodLowering::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_method_lowering_deps()` to resolve through `MethodLowering` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::method_lowering_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still lowers declaration aliases, assignments, returns, push-value, regex-subst, and method-value forms through `LinkedSpec::ActionIR::MethodLowering`,
  - method-lowering defaults still target the same trim, declare, method-expr, value-expr, and assignment-source callbacks as before,
  - alias, assign, and return-array lowering output stay behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_method_lowering_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=169`)
## 2026-03-11 - Backbone Item 3 Slice: Move ControlFlow Default Dep Builder into `ControlFlow`
## Summary
Continued the ActionIR cleanup track by moving control-flow default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::ControlFlow`, so the active control-flow owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/ControlFlow.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored control-flow dependency ownership:
  - added `LinkedSpec::ActionIR::ControlFlow::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::ControlFlow::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_control_flow_deps()` to resolve through `ControlFlow` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::control_flow_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still lowers `if(...)`, switch markers, and output helpers through `LinkedSpec::ActionIR::ControlFlow`,
  - control-flow defaults still target the same trim, tag-normalization, flow-expression, and method-expression callbacks as before,
  - `if(...)` lowering, stack mutation, and `print(...)` lowering stay behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_control_flow_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=168`)
## 2026-03-11 - Backbone Item 3 Slice: Move ArrayPipeline Default Dep Builder into `ArrayPipeline`
## Summary
Continued the ActionIR cleanup track by moving array-pipeline default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::ArrayPipeline`, so the active array-pipeline owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored array-pipeline dependency ownership:
  - added `LinkedSpec::ActionIR::ArrayPipeline::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::ArrayPipeline::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_array_pipeline_deps()` to resolve through `ArrayPipeline` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::array_pipeline_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still builds and lowers array-pipeline plans through `LinkedSpec::ActionIR::ArrayPipeline`,
  - array-pipeline defaults still target the same trim, literal, array, method-expr, scope-token, and scalar callbacks as before,
  - array-pipeline planning and lowering output stay behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_array_pipeline_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=167`)
## 2026-03-11 - Backbone Item 3 Slice: Move FlowExpr Default Dep Builder into `FlowExpr`
## Summary
Continued the ActionIR cleanup track by moving flow-expression default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::FlowExpr`, so the active flow-expression owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/FlowExpr.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored flow-expression dependency ownership:
  - added `LinkedSpec::ActionIR::FlowExpr::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::FlowExpr::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_flow_expr_deps()` to resolve through `FlowExpr` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::flow_expr_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still lowers `is_empty(...)`, boolean composition, and comparison flow expressions through `LinkedSpec::ActionIR::FlowExpr`,
  - flow-expression defaults still target the same trim, value-expression, and method-expression callbacks as before,
  - empty-check and composite flow lowering output stay behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_flow_expr_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=166`)
## 2026-03-11 - Backbone Item 3 Slice: Move ValueExpr Default Dep Builder into `ValueExpr`
## Summary
Continued the ActionIR cleanup track by moving value-expression default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::ValueExpr`, so the active value-expression owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/ValueExpr.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored value-expression dependency ownership:
  - added `LinkedSpec::ActionIR::ValueExpr::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::ValueExpr::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_value_expr_deps()` to resolve through `ValueExpr` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::value_expr_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still lowers scalar-access and scalaref value expressions through `LinkedSpec::ActionIR::ValueExpr`,
  - value-expression defaults still target the same trim, flow-expression, and method-value callbacks as before,
  - scalar-access and scalaref lowering output stay behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_value_expr_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ValueExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=165`)
## 2026-03-11 - Backbone Item 3 Slice: Move Action Contract Default Dep Builder into `Contracts`
## Summary
Continued the ActionIR cleanup track by moving action-contract default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::Contracts`, so the active contract owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/Contracts.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored action-contract dependency ownership:
  - added `LinkedSpec::ActionIR::Contracts::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::Contracts::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_action_contract_deps()` to resolve through `Contracts` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::action_rewriter_contract_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still builds lowering contracts through `LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts(...)`,
  - contract defaults still target the same return/assign/push/regex/array/flow/emit/declare lowering callbacks as before,
  - built contract surfaces and `declare_typed` lowering output stay behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_action_contract_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=164`)
## 2026-03-11 - Backbone Item 3 Slice: Move DeclareMethod Default Dep Builder into `DeclareMethod`
## Summary
Continued the ActionIR cleanup track by moving the specialized declare-method default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::DeclareMethod`, so the active declare-method owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/DeclareMethod.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored declare-method dependency ownership:
  - added `LinkedSpec::ActionIR::DeclareMethod::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::DeclareMethod::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_declare_method_deps()` to resolve through `DeclareMethod` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::action_rewriter_declare_method_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still lowers `declare(...)` and `assign(...)` method forms through `LinkedSpec::ActionIR::DeclareMethod`,
  - declare-method defaults still target the same trim/method-expr/flow/value/method-lowering callbacks as before,
  - declare-method and assign-method lowering output stay behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_declare_method_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/DeclareMethod.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=163`)
## 2026-03-11 - Backbone Item 3 Slice: Move RewritePipeline Default Dep Builder into `RewritePipeline`
## Summary
Continued the ActionIR cleanup track by moving rewrite-pipeline default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::RewritePipeline`, so the active rewrite-pipeline owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/RewritePipeline.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored rewrite-pipeline dependency ownership:
  - added `LinkedSpec::ActionIR::RewritePipeline::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::RewritePipeline::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_rewrite_pipeline_deps()` to resolve through `RewritePipeline` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::action_rewriter_rewrite_pipeline_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still builds rewrite rules and canonical-IR-driven helper rewrites through `LinkedSpec::ActionIR::RewritePipeline`,
  - rewrite-pipeline defaults still target the same lowering-contract, helper-event, canonical-event, and unresolved-helper callbacks as before,
  - helper rewrite output stays behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_rewrite_pipeline_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=162`)
## 2026-03-11 - Backbone Item 3 Slice: Move Diagnostics Default Dep Builder into `Diagnostics`
## Summary
Continued the ActionIR cleanup track by moving diagnostics default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::Diagnostics`, so the active diagnostics owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/Diagnostics.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored diagnostics dependency ownership:
  - added `LinkedSpec::ActionIR::Diagnostics::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::Diagnostics::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_diagnostics_deps()` to resolve through `Diagnostics` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::action_rewriter_diagnostics_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still builds unresolved-helper and helper-event diagnostics through `LinkedSpec::ActionIR::Diagnostics`,
  - diagnostics defaults still target the same statement-split and contract-scan callbacks as before,
  - unresolved-helper counting stays behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_diagnostics_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=161`)
## 2026-03-11 - Backbone Item 3 Slice: Move Canonical Event Default Dep Builder into `CanonicalEvents`
## Summary
Continued the ActionIR cleanup track by moving canonical-event default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::CanonicalEvents`, so the active canonical-event owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored canonical-event dependency ownership:
  - added `LinkedSpec::ActionIR::CanonicalEvents::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::CanonicalEvents::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_canonical_event_deps()` to resolve through `CanonicalEvents` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::action_rewriter_canonical_event_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still builds canonical action-IR events through `LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events(...)`,
  - canonical-event defaults still target the same trim and statement-split helpers as before,
  - canonical node emission stays behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_canonical_event_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=160`)
## 2026-03-11 - Backbone Item 3 Slice: Move StatementSplit Default Dep Builder into `StatementSplit`
## Summary
Continued the ActionIR cleanup track by moving statement-split default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::StatementSplit`, so the active statement-splitting owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/StatementSplit.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored statement-split dependency ownership:
  - added `LinkedSpec::ActionIR::StatementSplit::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::StatementSplit::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_statement_split_deps()` to resolve through `StatementSplit` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::action_rewriter_statement_split_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still splits action statements through `LinkedSpec::ActionIR::StatementSplit::_split_action_ir_statements(...)`,
  - the statement-split path still consumes the same `trim_action_ir_value` helper callback as before,
  - statement segmentation stays behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_statement_split_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=159`)
## 2026-03-11 - Backbone Item 3 Slice: Move Scanner Default Dep Builder into `Scanner`
## Summary
Continued the ActionIR cleanup track by moving scanner default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::Scanner`, so the active scanner owner module now defines its own default callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/Scanner.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored scanner dependency ownership:
  - added `LinkedSpec::ActionIR::Scanner::default_deps_for_package(...)`,
  - added `LinkedSpec::ActionIR::Scanner::_require_pkg_cb(...)` for scanner-owned callback validation,
  - rewired `LinkedSpec::ActionRewriter::_scan_contract_ir_event_deps()` to resolve through `Scanner` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::action_rewriter_scanner_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still scans helper contracts through `LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(...)`,
  - scanner default deps still target the same split/trim/method/declare helpers as before,
  - rewrite output remains unchanged for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_scanner_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=158`)
## 2026-03-11 - Backbone Item 3 Slice: Move Scanner Rule Dep Rebinding into `ScannerCore` Owner Helpers
## Summary
Continued the ActionIR cleanup track by moving scanner-rule dependency rebinding and dispatcher selection into explicit `LinkedSpec::ActionIR::ScannerCore` owner helpers, instead of leaving that orchestration inline inside `scan_contract_ir_events(...)`.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/ScannerCore.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::ActionIR::ScannerCore`:
  - added `_scanner_rule_dep_bindings(...)` to build the callback map consumed by scanner rule packages,
  - added `_with_scanner_rule_deps(...)` to own scanner-rule dependency rebinding,
  - added `_scanner_dispatchers()` so `scan_contract_ir_events(...)` no longer hardcodes its scanner dispatch chain inline.
- Preserved behavior:
  - ActionIR contract scanning still dispatches through the same primitive/basic/pipeline/flow/legacy rule packages,
  - scanner rule packages still receive the same helper callbacks for statement splitting, trimming, method parsing, array-pipeline planning, and declare parsing,
  - the action-rewriter and phase0 parser-generation path are behavior-stable.
- Updated focused regression coverage:
  - added `actionir_scannercore_uses_scanner_dep_binding_owner`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ScannerCore.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=157`)
## 2026-03-11 - Plugin Bridge Slice: Move Default Legacy Runtime Deps onto Owner Helpers
## Summary
Continued the `LinkedSpec::PluginBridge` modernization track by moving the bridge's default legacy runtime load/exec behavior onto explicit owner helpers, so the compatibility seam is now fully named inside `LinkedSpec::PluginBridge` instead of relying on inline closures.

## Changed Files
- Updated: `perl/LinkedSpec/PluginBridge.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::PluginBridge`:
  - added `_load_legacy_plugin_runtime(...)` as the explicit owner helper for lazy `PPlugin` loading,
  - added `_exec_legacy_plugin(...)` as the explicit owner helper for normalized-name legacy plugin execution,
  - updated `_default_deps()` to point at those owner helpers instead of inline closures.
- Preserved behavior:
  - `LinkedSpec::AUTOLOAD` still delegates to `LinkedSpec::PluginBridge::_dispatch_autoload(...)`,
  - default bridge dispatch still lazy-loads `PPlugin` and executes through `PPlugin::exec_plugin_name(...)`,
  - the public compatibility surface is unchanged while the bridge replacement seam gets narrower and easier to test.
- Updated focused regression coverage:
  - added `plugin_bridge_default_load_dep_uses_legacy_runtime_owner`,
  - added `plugin_bridge_default_exec_dep_uses_legacy_exec_owner`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=156`)
## 2026-03-11 - Plugin Bridge Slice: Split Explicit Plugin-Name Dispatch from Autoload Normalization
## Summary
Continued the `LinkedSpec::PluginBridge` modernization track by splitting explicit plugin-name dispatch into its own owner path, so autoload handling now normalizes once and delegates to a reusable explicit-name dispatcher.

## Changed Files
- Updated: `perl/LinkedSpec/PluginBridge.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::PluginBridge`:
  - added `_require_plugin_name(...)` to validate explicit normalized plugin names,
  - added `_dispatch_plugin_name(...)` as the owner path for explicit-name plugin dispatch through injected runtime deps,
  - `_dispatch_autoload(...)` now reduces to autoload-name normalization plus delegation into `_dispatch_plugin_name(...)`.
- Preserved behavior:
  - `LinkedSpec::AUTOLOAD` still delegates to `LinkedSpec::PluginBridge::_dispatch_autoload(...)`,
  - injected and default plugin-runtime deps still load the runtime and execute the normalized plugin name the same way,
  - invalid autoload names still fail before any runtime load/exec side effects.
- Updated focused regression coverage:
  - added `plugin_bridge_dispatch_plugin_name_supports_injected_runtime_deps`,
  - added `plugin_bridge_dispatch_plugin_name_rejects_invalid_name_before_runtime_load`,
  - added `plugin_bridge_autoload_uses_dispatch_plugin_name_owner`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=154`)
## 2026-03-11 - Plugin Runtime Slice: Migrate Internal Explicit Plugin Callers to `exec_plugin_name(...)`
## Summary
Continued the plugin/runtime modernization track by moving repo-owned callers that already know explicit plugin names off the compatibility `PPlugin::exec(...)` wrapper and onto `PPlugin::exec_plugin_name(...)`.

## Changed Files
- Updated: `perl/HUtils.pm`
- Updated: `perl/RTLUtils.pm`
- Updated: `perl/TableScript.pm`
- Updated: `plugin/string.plg`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated repo-owned explicit plugin dispatch sites:
  - `HUtils::GenericFilter(...)` now calls `PPlugin::exec_plugin_name("genericfilter_$action", ...)`,
  - `RTLUtils` header/context-clause generation now calls `PPlugin::exec_plugin_name('add_header_n_context_clause', ...)`,
  - `TableScript::http_exec(...)` now calls `PPlugin::exec_plugin_name('httplink', ...)`,
  - `plugin/string.plg` now calls `PPlugin::exec_plugin_name('file_list_path2http', ...)`.
- Preserved behavior:
  - explicit plugin names and arguments remain unchanged at each callsite,
  - the compatibility `PPlugin::exec(...)` wrapper remains available for mixed-name and external legacy callers,
  - autoload-style compatibility entrypoints are unchanged.
- Updated focused regression coverage:
  - added `tablescript_http_exec_uses_pplugin_explicit_name_owner`,
  - added `hutils_generic_filter_uses_pplugin_explicit_name_owner`.

## Validation
- Ran:
  - `perl -Iperl -c perl/HUtils.pm`
  - `perl -Iperl -c perl/RTLUtils.pm`
  - `perl -Iperl -c perl/TableScript.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=151`)
## 2026-03-11 - Plugin Runtime Slice: Lazy-Load `LinkedSpec` from `PPlugin` Default Parser Deps
## Summary
Continued the plugin/runtime modernization track by removing `PPlugin`'s eager `LinkedSpec` import and making the default `pplugin` parser dependency lazy-load `LinkedSpec` only when that callback is actually invoked.

## Changed Files
- Updated: `perl/PPlugin.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `PPlugin` module-load behavior:
  - removed eager `use LinkedSpec;` from `PPlugin.pm`,
  - added explicit core path-module ownership in `PPlugin.pm` with `Cwd`, `File::Basename`, and `File::Spec`,
  - updated `_default_deps()->{load_plugin_parser}` to `require LinkedSpec` lazily before calling `LinkedSpec::get_parser('pplugin')`.
- Preserved behavior:
  - `PPlugin` still uses the `pplugin` spec and `LinkedSpec::get_parser(...)` for legacy `.plg` parsing by default,
  - default registry construction and plugin dispatch behavior remain unchanged for the phase0 corpus,
  - `LinkedSpec` still loads when the default parser callback is executed.
- Updated focused regression coverage:
  - added `pplugin_require_does_not_eagerly_load_linkedspec`,
  - added `pplugin_default_parser_dep_lazy_loads_linkedspec`,
  - added `run_perl_snippet_in_subprocess(...)` helper for process-isolated module-load assertions.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/PPlugin.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=149`)
## 2026-03-11 - Plugin Runtime Slice: Extract Explicit `PPlugin` Registry Loader Deps
## Summary
Continued the plugin/runtime modernization track by extracting legacy registry construction in `PPlugin::new(...)` behind an explicit dependency-owned loader seam, so the compatibility adapter no longer hardwires parser loading, plugin-file discovery, and registry assembly inline.

## Changed Files
- Updated: `perl/PPlugin.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored legacy plugin registry loading:
  - added `_require_dep(...)`, `_default_deps()`, and `_load_legacy_registry(...)` to `PPlugin`,
  - `PPlugin::new(...)` now initializes its cached legacy registry through `_load_legacy_registry()` instead of calling `LinkedSpec::get_parser('pplugin')`, `_legacy_plugin_files(...)`, and `_build_plugin_registry(...)` inline,
  - the default dependency map now makes parser loading, plugin-file discovery, and registry assembly explicit owner callbacks.
- Preserved behavior:
  - `PPlugin` still loads the `pplugin` parser through `LinkedSpec` by default,
  - legacy `.plg` file discovery and registry assembly semantics remain unchanged for the phase0 corpus,
  - the cached registry shape and dispatch behavior stay compatibility-stable.
- Updated focused regression coverage:
  - added `pplugin_load_legacy_registry_uses_explicit_dependency_callbacks`,
  - added `pplugin_default_registry_deps_load_through_explicit_owner_paths`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/PPlugin.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=147`)
## 2026-03-11 - Plugin Runtime Slice: Route Bridge Exec Through Explicit `PPlugin` Plugin-Name Owner
## Summary
Continued the plugin/runtime modernization track by making `PPlugin` own explicit plugin-name execution through `exec_plugin_name(...)`, with `LinkedSpec::PluginBridge` now using that owner path directly while the older mixed-name `exec(...)` surface remains as compatibility glue.

## Changed Files
- Updated: `perl/PPlugin.pm`
- Updated: `perl/LinkedSpec/PluginBridge.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored legacy plugin execution ownership:
  - added `PPlugin::exec_plugin_name(...)` as the explicit owner path for executing a plugin by normalized plugin name,
  - added `PPlugin::_normalize_plugin_name(...)` so the older mixed-name `exec(...)` wrapper and `AUTOLOAD` compatibility path can normalize before delegating,
  - `LinkedSpec::PluginBridge::_default_deps()` now dispatches through `PPlugin::exec_plugin_name(...)` instead of the older mixed-name wrapper.
- Preserved behavior:
  - `LinkedSpec::AUTOLOAD` still resolves through `LinkedSpec::PluginBridge`,
  - the compatibility `PPlugin::exec(...)` surface still accepts older mixed autoload/subname inputs for direct callers,
  - legacy `.plg` dispatch behavior remains unchanged for the phase0 corpus.
- Updated focused regression coverage:
  - added `plugin_bridge_default_exec_dep_uses_pplugin_explicit_name_owner`,
  - added `pplugin_exec_wrapper_normalizes_to_explicit_name_owner`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/PPlugin.pm`
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=145`)
## 2026-03-11 - Plugin Runtime Slice: Extract Explicit Legacy Registry Builder
## Summary
Continued the plugin/runtime modernization track by extracting legacy `.plg` registry construction in `PPlugin` into an explicit owner helper, so the compatibility adapter now exposes a narrower, testable registry seam without changing runtime behavior.

## Changed Files
- Updated: `perl/PPlugin.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `PPlugin` legacy registry construction:
  - added `_build_plugin_registry(...)` as the owner helper for building the cached legacy plugin registry from discovered `.plg` files,
  - `PPlugin::new(...)` now enumerates plugin files through `_legacy_plugin_files(...)` and hands the ordered list to `_build_plugin_registry(...)`,
  - registry construction still preserves later-file override behavior for duplicate plugin names while skipping malformed plugin parses with a warning.
- Preserved behavior:
  - legacy `.plg` execution still searches the working directory and the project `plugin/` tree through the previously-landed deterministic discovery helpers,
  - plugin dispatch behavior remains unchanged for the phase0 corpus,
  - malformed legacy plugin files remain non-fatal to registry construction.
- Updated focused regression coverage:
  - added `pplugin_build_plugin_registry_preserves_file_order_and_skips_parse_failures`,
  - kept the deterministic discovery seam coverage for cwd-first root enumeration and sorted `.plg` file lists.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/PPlugin.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=143`)
## 2026-03-10 - Plugin Runtime Slice: Make Legacy `.plg` File Discovery Deterministic
## Summary
Continued the plugin/runtime modernization track by replacing `PPlugin`'s brace-glob plugin-file discovery with explicit, deterministic cwd-first root enumeration and sorted `.plg` file lists.

## Changed Files
- Updated: `perl/PPlugin.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `PPlugin` legacy discovery:
  - added `_plugin_project_root(...)` to compute the project-relative legacy plugin root,
  - added `_legacy_plugin_search_roots(...)` to enumerate cwd-first legacy plugin roots explicitly,
  - added `_legacy_plugin_files(...)` to enumerate `.plg` files per root in sorted order and dedupe duplicate file paths,
  - `PPlugin::new(...)` now consumes `_legacy_plugin_files(...)` instead of brace-globbing two root patterns directly.
- Preserved behavior:
  - legacy `.plg` execution still searches the working directory and the project `plugin/` tree,
  - plugin parsing/execution behavior remains unchanged for the phase0 corpus,
  - duplicate plugin filenames in distinct roots still preserve cwd-first root precedence through stable per-root ordering.
- Updated focused regression coverage:
  - added `pplugin_legacy_plugin_search_roots_are_cwd_first_and_deduped`,
  - added `pplugin_legacy_plugin_files_are_sorted_and_deduped`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/PPlugin.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=142`)
## 2026-03-10 - Plugin Runtime Slice: Normalize `PluginBridge` Dispatch to Explicit Plugin Names
## Summary
Continued the plugin/runtime modernization track by making `LinkedSpec::PluginBridge` normalize full `AUTOLOAD` names into explicit plugin names before runtime dispatch, narrowing the compatibility seam toward a deterministic registry-style plugin contract.

## Changed Files
- Updated: `perl/LinkedSpec/PluginBridge.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::PluginBridge`:
  - added `_normalize_plugin_name(...)` to extract and validate an explicit plugin identifier from the full Perl `AUTOLOAD` name,
  - `_dispatch_autoload(...)` now normalizes the autoloaded method name before loading the legacy runtime and before calling the injected `exec_plugin` callback,
  - invalid autoload names now fail before any legacy plugin-runtime load/exec side effects occur.
- Preserved behavior:
  - `LinkedSpec::AUTOLOAD` still delegates to `LinkedSpec::PluginBridge::_dispatch_autoload(...)`,
  - the default compatibility runtime still lazy-loads `PPlugin`,
  - legacy plugin execution still works through the same `.plg` compatibility path.
- Updated focused regression coverage:
  - `plugin_bridge_supports_injected_plugin_runtime_deps` now proves injected runtime callbacks receive normalized plugin names rather than full Perl method names,
  - added `plugin_bridge_rejects_invalid_autoload_name_before_runtime_load` to prove invalid autoload names fail before plugin runtime load/exec.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=140`)
## 2026-03-10 - Phase 1A Slice: Remove Dead Validation Facade Wrappers
## Summary
Reduced another stale `LinkedSpec.pm` seam by removing the dead validation delegate wrappers now that active validation and DSL error reporting already stay on `LinkedSpec::Validation`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale validation delegates from `LinkedSpec.pm`:
  - deleted `get_dsl_context(...)`,
  - deleted `report_dsl_error(...)`,
  - deleted `validate_spec_content(...)`,
  - deleted `validate_rule_definition(...)`,
  - deleted `validate_gdata_references(...)`,
  - deleted `validate_dsl_syntax(...)`,
  - deleted `extract_regex_literals_from_rule_rhs(...)`,
  - removed the now-unused `LinkedSpec::Validation` import from `LinkedSpec.pm`.
- Preserved behavior:
  - active compile-time validation still routes through `LinkedSpec::Validation` from `LinkedSpec::Compiler`,
  - malformed-spec diagnostics still report DSL line context through the `LinkedSpec::Validation` owner path,
  - `Get(..., return_descriptor => 1)` still returns the same descriptor structure and metadata.
- Updated focused regression coverage:
  - expanded `get_parser_malformed_spec_reports_validation_error` to trap the removed `LinkedSpec` validation helpers on the error path,
  - added `get_return_descriptor_avoids_removed_linkedspec_validation_facade` to trap the removed validation helpers on the successful descriptor-build path.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Validation.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=139`)
## 2026-03-10 - Phase 1A Slice: Remove Dead Internal Trace and Runtime Helper Wrappers
## Summary
Reduced another stale `LinkedSpec.pm` seam by removing the dead internal trace/runtime helper wrappers now that active trace configuration and parser-source emission already stay on `LinkedSpec::Trace`, `LinkedSpec::ParserFactory`, and `LinkedSpec::SpecEntry`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale internal wrappers from `LinkedSpec.pm`:
  - deleted `_trace_level_name(...)`,
  - deleted `_apply_trace_options(...)`,
  - deleted `_emit_parser_source_line(...)`.
- Preserved behavior:
  - public `LinkedSpec::configure_trace(...)` remains as the compatibility trace entrypoint,
  - active `get_parser(...)` tracing still routes through `LinkedSpec::Trace` and `LinkedSpec::ParserFactory`,
  - active parser-source emission still routes through `LinkedSpec::SpecEntry` plus injected `runtime_ctx`.
- Updated focused regression coverage:
  - expanded `get_parser_avoids_linkedspec_parser_factory_facade` to trap the removed internal trace helper `_trace_level_name(...)`,
  - expanded `spec_entry_compile_spec_entry_uses_injected_runtime_context` to trap the removed runtime helper `_emit_parser_source_line(...)`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Trace.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=138`)
## 2026-03-10 - Phase 1A Slice: Remove Dead Internal ActionIR Lowering Delegate Block
## Summary
Reduced another stale `LinkedSpec.pm` seam by removing the dead internal ActionIR lowering/dependency delegate block now that active helper lowering already stays on `LinkedSpec::ActionRewriter` and the extracted ActionIR owner modules.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale internal ActionIR delegates from `LinkedSpec.pm`:
  - deleted the old dependency builders (`_flow_expr_deps`, `_method_lowering_deps`, `_declare_method_deps`, `_array_pipeline_deps`, `_control_flow_deps`, `_value_expr_deps`),
  - deleted the remaining internal lowering/parser/extraction wrappers for flow expressions, declare/method lowering, value lowering, array-pipeline lowering, and fluent control-flow lowering,
  - removed the now-unused ActionIR/Deps import lines from `LinkedSpec.pm`.
- Preserved behavior:
  - `LinkedSpec::call_spec_handler_subst(...)` remains the compatibility/test shim,
  - active helper lowering still routes through `LinkedSpec::ActionRewriter::call_spec_handler_subst(...)` and the extracted ActionIR owner modules.
- Updated focused regression coverage:
  - renamed seam lock to `action_rewriter_avoids_removed_linkedspec_lowering_facade`,
  - expanded the traps across the removed internal lowering/dependency names,
  - added explicit `is_empty(...)` and composable array-pipeline coverage so the owner-path lock exercises the removed flow/value/pipeline helper surface more broadly.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=138`)
## 2026-03-10 - Phase 1A Slice: Remove Dead Internal RuleIR and Descriptor Delegate Block
## Summary
Reduced another stale `LinkedSpec.pm` seam by removing the dead internal `Compiler`/`RuleIR`/action-contract delegate block now that active descriptor/rule-compilation flow already stays on the owner modules.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale internal delegates from `LinkedSpec.pm`:
  - deleted `_build_action_rewriter_migration_summary(...)`
  - deleted `_action_contract_deps(...)`
  - deleted `_build_action_lowering_contracts(...)`
  - deleted `_select_rule_handler_variant(...)`
  - deleted `_build_rule_execution_meta(...)`
  - deleted `_collect_rule_ir(...)`
  - deleted `_plan_rule_ir_meta(...)`
  - deleted `_validate_rule_ir_or_exit(...)`
  - deleted `_normalize_rule_code_chunks(...)`
  - deleted `_build_rule_ir_emit_context(...)`
- Preserved behavior:
  - `LinkedSpec::spec_descr(...)` still compiles rules through `LinkedSpec::Compiler` plus `LinkedSpec::SpecEntry`,
  - `LinkedSpec::Get(..., return_descriptor => 1)` still exposes compiled handlers, selected handler metadata, and descriptor-level action-rewriter migration summary.
- Added focused regression coverage:
  - `spec_descr_and_get_avoid_removed_linkedspec_ruleir_internal_facade`
  - the seam lock traps the removed helper names and proves both `spec_descr(...)` and `Get(..., return_descriptor => 1)` succeed through the owner modules only.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=138`)
## 2026-03-10 - Phase 1A Slice: Remove Dead Internal ActionRewriter Facade Block
## Summary
Reduced another stale `LinkedSpec.pm` seam by removing the dead internal ActionRewriter delegate block now that active rewrite/scanner/canonicalization flow already stays on `LinkedSpec::ActionRewriter` and `LinkedSpec::RuleIR::EmitContext`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale internal ActionRewriter delegates from `LinkedSpec.pm`:
  - deleted `_find_unresolved_action_helpers(...)`
  - deleted `_scan_contract_ir_events(...)`
  - deleted `_collect_action_helper_ir_nodes(...)`
  - deleted `_trim_action_ir_value(...)`
  - deleted `_canonicalize_helper_action_ir_event(...)`
  - deleted `_split_action_ir_statements(...)`
  - deleted `_build_canonical_action_ir_events(...)`
  - deleted `_lower_action_code_from_canonical_ir(...)`
  - deleted `_accumulate_action_rewrite_diagnostics(...)`
  - deleted `_rewrite_action_code_with_diagnostics(...)`
  - deleted `_build_action_rewrite_rules(...)`
- Preserved behavior:
  - runtime rule emission still rewrites through `LinkedSpec::RuleIR::EmitContext` plus `LinkedSpec::ActionRewriter`,
  - `LinkedSpec::call_spec_handler_subst(...)` remains the public compatibility/test shim for focused rewrite inspection.
- Updated focused regression coverage:
  - `ruleir_emit_context_avoids_removed_linkedspec_action_rewriter_facade`
  - the seam lock now traps the removed helper names and proves `LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context(...)` still succeeds through the owner modules only.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=137`)
## 2026-03-10 - Phase 1A Slice: Remove Runtime `compile_spec_entry` Wrapper
## Summary
Reduced another stale runtime seam by removing `LinkedSpec::Runtime::compile_spec_entry(...)` now that active rule-entry compilation already flows through `LinkedSpec::SpecEntry::compile_spec_entry(...)` with injected runtime context.

## Changed Files
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale runtime wrapper from `Runtime.pm`:
  - deleted `LinkedSpec::Runtime::compile_spec_entry(...)`,
  - active rule-entry compilation continues to resolve through `LinkedSpec::SpecEntry::compile_spec_entry(...)` with injected `runtime_ctx`.
- Updated focused injected-callback coverage:
  - direct injected-state coverage now targets `LinkedSpec::SpecEntry::compile_spec_entry(...)`,
  - compiler-pipeline injected callback tests now use the `SpecEntry.pm` owner directly.
- Added/updated focused regression coverage:
  - `spec_entry_compile_spec_entry_uses_injected_runtime_context`
  - existing wrapper-bypass seams continue to prove active descriptor-build paths do not depend on the removed runtime wrapper.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=137`)
## 2026-03-10 - Phase 1A Slice: Remove Facade `spec_entry` Helper
## Summary
Reduced another stale `LinkedSpec.pm` compatibility seam by removing the façade-only `spec_entry(...)` wrapper and regression-locking rule-entry compilation to `LinkedSpec::SpecEntry`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale rule-entry delegation from `LinkedSpec.pm`:
  - deleted `LinkedSpec::spec_entry(...)`,
  - active rule-entry compilation continues to resolve through `LinkedSpec::SpecEntry::compile_spec_entry(...)` via compiler-owned defaults.
- Added focused regression coverage:
  - `spec_descr_paths_avoid_linkedspec_spec_entry_facade`
  - the regression traps the removed façade helper name and proves both `LinkedSpec::spec_descr(...)` and `LinkedSpec::Get(..., return_descriptor => 1)` still build compiled handlers through the `SpecEntry.pm` owner path.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=137`)
## 2026-03-10 - Phase 1A Slice: Remove Legacy Runtime Raw-Arg Wrapper
## Summary
Reduced another stale runtime seam by removing `LinkedSpec::Runtime::run_get_from_args(...)` now that active public/runtime/parser-factory flows all normalize options before delegating into `LinkedSpec::Runtime::run_get(...)`.

## Changed Files
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale runtime wrapper from `Runtime.pm`:
  - deleted `LinkedSpec::Runtime::run_get_from_args(...)`,
  - active runtime entrypoints continue to resolve through `LinkedSpec::Runtime::run_get(...)` with normalized hashref options supplied by `LinkedSpec::Get(...)` and `LinkedSpec::ParserFactory`.
- Added focused regression coverage:
  - `runtime_run_get_avoids_legacy_raw_arg_wrapper`
  - the regression traps the removed wrapper name and proves `LinkedSpec::Runtime::run_get(..., { return_descriptor => 1 })` still returns a descriptor hash directly through the active owner path.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=136`)
## 2026-03-10 - Phase 1A Slice: Remove Facade `spec_gdata` Helper
## Summary
Reduced another stale `LinkedSpec.pm` compatibility seam by removing the façade-only `spec_gdata(...)` wrapper and regression-locking final descriptor `gdata` compilation to `LinkedSpec::Compiler`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale compiler delegation from `LinkedSpec.pm`:
  - deleted `LinkedSpec::spec_gdata(...)`,
  - active final descriptor `gdata` compilation continues to resolve through `LinkedSpec::Compiler::spec_gdata(...)` inside `_build_final_descriptor(...)`.
- Added focused regression coverage:
  - `compiler_pipeline_avoids_linkedspec_spec_gdata_facade`
  - the regression traps the removed façade helper name and proves `Runtime::run_get(..., return_descriptor => 1)` still returns a descriptor hash with compiled `gdata` through the compiler-owned path.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=135`)
## 2026-03-10 - Phase 1A Slice: Remove Facade Local Spec Path Helper
## Summary
Reduced another stale `LinkedSpec.pm` compatibility seam by removing the façade-only `_resolve_local_spec_path(...)` wrapper and regression-locking the active local/module-relative parser-resolution path to `LinkedSpec::Resolver`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale resolver delegation from `LinkedSpec.pm`:
  - deleted `LinkedSpec::_resolve_local_spec_path(...)`,
  - active local/module-relative lookup continues to resolve through `LinkedSpec::Resolver::_resolve_local_spec_path(...)` via `resolve_spec_path(...)`.
- Added focused regression coverage:
  - `get_parser_avoids_linkedspec_local_spec_path_facade`
  - the regression traps the removed façade helper name and proves `get_parser('Lispish')` still resolves from a non-project cwd, builds a parser, executes it, and keeps `PathSearch` unloaded.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Resolver.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=134`)
## 2026-03-10 - Phase 1A Slice: Remove Stale Compiler Bootstrap Helper
## Summary
Reduced stale compiler scaffolding by removing the unused `LinkedSpec::Compiler::_run_bootstrap_parse(...)` helper now that bootstrap parsing is fully owned by `LinkedSpec::BootstrapSpec`, and regression-locking the active pipeline to that owner path.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale compiler-local bootstrap parsing glue:
  - deleted `LinkedSpec::Compiler::_run_bootstrap_parse(...)`,
  - active bootstrap parsing continues to resolve through `LinkedSpec::BootstrapSpec::run_bootstrap_parse(...)`.
- Added focused regression coverage:
  - `compiler_pipeline_avoids_legacy_run_bootstrap_parse_helper`
  - the regression traps the removed compiler-local helper name and proves `Runtime::run_get(...)` still returns a valid descriptor through the active BootstrapSpec-owned path.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=133`)
## 2026-03-10 - Plugin Runtime Slice: Add Explicit `PluginBridge` Runtime Deps
## Summary
Started the plugin/runtime modernization track in code by making `LinkedSpec::PluginBridge` own explicit plugin-runtime load/exec dependency callbacks, so future module-based plugin runtime work can replace `PPlugin` without changing `LinkedSpec::AUTOLOAD`.

## Changed Files
- Updated: `perl/LinkedSpec/PluginBridge.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::PluginBridge`:
  - added `_default_deps()` for lazy `PPlugin` loading and dispatch execution,
  - added `_dispatch_autoload(...)` as the internal compatibility-shim owner that consumes injected `load_plugin_runtime` and `exec_plugin` callbacks,
  - `LinkedSpec::AUTOLOAD` now delegates straight to `_dispatch_autoload(...)`,
  - removed the stale `dispatch_autoload(...)` wrapper.
- Added focused regression coverage:
  - `autoload_avoids_plugin_bridge_wrapper`
  - `plugin_bridge_supports_injected_plugin_runtime_deps`
  - the new seam locks prove `LinkedSpec::AUTOLOAD` still delegates through `PluginBridge`, and that `PluginBridge` can execute through injected runtime callbacks without relying on direct `PPlugin` calls at the call site.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=132`)
## 2026-03-10 - Phase 1A Slice: Move Pipeline Default Callbacks Into `Compiler`
## Summary
Reduced another compiler/runtime callback seam by making `LinkedSpec::Compiler::run_get_pipeline(...)` own the default `bootstrap_parse` and `compile_spec_entry` callbacks, so `LinkedSpec::Runtime::run_get(...)` now injects only `runtime_ctx` for mutable per-run state.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Compiler::run_get_pipeline(...)`:
  - it now defaults `bootstrap_parse` to `LinkedSpec::BootstrapSpec::run_bootstrap_parse(...)` internally,
  - it now defaults `compile_spec_entry` to `LinkedSpec::SpecEntry::compile_spec_entry(...)` bound to the injected `runtime_ctx`,
  - explicit callback injection remains available for focused tests and future internal refactors.
- Simplified `LinkedSpec::Runtime::run_get(...)`:
  - it now injects only `runtime_ctx`,
  - compiler owner modules now supply the default bootstrap/rule-compilation callbacks.
- Added focused regression coverage:
  - `runtime_run_get_defers_default_pipeline_callbacks_to_compiler_owner`
  - the regression traps `LinkedSpec::Compiler::run_get_pipeline(...)` and proves `Runtime::run_get(...)` no longer injects `bootstrap_parse` or `compile_spec_entry` while still returning a valid descriptor hash.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=130`)
## 2026-03-10 - Phase 1A Slice: Move Final Descriptor `spec_gdata` Default Into `Compiler`
## Summary
Reduced another compiler-owned callback seam by making `LinkedSpec::Compiler::_build_final_descriptor(...)` own the default `spec_gdata` callback, so `run_get_pipeline(...)` no longer threads that callback explicitly during descriptor assembly.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Compiler::_build_final_descriptor(...)`:
  - it now defaults `spec_gdata` to `LinkedSpec::Compiler::spec_gdata(...)` internally,
  - explicit callback injection remains available for focused tests and future internal refactors.
- Simplified `LinkedSpec::Compiler::run_get_pipeline(...)`:
  - final descriptor assembly now calls `_build_final_descriptor($auto_descr_spec)` directly,
  - `run_get_pipeline(...)` no longer threads `\&spec_gdata` as an explicit callback.
- Added focused regression coverage:
  - `run_get_pipeline_defers_default_spec_gdata_callback_to_final_descr_owner`
  - the regression traps `LinkedSpec::Compiler::_build_final_descriptor(...)` and proves the compiler pipeline now leaves the default `spec_gdata` callback undefined at the call site while still returning a valid descriptor.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=129`)
## 2026-03-10 - Phase 1A Slice: Move `spec_descr(...)` Default Callback Into `Compiler`
## Summary
Reduced another façade-owned default by making `LinkedSpec::Compiler::spec_descr(...)` own the default `compile_spec_entry` callback, so `LinkedSpec::spec_descr(...)` is now a pure façade delegate and no longer injects that default itself.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Compiler::spec_descr(...)`:
  - it now defaults `compile_spec_entry` to `LinkedSpec::SpecEntry::compile_spec_entry(...)` internally,
  - injected compile callbacks are still supported for focused tests and alternative compilation paths.
- Simplified `LinkedSpec::spec_descr(...)`:
  - it now delegates directly to `LinkedSpec::Compiler::spec_descr(...)`,
  - default callback ownership no longer lives in `LinkedSpec.pm`.
- Added focused regression coverage:
  - `spec_descr_defers_default_compile_callback_to_compiler_owner`
  - the regression traps `LinkedSpec::Compiler::spec_descr(...)` and proves `LinkedSpec::spec_descr(...)` now delegates without injecting the default callback while still returning a compiled handler.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=128`)
## 2026-03-10 - Phase 1A Slice: Move ParserFactory Default Deps Out of the Facade
## Summary
Reduced another façade-only helper seam by making `LinkedSpec::ParserFactory::run_get_parser(...)` own its default trace/resolution/compile dependency map, so the public `LinkedSpec::get_parser(...)` path no longer depends on the private façade helper `_parser_factory_deps()`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/ParserFactory.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::ParserFactory::run_get_parser(...)`:
  - it now loads its default dependency map from `LinkedSpec::Deps` when no explicit dep hash is supplied,
  - the explicit injected-deps seam remains available for focused tests and internal reuse.
- Simplified `LinkedSpec::get_parser(...)`:
  - it still normalizes flat option pairs locally,
  - parser-factory dispatch now delegates without calling the façade-only `_parser_factory_deps()` helper.
- Added focused regression coverage:
  - `get_parser_avoids_linkedspec_parser_factory_dep_builder`
  - the regression traps `LinkedSpec::_parser_factory_deps()` and proves `get_parser(...)` still returns an executable parser and parses input successfully.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=127`)
## 2026-03-10 - Phase 1A Slice: Normalize `get_parser(...)` Options Before `ParserFactory`
## Summary
Reduced another active raw-argument compatibility seam by making `LinkedSpec::get_parser(...)` normalize its flat option pairs locally and pass a hashref into `LinkedSpec::ParserFactory::run_get_parser(...)`, so the public parser path no longer depends on option-list normalization inside `ParserFactory.pm`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/ParserFactory.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::get_parser(...)`:
  - it now preserves the existing odd-option fallback behavior while normalizing flat option pairs locally,
  - parser-factory dispatch now forwards a normalized option hashref instead of a raw option list.
- Tightened `LinkedSpec::ParserFactory::run_get_parser(...)`:
  - it now treats the option payload as a hashref contract,
  - trace setup, resolution, and compile forwarding continue to use the same option keys and values.
- Added focused regression coverage:
  - `get_parser_normalizes_option_pairs_before_parser_factory`
  - the regression traps `LinkedSpec::ParserFactory::run_get_parser(...)` and proves `get_parser(...)` now passes a normalized option hashref with the expected trace option keys while still returning an executable parser.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=126`)
## 2026-03-09 - Phase 1A Slice: Route `Get(...)` Through `Runtime::run_get`
## Summary
Reduced another active compatibility-wrapper dependency by making `LinkedSpec::Get(...)` normalize its flat option pairs locally and delegate straight to `LinkedSpec::Runtime::run_get(...)`, so the public `Get` path no longer depends on `LinkedSpec::Runtime::run_get_from_args(...)`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Get(...)`:
  - it now extracts the spec scalar ref and normalizes trailing flat option pairs locally,
  - runtime compilation now delegates directly to `LinkedSpec::Runtime::run_get(...)`.
- Preserved compatibility:
  - `LinkedSpec::Runtime::run_get_from_args(...)` remains available as a compatibility wrapper for callers that still invoke the runtime entrypoint with raw flat option pairs,
  - public `Get(...)` behavior and option surface remain unchanged.
- Added focused regression coverage:
  - `get_avoids_runtime_run_get_from_args_wrapper`
  - the regression traps `LinkedSpec::Runtime::run_get_from_args(...)` and proves `LinkedSpec::Get(...)` still returns an executable parser coderef and successfully parses input without touching that wrapper.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=125`)
## 2026-03-09 - Phase 1A Slice: Route ParserFactory Compilation Through `Runtime::run_get`
## Summary
Reduced another active compatibility-wrapper dependency by making `LinkedSpec::ParserFactory` compile specs through `LinkedSpec::Runtime::run_get(...)` with an injected option hashref, so parser-factory compilation no longer depends on `LinkedSpec::Runtime::run_get_from_args(...)`.

## Changed Files
- Updated: `perl/LinkedSpec/ParserFactory.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::ParserFactory::run_get_parser(...)`:
  - it now forwards a normalized option hashref into the injected compile callback,
  - `trace_reset_log` is still stripped before the compile step so parser generation does not reapply reset-only trace handling.
- Updated parser-factory dependency wiring:
  - `LinkedSpec::Deps::parser_factory_deps_for_package(...)` now resolves `compile_spec` from `LinkedSpec::Runtime::run_get(...)` instead of `run_get_from_args(...)`.
- Preserved compatibility:
  - `LinkedSpec::Runtime::run_get_from_args(...)` remains as a compatibility wrapper for raw `Get(...)`-style entrypoints,
  - `LinkedSpec::Get(...)` public behavior is unchanged.
- Extended focused regression coverage:
  - `get_parser_avoids_linkedspec_parser_factory_facade`
  - the regression now also traps `LinkedSpec::Runtime::run_get_from_args(...)` and proves `get_parser(...)` still resolves, compiles, executes, and emits trace output without touching that raw-arg wrapper.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=124`)
## 2026-03-09 - Phase 1A Slice: Move Bootstrap Parse Ownership into `BootstrapSpec`
## Summary
Reduced another compiler/runtime coupling point by making `LinkedSpec::BootstrapSpec` own cached bootstrap grammar state and bootstrap parse execution, while `LinkedSpec::Compiler::run_get_pipeline(...)` now depends only on an injected `bootstrap_parse` callback instead of the raw bootstrap descriptor/index/gdata triple.

## Changed Files
- Updated: `perl/LinkedSpec/BootstrapSpec.pm`
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Expanded `LinkedSpec::BootstrapSpec`:
  - added `cached_bootstrap_state()` to lazily own the shared hardcoded bootstrap grammar state,
  - added `run_bootstrap_parse(...)` as the bootstrap parse owner for runtime/compiler callers.
- Refactored `LinkedSpec::Compiler::run_get_pipeline(...)`:
  - removed direct dependency on `spec_descr`, `bootstrap_rule_index`, and `gdata`,
  - now requires a single injected `bootstrap_parse` callback for the bootstrap parse step.
- Simplified `LinkedSpec::Runtime::run_get(...)`:
  - removed local bootstrap descriptor caching from `Runtime.pm`,
  - now injects `LinkedSpec::BootstrapSpec::run_bootstrap_parse(...)` directly into the compiler pipeline.
- Added focused regression coverage:
  - `compiler_run_get_pipeline_uses_injected_bootstrap_parse_and_runtime_context`
  - the regression proves `run_get_pipeline(...)` succeeds with the new injected `bootstrap_parse` callback plus shared `runtime_ctx`, and invokes the callback exactly once while preserving descriptor generation and parser-source capture.
- Refreshed focused bootstrap-entry tests:
  - targeted spec-entry/runtime tests now use `LinkedSpec::BootstrapSpec::run_bootstrap_parse(...)` directly instead of the older compiler-owned bootstrap parse helper.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=124`)
## 2026-03-09 - Phase 1A Slice: Route SpecEntry Compilation Through `SpecEntry.pm`
## Summary
Reduced another façade-era wrapper by letting `LinkedSpec::SpecEntry::compile_spec_entry(...)` consume the injected runtime context directly for parser-source emission and `top_rule` propagation, so default spec-entry compilation no longer depends on `LinkedSpec::Runtime::compile_spec_entry(...)` except as compatibility glue.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `perl/LinkedSpec/SpecEntry.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::SpecEntry::compile_spec_entry(...)`:
  - it now accepts `runtime_ctx` in its dependency hash,
  - parser-source emission falls back to `runtime_ctx->{emit_parser_source_line}`,
  - discovered `top_rule` is written back into the shared runtime context before returning.
- Simplified default/facade wiring:
  - `LinkedSpec::Runtime::run_get(...)` now injects `LinkedSpec::SpecEntry::compile_spec_entry(...)` directly into the compiler pipeline,
  - `LinkedSpec::spec_descr(...)` now defaults to `LinkedSpec::SpecEntry::compile_spec_entry(...)`,
  - `LinkedSpec::spec_entry(...)` now delegates directly to `SpecEntry.pm`,
  - `LinkedSpec::Runtime::compile_spec_entry(...)` remains only as a compatibility wrapper around the extracted owner.
- Added focused regression coverage:
  - `spec_entry_paths_avoid_runtime_compile_spec_entry_wrapper`
  - the regression traps `LinkedSpec::Runtime::compile_spec_entry(...)` and proves both `LinkedSpec::spec_descr(...)` and `LinkedSpec::Get(..., return_descriptor => 1)` still compile rules successfully without touching that wrapper.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=124`)
## 2026-03-09 - Phase 1A Slice: Collapse Compiler Runtime State Deps into `runtime_ctx`
## Summary
Reduced another compiler/runtime coupling point by making `LinkedSpec::Compiler::run_get_pipeline(...)` consume a single injected runtime context hash for parser-source emission, chunk capture, and `top_rule` propagation instead of threading those mutable state handles as separate dependencies.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Compiler::run_get_pipeline(...)`:
  - added a single required `runtime_ctx` dependency,
  - runtime-context validation now ensures parser-source chunk storage exists on the shared hash,
  - parser-source emission, final `Get` wrapper generation, and `top_rule` reads now all route through `runtime_ctx`.
- Simplified `LinkedSpec::Runtime::run_get(...)`:
  - stopped passing `emit_parser_source_line`, `top_rule_ref`, and `parser_source_chunks_ref` as separate compiler dependencies,
  - now injects the already-existing per-run `runtime_ctx` hash directly into `Compiler.pm`.
- Added focused regression coverage:
  - `compiler_run_get_pipeline_uses_injected_runtime_context`
  - the regression proves `run_get_pipeline(...)` succeeds when only `runtime_ctx` is provided for mutable parser-build state, records `top_rule`, and emits parser-source output through that shared injected context.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=123`)
## 2026-03-09 - Phase 1A Slice: Move Runtime Mutable State into Per-Run Context
## Summary
Reduced another package-global coupling point in `LinkedSpec::Runtime` by moving mutable parser-build state (`top_rule`, parser-source emission) into an injected per-run runtime context hash while keeping the cached bootstrap grammar shared.

## Changed Files
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Runtime`:
  - cached bootstrap state is now grouped in a shared lexical hash (`spec_descr`, `bootstrap_rule_index`, `gdata`),
  - mutable per-run state now lives in a runtime context hash created by `run_get(...)`,
  - parser-source emission now delegates through the injected runtime context instead of package-global `PARSER_SOURCE_EMIT_CB`,
  - `compile_spec_entry(...)` now accepts optional injected runtime context and writes discovered `top_rule` back into that context.
- Preserved behavior:
  - `LinkedSpec::Get(...)` / `LinkedSpec::Runtime::run_get_from_args(...)` still compile and return functional parsers with the same public API,
  - cached bootstrap grammar reuse is unchanged,
  - parser-source dumping and top-rule propagation still work through the compiler pipeline.
- Added focused regression coverage:
  - `runtime_compile_spec_entry_uses_injected_runtime_context`
  - the regression proves `LinkedSpec::Runtime::compile_spec_entry(...)` can compile a parsed entry, emit parser-source chunks, and write `top_rule` into injected state without relying on package-global mutation.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=122`)
## 2026-03-09 - Phase 1A Slice: Decouple ParserFactory from `LinkedSpec.pm` Facade
## Summary
Reduced another modularization-era reach-back into `LinkedSpec.pm` by making parser-factory dependency wiring use `LinkedSpec::Trace`, `LinkedSpec::Resolver`, and `LinkedSpec::Runtime` directly instead of routing trace/config/compile callbacks through façade helpers on `LinkedSpec.pm`.

## Changed Files
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Updated `LinkedSpec::Deps::parser_factory_deps_for_package(...)`:
  - trace/config callbacks now resolve from `LinkedSpec::Trace`,
  - spec validation/path/content callbacks continue to resolve from `LinkedSpec::Resolver`,
  - parser compilation callback now resolves from `LinkedSpec::Runtime::run_get_from_args(...)`,
  - dump-level values now resolve from `LinkedSpec::Trace` instead of `LinkedSpec.pm`.
- Preserved behavior:
  - `LinkedSpec::get_parser(...)` still returns parser coderefs with the same public API,
  - module-relative spec resolution still keeps `PathSearch` unloaded when not needed,
  - trace routing still works, but trace metadata now surfaces the real owning modules (`ParserFactory.pm`, `Resolver.pm`, `Compiler.pm`, etc.) rather than necessarily `LinkedSpec.pm`.
- Added focused regression coverage:
  - `get_parser_avoids_linkedspec_parser_factory_facade`
  - the regression traps the old `LinkedSpec.pm` parser-factory façade helpers/values and proves `get_parser(...)` still creates and executes a parser, keeps `PathSearch` unloaded for module-relative resolution, and emits routed trace output.
- Refreshed trace metadata regression:
  - `trace_output_includes_metadata_and_decisions` now asserts owning-module metadata rather than hardcoding `LinkedSpec.pm`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=121`)
## 2026-03-09 - Phase 1A Slice: Decouple ActionRewriter Lowering from `LinkedSpec.pm` Facade
## Summary
Reduced another modularization-era reach-back into `LinkedSpec.pm` by making `LinkedSpec::ActionRewriter` own the extracted lowering callbacks used by its declare/scanner/contract dependency maps, instead of resolving those callbacks through the façade.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Expanded `LinkedSpec::ActionRewriter`:
  - added local wrapper/dependency-builder helpers for extracted ActionIR modules:
    - `FlowExpr`
    - `ValueExpr`
    - `MethodLowering`
    - `ArrayPipeline`
    - `ControlFlow`
  - direct action-rewriter lowering now stays inside `LinkedSpec::ActionRewriter` for:
    - declare helper lowering
    - value/assignment lowering
    - array-pipeline lowering
    - fluent control-flow lowering
    - return/push/regex-substitution lowering
- Updated `LinkedSpec::Deps`:
  - `action_rewriter_declare_method_deps_for_package(...)` no longer hardcodes `LinkedSpec.pm` for declare/value lowering callbacks,
  - `action_rewriter_scanner_deps_for_package(...)` no longer hardcodes `LinkedSpec.pm` for array-pipeline planning,
  - `action_rewriter_contract_deps_for_package(...)` no longer hardcodes `LinkedSpec.pm` for method/pipeline/control-flow lowering callbacks.
- Added focused regression coverage:
  - `action_rewriter_avoids_removed_linkedspec_lowering_facade`
  - the regression traps the old `LinkedSpec::_...` lowering helper names and proves direct `LinkedSpec::ActionRewriter::call_spec_handler_subst(...)` rewrites still succeed for declare, assign, push, regex, pipeline, flow, switch, and return forms.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=120`)
## 2026-03-09 - Phase 1A Slice: Decouple RuleIR EmitContext from `LinkedSpec.pm` Action-Rewriter Facade
## Summary
Reduced one more modularization-era reach-back into `LinkedSpec.pm` by making `LinkedSpec::RuleIR::EmitContext` call `LinkedSpec::ActionRewriter` directly for rewrite-rule construction, rewrite execution, diagnostic accumulation, and trim helpers.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Updated `LinkedSpec::RuleIR::EmitContext`:
  - added explicit module dependency on `LinkedSpec::ActionRewriter`,
  - introduced local wrapper helpers that delegate to `LinkedSpec::ActionRewriter`,
  - removed remaining direct calls to:
    - `LinkedSpec::_build_action_rewrite_rules(...)`
    - `LinkedSpec::_rewrite_action_code_with_diagnostics(...)`
    - `LinkedSpec::_accumulate_action_rewrite_diagnostics(...)`
    - `LinkedSpec::_trim_action_ir_value(...)`
- Preserved behavior:
  - emit-context assembly still produces rewritten ACODE/BCODE/lifecycle chunks,
  - per-rule `action_rewriter` metadata remains intact,
  - gdata mapping order remains unchanged.
- Added focused regression coverage:
  - `ruleir_emit_context_avoids_linkedspec_action_rewriter_facade`
  - the regression traps the old `LinkedSpec.pm` façade helper names and proves `LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context(...)` still succeeds without them.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=119`)
## 2026-03-09 - CI Slice: Add Shared Local/GitHub Phase-0 Gate
## Summary
Added a repo-root CI entrypoint that can be run locally and from GitHub Actions, and tightened it so the gate only passes when the workflow/script themselves are git-tracked and the exercised LinkedSpec surface stays free of machine-specific absolute paths.

## Changed Files
- Added: `.github/workflows/ci.yml`
- Added: `tools/run_ci_local.sh`
- Updated: `README.md`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added shared CI gate `tools/run_ci_local.sh`:
  - checks required commands: `git`, `perl`, `prove`
  - requires git-tracked CI-critical files:
    - `.github/workflows/ci.yml`
    - `tools/run_ci_local.sh`
    - `perl/LinkedSpec.pm`
    - `t/phase0_regression.t`
  - requires git-tracked CI-critical trees:
    - `specs/`, `plugin/`, `conf/`, `tablescript/`, `ebnf/`, `perl/`, `t/`
  - fails on untracked files under the CI-critical surface, including the workflow directory and shared CI script path
  - audits machine-specific absolute-path literals across:
    - `.github/workflows/ci.yml`
    - `tools/run_ci_local.sh`
    - `t/phase0_regression.t`
    - `perl/LinkedSpec.pm`
    - `perl/LinkedSpec/**`
  - runs:
    - `perl -c perl/LinkedSpec.pm`
    - `perl -c -Iperl t/phase0_regression.t`
    - `prove -v -Iperl t/phase0_regression.t`
- Added `.github/workflows/ci.yml`:
  - triggers on `push`, `pull_request`, and `workflow_dispatch`
  - delegates directly to `bash tools/run_ci_local.sh` so local and GitHub validation stay aligned
- Verified the enforcement gap was closed:
  - before staging the new CI files, the gate failed because `.github/workflows/ci.yml` was not git-tracked
  - after staging the CI files, the gate passed cleanly
- Scope note:
  - the absolute-path audit now covers the CI-exercised LinkedSpec surface
  - older literals remain in non-LinkedSpec/non-gated files such as `perl/env.conf` and `perl/EasyTk.pm`

## Validation
- Ran:
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=118`)
## 2026-03-09 - Phase 1A Slice: Inject `compile_spec_entry` into `Compiler.pm`
## Summary
Reduced one more internal reverse dependency in the modularization track by making `LinkedSpec::Compiler` consume an injected `compile_spec_entry` callback during spec-descriptor assembly instead of calling back into `LinkedSpec.pm` directly.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Compiler::spec_descr(...)`:
  - it now requires a `compile_spec_entry` callback,
  - it no longer reaches back into `LinkedSpec::spec_entry(...)` while iterating parsed bootstrap entries.
- Refactored `LinkedSpec::Compiler::run_get_pipeline(...)`:
  - it now requires injected dependency `compile_spec_entry`,
  - descriptor assembly passes that callback through to `spec_descr(...)`.
- Updated `LinkedSpec::Runtime::run_get(...)`:
  - runtime pipeline wiring now injects `\&compile_spec_entry` into compiler dependencies so top-rule propagation stays owned by `Runtime.pm`.
- Preserved public compatibility surface:
  - `LinkedSpec::spec_descr(...)` still works with its existing public signature,
  - the façade now supplies `\&LinkedSpec::Runtime::compile_spec_entry` to the compiler internally.
- Added focused regression coverage:
  - `compiler_spec_descr_uses_injected_compile_spec_entry_callback`
  - locks that `LinkedSpec::Compiler::spec_descr(...)` can build a rule descriptor through an injected callback and still returns a compiled handler.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=118`)
## 2026-03-09 - Roadmap Slice: Add `array_copy(...)` Snapshot Alias
## Summary
Added clearer backend-neutral snapshot helper `array_copy(array(...))` as the preferred alias for `array_values(array(...))`, while keeping the older spelling fully supported and updating the lowering guides to present the new name as the canonical surface.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/FlowExpr.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_ArrayPipeline.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `USER_GUIDE_ActionIR_EmittedPerlReference.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `USER_GUIDE_ActionIR_ValueExpr.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added snapshot-helper alias recognition in canonical lowering:
  - `array_copy(array(target))` now lowers to `[@target]`,
  - legacy `array_values(array(target))` is unchanged and still lowers to the same emitted Perl shape.
- Routed the alias through every existing array-snapshot lowering surface:
  - direct method-value lowering in `MethodLowering::_lower_method_value_expr`,
  - generalized `return(payload)` direct helper detection and nested helper rewriting in `_lower_return_payload_expr`,
  - flow/value passthrough recognition in `ActionIR::FlowExpr`.
- Expanded focused regression coverage:
  - `action_rewriter_lowers_array_snapshot_and_array_assign_method_contracts` now covers `array_copy(...)` in `push_value(...)`, plain `return(payload)`, structured hash payloads, and descriptor readiness through an inline `return(array_copy(array(items)))` spec.
- Documentation cleanup:
  - the top-level guide and ActionIR references now present `array_copy(...)` as the preferred snapshot helper for new DSL authoring,
  - `array_values(...)` is now documented explicitly as preserved compatibility syntax rather than the preferred new spelling.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=117`)
## 2026-03-09 - Roadmap Slice: Migrate `tkgui` Entry-Point Print to Canonical Helper Flow
## Summary
Cleared the remaining `tkgui.spec` blocker by replacing the last raw entry-point debug print in `sub_gui` with canonical helper `print(...)`, while preserving both the printed message and the parser’s current one-entry hash result shape.

## Changed Files
- Updated: `specs/tkgui.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Selected `tkgui.spec` as the next deterministic tail slice because after the `pplugin` cleanup it was the final remaining blocked non-deferred spec (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`).
- Cleared the blocked `tkgui` rule:
  - `sub_gui`
- Reworked the `sub_gui` initializer print:
  - retained the existing `my ($subgui_name) = @IMATCH_LIST` destructuring,
  - replaced raw debug print `print "Found a SUB GUI entry point <$subgui_name>\n"` with:
    - `print("Found a SUB GUI entry point <", scalar(subgui_name), ">\n")`
- Important migration nuance:
  - the blocker was only the interpolated debug print; the existing return shape was already flowing through recognized helper lowering,
  - preserving behavior meant keeping the current output string unchanged even though the parser’s resulting hash shape is non-obvious,
  - the new smoke regression deliberately locks that current one-entry hash result instead of “fixing” it as part of this migration slice.
- Added focused regression coverage:
  - `tkgui_helper_flow_eliminates_raw_fallback`
  - `tkgui_parser_smoke`
  - these lock zero raw fallback, zero unresolved-helper hits, zero blocked-rule summary state, preserved entry-point print output, and the current one-entry hash result on a compact inline sample with a top-level comment.
- Updated blocker scan after the slice:
  - `tkgui.spec` no longer appears in the blocked-spec ranking
  - current non-deferred action-rewriter migration scan result:
    - zero blocked specs (`__BLOCKED_COUNT__=0`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=117`)
## 2026-03-09 - Roadmap Slice: Migrate `pplugin` Top Accumulator to Canonical Helper Flow
## Summary
Cleared the remaining `pplugin.spec` blocker by replacing the last raw list-splice in `pplugin_top` with canonical collection-target assignment, while preserving the parser’s returned hash-of-coderefs behavior for parsed `.plg` files.

## Changed Files
- Updated: `specs/pplugin.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Selected `pplugin.spec` as the next deterministic tail slice because after the `portmap` cleanup it had become the highest remaining one-rule blocker (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`).
- Cleared the blocked `pplugin` rule:
  - `pplugin_top`
- Reworked the top accumulator flow:
  - retained the existing initializer and child call shape (`my @defs; my $retv` and `$retv = call(subdef)`),
  - replaced raw splice `push @defs, @$retv` with canonical collection-target assignment:
    - `assign(array(defs), array(flat_array(defs), scalaref(retv, [0]), scalaref(retv, [1])))`
- Important migration nuance:
  - the blocker was not the child call itself but the flat list-splice of the returned `[name, coderef]` pair,
  - rebuilding `@defs` through `assign(array(...), array(...))` preserved the original flat `name => coderef` list semantics expected by the existing `return {@defs}` path,
  - this avoided adding new lowering contracts or changing the parser’s output contract.
- Added focused regression coverage:
  - `pplugin_helper_flow_eliminates_raw_fallback`
  - `pplugin_parser_smoke`
  - these lock zero raw fallback, zero unresolved-helper hits, zero blocked-rule summary state, and preserved returned hash/coderef execution behavior on a small inline plugin sample with comments.
- Updated blocker scan after the slice:
  - `pplugin.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=115`)
## 2026-03-08 - Roadmap Slice: Capture Plugin Modernization and `PathSearch` Strategy
## Summary
Recorded the missing roadmap commitment to replace the current `AUTOLOAD` + `.plg` plugin runtime with a clearer module-based plugin system, and documented the short-term decision to keep `PathSearch->go(...)` as a compatibility surface while hardening/replacing its internals rather than removing it outright.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `CHANGES.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Root cause for the roadmap gap:
  - existing docs only captured the lazy-loading cleanup (`LinkedSpec::PluginBridge`, lazy `PPlugin` load, lazy `PathSearch` fallback),
  - they did not explicitly state that the current plugin runtime itself is planned for later replacement.
- Captured current plugin-runtime behavior in the notes:
  - `LinkedSpec::AUTOLOAD` delegates to `LinkedSpec::PluginBridge::dispatch_autoload(...)`,
  - the bridge lazy-loads `PPlugin`,
  - `PPlugin` builds a cached registry from cwd `*.plg` plus project `plugin/*.plg`, parses those files via `pplugin.spec`, and dispatches plugins by extracted method-name suffix.
- Captured current `PathSearch` behavior in the notes:
  - `PathSearch->go(...)` seeds a mutable `state $search_path` from cwd plus a recursive project-tree walk,
  - extra directories are merged by hash dedupe and unordered `keys %hash`,
  - misses currently warn and return `undef`.
- Recorded roadmap direction:
  - plugin runtime: migrate toward explicit module/package plugins and registry/loader semantics, with `AUTOLOAD` + `.plg` kept only as a compatibility bridge during transition,
  - `PathSearch`: keep the public API short-term because it is still used by parser resolution, config loading, GUI/resource lookup, FSM loading, and plugin helpers, but rework the implementation around deterministic search roots, lazy walking, better diagnostics, and later CPAN-backed primitives,
  - keep this track orthogonal to Backbone item #3 so `pplugin.spec` cleanup can proceed without treating the current runtime as the final architecture.

## Validation
- Not run (`ROADMAP.md` / notes-only update)
## 2026-03-08 - Roadmap Slice: Migrate `portmap` Bare-Bit-Slice Classification to Canonical Helper Flow
## Summary
Cleared the remaining `portmap.spec` blocked rule by rewriting `bare_bit_slice` from a raw Perl smartmatch classifier into canonical helper control flow, while preserving the existing `bare` / `bit` / `slice` / `constant` AST shapes and explicitly locking the `bit[0]` edge case.

## Changed Files
- Updated: `specs/portmap.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Selected `portmap.spec` as the next slice because after the `sdce` cleanup it was the highest remaining blocked spec (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`).
- Cleared the blocked `portmap` rule:
  - `bare_bit_slice`
- Reworked `bare_bit_slice` into canonical helper flow:
  - raw `$mcnt = @IMATCH_LIST` / smartmatch classification logic was replaced with helper `if` / `elseif` / `else` branches,
  - helper returns now use `return(array("?kind:", array(flat_array(IMATCH_LIST))))`,
  - classification now branches on:
    - `matches(scalar(IMATCH), /:/)` for `slice`,
    - `or(eq(scalar(IMATCH_LIST, 1), "0"), is_nonempty(scalar(IMATCH_LIST, 1)))` for `bit`,
    - `matches(scalar(IMATCH_LIST, 0), /^\\d/io)` for `constant`,
    - final `else()` for `bare`.
- Important migration nuance:
  - `is_nonempty(scalar(IMATCH_LIST, n))` on indexed captures lowers through truthiness rather than strict defined/nonempty string checks,
  - because of that, zero-valued indices such as `bar[0]` and slice low bits such as `baz[7:0]` needed explicit classification logic instead of a naive truthiness test,
  - using `matches(scalar(IMATCH), /:/)` for slice detection plus the explicit `eq(..., "0")` guard for `bit` preserved the original zero-valued cases without reintroducing raw Perl.
- Behavior cleanup side effect:
  - the old raw classifier emitted Perl experimental smartmatch warnings during parsing,
  - the helper rewrite removes that warning path while keeping the AST contract unchanged.
- Added focused regression coverage:
  - `portmap_bare_bit_slice_helper_flow_eliminates_raw_fallback`
  - `portmap_bare_bit_slice_classification_smoke`
  - these lock zero raw fallback, zero unresolved-helper hits, canonical node coverage, zero blocked-rule summary state, and representative AST classification cases including `bar[0]`.
- Updated blocker scan after the slice:
  - `portmap.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=113`)
## 2026-03-08 - Roadmap Slice: Migrate `sdce` to Canonical Helper Flow
## Summary
Cleared the remaining `sdce.spec` blocked rules by rewriting the top accumulator and nested pin/port tokenization flow into canonical helper actions, removing raw push/substr/split chains while preserving parser output shape.

## Changed Files
- Updated: `specs/sdce.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Selected `sdce.spec` as the next slice because after the `lib_reader` cleanup it was the highest remaining blocked spec (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`).
- Cleared the blocked `sdce` rules:
  - `sdc_esplit`
  - `get_pinport`
- Reworked `sdc_esplit` into canonical helper flow:
  - initializer now uses `I.declare(array, pieces).declare(scalar, retv).assign(scalar(IPOS), 0)`
  - child dispatch accumulation now uses `assign(scalar(retv), call(get_pinport))` plus `push_value(array(pieces), scalar(retv))`
  - plain substring captures now use helper-shell `assign(...)` plus `push_value(...)`
  - rule exit now uses `return(array_values(array(pieces)))`
- Reworked `get_pinport` into canonical helper flow:
  - initializer now uses `I.declare(array, pieces)`
  - plain-text segment tokenization now uses `split(..., /(\\s+)/)` plus `filter_nonempty(...)`
  - brace-content tokenization now uses `split(..., /\\s+/)` plus `filter_nonempty(...)`
  - append semantics are preserved with `assign(array(pieces), array(flat_array(pieces), flat_array(segment_parts)))`
  - structured return now uses `return(array(flat_array(IMATCH_LIST), array_values(array(pieces))))`
- Important migration nuance:
  - `split(array(segment_parts), scalar(segment), /(\\s+)/)` was needed on the `LS` path to preserve the original interstitial whitespace tokens from raw `split /(\\s+)/`,
  - `split(..., /\\s+/)` on the brace path preserved the old non-whitespace token behavior from `=~ /\\S+/og`,
  - array reassignment with `flat_array(...)` provided a canonical replacement for the old raw `push @pieces, LIST` splice behavior.
- Added focused regression coverage:
  - `sdce_helper_flow_eliminates_raw_fallback`
  - locks per-rule zero raw fallback, zero unresolved-helper hits, canonical node coverage, and descriptor-level zero-blocker summary state for `sdce`
- Manual semantic spot-checks on representative inputs remained unchanged, including bracketed pin/port lists with whitespace and nested brace content.
- Updated blocker scan after the slice:
  - `sdce.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=111`)
## 2026-03-08 - Roadmap Slice: Migrate `lib_reader` to Canonical Helper Flow
## Summary
Cleared the remaining `lib_reader.spec` blocked rules by rewriting the initializer and attribute-normalization logic into canonical helper flow, using method-chain initializer syntax where the brace-block helper form still left raw-fallback metadata.

## Changed Files
- Updated: `specs/lib_reader.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Selected `lib_reader.spec` as the next slice because it had become the highest remaining blocked spec after the `DT` + `hlink_substitution` cleanup (`BLOCKED=3`, `TOP=group`, `BLOCKERS=4`).
- Cleared the blocked `lib_reader` rules:
  - `group`
  - `sattribute`
  - `cattribute`
- Rewrote the old raw cleanup paths into helper flow:
  - `group`
    - moved the initializer into method-chain form:
      - `I.declare(scalar, grouptype=scalar(IMATCH_LIST, 0), groupname=scalar(IMATCH_LIST, 1)).substr(scalar(groupname), "\"", "", go)`
    - migrated the close action to:
      - `.return(array("GROUP", scalar(grouptype), scalar(groupname), array_values(array(group))))`
    - migrated the syntax-error branch to canonical `say(...)` helper syntax plus `exit 1`
  - `sattribute`
    - migrated to method-chain form:
      - `I.declare(...).substr(...).return(array("SATTRIBUTE", ...))`
  - `cattribute`
    - migrated to method-chain form:
      - `I.declare(...).declare(array, value_items).substr(...).split(...).return(array("CATTRIBUTE", ..., array_values(array(value_items))))`
- Important nuance discovered during the slice:
  - the direct brace-block helper form for these initializer rules still reported raw-fallback metadata even though `call_spec_handler_subst(...)` could lower the same helper statements correctly in isolation,
  - switching those initializers to the existing method-chain form (`I.declare(...).substr(...).return(...)`) cleared the raw-fallback counts and made the rules language-agnostic-action-IR ready.
- Added focused regression coverage:
  - `lib_reader_helper_flow_eliminates_raw_fallback`
  - locks zero raw fallback, zero unresolved-helper hits, readiness, and zero blocked-rule summary state for `lib_reader`
- Updated blocker scan after the slice:
  - `lib_reader.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `sdce.spec` (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`)
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=110`)
## 2026-03-08 - Roadmap Slice: Migrate `hlink_substitution` to Canonical Helper Flow
## Summary
Cleared the remaining `hlink_substitution.spec` blocked rules by converting the raw error prints to canonical `print(...)` helper flow and rewriting the top accumulator rule into canonical helper flow with declarations, handler-call assignment, helper push, and helper return logic.

## Changed Files
- Updated: `specs/hlink_substitution.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Chose `hlink_substitution.spec` over the tied `lib_reader.spec` candidate because it was the lower-risk slice:
  - `hlink_substitution` blockers were limited to raw error prints plus one simple accumulator push in `substitute_top`
  - `lib_reader` still wants conditional regex-substitution cleanup in three rules
- Cleared the blocked `hlink_substitution` rules:
  - `substitute_top`
  - `substitute_statement2`
  - `curlyb`
- Reworked `substitute_top` into canonical helper flow:
  - declarations now use `declare(scalar, retv); declare(array, word_items)`
  - child dispatch assignments now use `assign(scalar(retv), call(...))`
  - the loop-end accumulator now uses `push_value(array(word_items), scalar(retv))`
  - the rule exit now uses helper control flow:
    - `if(is_nonempty(array(word_items))); return(array_values(array(word_items))); else(); return_undef(); endif()`
- Replaced the remaining raw error prints with canonical helper calls:
  - dangling closing bracket in `substitute_top`
  - unmatched closing bracket in `substitute_statement2`
  - unmatched closing brace in `curlyb`
- Added focused regression coverage:
  - `hlink_substitution_helper_flow_eliminates_raw_fallback`
  - locks per-rule zero raw fallback, zero unresolved-helper hits, node coverage, and descriptor-level zero-blocker summary state
- Updated blocker scan after the slice:
  - `hlink_substitution.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `lib_reader.spec` (`BLOCKED=3`, `TOP=group`, `BLOCKERS=4`)
    - `sdce.spec` (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`)
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=109`)
## 2026-03-08 - Roadmap Slice: Migrate `DT` Debug Prints to Canonical Helper Flow
## Summary
Cleared the remaining `DT.spec` blocked rules by converting all raw debug `print` statements to canonical `print(...)` helper flow, added a focused regression lock, and refreshed the blocker snapshot after the slice.

## Changed Files
- Updated: `specs/DT.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Selected `DT.spec` immediately after the `operators_try` commit because it became the highest remaining blocked spec in the corpus scan (`BLOCKED=11`, `TOP=group`, `BLOCKERS=14`).
- Confirmed that the entire `DT.spec` blocker surface was raw debug prints only, so the slice required no new lowering contracts.
- Migrated the remaining blocked `DT` rules:
  - `dtree`
  - `testcontrol`
  - `group`
  - `identifier`
  - `if_binary`
  - `if_vector`
  - `reg_assignment_lhs`
  - `state_transition`
  - `dtree_call`
  - `logical_operator`
  - `inline_dt_definition`
- Replaced raw `print "..."` actions with canonical `print(...)` helper flow throughout the spec.
- Re-expressed the old interpolated `($IMATCH)` diagnostics with canonical helper arguments using `scalar(IMATCH)`, e.g. `print("(identifier)(", scalar(IMATCH), ")\n")`.
- Added focused regression coverage:
  - `dt_debug_print_helper_flow_eliminates_raw_fallback`
  - locks per-rule zero raw fallback, canonical `PRINT` node coverage, and descriptor-level zero-blocker summary state.
- Updated blocker scan after the slice:
  - `DT.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `hlink_substitution.spec` (`BLOCKED=3`, `TOP=substitute_top`, `BLOCKERS=4`)
    - `lib_reader.spec` (`BLOCKED=3`, `TOP=group`, `BLOCKERS=4`)
    - `sdce.spec` (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`)
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=108`)
## 2026-03-08 - Roadmap Slice: Migrate `operators_try` Debug Prints to Canonical Helper Flow
## Summary
Cleared the remaining `operators_try` blocked rules by converting all raw debug `print` statements to canonical `print(...)` helper flow, added a focused regression lock, and refreshed the live notes with the new post-slice blocker ranking.

## Changed Files
- Updated: `specs/operators_try.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Selected `operators_try` as the next slice because the corpus-level migration summary had it as the highest remaining blocked spec (`BLOCKED=13`, `BLOCKERS=16`) and every blocker statement in the inspected rules was a raw debug print, so no new lowering contracts were required.
- Migrated the remaining blocked `operators_try` rules:
  - `top_expression`
  - `group`
  - `function_call`
  - `string`
  - `auto_inc_op`
  - `auto_dec_op`
  - `div_op`
  - `mul_op`
  - `add_op`
  - `sub_op`
  - `string_concat`
  - `variable`
  - `integer`
- Replaced raw `print "..."` actions with canonical `print(...)` helper flow throughout the spec.
- Re-expressed the old interpolated `($IMATCH)` diagnostics with canonical helper arguments using `scalar(IMATCH)`, e.g. `print("-> (", scalar(IMATCH), ") auto_inc_op\n")`.
- Removed the leftover nested `I { ... }` wrapper inside the `group[1]` closing action so the rule no longer contributed a residual raw fallback statement.
- Added focused regression coverage:
  - `operators_try_debug_print_helper_flow_eliminates_raw_fallback`
  - locks per-rule zero raw fallback, canonical `PRINT` node coverage, and descriptor-level zero-blocker summary state.
- Updated blocker scan after the slice:
  - `operators_try` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `DT.spec` (`BLOCKED=11`, `TOP=group`, `BLOCKERS=14`)
    - `hlink_substitution.spec` (`BLOCKED=3`, `TOP=substitute_top`, `BLOCKERS=4`)
    - `lib_reader.spec` (`BLOCKED=3`, `TOP=group`, `BLOCKERS=4`)
    - `sdce.spec` (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`)
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=107`)
## 2026-03-08 - Roadmap Slice: Migrate `Lispish::parenthesis` and Finalize the Exhaustive Lowering Guide Set
## Summary
Completed the last outstanding `Lispish` blocker by migrating `Lispish::parenthesis` off raw Perl fallback, added canonical assignment-source lowering for `call(rule)`, and finished the lowering documentation pass with a hub, module-focused guides, and an exhaustive emitted-Perl reference for the current ActionIR surface.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/ValueExpr.pm`
- Updated: `specs/Lispish.spec`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_DeclareMethod.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `USER_GUIDE_ActionIR_ValueExpr.md`
- Updated: `USER_GUIDE_ActionIR_FlowExpr.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `USER_GUIDE_ActionIR_ArrayPipeline.md`
- Updated: `USER_GUIDE_ActionIR_Contracts.md`
- Updated: `USER_GUIDE_ActionIR_EmittedPerlReference.md`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added canonical method-value lowering for `call(rule)` in `MethodLowering.pm` and taught assignment-source lowering in `ValueExpr.pm` to route `assign(scalar(retv), call(rule))` through that path instead of leaving it as a raw wrapper.
- Cleared `Lispish::parenthesis` by replacing the old raw state machine:
  - removed raw declarations `my @submatchs; my @word; my $retv`
  - removed raw call-wrapper assignments such as `$retv = call(parenthesis)`
  - removed the raw `LE { ... }` post-dispatch classification block
  - replaced them with canonical helper flow using:
    - `declare(array, word, tail)`
    - `declare(scalar, retv, head, has_head)`
    - `assign(scalar(retv), call(parenthesis))`
    - `push_value(array(word), scalaref(retv, {content}))`
    - `join_values("", array(word))`
    - `if/else/endif`
    - `return(array(...))`
- Preserved the existing recursive Lispish AST semantics while re-expressing the rule as explicit head/tail accumulation:
  - the first completed item becomes `head`
  - later completed items are accumulated into `tail`
  - empty list remains `return(array(undef))`
  - single-item list remains `return(array(scalar(head), undef))`
  - multi-item list remains `return(array(scalar(head), array_values(array(tail))))`
- Added/updated regressions:
  - extended `action_rewriter_lowers_method_contracts_for_capture_and_structured_return_values` with a direct lock for `assign(scalar(retv), call(Leaf))`
  - refreshed `lispish_small_helper_flow_eliminates_raw_fallback` to the final zero-blocker state
  - added `lispish_parenthesis_helper_flow_eliminates_raw_fallback`
  - kept `lispish_ast_smoke` passing to preserve the baseline nested AST shape
- Post-migration metadata snapshot:
  - `Lispish::parenthesis`: `raw_perl_dependency_count` `6 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `Lispish::parenthesis` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, `PUSH`, `IF`, `CALL`, and `RETURN`
  - `Lispish` descriptor migration summary: `language_agnostic_blocked_rule_count` `1 -> 0`
- Documentation scope:
  - rewrote `USER_GUIDE.md` into a navigation hub that explains portability tiers, common lowering patterns, and inspection workflow
  - added module-focused lowering references for:
    - `DeclareMethod.pm`
    - `MethodLowering.pm`
    - `ValueExpr.pm`
    - `FlowExpr.pm`
    - `ControlFlow.pm`
    - `ArrayPipeline.pm`
    - `Contracts.pm`
  - added `USER_GUIDE_ActionIR_EmittedPerlReference.md` as the exhaustive lowering-contract review document:
    - enumerates the preferred canonical helper surface,
    - enumerates compatibility helpers such as `return_a`, `return_m`, `return_ma`, `return_im`, `return_imatch`, `return_array`, capture/backtrack helpers, and raw call wrappers,
    - enumerates classified pass-through idioms that are preserved verbatim while still counting as canonical ActionIR rather than `RAW_PERL` fallback,
    - shows the emitted Perl shape for each documented construct
  - documented the preferred canonical replacement of raw `$retv = call(rule)` wrappers with `assign(scalar(retv), call(rule))`
  - added broader examples for declarations, value constructors, assignment, control flow, array pipelines, regex substitution, switch regex cases, and compatibility helper surfaces
  - cross-linked the module guides back to the exhaustive emitted-Perl reference so review can start either from the top-level hub or from the relevant ActionIR module guide

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=106`)
## 2026-03-08 - Roadmap Slice: Migrate `vhdl::subprogram_body` to Canonical Helper Flow
## Summary
Advanced roadmap Item #3 by adding a small backend-neutral array tokenization helper and using it to migrate `vhdl::subprogram_body` off raw Perl fallback, clearing the last blocked `vhdl` rule.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
- Updated: `perl/LinkedSpec/ActionIR/Contracts.pm`
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added backend-neutral array tokenization helper:
  - `split_each(array(...), /.../)`
  - lowers as a composable flattened per-element split stage and now surfaces canonical `SPLIT_EACH` action-IR metadata.
- Cleared `vhdl::subprogram_body` by replacing the raw init/finalization block with helper flow:
  - `declare(scalar, pos_begin, subprogram_statement_part); declare(array, subprogram_statement_tokens)`
  - `assign(scalar(pos_begin), pos $$STRING)`
  - `assign(scalar(subprogram_statement_part), substr($$STRING, $pos_begin, $LSPOS - $pos_begin - length $LMATCH))`
  - `split(array(subprogram_statement_tokens), scalar(subprogram_statement_part), /((?:\s*--.*\s*)+|\s*;\s*)/)`
  - `split_each(array(subprogram_statement_tokens), /^(\s+)/)`
  - `filter_nonempty(array(subprogram_statement_tokens))`
  - `return(array("?subprogram_body:", flat_array(IMATCH_LIST), array_values(array(subprogram_statement_tokens))))`
- Preserved the previous tokenization behavior while removing the raw Perl `grep {length} map {split /^(\s+)/o} split ...` fallback path.
- Added focused regression coverage:
  - `vhdl_subprogram_body_helper_flow_eliminates_raw_fallback`
- Refreshed older VHDL snapshot tests:
  - `vhdl_declaration_helper_flow_eliminates_raw_fallback`
  - `vhdl_small_blocker_helper_flow_eliminates_raw_fallback`
  - `vhdl_process_statement_helper_flow_eliminates_raw_fallback`
  - each now expects the later zero-blocker state after `subprogram_body` cleanup.
- Post-migration metadata snapshot:
  - `vhdl::subprogram_body`: `raw_perl_dependency_count` `5 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl::subprogram_body` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, `SPLIT`, `SPLIT_EACH`, `FILTER_NONEMPTY`, `RETURN`, and existing `CALL`
  - `vhdl` descriptor migration summary: `language_agnostic_blocked_rule_count` `1 -> 0`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=105`)
## 2026-03-07 - Roadmap Slice: Migrate `ds_vhistory::vhistory` to Canonical Helper Flow
## Summary
Advanced roadmap Item #3 by migrating `ds_vhistory::vhistory` off raw Perl fallback using the existing helper surface, clearing the last blocked `ds_vhistory` rule without adding new lowering contracts.

## Changed Files
- Updated: `specs/ds_vhistory.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Cleared `ds_vhistory::vhistory` without adding new helper surface:
  - replaced the raw declaration block `my (@vhistory, @capt, @object_hier, $cur_object)` with canonical declaration flow:
    - `declare(array, vhistory, capt, object_hier)`
    - `declare(scalar, cur_object, first_capt, entry_tag, current_object_name)`
  - replaced the raw capture/object-hierarchy flush logic with helper flow using:
    - `if(is_nonempty(array(capt)))`
    - `assign(scalar(first_capt), scalar(array(capt), 0))`
    - `if(eq(scalaref(first_capt, [0]), "?branch:")) ... else() ... endif()`
    - `push_value(array(object_hier), array(scalar(entry_tag), array_values(array(capt))))`
  - replaced in-place arrayref mutation `push @$cur_object, [@object_hier]` with direct construction of the finalized object payload before pushing into `vhistory`:
    - `assign(scalar(current_object_name), scalaref(cur_object, [1]))`
    - `push_value(array(vhistory), array("?object:", scalar(current_object_name), array_values(array(object_hier))))`
  - replaced the raw final return `['?ds_vhistory:', \@vhistory]` with:
    - `return(array("?ds_vhistory:", array_values(array(vhistory))))`
  - migrated the debug print to canonical helper form:
    - `print("\tObject   ", scalaref(cur_object, [1]), "\n")`
- Added focused regression coverage:
  - `ds_vhistory_vhistory_helper_flow_eliminates_raw_fallback`
- Post-migration metadata snapshot:
  - `ds_vhistory::vhistory`: `raw_perl_dependency_count` `5 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `ds_vhistory::vhistory` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, `IF`, `ELSE`, `ENDIF`, `PUSH`, `RETURN`, `CALL`, and `PRINT`
  - `ds_vhistory` descriptor migration summary: `language_agnostic_blocked_rule_count` `1 -> 0`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=104`)
## 2026-03-07 - Roadmap Slice: Migrate `vhdl::process_statement` to Canonical Helper Flow
## Summary
Advanced roadmap Item #3 by migrating `vhdl::process_statement` off raw Perl fallback using the existing helper surface, reducing the `vhdl` blocked-rule set from two rules to only `subprogram_body`.

## Changed Files
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Cleared `vhdl::process_statement` without adding new helper surface:
  - replaced raw declaration block `my $pos_begin` with canonical declaration flow:
    - `declare(scalar, pos_begin, process_statement_part)`
  - replaced raw position capture `$pos_begin = pos $$STRING` with:
    - `assign(scalar(pos_begin), pos $$STRING)`
  - replaced raw substring/return logic with:
    - `assign(scalar(process_statement_part), substr($$STRING, $pos_begin, $LSPOS - $pos_begin - length $LMATCH))`
    - `return(array("?process_statement:", flat_array(IMATCH_LIST), array_values(array(process_statement)), scalar(process_statement_part)))`
- Removed the leftover commented raw debug-print statements from the action blocks so the rule no longer contributes raw fallback metadata.
- Added focused regression coverage:
  - `vhdl_process_statement_helper_flow_eliminates_raw_fallback`
- Refreshed older VHDL snapshot tests:
  - `vhdl_declaration_helper_flow_eliminates_raw_fallback` now expects the later `process_statement` cleanup state
  - `vhdl_small_blocker_helper_flow_eliminates_raw_fallback` now reflects that only `subprogram_body` remains blocked
- Post-migration metadata snapshot:
  - `vhdl::process_statement`: `raw_perl_dependency_count` `4 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl::process_statement` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, `RETURN`, plus existing `CALL`/`PUSH`
  - `vhdl` descriptor migration summary: `language_agnostic_blocked_rule_count` `2 -> 1`, with blocked-rule priority list now reduced to `['subprogram_body']`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=103`)
## 2026-03-07 - Roadmap Slice: Clear the Remaining Small Lispish Blockers
## Summary
Advanced roadmap Item #3 by migrating the remaining small `Lispish` blockers — `Lispish`, `sbrackets`, `dquotes`, `squotes`, `curlyb`, `spaces`, `others`, and `comments` — off raw Perl fallback using the existing helper surface, reducing the `Lispish` blocked-rule set from nine rules to only `parenthesis`.

## Changed Files
- Updated: `specs/Lispish.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Cleared the top-level `Lispish` syntax-error branch:
  - replaced the raw form `say "(Lispish) -E- Syntax Error"` with canonical helper-call syntax:
    - `say("(Lispish) -E- Syntax Error")`
  - preserved the existing hard exit behavior with `exit 1`.
- Migrated the small token/leaf rules to canonical structured returns:
  - `sbrackets` now returns `hash("type", "SBRACKETS", "content", scalar(IMATCH))`
  - `dquotes` now returns `hash("type", "DQUOTES", "content", scalar(IMATCH_LIST, 0))`
  - `squotes` now returns `hash("type", "SQUOTES", "content", scalar(IMATCH_LIST, 0))`
  - `spaces` now returns `hash("type", "SPACE", "content", scalar(IMATCH))`
  - `others` now returns `hash("type", "OTHERS", "content", scalar(IMATCH))`
  - `comments` now returns `hash("type", "COMMENTS", "content", scalar(IMATCH))`
- Migrated `curlyb` to canonical helper flow:
  - added `declare(scalar, content)`
  - replaced the raw capture/return block with:
    - `assign(scalar(content), CAPTURE)`
    - `return(hash("type", "CBRACE", "content", scalar(content)))`
- Added focused regression coverage:
  - `lispish_small_helper_flow_eliminates_raw_fallback`
- Post-migration metadata snapshot:
  - `Lispish`, `comments`, `curlyb`, `dquotes`, `others`, `sbrackets`, `spaces`, and `squotes` now each report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `curlyb` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, and `RETURN`
  - top-level `Lispish` canonical action-IR nodes now include `SAY`
  - `Lispish` descriptor migration summary: `language_agnostic_blocked_rule_count` `9 -> 1`, with blocked-rule priority list now reduced to `['parenthesis']`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=102`)
## 2026-03-07 - Roadmap Slice: Clear the Remaining Small VHDL Blockers
## Summary
Advanced roadmap Item #3 by clearing the remaining small `vhdl` blockers — `signal_declaration`, `configuration_specification`, and `vhdl_file` — without adding new helper surface, reducing the `vhdl` blocked-rule set from five rules to just `subprogram_body` and `process_statement`.

## Changed Files
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Cleared `vhdl::signal_declaration`:
  - replaced raw rest-arity destructuring `my ($identifier_list, @remainder_info) = @IMATCH_LIST` with fixed-arity scalar destructuring:
    - `my ($identifier_list, $subtype_indication, $signal_kind, $expression) = @IMATCH_LIST`
  - preserved the existing return shape while removing the only remaining raw blocker statement for the rule.
- Cleared `vhdl::configuration_specification`:
  - replaced raw rest-arity destructuring `my ($instantiation_list, @remainder_info) = @IMATCH_LIST` with fixed-arity scalar destructuring:
    - `my ($instantiation_list, $component_name, $binding_indication) = @IMATCH_LIST`
  - preserved the existing return shape while removing the only remaining raw blocker statement for the rule.
- Cleared `vhdl::vhdl_file`:
  - removed the leftover line-buffering side effect `I {$|=1}`
  - kept the parser rule behavior unchanged apart from dropping that non-portable startup side effect.
- Added focused regression coverage:
  - `vhdl_small_blocker_helper_flow_eliminates_raw_fallback`
- Refreshed the older declaration-slice snapshot test:
  - `vhdl_declaration_helper_flow_eliminates_raw_fallback` now expects the later post-cleanup blocked-rule count.
- Post-migration metadata snapshot:
  - `vhdl::signal_declaration`: `raw_perl_dependency_count` `1 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl::configuration_specification`: `raw_perl_dependency_count` `1 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl::vhdl_file`: `raw_perl_dependency_count` `1 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl` descriptor migration summary: `language_agnostic_blocked_rule_count` `5 -> 2`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=101`)
## 2026-03-07 - Roadmap Slice: Migrate `ebnf::grammar_file` to Canonical Helper Flow
## Summary
Advanced roadmap Item #3 by migrating the remaining blocked `ebnf::grammar_file` accumulator/finalization path off raw Perl fallback using the existing helper surface, clearing the last `ebnf` blocked rule without adding new lowering contracts.

## Changed Files
- Updated: `specs/ebnf.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated `ebnf::grammar_file` initialization/finalization state to canonical helper flow:
  - replaced raw declarations with:
    - `declare(array, rules, rule, includes, semantic_annotations)`
    - `declare(scalar, rule, on)`
  - replaced both raw pending-rule flush sites with:
    - `if(scalar(rule))`
    - `push_value(array(rules), array(scalar(rule), flat_array(rule)))`
    - `endif()`
  - replaced raw final return `[@includes, @rules]` with:
    - `return(array(flat_array(includes), flat_array(rules)))`
- Migrated the `-> grammar_rule` state handoff:
  - copied staged semantic annotations into the next rule accumulator with:
    - `assign(array(rule), array(flat_array(semantic_annotations)))`
    - `assign(array(semantic_annotations), array())`
  - retained canonical call-wrapper assignment for rule binding:
    - `$rule = call(grammar_rule)`
    - `assign(scalar(on), 1)`
- Important DSL usage note captured during the slice:
  - `array_values(array(...))` remains the array-snapshot helper,
  - list-context array copying into an `assign(array(...), ...)` target should use `array(flat_array(source))`.
- Added focused regression coverage:
  - `ebnf_grammar_file_helper_flow_eliminates_raw_fallback`
- Post-migration metadata snapshot:
  - `ebnf::grammar_file`: `raw_perl_dependency_count` `4 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `ebnf` descriptor migration summary: `language_agnostic_blocked_rule_count` `1 -> 0`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=100`)
## 2026-03-07 - Roadmap Slice: Add Flat List Helpers and Clear VHDL Declaration Blockers
## Summary
Advanced roadmap Item #3 by adding backend-neutral flat list insertion helpers for array/hash content and then using that new helper surface to migrate `vhdl::subprogram_declaration` and `vhdl::type_declaration` off raw Perl fallback.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/Contracts.pm`
- Updated: `perl/LinkedSpec/BootstrapSpec/Core.pm`
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added flat list insertion helper support in method/value lowering:
  - generic forms:
    - `flat(array(name))`
    - `flatten(array(name))`
    - `flat(hash(name))`
    - `flatten(hash(name))`
  - non-redundant aliases:
    - `flat_array(name)`
    - `flat_hash(name)`
- Flat helpers now lower into surrounding list-context insertion expressions:
  - arrays -> `@name`
  - hashes -> `%name`
- Generalized `return(payload)` and method-chain `.return(...)` payload detection now recognize flat-list helper starts, including direct forms such as `return(flat_array(items))`.
- `hash(...)` constructor lowering now accepts flat hash/list insertions alongside ordinary key/value pairs.
- Migrated VHDL declaration rules to use the new helper:
  - `subprogram_declaration`
    - replaced raw `@IMATCH_LIST` return expansion with `I.return(array("?subprogram_declaration:", flat_array(IMATCH_LIST)))`
  - `type_declaration`
    - removed inert raw start block
    - replaced raw capture/return logic with:
      - `declare(scalar, type_definition)`
      - `assign(scalar(type_definition), CAPTURE)`
      - `return(array("?type_declaration:", flat_array(IMATCH_LIST), scalar(type_definition)))`
- Added focused regression coverage:
  - `action_rewriter_lowers_flat_list_value_helpers`
  - `vhdl_declaration_helper_flow_eliminates_raw_fallback`
- Post-migration metadata snapshot:
  - `vhdl::subprogram_declaration`: `raw_perl_dependency_count` `1 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl::type_declaration`: `raw_perl_dependency_count` `2 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl` descriptor migration summary: `language_agnostic_blocked_rule_count` `7 -> 5`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=100`)
## 2026-03-07 - Roadmap Slice: Migrate VHDL Package Rules to Canonical Helper Flow
## Summary
Advanced roadmap Item #3 by migrating `vhdl::package_declaration` and `vhdl::package_body` off raw Perl fallback using the existing helper surface, clearing both rules from the blocked set without adding new lowering contracts.

## Changed Files
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated `vhdl::package_declaration`:
  - replaced the inert raw start block with canonical helper declaration flow `I {declare(array, imatch_copy)}`
  - replaced raw lowercase/return logic with helper flow:
    - `assign(array(imatch_copy), array(scalar(IMATCH_LIST, 0)))`
    - `lowercase_each(array(imatch_copy))`
    - `return(array("?package_declaration:", scalar(array(imatch_copy), 0), array_values(array(package_declaration))))`
- Migrated `vhdl::package_body`:
  - removed the empty raw start block entirely
  - replaced the raw structured return with `.return(array("?package_body:", scalar(IMATCH_LIST, 0), array_values(array(package_body))))`
- Added focused regression coverage:
  - `vhdl_package_helper_flow_eliminates_raw_fallback`
  - verifies zero raw fallback, canonical node coverage, readiness, and absence from the blocked-rule summary
- Post-migration metadata snapshot:
  - `vhdl::package_declaration`: `raw_perl_dependency_count` `2 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl::package_body`: `raw_perl_dependency_count` `2 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl` descriptor migration summary: `language_agnostic_blocked_rule_count` `9 -> 7`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=98`)
## 2026-03-07 - Roadmap Slice: Clear Final `vhdl::signal_decl_range` Blocker
## Summary
Advanced roadmap Item #3 by clearing the last remaining raw fallback in `vhdl::signal_decl_range`, replacing the raw array reset with canonical helper flow so the rule now reports zero blockers and full language-agnostic action-IR readiness.

## Changed Files
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated the last remaining blocked statement in `vhdl::signal_decl_range`:
  - replaced raw `@capt = ()` with canonical helper flow `assign(array(capt), array())`
- Strengthened existing regression lock:
  - `vhdl_signal_decl_range_method_flow_reduces_raw_push_capture_fallback`
  - now verifies:
    - zero raw fallback statements,
    - zero raw fallback count,
    - and `language_agnostic_action_ir_ready=1`
- Post-migration metadata snapshot for `vhdl::signal_decl_range`:
  - `raw_perl_dependency_count`: `1 -> 0`
  - `unresolved_helper_count`: `0 -> 0`
  - `language_agnostic_action_ir_ready`: `0 -> 1`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=97`)
## 2026-03-07 - Roadmap Slice: Add `hash(...)` Return Payload Lowering and Clear `tablegrep` Blockers
## Summary
Advanced roadmap Item #3 by teaching generalized `return(payload)` lowering to handle helper-based `hash(...)` constructor payloads, then using that canonical form to migrate the remaining blocked `tablegrep` rules (`and_op`, `or_op`, `re_term`) off raw Perl fallback.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `specs/tablegrep.spec`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added helper-based hash constructor lowering in generalized return payload flow:
  - `return(hash("key", value, ...))` now lowers to a canonical structured hash payload instead of falling through as a raw helper expression
  - helper hash keys are normalized as stable string expressions while nested helper values continue to lower recursively
- Migrated remaining blocked `tablegrep` rules:
  - `and_op`
    - moved raw return payload to `I.return(hash("type", "AND_OP"))`
  - `or_op`
    - moved raw return payload to `I.return(hash("type", "OR_OP"))`
  - `re_term`
    - replaced raw capture/branch logic with helper flow using `declare`, `if(matches(...))`, `substr`, and `return(hash(...))`
    - bracketed numeric fields now normalize through canonical regex substitution helper flow before returning `STERM`
- Added/extended regression coverage:
  - extended `action_rewriter_lowers_general_return_payloads_with_nested_structures` to lock `return(hash(...))` lowering
  - added `tablegrep_terminal_token_helper_flow_eliminates_raw_fallback`
  - verifies zero raw fallback and zero blocked-rule summary state for `tablegrep`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=97`)
## 2026-03-07 - Roadmap Slice: Clear Remaining `simenv` Action-Rewriter Blockers
## Summary
Advanced roadmap Item #3 by migrating the last two blocked `simenv.spec` rules, `top` and `anyvariable`, to canonical helper flow so the `simenv` spec no longer reports any language-agnostic action-IR blocked rules.

## Changed Files
- Updated: `specs/simenv.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated `simenv::top`:
  - replaced raw `my @blocks` initialization with `declare(array, blocks)`
  - replaced `push @blocks, $retv if $retv` with fluent helper control flow using `if(...)`, `push_value(...)`, and `endif()`
  - replaced bare Perl `return @blocks ? \@blocks : undef` with helper return flow using `if(...)`, `return(array_values(array(blocks)))`, and `return_undef()`
- Migrated `simenv::anyvariable`:
  - replaced raw regex capture extraction `$IMATCH =~ /(\S+)/` with helper flow using `declare(scalar, variable_name=scalar(IMATCH))`
  - trimmed trailing spaces through `substr(...)`
  - converted diagnostic output to canonical `print(...)`
  - returned the structured payload through generalized `return({...})`
- Added focused regression coverage:
  - `simenv_top_and_anyvariable_helper_flow_eliminates_raw_fallback`
  - locks zero raw fallback and readiness for `top` and `anyvariable`, and verifies `simenv` now reports zero blocked rules in descriptor migration metadata

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=96`)
## 2026-03-07 - Roadmap Note: Queue `array_values(...)` Naming Cleanup
## Summary
Recorded a deferred roadmap task to rename the backend-neutral array snapshot helper `array_values(array(...))` to clearer `array_copy(array(...))` later, without changing current runtime behavior or helper semantics in this slice.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added an explicit backlog note under roadmap immediate-next-step guidance:
  - future naming cleanup target: `array_values(array(...))` -> `array_copy(array(...))`
  - current helper behavior remains unchanged for now
  - transition is expected to preserve compatibility for existing specs when the rename is eventually implemented

## Validation
- Docs-only roadmap update.
- No code or test validation was required for this slice.
## 2026-03-07 - Roadmap Slice: Migrate `simenv` Quote/Substitution Diagnostics to Canonical Helper Flow
## Summary
Advanced roadmap Item #3 by converting the remaining raw diagnostic/debug print statements in a focused `simenv.spec` quote/substitution family to canonical helper flow, and by rewriting `variable_substitution` and `comments` to avoid raw regex/print/chomp fallbacks.

## Changed Files
- Updated: `specs/simenv.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated raw diagnostic/debug print statements to canonical helper flow in:
  - `singleline_value`
  - `dquotes`
  - `perl_dquotes`
  - `command_substitution`
  - `perl_command_substitution`
- Rewrote remaining raw helper-block logic in:
  - `variable_substitution`
    - now uses `declare(scalar, variable_name=scalar(IMATCH))`
    - strips the leading `$` via `substr(...)`
    - emits diagnostics through `print(...)`
    - returns via generalized `return({...})`
  - `comments`
    - now uses `declare(scalar, comment_text=scalar(IMATCH))`
    - removes the trailing newline via `substr(...)`
    - emits diagnostics through `print(...)`
- Migration impact:
  - all seven migrated rules now report `raw_perl_dependency_count=0`,
  - all seven migrated rules now report `language_agnostic_action_ir_ready=1`.
- Added focused regression coverage:
  - `simenv_quote_substitution_helper_flow_eliminates_raw_fallback`
  - locks zero raw fallback, canonical `PRINT` node presence, and readiness across the selected `simenv` quote/substitution family.

## Validation
- Ran:
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=95`)
## 2026-03-07 - Roadmap Slice: Migrate `simenv` Delimiter-Helper Diagnostics to Canonical `print(...)` Flow
## Summary
Advanced roadmap Item #3 by converting the raw diagnostic/debug print statements in a focused `simenv.spec` delimiter-helper family to canonical `print(...)` helper calls, removing raw Perl fallback from those rules without changing parser behavior.

## Changed Files
- Updated: `specs/simenv.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated raw print statements to canonical helper flow in:
  - `bs_nl`
  - `squotes`
  - `perl_squotes`
  - `multiline_value`
  - `bvariable_substitution`
  - `curlybrace`
  - `parenthesis`
- Where diagnostic output included captured text or computed line numbers, the helper form now uses ordinary print arguments such as:
  - `print("<", substr(...), ">\n")`
  - `print("...", (@startline + 1), "\n")`
- Migration impact:
  - all seven migrated rules now report `raw_perl_dependency_count=0`,
  - all seven migrated rules now report `language_agnostic_action_ir_ready=1`.
- Added focused regression coverage:
  - `simenv_delimiter_helper_print_flow_eliminates_raw_fallback`
  - locks zero raw fallback, canonical `PRINT` node presence, and readiness across the selected `simenv` rule family.

## Validation
- Ran:
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=94`)
## 2026-03-07 - Roadmap Slice: Migrate `BNF.spec` Debug Prints to Canonical `print(...)` Helper Flow
## Summary
Advanced roadmap Item #3 by converting the raw debug-print statements in `specs/BNF.spec` to canonical `print(...)` helper calls, removing raw Perl fallback across the full BNF grammar while preserving existing behavior.

## Changed Files
- Updated: `specs/BNF.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated raw debug-print statements in `specs/BNF.spec` to canonical helper flow:
  - `description`
  - `construction_start`
  - `node`
  - `dquote_str`
  - `squote_str`
  - `regex`
  - `group`
  - `g_repetition`
  - `q_mark`
  - `plus`
  - `star`
  - `pipe`
- Where debug text depended on `$IMATCH`, the helper form now uses backend-neutral value access through `scalar(IMATCH)` inside `print(...)`.
- Migration impact:
  - eliminated raw-print fallback across the entire BNF spec,
  - all 12 migrated rules now report `raw_perl_dependency_count=0`,
  - all 12 migrated rules now report `language_agnostic_action_ir_ready=1`.
- Added focused regression coverage:
  - `bnf_debug_print_helper_flow_eliminates_raw_fallback`
  - locks zero raw fallback, canonical `PRINT` node presence, and readiness across the full BNF rule set.

## Validation
- Ran:
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=93`)
## 2026-03-06 - Roadmap Slice: Migrate `ifelse.spec` Debug Prints to Canonical `print(...)` Helper Flow
## Summary
Advanced roadmap Item #3 by converting the raw debug-print statements in `specs/ifelse.spec` to canonical `print(...)` helper calls, removing raw Perl fallback across the entire `ifelse` grammar without changing parser behavior.

## Changed Files
- Updated: `specs/ifelse.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated all debug-print statements in `specs/ifelse.spec` from raw Perl:
  - `print "..."` -> `print("...")`
- Covered rules:
  - `program`
  - `if`
  - `then`
  - `elsif`
  - `else`
  - `while`
  - `while_then`
- Migration impact:
  - eliminated 23 raw-print fallback statements across the `ifelse` file,
  - all seven rules now report `raw_perl_dependency_count=0`,
  - all seven rules now report `language_agnostic_action_ir_ready=1`.
- Added focused regression coverage:
  - `ifelse_debug_print_helper_flow_eliminates_raw_fallback`
  - locks zero raw fallback, canonical `PRINT` node presence, and readiness across the full `ifelse` rule set.

## Validation
- Ran:
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=92`)
## 2026-03-06 - Roadmap Slice: Migrate `simenv::begin_end_blocks` with Canonical Array Snapshot Flow
## Summary
Advanced roadmap Item #3 by introducing backend-neutral `array_values(...)` array snapshot lowering, extending `assign(...)` beyond scalar targets, and migrating `specs/simenv.spec` rule `begin_end_blocks` away from Perl-specific `[@...]` / `\@...` payload forms to canonical helper flow.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/FlowExpr.pm`
- Updated: `specs/simenv.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added method value helper lowering:
  - `array_values(array(target))` now lowers to a snapshot of current array contents (`[@target]`) without requiring Perl array-literal syntax in `.spec`.
  - Implemented through `MethodLowering::_lower_method_value_expr` and routed through generalized return/flow value lowering so it works inside `return(...)` payloads and nested helper expressions.
- Extended assignment lowering:
  - `assign(target, source_expr)` now accepts `array(name)` and `hash(name)` targets in addition to scalar targets.
  - Collection-target assignment reuses structured initializer lowering, so `assign(array(items), array(...))` and `assign(hash(map), hash(...))` remain canonical helper forms.
- Migrated `specs/simenv.spec` `begin_end_blocks`:
  - replaced Perl-ish `[@keyval_pairs]` / `\@assigns` payload usage with `array_values(array(...))`,
  - moved block-name extraction, branch guards, pending-pair flush, structured return, and diagnostics to helper flow using `declare`, `assign`, `push_value`, `if/else/endif`, `substr`, `print`, `return`, `return_undef`, and `exit`.
- Added regression coverage:
  - `action_rewriter_lowers_array_snapshot_and_array_assign_method_contracts`,
  - `simenv_begin_end_blocks_method_flow_is_language_agnostic_ready`.
- Post-migration metadata snapshot for `simenv::begin_end_blocks`:
  - `raw_perl_dependency_count`: `8 -> 0`
  - `unresolved_helper_count`: `0 -> 0`
  - `language_agnostic_action_ir_ready`: `0 -> 1`

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=91`)
## 2026-03-06 - Roadmap Slice: Migrate `vhdl::signal_decl_range` to Method Flow + Add `join_values` Helper
## Summary
Advanced roadmap Item #3 by migrating `specs/vhdl.spec` rule `signal_decl_range` away from raw Perl capture/push/guard statements, and added canonical value helper `join_values(...)` so assignment sources no longer need raw Perl `join(...)` expression text in `.spec` method flow.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/FlowExpr.pm`
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added method value helper lowering:
  - `join_values(delimiter, array(target))` now lowers to `join(delimiter, @target)`.
  - Implemented in `MethodLowering::_lower_method_value_expr`.
  - Routed through flow-expression source lowering by extending `FlowExpr` value-expression passthrough set.
- Migrated `vhdl.spec` `signal_decl_range` rule:
  - declaration setup moved from raw `my (@capt, @msi_lsi)` to `declare(array, capt, msi_lsi)`,
  - LS capture push moved to `push_value(array(capt), substr(...))`,
  - LE position update moved to `assign(scalar(IPOS), pos $$STRING)`,
  - nested capture handling moved to helper flow (`declare`, `assign`, `push_value`, `if`, `substr`, `endif`),
  - raw `join("", @capt)` sources replaced with `join_values("", array(capt))`.
- Added/updated regression locks:
  - expanded `action_rewriter_lowers_method_contracts_for_capture_and_structured_return_values` with `join_values` assignment-source lowering assertion,
  - added `vhdl_signal_decl_range_method_flow_reduces_raw_push_capture_fallback` to lock targeted raw fallback reductions and canonical node presence.
- Post-migration metadata snapshot for `vhdl::signal_decl_range`:
  - `raw_perl_dependency_count`: `9 -> 1`,
  - remaining raw fallback statement: `@capt = ()`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=89`)
## 2026-03-06 - Roadmap Slice: Add `push_value` Method Contract and Migrate `tablegrep` Accumulator Flow
## Summary
Advanced roadmap Item #3 by introducing a reusable `push_value(...)` action method contract (canonical `PUSH`) and migrating `tablegrep.spec` accumulator handling (`grep`/`group`) from raw Perl statements to fluent helper flow.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/Contracts.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `specs/tablegrep.spec`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `push_value(...)` helper lowering end-to-end:
  - new lowering routine `MethodLowering::_lower_push_value_statement`,
  - new lowering contract `push_value` in `ActionIR::Contracts` with canonical `PUSH` node,
  - new scanner extractor `_scan_contract_push_value` in `Scanner::PrimitivePipelineRules`,
  - dependency wiring via `Deps::action_rewriter_contract_deps_for_package` and `LinkedSpec::_lower_push_value_statement`.
- Migrated `specs/tablegrep.spec` `grep`/`group` accumulator actions to fluent helper flow:
  - declarations now use `declare(array, internal)` + `declare(scalar, prev_node_type)`,
  - null-guard uses `if(not(scalar(retv))); return_undef(); endif();`,
  - accumulator push uses `push_value(array(internal), scalar(retv));`,
  - previous-node tracking uses `assign(scalar(prev_node_type), scalaref(retv, {type}))`,
  - group-empty guard now uses `if(is_empty(array(internal))); print(...); exit 2; endif();`,
  - group return now uses `return({type=>'GROUP', group=>array(internal)})`.
- Added regression coverage:
  - `action_rewriter_lowers_push_value_method_contract`,
  - `tablegrep_accumulator_method_flow_avoids_push_internal_raw_fallback`.
- Post-migration metadata check:
  - `tablegrep::grep` and `tablegrep::group` now report `raw=0`, `unresolved=0`, `fallback=0`, and `language_agnostic_action_ir_ready=1`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=88`)
## 2026-03-06 - Roadmap Slice: Migrate `tablegrep` Operator-Adjacency Guards to Fluent Method Flow
## Summary
Advanced roadmap Item #3 by migrating `tablegrep.spec` operator-adjacency guard logic from raw Perl `if (...) { ... }` blocks into fluent method-flow statements, reducing RAW_PERL fallback for those guard branches while preserving runtime behavior and diagnostics.

## Changed Files
- Updated: `specs/tablegrep.spec`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- In both `tablegrep` rules `grep` and `group`, converted LE guard blocks from raw Perl:
  - `if ($prev_node_type && $prev_node_type =~ /_OP/o && $$retv{type} =~ /_OP/o) { print ...; exit 1 }`
  to fluent method-flow statements:
  - `if(and(and(scalar(prev_node_type), matches(scalar(prev_node_type), /_OP/o)), matches(scalaref(retv, {type}), /_OP/o)));`
  - `print(...)`
  - `exit 1`
  - `endif();`
- This migration reuses existing method/value lowering surfaces:
  - `and(...)`, `matches(...)`, `scalar(...)`, `scalaref(...)`
  - flow control markers `if(...)` / `endif()`
- Added regression lock `tablegrep_operator_guard_method_flow_avoids_prev_node_type_if_raw_fallback` to ensure:
  - `grep` and `group` no longer report `if($prev_node_type...)` raw fallback statements,
  - canonical action-IR includes `IF` and `EXIT` nodes for the migrated guards.

## Validation
- Ran:
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=86`)
## 2026-03-06 - Roadmap Slice: EBNF Fluent-Branch Migration + Quote-Aware Method Parsing
## Summary
Advanced roadmap Item #3 (language-agnostic action migration) by converting `ebnf.spec` container-guard branches from raw Perl `if/else` blocks to fluent method-chain control flow, and fixed method-argument parsing/lowering so delimiters inside quoted strings (e.g., `(`, `)`, `{`, `}`, `[`, `]`) no longer break recursive parenthesis matching.

## Changed Files
- Updated: `specs/ebnf.spec`
- Updated: `t/phase0_regression.t`
- Updated: `perl/LinkedSpec/BootstrapSpec/Core.pm`
- Updated: `perl/LinkedSpec/ActionIR/MethodExpr.pm`
- Updated: `perl/LinkedSpec/ActionIR/Contracts.pm`
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Migrated `specs/ebnf.spec` `grammar_file` token edges (`rule_name`, `quoted_string`, `number`, operators, parens, regex, logging annotation, etc.) from raw Perl:
  - `if ($on) { push @rule, call(...) } else { say ...; return undef }`
  to fluent method-chain forms:
  - `.if(scalar(on)).push(..., rule).else().say(...).return_undef().endif()`
- Added regression lock `ebnf_grammar_file_method_chain_branches_avoid_if_on_raw_fallback` to assert:
  - `grammar_file` no longer reports `if($on)` raw-perl fallback statements,
  - canonical action-IR captures `IF` and `PUSH` nodes for those branches.
- Fixed parser/lowering bug root cause:
  - recursive `PAREN` regexes previously counted delimiters inside quoted string payloads as structural parentheses,
  - this could fragment/skip method calls when strings contained delimiter characters.
- Applied quote-aware recursive `PAREN` handling across method-chain parsing and ActionIR rewrite/scanner surfaces so quoted string delimiters are ignored as literals.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec/Core.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=85`)
## 2026-03-06 - Phase 1A Slice: Decompose RuleIR Emit-Context Construction into `RuleIR::EmitContext`
## Summary
Refactored `LinkedSpec::RuleIR::_build_rule_ir_emit_context` into focused helper routines in a new `LinkedSpec::RuleIR::EmitContext` module, while keeping `RuleIR.pm` as a thin delegate surface for emit-context functions.

## Changed Files
- Added: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `perl/LinkedSpec/RuleIR.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- New `LinkedSpec::RuleIR::EmitContext` ownership:
  - rewrite diagnostics accumulator initialization (`_build_rewrite_diag_acc`)
  - ACODE and BCODE rewrite passes (`_rewrite_acode_entries`, `_rewrite_bcode_entries`)
  - lifecycle chunk normalization (`_normalize_rule_lifecycle_code` + `_normalize_rule_code_chunks`)
  - unresolved-helper/raw-Perl blocker extraction and deduplication
  - action-rewriter metadata assembly (`_build_action_rewriter_meta`)
  - top-level emit-context orchestrator (`build_rule_ir_emit_context`).
- `LinkedSpec::RuleIR` now delegates:
  - `_normalize_rule_code_chunks` -> `RuleIR::EmitContext::_normalize_rule_code_chunks`
  - `_build_rule_ir_emit_context` -> `RuleIR::EmitContext::build_rule_ir_emit_context`
- Behavior-preserving output shape was retained for emit context fields consumed by `SpecEntry` (`ACODEs`, `BCODEs`, `BCALLs`, `GDATA`, lifecycle chunks, and `action_rewriter_meta`).

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-06 - Phase 1A Slice: Decompose `build_bootstrap_spec` into `BootstrapSpec::Core` Rule Builders
## Summary
Refactored the large `LinkedSpec::BootstrapSpec::build_bootstrap_spec` flow into focused rule-builder helpers in a new `LinkedSpec::BootstrapSpec::Core` module, and reduced `BootstrapSpec.pm` to a thin delegate facade.

## Changed Files
- Added: `perl/LinkedSpec/BootstrapSpec/Core.pm`
- Updated: `perl/LinkedSpec/BootstrapSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- `LinkedSpec::BootstrapSpec::Core` now owns:
  - method-chain parsing/rendering helpers used by method-like bootstrap rules,
  - focused per-rule descriptor builders (SPEC_ROOT, entry-label, action/non-action code blocks, comment, blind-call, split-like, and curly-brace scanner),
  - bootstrap descriptor assembly orchestrator (`_build_bootstrap_rule_descriptors`),
  - bootstrap registry/gdata compilation (`_build_bootstrap_registry_gdata`),
  - top-level orchestrator (`build_bootstrap_spec`).
- `build_bootstrap_spec` is now decomposed as:
  - context initialization (`node_type` map + mutable `bootstrap_rule_index` registry handle),
  - descriptor construction via targeted helper builders,
  - registry/gdata construction and registry backfill into handler-shared context.
- `LinkedSpec::BootstrapSpec::build_bootstrap_spec` is now a thin facade delegating to `LinkedSpec::BootstrapSpec::Core::build_bootstrap_spec`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec/Core.pm`
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-06 - Phase 1A Slice: Decompose Canonical Helper-Event Normalization into `CanonicalEvents::Core`
## Summary
Refactored `_canonicalize_helper_action_ir_event` by decomposing its large contract-id mapping logic into smaller targeted helpers in a new `LinkedSpec::ActionIR::CanonicalEvents::Core` module, while keeping `CanonicalEvents.pm` as a thin delegate for that path.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/CanonicalEvents/Core.pm`
- Updated: `perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- `LinkedSpec::ActionIR::CanonicalEvents::Core` now owns decomposed canonicalization helpers:
  - `_kind_override_for_contract_id`
  - `_canonical_kind`
  - `_normalize_canonical_args`
  - `canonicalize_helper_action_ir_event`
- Canonicalization logic is now structured as:
  - contract-id -> kind override lookup
  - grouped multi-contract kind handling
  - focused argument normalization for special contract families (`return_call`, push variants, `return_undef`)
  - final canonical event assembly.
- `LinkedSpec::ActionIR::CanonicalEvents::_canonicalize_helper_action_ir_event` is now a thin delegate into `CanonicalEvents::Core`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents/Core.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-06 - Phase 1A Slice: Decompose `_split_action_ir_statements` into Core + Mode Submodules
## Summary
Refactored the large statement-splitting state machine into smaller targeted functions across dedicated `StatementSplit` submodules, keeping `LinkedSpec::ActionIR::StatementSplit` as a thin facade.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`
- Added: `perl/LinkedSpec/ActionIR/StatementSplit/Mode.pm`
- Updated: `perl/LinkedSpec/ActionIR/StatementSplit.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- `LinkedSpec::ActionIR::StatementSplit` now owns only dependency validation + delegation.
- New `StatementSplit::Core` ownership:
  - split orchestrator loop (`split_action_ir_statements`)
  - state initialization
  - nesting/terminator handling
  - trimmed statement emission.
- New `StatementSplit::Mode` ownership:
  - line/single/double/backtick/slash/angle/pipe mode consumers
  - mode-entry detectors for quote/comment and regex-like delimiters.
- The original single 240+ line state machine is now decomposed into focused helpers connected by the core orchestrator while preserving call surface.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit/Mode.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-05 - Phase 1A Slice: Decompose `scan_contract_ir_events` into Smaller Scanner Rule Submodules
## Summary
Refactored scanner ownership to break the large `scan_contract_ir_events` implementation into smaller targeted scanner rule submodules, with a thin orchestrator in `ScannerCore` and a stable facade in `Scanner`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/ScannerCore.pm`
- Added: `perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm`
- Added: `perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
- Added: `perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm`
- Added: `perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- `LinkedSpec::ActionIR::Scanner` is now a thin facade that delegates to `LinkedSpec::ActionIR::ScannerCore`.
- `LinkedSpec::ActionIR::ScannerCore` now owns orchestration only:
  - dependency callback validation (`_require_dep`)
  - callback symbol localization into scanner-rule submodule packages
  - ordered dispatch across focused scanner rule modules.
- Scanner rule ownership moved into focused submodules:
  - `Scanner::PrimitiveBasicRules`
  - `Scanner::PrimitivePipelineRules`
  - `Scanner::FlowRules`
  - `Scanner::LegacyRules`
- Each scanner submodule now owns only a bounded contract-id family and uses small targeted handlers per contract id.
- Resulting scanner file sizing (approx):
  - `ScannerCore.pm`: 66 lines
  - `PrimitiveBasicRules.pm`: 241 lines
  - `PrimitivePipelineRules.pm`: 208 lines
  - `FlowRules.pm`: 246 lines
  - `LegacyRules.pm`: 198 lines
  - `Scanner.pm`: 25 lines

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ScannerCore.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-05 - Phase 1A Slice: Extract ActionRewriter Dependency-Map Ownership to `LinkedSpec::Deps`
## Summary
Moved ActionRewriter dependency-map ownership out of `LinkedSpec::ActionRewriter` into `LinkedSpec::Deps`, preserving behavior with thin dependency-map delegates in `ActionRewriter`.

## Changed Files
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added ActionRewriter-specific dependency-map builders in `LinkedSpec::Deps`:
  - `action_rewriter_declare_method_deps_for_package`
  - `action_rewriter_statement_split_deps_for_package`
  - `action_rewriter_canonical_event_deps_for_package`
  - `action_rewriter_scanner_deps_for_package`
  - `action_rewriter_diagnostics_deps_for_package`
  - `action_rewriter_rewrite_pipeline_deps_for_package`
  - `action_rewriter_contract_deps_for_package`
- Updated `LinkedSpec::ActionRewriter`:
  - added `use LinkedSpec::Deps ();`
  - converted `_declare_method_deps`, `_statement_split_deps`, `_canonical_event_deps`, `_diagnostics_deps`, `_rewrite_pipeline_deps`, and `_action_contract_deps` to delegates into `LinkedSpec::Deps`.
  - added `_scan_contract_ir_event_deps` delegate into `LinkedSpec::Deps`.
  - rewired `_scan_contract_ir_events` to consume `_scan_contract_ir_event_deps()` rather than an in-file dependency hash.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-04 - Phase 1A Slice: Extract Rewrite Pipeline Ownership to `LinkedSpec::ActionIR::RewritePipeline`
## Summary
Moved rewrite pipeline orchestration/lowering ownership out of `LinkedSpec::ActionRewriter` into a dedicated `LinkedSpec::ActionIR::RewritePipeline` module, preserving compatibility through thin delegates in `ActionRewriter`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/RewritePipeline.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::RewritePipeline` owning:
  - `_lower_action_code_from_canonical_ir`
  - `_build_action_rewrite_rules`
  - `_rewrite_action_code_with_diagnostics`
- Boundary design:
  - module is dependency-injected for contract construction, helper-IR collection, canonical-event assembly, and unresolved-helper detection callbacks,
  - no hard-coded direct calls into `LinkedSpec` internals from rewrite-pipeline logic.
- Updated `LinkedSpec::ActionRewriter`:
  - added `use LinkedSpec::ActionIR::RewritePipeline ();`
  - added `_rewrite_pipeline_deps` callback map
  - converted moved rewrite pipeline functions to thin delegates.
- Validation bug discovered/fixed during this slice:
  - corrected delegate argument forwarding in `_rewrite_action_code_with_diagnostics` so dependency callbacks are passed in the dedicated deps argument slot when `rewrite_rules` is omitted.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-04 - Phase 1A Slice: Extract Action-Rewrite Diagnostics Ownership to `LinkedSpec::ActionIR::Diagnostics`
## Summary
Moved action rewrite diagnostics/helper aggregation ownership out of `LinkedSpec::ActionRewriter` into a dedicated `LinkedSpec::ActionIR::Diagnostics` module, preserving compatibility through thin delegates in `ActionRewriter`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/Diagnostics.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::Diagnostics` owning:
  - `_find_unresolved_action_helpers`
  - `_collect_action_helper_ir_nodes`
  - `_accumulate_action_rewrite_diagnostics`
- Boundary design:
  - module is dependency-injected for statement splitting and contract-event scanning callbacks,
  - no hard-coded direct calls into `LinkedSpec` internals from diagnostics aggregation logic.
- Updated `LinkedSpec::ActionRewriter`:
  - added `use LinkedSpec::ActionIR::Diagnostics ();`
  - added `_diagnostics_deps` callback map
  - converted `_find_unresolved_action_helpers`, `_collect_action_helper_ir_nodes`, and `_accumulate_action_rewrite_diagnostics` to thin delegates.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-04 - Phase 1A Slice: Extract Action-IR Statement Splitting to `LinkedSpec::ActionIR::StatementSplit`
## Summary
Moved statement-splitting ownership out of `LinkedSpec::ActionRewriter` into a dedicated `LinkedSpec::ActionIR::StatementSplit` module, preserving behavior through a thin delegate in `ActionRewriter`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/StatementSplit.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::StatementSplit` owning:
  - `_split_action_ir_statements`
- Boundary design:
  - module is dependency-injected for trimming callback (`trim_action_ir_value`),
  - no hard-coded direct calls into `LinkedSpec` internals from statement-splitting logic.
- Updated `LinkedSpec::ActionRewriter`:
  - added `use LinkedSpec::ActionIR::StatementSplit ();`
  - added `_statement_split_deps` callback map
  - converted `_split_action_ir_statements` to a thin delegate to `ActionIR::StatementSplit`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-03 - Phase 1A Slice: Extract Canonical Helper-Event Ownership to `LinkedSpec::ActionIR::CanonicalEvents`
## Summary
Moved canonical helper-event normalization and canonical action-IR event assembly ownership out of `LinkedSpec::ActionRewriter` into a dedicated `LinkedSpec::ActionIR::CanonicalEvents` module, preserving compatibility through thin delegates in `ActionRewriter`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::CanonicalEvents` owning:
  - `_canonicalize_helper_action_ir_event`
  - `_build_canonical_action_ir_events`
- Boundary design:
  - module is dependency-injected for trimming and top-level statement splitting callbacks,
  - no hard-coded direct calls back into `LinkedSpec` internals from module logic.
- Updated `LinkedSpec::ActionRewriter`:
  - added `use LinkedSpec::ActionIR::CanonicalEvents ();`
  - added `_canonical_event_deps` callback map
  - converted `_canonicalize_helper_action_ir_event` and `_build_canonical_action_ir_events` to thin delegates.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-03 - Phase 1A Slice: Extract Remaining `Get`/`AUTOLOAD` Ownership from `LinkedSpec.pm`
## Summary
Moved the last non-delegate entrypoint ownership out of `LinkedSpec.pm` by extracting `AUTOLOAD` plugin dispatch to `LinkedSpec::PluginBridge` and moving raw `Get` argument parsing into `LinkedSpec::Runtime`.

## Changed Files
- Added: `perl/LinkedSpec/PluginBridge.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::PluginBridge::dispatch_autoload($autoload_name, @args)`:
  - owns lazy `PPlugin` loading and plugin dispatch execution.
- Updated `LinkedSpec::Runtime`:
  - added `run_get_from_args(@args)` to own raw `Get` argument normalization (`$spec_content_ref`, `%options`) and delegate to existing `run_get(...)`.
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::PluginBridge ();`
  - `Get(...)` now delegates to `LinkedSpec::Runtime::run_get_from_args(...)`
  - `AUTOLOAD(...)` now delegates to `LinkedSpec::PluginBridge::dispatch_autoload(...)`
- Ownership outcome:
  - `LinkedSpec.pm` no longer contains non-delegate orchestration/bridge logic for `Get` and `AUTOLOAD`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-03 - Phase 1A Slice: Extract Declare/Assign Method Helper Ownership to `LinkedSpec::ActionIR::DeclareMethod`
## Summary
Moved declare/assign method helper parsing/lowering ownership out of `LinkedSpec::ActionRewriter` into a dedicated `LinkedSpec::ActionIR::DeclareMethod` module, while preserving compatibility through thin delegates in `ActionRewriter` and `LinkedSpec.pm`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/DeclareMethod.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::DeclareMethod` owning:
  - `_split_declare_symbol_names`
  - `_parse_declare_binding_entry`
  - `_lower_declare_value_expr`
  - `_lower_declare_initializer_expr`
  - `_extract_declare_statement_from_method_expr`
  - `_lower_declare_method_statement`
  - `_lower_assign_method_statement`
- Boundary design:
  - module is dependency-injected via callback map (`trim`, method parse/scope helpers, flow/value lowering, declaration alias/type lowering, assign lowering),
  - no hard-coded direct calls back into `LinkedSpec` internals from module logic.
- Updated `LinkedSpec::ActionRewriter`:
  - added `_declare_method_deps` dependency map,
  - converted the moved helper surface to thin delegates into `ActionIR::DeclareMethod`.
- Updated `LinkedSpec::Deps`:
  - added `declare_method_deps_for_package` callback map builder.
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::ActionIR::DeclareMethod ();`,
  - added `_declare_method_deps` delegate helper,
  - rewired declare/assign helper wrappers to delegate directly to `ActionIR::DeclareMethod`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/DeclareMethod.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-03 - Phase 1A Slice: Extract Dependency-Map Ownership to `LinkedSpec::Deps`
## Summary
Moved callback dependency-map construction ownership out of `LinkedSpec.pm` into a dedicated `LinkedSpec::Deps` module with explicit callback/value contract checks.

## Changed Files
- Added: `perl/LinkedSpec/Deps.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::Deps` module owning dependency-map builders:
  - `flow_expr_deps_for_package`
  - `method_lowering_deps_for_package`
  - `array_pipeline_deps_for_package`
  - `control_flow_deps_for_package`
  - `value_expr_deps_for_package`
  - `parser_factory_deps_for_package`
- Contract enforcement added in `LinkedSpec::Deps`:
  - `_require_pkg_cb` verifies required callbacks exist and are callable,
  - `_require_pkg_value` verifies required constant/value providers exist.
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::Deps ();`
  - converted `_flow_expr_deps`, `_method_lowering_deps`, `_array_pipeline_deps`, `_control_flow_deps`, `_value_expr_deps`, and `_parser_factory_deps` into thin delegates to `LinkedSpec::Deps`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ValueExpr.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-02 - Phase 1A Slice: Extract Runtime State + Get/spec_entry Orchestration to `LinkedSpec::Runtime`
## Summary
Moved bootstrap runtime state and `Get`/`spec_entry` orchestration ownership out of `LinkedSpec.pm` into a dedicated `LinkedSpec::Runtime` module, preserving public entrypoint compatibility through thin delegates in `LinkedSpec.pm`.

## Changed Files
- Added: `perl/LinkedSpec/Runtime.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::Runtime` as the owner of:
  - bootstrap parser runtime state initialization (`spec_descr`, `bootstrap_rule_index`, `gdata`),
  - parser-source emit callback routing (`_emit_parser_source_line` + callback state),
  - `Get` orchestration glue (`run_get`) that injects runtime state into `LinkedSpec::Compiler::run_get_pipeline(...)`,
  - `spec_entry` orchestration glue (`compile_spec_entry`) including top-rule propagation.
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::Runtime ();`
  - converted `_emit_parser_source_line` to a thin delegate,
  - replaced `Get(...)` body with a thin delegate to `LinkedSpec::Runtime::run_get(...)`,
  - replaced `spec_entry(...)` body with a thin delegate to `LinkedSpec::Runtime::compile_spec_entry(...)`.
- Ownership clean-up:
  - removed runtime bootstrap globals/callback state management from `LinkedSpec.pm`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-02 - Phase 1A Slice: Transfer Action Contract/Scanner Wiring to `LinkedSpec::ActionRewriter`
## Summary
Moved action-rewriter contract wiring and scanner-adapter ownership out of `LinkedSpec.pm` into `LinkedSpec::ActionRewriter`, preserving compatibility through thin delegates in `LinkedSpec.pm`.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- `LinkedSpec::ActionRewriter` now owns:
  - `_action_contract_deps`
  - `_build_action_lowering_contracts`
  - `_scan_contract_ir_events`
- `ActionRewriter` internal flow updates:
  - `_collect_action_helper_ir_nodes` now routes scanner calls through local `_scan_contract_ir_events`,
  - `_build_action_rewrite_rules` now builds contracts through local `_build_action_lowering_contracts` rather than calling back into `LinkedSpec`.
- `LinkedSpec.pm` updates:
  - `_action_contract_deps` converted to thin delegate,
  - `_build_action_lowering_contracts` converted to thin delegate,
  - `_scan_contract_ir_events` converted to thin delegate.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
