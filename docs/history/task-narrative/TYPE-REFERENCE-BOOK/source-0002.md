  Owned paths: lua/src/linkedspec/interpreter.lua if needed; lua/test/selected_value_receivers_test.lua and lua/test/run.lua registration; current book/Lua/array facts/map and TYPE/live continuity. Project-local disposable native builds use the published targeted wrapper.
  Verification tier: `focused`
  Focused checks: Fresh matching native products, source syntax and one small public native/generated-plan/fresh-emitted fixture per available ABI; directly affected compatibility check only when needed; book and fast continuity/history checks. No full Lua suite/corpus.
  Canonical trigger: None for bounded implementation/confirmation under director feature-first phase; full23.4 admission remains deferred.
  Claim verification: none: Deterministic implementation/confirmation and targeted regression, no quantified corpus/exhaustive/portable admission measurement.
  Environment: Direct lua/luajit banners and matching pkg-config report PUC5.5.1, LuaJIT2.1.1788460057 and PCRE2 10.48, consistent with the public integration guide. Declared PUC5.4.8 proof remains LUA-STARTUP-READING.2.2; no unversioned pass establishes5.4 conformance. Toolchain/native-formatter repairs are not silently closed here.
  Acceptance: Probe frozen journeys through public APIs first, reuse correct behavior, preserve selected kinds/copy/repeated transitions/null/empty/arity/effects and source snapshots. Check both available hosts with exact identity limits. Correct the Lua fact's stale Rust/Dart/Julia transform omissions against accepted5.3.1-.3; full admission remains separate.

  Reproduce/impact: Frozen selected journeys PASS on available PUC5.5.1 and LuaJIT through native/generated-plan/fresh-emitted routes before production edits. Expanded valid cases agree, but an extra first argument returns a with two effects instead of null and zero effects on both hosts.
  Root cause: interpreter.evaluate_expr's fluent_chain branch evaluates the receiver before typed_source.receiver_mutation.evaluate_fluent_calls; helper processing evaluates and ignores extra extraction operands. Validate first/last shapes before evaluating the receiver; preserve the existing per-value dispatcher.

  Completion: Preserve Lua's existing dynamic selected-value dispatcher and add first/last arity rejection before receiver/operand effects. Retain json.null slots, register the small fixture in lua/test/run.lua and syntax-load the interpreter/runner without executing the full package suite.
  Focused result: Published targeted wrappers build fresh ABI-matching native products and PASS the fixture on available PUC5.5.1 and LuaJIT. Native/generated-plan/fresh-emitted results agree, including dynamic function copies, repeated transitions, exact recipes, min/max, snapshots, nulls and effects. Book and fast continuity/history checks pass; no PUC5.4/full suite claim.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Frozen journeys PASS before production changes on both available hosts. The expanded fixture is RED for ignored first arguments, returning a and two effects instead of null and zero effects.
  - [x] **ROOT CAUSE (WHY + WHERE)** — interpreter.evaluate_expr evaluates fluent_chain receivers before delegating to the dynamic call loop; helper processing evaluates and ignores extra extraction values without prevalidation.
  - [x] **FIX** — Validate first/last call shape before receiver/operand evaluation, preserve the existing dynamic dispatcher and json.null representation, and enroll the focused producer in the normal runner.
  - [x] **ADDRESSED (verified)** — Fresh matching native builds, syntax loads and public native/generated-plan/fresh-emitted fixture PASS on available PUC5.5.1/LuaJIT.
  - [x] **NO REGRESSION** — Valid selected scalar/container/copy kinds, repeated extraction, functions/computed sources, snapshots, empty values, min/max and once-only effects pass. No full Lua suite/corpus or unsupported target claim.
  - [x] **LOCKSTEP** — Current five-backend implementation recipes include Lua host qualification; stale transform omissions are corrected in its fact. Contract/facts/map/task/live handoff agree; P1 Rust61.1/.61.2 repairs are next and full admission stays open.
  Harness note: Initial Lua long-string delimiters collided with nested array closing brackets and failed syntax before runtime. Use levelled long strings; no product-defect credit for that fixture setup error.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.1.5 - guard Lua selected-value receiver arity`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.2`
  Status: `active` / bounded copy-arity implementations complete; broad admission deferred
  Activation: clean `804f9657c47d62157e9f77b4f76749d24f11e7ab`; Rust scalar61.1/.61.2 repairs are committed. Start the distinguishing public Julia probe; create implementation children only for observed defects.
  Children: `TYPE-REFERENCE-BOOK.1.2.23.3.2.1`, `TYPE-REFERENCE-BOOK.1.2.23.3.2.2`, `TYPE-REFERENCE-BOOK.1.2.23.3.2.3`, `TYPE-REFERENCE-BOOK.1.2.23.3.2.4`, `TYPE-REFERENCE-BOOK.1.2.23.3.2.5`.
  Public Lua/Perl findings (October26): Both available PUC5.5.1/LuaJIT return [1,2], copying the extra operand after both effects; .2.4 owns the confirmed Lua repair. Perl Get returns [null,0] for the selected misuse, already correct; direct/generated controls follow without a fabricated implementation defect.
  Public Rust finding (October26): Fresh locked/offline public CLI probe returns [["a"],2], evaluating both receiver and extra operand. Child .2.3 owns early rejection. Tiny Rust/Perl controls return [[],[],[],[]] for scalar/selected-scalar/missing/free-scalar copy; canonical perl-scalar-bound-receiver-copy already documents scalar fallback and shallow container copies. The book's universal deep/scalar-copy wording is overbroad; .2.3 owns its correction, while complete copy-domain reconciliation remains23.2/23.4 scope.
  Public Dart finding (October26): The same probe returns [["a"],1], confirming an ignored copy operand after receiver effects. Child .2.2 owns this repair; Julia .2.1 is committed at08098f3.
  Public finding (October26): Julia's proposed probe returns [["a"],1] instead of invalid-shape null with zero effects. The receiver is evaluated and extra argument ignored. Child .2.1 owns the confirmed repair; other backends remain unassessed.
  Planned tier: `focused`; public reproduction and bounded per-backend implementation children before writes.
  Goal: Confirm and repair extra-argument copy receiver shapes without changing valid copy/value-kind semantics.
  Intake: Julia's _evaluate_runtime_fluent_value_call! returns _runtime_copy(value) for copy without inspecting call.args. This is source-observed risk; no runtime conclusion is yet claimed. Similar dispatchers must be assessed individually, not assumed identical.
  Reproduce at activation: effects=0; out={effects=num_add(effects,1); [["a"]]}.first().copy({effects=num_add(effects,1); 1}); return([out,effects]). Receiver copy takes no extra operands; compare expected invalid-shape rejection/effect suppression against its actual public contract and observed output before repair.
  Schedule: After selected-value23.3.1 native rollout and committed P1 Rust scalar61.1/.61.2 repairs, before complete fluent admission. Split per-backend implementation leaves only from actual public reproduction; commit each bounded repair before the next assessment.
  Claim verification: none: Bounded deterministic invalid-shape reproduction/repair, not a quantified corpus, exhaustive or portable parity claim.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.2.1`
  Status: `done`
  Activation: clean `804f9657c47d62157e9f77b4f76749d24f11e7ab`.
  Goal: Reject extra Julia copy receiver operands before receiver/operand effects while preserving valid runtime-kind deep copies.
  Owned paths: julia/src/runtime/Interpreter.jl, targeted Julia test/registration and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public probe; Julia package compilation and small receiver_copy_arity test on native/generated-plan/fresh-emitted routes; direct selected_value_receivers test; book and fast continuity/history/diff guards.
  Canonical trigger: None for this bounded invalid receiver-shape repair under director feature-first cadence; complete fluent admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored shape/effect regression; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Require zero extra copy receiver arguments at any link before effects; keep valid array/harray/scalar copies, selected kind, nulls and source detachment. No helper vocabulary, function-copy or other-backend change without evidence.
  Completion: Extend Julia's existing first/last chain preflight to copy. The existing dynamic copy remains unchanged; invalid direct/selected shapes return null before receiver/operand effects.
  Acceptance Checklist:
  - [x] REPRODUCE / ISSUE: Public Julia probe returns copied array/effects1; the retained receiver_copy_arity test fails all three execution assertions before repair (invalid copies/effects2). Authored invalid-shape expectations are null/null/effects0; valid controls already agree.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_value_call! copies the current value without inspecting call.args; _evaluate_runtime_fluent_chain! only preflights first/last, allowing copy receiver effects before ignoring operands.
  - [x] FIX: Include canonical copy in the existing zero-extra-operand chain guard before evaluating the receiver. Preserve the actual deep-copy implementation and per-value continuation.
  - [x] ADDRESSED (verified): Julia package precompilation and targeted receiver_copy_arity native/generated-plan/fresh-emitted checks PASS after actual RED.
  - [x] NO REGRESSION: Valid array detachment, scalar continuation, missing/null and once-only receiver controls PASS; direct selected_value_receivers test PASS. No full package suite or broad matrix.
  - [x] LOCKSTEP: Register the regression; public copy boundary, scalar duplicate status, Julia fact/map, current frontier and live handoff agree. Book and fast continuity/history/diff checks pass before landing.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.2.1 - guard Julia receiver copy arity`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.2.2`
  Status: `done`
  Activation: clean `08098f3ef2075389279207e421cbc1b6986a2d5a`.
  Goal: Reject extra Dart copy receiver operands before receiver/operand effects while preserving valid deep-copy and selected-value behavior.
  Owned paths: dart/lib/src/runtime/interpreter.dart, dart/test/receiver_copy_arity_test.dart and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public probe; Dart receiver_copy_arity and direct selected_value_receivers tests (native/restored/generated-plan); changed-file analysis/format, book and fast continuity/history/diff guards.
  Canonical trigger: None for this bounded invalid receiver-shape repair under director feature-first cadence; full fluent admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored shape/effect regression; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Reject any extra copy receiver operands before effects at direct/selected links. Preserve valid copies/kinds, detachment, null/scalar continuation and once-only receiver evaluation; no unrelated helper or backend changes.
  Acceptance Checklist:
  - [x] REPRODUCE / ISSUE: Public Dart probe returns copied array/effects1. The retained regression returns two invalid copies/effects2 instead of null/null/effects0 before repair; valid controls already agree.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluateFluentCall's copy arm ignores call.args, while ActionFluentChainExpr only preflights first/last before receiver evaluation. The public runtime probe distinguishes this from correct deep-copy semantics.
  - [x] FIX: Add canonical copy to existing zero-extra-operand preflight. Preserve _copyValue and valid per-value dispatch.
  - [x] ADDRESSED (verified): Small native/restored/generated-plan receiver_copy_arity test PASS after actual RED; changed-file analyzer reports no issues and formatter passes.
  - [x] NO REGRESSION: Valid copy detachment/kinds, scalar/null continuation and once-only controls plus direct selected_value_receivers test PASS. No full Dart suite.
  - [x] LOCKSTEP: Public copy boundary, canonical Dart fact/map, current frontier and live handoff synchronized; book and fast continuity/history/diff checks pass before landing.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.2.2 - guard Dart receiver copy arity`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.2.3`
  Status: `done`
  Activation: clean `a929c92e8c3a4209375302d443792a306a5b1cf6`.
  Goal: Reject extra Rust copy receiver operands before effects and document the actual valid copy-domain boundary.
  Owned paths: rust/linkedspec-runtime/src/engine.rs, targeted receiver_copy_arity test and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Fresh public CLI probe; locked/offline Rust receiver_copy_arity and direct selected_value_receivers tests on native/restored/generated-plan; first-party rustfmt, book and fast continuity/history/diff guards.
  Canonical trigger: None for this bounded invalid-shape repair/documentation correction under director feature-first cadence; complete copy/fluent admission stays23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored shape/effect and current-domain controls; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Reject extra copy receiver operands before receiver/argument effects; retain valid container copies/kinds, detachment and once-only evaluation. Retain existing scalar/missing empty-array fallback, qualify backend-specific scalar/depth book wording and preserve canonical Perl authority; no unrelated helper-domain change.
  Acceptance Checklist:
  - [x] REPRODUCE / ISSUE: Fresh public CLI returns copied array/effects2; retained receiver_copy_arity test returns invalid copies/effects4 before repair. Expected shape is null/null/effects0. Tiny public Rust/Perl value controls confirm existing scalar/missing fallback instead of assuming universal copy semantics.
  - [x] ROOT CAUSE (WHY + WHERE): Expr::FluentChain preflights first/last only; copy reaches receiver_call_args and call_helper, evaluating extra arguments and copying the source. The overbroad book paragraph conflates Lua/Dart/Julia scalar preservation with Perl/Rust container-oriented copy.
  - [x] FIX: Add copy to existing pre-effect arity guard. Keep copy implementation/fallback unchanged; qualify the book using current public value controls and canonical Perl shallow-container authority.
  - [x] ADDRESSED (verified): Locked/offline compilation and authored receiver_copy_arity native/restored/generated-plan regression PASS after actual RED.
  - [x] NO REGRESSION: Valid container detachment, once-only receiver, selected copy and existing scalar/missing fallback plus direct selected_value_receivers test PASS; first-party rustfmt passes. No full crate suite.
  - [x] LOCKSTEP: Public copy boundary, canonical array fact/map, task/current frontier and live handoff agree. Book and fast continuity/history/diff checks pass before landing; full copy-domain reconciliation remains23.2/23.4-owned.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.2.3 - guard Rust receiver copy arity`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.2.4`
  Status: `done`
  Activation: clean `222db28a32a4047ca9fccba03927c3eb975a29bb`.
  Goal: Reject extra Lua copy receiver operands before effects; confirm the already-correct bounded Perl copy-arity path.
  Owned paths: lua/src/linkedspec/interpreter.lua, targeted Lua test/registration and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Lua/Perl probes; fresh matching available PUC5.5.1/LuaJIT native builds, Lua syntax and small receiver_copy_arity native/generated-plan/fresh-emitted test plus direct selected-value regression; Perl native/fresh controls, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded invalid-shape repair under director feature-first cadence; complete copy/fluent admission stays23.4 and eventual clean push proof. Declared PUC5.4 target proof remains LUA-STARTUP-READING.2.2.
  Claim verification: none: deterministic authored shape/effect regression; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Reject extra copy operands before receiver/argument effects, preserve valid copy/kind/detachment/null/scalar behavior and once-only evaluation. Do not change Perl's already-correct public result; retain copy-domain/depth qualifications and Lua host limitations.
  Acceptance Checklist:
  - [x] REPRODUCE / ISSUE: Both available Lua public probes return [1,2]; retained native fixture returns extra operand copies/effects4 instead of null/null/effects0. Perl Get independently returns the correct selected null/effects0; no false Perl RED.
  - [x] ROOT CAUSE (WHY + WHERE): Lua fluent copy recognizes zero arguments only; extra-argument shapes fall through to function-copy evaluation and copy the operand. The chain preflight guards first/last only, after which receiver effects run.
  - [x] FIX: Extend canonical zero-extra-operand preflight to copy before receiver evaluation; retain copy_value and dynamic continuation. Register the small Lua regression.
  - [x] ADDRESSED (verified): Fresh matching available PUC5.5.1/LuaJIT products, syntax and authored native/generated-plan/fresh-emitted fixture PASS after actual RED.
  - [x] NO REGRESSION: Valid container detachment, scalar/null, once-only and direct selected-value controls PASS on both hosts. Perl direct/selected invalid shapes plus valid copies PASS through native Get and fresh emitted execution without runtime edits. No full Lua/Perl suite.
  - [x] LOCKSTEP: Public copy boundary, canonical Lua fact/map, task/current frontier and live handoff agree; book and fast continuity/history/diff checks pass. Declared5.4 and broader copy admission remain open under .2.5/23.4.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.2.4 - guard Lua receiver copy arity`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.2.5`
  Status: `pending`
  Goal: Admit bounded copy arity at the later supported-target/canonical boundary.
  Dependencies: .2.1-.2.4; LUA-STARTUP-READING.2.2 for declared PUC5.4 proof.
  Schedule: After feature coverage, compose existing targeted fixtures with23.4 admission and eventual clean push proof; do not launch duplicate broad suites during implementation.
  Planned tier: `canonical`; declare actual receipt/claim scope at activation.
  Claim verification: none: Future admission owner, no new measurement.
  Acceptance: Retain per-backend domain/depth distinctions, reject wrong shapes before effects through supported consumers, restore the declared Lua target and close the bounded parent without inferring complete fluent families.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.3`
  Status: `active` / bounded implementations complete; full admission remains23.4
  Goal: Implement the frozen count/count_keys/length result contract on ordinary backends, preserving correct existing behavior.
  Dependencies: .23.2.2.
  Children: `TYPE-REFERENCE-BOOK.1.2.23.3.3.1`, `TYPE-REFERENCE-BOOK.1.2.23.3.3.2`, `TYPE-REFERENCE-BOOK.1.2.23.3.3.3`, `TYPE-REFERENCE-BOOK.1.2.23.3.3.4`, `TYPE-REFERENCE-BOOK.1.2.23.3.3.5`; assess later backends individually after each clean implementation commit.
  Schedule: Feature/compile/quick-check/docs/commit per backend; full signatures/matrix/admission stays open and deferred.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.3.1`
  Status: `done`
  Activation: clean `4666667d09d3c133cd5e07a725fb08f718f533a5`.
  Goal: Implement Perl count/count_keys/length result continuations using existing selected-value scalar/number dispatch.
  Dependencies: .23.2.2.
  Owned paths: perl/LinkedSpec/ActionIR/MethodLowering.pm, targeted t/count_length_receiver_contract.t and existing suite registration, book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Small native/fresh count_length_receiver_contract and direct selected_scalar_receiver_contract/selected_container_receiver_contract tests, changed-module/new-test/registration syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for this bounded frozen feature under director feature-first cadence; full signatures/matrix/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored result/order/arity/scope regression; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Cover three producers after direct/selected/earlier pipeline sources, compatible scalar/number consumers, empty/null and source/argument order. Guard zero-extra producer shapes before effects, explicitly update the old ordinary count-uppercase terminal expectation, preserve helper domains/copy/deferred/callback boundaries and keep raw hash-chain DSL out of valid lowering. Small native/fresh checks and syntax, then commit before assessing the next backend.
  Completion: Route array count/length, string length and hash count_keys results through existing selected-value dispatch; replace the ordinary count/length continuation preflight stop with zero-extra shape validation, including count_keys. Existing helper implementations and the separate CodeblockRuntime evaluator are unchanged.
  Acceptance Checklist:
  - [x] REPRODUCE / ISSUE: Authored native/fresh fixture fails before repair, including stopped numeric chains and unlowered hash-chain syntax/host failures. Earlier isolated public count/length/hash controls distinguish the result-flow gap from working helper implementations.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering's ordinary fluent preflight rejects nonfinal count/length, and three return-family callbacks classify the producers as terminal. Hash rejection falls through with DSL residue; existing selected-value branches already support the required consumers.
  - [x] FIX: Preserve zero-extra arity but remove the producer continuation stop; classify count/count_keys/length as selected values and reuse all existing continuation loops. Explicitly supersede the ordinary count-uppercase negative control; keep deferred count behavior and other terminal families separate.
  - [x] ADDRESSED (verified): Small native/fresh count_length_receiver_contract PASS after actual RED for direct/selected/pipeline and ordinary function results, Unicode/array lengths, scalar conversion, empty/null and invalid-shape effects.
  - [x] NO REGRESSION: Count/length/key-count source/operand order is SALHK; later mutations retain the previously computed values and saved snapshots. Deferred count control stays null; direct selected-scalar/container tests and changed-module/new-test/registration syntax checks PASS. No full suite.
  - [x] LOCKSTEP: Register the regression; public working examples, contract status, canonical fact/map, current frontier and live handoff agree. Book and fast continuity/history/diff checks pass before landing; next Rust leaf begins with a public probe, not an assumed defect.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.3.1 - continue Perl count and length results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.3.2`
  Status: `done`
  Activation: clean `0d474c2e801270342a642e029eff28ac3b1a3218`.
  Goal: Publicly assess and implement/confirm the frozen count/count_keys/length result contract on Rust.
  Dependencies: .23.3.3.1.
  Owned paths: rust/linkedspec-runtime/src/engine.rs if repair is needed, focused Rust count/length receiver test and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Fresh public Rust CLI probe; locked/offline count_length_receivers and direct selected_value_receivers tests on native/restored/generated-plan, first-party rustfmt, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen feature implementation under director feature-first cadence; full signatures/matrix/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored result/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Begin with public Engine/primary-CLI controls beside nested helper equivalents, preserve already-correct behavior and claim no false RED. Cover three producers on direct/selected/earlier pipelines (including array length), numeric/scalar consumers, empty/null, source/operand effects and zero-extra shape rejection. Reuse existing helper domains/copy and callable vocabulary; run compilation plus a small native/restored/generated-plan check and direct dependents, then commit before the next backend.
  Acceptance Checklist:
  - [x] REPRODUCE / ISSUE: Fresh public CLI returns [null,5,null,6,null,5]. The authored fixture returns null producers, SH instead of SALHK and six invalid-shape effects before repair, distinguishing helper success from missing result flow and shape guards.
  - [x] ROOT CAUSE (WHY + WHERE): Engine static array/hash/string loops and dynamic endpoint checks stop count/count_keys/length; array-pipeline method checks exclude length. Expr::FluentChain's zero-extra guard covers extraction/copy only.
  - [x] FIX: Share is_selected_receiver_result_method for value handoff and dynamic endpoint exemptions; admit length within array links while keeping initial method dispatch unchanged. Extend the separate zero-extra guard to three count/length producers. Existing helper domains and callable vocabulary are unchanged.
  - [x] ADDRESSED (verified): Locked/offline compilation and small count_length_receivers native/restored/generated-plan assertions PASS after actual RED for direct/selected/pipeline/function results, scalar conversion, Unicode/array length, empty/null and invalid shapes.
  - [x] NO REGRESSION: SALHK effects, later source mutations, saved snapshots and zero invalid-shape effects agree; direct selected_value_receivers test and first-party rustfmt PASS. No full crate suite or broad context/portable admission.
  - [x] LOCKSTEP: Public Perl/Rust examples, contract status, canonical fact/map, task/current frontier and live handoff agree. Book and fast continuity/history/diff checks pass before landing; Dart begins with an independent public probe.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.3.2 - continue Rust count and length results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.3.3`
  Status: `completed`
  Activation: clean `d3f6fb4fc5eb63785e7b03f81a7fa9f724f27219`.
  Goal: Publicly assess and implement/confirm the frozen count/count_keys/length result contract on Dart.
  Dependencies: .23.3.3.2.
  Owned paths: dart/lib/src/runtime/interpreter.dart if needed, targeted count/length receiver test and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Dart producer/consumer and invalid-shape probes; small native/restored/generated-plan count/length plus direct selected-value tests, changed-file analysis/format, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen feature implementation/confirmation under director feature-first cadence; full signatures/matrix/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public reproduction / owned defects: Valid pairs return [5,5,6,6,5,5], so retain dynamic dispatch. count(extra) returns1 and runs receiver/operand effects twice instead of null/zero. Free count on [String,Hash,Number,Bool,undef,Array] returns [2,1,1,1,0,2], beside documented and public Perl [0,0,0,0,0,2]. Count incorrectly reuses _lengthValue; restrict Count to arrays while preserving Length and independent helper domains. Both small defects are owned and fixed in this leaf.
  Acceptance: Probe public valid producer/consumer pairs and preserve correct existing per-value dispatch. Independently check zero-extra shape/effect rejection; repair only observed defects. Cover direct/selected/earlier pipelines, values/kinds, Unicode/array length, source/argument snapshots and documented scope on native/restored/generated-plan consumers. Analyze/format changed files, compile/quick-check/docs/commit before the next backend.

  Completion: Preserve existing actual-value continuations. Extend zero-extra producer preflight to count/count_keys/length and restrict free/receiver count to Lists instead of reusing general length. Length Unicode/scalar/container behavior stays unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public valid pairs pass; invalid count(extra) runs effects, and non-array free count disagrees with the documented/public Perl oracle. Retained fixture RED shows bad producers returning2 with six effects and domain [2,1,1,1,0,2].
  - [x] ROOT CAUSE (WHY + WHERE): ActionFluentChainExpr guards extraction/copy only; helper argument collection evaluates ignored count/length extras. _callArrayHelper count delegates to _lengthValue, whose wider domains belong to length.
  - [x] FIX: Include three zero-extra producers in preflight; count only List values. Reuse existing dynamic continuation and length logic.
  - [x] ADDRESSED (verified): Small count_length_receivers native/restored/generated-plan fixture PASS after RED, including direct/selected/pipeline/function values, source snapshots, Unicode, SALHK order, nulls, zero invalid effects and array-only count.
  - [x] NO REGRESSION: Direct selected_value_receivers, changed-file fatal analysis and format PASS; no broad suite or complete family/portable admission is inferred.
  - [x] LOCKSTEP: Public examples/contract, Dart/central fact/map, current task/live records and bounded-history handling align; fast memory/cadence/diff/book checks pass.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.3.3 - guard Dart count and length producers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.3.4`
  Status: `completed`
  Activation: clean `bc7ae21edd999bee8217ce35b6fa990512d70633`.
  Goal: Publicly assess and implement/confirm the frozen count/count_keys/length result contract on Julia.
  Dependencies: .23.3.3.3.
  Owned paths: julia public runtime, small count/length receiver test and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Julia value/arity probes, small native/generated-plan/fresh-emitted count/length and direct selected-value tests, package compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen feature implementation/confirmation under director feature-first cadence; full context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public reproduction / owned defects: Valid producer pairs return [5,5,6,6,5,5]; count(extra) returns1 with two effects. Retained native/generated-plan/fresh-emitted RED confirms all three invalid producers return2 with six effects, and non-array count returns [2,1,1,1,0,2] instead of documented/public Perl [0,0,0,0,0,2]. Chain preflight omits producers; array count delegates to wider _runtime_value_length. Both bounded defects are owned and repaired in this leaf.
  Focused harness repair: Julia1.12 warns when the emitted parser execute binding is fetched outside invokelatest. Resolve that binding through invokelatest in the new/direct selected-value fixtures; verify both with --depwarn=error. Broader old fixture compatibility remains part of23.4 admission.
  Acceptance: Preserve correct existing value dispatch, probe valid chains and zero-extra shape/effect boundaries publicly, and repair only observed defects. Use a small native/generated-plan/fresh-emitted fixture plus direct selected-value checks, package compilation and docs; commit before Lua. Full context/portable admission stays separate.

  Completion: Preserve existing value continuations, extend producer arity preflight and restrict count to AbstractVectors; leave general length unchanged. Register the focused test and fetch fresh emitted execute bindings through invokelatest in new/direct fixtures.
  Verification:
  - [x] REPRODUCE / ISSUE: Public valid pairs pass, but count(extra) returns1/two effects. Native/generated-plan/fresh-emitted fixture RED confirms ignored extras/six effects and non-array count [2,1,1,1,0,2] beside the documented/public Perl oracle.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! omits count/count_keys/length from zero-extra validation; _call_runtime_array_helper count reuses wider _runtime_value_length. Julia1.12 separately diagnoses fresh emitted binding access outside invokelatest in the focused harnesses.
  - [x] FIX: Guard producer extras before source/operand evaluation, count only AbstractVectors and preserve existing dynamic dispatch/Length. Fetch emitted execute bindings through invokelatest in both focused fixtures.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted count/length and array-domain checks PASS after RED, retaining direct/selected/pipeline/function values, Unicode, SALHK effects, snapshots, nulls and zero invalid effects.
  - [x] NO REGRESSION: Package compilation and direct selected-value checks PASS; strict --depwarn=error rerun passes. Broader old harness compatibility and full portable admission remain23.4.
  - [x] LOCKSTEP: Public examples/contract, Julia/central fact/map, task/live records, book and fast continuity/history/diff checks align.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.3.4 - guard Julia count and length producers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.3.5`
  Status: `completed`
  Activation: clean `f61b2eaace135b711e2c300f2689de1d4a2857ec`.
  Goal: Publicly assess and implement/confirm the frozen count/count_keys/length result contract on shared Lua.
  Dependencies: .23.3.3.4.
  Owned paths: lua public interpreter, small count/length receiver test and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Lua value/arity probes; small native/generated-plan/fresh-emitted count/length and direct selected-value tests on available PUC5.5.1/LuaJIT with matching native products, loadfile compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; declared5.4 and full context/portable admission remain separately owned plus eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public reproduction / owned defects: Available PUC public pairs return [5,5,null,6,null,5], so count already continues but length/hash-count stop beside working nested controls. count(extra) returns1 with two effects. Shared evaluate_fluent_calls rejects nonfinal length through TERMINAL_STRING_HELPERS and count_keys through an explicit hash endpoint fence; chain preflight guards extraction/copy only. Repair these observed gaps here, preserving Count’s existing array-only domain and other endpoint policies.
  Acceptance: Preserve correct value dispatch, probe valid chains and zero-extra shape/effect boundaries through the public runtime, and repair only observed defects. Use small native/generated-plan/fresh-emitted and direct selected-value checks on available PUC5.5.1/LuaJIT with matching native products. Keep declared5.4 proof with LUA-STARTUP-READING.2.2 and full context/portable admission with23.4; commit before selecting the next feature.

  Completion: Keep correct Count and actual-value dispatch; remove only length/count_keys endpoint stops and extend zero-extra preflight. Retain other predicates/reducer/control boundaries and existing source domains. Register one small test.
  Verification:
  - [x] REPRODUCE / ISSUE: Public PUC pairs [5,5,null,6,null,5] distinguish stopped length/key-count from working Count and nested helpers. Retained fixture RED shows stopped values, skipped required operands, SAH order and six invalid effects.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls stops Length through TERMINAL_STRING_HELPERS and count_keys through a hash endpoint fence. evaluate_expr fluent preflight omits all three producers; later helper collection runs ignored extras.
  - [x] FIX: Remove only Length and key-count endpoint restrictions, retain existing Count/domain/dispatcher and add producer shape guards before receiver/operand effects.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted fixture PASS after RED on available PUC5.5.1/LuaJIT, including direct/selected/pipeline/function values, Unicode, SALHK effects, later-mutation snapshots, array-only Count and zero invalid effects.
  - [x] NO REGRESSION: Direct selected-value fixture and loadfile compilation of interpreter/runner pass with fresh matching native products on both available hosts. Declared5.4 proof remains LUA-STARTUP-READING.2.2; full method/context/portable admission stays23.4.
  - [x] LOCKSTEP: Public examples/contract, Lua/central facts/map, tasks/live records, book and fast continuity/history/diff checks align. Next source-backed feature selection is aggregate numeric result flow23.2.3, before exhaustive signatures/matrices.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.3.5 - continue Lua count and length results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.4`
  Status: `active` / bounded implementations complete; full admission remains23.4
  Goal: Implement the frozen ordinary aggregate numeric reducer result contract on each backend, preserving correct existing behavior.
  Dependencies: .23.2.3.
  Children: `TYPE-REFERENCE-BOOK.1.2.23.3.4.1`, `TYPE-REFERENCE-BOOK.1.2.23.3.4.2`, `TYPE-REFERENCE-BOOK.1.2.23.3.4.3`, `TYPE-REFERENCE-BOOK.1.2.23.3.4.4`, `TYPE-REFERENCE-BOOK.1.2.23.3.4.5`; assess later backends individually after clean implementation commits.
  Planned tier: Focused bounded children; complete context/portable admission remains23.4.
  Claim verification: none: Unactivated implementation family; no support/completeness measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.4.1`
  Status: `completed`
  Activation: clean `a71e0a0fe293783d27881cf131476fb30c42a6f6`.
  Goal: Continue ordinary Perl six aggregate reducer results through existing compatible pure scalar/number methods.
  Dependencies: .23.2.3.
  Owned paths: perl/LinkedSpec/ActionIR/MethodLowering.pm, small native/fresh regression and suite registration, helper reference/reducer fact/map/task/live records.
  Verification tier: `focused`
  Focused checks: Small native/fresh aggregate_numeric_receiver_contract and direct count_length_receiver_contract tests after actual RED, changed-module/test/registration syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation under director feature-first cadence; full signatures/context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Boundary finding / repair: Initial selected-value handoff passes valid results but changes old incompatible .sum().drop_front()/.min().sorted() null controls to empty arrays. Public substitution shows generic array fallback applied to the scalar reducer result. Preserve the frozen boundary with scalar_result flow metadata, restricted scalar/number consumers and propagation until an explicit string-to-array bridge. Do not relax those controls.
  Acceptance: Preserve zero-extra aggregate arity and scalar min/max overloads, actual source/results, null/error/empty policy, once-only ordered operands and mutation snapshots. Supersede only compatible ordinary reducer terminal controls, keep deferred and reducer-kind95 policies separately owned, and use small native/fresh plus direct Count/Length checks. Commit before assessing Rust; no full replay.

  Completion: Reuse selected-value continuation machinery with scalar_result metadata until an explicit string-to-array bridge. Remove ordinary reducer continuation stops, retain zero-extra shape checks and route zero-extra initial min/max through array handling while scalar overloads keep their numeric path. No helper implementation or separate deferred evaluator change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public probe and native/fresh fixture RED show stopped six-producer results, skipped source/consumer effects and missing mutations. Working scalar min/max controls distinguish overloads. An intermediate handoff exposes [] for old incompatible-array null controls; substitution identifies generic array fallback.
  - [x] ROOT CAUSE (WHY + WHERE): Ordinary MethodLowering preflight rejects nonfinal reducers; append_array_chain_call marks results terminal, while initial numeric dispatch claims zero-extra min/max. Generic selected dispatch needs a scalar boundary to preserve old incompatible consumers.
  - [x] FIX: Keep producer arity, hand reducer values to scalar_result flow using the existing selected dispatcher, propagate scalar metadata and release it only through an explicit Array bridge. Preserve scalar min/max operands and zero-extra Array min/max classification across all six loops.
  - [x] ADDRESSED (verified): Small native/fresh aggregate_numeric_receiver_contract PASS after actual RED for six direct/selected/pipeline/function results, even median, text/Array bridge, empty/null, scalar overloads, SA order, later mutation snapshots and invalid-shape suppression.
  - [x] NO REGRESSION: Direct count_length_receiver_contract and changed-module/new-test/registration syntax PASS. Old incompatible-array results and separate deferred reducer continuation remain null; existing source domains/kind95 remain unchanged. No broad suite or portable admission.
  - [x] LOCKSTEP: Register regression, update helper/guide/contract examples and stale guide Length summary, retain scalar-boundary fact/map and current task/live records; book and fast continuity/history/diff checks pass.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.4.1 - continue Perl aggregate numeric results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.4.2`
  Status: `completed`
  Activation: clean `e08a85b291554c98fd5636907104057246ab777e`.
  Goal: Publicly assess and implement/confirm ordinary aggregate numeric result continuations on Rust.
  Dependencies: .23.3.4.1.
  Owned paths: Rust engine if needed, focused native/restored/generated-plan regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Fresh public Rust CLI fluent/nested producer probes; locked/offline small aggregate_numeric_receivers and direct count_length_receivers native/restored/generated-plan tests, first-party rustfmt, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; complete context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / ownership: Fresh CLI returns [null,13,null,5,null,5,null,5,null,3,null,7]. Static Array-family loops classify reducers as terminal, dynamic endpoint checks exclude them from selected-result handoff, and the chain preflight lacks unambiguous aggregate zero-extra guards. Implement observed result-flow/shape gaps here, preserving source domains and old incompatible-array null boundaries.
  Empty-sum defect / owned repair: Public compiled CLI returns [null,null,null,null] for [num_sum([]),num_add(num_sum([]),1),num_sum(["bad"]),num_avg([])] instead of [0,1,null,null]. The shared num_sum/avg/median/range arm rejects every empty numeric list before considering sum; return zero only for an actually empty Array sum. Keep nonempty filtering/domain differences unchanged. Retain the direct helper control in this fixture.
  Edit-script note: A Rustfmt-layout assertion stopped the first edit before production writes; the resulting unchanged-source rerun is retained as RED, never GREEN evidence. The corrected edit validates all matches before writing.
  Acceptance: Preserve correct existing dispatch, helper domains and scalar min/max overloads. Check six valid producer-result chains publicly before classifying defects; retain scalar-only boundaries until an explicit Array bridge, order/snapshots/nulls/empty shapes and existing callable vocabulary. Compile and focused/direct checks, docs/commit before the next backend; no broad replay or complete admission.

  Completion: Include six reducers in existing result handoff/static/dynamic endpoint exemptions, carry scalar-result boundaries until an actual container bridge, and guard zero-extra sum/avg/median/range before effects. Preserve scalar min/max overloads and callable vocabulary. Repair empty Array sum to zero without changing nonempty filtering.
  Verification:
  - [x] REPRODUCE / ISSUE: Fresh public CLI six pairs and authored fixture are RED for stopped result flow and ignored-argument effects. Independent public empty helper probe returns [null,null,null,null] beside normative [0,1,null,null].
  - [x] ROOT CAUSE (WHY + WHERE): Engine static/dynamic endpoints exclude reducers from selected-result flow; Expr::FluentChain guard omits unambiguous aggregates. The shared numeric arm rejects empty terms before sum can return its additive identity.
  - [x] FIX: Share reducer result classification across existing handoffs, retain scalar-only consumer validation and clear it when a helper produces a container. Add early shape guards and the actually-empty-Array sum identity; keep other helper domains/callable vocabulary/serialized formats unchanged.
  - [x] ADDRESSED (verified): Locked/offline aggregate_numeric_receivers native/restored/generated-plan PASS after actual RED for six producers, overloads, empty/direct helpers, nulls, selected/pipeline/function values, even median, text/Array bridge, SA effects, source mutation snapshots and zero invalid effects.
  - [x] NO REGRESSION: Direct count_length_receivers, compilation and first-party rustfmt PASS; old incompatible consumers remain null. Nonempty generic filtering, existing callback vocabulary and broad context/portable admission stay separately owned.
  - [x] LOCKSTEP: Public helper/guide/contract examples, canonical reducer fact/map, tasks/live records, book and fast continuity/history/diff checks align. Dart assessment follows after this clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.4.2 - continue Rust aggregate numeric results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.4.3`
  Status: `completed`
  Activation: clean `f0596ea0430566608988500c04fd5ddf4da67e45`.
  Goal: Publicly assess and implement/confirm ordinary aggregate numeric result continuations on Dart.
  Dependencies: .23.3.4.2.
  Owned paths: Dart public interpreter if needed, focused native/restored/generated-plan regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Dart producer/shape/domain probes, small native/restored/generated-plan aggregate_numeric_receivers and direct Count/Length tests, changed-file fatal analysis/format, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; complete context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / owned defects: Valid six fluent/nested pairs agree [13,13,5,5,5,5,5,5,3,3,7,7], and empty helper controls already pass [0,1,null,null]. sum(extra) returns1 with two effects; incompatible Array consumers yield []/[] instead of the frozen null boundary. Preserve existing valid dispatch/empty identity, guard unambiguous aggregate shape before effects and carry scalar-result validation across ordinary/mutating-source value loops.
  Acceptance: Preserve correct dispatch, helper domains and scalar min/max overloads. Probe six producer results, unambiguous zero-extra shapes, scalar-only boundaries until an explicit Array bridge and empty helper controls before classifying defects. Small native/restored/generated-plan and direct Count/Length checks, changed-file analysis/format, docs/commit before Julia; no broad replay or complete admission.

  Completion: Keep valid result dispatch/empty identity, add canonical zero-extra num_sum/num_avg/num_median/num_range preflight and share ordinary/mutating-source continuation iteration. Track actual Array reduction results as scalars until a helper returns a container; reject array/hash-only consumers at that boundary.
  Verification:
  - [x] REPRODUCE / ISSUE: Public valid pairs/empty controls pass; sum(extra) runs two effects and incompatible Array consumers yield []/[]. Retained native fixture RED additionally shows invalid reducer operands mutate a named source and run eight effects.
  - [x] ROOT CAUSE (WHY + WHERE): ActionFluentChainExpr preflight omits canonical aggregate helpers, and its two value loops call generic helper dispatch without retaining scalar reduction boundaries.
  - [x] FIX: Extend zero-extra preflight and reuse _evaluateFluentCallsWithValue in both loops. Preserve existing helpers and dynamic min/max selection; retain scalar boundaries until actual container output.
  - [x] ADDRESSED (verified): Small native/restored/generated-plan aggregate fixture PASS after RED for six producers, overloads, empty helpers, selected/pipeline/function and named-mutation sources, explicit split, SA order, snapshots, incompatible nulls and zero invalid effects.
  - [x] NO REGRESSION: Direct count_length_receivers, changed-file fatal analysis and format PASS. Existing valid result flow, source domains/empty sum and callable vocabulary remain unchanged; full context/portable admission stays23.4.
  - [x] LOCKSTEP: Worked helper/guide/contract examples, Dart/reducer facts/map, current task/live records, book and fast continuity/history/diff checks align; Julia assessment follows the clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.4.3 - guard Dart aggregate result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.4.4`
  Status: `completed`
  Activation: clean `b9c37c64c3653344dbcbde093026bdb5627873ee`.
  Goal: Publicly assess and implement/confirm ordinary aggregate numeric result continuations on Julia.
  Dependencies: .23.3.4.3.
  Owned paths: Julia public interpreter if needed, focused native/generated-plan/fresh-emitted regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Julia producer/shape/domain probes, small native/generated-plan/fresh-emitted aggregate and direct Count/Length tests, strict Julia1.12 harness/package compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; complete context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / owned defects: Valid six fluent/nested pairs agree and empty helpers pass [0,1,null,null]. sum(extra) returns1/two effects; incompatible Array consumers yield []/[] instead of frozen null boundaries. Preserve correct value/min-max/empty behavior; guard canonical unambiguous aggregate shapes and retain scalar-result boundaries in the existing loop.
  Acceptance: Preserve correct dispatch, helper domains and scalar min/max overloads. Probe six result chains, unambiguous zero-extra shapes, scalar-only boundaries until an explicit Array bridge and empty helper controls before classifying defects. Small native/generated-plan/fresh-emitted and direct Count/Length checks with strict Julia1.12 harness/package compilation, docs/commit before Lua; no broad replay or complete admission.

  Completion: Preserve correct result dispatch/empty identity, extend canonical unambiguous aggregate preflight and retain scalar reduction boundaries in the existing loop until a helper returns a container. Register the focused fixture; no helper implementation or public format changes.
  Verification:
  - [x] REPRODUCE / ISSUE: Public valid pairs and empty controls agree; sum(extra) runs two effects and incompatible Array consumers yield []/[]. Native/generated-plan/fresh-emitted fixture RED retains invalid named mutation/effects and scalar-boundary differences.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! omits canonical aggregate methods from shape preflight and carries no scalar-result boundary between calls; generic wrong-kind Array helpers supply empty arrays.
  - [x] FIX: Guard num_sum/avg/median/range extras before source/operand effects and preserve scalar-only compatibility after actual Array reductions until a helper returns a container. Keep existing helper/domain/min-max/empty policies.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted aggregate fixture PASS after RED for six producers, overloads, empty helpers, direct/selected/pipeline/function/named-mutation sources, explicit split, SA order, snapshots, incompatible nulls and zero invalid effects.
  - [x] NO REGRESSION: Direct Count/Length tests, package compilation and strict Julia1.12 --depwarn=error harness checks PASS. Existing callable vocabulary and full context/portable admission remain separate.
  - [x] LOCKSTEP: Register fixture; update worked helper/guide/contract examples, Julia/reducer facts/map and current task/live records; book and fast continuity/history/diff checks pass. Lua assessment follows the clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.4.4 - guard Julia aggregate result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.4.5`
  Status: `completed`
  Activation: clean `629cdf0337d8a4847f9459f68db3139177acb558`.
  Goal: Publicly assess and implement/confirm ordinary aggregate numeric result continuations on shared Lua.
  Dependencies: .23.3.4.4.
  Owned paths: Lua public interpreter if needed, focused native/generated-plan/fresh-emitted regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Lua producer/shape/domain probes; small native/generated-plan/fresh-emitted aggregate and direct Count/Length tests on available PUC5.5.1/LuaJIT with matching native products, loadfile compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; declared5.4 and complete context/portable admission remain separately owned plus eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / ownership: Fresh PUC pairs are [null,13,null,5,null,5,null,5,null,3,null,7]; invalid sum(extra) already returns null but runs two effects. Empty helpers and old incompatible consumers already pass. evaluate_fluent_calls has a blanket reducer endpoint stop; remove it for compatible scalar consumers, retain scalar boundaries (including lowercase_each/uppercase_each routed via String helpers) and guard unambiguous canonical aggregate shapes before effects.
  Acceptance: Preserve correct dispatch, source domains and scalar min/max overloads. Probe six result chains, unambiguous zero-extra shapes, scalar boundaries until an explicit Array bridge and empty helper controls before classifying defects. Use small native/generated-plan/fresh-emitted and direct Count/Length checks on available PUC5.5.1/LuaJIT with matching products, loadfile compilation, docs/commit. Keep declared5.4 proof with LUA-STARTUP-READING.2.2 and full context/portable admission separate; no broad replay.

  Completion: Remove the reducer endpoint stop, retain scalar-result compatibility until actual container output and guard canonical unambiguous aggregate extras before effects. Preserve correct empty identity/min-max/domain behavior and old incompatible consumers, including Array case maps routed through String helpers. Register the fixture.
  Verification:
  - [x] REPRODUCE / ISSUE: Public PUC six pairs and retained fixture are RED for stopped results, skipped operands and ignored-argument effects. Empty helpers and old incompatible consumers already pass; preserve them. Invalid shapes mutate named arrays and run eight effects before repair.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls unconditionally stops after evaluate_numeric_reducer_values; evaluate_expr preflight omits canonical aggregate shapes. Generic consumers need a scalar boundary when the endpoint stop is removed; lowercase_each/uppercase_each live in String dispatch.
  - [x] FIX: Carry reducer results through compatible Scalar/Number consumers and release scalar boundaries only on actual container output. Include Array case maps in compatibility guards; reject num_sum/avg/median/range extras before source/operand effects.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted aggregate fixture PASS after RED on available PUC5.5.1/LuaJIT, with six producers, overloads, empty helpers, named mutation suppression, explicit split, SA order, snapshots and old incompatible nulls.
  - [x] NO REGRESSION: Direct Count/Length fixture and interpreter/runner loadfile compilation PASS with matching fresh native products on both hosts. Existing source domains, empty sum and callable vocabulary remain unchanged; declared5.4/full admission stay separately owned.
  - [x] LOCKSTEP: Register fixture; update worked helper/guide/contract, Lua/reducer facts/map and current task/live records; book and fast continuity/history/diff checks pass. Join-result assessment23.2.4 is next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.4.5 - continue Lua aggregate numeric results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.5`
  Status: `active` / bounded implementations complete; full admission remains23.4
  Goal: Implement the frozen ordinary joined String result contract on each backend, preserving correct existing behavior.
  Dependencies: .23.2.4.
  Children: `TYPE-REFERENCE-BOOK.1.2.23.3.5.1`, `TYPE-REFERENCE-BOOK.1.2.23.3.5.2`, `TYPE-REFERENCE-BOOK.1.2.23.3.5.3`, `TYPE-REFERENCE-BOOK.1.2.23.3.5.4`, `TYPE-REFERENCE-BOOK.1.2.23.3.5.5`; assess later backends individually after clean commits.
  Planned tier: Focused bounded children; complete context/portable admission remains23.4.
  Claim verification: none: Unactivated implementation family; no support/completeness measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.5.1`
  Status: `completed`
  Activation: clean `6978191195862cb74c0f6bd20081c5b3dba28d86`.
  Goal: Continue ordinary Perl join_values String results through compatible pure methods using existing result dispatch.
  Dependencies: .23.2.4.
  Owned paths: MethodLowering.pm, small native/fresh regression and suite registration, helper/guide/contract/fact/map/task/live records.
  Verification tier: `focused`
  Focused checks: Small native/fresh joined_string_receiver_contract after actual RED plus direct aggregate_numeric_receiver_contract, changed-module/test/registration syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation under director feature-first cadence; complete public/context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Add joined-result flow and exact one-delimiter pre-effect shape rejection, remove raw DSL from the valid hash-view chain and preserve correct producer snapshots/SDN order. Check direct/selected/pipeline/hash/function and empty sources, actual String/length/split transitions, old incompatible/deferred boundaries and later mutations. Small native/fresh plus direct aggregate checks, syntax/docs/commit before Rust assessment; source-domain normalization and Lua false-delimiter repair stay separately owned.

  Completion: Classify join_values as scalar_result using existing six-loop continuation handling and add exact one-delimiter preflight before effects. Preserve the join helper, free delimiter-first roles, existing snapshots/order/domains and separate deferred evaluator; no new formats/types.
  Verification:
  - [x] REPRODUCE / ISSUE: Public isolated Get/substitution confirms stopped direct/selected results and raw hash DSL/host sorted_values lookup. Retained native/fresh fixture RED exposes invalid-shape handler compile failure and stopped joined results.
  - [x] ROOT CAUSE (WHY + WHERE): append_array_chain_call returns terminal for join_values; later loops stop or fall through to raw DSL. Ordinary preflight lacks an exact one-delimiter check.
  - [x] FIX: Return scalar_result from the join handoff and reject other arities before lowering source/operand effects, reusing existing continuation/compatibility machinery.
  - [x] ADDRESSED (verified): Small native/fresh joined_string_receiver_contract PASS after RED for named/literal/function/selected/pipeline/hash/String sources, empty/Unicode, split/length bridges, SDAN order, mutation snapshots, clean invalid-shape nulls/zero effects and incompatible Array nulls.
  - [x] NO REGRESSION: Direct aggregate_numeric_receiver_contract and changed-module/new-test/registration syntax PASS. Existing join source domains/copy/null policies and separate deferred evaluation are unchanged; no additional context/portable admission.
  - [x] LOCKSTEP: Register fixture; update helper/guide/contract examples, Array fact/map and current task/live records; book and fast continuity/history/diff checks pass. Rust assessment follows the clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.5.1 - continue Perl joined String results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.5.2`
  Status: `completed`
  Activation: clean `5581d074d63bb32824280fad9243407f0ed7847c`.
  Goal: Publicly assess and implement/confirm ordinary joined String result continuations on Rust.
  Dependencies: .23.3.5.1.
  Owned paths: Rust public engine if needed, focused native/restored/generated-plan regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Fresh public Rust joined-result/nested probe; locked/offline small joined_string_receivers and direct aggregate_numeric_receivers native/restored/generated-plan tests, first-party rustfmt, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; complete public/context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / owned repair: Fresh Rust CLI returns [null,"A,B",null,"A-B",null,"X:Y"] for direct/selected/hash-view fluent/nested pairs. Join is absent from result handoff classification and retains Array endpoint rejection; preflight validates zero-extra methods only. Assess exact shape effects/snapshots in the focused fixture and reuse existing scalar-result boundaries rather than weakening incompatible Array consumers.
  Direct-dependent route / owned assessment: Expr::FluentChain’s named Array-end mutation tail iterates the generic dispatcher outside the scalar-result loop. The shared join handoff classifier affects this documented ordinary value route; add a valid mutating-source join and incompatible Array-consumer control before landing. Reuse the common continuation loop if the current candidate exposes a missing scalar boundary.
  Candidate regression / verified root: The added public Engine fixture returns "A,B,C" correctly for named_parts.push_back("c").join_values(",").uppercase(), but push_back("d").join_values(",").sorted() returns [] instead of prior/frozen null. The named mutation tail bypasses scalar-result tracking, allowing generic wrong-kind Array fallback. Reuse eval_selected_receiver_value_chain with an initial non-scalar flag for that tail; keep the distinguishing negative intact and verify before landing.
  Acceptance: Preserve correct dispatch and join source/domains/snapshot behavior. Probe valid joined-result chains, exact one-delimiter shapes, scalar boundaries until explicit Array bridge and receiver/delimiter/consumer order before classifying defects. Small native/restored/generated-plan and direct aggregate checks, compile/rustfmt/docs/commit before Dart. No new callable vocabulary, source-domain normalization or broad replay/admission.

  Completion: Include join_values in scalar-result classification/shared handoff and exact one-delimiter preflight. Generalize the private classifier to is_scalar_result_receiver_method and reuse selected continuation for named Array-end tails so they retain scalar guards. Preserve helper/source/copy/null behavior and callable vocabulary.
  Verification:
  - [x] REPRODUCE / ISSUE: Fresh public CLI and authored native fixture RED show stopped direct/selected/hash joins, skipped consumer effects and four invalid-shape effects. Added named-mutation control exposes [] instead of null after the initial candidate; valid mutating join already passes.
  - [x] ROOT CAUSE (WHY + WHERE): Join is excluded from result handoff/endpoint exemptions and exact arity preflight. The separate named mutation tail calls generic dispatch without scalar-result tracking, allowing wrong-kind Array fallback.
  - [x] FIX: Share scalar-result classification for six reducers/joins, retain scalar boundaries until container output and guard one delimiter before effects. Route Array-end tails through the same existing continuation loop with an initial non-scalar value.
  - [x] ADDRESSED (verified): Locked/offline joined_string_receivers native/restored/generated-plan PASS after initial/result and candidate-boundary RED, including named mutation sources, functions/selected/pipeline/hash/String sources, empty/Unicode, split/length bridges, SDAN order, snapshots, incompatible nulls and zero invalid effects.
  - [x] NO REGRESSION: Direct aggregate_numeric_receivers, compilation and first-party rustfmt PASS. Existing helper/source/deferred vocabulary and serialized formats remain unchanged; no additional complete context/portable admission.
  - [x] LOCKSTEP: Worked helper/guide/contract, Array fact/map and current task/live records align; book and fast continuity/history/diff checks pass. Dart assessment follows the clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.5.2 - continue Rust joined String results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.5.3`
  Status: `completed`
  Activation: clean `c5a06feebbbffd204004154a5c0bf5c0916e2f0c`.
  Goal: Publicly assess and implement/confirm ordinary joined String result continuations on Dart.
  Dependencies: .23.3.5.2.
  Owned paths: Dart public interpreter if needed, focused native/restored/generated-plan regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Dart joined-result/shape probes, small native/restored/generated-plan joined and direct aggregate fixtures, changed-file fatal analysis/format, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; complete public/context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / owned boundaries: Valid Dart direct/selected/hash joined-result pairs already agree. A missing delimiter returns "a" and runs its receiver effect; a joined scalar followed by sorted yields [] instead of frozen null. Preserve correct result flow, add exact one-delimiter preflight and extend existing shared scalar-producer tracking to join_values.
  Acceptance: Preserve correct dispatch, producer snapshots/order/source domains and inherited null/copy behavior. Probe joined-result chains, exact one-delimiter shapes, scalar boundaries until explicit Array bridge and named-mutation sources before classifying defects. Small native/restored/generated-plan and direct aggregate checks, changed-file fatal analysis/format, docs/commit before Julia. No source normalization or broad replay/admission.

  Completion: Keep already-correct joined-result dispatch/snapshots and add exact one-delimiter preflight. Extend shared Array scalar-producer tracking to join_values while preserving generic helper/source/null/copy behavior.
  Verification:
  - [x] REPRODUCE / ISSUE: Public valid direct/selected/hash pairs pass, but missing delimiter returns a/runs one effect and incompatible sorted returns []. Retained native fixture RED also catches named-mutation fallback and malformed arity effects.
  - [x] ROOT CAUSE (WHY + WHERE): ActionFluentChainExpr guards zero-extra methods only; _evaluateFluentCallsWithValue tracks numeric aggregates but omits joined String producers.
  - [x] FIX: Validate one delimiter before receiver/operand effects and include join_values in scalarProducer tracking until an actual container result. Preserve existing valid helper/value behavior.
  - [x] ADDRESSED (verified): Small native/restored/generated-plan joined fixture PASS after RED for named mutations, functions/selected/pipeline/hash/String sources, empty/Unicode, split/length bridges, SDAN order, snapshots, incompatible nulls and zero invalid effects.
  - [x] NO REGRESSION: Direct aggregate fixture, changed-file fatal analysis and format PASS. Existing producer domains/null/copy behavior and callable vocabulary remain unchanged; no complete context/portable admission.
  - [x] LOCKSTEP: Worked helper/guide/contract, Dart/Array facts/map and current task/live records align; book and fast continuity/history/diff checks pass. Julia assessment follows the clean commit; container-default transition assessment is scheduled after bounded joins.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.5.3 - guard Dart joined String boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.5.4`
  Status: `completed`
  Activation: clean `e84864bf19e2eec290f5163b6dc6506c923f71ad`.
  Goal: Publicly assess and implement/confirm ordinary joined String result continuations on Julia.
  Dependencies: .23.3.5.3.
  Owned paths: Julia public interpreter if needed, focused native/generated-plan/fresh-emitted regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Julia joined-result/shape probes, small native/generated-plan/fresh-emitted joined and direct aggregate fixtures, strict Julia1.12 harness/package compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; complete public/context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / owned boundaries: Julia valid direct/selected/hash joined-result pairs already agree; missing delimiter returns "a"/runs one effect, and sorted after joined String yields []. Preserve correct result/snapshot behavior; add exact one-delimiter preflight and include join_values in scalar-producer tracking within the existing loop.
  Acceptance: Preserve correct dispatch, producer snapshots/order/source domains and inherited null/copy behavior. Probe joined chains, exact one-delimiter shapes, scalar boundaries until explicit Array bridge and named mutation sources before classifying defects. Small native/generated-plan/fresh-emitted and direct aggregate checks with strict Julia1.12 harness/package compilation, docs/commit before Lua. No source normalization or broad replay/admission.

  Completion: Preserve correct result/snapshot behavior and add one-delimiter preflight plus join_values scalar-producer tracking in the existing value loop. Register the focused fixture; no helper/domain/copy/format changes.
  Verification:
  - [x] REPRODUCE / ISSUE: Public valid direct/selected/hash pairs agree; missing delimiter runs one effect and incompatible sorted yields []. Native/generated-plan/fresh-emitted fixture RED confirms malformed arity and scalar-boundary differences.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! guards zero-extra methods and tracks numeric reductions only; joined String producers receive no arity/scalar-result boundary.
  - [x] FIX: Reject non-one-delimiter shapes before effects and include join_values in scalar_producer tracking until actual container output. Keep existing helpers and producer behavior.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted joined fixture PASS after RED for named mutations, functions/selected/pipeline/hash/String sources, empty/Unicode, split/length bridges, SDAN order, snapshots, incompatible nulls and zero invalid effects.
  - [x] NO REGRESSION: Direct aggregate fixture, package compilation and strict Julia1.12 --depwarn=error harness PASS. Existing source/null/copy behavior and callable vocabulary stay unchanged; complete context/portable admission remains separate.
  - [x] LOCKSTEP: Register fixture and align worked helper/guide/contract, Julia/Array facts/map, current task/live records; book and fast continuity/history/diff checks pass. Lua assessment follows the clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.5.4 - guard Julia joined String boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.5.5`
  Status: `completed`
  Activation: clean `5856cfcb630f08df2ff9532241c38a78e6138de1`.
  Goal: Publicly assess and implement/confirm ordinary joined String result continuations on shared Lua.
  Dependencies: .23.3.5.4.
  Owned paths: Lua public interpreter if needed, focused native/generated-plan/fresh-emitted regression and synchronized book/fact/task/live records, including any confirmed join-only update to the existing false-delimiter owner2.9.
  Verification tier: `focused`
  Focused checks: Public Lua joined-result/shape/false-delimiter probes; small native/generated-plan/fresh-emitted joined and direct aggregate fixtures on available PUC5.5.1/LuaJIT with matching products, loadfile compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; declared5.4 and complete public/context/portable admission remain separately owned plus eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public findings / owned repair: PUC direct/selected/hash fluent pairs stop beside working nested controls. Missing delimiter returns a/runs one effect. The tracked false-delimiter issue reproduces: free join gives a0b, receiver ab, nested uppercase A0B and joined continuation null. evaluate_array_values uses an and/evaluate/or-empty fallback, replacing evaluated false. Repair the join route here with literal/computed false controls; retain mutable split under LUA-STARTUP-READING.2.9.1 for its next bounded leaf.
  Acceptance: Preserve correct source/snapshots/null/copy behavior, probe joined chains, one-delimiter shapes, scalar boundaries and named mutations. Reverify the existing LUA-STARTUP-READING.2.9 join false-delimiter route and own a small confirmed join repair here; mutable split stays with its existing owner. Small native/generated-plan/fresh-emitted and direct aggregate checks on available PUC5.5.1/LuaJIT with matching products, loadfile/docs/commit. Declared5.4/full admission remain separate; no broad replay/source normalization.

  Completion: Remove join endpoint rejection, retain scalar boundaries until container output and enforce one delimiter before effects. Replace the truthy evaluated-delimiter fallback with an explicit argument-presence branch, preserving false and once-only evaluation. Register the focused fixture; mutable split remains a separate next leaf.
  Verification:
  - [x] REPRODUCE / ISSUE: Public joined/nested pairs show stopped results; missing delimiter runs its receiver. Free false join gives a0b while receiver gives ab. Retained native fixture RED independently captures false loss, skipped consumers, malformed arity effects and named-mutation boundaries.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls stops after join and evaluate_expr lacks one-delimiter validation. evaluate_array_values uses expr.args[1] and evaluate_expr(...) or empty text, replacing an evaluated false before scalar conversion.
  - [x] FIX: Carry joined scalars through compatible methods, validate arity before effects and default only for absent delimiter expressions. Preserve helper/source/copy semantics and retain scalar compatibility guards.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted joined fixture PASS after RED on available PUC5.5.1/LuaJIT, including literal/computed false equality and once-only effects, named mutations, functions/selected/pipeline/hash/String sources, Unicode, explicit bridges, SDAN order, snapshots and invalid shapes.
  - [x] NO REGRESSION: Direct aggregate fixture and interpreter/runner loadfile compilation PASS with matching fresh products on both hosts. Source normalization, mutable split and declared5.4/full admission remain separately owned; no new callable vocabulary/format.
  - [x] LOCKSTEP: Register fixture and align worked helper/guide/contract, current Lua/Array/false-delimiter facts/map, partial2.9 ownership and current task/live records; book and fast continuity/history/diff checks pass. Reverify/repair remaining mutable split next, then container-default23.2.5.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.5.5 - continue Lua joined String results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6`
  Status: `active` / bounded default rollout targeted-checked on recorded hosts; full admission open
  Goal: Implement/confirm bounded actual-kind default-selection continuations across maintained backends.
  Dependencies: .23.2.5.
  Children: `.23.3.6.1`, `.23.3.6.2`, `.23.3.6.3`, `.23.3.6.4`, `.23.3.6.5`.
  Acceptance: Existing ordinary nonempty default selections preserve actual kinds, lazy required-prefix effects and scalar/container boundaries per default-selection-results.md. Assess each backend publicly; full domain/portable admission remains23.4.

  Follow-up: TYPE23.3.16.1 fixes the confirmed existing Hash-default->Array-view->successor staging gap via the established compatibility bridge. Direct/default/call/numeric/Array/String roots and first/last/count/join/contains/index/reducer/transform/selection plus SDC/numeric-kind controls are targeted-checked; original62/full admission stay separate.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.1`
  Status: `completed` / bounded Perl flow/literal repairs targeted-checked
  Goal: Repair Perl default result flow and valid literal operand lowering in separate slices.
  Dependencies: .23.2.5.
  Children: `.23.3.6.1.1`, `.23.3.6.1.2`.
  Acceptance: Both bounded repairs committed/targeted-checked; broader signature/deferred/admission remains separate.
  Completion: Children1.1/1.2 are committed separately with focused native/fresh/direct proof. Full helper-domain/deferred/portable admission remains23.4.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.1.1`
  Status: `completed`
  Goal: Continue ordinary Perl coalesce_nonempty results by their actual selected kind.
  Dependencies: .23.2.5.
  Reproduce: Direct String Array consumer reaches host helper; joined Array/Hash paths lower undef beside working nested A-B/X:Y. String-family metadata and scalar_result propagation retain the producer kind.
  Owned paths: MethodLowering ordinary receiver flow, one focused native/fresh fixture, direct joined/default compatibility and public/current docs.
  Acceptance: Reuse existing lazy helper semantics; preserve retained Scalar incompatible nulls, selected Array/Hash methods, empty/null/zero/false, source/default/consumer SDJ order, skipped late operands and snapshots. Small compile/targeted checks/docs/commit; no full suite.
  Activation: clean `59556bc75e143d68ba5001330133e2b13bf82e14`; assessment committed, brief empty, tree clean.
  Verification tier: `focused`
  Focused checks: Public native/fresh selected-default regression after RED, direct joined/default-exhaustion compatibility, MethodLowering/test syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; literal operand repair1.2, full domain/portable admission23.4 and final clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.

  Completion: Give nonempty defaults a default_result family, bind the selected value once, guard Array/Hash consumers by runtime kind and retain scalar-result boundaries after scalar helpers. Lower source and consumer helpers before enclosing them in host guards/do blocks; preserve existing lazy helper semantics.
  Candidate correction: First guarded candidate enclosed still-authored helpers/blocks in host do source; native/fresh compilation failed. Public Get dump shows unlowered coalesce_nonempty/join_values/uppercase and bare effect bindings. Lower both expressions before host guard construction; the intermediate guarded-helper attempt still left the consumer raw and is also RED, not passing proof. Final focused native/fresh fixture is GREEN.
  Verification:
  - [x] REPRODUCE / ISSUE: Frozen Get/substitution/fresh pairs and retained target fixture RED show stopped Array/Hash flow/direct host-helper failure; old retained-scalar negatives stay null.
  - [x] ROOT CAUSE (WHY + WHERE): String metadata and scalar_result propagation retain source kind. Public generated source additionally identifies the candidate's DSL-inside-host wrapper boundary before correction.
  - [x] FIX: Dispatch default_result through a once-bound actual value with Array/Hash guards; fully lower source/consumer before host wrapping. Preserve existing free-helper and deferred domains.
  - [x] ADDRESSED (verified): t/default_selected_receiver_contract.t PASS native/fresh after RED: direct/joined Array, named Harray, selected-null, scalar retention, empty containers, zero/false, exhausted/null, skipped fallback and SDJ snapshot controls.
  - [x] NO REGRESSION: Direct joined and nonempty-exhaustion tests plus MethodLowering/test compilation PASS; no broad suite, new callable vocabulary or serialized format. Literal operands remain owned1.2.
  - [x] LOCKSTEP: Bounded contract/catalog, default fact/derived map and live/task/resume docs align; book and fast memory/cadence/diagnosis/history/diff checks pass. Literal repair1.2 next after clean commit, other backend assessments later.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.6.1.1 - continue selected Perl default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.1.2`
  Status: `completed`
  Goal: Preserve valid Hash literal operands through Perl lazy default lowering.
  Dependencies: .23.3.6.1.1.
  Reproduce / impact: coalesce_nonempty("",{"b":"y","a":"x"}) returns null with hash_literal_use_colon marker despite valid source; named Hash and nested view controls succeed. The AST value-only lowerer passes lowered host fat arrows through legacy DSL parsing. This silently discards a valid chosen fallback; assess ordinary coalesce twin and typed nested values with public probes before repair.
  Owned paths: bounded lazy default AST/legacy bridge and native/fresh fixture, qualified book/default facts/current docs.
  Acceptance: Lower typed operands without reparsing host Hash syntax as DSL, preserve laziness/kinds/effects and genuine retired authored-fat-arrow rejection. Do not normalize unrelated helper domains or deferred evaluation. Compile/small checks/docs/commit.
  Activation: clean `e01bf90551f70b8e5648baea6eb0052eebb4f19c`; flow committed, brief empty, tree clean.
  Verification tier: `focused`
  Focused checks: Public direct coalesce/nonempty Hash twins and nested typed/lazy controls, retained native/fresh literal regression after RED, direct selected-default/exhaustion compatibility, MethodLowering/test syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded existing typed operand repair under director feature-first cadence; full helper-domain/portable admission23.4 and final clean push remain separate.
  Claim verification: none: deterministic authored literal/kind/order regression; no quantified or portable measurement.

  Completion: Construct both lazy selectors from fully lowered typed operands via _lower_lazy_default_value_args. Reuse the same host-source builder from legacy paths, retaining original coalesce tail semantics and copied nonempty comparison. No host Hash source is reparsed as DSL.
  Public findings / candidate correction: Native/fresh RED confirms direct coalesce and coalesce_nonempty Hash twins plus fluent literal fallback are null; nested Array, empty Hash, block Hash and SDK order already work. The first candidate reused generic value-only argument reconstruction, which intentionally leaves authored variable/call source for the legacy phase; native/fresh/direct compatibility exposes host join_values/bare-binding compile errors. Lower default operands completely with bare_scalar_read before the shared builder; do not pass that mixed intermediate directly to host emission.
  Verification:
  - [x] REPRODUCE / ISSUE: Frozen public marker/named controls and t/default_literal_operand_contract.t RED distinguish direct valid Hash/default twins and fluent literal fallback from working typed nested/block controls.
  - [x] ROOT CAUSE (WHY + WHERE): lower_ast_value_only_call_node feeds lowered Hash host fat arrows into legacy_method_value_expr, triggering hash_literal_use_colon. Its generic intermediate also retains authored source, requiring complete typed operand lowering for the direct builder.
  - [x] FIX: Dedicated typed coalesce/nonempty operands plus shared lazy host builder avoid reparsing; legacy callers reuse the same selector construction after their existing normalization/lowering.
  - [x] ADDRESSED (verified): New native/fresh fixture PASS after RED for coalesce/nonempty Hash twins, nested Hash/Array bound numbers/false, fluent selected literal, empty Hash, lazy SDK order, skipped arms and numeric/false preservation. Genuine authored retired fat-arrow literal still produces the rejection marker.
  - [x] NO REGRESSION: Direct selected-default and nonempty-exhaustion fixtures plus MethodLowering/test compilation PASS. No broad suite, helper-domain normalization, callable vocabulary or serialized format change.
  - [x] LOCKSTEP: Contract/catalog, default fact/map and live/task/resume records align; book and fast memory/cadence/diagnosis/history/diff checks pass. Bounded Perl parent complete; Rust assessment2 next after clean commit, full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.6.1.2 - preserve typed lazy default operands`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.2`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Rust default-selection result flow.
  Dependencies: .23.3.6.1.
  Acceptance: Follow frozen default-selection-results.md with existing helper domains and actual-kind/lazy/effect/snapshot controls. Public native/generated distinguishing checks before repair; no inferred backend failure. Small compile/targeted checks/docs/commit; Lua declared5.4/full admission stays separate.
  Activation: clean `3fbd7be94e36e50241fd2665b97ddf520a59f4bb`; bounded Perl repairs committed, brief empty, tree clean.
  Owned paths: Rust public receiver dispatcher only for confirmed gaps, one focused native/restored/generated-plan fixture and direct default/join compatibility, public/current docs.
  Verification tier: `focused`
  Focused checks: Public CLI fluent/nested selected-default controls; small native/restored/generated-plan default regression plus direct joined/default-receiver checks, compilation/rustfmt, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public finding / owned repair: Rust public CLI returns null for direct String-selected Array continuation while joined/nested Array and joined Hash controls give A-B/X:Y with correct SDJ snapshots. eval_string_receiver_value_chain handles coalesce_nonempty then continues its original String-family loop. Route that selected result through existing dynamic continuation with actual scalar/container boundary; retain correct joined/default helpers. Shared authored fixture adds a direct Hash counterpart.

  Completion: After direct String coalesce_nonempty selection, return through eval_selected_receiver_value_chain with scalar guarding derived from the actual selected kind. Preserve existing joined/default helper behavior and source snapshots.
  Verification:
  - [x] REPRODUCE / ISSUE: Public CLI shows direct String-selected Array null beside working joined/nested controls. New shared authored fixture RED independently shows direct Array/Hash null with all other values unchanged.
  - [x] ROOT CAUSE (WHY + WHERE): eval_string_receiver_value_chain's coalesce_nonempty special branch continues its local String family after selection rather than handing off the selected result.
  - [x] FIX: Reuse existing dynamic continuation and set scalar guarding from actual Array/Hash versus scalar/null output; no helper, copy, lazy or serialized policy changes.
  - [x] ADDRESSED (verified): Small native/restored/generated-plan default fixture PASS after RED, including direct/joined Array/Hash, scalar incompatible nulls, empty/null/zero/false, skipped arms and SDJ snapshots.
  - [x] NO REGRESSION: Direct joined and default-receiver fixtures plus compilation/rustfmt PASS. Existing selected-null and source/helper differences remain unchanged; no broad suite/admission claim.
  - [x] LOCKSTEP: Shared fixture, contract/catalog, canonical defaults fact/map and live/task/resume docs align; book and fast memory/cadence/diagnosis/history/diff checks pass. Dart assessment3 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.6.2 - continue Rust selected default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.3`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Dart default-selection result flow.
  Dependencies: .23.3.6.2.
  Acceptance: Follow frozen default-selection-results.md with existing helper domains and actual-kind/lazy/effect/snapshot controls. Public native/generated distinguishing checks before repair; no inferred backend failure. Small compile/targeted checks/docs/commit; Lua declared5.4/full admission stays separate.
  Activation: clean `1a1e6ea6d37fa16ad174fd310332cc7373e35189`; Rust committed, brief empty, tree clean.
  Owned paths: Dart public fluent dispatcher only for confirmed gaps, focused native/restored/generated-plan default fixture, direct joined compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Public engine native/restored/generated-plan shared selected-default and direct retained-Scalar controls, existing default-receiver fixture plus direct joined test, selected-file fatal analysis/format, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Shared direct/joined Array/Hash flow, lazy SDJ snapshots and the existing receiver fixture already pass. Direct retained/fallback String followed by sorted/sorted_values yields [] instead of frozen null. _evaluateFluentCallsWithValue starts scalarResult only for List reducers/join; a direct coalesce_nonempty scalar selection never activates it. Treat nonempty selection as a possible scalar producer, then retain/clear the guard by its actual output kind.

  Completion: Retain already-correct actual container flow. Mark nonempty defaults as possible scalar results, then keep/clear the existing scalar guard from actual List/Map versus scalar/null output. Existing lazy/copy/helper policies stay unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared public native/restored/generated-plan values already pass; retained/fallback direct String sorted/sorted_values independently RED as [] instead of null.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluateFluentCallsWithValue only starts scalarResult for List reducers/join. Direct String nonempty selection does not activate the boundary, though _callCoalesceWithReceiver already selects lazily and copies actual values correctly.
  - [x] FIX: Include coalesce_nonempty in mayProduceScalar and retain/clear guarding after evaluation according to actual List/Map output. Preserve the existing dispatcher and producer semantics.
  - [x] ADDRESSED (verified): New native/restored/generated-plan regression PASS after boundary RED for direct scalar negatives; shared Array/Hash, empty/null/zero/false, skipped fallbacks and SDJ snapshots still pass.
  - [x] NO REGRESSION: Existing default receiver fixture and direct joined test PASS; selected-file fatal analysis/format and compilation PASS. Generic coalesce/deferred/domain policies and generated formats stay unchanged; no broad suite.
  - [x] LOCKSTEP: Register focused test via normal test discovery, align contract/catalog/default and Dart facts/map plus live/task/resume records; book and fast memory/cadence/diagnosis/history/diff checks pass. Julia assessment4 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.6.3 - guard Dart scalar default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.4`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Julia default-selection result flow.
  Dependencies: .23.3.6.3.
  Acceptance: Follow frozen default-selection-results.md with existing helper domains and actual-kind/lazy/effect/snapshot controls. Public native/generated distinguishing checks before repair; no inferred backend failure. Small compile/targeted checks/docs/commit; Lua declared5.4/full admission stays separate.
  Activation: clean `220c0a37d9a308eb07c7a0a6347f78c9a799ce44`; Dart committed, brief empty, tree clean.
  Owned paths: Julia public fluent dispatcher only for confirmed gaps, focused native/generated-plan/fresh-emitted default fixture and runner registration, direct joined compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Public native/generated-plan/fresh-emitted shared selected-default and direct Scalar controls, existing default-receiver fixture plus direct joined test under strict Julia flags, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Shared direct/joined container and existing default receiver controls pass on native/generated-plan/fresh-emitted routes. Direct retained/fallback String sorted/sorted_values returns empty Arrays instead of null on all three routes. _evaluate_runtime_fluent_chain! only activates scalar_result for AbstractVector reducers/join; include nonempty selection as a possible scalar producer, clearing the guard for actual AbstractVector/AbstractDict output.

  Completion: Preserve correct selected container flow and include nonempty defaults as possible scalar results. Retain/clear the existing guard using actual AbstractVector/AbstractDict output; keep lazy/copy/helper policies unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared/default-receiver controls already pass; direct retained/fallback String sorted/sorted_values returns empty Arrays instead of null on native/generated-plan/fresh-emitted routes.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! only activates scalar_result for AbstractVector reducers/join. Direct String default selection never activates it; _evaluate_runtime_fluent_value_call! already selects lazily and copies actual values.
  - [x] FIX: Include coalesce_nonempty in may_produce_scalar, then keep/clear guarding from actual container output. Preserve shared dispatch and default semantics.
  - [x] ADDRESSED (verified): Focused native/generated-plan/fresh-emitted default regression PASS after boundary RED, including direct scalar nulls, actual Array/Hash, empty/null/zero/false, skipped fallbacks and SDJ snapshots.
  - [x] NO REGRESSION: Existing default receiver fixture and direct joined test PASS under startup/history disabled and depwarn=error; package compilation succeeds. Generic coalesce/deferred/domain policies and generated formats stay unchanged; no broad suite.
  - [x] LOCKSTEP: Register fixture, align contract/catalog/default and Julia facts/map plus live/task/resume records; book and fast memory/cadence/diagnosis/history/diff checks pass. Lua assessment5 next after clean commit, declared5.4/full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.6.4 - guard Julia scalar default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.5`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Lua default-selection result flow.
  Dependencies: .23.3.6.4.
  Acceptance: Follow frozen default-selection-results.md with existing helper domains and actual-kind/lazy/effect/snapshot controls. Public native/generated distinguishing checks before repair; no inferred backend failure. Small compile/targeted checks/docs/commit; Lua declared5.4/full admission stays separate.
  Activation: clean `e8bd3f389fe1ceb79c43d9fd702fa19a68865dfa`; Julia committed, brief empty, tree clean.
  Owned paths: Shared Lua fluent dispatcher only for confirmed gaps, focused native/generated-plan/fresh-emitted fixture and runner registration, direct joined compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Public native/generated-plan/fresh-emitted shared selected-default and direct Scalar controls, existing default-receiver fixture plus direct joined test on available PUC5.5.1/LuaJIT with matching products, loadfile, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; declared5.4/full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Shared actual Array/Hash selections pass on native/generated-plan/fresh-emitted routes on both available hosts. Direct retained/fallback String sorted/sorted_values returns [] instead of null on native controls. evaluate_fluent_calls handles lazy coalesce without activating scalar_result; set the existing guard for nonempty selection and let the existing actual array/harray result check release it.

  Completion: Preserve correct actual container flow and activate scalar_result after nonempty selection; the existing array/harray result-kind check releases it for actual containers. Keep lazy/copy/helper semantics unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared Array/Hash selections already pass; direct retained/fallback String sorted/sorted_values independently RED as [] instead of null on both available hosts.
  - [x] ROOT CAUSE (WHY + WHERE): typed_source.receiver_mutation.evaluate_fluent_calls handles coalesce selection without activating scalar_result. Its existing result-kind check can already release that guard for actual array/harray output.
  - [x] FIX: Activate the existing guard for coalesce_nonempty and preserve the shared actual-kind release. Generic coalesce/deferred/helper policies remain unchanged.
  - [x] ADDRESSED (verified): Focused native/generated-plan/fresh-emitted default fixture PASS after boundary RED on available PUC5.5.1/LuaJIT, including direct scalar nulls, actual Array/Hash, empty/null/zero/false, lazy skipped arms and SDJ snapshots.
  - [x] NO REGRESSION: Existing default receiver fixture, direct joined fixture and interpreter/runner loadfile checks PASS on both hosts with matching native products. No broad suite, source normalization, declared5.4 or full admission claim.
  - [x] LOCKSTEP: Register fixture, align contract/catalog/default and Lua facts/map plus live/task/resume records; book and fast memory/cadence/diagnosis/history/diff checks pass. Bounded default rollout targeted-checked; index_of result assessment23.2.6 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.6.5 - guard Lua scalar default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.7`
  Status: `active` / bounded index rollout targeted-checked on recorded hosts; full admission open
  Goal: Implement/confirm ordinary index_of integer/null result continuations across maintained backends.
  Dependencies: .23.2.6.
  Children: `.23.3.7.1`, `.23.3.7.2`, `.23.3.7.3`, `.23.3.7.4`, `.23.3.7.5`.
  Acceptance: Frozen index-results.md targets preserve index/domain/equality/kind, one-needle preflight, once-only source/needle/consumer order, snapshots and scalar boundaries. Assess each backend independently; full admission remains23.4.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.7.1`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Perl index_of result continuation.
  Dependencies: .23.2.6.
  Acceptance: Follow index-results.md through current public/native/generated carriers. Preserve correct producer/equality/source/null/copy policies, exact-one-needle preflight before effects, zero/nonmatch, actual scalar kinds, snapshots and incompatible container nulls. Source/code children only for confirmed bounded gaps; compile/small checks/docs/commit. Lua declared5.4/full admission stays separate.
  Activation: clean `434fe1abcd703ff1041991b62d43aa470cedc895`; index contract committed, brief empty, tree clean.
  Owned paths: Perl ordinary array result-family/arity lowering, focused native/fresh index fixture, direct selected-default compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Native/fresh index continuation fixture after RED, direct selected-default regression, MethodLowering/test syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable/deferred admission23.4 and final clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.

  Completion: Classify index_of as scalar_result in the existing Array return-family callback and preflight exactly one needle before source/operand effects. Reuse shared scalar/default/String/Array continuation; leave the correct producer/equality/source/copy implementation unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public frozen direct/nested distinctions and retained target fixture RED show stopped numeric/String consumers and Hash-view fallback. Existing incompatible-container and producer snapshot controls remain valid.
  - [x] ROOT CAUSE (WHY + WHERE): array_chain_return_family defaults index_of to terminal, preventing later compatible consumers. Common arity preflight lacks its one-needle check.
  - [x] FIX: Return scalar_result for index_of and reject missing/extra needles before effects. Existing selected/scalar/default bridges handle the returned integer/null.
  - [x] ADDRESSED (verified): t/index_result_receiver_contract.t PASS native/fresh after RED for direct/selected/pipeline/hash/String/function/default sources, zero/no-match/empty/null, numeric selector writes, String bridges/defaults, scalar negatives and malformed-shape no-effects.
  - [x] NO REGRESSION: Direct selected-default fixture, MethodLowering/test compilation and original N/SN producer/SNA consumer snapshot controls PASS. No producer, equality/domain, deferred vocabulary or generated-format change; no broad suite.
  - [x] LOCKSTEP: Worked catalog/guide examples and former terminal summaries align with bounded Perl support; contract, array fact/map and live/task/resume records align. Book and fast memory/cadence/diagnosis/history/diff checks pass. Fresh-current Rust assessment2 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.7.1 - continue Perl index results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.7.2`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Rust index_of result continuation.
  Dependencies: .23.3.7.1.
  Acceptance: Follow index-results.md through current public/native/generated carriers. Preserve correct producer/equality/source/null/copy policies, exact-one-needle preflight before effects, zero/nonmatch, actual scalar kinds, snapshots and incompatible container nulls. Source/code children only for confirmed bounded gaps; compile/small checks/docs/commit. Lua declared5.4/full admission stays separate.
  Activation: clean `58833111dd2fc8c62f00afc4733c1d1422f14bac`; Perl committed, brief empty, tree clean.
  Owned paths: Rust public receiver result/arity dispatch only for confirmed gaps, focused native/restored/generated-plan index fixture, direct default compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Fresh-current public CLI fluent/nested/shape controls; small native/restored/generated-plan index regression after RED and direct selected-default test, compilation/rustfmt, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Fresh-current CLI gives fluent direct/hash/default/zero null beside nested2; valid effect control stops after SN with source[a,b,c], and malformed missing/extra needles run four effects. is_selected_receiver_result_method/is_scalar_result_receiver_method omit index_of; Expr::FluentChain preflight guards one join delimiter but not one index needle. Extend those existing owners, preserving the index producer/equality/copy behavior.

  Completion: Include index_of in is_scalar_result_receiver_method, which also admits the existing selected-value handoff, and add it to exact-one-operand fluent preflight. Keep the index helper/equality/source/copy implementation unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Fresh-current CLI returns fluent null beside nested2, runs SN without the consumer and runs four malformed-shape effects. Retained shared fixture RED reaches a selector write with the derived null instead of numeric0; the selector validator correctly rejects it.
  - [x] ROOT CAUSE (WHY + WHERE): is_scalar_result_receiver_method/is_selected_receiver_result_method omit index_of, so the Array loop stops after that producer. Expr::FluentChain lacks its one-needle preflight.
  - [x] FIX: Extend existing scalar handoff and common one-operand preflight; preserve the correct producer and existing domain/equality/copy behavior.
  - [x] ADDRESSED (verified): Small native/restored/generated-plan index fixture PASS after RED, including direct/selected/pipeline/hash/String/default/function sources, numeric0 selector writes, zero/null, scalar boundaries, explicit bridges, malformed-shape no-effects and N/SN/SNA snapshots.
  - [x] NO REGRESSION: Direct selected-default test plus compilation/rustfmt PASS. No source normalization, helper/deferred vocabulary, serialized format or broad admission change; no full suite.
  - [x] LOCKSTEP: Shared fixture, worked catalog/guide and terminal summaries, contract, array fact/map and live/task/resume records align; book and fast memory/cadence/diagnosis/history/diff checks pass. Dart assessment3 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.7.2 - continue Rust index results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.7.3`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Dart index_of result continuation.
  Dependencies: .23.3.7.2.
  Acceptance: Follow index-results.md through current public/native/generated carriers. Preserve correct producer/equality/source/null/copy policies, exact-one-needle preflight before effects, zero/nonmatch, actual scalar kinds, snapshots and incompatible container nulls. Source/code children only for confirmed bounded gaps; compile/small checks/docs/commit. Lua declared5.4/full admission stays separate.
  Activation: clean `3f00457cac9a96b9a9b1bcc7f914f174db21d29c`; Rust committed, brief empty, tree clean.
  Owned paths: Dart public fluent scalar/arity dispatch only for confirmed gaps, focused native/restored/generated-plan index fixture, direct default compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Public native/restored/generated-plan shared index fixture before/after repair and direct selected-default test; selected-file fatal analysis/format, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation/confirmation under director feature-first cadence; full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Native shared values already carry numeric results and N/SN/SNA snapshots, but scalar consumers sorted/after-cat return [], extra shape returns2 and malformed shapes run four effects. A separate null-source index followed by sorted also returns []. Common fluent preflight only checks one join delimiter; mayProduceScalar omits index_of. Guard index results independently of source kind (the documented result is integer/null), and add one-needle preflight.

  Completion: Preserve correct native numeric flow; include index_of in mayProduceScalar independently of source kind, and require one needle in common fluent preflight. Integer/null results retain scalar guarding until a compatible container output.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared native values expose [] scalar negatives, extra-shape result2 and four effects. A separate null-source index then sorted independently REDs as [] instead of null; retained native JSON reasons show the actual untruncated values.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluateFluentCallsWithValue omits index_of from mayProduceScalar; common ActionFluentChainExpr preflight checks one join delimiter but not one index needle. Correct integer/null flow and producer snapshots already work natively.
  - [x] FIX: Guard index results regardless of source kind and reject missing/extra needles before effects. Preserve existing helper/equality/source/copy behavior and dynamic bridges.
  - [x] ADDRESSED (verified): Small native/restored/generated-plan index regression PASS after RED, including integer/null scalar negatives, shape no-effects, zero selector use, direct/selected/pipeline/hash/String/function/default sources and N/SN/SNA snapshots.
  - [x] NO REGRESSION: Direct selected-default regression plus selected-file fatal analysis/format and compilation PASS. No producer, equality/domain, generic/deferred or generated-format changes; no broad suite.
  - [x] LOCKSTEP: Worked catalog/guide, contract, Dart/array facts/map and live/task/resume records align; book and fast memory/cadence/diagnosis/history/diff checks pass. Julia assessment4 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.7.3 - guard Dart index result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.7.4`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Julia index_of result continuation.
  Dependencies: .23.3.7.3.
  Acceptance: Follow index-results.md through current public/native/generated carriers. Preserve correct producer/equality/source/null/copy policies, exact-one-needle preflight before effects, zero/nonmatch, actual scalar kinds, snapshots and incompatible container nulls. Source/code children only for confirmed bounded gaps; compile/small checks/docs/commit. Lua declared5.4/full admission stays separate.
  Activation: clean `15ab79ad75834eab7350c090e8fe90d6e3308c0c`; Dart committed, brief empty, tree clean.
  Owned paths: Julia public fluent scalar/arity dispatch only for confirmed gaps, focused native/generated-plan/fresh-emitted index fixture and runner registration, direct default compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Public shared index and null-source scalar controls on native/generated-plan/fresh-emitted routes before/after repair, direct selected-default fixture under strict flags, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation/confirmation under director feature-first cadence; full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Three-carrier RED shows numeric0 selector use, extra2 and four malformed effects; separate null-source index then sorted returns [] on all routes. _evaluate_runtime_fluent_chain! lacks one-needle preflight and index_of in may_produce_scalar. Guard its guaranteed integer/null output independently of source kind and extend the existing shape check; preserve helper/equality/source/copy behavior.

  Completion: Preserve correct numeric flow; include index_of in source-independent may_produce_scalar and one-operand fluent preflight. Integer/null results keep scalar guarding until an actual container output.
  Evidence retention: Preserve the exact earlier Rust CLI input as docs/checkpoints/type-operation-inventory/rust-index-probe.spec, byte-compared to the executed local input; its historical pre-repair source base is58833111dd2fc8c62f00afc4733c1d1422f14bac. This is retention of existing family evidence, not a new Rust run/admission.
  Verification:
  - [x] REPRODUCE / ISSUE: Native/generated-plan/fresh-emitted shared RED shows extra2/four effects; separate null-source index then sorted returns [] instead of null on every route. Current numeric0 selector and producer snapshot controls remain distinct from those gaps.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! omits index_of from one-needle preflight and may_produce_scalar, so nullable/scalar consumers lack the existing boundary.
  - [x] FIX: Include index_of in both shared checks independently of receiver kind. Preserve helper/equality/source/copy and dynamic bridge behavior.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted index regression PASS after RED, including integer/null scalar boundaries, zero/null, numeric selector writes, direct/selected/pipeline/hash/String/function/default sources, shape no-effects and N/SN/SNA snapshots.
  - [x] NO REGRESSION: Direct selected-default fixture and package compilation PASS under startup/history disabled and depwarn=error. No producer/deferred/generic/equality/domain or generated-format changes; no broad suite.
  - [x] LOCKSTEP: Register fixture; preserve exact CLI input and align worked catalog/guide, contract, Julia/array facts/map and live/task/resume records. Book and fast memory/cadence/diagnosis/history/diff checks pass. Lua assessment5 next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.7.4 - guard Julia index result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.7.5`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Lua index_of result continuation.
  Dependencies: .23.3.7.4.
  Acceptance: Follow index-results.md through current public/native/generated carriers. Preserve correct producer/equality/source/null/copy policies, exact-one-needle preflight before effects, zero/nonmatch, actual scalar kinds, snapshots and incompatible container nulls. Source/code children only for confirmed bounded gaps; compile/small checks/docs/commit. Lua declared5.4/full admission stays separate.
  Activation: clean `5e105be6536b53cfe99a9d726cd3b8a972a51158`; Julia committed, brief empty, tree clean.
  Owned paths: Shared Lua fluent scalar/arity dispatch only for confirmed gaps, focused native/generated-plan/fresh-emitted index fixture and runner registration, direct default compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Public shared index/null-source scalar controls before/after repair and direct selected-default fixture on native/generated-plan/fresh-emitted routes on available PUC5.5.1/LuaJIT with matching products, loadfile, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation/confirmation under director feature-first cadence; declared5.4/full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Both available native hosts already produce correct numeric0 selector writes and N/SN/SNA snapshots, but integer scalar negatives are [], extra-shape result2 and four effects. evaluate_fluent_calls only marks join_values after Array helpers; fluent preflight only checks one join delimiter. Include index_of in those existing checks, preserving helper/equality/source/copy policies and covering its integer/null output independently of source kind.

  Completion: Include index_of in common one-operand preflight and activate scalar_result after its Array-helper evaluation, independently of source kind. The existing actual array/harray output check releases the guard for explicit bridges.
  Verification:
  - [x] REPRODUCE / ISSUE: Both available native hosts show correct numeric flow but [] integer scalar negatives, extra2 and four malformed effects; the full native JSON is retained in the failing fixture output.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls only marks join_values after Array helpers, and evaluate_expr's fluent preflight only checks one join delimiter. index_of is absent from both owners.
  - [x] FIX: Add index_of to those existing checks. Preserve helper/equality/source/copy and dynamic bridge behavior.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted index fixture PASS after RED on available PUC5.5.1/LuaJIT, including integer/null boundaries, zero/null, numeric0 selector writes, source families, shape no-effects and N/SN/SNA snapshots.
  - [x] NO REGRESSION: Direct selected-default fixture and interpreter/runner loadfile checks PASS on both hosts with matching native products. No producer/generic/deferred/domain or generated-format change; declared5.4/full admission stays separate.
  - [x] LOCKSTEP: Register fixture; align worked catalog/guide, contract, Lua/array facts/map and live/task/resume records. Book and fast memory/cadence/diagnosis/history/diff checks pass. Bounded index rollout targeted-checked; has_key result assessment23.2.7 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.7.5 - guard Lua index result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8`
  Status: `active` / bounded implementation planned; full admission open
  Goal: Implement frozen has_key result/key targets in has-key-results.md without changing producer kinds/domains.
  Children: `.23.3.8.1`, `.23.3.8.2`, `.23.3.8.3`, `.23.3.8.4`, `.23.3.8.5`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.1`
  Status: `active` / bounded Perl producer/result repairs targeted-checked; full admission open
  Goal: Repair confirmed Perl key-block producer compilation, then compatible result continuation.
  Children: `.23.3.8.1.1`, `.23.3.8.1.2`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.1.1`
  Status: `completed`
  Goal: Repair valid String key blocks failing has_key native/fresh compilation; priority P1.
  Dependencies: .23.2.7.
  Reproduction / impact: meta.has_key({order=cat(order,"K");"a"}) leaves raw DSL inside exists ->{{...}}, failing compilation even without chaining. Literal/variable/helper String keys already work.
  Acceptance: Complete key lowering in its current context without disturbing generic callback contracts; establish once-only/source-before-key snapshots, false/null-valued presence and literal/variable/helper compatibility on native/fresh routes. Compile/small checks/docs/commit before result flow.

  Activation: clean `34167dfba3fbddec13ad4da8013d6cdd484117c6`; assessment committed, brief empty, tree clean.
  Owned paths: Perl has_key current-context key lowering; focused native/fresh producer fixture and current contract/book/hash fact/live records.
  Verification tier: `focused`
  Focused checks: Native/fresh key-block producer RED/GREEN, literal/variable/helper presence and source/key snapshot/order controls; direct index compatibility, Perl syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded producer repair under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored value/order regression, no quantified population or portable measurement.

  Completion: Complete key expressions with _lower_method_value_expr before existing scalar-key fallback; no generic/private callback contract change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Get/fresh key-block regression RED3/4 with raw DSL syntax errors near {{, while prior literal/variable/helper controls work.
  - [x] ROOT CAUSE (WHY + WHERE): call_spec_handler_subst retains authored key blocks inside exists; MethodLowering has_key delegates only to scalar access key lowering.
  - [x] FIX: Finish key lowering in current MethodLowering context, then retain original fallback. No producer kind/domain/copy policy change.
  - [x] ADDRESSED (verified): Native/fresh fixture passes key once-only, literal/variable/helper presence, false/null stored values and named/computed/free snapshots with K/SK order. Later-added key stays absent from captured source.
  - [x] NO REGRESSION: Direct native/fresh index fixture and Perl source/test syntax pass; no broad suite or result-flow change.
  - [x] LOCKSTEP: Current contract/book/key fact/map and task/live/resume records updated; fast memory/cadence/diagnosis/history/diff and book pass. Result handoff1.2 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.8.1.1 - lower has_key key blocks in context`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.1.2`
  Status: `completed`
  Goal: Continue Perl has_key truth-valued results through existing compatible scalar/text methods.
  Dependencies: .23.3.8.1.1.
  Acceptance: Frozen has-key-results.md, actual kind retained, one-key preflight before effects, direct/selected/pipeline/default/function sources, explicit bridges/scalar boundaries and source/key/consumer snapshots; native/fresh/direct compatibility and docs/commit. No Boolean normalization/new vocabulary.

  Activation: clean `1cc204148d3053d07857c08ebc89c7873455b87e`; producer committed, brief empty, tree clean.
  Owned paths: Shared ordinary has_key scalar-result classification/one-key preflight, focused native/fresh receiver fixture, contract/book/hash fact and live records.
  Verification tier: `focused`
  Focused checks: Native/fresh has_key result RED/GREEN, scalar/bridge/false retention, source/key/consumer snapshots and malformed no-effects; direct key producer compatibility, Perl syntax/book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen result implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored values/order, no quantified population or portable measurement.
  Additional owned flow defect: make_meta().has_key("a").cat("!") alone remains null after classifier repair while make_meta(), free has_key and single-step receiver return Hash/1/1. Public generated-source dump shows unsupported has_key inside cat. The generic aggregate bridge reparses an already lowered function Hash operand as DSL; complete typed has_key operands before host presence emission within this leaf.

  Completion: scalar_result plus exact-one-key preflight; typed has_key aggregate operands, typed nested has_key arguments and preserved authored root calls prevent function Hash host output from being reparsed as DSL.
  Verification:
  - [x] REPRODUCE / ISSUE: Native/fresh shared fixture RED with raw host DSL compilation errors. First scalar/shape change leaves only function result null on both routes; public Get returns Hash/1/1/null for function/free/single-step/chained forms.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering hash return-family marks has_key terminal; fluent shape lacks one-key guard. Generated source additionally shows unsupported has_key inside cat after ast_expr_source_node prematurely lowers a function Hash into compatibility DSL.
  - [x] FIX: Reuse scalar_result, preflight exact one key and finish typed has_key operands/nested arguments while retaining authored root calls until that lowering. No producer Boolean/numeric normalization or new methods.
  - [x] ADDRESSED (verified): Native/fresh shared fixture passes direct/selected/pipeline/literal/function/default and String keys, false retention, scalar boundaries/explicit bridge, zero malformed effects and K/SK/SKA snapshots after RED.
  - [x] NO REGRESSION: Direct native/fresh key producer fixture and source/test syntax pass;12 checks across two fixtures. No broad suite/domain/deferred/copy/generated-format change.
  - [x] LOCKSTEP: Contract/worked catalog/guide, hash fact/map and task/live/resume updated. Book and fast memory/cadence/diagnosis/history/diff pass. Rust2 assessment next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.8.1.2 - continue has_key scalar results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust has_key result/key/shape targets.
  Dependencies: .23.3.8.1.2.
  Acceptance: Public native/generated assessment before classification; repair only confirmed gaps under has-key-results.md, preserving actual producer kinds/domains/source/copy. One-key preflight, presence/false retention, scalar boundaries/bridges and ordered snapshots; compile/small checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 separate.

  Activation: clean `ce4372bdef73e4db1b61a0a16c0d2ab54cdca2bb`; Perl committed, brief empty, tree clean.
  Owned paths: Confirmed Rust has_key fluent scalar/arity gaps only; shared native/restored/generated-plan fixture, direct index compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public Engine native/restored/generated-plan has_key fixture before/after repair, direct index fixture, targeted offline Cargo compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored value/order regression, no quantified corpus or portable measurement.

  Completion: Include has_key in existing scalar-result classification and exact-one-operand fluent preflight; existing Number1/0 presence helper untouched.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Engine native fixture RED shows fluent null, nested1!, SK-only order and four malformed effects; producer keys still run.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs hash dynamic dispatcher stops terminal has_key unless selected-result; scalar-result classifier and one-operand preflight omit it.
  - [x] FIX: Add has_key to existing scalar-result classifier and preflight; no helper/domain/source/copy normalization.
  - [x] ADDRESSED (verified): Native/restored/generated-plan result fixture passes presence/false retention, literal/variable/helper/block String keys, selected/pipeline/literal/function/default sources, explicit bridge/scalar nulls, zero malformed effects and K/SK/SKA snapshots.
  - [x] NO REGRESSION: Direct native/restored/generated-plan index fixture and targeted offline Cargo compilation pass. No broad suite, new methods or serialized-format change.
  - [x] LOCKSTEP: Contract/worked catalog/guide, hash fact/map and task/live/resume updated; book and fast memory/cadence/diagnosis/history/diff pass. Dart3 assessment next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.8.2 - continue Rust has_key scalar results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart has_key result/key/shape targets.
  Dependencies: .23.3.8.2.
  Acceptance: Public native/generated assessment before classification; repair only confirmed gaps under has-key-results.md, preserving actual producer kinds/domains/source/copy. One-key preflight, presence/false retention, scalar boundaries/bridges and ordered snapshots; compile/small checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 separate.

  Activation: clean `5ffc8c82350d6ef738b19cd0ef6cf87127879e91`; Rust committed, brief empty, tree clean.
  Owned paths: Confirmed Dart has_key fluent result/shape gaps only; native/restored/generated-plan shared fixture, direct index compatibility, selected-file analysis and current docs.
  Verification tier: `focused`
  Focused checks: Public native/restored/generated-plan has_key fixture before/after confirmed repair, direct index fixture, fatal selected-file analysis, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored value/order regression, no quantified corpus or portable measurement.

  Completion: Include has_key in existing exact-one-operand preflight and mayProduceScalar independently of source kind; actual List/Map output still releases the guard.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native shared fixture RED retains correct result/order/snapshots but incompatible/after-text consumers return[], missing0!, extra1! and four malformed effects; full native JSON retained in test reason.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart _evaluateFluentCallsWithValue omits has_key from scalar producers, and ActionFluentChainExpr preflight omits its one-key shape.
  - [x] FIX: Add has_key to those existing checks independently of source kind; actual container output enables explicit bridges. Presence helper Number0/1 remains unchanged.
  - [x] ADDRESSED (verified): Native/restored/generated-plan shared fixture passes presence/false retention, String keys, source families, scalar nulls/explicit bridge, zero malformed effects and K/SK/SKA snapshots after RED.
  - [x] NO REGRESSION: Direct index native/restored/generated-plan checks and fatal selected-file analysis pass;3 tests total. No broad suite, helper/domain/source/copy or format change.
  - [x] LOCKSTEP: Contract/worked catalog/guide, Dart/hash facts/map and task/live/resume updated; book and fast memory/cadence/diagnosis/history/diff pass. Julia4 assessment next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.8.3 - guard Dart has_key result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia has_key result/key/shape targets.
  Dependencies: .23.3.8.3.
  Acceptance: Public native/generated assessment before classification; repair only confirmed gaps under has-key-results.md, preserving actual producer kinds/domains/source/copy. One-key preflight, presence/false retention, scalar boundaries/bridges and ordered snapshots; compile/small checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 separate.

  Activation: clean `99167513535ddb39eff8932e481f4744d8b0a076`; Dart committed, brief empty, tree clean.
  Owned paths: Confirmed Julia has_key ordinary scalar/shape gaps only; native/generated-plan/fresh-emitted shared fixture, direct index compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Strict Julia native/generated-plan/fresh-emitted has_key fixture before/after repair, direct index fixture, package compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored values/order, no quantified corpus or portable measurement.

  Completion: Include has_key in existing exact-one-operand fluent preflight and source-independent may_produce_scalar; actual AbstractVector/AbstractDict output releases the guard.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native shared fixture JSON retains correct flow/order/snapshots but incompatible/after-text [], missing0!, extra1! and four effects; native/plan/fresh expectations all RED.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _evaluate_runtime_fluent_chain! omits has_key from scalar producers and exact-one-operand preflight.
  - [x] FIX: Add has_key to those existing checks independently of source kind; explicit container outputs release the guard. Integer0/1 presence helper remains unchanged.
  - [x] ADDRESSED (verified): Strict native/generated-plan/fresh-emitted shared fixture passes presence/false retention, String keys, source families, scalar nulls/explicit bridge, zero malformed effects and K/SK/SKA snapshots after RED.
  - [x] NO REGRESSION: Direct three-route index fixture and package compilation pass under startup/history disabled and depwarn=error;9 assertions total. No broad suite/helper/domain/source/copy/format change.
  - [x] LOCKSTEP: Register fixture; contract/worked catalog/guide, Julia/hash facts/map and task/live/resume updated; book and fast memory/cadence/diagnosis/history/diff pass. Lua5 assessment next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.8.4 - guard Julia has_key result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua has_key result/key/shape targets.
  Dependencies: .23.3.8.4.
  Acceptance: Public native/generated assessment before classification; repair only confirmed gaps under has-key-results.md, preserving actual producer kinds/domains/source/copy. One-key preflight, presence/false retention, scalar boundaries/bridges and ordered snapshots; compile/small checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 separate.

  Activation: clean `07d65e85378ed248a0a324e307e0eee4eaafbb05`; Julia committed, brief empty, tree clean.
  Owned paths: Confirmed Lua ordinary has_key scalar/shape gaps only; native/generated-plan/fresh-emitted shared fixture and runner registration, direct index compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public native/generated-plan/fresh-emitted has_key before/after repair on available PUC5.5.1/LuaJIT with matching products, direct index fixture, interpreter/runner loadfile, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; declared5.4/full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified corpus or portable measurement.

  Completion: Replace has_key terminal continuation fence with scalar_result tracking; add has_key to existing exact-one-operand fluent preflight. Actual container results still release the scalar guard.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native shared fixture RED on both available hosts shows fluent null versus nested1!, SK-only order and four malformed effects; full expected/actual JSON retained.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua evaluate_fluent_calls explicitly returns null after nonfinal has_key, and evaluate_expr fluent preflight omits its one-key shape.
  - [x] FIX: Replace that fence with scalar_result=true and include has_key in one-key preflight; presence numeric0/1/helper/domain/source/copy unchanged.
  - [x] ADDRESSED (verified): Both installed hosts pass native/generated-plan/fresh-emitted shared fixture after RED, preserving presence/false retention, String keys/source families, explicit bridge/scalar nulls, zero malformed effects and K/SK/SKA snapshots.
  - [x] NO REGRESSION: Direct three-route index fixture and interpreter/runner loadfile pass on available PUC5.5.1/LuaJIT with matching products. No broad suite/new methods/generated-format change; declared5.4/full admission separate.
  - [x] LOCKSTEP: Register fixture; contract/worked catalog/guide, Lua/hash facts/map and task/live/resume updated; book and fast memory/cadence/diagnosis/history/diff pass. Bounded has_key rollout targeted-checked; predicate assessment23.2.8 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.8.5 - continue Lua has_key scalar results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9`
  Status: `active` / bounded emptiness implementation planned
  Goal: Canonical actual-value emptiness and compatible predicate-result continuation under emptiness-results.md.
  Children: `.23.3.9.1`, `.23.3.9.2`, `.23.3.9.3`, `.23.3.9.4`, `.23.3.9.5`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.1`
  Status: `active` / bounded Perl producer before flow
  Children: `.23.3.9.1.1`, `.23.3.9.1.2`.
  Existing owner: SESSION-STARTUP-READING16.1/.16.2 retain broader conditions/global literal-slot acceptance; these children own only the ordinary value/result dependency and must record the exact overlap.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.1.1`
  Status: `completed`
  Goal: Repair P1 bounded ordinary Perl emptiness value-producer expression/kind defects before chaining.
  Dependencies: .23.2.8.
  Reproduction / impact: Public nested cat(is_empty({order=cat(order,"S");parts}),consumer) gives0!/SA for parts=[]; literal String0 differs from its bound twin. Empty Array/Hash expression results and source spellings must obey canonical value-based emptiness.
  Acceptance: Typed literal/binding/block/nested/function ordinary producers, empty/nonempty Array/Hash/String, undef and String0, inverse helpers/once-only/source snapshots; native/fresh/direct compatibility plus syntax/book/fast checks/commit. Update existing SESSION16 fact/owner overlap without claiming full conditional/global-selector repair.

  Activation: clean `e73cfce42d13f3e08a0285de494cc9f6472d8d19`; assessment committed, brief empty, tree clean.
  Owned paths: MethodLowering typed ordinary is_empty/is_nonempty producer operands and value-based predicate emission, native/fresh focused fixture, current contract/book/emptiness fact/live records. SESSION16 condition/global scalar-name audit remains separate.
  Verification tier: `focused`
  Focused checks: Public native/fresh literal/binding/block/nested/function producer RED/GREEN, inverse/presence/once-only/SA and host-program-name controls; direct has_key producer fixture, Perl syntax/book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded ordinary value-producer repair under director feature-first cadence; broader SESSION16 conditions/consumer audit, full23.4 admission and final clean push separate.
  Claim verification: none: deterministic authored values/order/host-state regression, no quantified corpus or portable measurement.
  Wrapper note: Previous probe syntax completed exit0 despite known child setpgid EPERM warning; SESSION-STARTUP-READING7 retains that infrastructure defect. No recovery/deletion or wrapper repair is part of this feature.

  Completion: Register existing emptiness helpers on typed ordinary value-call arities and fully lower their single operand before actual-kind emptiness emission. No FlowExpr/global scalar-name callback change.
  Verification:
  - [x] REPRODUCE / ISSUE: Retained public native/fresh probe shows wrong empty-Array block0!/SA and literal/bound String0 mismatch. New full producer fixture additionally RED8/11 on raw empty_items host invocation.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering's legacy fallback uses host truthiness and source-name extraction; missing typed value-only emptiness registration also leaves function operands raw. Public Get error identifies undefined host empty_items.
  - [x] FIX: Complete typed single operands and emit once-only actual undef/String/Array/Hash emptiness tests, with inverse numeric flags. Preserve actual data values and keep conditional/global callback repair with SESSION16.
  - [x] ADDRESSED (verified): Native/fresh producer fixture passes literals/bindings/blocks/nested/functions, empty/nonempty containers/String, String0/numeric0/false, inverse helpers, two host-program-name states and1!/SA/one-call source snapshots after RED.
  - [x] NO REGRESSION: Direct native/fresh has_key key-producer fixture and source/test syntax pass;17 assertions across two fixtures. No broad suite/FlowExpr/global selector/source/copy/format change.
  - [x] LOCKSTEP: Contract/worked catalog, existing emptiness fact/map, SESSION16 overlap and task/live/resume updated; refresh mutable SESSION index. Book and fast memory/cadence/diagnosis/history/diff pass. Result flow1.2 next after clean commit; broader16/full admission remain open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.9.1.1 - evaluate typed emptiness values`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.1.2`
  Status: `completed`
  Goal: Continue Perl is_empty/is_nonempty results through existing compatible scalar/text methods.
  Dependencies: .23.3.9.1.1.
  Acceptance: Frozen emptiness-results.md, actual result kinds, zero-operand shape before effects, named/literal/selected/pipeline/default/function sources, false retention, scalar nulls/explicit bridge and source/consumer snapshots. Native/fresh/direct small checks/docs/commit; no new logic or contains calibration change.

  Activation: clean `e003bd9e7d30e0f41643c2dab4e625841b9e6e08`; producer committed, brief empty, tree clean.
  Owned paths: Confirmed ordinary Perl emptiness receiver/result classification and zero-operand preflight, actual generic source handling, native/fresh shared fixture and current docs.
  Verification tier: `focused`
  Focused checks: Native/fresh shared receiver/result RED/GREEN across actual source kinds, false retention/scalar/bridge, zero-extra no-effects and SA snapshots; direct typed producer fixture, source/test syntax/book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary result implementation under director feature-first cadence; broader SESSION16/full23.4 admission and final clean push separate.
  Claim verification: none: deterministic authored value/order regression, no quantified population or portable measurement.
  Additional owned receiver findings: Classifier/shape-only candidate fixes basic flow but native/fresh expose wrong block/function0!, nonempty named Hash treated empty, String0/numeric0 treated empty, and repeated generic predicate null. Legacy compatibility producer still uses host truthiness; initial Array wrapper coerces broad emptiness sources and selected/default guards classify the generic predicates as container-only. Share actual-kind producer emission, retain broad source values, and admit these existing generic helpers through scalar/default/Hash continuations in this leaf.
  Candidate regression caught/owned: Registering generic predicates for Hash continuations makes copy's next-method hint infer Hash for a scalar binding carrying a nonempty Array; native/fresh copied_binding becomes1! rather than0!. Generic emptiness must not infer a container kind. Exclude it from copy's Hash hint and preserve the evaluated source through copy/predicate routing; retain this distinguishing bound-function Array case in the shared fixture.

  Completion: Scalar-result/zero-operand preflight, shared _lower_emptiness_value_test for typed/legacy ordinary producers, generic source preservation and scalar/default/Hash continuation. Copy lookahead excludes generic predicates; its source remains uncoerced before emptiness. FlowExpr/global scalar recognition unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Native/fresh shared result fixture RED shows stopped chains. Classifier-only candidate exposes wrong block/function0!, named Hash empty1!, String0/numeric0 nonempty0! and repeated predicate null. Bound function Array copy then predicate additionally RED1! versus0! after Hash registration.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering terminal family, legacy host-truthiness fallback, initial Array wrapper, generic methods treated as container-only in selected/default guards, function calls entering compatibility-only lowering and copy next-method Hash inference. Public Get/substitution errors and retained fixture JSON distinguish each candidate failure.
  - [x] FIX: Share actual-kind predicate emission; preserve generic receiver/typed-root values, admit existing generic predicates through scalar/default/Hash continuations and zero-operand preflight. Exclude predicates from Hash type inference; no copy helper/domain normalization.
  - [x] ADDRESSED (verified): Native/fresh shared result fixture passes Array/Hash/String/null/zero/selected/pipeline/function/default sources, repeated generic predicates, false retention, explicit bridge/scalar nulls, zero malformed effects and1!/SA/once-only source snapshots. Both function-bound Array and Hash copy cases pass after distinguishing Array RED.
  - [x] NO REGRESSION: Direct native/fresh typed producer fixture passes after shared-emitter refactor; final receiver fixture rechecked after copy/source corrections. Source/test syntax pass. No broad suite, FlowExpr/global scalar-name, helper-copy or serialized-format change.
  - [x] LOCKSTEP: Contract/worked catalog/guide, existing emptiness fact/map, SESSION16 overlap and task/live/resume align; refresh mutable SESSION index. Book and fast memory/cadence/diagnosis/history/diff pass. Rust2 assessment next after clean commit; broader16/full admission remain open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.9.1.2 - continue actual-value emptiness results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary emptiness result targets.
  Dependencies: .23.3.9.1.2.
  Acceptance: Public native/generated assessment before classification; preserve actual producer kinds and canonical empty/null/String/container domains, zero receiver operands, false retention, scalar guards/explicit bridges and ordered snapshots. Repair only confirmed bounded gaps; compile/small direct checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 remain separate.

  Activation: clean `61dd294d9394cfffc52abf0648a3c0530ecfd91a`; Perl committed, brief empty, tree clean.
  Owned paths: Confirmed Rust ordinary emptiness result/source/shape gaps only; shared native/restored/generated-plan fixture and direct has_key compatibility plus current docs.
  Verification tier: `focused`
  Focused checks: Public native/restored/generated-plan emptiness fixture before/after repair, direct has_key fixture, targeted offline Cargo compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored value/order regression, no quantified population or portable measurement.
  Confirmed findings / preservation: Public Engine native RED gives fluent null versus nested1!, S-only snapshot order and four malformed effects. Existing producer is Boolean-valued; preserve it. Add scalar-result/zero-operand shape handling and generic current-value dispatch, including ordinary family prefixes. First candidate then exposes copied Hash bindings/pipeline wrong1! versus0!: static Array inference from next is_empty loses a scalar-held Hash. Route initial copy followed by generic emptiness through evaluated actual-value dispatch, preserving the copy helper and retaining Array/Hash twins in the fixture.

  Completion: Zero-operand preflight/scalar-result flags and generic evaluated-value predicate dispatch, including ordinary Array/Hash/String/Number prefixes. Initial copy before a predicate avoids static Array inference; helper/copy/RuntimeValue emptiness policy unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Engine native RED gives fluent null versus nested1!, S-only order and four malformed effects. First candidate then exposes copied Hash binding/pipeline1! rather than0! while other fields pass.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs omits predicates from scalar-result/shape handling, routes generic sources through family-specific snapshots/validation and uses next is_empty Array classification for initial copy. Existing call_helper returns Bool from RuntimeValue::is_nonempty; preserve it.
  - [x] FIX: Classify scalar results, reject extra operands before effects, dispatch generic predicates by current evaluated value at initial/prefix/selected positions, and route initial copy before generic predicates the same way. No producer/copy/domain normalization or new vocabulary.
  - [x] ADDRESSED (verified): Native/restored/generated-plan shared fixture passes Array/Hash/String/null/zero/selected/pipeline/default/function and copied dynamic Array/Hash bindings, false retention/repeated predicates, explicit bridge/scalar nulls, zero malformed effects and1!/SA/once-only snapshots after RED.
  - [x] NO REGRESSION: Direct has_key native/restored/generated-plan fixture and targeted offline Cargo compilation pass; existing Boolean/Number0/false/data policy remains unchanged. No broad suite/format/source/copy changes.
  - [x] LOCKSTEP: Contract/worked catalog/guide, array/emptiness facts/map and task/live/resume align; bounded-history rollover if required is part of this commit. Book and fast memory/cadence/diagnosis/history/diff pass. Dart3 next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.9.2 - continue Rust generic emptiness results`.
  Continuity: Required engineering-notes pressure rollover archived the clean committed suffix as docs/history/development-notes/segment-4956-d41121f01c2b.md with its manifest/root update; --apply and --check pass. No immutable old segment edited or runtime verification scope expanded.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary emptiness result targets.
  Dependencies: .23.3.9.2.
  Acceptance: Public native/generated assessment before classification; preserve actual producer kinds and canonical empty/null/String/container domains, zero receiver operands, false retention, scalar guards/explicit bridges and ordered snapshots. Repair only confirmed bounded gaps; compile/small direct checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 remain separate.

  Activation: clean `796a3fdbaf2664f3a4922d7f552f4a574b99481b`; Rust committed, brief empty, tree clean.
  Owned paths: Confirmed Dart ordinary emptiness result/source/shape gaps only; native/restored/generated-plan shared fixture, direct has_key compatibility, selected-file analysis and current docs.
  Verification tier: `focused`
  Focused checks: Public native/restored/generated-plan shared emptiness fixture before/after repair, direct has_key fixture, fatal selected-file analysis, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored value/order regression, no quantified population or portable measurement.

  Completion: Include predicates in zero-operand preflight/source-independent scalar tracking and exempt these generic consumers from scalar container-only rejection. Bool helpers/source/copy and free-helper argument handling unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native fixture JSON RED retains correct source kinds/copy bindings/results/order, but incompatible/after-text consumers return[], bad empty1!, bad nonempty0! and four malformed effects.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart fluent preflight/scalar tracking omit emptiness predicates, while the Array-helper registry also puts their generic consumers in the scalar container-only guard.
  - [x] FIX: Add zero-operand preflight/scalar producer tracking independently of source; allow the existing generic predicates on scalar results without changing free-helper selector classifications or Bool/domain/source/copy behavior.
  - [x] ADDRESSED (verified): Native/restored/generated-plan shared fixture passes source kinds/copied Array/Hash bindings, repeated predicates, false retention/explicit bridge/scalar nulls, zero malformed effects and1!/SA/once-only snapshots after RED.
  - [x] NO REGRESSION: Direct has_key three-route fixture and fatal selected-file analysis pass; two targeted tests, no broad suite or serialized-format change.
  - [x] LOCKSTEP: Contract/worked catalog/guide, Dart/array facts/map and task/live/resume updated; book and fast memory/cadence/diagnosis/history/diff pass. Julia4 assessment next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.9.3 - guard Dart generic emptiness results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary emptiness result targets.
  Dependencies: .23.3.9.3.
  Acceptance: Public native/generated assessment before classification; preserve actual producer kinds and canonical empty/null/String/container domains, zero receiver operands, false retention, scalar guards/explicit bridges and ordered snapshots. Repair only confirmed bounded gaps; compile/small direct checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 remain separate.

  Activation: clean `10251b858e1fc20a3329d5bfc8e5fb9bbb6ec9f9`; Dart committed, brief empty, tree clean.
  Owned paths: Confirmed Julia ordinary emptiness result/source/shape gaps only; shared native/generated-plan/fresh-emitted fixture/registration, direct has_key compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Strict public native/generated-plan/fresh-emitted shared emptiness fixture before/after repair, direct has_key fixture, package compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Completion: Add predicates to zero-operand preflight/source-independent scalar tracking and permit these generic consumers on scalar results; existing Bool helpers/domains/source/copy unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native shared JSON RED retains correct flow/source kinds/copied bindings/order but incompatible/after-text [], bad empty1!, bad nonempty0! and four effects; native/plan/fresh all fail before repair.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _evaluate_runtime_fluent_chain! omits predicates from zero-operand/scalar tracking and treats generic predicate consumers as array-only at the scalar guard.
  - [x] FIX: Include predicates in those existing checks, independently of source, and exempt generic consumers from scalar container-only rejection. No Boolean normalization or helper/domain/source/copy change.
  - [x] ADDRESSED (verified): Strict native/generated-plan/fresh-emitted shared fixture passes source kinds/copied Array/Hash bindings, repeated predicates, false retention/explicit bridge/scalar nulls, no malformed effects and1!/SA/once-only snapshots after RED.
  - [x] NO REGRESSION: Direct has_key three-route fixture and package compilation pass under startup/history disabled and depwarn=error;6 assertions. No broad suite or generated-format change.
  - [x] LOCKSTEP: Register fixture; contract/worked catalog/guide, Julia/array facts/map and task/live/resume align. Book and fast memory/cadence/diagnosis/history/diff pass. Lua5 next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.9.4 - guard Julia generic emptiness results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary emptiness result targets.
  Dependencies: .23.3.9.4.
  Acceptance: Public native/generated assessment before classification; preserve actual producer kinds and canonical empty/null/String/container domains, zero receiver operands, false retention, scalar guards/explicit bridges and ordered snapshots. Repair only confirmed bounded gaps; compile/small direct checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 remain separate.

  Activation: clean `3959d9a60ce2023f92753bcd43cefb7487a86cf8`; Julia committed, brief empty, tree clean.
  Owned paths: Confirmed Lua ordinary emptiness result/source/shape gaps only; shared native/generated-plan/fresh-emitted fixture/runner registration, direct has_key compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public native/generated-plan/fresh-emitted emptiness before/after repair on available PUC5.5.1/LuaJIT with matching products, direct has_key fixture, interpreter/runner loadfile, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; declared5.4/full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Completion: Remove is_empty/is_nonempty from TERMINAL_STRING_HELPERS, mark their pure-string-dispatch results scalar and include zero-operand preflight. Generic consumers were already allowed by the Lua guard; actual container outputs release it.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native shared fixture RED on both installed hosts shows fluent null versus nested1!, S-only order and four malformed effects; full JSON retained.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua evaluate_fluent_calls stops these generic helpers via TERMINAL_STRING_HELPERS; evaluate_expr preflight omits their zero-operand shapes.
  - [x] FIX: Remove that endpoint fence, track existing Boolean results as scalar and preflight zero operands before effects. No producer/domain/source/copy/Boolean normalization.
  - [x] ADDRESSED (verified): Both hosts pass native/generated-plan/fresh-emitted shared fixture after RED, including source kinds/copied Array/Hash bindings, repeated predicates, false retention, explicit bridge/scalar nulls, no malformed effects and1!/SA/once-only snapshots.
  - [x] NO REGRESSION: Direct three-route has_key fixture and interpreter/runner loadfile pass on available PUC5.5.1/LuaJIT with matching products. No broad suite or generated-format change; declared5.4/full admission separate.
  - [x] LOCKSTEP: Register fixture; contract/worked catalog/guide, Lua/array/emptiness facts/map and task/live/resume align. Book and fast memory/cadence/diagnosis/history/diff pass. Bounded emptiness rollout targeted-checked; String predicate assessment23.2.9 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.9.5 - continue Lua generic emptiness results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10`
  Status: `active` / bounded children targeted-checked; broad admission23.4 separate
  Goal: Compatible result handoff for existing starts_with/ends_with/contains_substr/matches under string-predicate-results.md.
  Children: `.23.3.10.1`, `.23.3.10.2`, `.23.3.10.3`, `.23.3.10.4`, `.23.3.10.5`, `.23.3.10.6`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary String predicate result handoff.
  Dependencies: .23.2.9.
  Acceptance: Frozen string-predicate-results.md through public native/generated routes; preserve correct producers, actual kinds, null/empty/regex/source/operand/copy domains and SOC snapshots. One receiver operand before effects, source families, false retention, explicit bridges/scalar nulls; compile/small direct checks/docs/commit. No String-comparison registration, contains calibration or broader admission; Lua declared5.4 separate.

  Activation: clean `d58ea4478b36aff1c3c293fecbb3bb89c97f72be`; assessment committed, brief empty, tree clean.
  Owned paths: Existing Perl String predicate result-family/one-operand preflight only for confirmed gaps; shared native/fresh fixture, direct emptiness compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Native/fresh String predicate RED/GREEN across four methods, boundaries/source families/SOC and SC snapshots, false retention/bridges/scalar guards and malformed no-effects; direct emptiness fixture, source/test syntax/book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full regex/domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Completion: Use scalar_result for the four existing String predicate methods and include them in exact-one-operand ordinary preflight. Producer bodies/domains/regex/source/copy unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/fresh shared fixture RED2/6 on fluent-null results; nested vectors/producer controls remain correct. Retained Get/substitution diagnostic identifies terminal lowering.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering _string_receiver_value_chain_return_family labels all four methods terminal, ending compatible later links. Preflight needs one-operand shape before enabling flow.
  - [x] FIX: Return scalar_result and reject missing/extra operands before source/operand effects; reuse existing scalar/text/generic/explicit-container bridge dispatch. No producer/kind/domain/regex policy normalization.
  - [x] ADDRESSED (verified): Native/fresh shared fixture passes all four true/false pairs, null/empty/regex-i boundaries, selected/pipeline/Hash-view/split/function/default/join sources, false retention/repeated generic predicates, bridges/scalar nulls, eight malformed no-effect controls and SOC/SC/once-only snapshots after RED.
  - [x] NO REGRESSION: Direct native/fresh emptiness fixture and source/test syntax pass;12 assertions across two targeted fixtures. No broad suite/comparison registration/contains calibration/format change.
  - [x] LOCKSTEP: Contract/worked catalog/guide, String fact/map and task/live/resume align. Book and fast memory/cadence/diagnosis/history/diff pass. Rust2 independent assessment next after clean commit; full regex/domain/portable admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.1 - continue Perl String predicate results`.
  Surfaced gate ownership: New predicate t files are not automatically selected by canonical CI; exact named no-match controls and required before-admission/push repair are owned by23.4.1. Current directly executed focused proof remains valid; no canonical-coverage claim is made here.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary String predicate result handoff.
  Dependencies: .23.3.10.1.
  Acceptance: Frozen string-predicate-results.md through public native/generated routes; preserve correct producers, actual kinds, null/empty/regex/source/operand/copy domains and SOC snapshots. One receiver operand before effects, source families, false retention, explicit bridges/scalar nulls; compile/small direct checks/docs/commit. No String-comparison registration, contains calibration or broader admission; Lua declared5.4 separate.

  Activation: clean `7f5c87cb72aae96cca15a03a703e19e969042ee5`; Perl committed, brief empty, tree clean; committed memory invariants rechecked PASS.
  Owned paths: Confirmed Rust String predicate scalar/terminal/shape dispatch gaps only; native/restored/generated-plan shared fixture, direct predicate-boundary compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public native/restored/generated-plan shared String predicate fixture before/after repair, direct scalar_predicate_boundaries fixture, targeted offline Cargo compilation, book and fast staged continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full regex/domain/portable admission23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.
  Prior continuity clarification: The prior leaf's last pre-stage memory check rejected its temporary staged/unstaged pointer split. Final staging removed that split, but the check was not rerun before commit; committed-state rerun passes all invariants in string-predicate-perl-memory-final.log. No content repair is needed. Run final memory checks after all staging and branch on their exit status before subsequent commits.
  Newly confirmed P1 producer issue / own now: After scalar/shape dispatch repair, every shared native field passes except matches("ABC",/^a/i) renders0! rather than canonical1!. Existing catalog explicitly supports i; do not weaken the expected result or infer unsupported flags. Isolate free/fluent producer, serialized literal representation and public matcher path using owned Rust/public interfaces; repair a bounded LinkedSpec flag-loss cause if possible before accepting this leaf, otherwise split a concrete upstream/access blocker. RGX/PGEN remain read-only black boxes.
  Producer root cause / bounded repair authority: Free matches flag controls serialize /^a/i and /^a/ identically as regex pattern ^a; direct (?i), (?m), (?s), (?x) controls work through the public Engine/matcher. Owned rust/linkedspec-core/src/expr.rs parse_regex explicitly consumes/discards adjacent suffix letters before Expr::RegexLiteral {pattern}. Restore catalog imsx/go/unknown semantics in the existing pattern-string representation, with no new regex value kind/schema field or RGX/PGEN implementation/pin change. Add native/restored/plan flag controls and focused Core regex parser compatibility; old compiled artifacts require regeneration because lost flags cannot be recovered.

  Completion: Scalar-result/one-operand guards for four existing predicates; restore literal imsx suffix modes as inline flags in the existing Expr::RegexLiteral pattern string, keep go no-ops, and lower unknown suffixes to an invalid pattern for existing contextual failure handling. No regex value variant/serialized field/dependency change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Engine native shared fixture RED has fluent null, SO/S-only effects and12 malformed effects. Dispatch-only candidate leaves regex-i0!; free matches controls serialize /^a/i and /^a/ as identical pattern ^a. Native suffix imsx fail while equivalent inline controls work; unknownq is wrongly accepted.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs scalar/preflight lists omit predicates; existing terminal guards already honor selected results. Core expr.rs parse_regex explicitly skips adjacent flag letters then emits only body. This is LinkedSpec producer loss, not an inferred RGX defect.
  - [x] FIX: Add four methods to existing dispatch/shape lists; encode declared modes in existing pattern payload, deduplicate modes, ignore go and fail unsupported flags using existing invalid-regex handling. Preserve numeric substring flags/Boolean matches and all unrelated producer/domain/source/copy policies; no schema/type or black-box writes.
  - [x] ADDRESSED (verified): Native/restored/generated-plan shared result fixture passes true/false/null/empty/regex-i, source families, false retention/generic/bridges/scalar guards, no malformed effects and SOC/SC/once-only snapshots. Same three routes pass imsx, inline/no-flag controls, duplicatei, go/unknownq and flagged split/filter consumers after RED.
  - [x] NO REGRESSION: Direct scalar_predicate_boundaries and18 focused Core regex parser/compiler/validation tests pass with targeted offline compilation. No full suite or new serialized field/regex type. Older compiled nodes retain recorded patterns; regenerate from source to acquire previously lost suffix modes.
  - [x] LOCKSTEP: Contract/worked catalog/guide, String/regex facts/map and task/live/resume align. Book/history/diff and final staged memory/cadence/diagnosis checks pass; no canonical-coverage claim. Dart3 next after clean commit; full regex/admission and mandatory Perl registration23.4.1 remain separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.2 - carry Rust predicate results and regex flags`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary String predicate result handoff.
  Dependencies: .23.3.10.2.
  Acceptance: Frozen string-predicate-results.md through public native/generated routes; preserve correct producers, actual kinds, null/empty/regex/source/operand/copy domains and SOC snapshots. One receiver operand before effects, source families, false retention, explicit bridges/scalar nulls; compile/small direct checks/docs/commit. No String-comparison registration, contains calibration or broader admission; Lua declared5.4 separate.

  Activation: clean `d42199d00ee1f5a4712a3d8151c9dc8d1e9a2d1a`; Rust committed, brief empty, tree clean; final staged checks passed.
  Owned paths: Confirmed Dart ordinary String predicate dispatch/shape gaps only; shared native/restored/generated-plan fixture, direct emptiness compatibility, selected-file analysis and current docs.
  Verification tier: `focused`
  Focused checks: Public native/restored/generated-plan shared predicate fixture before/after repair, direct emptiness fixture, fatal selected-file analysis, book/history/diff and final staged memory/cadence/diagnosis checks.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full regex/domain/portable admission23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Newly confirmed P1 producer defects / own now: Native shared RED renders null suffix/needle operands1! instead of0!, regex /^a/i0! instead of1!, container negatives[] and malformed shapes execute12 effects. _callStringPredicate explicitly coerces null operands to empty text; ActionRegexLiteralExpr retains flags in AST/JSON but interpreter evaluation and contextual pattern conversion drop them. Restore null handling and existing inline i/m/s modes without changing producer kinds or introducing a public regex type. Other regex dialect/flag admission remains separate.

  Completion: Add four existing predicates to scalar/one-operand guards; stop null text operand coercion; retain literal i/m/s suffix modes in existing pattern strings/contextual helper operands using the existing inline bridge. No new type/schema or producer-kind normalization.
  Verification:
  - [x] REPRODUCE / ISSUE: Native shared RED has null suffix/needle1! instead of0!, regex-i0! instead of1!, container negatives[] and12 malformed effects. Valid result flow and SOC/SC snapshots already work.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart scalar/shape lists omit four predicates; _callStringPredicate sets nullAsEmpty; regex literal evaluation/contextual conversion return body without already-serialized flags. Extra inline grouped/dotted control fails separately because action_parser.dart rejects slash before (, exposing its dot as a fluent separator; owned P1 sibling6.
  - [x] FIX: Extend only existing guards; preserve null operands; encode suffix i/m/s for existing runtime bridge in action/contextual pattern conversion. Preserve numeric substring/Boolean matches and eager source/operand snapshots; no regex bridge/domain expansion.
  - [x] ADDRESSED (verified): Shared native/restored/plan expected JSON passes source families, all four true/false pairs, null/empty/regex-i, false retention/generic/bridges/scalar guards, SOC/SC/once-only effects and malformed no-effects. Added i/m/s no-flag/inline controls, duplicatei and flagged split/filter pass on all three routes.
  - [x] NO REGRESSION: Direct emptiness fixture and fatal selected-file analysis pass; three targeted tests. Added flag control initially had one extra expected Boolean after extracting the separately owned grouped-pattern case; corrected expected vector to authored eleven values, with all distinguishing false/true controls retained. No full suite or broad regex/comparison/contains admission.
  - [x] LOCKSTEP: Contract/book/String+regex facts/map and task/live/resume align. Book/history/diff and final staged memory/cadence/diagnosis checks pass; canonical coverage not claimed. Julia4 next after clean commit; P1 grouped Dart regex6 follows Julia/Lua before further families.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.3 - carry Dart predicate results and literal modes`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary String predicate result handoff.
  Dependencies: .23.3.10.3.
  Acceptance: Frozen string-predicate-results.md through public native/generated routes; preserve correct producers, actual kinds, null/empty/regex/source/operand/copy domains and SOC snapshots. One receiver operand before effects, source families, false retention, explicit bridges/scalar nulls; compile/small direct checks/docs/commit. No String-comparison registration, contains calibration or broader admission; Lua declared5.4 separate.

  Activation: clean `860e231f93714da4076ab477d6934b75b5d5e0d8`; Dart committed, brief empty and tree clean; post-commit pointer passed.
  Owned paths: Confirmed Julia ordinary String predicate result/shape gaps; shared native/generated-plan/fresh emitted fixture and registration, direct emptiness compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Shared public native/plan/fresh String predicate fixture before/after repair plus direct emptiness fixture with strict depwarn compilation; book/history/diff and final staged memory/cadence/diagnosis checks.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full regex/domain/portable admission23.4, Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Confirmed P1 producer boundary / own now: Native/plan/fresh shared RED renders null suffix/needle1! rather than0!, scalar negatives[], malformed predicate values with12 effects. Valid true/false/regex-i/SOC/SC/source-family behavior already works. _runtime_string_predicate explicitly coerces null operands to empty text; restore canonical undefined-operand false alongside existing scalar/shape lists, preserving actual numeric/Bool kinds and regex/eager evaluation policies.

  Completion: Extend existing scalar/one-operand lists for four predicates; reject undefined text operands instead of empty-text coercion. Existing correct result flow, regex flags, source/operand/result snapshots and numeric/Bool producer kinds remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared native/plan/fresh fixture RED renders null suffix/needle1!, scalar negatives[] and12 malformed effects; valid flow/regex-i/SOC/SC already correct.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _evaluate_runtime_fluent_chain! omits four predicates from scalar/preflight lists; _runtime_string_predicate sets null_as_empty on operand.
  - [x] FIX: Add four existing methods to lists and remove operand null coercion. No producer-kind/regex/source/copy normalization or new method/domain admission.
  - [x] ADDRESSED (verified): Native/plan/fresh exact shared JSON passes true/false/null/empty/regex-i, source families, false retention/generic/explicit bridges/scalar guards, eight malformed no-effect controls and SOC/SC/once-only snapshots.
  - [x] NO REGRESSION: Direct emptiness fixture and strict depwarn compilation pass; six targeted assertions across public native/plan/fresh routes. Full regex/domain/context admission remains separate.
  - [x] LOCKSTEP: Registered new Julia fixture; contract/book/String+Julia fact/map and task/live/resume align. Book/history/diff and final staged memory/cadence/diagnosis pass; Lua5 next after clean commit, P1 Dart grouped regex6 follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.4 - guard Julia predicate results and null operands`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary String predicate result handoff.
  Dependencies: .23.3.10.4.
  Acceptance: Frozen string-predicate-results.md through public native/generated routes; preserve correct producers, actual kinds, null/empty/regex/source/operand/copy domains and SOC snapshots. One receiver operand before effects, source families, false retention, explicit bridges/scalar nulls; compile/small direct checks/docs/commit. No String-comparison registration, contains calibration or broader admission; Lua declared5.4 separate.

  Activation: clean `4584d0b41e12581a7bc68e9ad80336abf968d72f`; Julia committed, brief empty and tree clean; post-commit pointer passed.
  Owned paths: Confirmed Lua ordinary String predicate terminal/result/shape gaps; shared native/plan/fresh fixture on available hosts and named runner registration, direct emptiness compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Shared public native/plan/fresh String predicate RED/GREEN on PUC5.5.1/LuaJIT, direct emptiness fixture and loadfile compilation, book/history/diff and final staged memory/cadence/diagnosis checks.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full regex/domain/portable admission23.4, declared5.4 proof, Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression on named hosts, no quantified population or portable measurement.

  Newly confirmed P1 producer boundary / own now: Both hosts show terminal-null/SO/S/12-effect RED. Flow-only candidate additionally exposes null suffix/needle1! rather than0!; string_predicate explicitly uses scalar_string(...,true), matching Dart/Julia cause. Restore canonical null-operand false. Existing run.lua matches terminal_chain expectation contradicts new flow; its neighboring length().trim() terminal expectation is also stale after23.3.3. Update and run only those exact direct String/regex cases alongside shared/direct emptiness; no full suite.

  Known native failure recovered / no new defect: The added existing full regex helper compatibility case re-enters the recorded malformed-pattern PUC5.5.1 crash (exit139). Canonical lua-native-readme-and-action-ast-reading and pending LUA-STARTUP-READING.2.3 already locate unsupported %lu in regex_pcre2.c luaL_error; that exact group was explicitly excluded under reading1.42. This slice mistakenly selected it before checking the known exclusion. No repeat crash or native patch; keep repair/re-admission with existing owner and prerequisite2.2 runtime/header identity. JIT whole case passes; PUC pass counts exclude it. Safe shared/direct checks pass on both hosts.
  Completion: Remove four String predicate terminal fences; mark results scalar, preflight one operand and reject null text operands. Existing numeric/Bool kinds, regex/source/copy and correct snapshots remain. Register named fixture and update stale matches/length terminal expectations in directly affected runner cases.
  Verification:
  - [x] REPRODUCE / ISSUE: Both hosts' shared native RED has fluent null/SO/S and12 malformed effects while nested controls work. Dispatch candidate exposes null suffix/needle1! instead of0!; initial candidate accidentally retained starts_with last map entry, removed before acceptance.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua TERMINAL_STRING_HELPERS fences four methods, scalar/preflight omit them, and string_predicate calls scalar_string operand with null-as-empty. Existing runner terminal assertions lag result features. Native malformed-pattern failure has separate canonical cause/owner above.
  - [x] FIX: Remove only four fences, extend scalar/shape lists and reject null operand coercion; update direct runner expectations. No producer kind/regex/domain/source/copy normalization or native dependency change.
  - [x] ADDRESSED (verified): Both hosts' shared native/plan/fresh exact JSON passes four true/false pairs, null/empty/regex-i, source families, false retention/generic/bridges/scalar guards, eight malformed no-effect controls and SOC/SC/once-only snapshots.
  - [x] NO REGRESSION: Both hosts pass shared/direct emptiness plus affected deterministic String case; JIT also passes whole strict regex helper case, PUC excludes its known native invalid-pattern crash. Selected runner gives3 PUC /4 JIT named cases; all changed Lua files loadfile-compile. No whole suite/declared5.4/full regex admission claim.
  - [x] LOCKSTEP: Contract/book/String+Lua fact/map and task/live/resume align. Book/history/diff and final staged memory/cadence/diagnosis checks pass; P1 Dart grouped regex6 next after clean commit. Native crash remains owned2.3 with runtime/header prerequisite2.2; do not relabel as fixed.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.5 - continue Lua predicates and reject null operands`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.6`
  Status: `completed`
  Priority: P1; owned Dart grouped-regex action scanner repair, immediately after Julia4/Lua5 result handoff and before further family/admission work.
  Goal: Repair the newly reproduced grouped literal/dot parsing boundary without confusing division or receiver syntax.
  Reproduction: Public native execution of Top:: I { return(matches(input_text(),/(?s)^a.b$/)) } raises unsupported raw action expression for /(?s)^a.b$/; same mode as /^a.b$/s executes. Additional mode control failed in string-predicate-dart-green.log while the shared String fixture/direct emptiness passed.
  Root cause: action_parser.dart _looksLikeRegexStart explicitly rejects slash followed by open parenthesis; _splitTopLevelFluentSegments consequently sees the pattern's dot, and _parseFluentChain emits ActionRawExpr(reason invalid_fluent_chain) before _parseLiteral can recognize it. Existing matching.dart supports inline i/m/s; do not classify this as an engine limitation.
  Acceptance: Focused public AST/native/restored/plan grouped/dotted and slash/division/receiver controls, minimal lexical repair, direct predicate compatibility and current book/fact/task/live docs. Assess extended x/unknown suffix modes independently before claiming full catalog support; current i/m/s repair is bounded. No dependency implementation inspection, public regex type or full gate.
  Activation: clean `5bf0009e421a35f99aaa4b4fae5c08c2e5f8bf74`; Lua committed, brief empty/tree clean, post-commit pointer passed.
  Scope reconciliation: Canonical dart-regex-brace-scanner-defects already owns the same slash-before-( scanner cause under DART-STARTUP-READING.2.2.1; broader attached-block/grouped-brace and validator/outer collector repairs stay there/2.2.2. This leaf repairs complete standalone action literal recognition before fluent splitting, including grouped dots, without globally reclassifying slash/division or closing those owners. No x/unknown-mode expansion in this bounded leaf.
  Verification tier: `focused`
  Focused checks: Public grouped-literal AST/native/restored/generated-plan RED/GREEN, slash symbolic-call/ordinary fluent controls, direct String predicate fixture, fatal selected-file analysis and small parser test; book/history/diff and final staged memory/cadence/diagnosis.
  Canonical trigger: None for bounded first-party action literal priority repair under director feature-first cadence; broad scanner/domain/portable admission and final clean push remain separate.
  Claim verification: none: deterministic authored lexical/result regressions, no quantified population or portable measurement.

  Completion: Recognize a complete ActionRegexLiteralExpr before assignment/fluent scanning; do not change global slash classification. Grouped dotted literals retain pattern payload/source spans through existing AST/JSON and runtime bridge. Broader scanner/brace owners remain open.
  Verification:
  - [x] REPRODUCE / ISSUE: Public parseActionExpression(/(?s)^a.b$/) RED returns ActionRawExpr; prior native result test raises unsupported raw expression. Suffix /^a.b$/s works.
  - [x] ROOT CAUSE (WHY + WHERE): action_parser.dart _parseExpr tries fluent splitting before _parseLiteral; existing _looksLikeRegexStart rejects slash before (, so the pattern dot is treated as a method separator. Canonical broader scanner owner2.2.1 is retained, not duplicated/closed.
  - [x] FIX: At _parseExpr entry, recognize only complete slash literals using existing anchored literal parser. Symbolic division calls/ordinary receiver expressions fail this literal check and follow the original route. No general delimiter/validator/outer collector change or new regex type/mode.
  - [x] ADDRESSED (verified): Public AST and native/restored/generated-plan grouped dotted regex and fluent/nested matches return exact [true,1!,true,4,A.B] with symbolic division/ordinary receiver controls. Existing shared predicate/mode tests pass.
  - [x] NO REGRESSION: Direct action_ast_parser_test plus changed result test pass10 targeted tests; fatal selected-file analysis passes. No whole suite or broader grouped-brace/x/unknown regex admission.
  - [x] LOCKSTEP: Contract/book/String+regex facts/map and task/live/resume align. Book/history/diff and final staged memory/cadence/diagnosis pass. Definedness assessment23.2.10 next after clean commit; broader DART-STARTUP-READING.2.2.1/.2.2.2 and Lua native crash2.3 remain owned.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.6 - parse complete grouped regex literals before fluent dots`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.7`
  Status: `completed`
  Priority: P1 immediate next after23.2.12, before contains23.2.13.
  Goal: Preserve complete grouped or whitespace-prefixed action regex literal boundaries inside ordinary helper calls, including invalid grouped regex reaching its helper failure boundary.
  Dependencies: .23.2.12 committed cleanly; coordinate existing DART-STARTUP-READING.2.2.1/.2.2.2 without claiming their full scanner/validator closeout.
  Reproduce: Public authored matches("abc",/(/), receiver matches(/(/), split/filter(/(/) become raw action expressions instead of reaching false/empty helper behavior. The same malformed text as a quoted runtime pattern reaches a FormatException;23.2.12 owns that helper boundary.
  Root cause: action_parser.dart _looksLikeRegexStart rejects slash followed by opening parenthesis/whitespace; _findMatchingDelimiter therefore counts the regex's opening parenthesis as action syntax and misses the enclosing call end. Complete standalone /(/ still has literal priority. Retained public AST/native probe: docs/checkpoints/type-operation-inventory/probe_dart_grouped_invalid_pattern.dart.
  Acceptance: Reconcile operand-position slash literals against symbolic /(8,2) and / (8,2), ordinary numeric division, escaped delimiters, classes and valid grouped patterns. Confirm exact AST/source spans and native/restored/plan false/empty invalid-group consumers; small direct parser/String checks and docs/commit. No global regex type, engine/dialect, unassessed brace-scanner/validator closure or full suite.
  Planned verification tier: focused; declare metadata at activation.

  Activation: clean `dc7b9950764bdf717b07de3429c7de9dd9336098`; modes committed, brief0/tree clean.
  Owned paths: Complete grouped/whitespace-prefixed action operand recognition, exact public AST/source and native/restored/plan consumers, direct bounded parser/String checks and docs. Broader brace-scanner/validator admission remains DART2.2.
  Verification tier: `focused`
  Focused checks: Retained public grouped-invalid AST/native probe, exact operand AST/spans/division and native/restored/plan RED/GREEN, prior mode/String fixture, selected-file fatal analysis/formatting and book/history/diff/final staged continuity checks.
  Canonical trigger: None for bounded ordinary syntax preservation under director feature-first cadence; broad scanner/validator/context admission remains separate.
  Claim verification: none: deterministic authored parse/runtime regression controls, no grammar population/completeness measurement.

  Completion: _looksLikeRegexStart accepts complete grouped/whitespace-prefixed slash operands only at existing operand-start positions. Reuse literal escape/body/flags shape with a following operand boundary after optional whitespace; no closing slash means symbolic division remains a call. Matching/statement/fluent scanners reuse this classification. No validator/dialect/schema change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public AST/native probe and new exact operand fixture RED: nested /(/ is ActionRawExpr and helper/receiver/split/filter are unsupported raw code. Five valid grouped/escaped/class/whitespace/division/quoted controls already pass. Standalone /(/ is RegexLiteral.
  - [x] ROOT CAUSE (WHY + WHERE): action_parser.dart _looksLikeRegexStart unconditionally rejects next '(' or whitespace; _findMatchingDelimiter and shared _consumeScanChar then count regex punctuation as action syntax. A complete literal prefix must have escaped delimiters and a real following operand boundary, not just a slash somewhere later.
  - [x] FIX: Add one compiled complete-prefix recognizer and retain existing preceding-operand classification. Right-boundary lookahead skips whitespace before requiring delimiter/end; this prevents a second spaced division call from closing a supposed regex over adjacent array entries. Preserve symbolic calls and source text/spans.
  - [x] ADDRESSED (verified): Exact RegexLiteral operand pattern/source/span14-17 passes; native/restored/plan grouped invalid matches/receiver false and split/filter empty, valid escaped delimiter/class/whitespace groups and nested/adjacent/continued symbolic divisions pass. Retained probe now reports typed call/false and division4, with no new Regex kind.
  - [x] NO REGRESSION: Prior mode/String fixtures and direct ActionIR parser controls pass;44 targeted Dart tests plus fatal selected-file analysis/formatting. No full suite, broad brace/scoped-regex/emitted admission or existing validator repair inferred.
  - [x] LOCKSTEP: Book removes obsolete ordinary grouped-invalid caveat and teaches helper false/empty; canonical mode/operand/brace facts, DART2.2.1 partial repair note and current task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Contains23.2.13 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.7 - recognize complete Dart grouped regex operands`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.11`
  Status: `active` / bounded children targeted-checked; broad admission23.4 separate
  Goal: Ordinary is_defined/is_undefined generic receiver/result handoff under definedness-results.md; preserve actual producer kinds/domains.
  Children: `.23.3.11.1`, `.23.3.11.2`, `.23.3.11.3`, `.23.3.11.4`, `.23.3.11.5`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.11.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary generic definedness receiver/result handoff.
  Dependencies: .23.2.10.
  Acceptance: Frozen definedness-results.md through public native/generated routes; preserve actual non-null definition, true/false kinds/text/default behavior and correct source/result snapshots. Zero receiver operands before effects, source families/all admitted value kinds, compatible scalar/generic consumers/explicit bridges and scalar guards. Small compile/direct check/docs/commit; full regex/domain/portable admission and Lua declared5.4 separate.

  Activation: clean `152208bb63b82cf30b52e9eba483dc8027093062`; assessment committed, brief empty/tree clean; post-commit pointer passed.
  Owned paths: Existing Perl generic definedness receiver routing/result/shape registrations only; actual free helpers already correct. Shared source fixture with explicit Perl expected variant, native/fresh regression, direct String predicate compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public native/fresh generic definedness RED/GREEN fixture, direct String predicate fixture, source/test syntax, book/history/diff and final staged memory/cadence/diagnosis. Preserve1/empty-string and correct nested SC snapshot control; no broad suite.
  Canonical trigger: None for bounded frozen implementation under director feature-first cadence; full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored regression values/order, no quantified population or portable measurement.

  Newly exposed P1 operand lowering / own now: Registration-only native/fresh fixture compiles but reaches undefined host first; public dump_parser_source emits defined(word)/!defined(missing), defined(first(...)) and an unlowered is_defined(word) inside the explicit split bridge. The existing typed free helper's generic variable_source operand path is unsuitable when synthetic receiver source is reconstructed; literal/free-nested assessment remains correct. Lower the definedness operand as an actual typed value (bare_scalar_read), preserving defined()/!defined() result representation and once-only behavior. Include names in existing legacy nested helper recognition only as required by the demonstrated bridge.

  Completion: Register definedness generic/scalar/zero-operand routes, preserve actual source-kind/copy/default dispatch and add handoff after numeric prefixes. Typed actual-value operands plus a corresponding legacy definedness branch finish synthetic producers; remove dead generic typed cases. Keep defined()/!defined()1/empty-string results unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: LinkedSpec::Get native/fresh shared fixture RED has raw-host/compile failures. Registration candidate emits defined(word), defined(first(...)) and raw is_defined inside split bridge, reaching undefined host first. call_spec_handler_subst/dump_parser_source retain exact mechanisms and locations.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering's generic/return-family/shape/copy guards omit definedness. Reconstructed call operands need bare_scalar_read typed lowering; selected/bridge paths enter the compatibility lowerer, which has no definedness branch. Free literal/nested assessment semantics already correct.
  - [x] FIX: Extend existing registrations/guards; keep first generic sources on actual-kind route, permit numeric-prefix handoff, lower typed operands fully and add explicit legacy producer lowering. Preserve1/empty-string actual kinds, definedness/domain/source/copy/default policies; no Boolean normalization.
  - [x] ADDRESSED (verified): Native/fresh shared source with explicit Perl expected JSON passes true/false/null/empty/zero/Array/Hash, named/selected/pipeline/numeric/function/default/copied sources, false text/fallback, repeated generic/explicit bridges/scalar guards, malformed no-effects and1!/SC/one source call.
  - [x] NO REGRESSION: Direct native/fresh String predicate fixture passes; final definedness rerun6 assertions passes after completing the missing legacy path. Source/test syntax pass; no phase0/full suite or other-backend/portable admission claim. Known wrapper setpgid warning occurs only in the failed intermediate log; existing SESSION7 owner unchanged.
  - [x] LOCKSTEP: Contract/source/Perl expected variant/native+fresh fixture, book/guide and canonical fact/map align with task/live/resume and SESSION28.5/index. Histories/book/diff and final staged memory/cadence/diagnosis checks pass; Rust2 next after clean commit. New Perl fixture canonical registration remains mandatory23.4.1 before admission/push.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.11.1 - add Perl generic definedness receiver flow`.

  Same-slice history containment: CHANGES reached its90% byte rollover trigger; tool archived only a complete clean-HEAD suffix as docs/history/changes/segment-4958-c104128986da.md and refreshed the manifest/root. Apply/check pass; no immutable prior evidence edited.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.11.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary generic definedness receiver/result handoff.
  Dependencies: .23.3.11.1.
  Acceptance: Frozen definedness-results.md through public native/generated routes; preserve actual non-null definition, true/false kinds/text/default behavior and correct source/result snapshots. Zero receiver operands before effects, source families/all admitted value kinds, compatible scalar/generic consumers/explicit bridges and scalar guards. Small compile/direct check/docs/commit; full regex/domain/portable admission and Lua declared5.4 separate.

  Activation: clean `c9986d985378fdf5ec80ce828e766784bb5093cd`; Perl committed, brief empty/tree clean; post-commit pointer passed.
  Owned paths: Confirmed Rust ordinary generic definedness dispatch/result/shape gaps; shared source/current Boolean expected variant and public native/restored/plan fixture, native free producer preservation control, direct String compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public actual free producer kind/text/default control and native/restored/generated-plan shared definedness fixture before/after repair, direct String result fixture, targeted offline Cargo compilation, rustfmt and book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression and explicit backend producer preservation, no quantified population or portable measurement.

  Newly confirmed P1 literal receiver parse gap / own now: Public Engine free producer control passes Bool/0!/retained false, but shared source compilation fails at false.is_defined() (expected comma or closing array). Core expr.rs parse primary immediately returns BooleanLiteral/Undef while numeric/String primaries enter parse_fluent_chain. Add the same existing postfix path for true/false/undef; preserve whole-word prefix checks and existing AST/schema. This is a first-party syntax handoff needed by the frozen generic value-kind contract, not a numeric-dot or dependency defect. Then independently assess runtime dispatch/guards without weakening source literal cases.

  Runtime baseline after literal syntax repair: Native free producer vector retains Bool/text/default controls; newly parsed true/false/undef receiver controls return null. Shared receiver values are null while nested controls give1!; malformed calls execute4 effects. Source/consumer already execute once in SC order and source becomes changed. is_emptiness_receiver_method currently gates actual-kind generic dispatch and prefix/copy/selected handoffs; extend that shared classification to all four existing generic predicates, scalar-result and zero-operand lists without changing helper producer semantics.

  Snapshot distinguishing control: Strengthen only the shared consumer mutation from one defined String to actual null; expected predicate result stays1!, orderSC/calls1 and final source null on both backend-specific goldens. This distinguishes capturing the earlier predicate from reading the mutated binding later. Recheck the same Perl native/fresh and Rust native/restored/plan fixture because its shared input changed; no broader suite. Historical assessment probe remains its recorded changed-String baseline.

  Completion: Core true/false/undef literals use existing fluent parsing; runtime generic classification covers definedness in initial/selected/copy/family-prefix dispatch and scalar/zero-operand lists. Existing Bool producer, scalar-text/default/null/source/copy policies and AST/schema stay unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Engine free Bool/text/default control passes; shared compile RED stops at false.is_defined(). Added true/false/undef postfix control also fails compilation. Parser-only candidate gives native null receiver values beside nested1!, three literal controls null and4 malformed effects.
  - [x] ROOT CAUSE (WHY + WHERE): Core expr.rs returns BooleanLiteral/Undef before parse_fluent_chain; number/String primaries already enter it. engine.rs is_emptiness_receiver_method restricts existing actual-kind generic/prefix/copy/selected dispatch; scalar/zero-operand lists omit definedness. Producer/source/order already correct.
  - [x] FIX: Add existing postfix parser calls at three literal returns with whole-word checks unchanged; rename/extend shared generic receiver classification and scalar/shape lists. No helper producer, type/schema, regex/dependency or Boolean normalization change.
  - [x] ADDRESSED (verified): Native/restored/plan shared exact Boolean expected JSON passes source/null/defined/empty/false/zero/container/copy families, false retention/generic/bridges/scalar guards, malformed no-effects and1!/SC/one-call snapshots. Native free producer/literal vector preserves actual Bool/text/default. Strengthened consumer mutates source to null yet earlier result staystrue; same Perl native/fresh fixture recheck passes.
  - [x] NO REGRESSION: Direct String predicate result/flag fixtures pass; four focused Rust tests pass; after the shared snapshot input change, the same definedness2 and Perl6 assertions recheck successfully. Targeted offline compilation and rustfmt pass. No broad suite or portable/full-domain claim; Perl1/empty-string and RustBool variants are explicit.
  - [x] LOCKSTEP: Shared source/Boolean+Perl expectations, contract/book/guide and generic/teaching facts/map align with task/live/resume. Book/history/diff and final staged memory/cadence/diagnosis checks pass; Dart3 next after clean commit. Full admission/Perl canonical registration23.4.1 remain separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.11.2 - carry Rust definedness and literal receiver chains`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.11.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary generic definedness receiver/result handoff.
  Dependencies: .23.3.11.2.
  Acceptance: Frozen definedness-results.md through public native/generated routes; preserve actual non-null definition, true/false kinds/text/default behavior and correct source/result snapshots. Zero receiver operands before effects, source families/all admitted value kinds, compatible scalar/generic consumers/explicit bridges and scalar guards. Small compile/direct check/docs/commit; full regex/domain/portable admission and Lua declared5.4 separate.

  Activation: clean `01e9d8aae02e76ead8575468c743490a431926a7`; Rust committed, brief empty/tree clean; post-commit pointer passed; identity derived from Git.
  Owned paths: Confirmed Dart ordinary generic definedness result/shape gaps; shared native/restored/generated-plan fixture and actual Bool/text/default controls, direct String compatibility, fatal selected-file analysis and current docs.
  Verification tier: `focused`
  Focused checks: Public actual producer and shared native/restored/plan RED/GREEN including null-mutating snapshot, direct String fixture and selected-file fatal analysis, book/history/diff and final staged memory/cadence/diagnosis.
  Canonical trigger: None for bounded frozen implementation under director feature-first cadence; full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Public baseline: Shared native valid source/result/null/empty/false/zero/copy/default/generic/bridge and1!/SC/one-call/final-null snapshot fields already match. Only container negatives[] and malformed[1!,1!]/four effects fail; free Bool/text/default/true-false-undef literal controls pass native/restored/plan. interpreter.dart scalar-result and zero-operand lists omit definedness; extend only those lists, preserving producer/domain/source/copy behavior.

  Completion: Add definedness to existing scalar-result and zero-operand lists only. Valid generic helper dispatch, Bool/text/default/source/copy and primitive literal parsing were already correct; preserve them.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native shared exact JSON differs only at container negatives[] and malformed[1!,1!]/four effects. Free Bool/text/default and true/false/undef literal control passes native/restored/plan before repair.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart fluent preflight and mayProduceScalar lists omit is_defined/is_undefined. Existing generic/pure helper dispatch already accepts actual kinds and snapshots.
  - [x] FIX: Four list entries across those two guards; no producer/parser/type/schema/domain/source/copy change or Boolean normalization.
  - [x] ADDRESSED (verified): Shared native/restored/plan exact Boolean JSON passes true/false/null/empty/zero/containers, source/copy families, false retention/repeated generic/bridges/scalar guards, malformed no-effects and1!/SC/one-call/final-null snapshot; free producer controls continue passing on all three routes.
  - [x] NO REGRESSION: Direct String predicate/mode/grouped-literal fixture and fatal selected-file analysis pass; five targeted Dart tests. No broad suite or full-domain/portable admission.
  - [x] LOCKSTEP: Contract/book/guide and canonical Dart fact/map align with task/live/resume. Book/history/diff and final staged memory/cadence/diagnosis pass; Julia4 next after clean commit. Mandatory Perl canonical registration23.4.1/full admission stay separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.11.3 - guard Dart definedness result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.11.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary generic definedness receiver/result handoff.
  Dependencies: .23.3.11.3.
  Acceptance: Frozen definedness-results.md through public native/generated routes; preserve actual non-null definition, true/false kinds/text/default behavior and correct source/result snapshots. Zero receiver operands before effects, source families/all admitted value kinds, compatible scalar/generic consumers/explicit bridges and scalar guards. Small compile/direct check/docs/commit; full regex/domain/portable admission and Lua declared5.4 separate.

  Activation: clean `4423e5131ef76fd046d54438aae1470731050b1c`; Dart committed, brief empty/tree clean; post-commit pointer passed; identity derived from Git.
  Owned paths: Confirmed Julia ordinary generic definedness result/shape gaps; shared native/generated-plan/fresh fixture and producer controls/runner registration, direct String compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Shared public native/plan/fresh RED/GREEN plus free Bool/text/default/literal controls and direct String fixture with strict depwarn compilation; book/history/diff and final staged memory/cadence/diagnosis.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Public baseline: Native/plan/fresh shared valid fields including null/empty/false/zero/copy/default/generic/bridge and1!/SC/one-call/final-null snapshot agree; container negatives[] and malformed[1!,1!]/four effects fail. Existing Bool producer and generic dispatch are preserved; extend scalar/zero-operand lists only. Initial top-level failing testset stops before later free-control testset; consolidate both calls into one testset so all six route assertions execute in the final focused check, without claiming unrun baseline producer controls.

  Producer-kind oracle / fixed now: Existing Julia == value comparison alone can accept Boolean/integer equality; add explicit isa Bool assertions at Boolean expected positions of the retained producer vector on native/plan/fresh routes. Shared value controls and runtime producer stay unchanged; rerun only this same fixture after adding its distinguishing type assertion, no broader matrix.

  Completion: Add definedness to scalar-result/zero-operand lists only; register new fixture. Preserve Bool/text/default/actual-kind source/copy/literal semantics and correct snapshots. Explicit Bool producer-type assertions strengthen the value oracle on all three routes.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/plan/fresh shared RED has container negatives[] and malformed[1!,1!]/four effects while other expected fields including1!/SC/one-call/final-null match. Initial top-level failure prevents later producer set; no unrun baseline control is claimed.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl fluent scalar-result and zero-operand lists omit definedness; existing generic dispatch/producer already handle actual kinds. Value equality alone does not establish Bool identity, so producer assertions need isa Bool.
  - [x] FIX: Extend two existing lists; preserve producer/parser/schema/domain/source/copy. Consolidate shared and producer checks into one testset and assert Bool at expected Boolean vector positions for native/plan/fresh. No numeric-Boolean normalization.
  - [x] ADDRESSED (verified): Exact shared Boolean expected JSON passes source/null/defined/empty/false/zero/copy/default/selected/numeric/function families, false retention/generic/bridges/scalar guards, malformed no-effects and1!/SC/one-call/final-null. Native/plan/fresh free producer/text/default/literal controls and type assertions pass.
  - [x] NO REGRESSION: Definedness6 value and direct String3 assertions pass with strict depwarn compilation; after type-assertion addition, the same definedness fixture passes9 assertions. No whole suite/full-domain/portable admission or producer/parser repair claim.
  - [x] LOCKSTEP: New runner include, contract/book/guide and Julia/generic facts/map align with task/live/resume. Book/history/diff and final staged memory/cadence/diagnosis pass; Lua5 next after clean commit. Perl canonical registration23.4.1 and full admission remain separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.11.4 - guard Julia definedness scalar and arity flow`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.11.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary generic definedness receiver/result handoff.
  Dependencies: .23.3.11.4.
  Acceptance: Frozen definedness-results.md through public native/generated routes; preserve actual non-null definition, true/false kinds/text/default behavior and correct source/result snapshots. Zero receiver operands before effects, source families/all admitted value kinds, compatible scalar/generic consumers/explicit bridges and scalar guards. Small compile/direct check/docs/commit; full regex/domain/portable admission and Lua declared5.4 separate.

  Activation: clean `77dad432e0851e4071f09ad47bc36294526dbd39`; Julia committed, brief empty/tree clean; post-commit pointer passed; identity derived from Git.
  Owned paths: Confirmed Lua ordinary generic definedness terminal/result/shape gaps; shared native/plan/fresh fixture and producer controls/runner registration on available hosts, direct String compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Shared native/plan/fresh definedness RED/GREEN and free Bool/text/default/literal controls on PUC5.5.1/LuaJIT, direct String fixture/loadfile compilation, book/history/diff and final staged memory/cadence/diagnosis.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; declared5.4/full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored regression values/order on named hosts, no quantified population or portable measurement.
  Known exclusion: Do not select the existing malformed regex groups; native crash LUA-STARTUP-READING.2.3 and declared-primary identity2.2 remain independently owned. Valid direct String fixture uses no malformed regex.

  Public baseline: Both hosts' shared native RED has terminal-null results, nested1!, orderS/sourceabc and4 malformed effects; source call remains once. Producer-first recheck confirms all native/plan/fresh Bool/text/default and true/false/undef literal controls before reaching the same shared failure. Only remaining TERMINAL_STRING_HELPERS entries are definedness; remove that now-empty fence/map and extend scalar/zero-operand lists, keeping String comparison policy and existing producers unchanged.

  Completion: Remove definedness's last two terminal fences and the empty private map; mark results scalar and preflight zero operands. Register named fixture; String comparison terminal policy and existing Bool/source/copy/domain semantics remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Both hosts' shared native RED gives fluent null beside nested1!, orderS/sourceabc and4 malformed effects. Producer-first recheck passes native/plan/fresh Bool/text/default and true/false/undef literal controls before reaching the same shared failure.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua TERMINAL_STRING_HELPERS retains only is_defined/is_undefined; scalar and zero-operand lists omit them. Producers already yield correct Bool/text/default values and source evaluation is once.
  - [x] FIX: Delete only those remaining entries/map and simplify its sole fence to the unchanged String comparison condition; extend scalar/shape lists. No producer/parser/type/schema/domain/source/copy normalization.
  - [x] ADDRESSED (verified): Both hosts' native/plan/fresh exact shared JSON and free producer controls pass source/null/defined/empty/false/zero/copy/default/pipeline/numeric/function families, false retention/generic/bridges/scalar guards, malformed no-effects and1!/SC/one-call/final-null snapshot.
  - [x] NO REGRESSION: Direct String fixture and loadfile compilation pass on PUC5.5.1/LuaJIT alongside shared/producer checks. No whole suite, malformed native regex case, declared5.4 or full-domain/portable claim; native crash2.3 remains owned.
  - [x] LOCKSTEP: Named runner include, contract/book/guide and canonical Lua fact/map align with task/live/resume. Book/history/diff and final staged memory/cadence/diagnosis pass; String comparison assessment23.2.11 next after clean commit. Full admission/canonical Perl registration23.4.1 remain separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.11.5 - continue Lua definedness receiver results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.12`
  Status: `active` / bounded explicit String comparison counterparts planned
  Goal: Ordinary receiver/result counterparts for six str_* helpers under string-comparison-results.md; preserve actual producer and lexical domains.
  Children: `.23.3.12.1`, `.23.3.12.2`, `.23.3.12.3`, `.23.3.12.4`, `.23.3.12.5`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.12.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary str_eq/str_ne/str_gt/str_ge/str_lt/str_le receivers and compatible result handoff.
  Dependencies: .23.2.11.
  Acceptance: Frozen string-comparison-results.md through public native/generated routes; preserve actual producer kinds, existing null/scalar/Unicode/empty/source/copy domains and correct source/operand/result snapshots. One operand before effects, all six true/false pairs, source families/false retention/generic/bridges/scalar guards; small compile/direct checks/docs/commit. Numeric aliases, deferred/callable/full admission and declared Lua5.4 remain separate.

  Activation: clean `789dc307a8bd6706a68038bb4aea8d4703ea3ddf`; assessment committed, brief empty/tree clean; post-commit pointer passed; identity derived from Git.
  Owned paths: Existing Perl six String comparison receiver/result/shape registrations and any newly confirmed bounded operand-lowering gap; shared native/fresh fixture, distinguishing zero-text producer control, direct definedness compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public free zero-text literal/binding control before classification; native/fresh six-method shared RED/GREEN with actual1/0/null compatibility and SOC snapshots, direct definedness fixture, source/test syntax/book/history/diff and final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order and producer-preservation controls, no quantified population or portable measurement.

  Completion: Add six str_* names to existing one-operand and scalar-result String receiver lists only. Existing numeric1/0 producers, lexical/undef-as-empty behavior and correct eager snapshots remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public free literal/bound zero-text control gives[1,1,1!] and substitution preserves quoted0 versus $zero_text. New shared native/fresh fixture RED has raw receiver/handler compile failures before counterparts; no producer repair is inferred.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering String return-family and one-operand lists omit six free-only bridge names. Existing str_* branch captures lhs/rhs into temporaries and returns1/0 with lexical operators; source/operand/order already correct.
  - [x] FIX: Two registration/preflight lines enable ordinary counterparts and current-value scalar/generic/bridge continuation; keep numeric aliases and existing producers/domains/source/copy semantics.
  - [x] ADDRESSED (verified): Native/fresh exact shared Perl JSON passes all six true/false pairs and raw numeric flags, null/empty/zero literal-binding twins, named/selected/pipeline/Hash/split/function/default/join sources, retained0!/generic/bridges/scalar guards,12 malformed no-effects and1!/SOC/once-only/final-null snapshot. Null-source operand control remains0!/SO.
  - [x] NO REGRESSION: Direct native/fresh definedness fixture passes;12 assertions across two focused fixtures. Source/test syntax pass. Undef comparisons retain enabled legacy uninitialized warnings; no suppression/domain change or portable-null claim. No full suite/global scalar-slot audit.
  - [x] LOCKSTEP: Contract/shared source/Perl expected/test, six true/false worked receiver examples, canonical fact/map and task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis pass; Rust2 independent assessment next. New Perl canonical selection remains mandatory23.4.1; residual Dart mode assessment23.2.12 follows all five counterparts.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.12.1 - add Perl explicit String comparison receivers`.

  Additional live-doc defect / fix now: Catalog String summary439/441 still calls the four already-implemented predicate continuations outside scope/terminal, and Array summary669 still calls is_empty/is_nonempty terminal. These contradict23.3.9/.10/.11 implementations and their individual entries. Reconcile these exact summary lines and the formal grammar's explicit comparison-name paragraph with current scoped support; remove the unassessed membership-terminal generalization and give contains result assessment an explicit pending leaf23.2.13. No new runtime/contains behavior is claimed.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.12.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary str_eq/str_ne/str_gt/str_ge/str_lt/str_le receivers and compatible result handoff.
  Dependencies: .23.3.12.1.
  Acceptance: Frozen string-comparison-results.md through public native/generated routes; preserve actual producer kinds, existing null/scalar/Unicode/empty/source/copy domains and correct source/operand/result snapshots. One operand before effects, all six true/false pairs, source families/false retention/generic/bridges/scalar guards; small compile/direct checks/docs/commit. Numeric aliases, deferred/callable/full admission and declared Lua5.4 remain separate.

  Activation: clean `e227e9e8199527dc358e81c588c49afe210a5ef3`; Perl committed, brief empty/tree clean; post-commit pointer passed; identity derived from Git.
  Owned paths: Confirmed Rust ordinary six explicit String comparison receiver/result/shape gaps; public existing producer kind/null/text/order control, shared native/restored/plan regression and direct definedness compatibility, current docs.
  Verification tier: `focused`
  Focused checks: Public native free producer first, native/restored/generated-plan shared RED/GREEN with actual backend expectations, direct definedness fixture, targeted offline Cargo compilation/rustfmt and book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored preservation/regression values/order, no quantified population or portable measurement.

  Public existing producer / preservation: Native free control returns12 Boolean flags (sixtrue/sixfalse), five true null/empty/zero twins, null-resultfalse with SO order and false/default texts0!/0!. engine.rs existing str_* branch compares evaluated to_str() values and returns RuntimeValue::Bool. Keep this Bool/null/text behavior; shared Boolean expected variant differs from Perl only at raw flags. No producer or undefined-domain normalization is inferred.

  Shared baseline: Native producer control passes; receiver values are null beside six nested1!, rawBool flags correct, and24 malformed effects execute. Existing source/operand/result blocks already run1/1 calls in SOC order with final source null; null-source block orderSO also works. Register six names in String result-family, scalar-producer and one-operand preflight lists; no producer/snapshot repair or numeric alias change.

  Completion: Add six names to existing String-result/scalar-producer/one-operand lists. Existing Bool producers, to_str lexical/null compatibility, zero/false/default and correct source/operand/result snapshots remain unchanged; no parser/schema/numeric alias change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native free control confirms twelve Bool flags, null/empty/zero true twins, null-resultfalse/SO and false/default0!/0!. Shared receiver RED gives null beside nested1!, rawBool correct,24 malformed effects; existing1/1 source/operand calls and SOC/final-null already work.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs String result-family, scalar-result and one-operand lists omit six explicit comparison names. Existing helper branch compares evaluated to_str operands and returns RuntimeValue::Bool; no producer or snapshot defect inferred.
  - [x] FIX: Extend only the three method lists, using existing selected/dynamic consumer dispatch and scalar guards. Preserve literal/text/null/Unicode/source/copy domains and numeric aliases; no Bool-number normalization.
  - [x] ADDRESSED (verified): Native/restored/generated-plan exact Boolean shared JSON passes six true/false/raw-kind pairs, null/empty/zero twins, source families, retained0!/generic/bridges/scalar guards, twelve malformed no-effects and1!/SOC/once-only/final-null; null-source operand remains0!/SO. Free producer control stays passing.
  - [x] NO REGRESSION: Direct definedness result/producer fixtures pass; four targeted Rust tests with offline compilation/rustfmt. No broad suite/standalone emitted/full-domain/portable claim or Core/schema change.
  - [x] LOCKSTEP: Shared Boolean expected/test, contract/book/guide/formal grammar and canonical comparison fact/map align with task/live/resume. Predicate-arity prose is scoped to the above admitted families. Book/history/diff/final staged memory/cadence/diagnosis pass; Dart3 next after clean commit. Residual modes23.2.12/full admission/Perl registration23.4.1 remain separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.12.2 - add Rust explicit String comparison receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.12.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary str_eq/str_ne/str_gt/str_ge/str_lt/str_le receivers and compatible result handoff.
  Dependencies: .23.3.12.2.
  Acceptance: Frozen string-comparison-results.md through public native/generated routes; preserve actual producer kinds, existing null/scalar/Unicode/empty/source/copy domains and correct source/operand/result snapshots. One operand before effects, all six true/false pairs, source families/false retention/generic/bridges/scalar guards; small compile/direct checks/docs/commit. Numeric aliases, deferred/callable/full admission and declared Lua5.4 remain separate.

  Activation: clean `a9f7b0bb766934ba25fe0c4cc106d5df2486fe7d`; Rust committed, brief0/tree clean; identity derived from Git.
  Owned paths: Dart six explicit comparison receiver shape/scalar guards, independently assessed producer/null kinds, shared native/restored/plan regression and direct definedness compatibility/docs. Existing UTF-16 ordering stays scheduled under DART-STARTUP-READING.2.13; its unresolved portable consumer contract is outside this preservation slice.
  Verification tier: `focused`
  Focused checks: Public free producer control and shared native/restored/plan RED/GREEN, direct definedness fixture, selected-file fatal analysis/formatting, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored regression and preservation controls, no population or portable completeness measurement.

  Completion: Add six names only to existing one-operand preflight and scalar-producer lists. Existing Bool producers and null-propagating comparison remain unchanged. No Unicode ordering, numeric alias, parser/schema or snapshot change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public free producer control passes native/restored/plan with twelve Bool flags, null comparison results, empty/zero true twins, false/default0!/0! and eager SO. Shared RED has incompatible/after_text empty Arrays and24 malformed effects; other six pairs/source families and1!/SOC/once-only/final-null already work.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart ActionFluentChainExpr one-operand preflight and _evaluateFluentCallsWithValue mayProduceScalar omit six comparison names. _callStringCompareHelper already returns Bool for scalar operands and null for absent operands; preserve its domains. Known UTF-16 order remains DART2.13, not closed here.
  - [x] FIX: Extend only the two lists; add explicit Dart null-propagating golden variant based on observed public producer behavior, retaining Boolean identity.
  - [x] ADDRESSED (verified): Shared native/restored/generated-plan passes all six true/false pairs, raw kinds, empty/zero/null boundaries, source families, false/generic/bridges/scalar guards, twelve malformed no-effects,1!/SOC/source and operand once/final-null; null source remains null/SO.
  - [x] NO REGRESSION: Direct definedness result/producer checks pass; four focused Dart tests and selected-file fatal analysis/formatting pass. No broad suite, fresh emitted, full-domain or portable-null claim.
  - [x] LOCKSTEP: Current contract/shared Dart expected/test, catalog/guide/formal grammar, canonical fact/map and live/resume align. Correct stale Receiver-Dot summary of the already-implemented four String predicates to all five recorded hosts. Book/history/diff/final staged memory/cadence/diagnosis checked before commit; Julia4 follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.12.3 - guard Dart String comparison result receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.12.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary str_eq/str_ne/str_gt/str_ge/str_lt/str_le receivers and compatible result handoff.
  Dependencies: .23.3.12.3.
  Acceptance: Frozen string-comparison-results.md through public native/generated routes; preserve actual producer kinds, existing null/scalar/Unicode/empty/source/copy domains and correct source/operand/result snapshots. One operand before effects, all six true/false pairs, source families/false retention/generic/bridges/scalar guards; small compile/direct checks/docs/commit. Numeric aliases, deferred/callable/full admission and declared Lua5.4 remain separate.

  Activation: clean `d103e63ccf2dd9c3f3309bc37c3f5ad40ff3a991`; Dart committed/brief0/tree clean.
  Owned paths: Julia ordinary comparison shape/scalar guards, independently assessed actual producer kinds/null semantics, shared native/plan/fresh producer/result fixture and direct definedness/docs.
  Verification tier: `focused`
  Focused checks: Public free producer control first; shared native/plan/fresh RED/GREEN with explicit Bool identity, direct definedness, strict depwarn compilation, book/history/diff/final staged continuity checks.
  Canonical trigger: None for bounded ordinary implementation under director feature-first cadence; complete domain/portable admission23.4/final clean push separate.
  Claim verification: none: deterministic authored preservation/regression controls, no quantified population/portable measurement.

  Completion: Extend two existing one-operand/scalar-producer lists only. Producer Bool/null/zero/text behavior and snapshots stay unchanged; reuse the independently confirmed null-propagating expected variant, renamed .null.json with Dart consumer updated.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/plan/fresh free producers pass with12 Bool flags, null boundaries/null-result, empty/zero true twins, false/default0!/0! and eager SO. All three shared routes RED with incompatible/after_text empty Arrays and24 malformed effects;1!/SOC/once-only/final-null snapshots already work.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _evaluate_runtime_fluent_chain! omits six names from exactly-one-operand and may_produce_scalar lists. Existing _call_runtime_string_comparison returns Bool for defined scalar operands and nothing for null. Julia == alone accepts numeric lookalikes; raw flag assertions additionally require isa Bool.
  - [x] FIX: Add six names to the two guards; preserve producer/domain/numeric aliases and correct source/result capture. Register fixture in runtests.jl; no parser/schema change.
  - [x] ADDRESSED (verified): Native/generated-plan/fresh emitted exact shared case passes six pairs/raw kinds, source families, null/empty/zero, retained0!/generic/bridge/scalar guards, twelve malformed no-effects and1!/SOC/once-only/final-null; null source remains null/SO.
  - [x] NO REGRESSION: Twelve comparison and nine direct definedness assertions pass with strict depwarn compilation. Dart two comparison tests pass after shared expected rename. No broad suite/full-domain/portable admission claim.
  - [x] LOCKSTEP: Shared null expected/test/registration, contract, six worked book examples/support qualifiers, canonical fact/map and task/live/resume align; book/history/diff/final staged memory/cadence/diagnosis checked before commit. Lua5 follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.12.4 - guard Julia String comparison result receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.12.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary str_eq/str_ne/str_gt/str_ge/str_lt/str_le receivers and compatible result handoff.
  Dependencies: .23.3.12.4.
  Acceptance: Frozen string-comparison-results.md through public native/generated routes; preserve actual producer kinds, existing null/scalar/Unicode/empty/source/copy domains and correct source/operand/result snapshots. One operand before effects, all six true/false pairs, source families/false retention/generic/bridges/scalar guards; small compile/direct checks/docs/commit. Numeric aliases, deferred/callable/full admission and declared Lua5.4 remain separate.

  Activation: clean `71047c4791dddd79877a9c658fb161a4166e749c`; Julia committed, brief0/tree clean.
  Owned paths: Lua ordinary comparison terminal/scalar/shape dispatch, actual producer kind/null controls, shared native/plan/fresh and direct definedness fixtures/registration/docs. Known malformed native patterns remain excluded under LUA-STARTUP-READING.2.3; measured PUC5.5.1/LuaJIT do not establish declared5.4.
  Verification tier: `focused`
  Focused checks: Public free producer then shared native/plan/fresh RED/GREEN and direct definedness on both available hosts, source load checks, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded ordinary implementation under director feature-first cadence; full admission23.4/declared5.4/final clean push separate.
  Claim verification: none: deterministic authored preservation/regression controls, no population or portable completeness measurement.

  Completion: Remove the obsolete comparison-only terminal fence, mark its actual result scalar and include six names through existing is_string_comparison in one-operand preflight. Preserve Bool/null/zero/text producers, lexical domains and eager source/operand capture.
  Verification:
  - [x] REPRODUCE / ISSUE: Public free producer controls pass native/plan/fresh on PUC5.5.1/LuaJIT with twelve Bool flags, null propagation, empty/zero true twins, false/default0!/0! and SO. Shared RED yields terminal nulls beside nested1!,24 malformed effects and SO/sourcezzz because the fence suppresses consumer C.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua evaluate_fluent_calls rejects continued is_string_comparison, omits it from scalar producers; evaluate_expr fluent preflight omits its one-operand rule. Existing producer retains lexical Bool/null behavior; no source snapshot defect inferred from suppressed continuation.
  - [x] FIX: Remove the fence, reuse is_string_comparison in scalar/preflight guards and register a separate named fixture. No producer/parser/schema/numeric-alias change.
  - [x] ADDRESSED (verified): Native/plan/fresh exact .null.json passes on both hosts: six true/false/raw-Bool pairs, source families, null/empty/zero, retained0!/generic/bridge/scalar guards, twelve malformed no-effects and1!/SOC/once-only/final-null; null-source remains null/SO.
  - [x] NO REGRESSION: Direct definedness producer/result fixtures pass on both hosts; loadfile checks interpreter and named runner syntax. No known malformed native pattern executed; declared5.4/full-domain/portable admission remains separate.
  - [x] LOCKSTEP: Contract/book six examples/support and actual kind/null qualifications, canonical comparison fact/map and task/live/resume align. Qualify obsolete July Lua76/76 closeout as historical, preserving exact old record in Git; it is not current completeness or frontier. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Residual Dart mode assessment23.2.12 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.12.5 - continue Lua String comparison result receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.13`
  Status: `active` / bounded contains rollout; full admission23.4 separate
  Goal: Ordinary contains receiver/result handoff and coordinated required-needle guards under contains-results.md and FUTURE-PARITY-BACKLOG.5.6.
  Children: `.23.3.13.1`, `.23.3.13.2`, `.23.3.13.3`, `.23.3.13.4`, `.23.3.13.5`.
  Acceptance: Independently preserve actual producer kinds/equality/null/empty/source snapshots; implement compatible scalar/generic/explicit-container flow and one authored needle before effects. Normalize old four-backend missing-needle0 only under activated original owner5.6; update named punctuation-light tests and preserve both zero-argument twins. No free helper/equality/full-domain/deferred/portable admission inference.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.13.1`
  Status: `completed`
  Goal: Independently assess and implement Perl ordinary Array contains result handoff and required-needle guards.
  Dependencies: .23.2.13; coordinate original arity owner FUTURE-PARITY-BACKLOG.5.6.
  Acceptance: Frozen contains-results.md through public native/generated routes; actual kinds/equality/null/empty/source/eager snapshots unchanged. Hit/miss/false-retention/generic/bridge/scalar guards, source families and missing/extra no-effects, with both bare/parenthesized zero-arg aliases; update actual named calibration expectation after normalization. Small compile/direct checks/docs/commit; full domains/free signatures/portable admission and Lua declared5.4 remain separate.
  Immediate defect: Malformed contains nested in an Array currently emits raw items.contains() and fails an undefined host subroutine on native/fresh; eliminate this fallthrough with guard before effects. Valid free/nested/named source snapshots already work.

  Activation: clean `299a3f67a30b991aa07b1d38922d8582a321146d`; contains assessment/explicit FUTURE5.6 activation committed, brief0/tree clean.
  Owned paths: Perl contains ordinary result/scalar/shape routing and nested malformed host-call leak, shared native/fresh fixture and direct comparison compatibility/docs; producer/equality/snapshot semantics preserved.
  Verification tier: `focused`
  Focused checks: Public shared native/fresh RED/GREEN with existing producer values, direct String comparison fixture, source/test syntax and book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; complete domains/portable23.4 and mandatory Perl fixture selection23.4.1 separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Completion: Add contains only to global exactly-one-operand preflight and Array scalar-result return-family map. Existing numeric1/0 membership/equality/null/empty/zero/source snapshots remain unchanged. Global guard also removes malformed nested host-call/complex-block syntax fallthrough.
  Verification:
  - [x] REPRODUCE / ISSUE: Assessment public native/fresh producer/nested controls work while valid result chains lower undef. Shared RED produces native/fresh handler compilation errors from complex malformed bodies and raw contains fallthrough; no valid snapshot defect is inferred from wholly skipped receiver continuation.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering.pm global one-operand list and array_chain_return_family omit contains. The terminal classification rejects compatible later methods; malformed nested operands can fall through source text rather than a complete null expression. Existing free producer captures source before needle and computes before consumer.
  - [x] FIX: Extend only the two lists, using existing dynamic scalar/result dispatch and preflight. No producer/parser/schema/equality/free-arity change. Required receiver policy follows activated FUTURE5.6; Perl direct baseline already rejected missing/extra.
  - [x] ADDRESSED (verified): Native/fresh exact shared numeric JSON passes hit/miss/raw kinds, empty/null/zero, literal/named/selected/split/concat/Hash/function/default/copied Arrays, false retention/generic/bridge/scalar guards,1!/SOC/once-only/final-null. Missing bare/parenthesized and extra no-effects now work inside Arrays too, without host calls or compile failures.
  - [x] NO REGRESSION: Direct String comparison fixture passes;12 assertions/two files and source/test syntax pass. Existing enabled undef-comparison warnings remain. No broad suite/full domain/portable admission.
  - [x] LOCKSTEP: Shared source/Perl expected/test, contract/book/guide, canonical contains/arity facts/map and TYPE/FUTURE5.6/index/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Rust2 independent producer/calibration assessment next; new Perl fixture selection remains mandatory23.4.1.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.13.1 - continue Perl Array contains results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.13.2`
  Status: `completed`
  Goal: Independently assess and implement Rust ordinary Array contains result handoff and required-needle guards.
  Dependencies: .23.3.13.1; coordinate original arity owner FUTURE-PARITY-BACKLOG.5.6.
  Acceptance: Frozen contains-results.md through public native/generated routes; actual kinds/equality/null/empty/source/eager snapshots unchanged. Hit/miss/false-retention/generic/bridge/scalar guards, source families and missing/extra no-effects, with both bare/parenthesized zero-arg aliases; update actual named calibration expectation after normalization. Small compile/direct checks/docs/commit; full domains/free signatures/portable admission and Lua declared5.4 remain separate.

  Activation: clean `45d7c13869dd94cb54b3bdd58ef74e8f3c1944d5`; Perl committed, brief0/tree clean.
  Owned paths: Rust contains ordinary result/scalar/required-needle dispatch, independent public producer kind/equality/snapshot control, native/restored/plan shared and named punctuation-light calibration, direct comparison/docs. FUTURE5.6 explicitly authorizes missing0-to-null receiver normalization; no free/equality policy changes.
  Verification tier: `focused`
  Focused checks: Native public producer and shared RED/GREEN, native/restored/plan result/shape/source fixtures, exact named punctuation-light required-needle test, direct comparison, targeted offline Cargo compilation/rustfmt, book/history/diff/final staged continuity checks.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/equality/portable23.4/final push separate.
  Claim verification: none: deterministic authored preservation/regression controls, no population/completeness measurement.

  Newly confirmed producer defect / fix now: Public native producer raw flags are numeric[1,0,0,1,1,1,1,1,1] (null/empty membership merges unlike Perl); named items=[a], needle rebinds items=[z], returns0 instead of captured1/O/[z]. engine.rs contains calls array_consuming_arg after all arguments: that helper prefers current ctx binding over evaluated get_bare_value snapshot. Use the already-evaluated contains source only, preserving actual equality/kinds. Own source-null rebound control and native/restored/plan producer regression here. Other aggregate-consuming re-read seams and null/empty reference mismatch are assessed immediately after rollout by23.2.14, coordinated with original helper-caveat owner FUTURE5; no unexecuted sibling failure is claimed.

  Completion: Add contains to existing scalar-result/one-operand lists and consume its already-evaluated typed source in the producer instead of re-reading context after the needle. Preserve numeric1/0 and existing text equality/null-empty compatibility. Update named missing-needle calibration to null with identical bare/parenthesized results under FUTURE5.6.
  Verification:
  - [x] REPRODUCE / ISSUE: Native producer RED shows raw numeric[1,0,0,1,1,1,1,1,1], correct0!/default0!, but named source changed by needle returns0/O/[z] instead of captured1. Shared RED is terminal nulls beside nested1!, five malformed effects, missing twins0/0, stopped consumer SO/source[z]. No block-source snapshot defect is inferred from the stopped continuation.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs scalar/one-operand lists omit contains. Its producer calls array_consuming_arg, which replaces evaluated args[0] with a current named binding after needle evaluation; Expr::Variable already captured typed get_bare_value. Numeric text equality merges undef/empty; preserve it in this feature slice and own reference reconciliation23.2.14 immediately after rollout.
  - [x] FIX: Extend the two lists; contains consumes args.first() as Array and returns0 for other actual kinds, preserving the captured source/null rather than reading later bindings. Update actual named punctuation-light test from old0 to null; no AST/parser/schema/free-arity/equality changes.
  - [x] ADDRESSED (verified): Native/restored/generated-plan producer and shared .rust.json pass: actual raw kinds/null-empty compatibility, rebound Array snapshot1/O/[z], absent-source snapshot0/O/[a], hit/miss/source families, false/generic/bridge/scalar guards, missing/extra and both missing aliases null/no-effects,1!/SOC/once-only/final-null.
  - [x] NO REGRESSION: Two contains, two direct comparison tests and exact named punctuation-light resolution test pass (five focused Rust tests) with offline Cargo compilation/rustfmt. No broad suite, standalone emitted/full equality/domain/portable admission.
  - [x] LOCKSTEP: Shared Rust expected/producer/result test and calibration, contract/book/guide, canonical contains/arity facts/map and TYPE/FUTURE5.6/index/live/resume align; newP1 .23.2.14 owns actual null-empty reference mismatch and unassessed sibling re-read seams. Book/history/diff/final staged memory/cadence/diagnosis checked before commit; Dart3 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.13.2 - capture Rust contains sources and continue results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.13.3`
  Status: `completed`
  Goal: Independently assess and implement Dart ordinary Array contains result handoff and required-needle guards.
  Dependencies: .23.3.13.2; coordinate original arity owner FUTURE-PARITY-BACKLOG.5.6.
  Acceptance: Frozen contains-results.md through public native/generated routes; actual kinds/equality/null/empty/source/eager snapshots unchanged. Hit/miss/false-retention/generic/bridge/scalar guards, source families and missing/extra no-effects, with both bare/parenthesized zero-arg aliases; update actual named calibration expectation after normalization. Small compile/direct checks/docs/commit; full domains/free signatures/portable admission and Lua declared5.4 remain separate.

  Activation: clean `b29781fb5ac3afb0a4339b2d560a838525ccdf7a`; Rust committed, brief0/tree clean.
  Owned paths: Dart contains receiver/scalar/required-needle guards, independently observed actual producer kinds/null/equality/source snapshots, native/restored/plan shared/direct comparison and named punctuation-light calibration/docs. FUTURE5.6 explicitly authorizes missing0-to-null; equality reconciliation23.2.14 remains next after rollout.
  Verification tier: `focused`
  Focused checks: Public native/restored/plan producer and shared RED/GREEN, direct comparison, exact named punctuation-light required-needle test, selected-file fatal analysis/formatting, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; complete equality/domain/portable23.4/final push separate.
  Claim verification: none: deterministic authored preservation/regression controls, no population/completeness measurement.

  Completion: Add contains only to existing one-operand preflight and scalar-producer lists. Preserve numeric1/0, actual null/empty merging and already-correct named/source-null snapshots. Update exact named missing-needle calibration to null/no-effects with identical aliases under FUTURE5.6.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/restored/plan producer passes before code changes: numeric raw[1,0,0,1,1,1,1,1,1], named rebound1/O/[z], absent-source0/O/[a], false/default0!/0!. Shared RED has incompatible/after_text empty Arrays, five malformed effects and missing twins0/0; valid hit/miss/source families and1!/SOC/once-only/final-null already work.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart ActionFluentChainExpr exactly-one-operand and _evaluateFluentCallsWithValue mayProduceScalar lists omit contains. _callArrayContains already consumes the captured List and returns numeric flags; nullAsEmpty comparison matches Rust but differs from Perl. No Dart producer/snapshot repair needed; actual equality mismatch added to P1 assessment23.2.14.
  - [x] FIX: Extend two lists and update actual named punctuation-light expectation from0 to null, retaining identical bare/parenthesized behavior. Rename shared .rust.json to .text.json after independent Dart agreement; update Rust include and rerun its focused consumers. No parser/schema/free-signature/equality changes.
  - [x] ADDRESSED (verified): Native/restored/plan producer/shared pass numeric/raw/null/empty/zero, source families, false/generic/bridge/scalar guards, missing/extra and both missing aliases null/no-effects,1!/SOC/once-only/final-null.
  - [x] NO REGRESSION: Direct comparison and exact named alias checks pass (five Dart tests), selected-file fatal analysis/formatting pass; two Rust contains tests pass after shared expected rename. No broad suite/full-domain/portable admission.
  - [x] LOCKSTEP: Shared text expected/Dart producer/result test/calibration, contract/book/guide, current contains/arity/Dart array facts/map and TYPE/FUTURE5.6/index/live/resume align. Correct stale generic Dart fact calling already-implemented numeric reducers terminal. Book/history/diff/final staged memory/cadence/diagnosis checked before commit; Julia4 next with explicit numeric-kind guards.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.13.3 - guard Dart Array contains result receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.13.4`
  Status: `completed`
  Goal: Independently assess and implement Julia ordinary Array contains result handoff and required-needle guards.
  Dependencies: .23.3.13.3; coordinate original arity owner FUTURE-PARITY-BACKLOG.5.6.
  Acceptance: Frozen contains-results.md through public native/generated routes; actual kinds/equality/null/empty/source/eager snapshots unchanged. Hit/miss/false-retention/generic/bridge/scalar guards, source families and missing/extra no-effects, with both bare/parenthesized zero-arg aliases; update actual named calibration expectation after normalization. Small compile/direct checks/docs/commit; full domains/free signatures/portable admission and Lua declared5.4 remain separate.

  Activation: clean `10e1005299b9a3b24ecdc08870b3046bbd5a22cd`; Dart committed, brief0/tree clean.
  Owned paths: Julia contains scalar/required-needle receiver guards, independent producer numeric-kind/equality/source controls, native/plan/fresh shared and direct comparison/calibration/registration/docs. FUTURE5.6 explicitly authorizes missing0-to-null; P1 equality/sibling snapshots23.2.14 stays next after rollout.
  Verification tier: `focused`
  Focused checks: Public native/plan/fresh producer and shared RED/GREEN with explicit Number/not-Bool raw identity, direct comparison and small changed punctuation-light fixture, strict depwarn compilation, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full equality/domain/portable23.4/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Completion: Add contains only to existing one-operand and scalar-producer lists; update actual small punctuation-light calibration to null with identical aliases under FUTURE5.6. Preserve numeric1/0, actual null/empty text-key equality and already-correct source snapshots; no producer/parser/schema/free-signature change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/plan/fresh producer and explicit Number/not-Bool checks already pass: numeric raw[1,0,0,1,1,1,1,1,1], named rebound1/O/[z], absent-source0/O/[a], false/default0!/0!. Three shared REDs show incompatible/after_text empty Arrays, five malformed effects and missing twins0/0; valid source families and1!/SOC/once-only/final-null already work.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _evaluate_runtime_fluent_chain! omits contains from one-operand and may_produce_scalar lists. _call_runtime_array_contains already consumes captured values and returns numeric1/0; null_as_empty merges null/empty as Rust/Dart do. Julia == accepts Bool-number lookalikes, so raw result checks explicitly reject Bool.
  - [x] FIX: Extend two guard lists, register the new fixture and update the actual missing-needle calibration from0 to nothing; both spellings stay equal. Existing .text.json independently agrees with Julia. No source/equality normalization; actual null/empty reference mismatch joins P1 .23.2.14.
  - [x] ADDRESSED (verified): Native/generated-plan/fresh emitted producer/shared passes raw numeric identity/null/empty/zero, source families, false/generic/bridge/scalar guards, missing/extra and both missing aliases null/no-effects,1!/SOC/once-only/final-null.
  - [x] NO REGRESSION: Twelve membership and twelve direct comparison assertions plus55 in the small changed punctuation-light fixture pass with strict depwarn compilation. No full suite, broad equality/domain/portable admission.
  - [x] LOCKSTEP: Shared text expected/Julia test/registration/calibration, contract/book/guide, compact current contains/arity/Julia array facts/map and TYPE/FUTURE5.6/index/live/resume align. Correct stale generic Julia fact calling already-implemented numeric reducers terminal. Book/history/diff/final staged memory/cadence/diagnosis checked before commit; Lua5 next, excluding known malformed native regexes.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.13.4 - guard Julia Array contains result receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.13.5`
  Status: `completed`
  Goal: Independently assess and implement Lua ordinary Array contains result handoff and required-needle guards.
  Dependencies: .23.3.13.4; coordinate original arity owner FUTURE-PARITY-BACKLOG.5.6.
  Acceptance: Frozen contains-results.md through public native/generated routes; actual kinds/equality/null/empty/source/eager snapshots unchanged. Hit/miss/false-retention/generic/bridge/scalar guards, source families and missing/extra no-effects, with both bare/parenthesized zero-arg aliases; update actual named calibration expectation after normalization. Small compile/direct checks/docs/commit; full domains/free signatures/portable admission and Lua declared5.4 remain separate.

  Activation: clean `7bb011b4eea5129faf334a57c50871d695ffb92c`; Julia committed, brief0/tree clean.
  Owned paths: Lua ordinary contains scalar/required-needle dispatch, independently assessed producer kinds/equality/source captures, shared native/plan/fresh and direct comparison/named punctuation-light calibration/registration/docs. FUTURE5.6 authorizes missing0-to-null; available PUC5.5.1/LuaJIT only, declared5.4 remains LUA2.2. Known malformed native patterns stay excluded under LUA2.3.
  Verification tier: `focused`
  Focused checks: Public native/plan/fresh producer/shared RED/GREEN and direct comparison on both hosts, exact safe named punctuation-light calibration, source/runner load checks, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full equality/domain/portable23.4/declared5.4/final push separate.
  Claim verification: none: deterministic authored preservation/regression controls, no population/completeness measurement.

  Completion: Add contains only to existing Array scalar-producer and one-operand preflight lists; update the actual named punctuation-light missing expectation0->json.null and register a separate shared fixture. Existing numeric flags/text-key equality/source snapshots remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/plan/fresh free producers pass on both hosts before changes: numeric raw[1,0,0,1,1,1,1,1,1], rebound Array1/O/[z], absent-source0/O/[a], false/default0!/0!. Shared RED has incompatible/after_text empty Arrays, five malformed effects and missing twins0/0; valid source families and1!/SOC/once-only/final-null already work.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua evaluate_fluent_calls marks join/index scalars but omits contains; evaluate_expr preflight omits its one-needle rule. evaluate_array_helper already returns numeric1/0 from captured Array values and scalar_array_key null-as-empty text comparison. No producer/snapshot repair needed; confirmed Lua null/empty mismatch joins P1 .23.2.14.
  - [x] FIX: Extend only those two lists; named alias expectation now null under FUTURE5.6. Both terminal zero-argument spellings reject identically before effects. No producer/parser/schema/free-signature/equality change.
  - [x] ADDRESSED (verified): Native/plan/fresh exact .text.json passes on PUC5.5.1/LuaJIT: raw numeric/null/empty/zero, source families, retained false/generic/bridges/scalar guards, missing/extra and both missing aliases null/no-effects,1!/SOC/once-only/final-null.
  - [x] NO REGRESSION: Direct comparison producer/result fixtures and exact named punctuation-light contract pass on both hosts; source/runner load checks pass. Only the named safe contract is selected from run.lua; no malformed native pattern/full suite/declared5.4/full domain/portable admission executed or inferred.
  - [x] LOCKSTEP: Shared Lua fixture/registration/actual calibration, contract/book/guide, current contains/arity/Lua selection facts/map and TYPE/FUTURE5.6/index/live/resume align. Historical July93/93 is qualified and full unsafe reverify replaced by this safe changed surface; no historical version evidence reclassified as current. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. P1 .23.2.14 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.13.5 - guard Lua Array contains result receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14`
  Status: `active` / six bounded repairs targeted-checked; full admission23.4 separate
  Goal: Implement frozen aggregate-null-and-snapshot-contract.md under original helper-caveat owner FUTURE-PARITY-BACKLOG.5.7.
  Children: `.23.3.14.1`, `.23.3.14.2`, `.23.3.14.3`, `.23.3.14.4`, `.23.3.14.5`, `.23.3.14.6`.
  Acceptance: Cached pure aggregate value operands; eager Perl has_key key effects; null distinct from empty in contains/index_of/uniq, original kinds/first occurrence/source snapshots retained. Preserve existing defined-scalar coercion, malformed arity, invalid-kind fallback, target mutation and lazy controls; bounded per-backend commits/quick checks. Full domain/portable admission remains23.4.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14.1`
  Status: `completed`
  Goal: Repair Rust aggregate-consuming named-source snapshots.
  Dependencies: .23.2.14; original helper owner FUTURE-PARITY-BACKLOG.5.7.
  Intake: Rust source re-read is confirmed on all three carriers; contains already has a local fix. Mutation-target resolvers and lazy helpers stay untouched.
  Acceptance: Use cached typed get_bare_value arguments in array_consuming_arg/hash_consuming_arg; preserve existing named wrong-kind/absent empty-container fallback without reading later ctx bindings. Public native/restored/plan index/has_key/append/merge and literal/null/concat controls plus direct contains/index/has_key/uniform checks; no null equality change. Small compile/changed-surface/direct checks/docs/commit under feature-first cadence; complete domain/context/admission remains23.4.

  Activation: clean `97faac2f753201be9a7c13753a86ad4c86864951`; aggregate/null freeze and original FUTURE5.7 activation committed, brief0/tree clean.
  Owned paths: Rust private aggregate-consuming value adapters, public native/restored/plan named source/append/merge/null snapshot regression, named valid/missing/wrong-kind defaults and direct contains/index/has_key/uniform checks/docs. Preserve null-key merging until14.3 and all target/lazy resolvers.
  Verification tier: `focused`
  Focused checks: Retained public source/native/restored/plan RED/GREEN plus named fallback controls, direct contains/index/has_key tests and one typed-constructor uniform control, offline compilation/rustfmt, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded existing value-contract repair under director feature-first cadence; complete domains/context/portable23.4 separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Baseline compatibility control: Initial empty-Array expectation for flat_hash(wrong/undef) was incorrect; actual pre-change output is empty Hash{}. Pin that observed shape instead, without normalizing its existing context-sensitive/invalid-domain behavior owned by FUTURE5. Main snapshot RED independently distinguishes stale sources; the fallback control guards against widening this fix into raw-kind normalization.

  Completion: Replace live ctx reads in the two aggregate value adapters with already-evaluated typed arguments. Named wrong-kind/absent inputs still yield the prior empty Array/Hash fallback, preserving flat_hash’s observed empty Hash{} compatibility; nonvariable/literal inputs stay unchanged. Target/lazy resolvers and null-key equality untouched.
  Verification:
  - [x] REPRODUCE / ISSUE: Retained public probes and snapshot fixture RED on native/restored/plan: named index null instead of0, has_key0 instead of1, appended index1 instead ofnull, merge{z,b} instead of{a,b}, absent source result replaced by later binding. Concat control already works. Fallback baseline control passes separately before production after correcting an unproved Array[] expectation to actual Hash{}.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs array_consuming_arg/hash_consuming_arg prefer current ctx named storage after all operands, replacing cached args. runtime.rs get_bare_value already captures typed Array/Hash clones. Preserve the old raw-variable wrong-kind empty fallback but never inspect later bindings; other mutation-target and lazy protocols use separate resolvers.
  - [x] FIX: Both adapters return captured typed arguments, with only the prior named non-container fallback synthesized as empty. Keep call signatures/private context parameter unused, avoiding unrelated caller edits. No parser/schema/free signature/equality/target changes.
  - [x] ADDRESSED (verified): Native/restored/plan exact expected source controls now return index0/has_key1, absent indexnull/has_key0 despite later rebinding, appended indexnull and merged{a,b}; source mutations remain visible in separate after fields. Literal/concat/null controls and named first/last/copy/sorted/default/flat_hash shapes pass. Existing null/empty merging is intentionally unchanged for14.3.
  - [x] NO REGRESSION: Two snapshot/fallback tests, two direct contains, one index, one has_key and one retained typed-constructor uniform control pass (seven focused Rust tests), offline compilation/rustfmt. No full suite/standalone emitted/full domain/portable admission.
  - [x] LOCKSTEP: Retained source/shared Rust expected/test, current book free index/has_key/merge examples, canonical source/null fact/map and TYPE/FUTURE5.7/index/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit; Perl key14.2 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.14.1 - preserve captured Rust aggregate operands`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14.2`
  Status: `completed`
  Goal: Evaluate Perl has_key key after captured null sources.
  Dependencies: .23.3.14.1; original helper owner FUTURE-PARITY-BACKLOG.5.7.
  Intake: Public dump shows typed and legacy key expression nested inside defined(hash), suppressing valid key effects on a null source; result remains0 while key mutations must run once.
  Acceptance: Move key evaluation before source-validity ternary in typed/legacy ordinary lowering, preserving source snapshot/output kinds/domain/warnings and one-key guard. Native/fresh source-null/effect/valid source/malformed and direct has_key/contains checks. Small compile/changed-surface/direct checks/docs/commit under feature-first cadence; complete domain/context/admission remains23.4.

  Activation: clean `03ceddd1f251f41a1de9bc82d3f6b71fc027e39a`; Rust cached-source repair committed, brief0/tree clean.
  Owned paths: Perl typed/legacy has_key value lowering key temporaries, public native/fresh source-null/absent/effect/valid source/shape fixture and direct has_key/contains checks/docs. Source/output kinds/free arity and key domain remain unchanged.
  Verification tier: `focused`
  Focused checks: Public Get/substitution/dump source-null RED/GREEN, shared native/fresh key ordering/once-only/source/result snapshot fixture, direct has_key/contains fixtures, source/test syntax and book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded existing ordinary evaluation-contract repair under director feature-first cadence; complete contexts/domains/portable23.4 separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Completion: In typed and legacy conditional has_key value builders, capture source then key in separate lexical temporaries before defined(source)/exists. Null-source output stays numeric0, with key effects no longer suppressed. Key expressions remain untouched and evaluated once; no source/key domain/coercion/arity change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public dump located key in the defined(hash) ternary. After correcting a new fixture filename setup error (not semantic RED), native/fresh regression genuinely fails key effects: free/literal/missing calls stay0, source bindings remainnull, receiver orderSC/keycalls0. Valid/empty source controls and malformed guards already pass.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering.pm typed4501/4511 and legacy6840/6863 emit key inside exists on the true branch of defined(source). The existing source-then-key ordinary value contract requires key evaluation before this presence decision, including null/missing sources.
  - [x] FIX: Add one key temporary to each conditional builder and use that value in exists; source captured first, presence tested last. No try/catch or key rewriting, so actual operand behavior is retained. Existing named direct-hash branch already evaluates key and is unchanged.
  - [x] ADDRESSED (verified): Native/fresh exact expected passes free/literal/absent/null-source key once and binding effects, receiver0!/SKC/source1/key1, valid captured-source1/SK and empty-source0 despite later binding creation. Missing/extra receiver calls remain null with zero effects.
  - [x] NO REGRESSION: Direct has_key and contains fixtures pass;18 assertions across three focused files, source/test syntax pass. Both builders are updated; no claim of exhaustive independent legacy-route, exception, full-domain or portable admission.
  - [x] LOCKSTEP: New source/expected/test, frozen contract/current book example and canonical source/null fact/map align with TYPE/FUTURE5.7/index/live/resume. Book/history/diff/final staged memory/cadence/diagnosis checked before commit; Rust null-key14.3 next. Mandatory Perl fixture registration23.4.1 remains open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.14.2 - evaluate Perl has_key keys before source guards`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14.3`
  Status: `completed`
  Goal: Distinguish Rust null Array comparison and uniqueness keys.
  Dependencies: .23.3.14.2; original helper owner FUTURE-PARITY-BACKLOG.5.7.
  Intake: Public membership/index/uniq null-empty reference mismatch is confirmed; raw numeric flags and first value/kind/order stay unchanged.
  Acceptance: Preserve defined to_str conversion, but null matches only null in contains/index_of and has its own uniq key. Native/restored/plan literals/variables/receivers/nested consumers and existing contains expected updates; source adapters from1 stay correct. Small compile/changed-surface/direct checks/docs/commit under feature-first cadence; complete domain/context/admission remains23.4.

  Activation: clean `d90c6d5634a39a1affd174d56ca156b21186395d`; Perl key evaluation committed, brief0/tree clean.
  Owned paths: Rust private null-distinct Array keys for contains/index_of/uniq, retained reference native/fresh producer and native/restored/plan primitive/position/value/receiver/standalone/inter-type regressions, intentional current contains/snapshot expected updates/docs. Existing defined to_str/free-default/arity/source/value-kind semantics stay unchanged.
  Verification tier: `focused`
  Focused checks: Public Perl reference native/fresh and Rust native/restored/plan RED/GREEN, direct contains/index/snapshot fixtures, offline compilation/rustfmt and book/history/diff/final staged continuity guards. No broad equality/full suite.
  Canonical trigger: None for bounded existing reference-contract repair under director feature-first cadence; complete source/domain/context/portable23.4 separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Completion: Add private collision-free Option<String> Array key projection: Undef=None, every defined value retains Some(to_str). Use it only in contains/index_of/uniq, preserving raw numeric flags, index/null outputs, first original value/kind/order and standalone writeback. Missing free needles retain the old empty-text default branch; receiver arity/source adapters unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: New shared fixture passes six Perl native/fresh reference assertions. Rust RED merges null/empty, picks index0 where1 is correct, drops empty in value/receiver/standalone uniq, returns1!/numeric3/fallback1/count3 instead of0!/2/8/4. Input values, last numeric value and NC/one-needle control already work.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs contains/index_of compare to_str and uniq inserts to_str keys, making Undef and empty text indistinguishable. A typed internal absent key separates null from every String without changing public RuntimeValue or any defined conversion.
  - [x] FIX: Add array_scalar_key and use projected keys in three helpers; keep absent free-helper legacy matching explicit. Update current contains producer/shared expected to Perl reference and snapshot expected membership/index/uniq fields, intentionally replacing the old null-merging expectations. No global to_str/parser/schema/arity/source/target changes.
  - [x] ADDRESSED (verified): Native/restored/plan shared null keys pass mixed positions, empty/missing/defined number-string and bool controls, raw kinds/first values/source nonmutation, value/receiver/standalone uniq, false retention, numeric result2, absent/found index consumers8/2, count4/last4 and NC/one needle. Contains and aggregate snapshot consumers now agree with the selected reference; captured sources/fallbacks remain passing.
  - [x] NO REGRESSION: Six focused Rust tests across null/contains/index/snapshot fixtures with offline compilation/rustfmt, plus six independent Perl reference assertions and source/test syntax pass. No full suite, general strict/container/callable equality, free-signature normalization or portable admission.
  - [x] LOCKSTEP: Shared reference source/expected/test and Rust consumer updates, frozen contract/current scoped book examples, canonical contains/source-null facts/map and TYPE/FUTURE5.7/index/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Dart14.4 independent index/uniq assessment next; new Perl reference fixture selection remains mandatory23.4.1.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.14.3 - distinguish Rust null Array comparison keys`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14.4`
  Status: `completed`
  Goal: Distinguish Dart null Array comparison and uniqueness keys.
  Dependencies: .23.3.14.3; original helper owner FUTURE-PARITY-BACKLOG.5.7.
  Intake: Contains null/empty merging confirmed; index/uniq still require public controls. No new producer defect inferred before assessment.
  Acceptance: Independently assess index/uniq against public Perl authority, preserve defined conversions, implement null-only matching/own uniq key and current contains fixture expectations. Native/restored/plan and direct small checks/fatal analysis. Small compile/changed-surface/direct checks/docs/commit under feature-first cadence; complete domain/context/admission remains23.4.

  Activation: clean `2fedae957ba9a5e6765a2d7780976bf5c768b218`; Rust null-key child committed, brief0/tree clean.
  Owned paths: Dart contains/index_of/uniq null-distinct keys, shared-reference and defined-conversion preservation tests, current contains expected updates and synchronized book/facts/task/live docs.
  Verification tier: `focused`
  Focused checks: Native/restored/plan RED/GREEN, direct contains/index/standalone transforms, fatal analysis/format and book/history/staged continuity guards.
  Canonical trigger: None for this bounded reference-contract repair under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions and preservation controls; no population/completeness measurement.

  Completion: A private const Object token distinguishes actual null from every defined String key and unsupported/nonfinite projection. contains/index_of retain each defined scalar projection; uniq keeps its existing fallback-to-empty projection, copied first values/kinds and source order. No user String can collide with the token.
  Verification:
  - [x] REPRODUCE / ISSUE: Dart native shared-reference RED shows merged membership, wrong index0, lost empty uniq entries, 1!/numeric3/default1/count3. Null versus defined-container projection RED is[1,1,0,0,[[]]] instead of[0,0,null,null,[[],null]]. Independent defined conversion/free-missing controls already pass native/restored/plan.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart _callArrayContains/_callIndexOf compare _scalarString(nullAsEmpty:true), while _callUniq stores that projection with empty fallback. Null, empty and defined containers all project to empty. Actual-null token separation fixes only the selected reference defect without redefining defined-container or numeric/Bool comparisons.
  - [x] FIX: Private _arrayScalarKey token projection used in three helpers; preserve defined conversion and uniqueness fallback, result kinds, copied values, source capture and free defaults. Existing contains raw/shared expected intentionally switches from old text merging to selected Perl reference. No parser/schema/arity/global conversion changes.
  - [x] ADDRESSED (verified): Three new native/restored/plan tests pass shared positions/null/empty/number-string/Bool controls, value/receiver/standalone uniq, original source/kinds/order, numeric/default/count/last/text consumers and NC/one needle. Null stays distinct from defined-container projections; old defined-only comparison/uniq/free-default controls stay passing.
  - [x] NO REGRESSION: Nine tests across null keys/direct contains/index/standalone transforms pass with compilation, format and fatal analysis of changed runtime/tests. No exhaustive suite, strict equality policy or full context/portable admission.
  - [x] LOCKSTEP: Shared reference/current contains selection, scoped catalog examples, aggregate contract and contains/source-null facts/map, TYPE/FUTURE5.7/index/live/resume align; book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia14.5 follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.14.4 - distinguish Dart null Array comparison keys`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14.5`
  Status: `completed`
  Goal: Distinguish Julia null Array comparison and uniqueness keys.
  Dependencies: .23.3.14.4; original helper owner FUTURE-PARITY-BACKLOG.5.7.
  Intake: Contains null/empty merging confirmed; index/uniq still require public controls. Preserve copied values and current source effects.
  Acceptance: Independently assess index/uniq, preserve defined conversions, implement null-only matching/own uniq key and current contains expectations with explicit Number/not-Bool guards. Native/plan/fresh strict small checks. Small compile/changed-surface/direct checks/docs/commit under feature-first cadence; complete domain/context/admission remains23.4.

  Activation: clean `167ce311bad3f497bd500c775a401cc7cc2517eb`; Dart null child committed, brief0/tree clean.
  Owned paths: Julia null-distinct contains/index_of/uniq keys, retained native/plan/fresh shared and defined-projection controls, fixture registration, current contains expected and book/facts/task/live docs.
  Verification tier: `focused`
  Focused checks: Public native/plan/fresh RED/GREEN with explicit Number/not-Bool guards, direct contains/index/standalone transforms, strict compilation and book/history/staged continuity guards.
  Canonical trigger: None for bounded reference-contract repair under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Completion: Private (actual-null tag, prior scalar text) keys distinguish null without changing defined projections. contains/index_of compare tagged keys; uniq keeps its old empty fallback in a typed (Bool,String) key and preserves copied first values/kinds/order. No user String sentinel can collide.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Julia native/plan/fresh RED returns merged membership, index0 instead of1, lost empty values in all uniq forms, 1!/numeric3/default1/count3. Null/container projection RED[1,1,0,0,[[]]] versus[0,0,null,null,[[],null]]. Defined-only/free-missing control passes before production changes. RED also exposed a test length-assumption error after lost entries; guard that assertion so it reports shape safely.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _call_runtime_array_contains/index_of compare _runtime_scalar_string(null_as_empty=true); uniq inserts the same projection with empty fallback into Set{String}. The actual-null tag separates null while retaining every defined key and uniqueness fallback.
  - [x] FIX: Add private tuple projection; compare it in two helpers, use typed tagged String keys in uniq. Intentionally select Perl reference in current contains producer/shared expected. Register the new retained fixture in runtests.jl. No parser/schema/global conversion/arity/source or free-default change.
  - [x] ADDRESSED (verified):36 new native/plan/fresh assertions pass shared positions/null/empty/number-string/Bool controls, value/receiver/standalone uniq, original source/kinds/order, numeric/default/count/last/text consumers and NC/one needle. Explicit Number/not-Bool guards reject Boolean lookalikes; null stays separate from defined containers while their old projection remains.
  - [x] NO REGRESSION:63 strict focused assertions across null keys/direct contains/index/standalone transforms pass with package precompilation and depwarn=error. No full suite, general equality or complete domain/context/portable admission.
  - [x] LOCKSTEP: Shared/current reference selection, catalog examples, aggregate contract and contains/source-null facts/map, TYPE/FUTURE5.7/index/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Lua14.6 safe named PUC/JIT fixtures follow; declared5.4 admission stays separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.14.5 - distinguish Julia null Array comparison keys`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14.6`
  Status: `completed`
  Goal: Distinguish Lua null Array comparison and uniqueness keys.
  Dependencies: .23.3.14.5; original helper owner FUTURE-PARITY-BACKLOG.5.7.
  Intake: Contains null/empty merging confirmed; index/uniq still require controls. Known malformed native patterns remain excluded; declared5.4/full admission separate.
  Acceptance: Independently assess index/uniq, preserve defined conversions, implement null-only matching/own uniq key and current contains expectations. Native/plan/fresh/direct checks on PUC5.5.1/LuaJIT, safe named fixtures only. Small compile/changed-surface/direct checks/docs/commit under feature-first cadence; complete domain/context/admission remains23.4.

  Activation: clean `e49ecee4bb0d7f4304f549930514cda1c315ace3`; Julia null child committed, brief0/tree clean.
  Owned paths: Lua null-distinct scalar_array_key helper, shared/native-plan-fresh and defined-projection/free-default controls, safe fixture registration/current contains expected and synchronized book/facts/task/live docs.
  Verification tier: `focused`
  Focused checks: Independent safe public native/plan/fresh RED/GREEN and direct contains/index on available PUC5.5.1/LuaJIT, source/runner load checks and book/history/staged continuity guards.
  Canonical trigger: None for bounded reference-contract repair under director feature-first cadence; malformed native patterns excluded, declared5.4/full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls; no population/completeness measurement.

  Completion: scalar_array_key returns the existing json.null token for actual null before the unchanged defined scalar-to-text/fallback conversion. Its shared contains/index_of/uniq consumers now distinguish null without a String marker collision; output kinds/first copied values/order/free defaults stay unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent public PUC5.5.1/LuaJIT native RED confirms mixed null/empty membership, wrong index0, lost empty in value/receiver/standalone uniq, 1!/numeric3/default1/count3. Null-container RED[1,1,0,0,[[]]] versus[0,0,null,null,[[],null]]. Defined-only/free-default controls pass all three routes before production.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua scalar_array_key unconditionally uses scalar_string(value,true) or empty; json.null, empty and defined containers collapse. The existing opaque null token is a safe table key distinct from every defined String projection.
  - [x] FIX: One null guard in the shared key helper; retain the entire defined conversion/fallback branch and all three existing callers. Intentionally select reference raw/shared contains expectations and register safe new fixture in run.lua. No parser/schema/global conversion/arity/source/free-default changes.
  - [x] ADDRESSED (verified): Shared/native-plan-fresh null reference and null-versus-container checks pass on both hosts after RED; numeric/raw JSON kinds, mixed positions, value/receiver/standalone uniq, copied first values/order/nonmutation, numeric/default/count/last/text consumers and NC/one needle hold. Defined-only/container-projection/free-missing controls stay passing.
  - [x] NO REGRESSION: Direct contains/index fixtures and interpreter/runner load checks pass on both hosts. Only safe named fixtures run; no malformed native pattern/full suite/declared5.4 or complete domain/portable admission.
  - [x] LOCKSTEP: Shared/current reference selection, new fixture/registration, scoped catalog/current contract progress, source-null/contains/Lua-selection facts/map and TYPE/FUTURE5.7/index/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Six bounded repairs targeted-checked; next numeric-comparison result assessment23.2.15 is scheduled without presuming a defect or changing its prior intentional terminal policy yet.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.14.6 - distinguish Lua null Array comparison keys`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.15`
  Status: `active` / all five comparison result implementations targeted-checked; full admission separate
  Goal: Extend existing six short numeric comparison methods with actual numeric/null result continuations.
  Dependencies: .23.2.15 frozen numeric-comparison-results.md.
  Children: `.23.3.15.1`, `.23.3.15.2`, `.23.3.15.3`, `.23.3.15.4`, `.23.3.15.5`.
  Acceptance: Independently preserve scalar-numeric-v1 producers, strict domains, one-RHS preflight, once-only source/RHS/consumer order and numeric/null scalar boundaries, compatible defaults/generic/String/explicit-container bridges. Small changed-surface/direct checks/docs/commit per backend; full domain/context/portable admission23.4 separate.

  Follow-up: Rust String-prefix numeric comparison dispatch is independently repaired/tested with arithmetic16.2; existing numeric producer/domain policy is preserved.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.15.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary numeric comparison result continuations.
  Dependencies: .23.2.15.
  Acceptance: Follow numeric-comparison-results.md for six short eq/ne/gt/ge/lt/le methods, preserve actual contracted numeric1/0/invalid-null and scalar numeric domains/free signatures. Native/generated producer-first RED/GREEN, six pairs, source families, strict invalid/default/generic/numeric/String/Array transitions, shape-before-effects and captured SOC controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `26454b71bbcd1e5bff5fcb457a7759531bc161de`; numeric result freeze committed, brief0/tree clean.
  Owned paths: Perl ordinary numeric comparison result-family handoff, retained shared native/fresh result/type/shape/effect/selector fixture, intentional ordinary AST/Phase0/codeblock-outer expected updates and direct focused selectors, synchronized book/facts/task/live docs. Deferred callback vocabulary remains unchanged.
  Verification tier: `focused`
  Focused checks: Shared public native/fresh RED/GREEN, actual touched AST/Phase0 named cases and changed outer numeric-codeblock rows plus deferred preservation control; direct comparison, syntax/compile and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary result implementation under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored results and preservation controls; no population/completeness measurement.

  Implementation seams owned here: Initial result-family-only change makes ordinary numeric/text/default consumers work but exposes two frozen bridge gaps. Public generated handler retains score.eq(2).cat(...).split(...).last().uppercase() (compile error at .eq): Number loop cannot consume the actual Array after explicit split. Actual outside/cat-prefix-gt-tail fixture retains read().cat(...).gt(...), failing handler compile: String loop lacks the existing short numeric-comparison handoff. Add only the missing scoped actual-kind dispatches; retain deferred terminal policy and unsupported-tail no-effects.

  Completion: Classify six short numeric comparisons as scalar_result and preserve existing strict numeric helper mapping/one-RHS preflight. Number chains now hand actual explicit split Arrays to the shared Array dispatcher; String prefixes can hand six existing numeric comparison methods to shared scalar dispatch. Producers and deferred runtime remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared native/fresh RED returns raw/nested/invalid producers correctly but every continued comparison null, effects skipped/source2. Selector-kind control already works. Initial family-only repair exposes public generated-handler raw bridge .eq and outside/cat-prefix .gt compile residue; own both frozen transition gaps in this leaf, without blessing null/compile errors.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering _number_receiver_value_chain_return_family marks comparisons terminal. Public dump shows score.eq(...).cat(...).split(...).last().uppercase() residue because Number loop lacks actual Array handoff; actual outer callback fixture read().cat(...).gt(...) remains raw because String loop lacks numeric comparison handoff. CodeblockRuntime has its own deliberate terminal preflight, retained unchanged.
  - [x] FIX: scalar_result comparison classification plus scoped shared Array dispatch in Number loop and six-comparison scalar dispatch from String loop. Intentionally update actual AST poisoned-node/Phase0 ordinary comparison calibration and seven ordinary outer numeric-codeblock expectations; keep deferred/unknown-tail expectations and source/value policies.
  - [x] ADDRESSED (verified): Shared native/fresh six true/false pairs, numeric1/0 and strict invalid-null/decimal controls, source families, false retention/default8/definedness/numeric consumers, repeated comparison, explicit String/Array bridgeX, scalar negatives, source1/operand1/SOC/final-null, invalid-source SOC/default8 and twelve malformed no-effects pass. Numeric flag still writes Array index1. Actual modified outer callable rows now produce0x/1x with one read, deferred and unknown-tail no-effects stay passing.
  - [x] NO REGRESSION:59 assertions across shared fixture and exact actual AST/Phase0 named cases plus changed outer rows/deferred preservation pass after bridge repair. Direct lexical comparison, changed source/test syntax pass as recorded; no whole Phase0/parser/numeric suites, deferred vocabulary expansion or full admission.
  - [x] LOCKSTEP: Shared source/expected/test and current calibration rows, frozen contract progress, scoped book/grammar examples and canonical number-chain fact/map, live/task/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Engineering hot-root reached59008/65536 bytes: normal rollover archived143 lines as segment4955, leaving199 lines/32488 bytes; immutable prior history untouched. New Perl fixture selection remains mandatory23.4.1. Rust15.2 independent producer/transition assessment follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.15.1 - continue Perl numeric comparison results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.15.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary numeric comparison result continuations.
  Dependencies: .23.3.15.1.
  Acceptance: Follow numeric-comparison-results.md for six short eq/ne/gt/ge/lt/le methods, preserve actual contracted numeric1/0/invalid-null and scalar numeric domains/free signatures. Native/generated producer-first RED/GREEN, six pairs, source families, strict invalid/default/generic/numeric/String/Array transitions, shape-before-effects and captured SOC controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `7e47de7413c0ce0c84f33628921dddbc6473522f`; Perl comparison result child committed, brief0/tree clean.
  Owned paths: Rust short comparison scalar-result/one-RHS dispatch and actual affected named number calibration, native/restored/plan producer/shared/selector regression, scoped book/facts/task/live docs. Numeric domains/free signatures and unrelated arithmetic guards stay unchanged.
  Verification tier: `focused`
  Focused checks: Producer-first native/restored/plan controls, shared RED/GREEN and direct String/aggregate result tests, exact touched number integration cases, offline compilation/rustfmt and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary result implementation under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Producer setup correction: First Rust control used -.5 as a bare literal (not a JSON number) beside valid numeric String"-.5". Public Engine warns unknown helper5/returns null; Core primary parser recognizes negative numeric literals only when minus is followed by a digit. Use canonical -0.5 literal in shared fixture/probe while retaining String"-.5" conversion control. This is a source spelling correction, not numeric producer RED credit or a new leading-dot literal contract. Reconfirm the producer before runtime edits.

  Completion: Rename the private comparison classifier to reflect its nonterminal role; classify six methods as scalar-result producers and hand Number-chain comparisons to shared actual-value continuation. Remove obsolete terminal state/fences, retaining numeric helper/arity/domain evaluation. Add exact-one-RHS global preflight before effects. Shared String/Array bridges already work through dynamic dispatch after handoff.
  Verification:
  - [x] REPRODUCE / ISSUE: After source spelling correction, independent native/restored/plan raw/canonical/word/symbol/strict-domain/nested/source producer and selector controls pass. Shared continuation RED returns null, SO/source3 instead of SOC/final-null, and twelve malformed effects. Initial -.5 bare literal setup is not numeric producer RED credit; use canonical -0.5 and keep String"-.5" control.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs dynamic Number helper and Number loop enforce comparison-terminal fences/state; is_scalar_result_receiver_method omits six comparisons. Common Expr::FluentChain preflight omits their one-RHS guard. Correct producers capture source and return numeric1/0/invalid-null; do not copy String-comparison Bool policy.
  - [x] FIX: Reuse comparison classifier in scalar result selection, shared selected-value continuation and one-RHS preflight; remove obsolete private Terminal state/dynamic fence. Intentionally update actual integration comparison calibration from[null,null] to[2,1]. Canonical literal spelling only changes shared source/probe, not expected values; Perl reference rechecks pass. No parser/schema/numeric-adapter/free signature or unrelated arithmetic change.
  - [x] ADDRESSED (verified): Native/restored/plan shared six pairs/Number flags/strict domains, source families, false/default8/definedness/numeric/selector and repeated-comparison consumers, String/Array bridgesX and scalar negatives pass. Valid and invalid-source SOC/once-only/final snapshots and twelve malformed no-effects pass. Free aliases/producer controls stay correct.
  - [x] NO REGRESSION: Eight Rust tests across numeric producer/shared/selector, direct lexical/aggregate and two actual named number integration cases pass with offline compilation/rustfmt; twelve shared Perl reference assertions pass after literal spelling correction. No full suite, standalone emitted Rust, new leading-dot literal/strict equality or full domain/portable admission.
  - [x] LOCKSTEP: Retained Rust tests/current calibration/shared canonical literal, frozen contract progress, scoped book/catalog/grammar and canonical number-chain/deferred qualifier facts/map, TYPE/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Dart15.3 independent producer/continuation assessment next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.15.2 - continue Rust numeric comparison results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.15.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary numeric comparison result continuations.
  Dependencies: .23.3.15.2.
  Acceptance: Follow numeric-comparison-results.md for six short eq/ne/gt/ge/lt/le methods, preserve actual contracted numeric1/0/invalid-null and scalar numeric domains/free signatures. Native/generated producer-first RED/GREEN, six pairs, source families, strict invalid/default/generic/numeric/String/Array transitions, shape-before-effects and captured SOC controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `82635ca70466e0d475c31597c378a1bb2c7c2248`; Rust comparison result child committed, brief0/tree clean.
  Owned paths: Dart confirmed numeric comparison result/shape guard gaps, native/restored/plan producer/shared/selector tests and synchronized book/facts/task/live docs. Preserve numeric adapters/domains/free signatures/source behavior and existing aliases.
  Verification tier: `focused`
  Focused checks: Producer-first native/restored/plan controls and shared RED/GREEN, direct lexical/aggregate result checks, format/fatal analysis and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary result implementation under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls; no population/completeness measurement.

  Completion: Share a private six-name canonical numeric comparison set between one-RHS preflight and possible scalar-result classification. Existing dynamic result/alias/producer dispatch already works; guard boundaries by actual result and reject bad shapes before effects.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent native/restored/plan free canonical/word/symbol producers, strict numeric domains, nested SOC/source snapshot and numeric selector control pass before production. Shared native valid continuations/bridges/defaults/SOC already work; scalar incompatible/after-text results are[] and twelve bad shapes run24 effects instead of null/zero effects.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart common ActionFluentChainExpr preflight omits canonical num_eq/ne/gt/ge/lt/le; _evaluateFluentCallsWithValue mayProduceScalar omits them too. NumericCompare already returns numeric1/0/invalid-null with correct conversion; no producer or source defect inferred.
  - [x] FIX: Add private _numericComparisonHelperNames set used by both guards. Preserve every helper/alias conversion, shape-independent domain policy, raw kinds and current valid flows; no parser/schema/free signatures/arithmetic or calibration expectation change.
  - [x] ADDRESSED (verified): Native/restored/plan shared six pairs/raw Number flags/strict invalid/decimal inputs, source families, false/default8/generic/numeric/selector and repeated-comparison consumers, String/Array bridgesX and scalar negatives pass. Valid/invalid-source SOC/once-only/final snapshots stay correct; twelve malformed no-effects now pass.
  - [x] NO REGRESSION: Six tests across new numeric producer/shared/selector and direct lexical/aggregate result fixtures pass with compilation/format/fatal selected-file analysis. No full suite, new canonical method surface or complete domain/context/portable admission.
  - [x] LOCKSTEP: New retained shared-reference consumer, frozen contract progress, scoped guide/catalog/grammar and canonical number/Dart numeric facts/map, TYPE/live/resume align. Relevant Dart fact compacts the prior full generic guard record behind exact Git pointer; no budget increase or unrelated cleanup. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia15.4 independent assessment next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.15.3 - guard Dart numeric comparison result flow`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.15.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary numeric comparison result continuations.
  Dependencies: .23.3.15.3.
  Acceptance: Follow numeric-comparison-results.md for six short eq/ne/gt/ge/lt/le methods, preserve actual contracted numeric1/0/invalid-null and scalar numeric domains/free signatures. Native/generated producer-first RED/GREEN, six pairs, source families, strict invalid/default/generic/numeric/String/Array transitions, shape-before-effects and captured SOC controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `03f0036a8093e87db4af7c82ef6518448c9d9ee7`; Dart comparison guard child committed, brief0/tree clean.
  Owned paths: Julia confirmed numeric comparison result/shape gaps, native/plan/fresh producer/shared/selector tests with Number/not-Bool guards and fixture registration, synchronized scoped book/facts/task/live docs. Preserve numeric adapters/domains/free signatures and source/alias behavior.
  Verification tier: `focused`
  Focused checks: Independent producer-first native/plan/fresh RED/GREEN with raw numeric identity guards, direct lexical/aggregate result tests, strict compilation and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary result implementation under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls; no population/completeness measurement.

  Completion: Add canonical num_eq/ne/gt/ge/lt/le to common exact-one-RHS and possible scalar-result lists. Existing numeric producer/alias/dynamic continuation already works; actual container outputs still release scalar guarding.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent native/plan/fresh canonical/word/symbol and strict numeric-domain producers, raw Number/not-Bool flags/aliases, nested SOC and selector kinds pass before production. Three shared route REDs preserve all valid continuation/default/bridge/SOC results but expose incompatible/after-text[] and24 malformed effects.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _evaluate_runtime_fluent_chain! common one-operand and may_produce_scalar tuples omit canonical numeric comparisons. Existing numeric helper returns numeric1/0/invalid-nothing; shared helper implementation alone does not establish fluent shape/result guards.
  - [x] FIX: Two scoped tuple additions plus retained regression/runner registration. Preserve all helper conversions/aliases/free signatures/source evaluation and existing actual-kind dispatch; no parser/schema/arithmetic or calibration expectation changes.
  - [x] ADDRESSED (verified):27 new strict native/plan/fresh assertions pass six pairs/raw kinds/decimal and invalid inputs, source families, false/default8/generic/numeric/selector/repeated comparisons, String/Array bridgeX, scalar negatives and valid/invalid-source SOC/once-only/final snapshots. Explicit Number/not-Bool guards reject false passing from Julia ==; twelve malformed shapes now run zero effects.
  - [x] NO REGRESSION:42 focused assertions across numeric/direct lexical/aggregate result fixtures and strict package precompilation pass. No whole suite, arithmetic/domain expansion or complete context/portable admission.
  - [x] LOCKSTEP: New retained consumer/registration, frozen contract progress, scoped guide/catalog/grammar and canonical number/Julia numeric facts/map, TYPE/live/resume align. Qualify prior overly broad cannot-drift wording: helper reuse does not replace receiver guards; compact historical guard detail behind exact prior Git record. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Safe Lua15.5 independent assessment next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.15.4 - guard Julia numeric comparison result flow`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.15.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary numeric comparison result continuations.
  Dependencies: .23.3.15.4.
  Acceptance: Follow numeric-comparison-results.md for six short eq/ne/gt/ge/lt/le methods, preserve actual contracted numeric1/0/invalid-null and scalar numeric domains/free signatures. Native/generated producer-first RED/GREEN, six pairs, source families, strict invalid/default/generic/numeric/String/Array transitions, shape-before-effects and captured SOC controls. Small compile/direct checks/docs/commit; full admission separate. Lua available PUC5.5.1/LuaJIT safe named fixtures only; declared5.4 and malformed native patterns remain separately owned.

  Activation: clean `564157d106c526a7a3c6062744381ffc821cb2c5`; Julia comparison guard child committed, brief0/tree clean.
  Owned paths: Lua confirmed comparison scalar-result/one-RHS gaps, native/plan/fresh producer/shared/selector tests and safe registration, actual named numeric calibration expectation update, scoped book/facts/task/live docs. Numeric adapter/domains/free signatures stay unchanged; malformed native patterns excluded.
  Verification tier: `focused`
  Focused checks: Independent public producer-first native/plan/fresh RED/GREEN and direct lexical/aggregate fixtures, exact affected named numeric calibration/source loads on PUC5.5.1/LuaJIT, book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; declared5.4/full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Replace the numeric-comparison terminal fence with scalar-result marking and reuse scalar_numeric.is_comparison in common one-RHS preflight. Existing dynamic dispatcher now consumes actual numeric/null results through text/default/generic/numeric and explicit container bridges; producer/equality/adapter policy stays unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent PUC5.5.1/LuaJIT native/plan/fresh canonical/word/symbol/strict-domain numeric producers, nested SOC/false/default/bridge controls pass before production. Shared native RED stops every continuation at null/SO/source3 and runs24 malformed effects; correct raw numeric and incompatible scalar controls already hold.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua evaluate_fluent_calls returns json.null immediately after any nonfinal scalar_numeric comparison, and common fluent preflight omits its RHS guard. scalar_numeric evaluator already returns numeric1/0/invalid-null; actual source captures work, so do not infer a source or producer defect.
  - [x] FIX: Mark numeric comparison result scalar instead of stopping, add existing is_comparison classifier to one-RHS preflight, register retained fixture. Intentionally update six actual named numeric terminal_* expected values fromnull to2; stable historical field names retained. No parser/schema/numeric adapter/free signatures/arithmetic changes.
  - [x] ADDRESSED (verified): Strict canonical JSON/native-plan-fresh shared six pairs/raw numeric kinds/decimal and invalid inputs, source families, false/default8/generic/numeric/selector/repeated comparisons, String/Array bridgeX and scalar negatives pass on both hosts. Valid/invalid-source SOC/once-only/final snapshots and twelve malformed no-effects pass. Actual old numeric calibration now admits all six comparison arithmetic results2 while free alias/arithmetic controls stay green.
  - [x] NO REGRESSION: Direct lexical/aggregate fixtures, exact affected named numeric calibration and interpreter/runner load checks pass on both hosts. Only safe named operations selected; reviewed valid regex AST parsing in that calibration invokes no malformed native pattern. No full runner, declared5.4 or complete domain/portable admission.
  - [x] LOCKSTEP: New retained consumer/registration/current calibration, frozen contract/all-five bounded progress, scoped guide/catalog/grammar/Lua handoff and canonical number/Lua numeric facts/map, TYPE/live/resume align. Old unsafe full-runner reverify replaced by safe current public fixture, dated July gate retained via exact Git pointer. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Next scalar arithmetic result assessment23.2.16 is scheduled from the same helper spine, preserving overload/domain authority before code.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.15.5 - continue Lua numeric comparison results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.16`
  Status: `active` / all bounded arithmetic backends targeted-checked; full admission separate
  Goal: Extend ordinary scalar numeric arithmetic results into compatible scalar/text/generic/explicit-container continuations.
  Dependencies: .23.2.16 frozen scalar-arithmetic-results.md.
  Children: `.23.3.16.1`, `.23.3.16.2`, `.23.3.16.3`, `.23.3.16.4`, `.23.3.16.5`.
  Acceptance: Preserve scalar-numeric-v1 producer/input/arity rules and actual Number/null kinds, one-time source/operand/result snapshots, scalar/Array min/max overloads, current free/deferred boundaries and Array reducer defects. Independent backend small changed-surface/direct checks/docs/commit; full admission23.4 separate.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.16.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary scalar arithmetic result continuations.
  Dependencies: .23.2.16.
  Acceptance: Follow scalar-arithmetic-results.md for twelve existing short Number methods, preserving raw Number/null/strict domains/free signatures/overload policies. Public producer-first/native-generated RED/GREEN, source families, zero/invalid/default/generic/scalar boundaries, numeric->text->Array->String bridges, lazy actual-container defaults and captured SOC/arity controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `846a39094d1f0f1972169fc089098df43aad47d2`; scalar arithmetic result freeze committed, brief0/tree clean.
  Owned paths: Perl ordinary arithmetic scalar-result classification/String-prefix handoff, retained shared/native/fresh twelve-method/source/kind/shape/default/bridge/overload regression and selector control, scoped book/facts/task/live docs. Numeric adapters/free signatures/scalar-Array min-max/deferred/reducer95 policies stay unchanged.
  Verification tier: `focused`
  Focused checks: Public native/fresh shared RED/GREEN plus direct numeric comparison and actual named arithmetic AST/Phase0 cases, source/test syntax and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary result implementation under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  In-flight owned bridge defect: Initial arithmetic scalar classification/String-prefix handoff passes every shared field except invalid numeric -> explicit Hash default -> sorted_values -> first -> uppercase, which is null instead of A on native/fresh. Array defaults/copy, numeric snapshots/overloads/shapes and direct comparison/actual arithmetic calibrations pass. Keep the Hash expectation; investigate with public substitution/Get/dump and distinguishing default-source controls before any further repair.

  Hash bridge root/ownership: Public Get/substitution/dumps show numeric-root, canonical-call-root and direct undef.coalesce Hash projection all become unsupported-helper:first/null, while fully nested equivalent yields A. Once-bound default guards contain emitted host do expressions; later Array consumers reparse those as DSL. Repair the Array composition seam via the existing compatibility bridge only for already-emitted do sources, preserving the dedicated sorted/reversed path and authored syntax checks. Original default-selection62 / TYPE23.3.6 remain authoritative; this direct dependent repair/regression is owned here and fixes their confirmed projection-successor gap too.

  Completion: All existing short Number methods yield scalar_result for compatible actual-value continuation; String prefixes hand existing numeric methods to that same dispatcher. Numeric adapters, overload rules and shape preflight stay unchanged. Also repair confirmed existing default Hash-view successor staging: Array call composition uses the existing compatibility bridge when its source already contains emitted host do code, keeping the dedicated sorted/reversed path. No authored syntax or unsupported-AST fallback is widened.
  Verification:
  - [x] REPRODUCE / ISSUE: New shared native/fresh RED fails handler compile on raw arithmetic-to-text/default chains, while raw selector controls already work. Family/prefix change makes every field pass except Hash default sorted_values->first->uppercase. Independent numeric/call/direct-default public Get/substitution/dumps return unsupported-helper:first/null versus nested A; retained focused default projection fixture RED confirms the old staging defect.
  - [x] ROOT CAUSE (WHY + WHERE): Number return-family metadata and String-prefix numeric dispatch prevent compatible arithmetic flow. The separate Hash-view bug is append_array_chain_call constructing DSL over an already emitted default guard do expression; later typed lowering reparses host output and emits first's unsupported sentinel. Existing legacy composition flag is the established bridge for generated host expressions, not an invitation to parse authored retired syntax.
  - [x] FIX: Scalar arithmetic return family and existing Number-method handoff, plus local Array-call finishing through the compatibility bridge only for do-expression sources. Preserve sort/reverse's existing runtime route, all numeric/Array/default producers and free/deferred/overload policies. Add shared arithmetic and direct default-projection native/fresh regressions and numeric selector control; no public method/parser/schema changes.
  - [x] ADDRESSED (verified): Twelve arithmetic methods and variadic forms retain numeric/text results, strict invalid/rounding/modulo cases, all source families, zero retention/skipped fallback, numeric/default8/generic/comparison consumers, String/Array/Hash defaults, copied chosen Array and bridgeX. Valid/invalid-source SOC/once-only and ASO min/max overloads hold; fourteen bad shapes run zero effects. Numeric add/scalar min outputs remain Array indexes. Default Hash projections now support first/last/count/join/contains/index, sum/transform/reverse/take successors, multiple root families, numeric index kinds and SDC/once-only/source snapshots.
  - [x] NO REGRESSION:29 current focused assertions across arithmetic/projection/existing selected/literal default fixtures pass; the literal suite still rejects authored fat-arrow Hash syntax. Extended projection smoke and two actual AST/Phase0 numeric named cases pass, source/test syntax clean. Direct numeric comparison12 assertions already pass after arithmetic classification; final projection tests cover its affected Hash-root path. No whole suites, Array reducer95/deferred expansion or portable admission.
  - [x] LOCKSTEP: Shared and default-projection source/expected/tests, frozen contract/old default-family follow-up, current worked book examples and canonical Number/default facts/map plus live/task/resume align. Normal gate registration of both new Perl files remains mandatory23.4.1. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Rust16.2 independently assesses its producers and transitions next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.16.1 - continue Perl scalar arithmetic results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.16.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary scalar arithmetic result continuations.
  Dependencies: .23.3.16.1.
  Acceptance: Follow scalar-arithmetic-results.md for twelve existing short Number methods, preserving raw Number/null/strict domains/free signatures/overload policies. Public producer-first/native-generated RED/GREEN, source families, zero/invalid/default/generic/scalar boundaries, numeric->text->Array->String bridges, lazy actual-container defaults and captured SOC/arity controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `1d77f481bbe2222effd36bb946438a2d41093b37`; Perl arithmetic/default-projection slice committed, brief0/tree clean.
  Owned paths: Rust confirmed arithmetic result/shape dispatch gaps, native/restored/plan canonical/alias/strict-domain/shared/selector regression, scoped book/facts/task/live docs. Numeric adapters/free signatures/min-max overload/source/reducer policies stay unchanged.
  Verification tier: `focused`
  Focused checks: Producer-first native/restored/plan RED/GREEN and direct numeric comparison/aggregate/default fixtures, actual named number integration cases, offline compilation/rustfmt and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Remaining prefix seam: Initial shared numeric result dispatch/shape repair passes every shared field except String trim->add, still null. Public Engine result and eval_string_receiver_value_chain show String loop validates its own whitelist before numeric result handoff; add focused arithmetic/comparison/invalid prefix controls and hand existing Number methods to shared dispatch before evaluating consumer operands. This also owns the same existing numeric-comparison prefix gap, without changing its producer/domain policy.

  Completion: Classify existing Number methods as scalar-result producers and use shared actual-value dispatch for Number chains, removing duplicate Number-only evaluation. String prefixes hand existing Number methods to that dispatcher too. Extend common unambiguous arity preflight for unary/sub/div/mod/clamp/add/mul; min/max zero-extra Array and scalar variadic modes remain untouched.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent native/restored/plan canonical/word/symbol arithmetic producers, strict invalid/null/decimal controls, nested5!/SOC and numeric add/scalar-min selector controls pass before production. Shared RED stops ten literal arithmetic text/default/bridge flows, leaves SO/source9 and runs14 malformed effects. min/max text/variadic and selected/call/count/reducer sources already work; preserve them.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs Number loop only accepts Number links, while scalar-result classification misses most arithmetic methods. Common fluent preflight lacks their shape checks. Initial shared dispatch repair fixes every field except String trim->add; String loop checks its whitelist before numeric handoff. Direct prefix RED independently returns[null,null,null] versus[5!,1!,8], covering existing numeric-comparison prefix too.
  - [x] FIX: Shared Number-method scalar classification and Number-chain dispatch, scoped String-family numeric handoff before consumer-argument evaluation, and reference-matching unambiguous shape guards. Remove obsolete duplicate Number-loop helper/argument construction. Numeric adapters/free signatures/parser/schema/min-max/reducer/deferred vocabulary stay unchanged; no old expectations require normalization.
  - [x] ADDRESSED (verified): Native/restored/plan shared twelve/variadic/domain/source/zero/default/copy/Array/Hash/bridge/selector/generic/comparison cases pass. Valid/invalid-source SOC, ASO overloads and fourteen malformed no-effects hold. Extra String prefix arithmetic/comparison/invalid-default controls now give5!/1!/8; existing source captures and numeric kinds remain.
  - [x] NO REGRESSION: Eleven Rust tests across four new numeric producer/shared/selector/prefix cases, direct comparison/aggregate/default fixtures and two actual named number integration cases pass with offline compilation/rustfmt. No whole suite, standalone emitted Rust, numeric domain/free signature or full portable admission claim.
  - [x] LOCKSTEP: New retained shared-reference/prefix consumer, frozen contract progress and comparison follow-up, current catalog/guide examples and canonical Number fact/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Dart16.3 independent producer/continuation assessment next; Perl host-staging repair remains separately evidenced.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.16.2 - continue Rust scalar arithmetic results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.16.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary scalar arithmetic result continuations.
  Dependencies: .23.3.16.2.
  Acceptance: Follow scalar-arithmetic-results.md for twelve existing short Number methods, preserving raw Number/null/strict domains/free signatures/overload policies. Public producer-first/native-generated RED/GREEN, source families, zero/invalid/default/generic/scalar boundaries, numeric->text->Array->String bridges, lazy actual-container defaults and captured SOC/arity controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `392b181b5865c5e424a85d8a863d3243bce5073b`; Rust arithmetic committed, brief0/tree clean.
  Owned paths: Dart independently confirmed arithmetic scalar/shape gaps, retained native/restored/plan producer/shared/selector/prefix controls, scoped book/facts/task/live docs. Preserve numeric adapters/free signatures/min-max modes and source/default snapshots.
  Verification tier: `focused`
  Focused checks: Producer-first public RED/GREEN and direct comparison/aggregate/default fixtures, format/fatal selected analysis and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Add canonical arithmetic scalar-result marking and common unambiguous unary/sub-div-mod/clamp/add-mul arity guards. Existing actual-value dispatcher already handles valid arithmetic/prefix/default/bridge flow; preserve numeric producers/free signatures/min-max modes.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent canonical/word/symbol producer, selector and String-prefix controls pass before production. Shared native RED has incompatible/after_text [] instead ofnull and28 malformed source/operand effects; valid twelve-method/variadic/source/default/bridge/SOC/ASO fields already pass.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart mayProduceScalar omits arithmetic methods, permitting scalar fallthrough into container helpers; common fluent preflight omits their unambiguous arities. Canonical numeric evaluator and captured source/default dispatch are already correct for this fixture.
  - [x] FIX: Add _numericArithmeticHelperNames to scalar marking and shape checks before source/operand evaluation. Leave min/max global shape handling unchanged for Array/scalar overloads. No new method/parser/schema/numeric adapter/free signature or domain normalization.
  - [x] ADDRESSED (verified): Four new native/restored/plan cases preserve raw twelve/alias/symbol kinds and strict invalid/rounding/modulo, text/variadic/source/numeric selector/prefix paths, zero/default/copy/Array/Hash/bridge/generic boundaries and SOC/ASO; fourteen malformed calls now have zero effects.
  - [x] NO REGRESSION: Eleven focused tests across arithmetic, numeric comparison, aggregate numeric and selected default fixtures pass. Format and fatal selected source/new-test analysis pass. No whole suite, large-magnitude repair or full portable admission claim.
  - [x] LOCKSTEP: Retained regression, frozen contract/current backend progress, worked catalog/guide and canonical Dart/Number facts/map plus live/task/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia16.4 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.16.3 - guard Dart scalar arithmetic results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.16.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary scalar arithmetic result continuations.
  Dependencies: .23.3.16.3.
  Acceptance: Follow scalar-arithmetic-results.md for twelve existing short Number methods, preserving raw Number/null/strict domains/free signatures/overload policies. Public producer-first/native-generated RED/GREEN, source families, zero/invalid/default/generic/scalar boundaries, numeric->text->Array->String bridges, lazy actual-container defaults and captured SOC/arity controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `bec537d5b05ebfdd7750930bfb13ca1588a4da5e`; Dart arithmetic committed, brief0/tree clean.
  Owned paths: Julia confirmed arithmetic scalar/shape gaps, native/plan/fresh producer/shared/selector/prefix regression and runner registration, scoped book/facts/task/live docs. Preserve strict Number/not-Bool/null kinds and numeric/free/min-max/source/default policies.
  Verification tier: `focused`
  Focused checks: Independent producer-first RED/GREEN, direct comparison/aggregate/default tests with strict Number/not-Bool checks, compilation and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Extend common unambiguous arithmetic arity preflight and scalar marking tuples, reusing existing canonical actual-value dispatcher and unchanged numeric adapters/min-max modes. Retain/register strict native/plan/fresh producer/shared/selector/prefix regression.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent canonical/word/symbol/nested producer and selector/prefix cases pass before production. Shared RED has incompatible/after_text [] instead ofnull and28 source/operand effects; valid twelve/variadic/source/domain/default/bridge/SOC/ASO fields already hold on all three routes.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! omits arithmetic scalar marking and unambiguous common arity preflight. Canonical pure helper/actual-value source and default dispatch already satisfy retained valid controls; do not infer numeric producer defects.
  - [x] FIX: Add unary/sub-div-mod/clamp/add-mul guards and twelve arithmetic canonical names to scalar tuple; preserve min/max overload shape handling. No parser/schema/helper/domain/free signature changes. Register the new retained test in runtests.jl.
  - [x] ADDRESSED (verified): Thirty new assertions pass native/plan/fresh twelve/variadic/strict-domain/aliases/symbols/selector/prefix and shared source/zero/default/copy/actual Array-Hash/bridge/generic/comparison flow. Explicit Number && !Bool guards protect raw/alias/symbol/counter kinds. SOC/ASO and fourteen malformed zero-effects hold.
  - [x] NO REGRESSION:69 focused assertions across new arithmetic, direct numeric comparison, aggregate and selected-default tests pass with strict Julia compilation. No whole suite, known large-magnitude/slice repair or complete portable admission claim.
  - [x] LOCKSTEP: Retained test/runner, contract/current progress and book examples, compacted canonical Julia fact with exact prior Git history pointer and Number fact/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Safe Lua16.5 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.16.4 - guard Julia scalar arithmetic results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.16.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary scalar arithmetic result continuations.
  Dependencies: .23.3.16.4.
  Acceptance: Follow scalar-arithmetic-results.md for twelve existing short Number methods, preserving raw Number/null/strict domains/free signatures/overload policies. Public producer-first/native-generated RED/GREEN, source families, zero/invalid/default/generic/scalar boundaries, numeric->text->Array->String bridges, lazy actual-container defaults and captured SOC/arity controls. Small compile/direct checks/docs/commit; full admission separate. Safe PUC5.5.1/LuaJIT named fixtures only; malformed native patterns/declared5.4 remain separately owned.

  Activation: clean `a4385a108eac4c9c73e8b85c68f6710d52a3ba68`; Julia arithmetic committed, brief0/tree clean.
  Owned paths: Lua confirmed arithmetic scalar/shape gaps, native/plan/fresh producer/shared/selector/prefix regression and safe runner registration, scoped book/facts/task/live docs. Numeric adapters/free signatures/min-max modes/source/default snapshots remain unchanged.
  Verification tier: `focused`
  Focused checks: Producer-first public RED/GREEN on PUC5.5.1/LuaJIT, direct comparison/aggregate/default fixtures and actual affected safe numeric calibration, source loads and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; declared5.4/full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Mark all scalar_numeric fluent results scalar and extend common unambiguous unary/sub-div-mod/clamp/add-mul preflight. Reuse actual-value dispatcher, preserving min/max reducer/scalar modes and every numeric adapter/free signature. Register the safe retained producer/shared/selector/prefix fixture.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent PUC5.5.1/LuaJIT canonical/word/symbol/nested producers pass native/plan/fresh before production. Shared native RED exposes incompatible/after_text [] and28 malformed source/operand effects; valid arithmetic/source/default/copy/bridge/SOC/ASO already holds.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls marks only numeric comparisons scalar, leaving arithmetic fallthrough into container helpers; common fluent preflight lacks arithmetic shapes. Strict scalar_numeric evaluator and captured snapshots already satisfy valid controls.
  - [x] FIX: All scalar_numeric branch results set scalar_result=true; common unambiguous unary/binary/clamp/add-mul arity checks precede source/operand evaluation. min/max shape selection unchanged. Register new safe fixture; no parser/schema/numeric/domain/free signature changes.
  - [x] ADDRESSED (verified): Native/plan/fresh canonical JSON on both hosts distinguishes Number/Bool/String/null across producer aliases/symbols and twelve/variadic shared fields. Selector/prefix/default copy/actual Array-Hash/bridge/generic/comparison/source boundaries, SOC/ASO and fourteen malformed no-effects pass.
  - [x] NO REGRESSION: Both hosts pass direct numeric comparison/aggregate/default fixtures, exact affected safe named numeric calibration and interpreter/runner source loads. No full runner, malformed native regex, declared5.4 or complete portable admission claim.
  - [x] LOCKSTEP: Retained fixture/runner, frozen contract/all-five bounded progress and qualified catalog/guide, canonical Lua/Number facts/map plus live/task/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Next logical result assessment23.2.17 is owned before any new probe/change.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.16.5 - guard Lua scalar arithmetic results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17`
  Status: `active` / all bounded logical backends targeted-checked; full admission separate
  Goal: Complete bounded ordinary logical Boolean result continuation and clean scalar boundaries while retaining eager typed producer/error contracts.
  Dependencies: .23.2.17 frozen logical-results.md.
  Children: `.23.3.17.1`, `.23.3.17.2`, `.23.3.17.3`, `.23.3.17.4`, `.23.3.17.5`.
  Acceptance: Existing and/or/not free helper results remain actual Bool, typed truthiness/eager once-only operands unchanged. Compatible scalar/text/generic/default/explicit-container flow and source snapshots work; invalid logical source arity retains typed pre-effect errors. No new logical methods, numeric Bool coercion or full domain/context/portable admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17.1`
  Status: `completed` / primary implementation and rejection-effect follow-up17.1.1 verified
  Goal: Independently assess and implement/confirm Perl ordinary logical Boolean result continuations.
  Dependencies: .23.2.17.
  Acceptance: Follow logical-results.md, preserving actual Bool/strict numeric rejection, eager typed truthiness/source snapshots/free signatures, defaults/explicit Array-Hash bridges/scalar boundaries and pre-effect typed source arity errors. Public producer-first native/generated RED/GREEN and small direct checks/docs/commit; full admission separate.
  Owned confirmed defects: Logical-to-text-to-split staging unsupported cat; scalar-to-container raw DSL/accidental BindingRuntime error; unknown source operand scan suppressing not arity diagnostics. Repair immediately under this leaf, retaining direct/nested/effect source distinctions.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and small direct regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.


  Activation: clean `00fd9896e17386782689b2cdb6484f38820aad4b`; logical result freeze committed, brief0/tree clean.
  Owned paths: Perl logical-source typed scalar dispatch/bridge/scalar boundary and pre-effect source arity precedence, retained shared native/fresh logical result/error regression, scoped book/facts/task/live docs. Preserve existing logical/numeric/free/callback policies and emitted-host compatibility boundaries.
  Verification tier: `focused`
  Focused checks: Retained shared and typed source error RED/GREEN, direct logical/selected/default/arithmetic dependencies as warranted, syntax and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Validate malformed logical source arity before unknown-operand scanning. Materialize valid logical sources via the existing typed logical lowerer and scalar actual-result dispatcher; finish each composed helper through the established emitted-host compatibility bridge before a successor. Existing with/traversal normalization and all producer/free/numeric/typed truth policies stay unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: New native/fresh shared regression RED fails compound handler compile on raw and residue and misses the typed invalid-not/unknown-operand error. Independent retained intake already distinguishes unsupported cat bridge/null versus nestedX, source families/direct text/false/default/eager controls and accidental Array BindingRuntime error.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering chooses dispatch by first consumer before materializing the logical actual result; rebuilding later Array DSL loses typed source ownership. first_unknown_value_call_name also walks invalid source operands before typed logical arity checking. Numeric/truthiness and source snapshots are already correct; no producer or emitter repair inferred.
  - [x] FIX: Early malformed logical source arity validation, then a scoped logical-source loop reusing selected/Array/scalar families and existing compatibility finishing for already emitted logical host expressions. No broad raw fallback, new method, parser/schema/numeric/free signature or truth policy change.
  - [x] ADDRESSED (verified): Retained shared source/JSON/native/fresh regression passes six raw real-Bool/text/nested values, typed truthiness and named/selected/Hash/block/function/literal sources. All and/or/not split bridges giveX; Bool remains invalid numeric input with explicit8/ArrayB/HashA recovery, false default stays0!, incompatible scalar consumers are cleannull. Eager and/or LRC and not SC/calls/source snapshots hold. Five malformed source cases retain typed helper/arity/zero-evaluated fields, including unknown fail and known print operands.
  - [x] NO REGRESSION:26 current top-level checks across new12, direct logical8 and literal-default6 pass; source/new-test syntax clean. Existing logical with/typed sites/lazy contrast and default kinds remain. Additional new-route retired authored Hash-arrow assertion passes; no compatibility syntax widening or whole suite/portable admission.
  - [x] LOCKSTEP: Shared spec/expected/new test, frozen contract/current qualified catalog and canonical logical fact/map plus task/live/resume align. New Perl fixture registration remains mandatory23.4.1 before admission/push. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Independent Rust17.2 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.17.1 - continue Perl logical Boolean results`.
  Follow-up repaired: Rust17.2 intake exposed discarded source effects before incompatible rejection. Child17.1.1 now retains LR/LRC/S with the new rejected-effect regression; primary shared result fixture stays green.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17.1.1`
  Status: `completed`
  Priority: P1 immediate after clean Rust17.2, before Dart17.3.
  Goal: Preserve evaluated logical sources/prefix effects when a later incompatible container consumer rejects.
  Dependencies: Primary Perl17.1 implementation; finish/commit current Rust17.2 first.
  Reproduce: seen=0;bad=and({seen=num_add(seen,1);true}).sorted();return([bad,seen]) gives[null,0]; nested free sorted control gives[[],1]. Public substitution shows the new logical loop replaces the whole chain with undef when selected dispatch returns terminal, discarding the valid logical source. Source should execute once while incompatible consumer operands remain skipped; malformed-shape preflight policy unchanged.
  Root/impact: Newly introduced17.1 scalar-rejection branch loses the prior current_expr rather than evaluating it. This violates retained eager source behavior, although the original shared fixture lacks an effectful rejected consumer.
  Owned paths: Perl logical-loop rejection expression, shared logical_rejected_consumer_effects source/expected and focused native/fresh regression, retained public probe/current logical docs. Rust current leaf retains the independent cross-backend fixture/control without modifying Perl while dirty.
  Acceptance: Preserve LR/LRC/S prefix effects and null results, skip incompatible take operand, keep malformed logical typed errors and known consumer shape rules. Small current result/direct checks/docs/commit, then Dart17.3.
  Planned verification tier: focused
  Planned focused checks: Public native/fresh RED/GREEN rejection-effects plus current logical result regression and syntax/docs/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regression, no population/completeness measurement.

  Activation: clean `980c3c9ae171e7f4f17d885aaf78fca1759a44ee`; Rust17.2 committed, brief0/tree clean.
  Verification tier: `focused`
  Focused checks: Shared native/fresh rejection-effect RED/GREEN, existing logical result/error regression and Perl-only malformed consumer preflight control, syntax/book/history/staged continuity guards.
  Canonical trigger: None for immediate bounded regression repair under director feature-first cadence; full admission separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Completion: Capture the prior current_expr before applying each link; terminal scalar rejection now evaluates that prior emitted source/prefix once in scalar context, then returnsundef. It does not lower/evaluate incompatible consumer operands. Malformed-shape preflight and typed logical source arity remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: New shared native/fresh rejection regression RED returns empty order Strings instead ofLR/LRC/S; malformed sorted(1) control already gives[null,0]. Retained public comparison/substitution shows the whole chain becameundef, discarding source effects.
  - [x] ROOT CAUSE (WHY + WHERE): Newly added17.1 logical loop overwrites current_expr with the selected dispatch rejection before returning a constantundef. The previous logical/cat prefix remains unevaluated. This is our new continuation branch, not RuntimeLogical or emitter behavior.
  - [x] FIX: Preserve previous source_expr, bind it once in scalar context before terminal null rejection. No producer/truthiness/parser/schema/free-helper/domain or shared consumer-shape policy change.
  - [x] ADDRESSED (verified): Native/fresh shared bad Array/Hash/take fields returnnull and preserve LR/LRC/S; incompatible take operandA is skipped. The valid source/prefix runs once with its prior captured result. Perl-only malformed sorted(1) retains source-effect0.
  - [x] NO REGRESSION:24 focused top-level checks across new12 and current logical result/error12 pass; module/new-test syntax clean. Five malformed logical source cases retain typed pre-effect errors; raw Bool/false/default/bridge/source kinds and retired Hash-arrow assertion stay green. No whole suite/admission.
  - [x] LOCKSTEP: New retained Perl consumer of already checked shared rejected-effects fixture, frozen current contract and qualified catalog, logical/Rust facts/map plus task/live/resume align. Both new Perl logical tests remain mandatory23.4.1 registration before admission/push. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Parent17.1 closes; Dart17.3 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.17.1.1 - preserve rejected logical source effects`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary logical Boolean result continuations.
  Dependencies: .23.3.17.1.
  Acceptance: Follow logical-results.md, preserving actual Bool/strict numeric rejection, eager typed truthiness/source snapshots/free signatures, defaults/explicit Array-Hash bridges/scalar boundaries and pre-effect typed source arity errors. Public producer-first native/generated RED/GREEN and small direct checks/docs/commit; full admission separate.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and small direct regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.


  Activation: clean `a56732abcbf2af5968510246e23472c49d2fcadf`; Perl logical result repair committed, brief0/tree clean.
  Owned paths: Rust independently confirmed logical result/scalar/error gaps, native/restored/plan producer/shared/source error regression, scoped book/facts/task/live docs. Keep typed truthiness/eager Bool/numeric rejection/free signatures/source snapshots unchanged.
  Verification tier: `focused`
  Focused checks: Independent public producer-first RED/GREEN, direct named neutral logical/default cases as warranted, offline compilation/rustfmt and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Route known logical call receivers through existing selected scalar-result dispatch after dedicated trailing-block handling. Producer/eager typed truthiness/numeric rejection/source errors already work; only clean direct scalar->Array rejection needs repair.
  Verification:
  - [x] REPRODUCE / ISSUE: Correct the new harness to use public execute_value_with_diagnostics before crediting semantic RED. Producer and typed invalid source cases pass independently; shared RED differs only at incompatible Array[] instead ofnull. Valid three bridges/defaults/source kinds/LRC/SC already hold.
  - [x] ROOT CAUSE (WHY + WHERE): Common fluent dispatch chooses first Array consumer without marking the known logical source scalar. Existing selected dispatcher has the required scalar boundary; eval_expr already preserves source arity/eager Bool and snapshots.
  - [x] FIX: Evaluate and/or/not call receivers once, then selected scalar dispatch; keep existing trailing-block normalization first. No typed truthiness/parser/schema/helper/free/numeric/error changes.
  - [x] ADDRESSED (verified): Four new native/restored/plan tests pass canonical Bool producer/strict numeric-null, shared kinds/source/false/default/bridge/boundary/eager controls and five typed source-error shapes. Independent rejected-consumer fixture preserves LR/LRC/S while skipping incompatible take operand; no original operand substituted for Bool.
  - [x] NO REGRESSION: Six focused tests total include direct default and actual named neutral logical native/serialized/generated-plan consumer. Offline compilation/rustfmt pass. No whole suite or fresh standalone emitted Rust claim. Direct-dependent public Perl check exposes new17.1 rejection-effect loss; retained probe/fixture and immediate P1 child17.1.1 own repair after this clean commit, before Dart.
  - [x] LOCKSTEP: Retained Rust/shared rejected-effect controls and reference probe, frozen contract/current book qualification and compacted canonical Rust fact with exact prior Git pointer plus neutral fact/map/live/task/resume align. Normal change-history rollover is owned here. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Perl17.1.1 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.17.2 - guard Rust logical Boolean results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary logical Boolean result continuations.
  Dependencies: .23.3.17.2.
  Acceptance: Follow logical-results.md, preserving actual Bool/strict numeric rejection, eager typed truthiness/source snapshots/free signatures, defaults/explicit Array-Hash bridges/scalar boundaries and pre-effect typed source arity errors. Public producer-first native/generated RED/GREEN and small direct checks/docs/commit; full admission separate.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and small direct regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.


  Activation: clean `41b61a86bb51cdc872c71e3b6940f69bdec6f67d`; Perl rejection-effect follow-up committed, brief0/tree clean.
  Owned paths: Dart independently confirmed logical Boolean actual-result guards, retained native/restored/plan producer/shared/rejected-effect/source-error regression, scoped book/facts/task/live docs. Preserve typed truth/eager Bool/numeric rejection/free signatures/named context normalization and snapshots.
  Verification tier: `focused`
  Focused checks: Public producer-first RED/GREEN, direct selected neutral logical/default tests, format/fatal selected analysis and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Mark actual Boolean fluent input and any resulting Boolean scalar, reusing existing value dispatcher/container release and preserving named context normalization, helper/error/truth/numeric policies. Retain producer/shared/rejected-effect/actual-Bool/source-error regression.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent canonical Bool/nested/eager LRC/strict numeric-null producer and five typed source-error cases pass before production. Shared RED has container[] instead ofnull; rejected take runsA (SA). Actual selected/block/literal Bool sorted controls yield three[] values. Correct producer and source evaluation are not blamed.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluateFluentCallsWithValue initializes scalarResult=false and never recognizes actual Bool selected from another helper. Existing scalar guard therefore permits container dispatch/operand effects, although actual-value source/error logic is correct.
  - [x] FIX: Initialize scalar tracking from actual bool and retain it after Bool-yielding links; existing Array/Map results release the boundary. No method/parser/schema/eager truth/numeric/free signature, named container-context or typed source error changes.
  - [x] ADDRESSED (verified): Nine new native/restored/plan cases retain strict raw Bool/nested/typed truth/numeric-null/shared sources/defaults/bridges and five typed source-arity errors with unknown/known operands. Actual selected/block/literal Boolean boundaries rejectnull; LR/LRC/S prefix effects survive while incompatible take operandA is skipped.
  - [x] NO REGRESSION: Fifteen focused tests total include direct defaults and three actual named neutral logical native/normalized fixtures, preserving prior with/lazy controls. Format/fatal selected source/new-test analysis pass. No full suite, standalone emitted or full context/portable admission claim.
  - [x] LOCKSTEP: Retained current tests, contract/qualified public examples and compacted canonical Dart fact with exact prior Git pointer plus neutral fact/map/task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia17.4 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.17.3 - guard Dart logical Boolean results`.
  Continuity defect owned/fixed: Current Frontier paragraph still schedules assessment14 after its completed rollout and later15/16 work, despite the correct17.3 row. Prior slices advanced the row but accumulated stale summary prose. Replace the paragraph with a bounded current family/admission view; Git preserves the old chronology.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary logical Boolean result continuations.
  Dependencies: .23.3.17.3.
  Acceptance: Follow logical-results.md, preserving actual Bool/strict numeric rejection, eager typed truthiness/source snapshots/free signatures, defaults/explicit Array-Hash bridges/scalar boundaries and pre-effect typed source arity errors. Public producer-first native/generated RED/GREEN and small direct checks/docs/commit; full admission separate.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and small direct regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.


  Activation: clean `40cc7b4581a8826200c65f04b9fa1622515042d8`; Dart logical results committed, brief0/tree clean.
  Owned paths: Julia independently confirmed actual Boolean result/scalar guards, retained native/plan/fresh producer/shared/rejected-effect/selection/source-error test and runner registration, scoped book/facts/task/live docs. Preserve Bool identity/eager typed truth/numeric rejection/free/context/error policies.
  Verification tier: `focused`
  Focused checks: Public producer-first RED/GREEN and small direct neutral/default fixtures with explicit Bool/Number identity, strict compilation and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Initialize scalar_result from actual Bool and retain it after any Bool-yielding link, reusing existing selected dispatch and container release. Register strict native/plan/fresh producer/shared/rejected-effects/actual-Bool/source-error regression. All logical/free/numeric/named-context policies stay unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent producer/valid shared flow and source errors already pass. Nine native/plan/fresh RED assertions expose container[] andSA incompatible-operand effects plus selected/block/literal Bool sorted fallthrough. Raw Bool/eager truth/strict numeric-null/default/source fields remain healthy.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! starts scalar_result=false and omits actual Bool after result selection, so container dispatch/operands run despite a Boolean actual value. Logical evaluator/source snapshots/error validator already work.
  - [x] FIX: Initial and post-result Bool tracking, preserving actual container release, named normalization and all typed truth/arity/free/numeric/producer behavior. No new method/parser/schema or callback ABI change; register the retained test.
  - [x] ADDRESSED (verified): New100 assertions pass native/plan/fresh canonical Bool/typed truth/numeric-null/shared source/default/bridge/boundary/rejected-effect and five source-error cases. Explicit Bool identity/raw/meta/flag and Number-not-Bool counter checks avoid Julia equality lookalikes. LR/LRC/S remain, takeA skipped; selected/block/literal boundaries give null.
  - [x] NO REGRESSION:214 focused assertions total include direct defaults9 and three exact neutral logical fixtures105, preserving with/lazy controls and producer policies. Strict compilation passes. No whole suite, full context/portable admission or separately owned callback-identity repair.
  - [x] LOCKSTEP: New test/runner, frozen contract/current examples and compacted canonical Julia fact with exact prior Git pointer plus neutral fact/map/task/live/resume align. Current frontier paragraph/row advance together. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Safe Lua17.5 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.17.4 - guard Julia logical Boolean results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary logical Boolean result continuations.
  Dependencies: .23.3.17.4.
  Acceptance: Follow logical-results.md, preserving actual Bool/strict numeric rejection, eager typed truthiness/source snapshots/free signatures, defaults/explicit Array-Hash bridges/scalar boundaries and pre-effect typed source arity errors. Public producer-first native/generated RED/GREEN and small direct checks/docs/commit; full admission separate.
  Safety scope: Only safe available PUC5.5.1/LuaJIT fixtures; exclude malformed native patterns/full runner. Declared5.4 remains separately owned.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and small direct regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.


  Activation: clean `1b92335386b2bbe929646e66623a722b4351cba2`; Julia logical results committed, brief0/tree clean.
  Owned paths: Lua independently confirmed actual Boolean scalar guards, safe retained native/plan/fresh producer/shared/rejected-effect/actual-Bool/source-error test and runner registration, scoped book/facts/task/live docs. Preserve typed truth/eager Bool/numeric/free/named-context/error policies and existing module-local ceiling.
  Verification tier: `focused`
  Focused checks: Producer-first/source-error public RED/GREEN and direct neutral/default fixtures on safe PUC5.5.1/LuaJIT, source loads and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; declared5.4/full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Initialize scalar_result from actual boolean and retain it after Boolean results, with existing container release. No new module-level locals, helper/parser/schema/truth/numeric/free/named-context or error policy changes. Register safe retained producer/source-error/shared/rejected-effect/actual-Bool/direct-neutral test.
  Verification:
  - [x] REPRODUCE / ISSUE: Both hosts pass independent native/plan/fresh canonical Bool/nested/eager LRC/strict numeric-null producer and five typed source errors before production. Shared native RED differs at incompatible/after_text Array[] instead ofnull; valid source/default/bridge/effect fields already hold.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls starts scalar_result=false and does not recognize actual Boolean values from subsequent selections, permitting container fallthrough. Typed logical helper/source/eager/error behavior already works; do not infer a producer defect or earlier unmeasured rejected-operand failure from another backend.
  - [x] FIX: Actual boolean tracking at entry and after results, retaining container release. No module-local validator/helper addition or numeric/truth/free/context normalization; register new safe fixture.
  - [x] ADDRESSED (verified): Strict canonical JSON native/plan/fresh checks on PUC5.5.1/LuaJIT preserve raw Bool/false/default/source/generic/numeric-null/three bridges and typed source errors. Rejected-consumer fixture retains LR/LRC/S/null and skips takeA; actual selected/block/literal Bool boundaries give null. No integer/String lookalike passes canonical JSON.
  - [x] NO REGRESSION: Both hosts pass three exact neutral logical fixtures and direct selected defaults, plus interpreter/runner source loads; no new module locals at the historical chunk ceiling. No full runner, malformed native pattern, declared5.4 or complete portable/domain/context admission.
  - [x] LOCKSTEP: Retained test/runner, frozen contract/all-five bounded progress and qualified catalog, canonical Lua/neutral facts/map/task/live/resume align. Current frontier row/paragraph advance together. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Separate next18 assessment owns useful defined-only coalesce receiver/result breadth before any contract or code expansion.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.17.5 - guard Lua logical Boolean results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4`
  Status: `pending`
  Children: `TYPE-REFERENCE-BOOK.1.2.23.4.1`, `TYPE-REFERENCE-BOOK.1.2.23.4.2`, `TYPE-REFERENCE-BOOK.1.2.23.4.3`, `TYPE-REFERENCE-BOOK.1.2.23.4.4`; remaining admission leaves split at activation.
  Count/length prerequisite: Bounded result rollout23.3.3 must land before complete fluent admission; the frozen contract is23.2.2 and bounded implementations23.3.3.1-.5 are targeted-checked; complete context/portable admission remains here.
  Known admission prerequisite: Rust scalar/default and bounded copy-arity implementations are targeted-checked; broad61.3/62.3/.62.4/copy23.3.2.5 remain open. Selected/count result implementations do not establish complete scalar families. Lua declared5.4 runtime/header proof remains LUA-STARTUP-READING.2.2.
  Goal: Independently admit complete fluent families and inter-type chains for the selected scope.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.3`
  Acceptance: Reconcile expected families and every transition in both directions against actual native/generated consumers and individual mdBook examples. Reject deliberate missing-method, wrong-return-type and continuation-dispatch faults; include empty/missing/error and backend controls. No family's final reference leaf .2-.6 or aggregate .7 closes over an unresolved assigned fluent gap. Keep scope exclusions explicit; publish no completeness claim from samples alone.
  Planned tier: Canonical admission; declare exact source-bound claim records before execution.

  Required gate prerequisite: TYPE-REFERENCE-BOOK.1.2.23.4.1 registers retained new Perl feature fixtures before this admission and any final push. Focused direct checks do not imply canonical selection.
  Artifact admission note: Rust23.3.10.2 restores action regex suffix modes in new compiled patterns. Rebuild current production derived artifacts from tracked source before promotion; previously stored nodes cannot infer discarded suffix information. Preserve immutable historical proof artifacts and their original results under their existing owners.

  Mandatory admission prerequisites: Resolve document-pressure/freshness intake1.2.20.1 and invalid-callback phase/diagnostic parity1.2.1.4.1, alongside explicit Perl registration23.4.1 and all existing backend/context prerequisites. Ordinary feature checks and known baseline gate failures do not constitute canonical admission.

  Admission prerequisite2026-10-27: TYPE-REFERENCE-BOOK.1.2.23.3.31.6.4.4 must reconcile deferred-helper readiness (coalesce recognized statically but unknown in the current CodeblockRuntime vocabulary) without inheriting eager receiver18's excluded Codeblock/deferred domain. Immediate identity/snapshot .4.1-.3 remain ahead of unrelated feature selection.

  Direct-fixture custody prerequisite:23.4.2 audits earlier capture consumers and repairs every demonstrated direct-input omission before admission; bounded67.6 closes only its specified named edges.

- ID: `TYPE-REFERENCE-BOOK.1.3`
  Status: `pending`
  Goal: Independently review the complete inventory and choose bounded canonical per-type sections and example requirements.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2`
  Planned tier: `focused`; determine any canonical trigger from actual layout/owner movement.
  Claim verification: none: Unactivated independent inventory/layout review; declare measured proof at activation.
  Acceptance: Reject distinguishing omissions/stale semantics, preserve existing anchors/includes and pressure controls, and schedule the type-specific implementation children. Inventory closeout does not admit complete reference coverage.

- ID: `TYPE-REFERENCE-BOOK.2`
  Status: `pending`
  Goal: Complete scalar/string reference and each supported associated operation.
  Dependencies: `TYPE-REFERENCE-BOOK.1`
  Acceptance: Add canonical navigation and per-operation signatures, arguments, conversions, results, empty/Unicode/missing/error cases, chaining/callback semantics and executable examples for every scalar/string inventory item. Preserve verified current behavior and existing anchors; split safely before implementation if needed.
  Planned tier: `focused`
  Claim verification: none: Future reference implementation; declare actual example/coverage proof at activation.

- ID: `TYPE-REFERENCE-BOOK.3`
  Status: `pending`
  Goal: Explain integer/real numeric behavior within the actual type model and every supported numeric operation.
  Dependencies: `TYPE-REFERENCE-BOOK.1`
  Acceptance: Resolve integer/real, scalar conversion, boolean/null and numeric validation distinctions from current contracts; document every inventoried constructor/operator/helper/method with results, precision/rounding/range/error boundaries where applicable and verified examples. State backend differences explicitly rather than inventing separate types.
  Planned tier: `focused`
  Claim verification: none: Future reference implementation; declare actual example/coverage proof at activation.

- ID: `TYPE-REFERENCE-BOOK.4`
  Status: `pending`
  Goal: Complete array reference across construction, access, mutation, pipelines and traversal.
  Dependencies: `TYPE-REFERENCE-BOOK.1`
  Acceptance: One navigable canonical array family covers every inventoried operation and alias, including updated independent mutation results, named receiver constraints, empty/non-array/error outcomes, order, chaining and callback behavior. Backfill individual worked examples rather than relying only on shared table examples; preserve existing pipeline and tree traversal contracts.
  Planned tier: `focused`
  Claim verification: none: Future reference implementation; declare actual example/coverage proof at activation.

- ID: `TYPE-REFERENCE-BOOK.5`
  Status: `pending`
  Goal: Complete hash reference across construction, lookup, mutation and traversal.
  Dependencies: `TYPE-REFERENCE-BOOK.1`
  Acceptance: Document every inventoried hash operation/alias with key/value arguments, missing-key behavior, returned values, order guarantees, mutation/aliasing and callable traversal semantics, supported forms/backend limits and individual verified examples. Preserve governed nested-write and map_leaves contracts.
  Planned tier: `focused`
  Claim verification: none: Future reference implementation; declare actual example/coverage proof at activation.

- ID: `TYPE-REFERENCE-BOOK.6`
  Status: `pending`
  Goal: Make codeblock values and all supported operations directly navigable and thoroughly documented.
  Dependencies: `TYPE-REFERENCE-BOOK.1`
  Acceptance: Canonical section covers literal/parameter forms, named and inline invocation, typed callback slots, result/return and dynamic-context behavior, mutation/composition and error cases established by inventory, with worked examples and exact backend limits. Distinguish invocation from receiver methods on a yielded typed value; list only actually supported codeblock operations.
  Planned tier: `focused`
  Claim verification: none: Future reference implementation; declare actual example/coverage proof at activation.

- ID: `TYPE-REFERENCE-BOOK.7`
  Status: `pending`
  Goal: Independently close complete per-type coverage and rendered navigation.
  Dependencies: `TYPE-REFERENCE-BOOK.2`, `TYPE-REFERENCE-BOOK.3`, `TYPE-REFERENCE-BOOK.4`, `TYPE-REFERENCE-BOOK.5`, `TYPE-REFERENCE-BOOK.6`
  Acceptance: Reconcile the entire retained inventory against canonical entries and runnable examples, verify old/new links and recursive includes, render and inspect all affected sections, and reject distinguishing omissions or stale semantics with retained controls before asserting exhaustive coverage. Update current book/status records and use canonical admission if the closeout moves public/mechanical contracts.
  Planned tier: Determine at activation from actual closeout scope.
  Claim verification: none: No coverage measurement yet; declare actual independent closeout proof before execution.

- ID: `TYPE-REFERENCE-BOOK.8`
  Status: `pending` / P3 continuity defect owned
  Goal: Reconcile the exact legacy documentation task-status contradictions encountered during intake.
  Reproduce: BOOK-DOCUMENTATION-SYNC metadata says done while its root node says active and all children/frontier are done. DOC-DRIFT-SYNC.2 says pending despite its dated Done verification and done frontier/tree-complete assertion. DOC-CODEBASE-ALIGNMENT.4/.5 say pending despite completed verification and done frontier/tree-complete assertion; several commit fields still say pending. BOOK-DOCUMENTATION-SYNC also has a four-cell Commit Log delimiter under a three-cell header, impairing table rendering.
  Impact: Contradictory task definitions can misdirect resumption or falsely reopen/close historical work; no runtime defect is inferred.
  Owned paths: `docs/tasks/BOOK-DOCUMENTATION-SYNC.md`, `docs/tasks/DOC-DRIFT-SYNC.md`, `docs/tasks/DOC-CODEBASE-ALIGNMENT.md`, exact related index/history projections and this owner.
  Schedule: Repair during the first documentation phase after the active private callback lane, alongside the reference inventory; not an active-task pivot.
  Acceptance: Audit only relevant Git subjects/diffs and dated verification records, reconcile root/leaf/frontier/commit metadata to actual accepted work, preserve every old result and historical claim, check current definitions and ordinary task/memory doctrines, and commit separately. Do not treat a stale pending field as proof that implementation is missing.
  Planned tier: `focused`
  Claim verification: none: Qualitative contradiction intake only; any new historical census or measured repair proof is declared before publication.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.18`
  Status: `active` / all bounded defined-only default backends targeted-checked; full admission separate
  Goal: Add bounded ordinary defined-only coalesce receivers and actual selected-result continuations.
  Dependencies: .23.2.18 frozen defined-default-results.md.
  Children: `.23.3.18.1`, `.23.3.18.2`, `.23.3.18.3`, `.23.3.18.4`, `.23.3.18.5`.
  Acceptance: One-or-more fallbacks, defined-only lazy once-only selection, actual String/Number/Boolean/Array/Hash kinds/copies/snapshots, compatible consumers/explicit bridges and scalar boundaries. Preserve existing free signatures/domains/callbacks and old nonempty-default behavior; no complete domain/context/portable admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.18.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary defined-only coalesce receivers and actual selected-result continuations.
  Dependencies: .23.2.18.
  Acceptance: Follow defined-default-results.md; preserve defined empty/zero/false, null exhaustion, source-first lazy once-only selection, actual scalar/container/copy/selector kinds and skipped runtime failures. One-or-more receiver fallbacks and scalar boundaries reject before forbidden effects. Public producer-first native/generated RED/GREEN plus small direct defaults/compile checks/docs/commit; no free signature/domain normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and shared result/effect/kind/shape controls, small direct default regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `c918f545af7c83b5ff0b93958a4ed141c849bc59`; defined-default freeze committed, brief0/tree clean.
  Owned paths: Perl ordinary coalesce receiver admission/lazy actual-result flow/shape boundaries, retained shared native/fresh values/effects/kinds/copies/selectors test and scoped book/fact/task/live docs. Reuse existing typed lazy/default and emitted-host machinery, preserving authored Hash colon validation and free signatures.
  Verification tier: `focused`
  Focused checks: Independent retained public producer/AST intake, shared native/fresh RED/GREEN and direct selected/literal default checks, syntax and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Owned implementation findings: Metadata-only admission fixes most shared cases, but a Hash-returning pick_keys successor falls out of the String-first loop and emits unsupported sorted_values; a text-prefix rejected Hash consumer lowers to constantundef and loses SC. Public Get/substitution/native/fresh reproduce both. Complete this new receiver chain through the existing actual-value/host compatibility loop, preserving source effects before rejection and actual Hash results.
  Additional P2 defect owned/scheduled: Public free pick_keys(chosen,{order=cat(order,"C");meta["a"]="z";"a"}) retains a raw DSL key block in emitted host foreach and fails handler/fresh compilation. A new explicit key-variable control separates this pre-existing free-key staging defect from receiver flow; The same key-block staging defect blocks the new fluent Hash snapshot consumer after dispatch repair, so repair it now within18.1 using the existing typed block lowerer and retain a direct free-key control; no separate18.1.1 pivot. The initial failing free-block expression is not a passing oracle.

  Completion: Admit coalesce as default_result with a pre-effect one-or-more-fallback guard. Chains containing this new method share the established logical/actual-value dispatcher and emitted-host finishing, retaining actual Hash/Array transitions and source/prefix effects before scalar rejection. Bind the fully lowered source once in scalar context inside the host bridge, preserving valid direct Hash literal identity without reparsing host fat arrows as retired authored syntax. Lower actual pick_keys key blocks with the existing typed block bridge; ordinary key forms/free signatures remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared native/fresh RED has raw receiver DSL compile errors. Metadata-only admission exposes Hash successor unsupported sorted_values and dropped SC before a rejected scalar tail; public substitution retains both mechanisms. Direct free pick_keys key-block control fails host compilation with raw DSL foreach operand; it also blocks the new fluent Hash consumer.
  - [x] ROOT CAUSE (WHY + WHERE): Missing receiver return family/shape metadata, String-first loop lacking Hash handoff and terminal constantundef discarding a valid prefix. The new scoped typed-source handoff initially reparses emitted Hash arrows, then an unbound bare Hash block loses reference kind; public AST/substitution distinguish authored hash_literal from emitted host syntax. pick_keys legacy key normalization lacks typed block lowering.
  - [x] FIX: Scoped actual-result/host compatibility composition, scalar-bound source and pre-effect coalesce shape guard; existing typed block lowerer for pick_keys key operands. No raw authored fallback, parser/schema/free signature/numeric/truth/callback/domain normalization. Fix the blocking key defect in this leaf rather than defer an unworking Hash snapshot consumer.
  - [x] ADDRESSED (verified): New13 native/fresh checks pass strict selected kinds, empty/zero/false/exhaustion, eight source families, String-to-Array bridge, numeric indices, chosen Array/Hash copies, SDC/SC/once-only snapshots, skipped effects/runtime error, Hash key C mutation/capture, rejected source/prefix effects and malformed zero-RHS no-effects. Retired authored Hash arrows still reject.
  - [x] NO REGRESSION: Direct existing selected-default5 and logical rejected-effect12 checks pass; source/test/probe syntax and final changed fixture pass,30 focused top-level checks across retained runs. Later source wrapping only affects new coalesce receiver chains. No broad suites/full matrix/portable admission; every new Perl fixture needs explicit23.4.1 runner registration.
  - [x] LOCKSTEP: Shared fixture/test, retained public Hash/prefix/AST controls, frozen contract/current qualified catalog/guide and canonical default fact/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Rust18.2 independently assesses its producer next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.18.1 - add Perl defined-only default receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.18.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary defined-only coalesce receivers and actual selected-result continuations.
  Dependencies: .23.3.18.1.
  Acceptance: Follow defined-default-results.md; preserve defined empty/zero/false, null exhaustion, source-first lazy once-only selection, actual scalar/container/copy/selector kinds and skipped runtime failures. One-or-more receiver fallbacks and scalar boundaries reject before forbidden effects. Public producer-first native/generated RED/GREEN plus small direct defaults/compile checks/docs/commit; no free signature/domain normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and shared result/effect/kind/shape controls, small direct default regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `1ad4335927d71adb22e331d61ebe7df2fd578046`; Perl defined-default receivers committed, brief0/tree clean.
  Owned paths: Rust independently confirmed defined-only receiver admission/lazy actual-result/scalar/shape flow and retained native/restored/in-process generated-plan public producer/shared regression, scoped book/fact/task/live docs. Preserve free signatures/domains/callbacks and compiled formats; no standalone emitted Rust admission.
  Verification tier: `focused`
  Focused checks: Producer-first public native/restored/plan and shared receiver RED/GREEN, direct selected/nonempty defaults as warranted, offline compile/rustfmt and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: Native/restored/plan free/nested producer controls pass strict defined kinds/laziness/copies/Number selector writes before production. Shared receiver RED reaches a deliberately unused typed nested-write failure, proving eager evaluation of a fallback. engine fluent String admission/lazy handling only knows coalesce_nonempty, so coalesce falls to generic eager helper invocation without receiver normalization. Add only the frozen counterpart metadata/lazy/scalar/pre-effect-shape handling; no free helper change.

  Completion: Admit coalesce alongside nonempty defaults in String/dynamic receiver dispatch, select the existing lazy default policy by helper spelling, hand actual selections to shared continuation and mark the new method's scalar results until a container is returned. Common zero-RHS preflight precedes source/consumer effects. No free helper/producer/domain/schema/callback change.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent native/restored/plan free/nested producer controls pass strict defined empty/zero/false/null/container values, skipped effects/failure, copies and numeric selector writes. Shared native RED reaches the deliberately unused nested_write_kind_conflict failure before returning a value; other pre-change shared fields are not inferred.
  - [x] ROOT CAUSE (WHY + WHERE): engine fluent String method admission, dynamic lazy branch and actual-selection handoff include only coalesce_nonempty. coalesce falls through generic eager helper invocation without the source operand. Common preflight and selected-result scalar tracking also lack the new counterpart's shape/result metadata.
  - [x] FIX: Add the bounded counterpart to existing String/lazy/result dispatch and one-or-more receiver preflight; reuse eval_coalesce_args/coalesce_accepts and selected actual-value flow. Preserve all free signatures/truth/numeric/context/copy policies and compiled formats.
  - [x] ADDRESSED (verified): Shared native/restored/in-process plan GREEN preserves exact scalar/container kinds, all source families, empty containers, SDC/SC/Hash-C snapshots, chosen copies/Number indices, skipped supported runtime errors and rejected-prefix/operand effects. Extra selected/named/Boolean/malformed controls give fournull/emptyorder, with no forbidden source or consumer effect.
  - [x] NO REGRESSION: New3 and direct nonempty/selected default3 tests pass, six focused tests total, with offline compilation and rustfmt. No broad suite/full matrix, standalone emitted Rust or complete portable domain/context admission.
  - [x] LOCKSTEP: Retained public producer/shared/selected controls, frozen contract/current qualified catalog/guide and canonical default fact/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Dart18.3 independently assesses next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.18.2 - add Rust defined-only default receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.18.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary defined-only coalesce receivers and actual selected-result continuations.
  Dependencies: .23.3.18.2.
  Acceptance: Follow defined-default-results.md; preserve defined empty/zero/false, null exhaustion, source-first lazy once-only selection, actual scalar/container/copy/selector kinds and skipped runtime failures. One-or-more receiver fallbacks and scalar boundaries reject before forbidden effects. Public producer-first native/generated RED/GREEN plus small direct defaults/compile checks/docs/commit; no free signature/domain normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and shared result/effect/kind/shape controls, small direct default regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `03008322bb320d137ebecc4c9f243bdde01ff887`; Rust defined-default receivers committed, brief0/tree clean.
  Owned paths: Dart independently confirmed defined-only receiver actual-result/scalar/shape flow and retained native/restored/generated-plan public producer/shared/selected regression, scoped book/fact/task/live docs. Preserve free signatures/domains/callbacks, named-context normalization and serialized formats.
  Verification tier: `focused`
  Focused checks: Producer-first public native/restored/plan and shared receiver RED/GREEN, direct selected/nonempty defaults, format/fatal selected analysis and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: Correct package-directory producer run passes native/restored/plan defined kinds/lazy copies/Number indices. Shared native RED preserves valid selection/source/default/SDC-SC-HashC flow but gives rejected/after_text [] and reject_order SA; zero-RHS malformed chain runs SC. Selected controls give[[],[],null,1!,SC]. Existing _callCoalesceWithReceiver already handles defined-only laziness; missing scalar-result tracking and common shape guard own the gaps. Initial root-directory test invocation only reports missing pubspec and is not semantic RED.

  Completion: Add coalesce to mayProduceScalar and common one-or-more receiver preflight. Reuse already-correct defined-only lazy selection/actual container release; preserve all free/helper/numeric/callback/named-context/format policies.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent native/restored/plan free/nested producers pass defined kinds/lazy skipped failure/copies/Number indices. Shared native RED yields rejected/after_text [] and reject_order SA, while valid selection/SDC-SC-HashC/snapshots already hold. Malformed zero-RHS executes SC; selected controls give[[],[],null,1!,SC].
  - [x] ROOT CAUSE (WHY + WHERE): _evaluateFluentCallsWithValue mayProduceScalar omits coalesce, permitting container fallthrough and operands; common ActionFluentChainExpr preflight lacks its shape. _callCoalesceWithReceiver already preserves required defined-only selection, so no producer repair inferred.
  - [x] FIX: Track the new method's scalar results until an actual List/Map releases the boundary; reject zero fallbacks before source/consumer effects. No free arity/domain/context/schema/callback or lazy helper change.
  - [x] ADDRESSED (verified): Shared native/restored/plan GREEN preserves exact kinds/empty/zero/false/exhaustion/containers/sources, SDC/SC/HashC snapshots, independent copies/indices/skipped errors, source/prefix effects before rejection and no forbidden consumer operands. Extra selected/named/Boolean/malformed controls yield fournull/emptyorder.
  - [x] NO REGRESSION: New3/direct selected/nonempty default3 tests pass, six focused tests, plus format/fatal selected analysis. Initial root-directory missing-pubspec invocation is corrected and not credited as semantic RED. No broad suite/matrix/standalone/complete portable admission; existing named-context normalization remains unchanged.
  - [x] LOCKSTEP: Retained producer/shared/selected test, frozen contract/current qualified catalog/guide and canonical default fact/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia18.4 independently assesses next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.18.3 - guard Dart defined-only default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.18.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary defined-only coalesce receivers and actual selected-result continuations.
  Dependencies: .23.3.18.3.
  Acceptance: Follow defined-default-results.md; preserve defined empty/zero/false, null exhaustion, source-first lazy once-only selection, actual scalar/container/copy/selector kinds and skipped runtime failures. One-or-more receiver fallbacks and scalar boundaries reject before forbidden effects. Public producer-first native/generated RED/GREEN plus small direct defaults/compile checks/docs/commit; no free signature/domain normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and shared result/effect/kind/shape controls, small direct default regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `3f1a386d0c9b48268b02b07e51aa68728b5a80fa`; Dart defined-default results committed, brief0/tree clean.
  Owned paths: Julia independently confirmed defined-only receiver actual-result/scalar/shape flow and retained native/plan/fresh public producer/shared/selected regression with strict Bool/Number distinctions, runner registration and scoped book/fact/task/live docs. Preserve free signatures/domains/callbacks/named-context/serialized formats.
  Verification tier: `focused`
  Focused checks: Producer-first public native/plan/fresh and shared receiver RED/GREEN, direct selected/nonempty defaults, strict compilation and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: Producer-first strict native/plan/fresh controls pass12 assertions before code. Shared all three routes preserve selection/snapshots/copies/indices/skipped errors but expose rejected/after_text [] with SA and malformed SC. Selected controls[[],[],null,1!,SC] on all three. _evaluate_runtime_fluent_chain! lacks coalesce in may_produce_scalar and one-or-more preflight; existing _runtime_coalesce_accepts/lazy receiver path already works. No producer/free repair inferred.

  Completion: Add coalesce to common one-or-more receiver preflight and may_produce_scalar. Reuse already-correct lazy defined-only selection, actual container release and ordinary copy/Hash-key/source flow. Register the retained strict native/plan/fresh producer/shared/selected test.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent strict native/plan/fresh producer-first12 pass. Shared all three routes expose rejected/after_text [] and SA, malformed SC; selected controls give[[],[],null,1!,SC]. Existing actual values/SDC-SC-HashC/copies/Number indices/skipped failures already hold.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! lacks coalesce in common shape preflight/may_produce_scalar, permitting scalar container normalization/operand effects and zero-RHS source effects. Existing lazy _runtime_coalesce_accepts/receiver/copy policy is correct; no producer defect inferred.
  - [x] FIX: New counterpart scalar-result tracking until AbstractVector/AbstractDict output releases the boundary and zero-RHS rejection before source/consumer effects. No parser/schema/free signature/domain/numeric/callback/named-context normalization; register the test in runtests.
  - [x] ADDRESSED (verified): New36 native/plan/fresh assertions pass shared exact values/bridges/source families, strict false identity and Number-not-Bool counters/results, empty containers/exhaustion, SDC/SC/HashC snapshots/copies/indices/skipped runtime errors, rejected-prefix effects and forbidden operand suppression. Selected/malformed controls yield fournull/emptyorder.
  - [x] NO REGRESSION: Direct selected/nonempty defaults9 assertions also pass,45 total with strict compilation. No full suite/matrix/complete portable admission, callback-identity or blanket named-context repair is claimed.
  - [x] LOCKSTEP: Retained test/runner, frozen contract/current qualified catalog/guide and canonical default fact/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Safe Lua18.5 independently assesses next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.18.4 - guard Julia defined-only default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.18.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary defined-only coalesce receivers and actual selected-result continuations.
  Dependencies: .23.3.18.4.
  Acceptance: Follow defined-default-results.md; preserve defined empty/zero/false, null exhaustion, source-first lazy once-only selection, actual scalar/container/copy/selector kinds and skipped runtime failures. One-or-more receiver fallbacks and scalar boundaries reject before forbidden effects. Public producer-first native/generated RED/GREEN plus small direct defaults/compile checks/docs/commit; no free signature/domain normalization or full admission.
  Safety scope: Only safe available PUC5.5.1/LuaJIT fixtures; exclude malformed native patterns/full runner. Declared5.4 remains separately owned.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and shared result/effect/kind/shape controls, small direct default regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `266ae756e44eeb672c6e8752b42dab7e23c5d272`; Julia defined-default results committed, brief0/tree clean.
  Owned paths: Lua independently confirmed defined-only receiver actual-result/scalar/shape flow and safe retained native/plan/fresh public producer/shared/selected regression, safe named runner registration and scoped book/fact/task/live docs. Preserve free signatures/domains/callbacks/named-context/formats and module-local ceiling; no full runner or malformed native pattern execution.
  Verification tier: `focused`
  Focused checks: Producer-first public native/plan/fresh and shared receiver RED/GREEN plus direct selected/nonempty defaults/source loads on safe PUC5.5.1/LuaJIT, book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; declared5.4/full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: Both safe available hosts pass canonical JSON native/plan/fresh free/nested producer controls before production. Shared native RED gives scalar rejected/after_text [] with reject_order SA and malformed SC; valid selection/source/snapshot/copy/index/skipped-error values remain. evaluate_fluent_calls already invokes defined-only evaluate_coalesce but marks only nonempty defaults scalar; common preflight lacks the new one-or-more shape. Repair only these metadata guards, with no new module locals/free helper changes.

  Completion: Both coalesce receiver branches mark scalar_result before existing actual-container release; common zero-RHS preflight precedes source/consumer effects. Register safe retained producer/shared/selected checks, with no new module locals or helper/free/named-context/format/callback changes.
  Verification:
  - [x] REPRODUCE / ISSUE: Both PUC5.5.1/LuaJIT pass canonical JSON native/plan/fresh producer-first controls before code. Shared native RED has scalar[]/SA and malformed SC; valid source/selection/SDC-SC-HashC/copies/indices/skipped-runtime-error fields already hold. No unobserved backend error is inferred.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls already calls defined-only evaluate_coalesce, but marks only nonempty defaults scalar, permitting incompatible container helpers/operands. Common fluent preflight lacks the new counterpart's one-or-more fallback shape. No producer/domain/free-signature repair is needed.
  - [x] FIX: Mark both default selections scalar before actual Array/Harray release and add coalesce zero-RHS preflight. Retain existing lazy/copy/context/truth/numeric policies and module-local ceiling; register only a safe named test group.
  - [x] ADDRESSED (verified): Both hosts pass canonical JSON native/plan/fresh producer/shared/selected controls, preserving real Bool/Number/String/null/container kinds, empty/zero/false/exhaustion, source families, chosen copies/indices/SDC-SC-HashC snapshots, skipped supported failures and incompatible operands, source/prefix effects before rejection and malformed no-effects.
  - [x] NO REGRESSION: Direct existing selected/nonempty default fixtures and interpreter/runner source loads pass on both hosts. No full runner/malformed native patterns, declared5.4, broad matrix or complete portable domain/context admission claim.
  - [x] LOCKSTEP: Retained test/safe runner, frozen contract/all-five bounded progress and qualified catalog/guide, canonical default fact/map plus task/live/resume align. Next pure String result assessment23.2.19 is owned before any new diagnostic/change. Book/history/diff/final staged memory/cadence/diagnosis checked before commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.18.5 - guard Lua defined-only default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.19`
  Status: `active` / all bounded scalar String backends targeted-checked; domain20/full admission separate
  Goal: Complete bounded actual scalar String-helper results, identity kinds and clean scalar/shape boundaries.
  Dependencies: .23.2.19 frozen scalar-string-results.md.
  Children: `.23.3.19.1`, `.23.3.19.2`, `.23.3.19.3`, `.23.3.19.4`, `.23.3.19.5`.
  Acceptance: Preserve existing eight helper/free/Unicode/null/conversion domains and actual identity kinds; compatible scalar/generic/numeric/explicit Array flow, once-only snapshots/effects, clean scalar rejection and pre-effect ordinary shapes. No full domain/context/portable admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.19.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary scalar String-helper result flow and boundaries.
  Dependencies: .23.2.19.
  Acceptance: Follow scalar-string-results.md; preserve eight helper domains/null/empty/Unicode/strict cat policies, actual identity Number/Boolean/String kinds, source-first once-only operands/snapshots and scalar/generic/numeric/explicit Array bridges. Clean incompatible-consumer and malformed-shape boundaries retain permitted effects and skip forbidden ones. Public producer-first native/generated RED/GREEN plus small direct String/compile checks/docs/commit; no free signature/selector/callback normalization or full admission.
  Owned P1 defect: Free/fluent/named unmatched affix numeric identity loses typed Array-index kind despite numeric JSON; inspect a copy during index/length/substr tests, preserving original Number/Boolean/String value. Retain exact selector/B-flag distinctions and unchanged String-key rejection. Repair here before Rust; reducer95 remains separate.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and retained result/effect/kind/shape controls, small direct String regression/source compilation/book/continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `9eb55615dc568652ae3cd8882f27be7d1ab9234e`; scalar String freeze committed, brief0/tree clean.
  Owned paths: Perl eight scalar String-helper actual-result/scalar/shape composition and affix identity copy inspection, retained shared native/fresh values/effects/Unicode/typed-selector regression and scoped book/facts/task/live docs. Preserve dedicated mutation/traversal/callback routes, authored Hash colon checks, typed selectors and free signatures.
  Verification tier: `focused`
  Focused checks: Public producer/AST/identity flag intake and retained shared native/fresh RED/GREEN, direct scalar-text/default/logical rejection checks as warranted, syntax and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Classify the eight scalar String helpers as scalar_result and validate ordinary receiver shapes through existing free arity metadata before effects. Ordinary transform chains reuse the established typed actual-result/emitted-host loop, preserving source/prefix effects before rejection and actual Array bridges. Dedicated mutation/traversal dispatch remains on its existing route. Affix matching inspects a scalar copy, returning the untouched original on identity and actual substring text on match.
  Verification:
  - [x] REPRODUCE / ISSUE: New native/fresh shared RED fails compilation on raw boundary/malformed DSL. Retained public free/fluent/named prefix/suffix Number indices fail typed harray-vs-array; replacement/literal0 controls pass. Pre-JSON flags distinguish contaminated IOK+POK from numeric IOK-only and String POK-only.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering String metadata/composition lacks a scalar rejection boundary after transforms, while common preflight lacks their ordinary shapes. rm_prefix/rm_suffix inspect the original Number via index/length/substr, adding POK honored by BindingRuntime. This is producer contamination, not a selector-kind bug or Number/JSON encoding policy change.
  - [x] FIX: Central scalar String helper classifier, existing arity metadata/typed result/host compatibility dispatch and once-bound scalar source; preserve dedicated routes and authored Hash colon checks. Inspect affix text copies and return original identities. No free signature/Unicode/null/strict cat/numeric/selector/callback normalization.
  - [x] ADDRESSED (verified): New7 native/fresh shared checks pass all eight texts/nested/bridges/boundaries/empty/null, Unicode expansion/final-sigma/emoji substring, eight source roots, numeric/generic consumers, identity Number/Bool/String and matched text keys. Free/fluent/named Array writes pass; String0/matched/empty keys remain Hash keys. SONC/SC/selected-S/once-only snapshots, eager null operands, rejected-consumer operand skipping and12 malformed no-effects hold. Public flags now show IOK-only numeric affix identities and POK-only String0 on both routes.
  - [x] NO REGRESSION: Direct scalar-text7/nonempty-default5 and new7 pass,19 focused top-level checks plus module/test/probe syntax. Authored retired Hash arrows still reject. No broad suite/matrix/portable admission, reducer95, large-number/unary-cat or mutation/callback admission claim. Every new Perl fixture still requires23.4.1 registration.
  - [x] LOCKSTEP: Shared fixture/test, retained public flags/probe/frozen contract, current qualified catalog/guide and canonical String/null facts/map plus task/live/resume align. Remove the temporary identity limitation from current book; typed Array-index examples now work. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Rust19.2 independently assesses next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.19.1 - preserve Perl scalar String result kinds`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.19.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary scalar String-helper result flow and boundaries.
  Dependencies: .23.3.19.1.
  Acceptance: Follow scalar-string-results.md; preserve eight helper domains/null/empty/Unicode/strict cat policies, actual identity Number/Boolean/String kinds, source-first once-only operands/snapshots and scalar/generic/numeric/explicit Array bridges. Clean incompatible-consumer and malformed-shape boundaries retain permitted effects and skip forbidden ones. Public producer-first native/generated RED/GREEN plus small direct String/compile checks/docs/commit; no free signature/selector/callback normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and retained result/effect/kind/shape controls, small direct String regression/source compilation/book/continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `ea6f82c2ac8e216bcfd721a42d10b713a24c5dc1`; Perl scalar String flow/affix identity repair committed, brief0/tree clean.
  Owned paths: Rust independently confirmed scalar String-helper actual-result/scalar/shape flow and retained native/restored/in-process generated-plan public producer/shared/selector regression, scoped book/facts/task/live docs. Preserve free domains/null/Unicode/strict cat/callbacks and compiled formats; no standalone Rust admission.
  Verification tier: `focused`
  Focused checks: Producer-first public native/restored/plan and shared result RED/GREEN, direct scalar-null/predicate/default checks as warranted, offline compile/rustfmt and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: Producer-first native/restored/plan free values/Unicode/identity selectors/order pass before code. Shared native RED preserves basic outputs/bridges/identities/Unicode but runs rejected SCA/selected SA, returns selected[] and malformed values with SASSSASSSSSSSSC. Null source substr also yields emptyString rather than the catalog's null; isolate free explicit-null source/start and eager operand order before classifying/repairing this additional source boundary. Own confirmed null defect here with the result/shape changes, without inferring other backend failure.

  Additional source defect: Independent Rust free/fluent null source/start test returns[empty,abc,empty,abc,SIL] instead ofnulls/SIL. The ordinary substr arm textifies undef and defaults its null start before guarding; dedicated regex mutation exits earlier and must stay untouched. Public Perl native boundary control also confirms fractional start/width normalize0, Boolean true keeps its existing offset1 compatibility, and provided-null width returnsnull. Retain the reference in the public probe and extend the independent Rust control before narrowing the ordinary slice fix. Preserve free unary/extra-arity policy and dedicated mutation; no global numeric normalization.

  Completion: Mark all eight String-helper results scalar in existing selected-result dispatch and add precise ordinary receiver shapes to common preflight. Independently confirmed ordinary substr source/start/provided-width null and fractional start/width defects now guard null before coercion and normalize nonnegative whole offsets, after dedicated regex mutation exits. Retain optional omitted width, Boolean offset compatibility, free unary/extra arity and named-target mutation policies.
  Verification:
  - [x] REPRODUCE / ISSUE: Producer-first native/restored/plan free values/Unicode/identity selectors/order pass. Shared native RED preserves valid output but runs rejected SCA/selected SA, returns selected[] and malformed nonnull/effects; null substr yields emptyString. Independent free/fluent null test gives[empty,abc,empty,abc,SIL], and expanded bounds RED truncates fractional start/width instead of normalizing0.
  - [x] ROOT CAUSE (WHY + WHERE): engine scalar-result list omits the eight methods and common preflight lacks their ordinary shapes; String loop evaluates incompatible operands before rejecting. Ordinary substr converts undef with to_str/as_number before guards and casts fractional numbers directly to usize. Retained public Perl native/fresh bounds return null/null/abc/a/empty/empty/bc/null, distinguishing the correct source/start/width/fraction/negative/Boolean rules. Regex mutation returns earlier in its dedicated arm.
  - [x] FIX: Existing scalar/result tracking and precise receiver preflight; ordinary two/three-operand null guard plus local whole-offset normalization after dedicated mutation dispatch. No global numeric/selector/Unicode/free-arity/schema/callback normalization or affix producer change.
  - [x] ADDRESSED (verified): Shared native/restored/in-process plan GREEN preserves all eight outputs/bridges/empty/null/Unicode/source roots, exact identity/matched keys/Array indices, scalar/generic/numeric flow, SONC/SC/selectedS snapshots/eager null operands, prefix effects/skipped incompatible operands and12 malformed no-effects. Independent substring null/fraction/negative/Boolean/optional-width controls retain SIL; both named-target substr/regex_subst mutation controls return xbx/yba.
  - [x] NO REGRESSION: New4/direct scalar-null1/scalar-predicate1/nonempty-default1 tests pass, seven focused tests, with offline compile/rustfmt and probe syntax. No broad suite/matrix, standalone Rust or complete portable/domain admission; old unary-cat/large-number/reducer95/callback owners remain separate.
  - [x] LOCKSTEP: Retained test/primary probe, frozen contract/current qualified catalog/guide and canonical String/null facts/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Dart19.3 independently assesses next, including observed substring boundaries.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.19.2 - guard Rust scalar String results and slices`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.19.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary scalar String-helper result flow and boundaries.
  Dependencies: .23.3.19.2.
  Acceptance: Follow scalar-string-results.md; preserve eight helper domains/null/empty/Unicode/strict cat policies, actual identity Number/Boolean/String kinds, source-first once-only operands/snapshots and scalar/generic/numeric/explicit Array bridges. Clean incompatible-consumer and malformed-shape boundaries retain permitted effects and skip forbidden ones. Public producer-first native/generated RED/GREEN plus small direct String/compile checks/docs/commit; no free signature/selector/callback normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and retained result/effect/kind/shape controls, small direct String regression/source compilation/book/continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `bbb8d0dddc802a9637c678d818666eb155a28a7d`; Rust scalar String/slice fixes committed, brief0/tree clean.
  Owned paths: Dart independently confirmed scalar String-helper actual-result/scalar/shape and observed slice-boundary flow, retained native/restored/generated-plan public producer/shared/slice/mutation regression, scoped book/facts/task/live docs. Preserve free domains/Unicode/strict cat/identity/callbacks/named-context/serialized formats; assess producer defects independently.
  Verification tier: `focused`
  Focused checks: Producer-first public native/restored/plan and shared/slice RED/GREEN, direct selected/default or String checks as warranted, format/fatal selected analysis and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent producer finding: Initial free producer/index control fails native typed harray-vs-array before receiver code, so no producer-pass or shared result is credited. _callRemoveEdge and _callReplaceSubstr return coerced String on identity, violating published original Number/Boolean kinds. Their explicit null replacement/affix operands also use nullAsEmpty despite published null propagation; isolate raw identity/null and healthy String/Unicode/eager controls plus receiver boundaries before production. Preserve existing regex/other scalarization compatibility and do not infer argument domains from another backend.

  Confirmed intake: Basic String/Unicode/strict-null/SON controls pass native/restored/plan. Native identity/null operands yield[String0,String0,String0,String0,String0,String0,abc,bc,abc,abc]; receiver control gives[[],SCA,null,SAC]. Full shared aborts on prefix identity index. Existing named-target mutation passes. Slice source/start null already work; fractional Number indices truncate. Dart intentionally treats provided-null width as omitted and Boolean offset as invalid0, unlike the recorded Perl/Rust compatibility. Preserve those two existing input-domain conventions in this result slice; explicit reconciliation is P2 assessment20 before portable admission, not an inferred backend defect/promotion.

  Completion: Add eight-method scalar-result tracking and precise common receiver preflight. Preserve Number/Boolean identity for empty-old replacement/empty-unmatched affixes, retaining existing text behavior for other scalarized carriers. Guard explicit null replacement/affix operands without changing non-null scalarization admission. Normalize fractional slice offsets locally, preserving Dart provided-null-width/Boolean-offset conventions and dedicated mutation; concrete domain reconciliation20 is scheduled before portable admission.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent healthy basic String/Unicode/strict-null/eager SON producers pass native/restored/plan. Separate identity/null source RED gives six String0 then abc/bc/abc/abc instead of typed identities/nulls; typed Array index aborts original/shared producers. Receiver RED gives[[],SCA,null,SAC]; slice RED truncates fractional Numbers. Both named-target mutation aliases already pass.
  - [x] ROOT CAUSE (WHY + WHERE): _callReplaceSubstr/_callRemoveEdge return coerced text on identity and nullAsEmpty masks explicit null operands. _evaluateFluentCallsWithValue scalar list/common preflight omit eight methods/shapes. _callSubstr uses global _intValue truncation; its intentional null-width-as-omitted/Bool-invalid-zero rules are distinct domain conventions, not inferred failures against Perl expectations.
  - [x] FIX: Preserve only supported Number/Boolean originals on identity, keep other scalarized text behavior, add explicit positional null guards, eight-method result set/ordinary shape guards and local fractional offset normalization. No global numeric/int helper, selector, Unicode, free arity, regex/callback, named-context or aggregate domain normalization. Source input-domain assessment20 owns width/Bool policy before any promotion.
  - [x] ADDRESSED (verified): All seven new native/restored/plan tests pass: healthy/identity/null producers, source boundary control, full shared values/bridges/empty/null/Unicode/roots, strict Number/Bool/String/matched keys and free/fluent/named Array indices, SONC-SC-selectedS snapshots/eager null operands and12 malformed no-effects. Independent slice controls preserve SIL/current width/Bool conventions; both mutation aliases return xbx/yba.
  - [x] NO REGRESSION: Direct selected/nonempty default3 also pass, ten focused tests total, plus format/fatal selected analysis. Existing large-number2.12/Unicode ordering2.13/large-slice end overflow2.14 remain separately owned. No full suite/matrix/standalone/complete portable/domain admission; existing regex/other carrier scalarization is preserved rather than promoted.
  - [x] LOCKSTEP: Retained producer/shared/slice/mutation tests, frozen/current qualified catalog/guide and canonical Dart/String/null facts/map plus task/live/resume align. P2 assessment20 has exact reproduction, impact, mandatory schedule and repair ownership before23.4; no width/Bool universal promise. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia19.4 independently assesses next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.19.3 - preserve Dart scalar String result kinds`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.19.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary scalar String-helper result flow and boundaries.
  Dependencies: .23.3.19.3.
  Acceptance: Follow scalar-string-results.md; preserve eight helper domains/null/empty/Unicode/strict cat policies, actual identity Number/Boolean/String kinds, source-first once-only operands/snapshots and scalar/generic/numeric/explicit Array bridges. Clean incompatible-consumer and malformed-shape boundaries retain permitted effects and skip forbidden ones. Public producer-first native/generated RED/GREEN plus small direct String/compile checks/docs/commit; no free signature/selector/callback normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and retained result/effect/kind/shape controls, small direct String regression/source compilation/book/continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `ebe047c11996a5f87c16777d4538cd8e022e79e7`; Dart scalar String fixes/qualified domain20 schedule committed, brief0/tree clean.
  Owned paths: Julia independently confirmed scalar String-helper producer/result/scalar/shape and qualified slice flow, retained public native/plan/fresh diagnostic and strict result/identity/selector/slice/mutation regression, runner and scoped book/facts/task/live docs. Preserve free domains/Unicode/strict cat/callbacks/formats and observed width/Bool conventions pending20; no inferred backend failures.
  Verification tier: `focused`
  Focused checks: Public producer-first native/plan/fresh and strict shared/kind/shape RED/GREEN, direct selected/default checks as warranted, strict compilation and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: Retained public probe observes all native/plan/fresh routes before code: identities are six String0 then abc/bc/abc/abc, numeric selector producers/shared abort with typed harray-vs-array, boundaries give[[],SCA,null,SAC]. Substring source/start null and fractional normalization already work; provided-null width is omitted, Bool offset keeps1 (abc/SIL/abc/a/empty/empty/bc). Both mutation aliases pass. Own identity/null operand/scalar/shape repairs here; preserve those qualified slice conventions under20 and existing large-slice2.10 owner. Add a healthy basic String/Unicode/SON control before implementation; do not infer unreturned shared fields.

  Completion: Preserve Number/Boolean original identities in empty-old replacement/empty-unmatched affix removal while other scalarized carriers retain text; guard explicit null operands without changing non-null scalarization. Add eight-method scalar-result tuple and precise receiver preflight. Fractional/null source/start slicing already works; preserve provided-null-width-as-omitted and Bool-offset1 conventions under scheduled20, with no substring/global int change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/plan/fresh probe independently returns textified identity/null data, typed selector errors on producer/shared and boundary[[],SCA,null,SAC]. Healthy basic String/Unicode/strict-null/SON tests pass3 before code. Strict RED captures15 failures/two producer errors; bounds/mutation routes already work and their data is not inferred from Dart.
  - [x] ROOT CAUSE (WHY + WHERE): _call_runtime_replace_substr/_call_runtime_remove_edge return coerced text and null_as_empty masks explicit null operands. Common _evaluate_runtime_fluent_chain! omits eight methods in scalar tuple/shapes. Ordinary substring already normalizes fractions/null source/start, with its own qualified optional-width/Bool conventions.
  - [x] FIX: Supported scalar originals on identity (Number includes Bool; strict tests distinguish them), positional null guards retaining other conversion compatibility, eight-method scalar/ordinary shape tuples and runner registration. No global numeric/int/selector/Unicode/free signature/regex/callback/named-context/schema change; dedicated mutation routes stay.
  - [x] ADDRESSED (verified): Registered new54 native/plan/fresh assertions pass all seven groups: healthy/identity/null producers, boundary effects, typed free/fluent/named selector producers, shared eight helper values/bridges/empty/null/Unicode/roots, strict Number-not-Bool/false identity/counters and matched String keys, SONC-SC-selectedS snapshots/eager null operands, rejection/12 malformed no-effects, qualified slice domains/SIL and both mutation aliases.
  - [x] NO REGRESSION: Direct selected/nonempty defaults9 pass too,63 assertions with strict compilation. Retained diagnostic basic case executes on all three routes after cleanup of its unused parameter. Existing callback identity2.8/large-number2.9/unsafe large-slice2.10 remain separate; no full suite/matrix/portable admission or blanket producer-domain closure.
  - [x] LOCKSTEP: Retained public probe/test/runner, frozen/current qualified catalog/guide and canonical Julia/String/null facts/map plus task/live/resume align. Domain20 now records Julia width-omitted/Bool1 separately from Dart width-omitted/Bool0 and Perl/Rust null-width/Bool1; mandatory schedule stays after19.5 before admission. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Safe Lua19.5 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.19.4 - preserve Julia scalar String result kinds`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.19.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary scalar String-helper result flow and boundaries.
  Dependencies: .23.3.19.4.
  Acceptance: Follow scalar-string-results.md; preserve eight helper domains/null/empty/Unicode/strict cat policies, actual identity Number/Boolean/String kinds, source-first once-only operands/snapshots and scalar/generic/numeric/explicit Array bridges. Clean incompatible-consumer and malformed-shape boundaries retain permitted effects and skip forbidden ones. Public producer-first native/generated RED/GREEN plus small direct String/compile checks/docs/commit; no free signature/selector/callback normalization or full admission.
  Safety scope: Only safe available PUC5.5.1/LuaJIT fixtures; exclude malformed native patterns/full runner. Declared5.4 remains separately owned.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and retained result/effect/kind/shape controls, small direct String regression/source compilation/book/continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `1b69aba951d1e9748988e652430988e6f92ca584`; Julia scalar String fixes/qualified domain20 inventory committed, brief0/tree clean.
  Owned paths: Lua independently confirmed scalar String producer/result/scalar/shape and qualified slice flow, safe retained public native/plan/fresh diagnostic/test and named runner registration, scoped book/facts/task/live docs. Preserve module-local ceiling/free domains/Unicode/strict cat/callbacks/formats; observe width/Bool conventions under20. Only safe PUC5.5.1/LuaJIT; no full runner/malformed native patterns.
  Verification tier: `focused`
  Focused checks: Safe public producer-first native/plan/fresh and strict result/kind/shape RED/GREEN, direct selected/default fixtures/source loads on both hosts, book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; declared5.4/full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: After correcting the diagnostic metadata row to public json.harray (plain tables are intentionally ambiguous), both hosts pass basic String/Unicode/strict-null/SON on native/plan/fresh. All routes show textified identity/null data, typed producer/shared selector failures and boundaries[[],SCA,null,SAC]. Slice source/start null/fractions and both mutation aliases already work; width-null is omitted and Bool offset invalid0, matching Dart's qualified conventions under20. Own producer identity/null/scalar/shape repairs here; no result inferred from another backend. The same ordinary substring branch adds start+width before clipping; assess a single safe large-width public distinction before changing that arithmetic, without a magnitude matrix or malformed patterns.

  Owned P1 substring defect: Safe public large_end/native-plan-fresh gives PUC[abc,empty,empty] versus LuaJIT[abc,bc,bc] for width9223372036854775807 at offsets0/1. This matches the published clipping contract/retained primary large-slice reference; current start+width wraps the PUC integer before character conversion. Fix the small ordinary String interval by clipping against remaining character length before addition; keep global integer/argument-domain/regex mutation policies unchanged. Strict new test independently observes large-end RED on PUC and identity RED on LuaJIT after healthy producer controls.

  Completion: Preserve Number/Boolean identity (explicit branches retain false) for empty-old replacement/empty-unmatched affixes, guard explicit null operands retaining other scalarization, and add eight-method scalar/ordinary shape guards without new module locals. Clip ordinary substring width to remaining characters before addition, with early out-of-range empty result, fixing PUC wrap while preserving slice domains/dedicated mutation.
  Verification:
  - [x] REPRODUCE / ISSUE: Both safe hosts pass independent native/plan/fresh basic String/Unicode/strict-null/SON. All routes reproduce textified identity/null data, typed producer/shared selector failures and[[],SCA,null,SAC]. PUC large_end gives[abc,empty,empty] versus LuaJIT[abc,bc,bc]; strict test RED distinguishes large-end/identity failures after healthy controls. Initial plain-table diagnostic encoding error is corrected with json.harray and not credited as semantic evidence.
  - [x] ROOT CAUSE (WHY + WHERE): Pure string helper branches return scalarized text and mask explicit null operands, while fluent scalar/shape lists omit eight methods. Ordinary substr adds start+width before clipping, wrapping the PUC integer at nonzero start. Existing source/start null/fraction rules, null-width-as-omitted/Bool-invalid0 and mutation routes already work.
  - [x] FIX: Supported primitive identity returns without Lua and/or false loss, explicit null guards, existing scalar-result/shape lists and bounded character interval clipping before addition. No new module locals/global integer/numeric/selector/Unicode/free arity/regex/callback/format or aggregate-domain normalization. Preserve current width/Bool conventions for20.
  - [x] ADDRESSED (verified): Both PUC5.5.1/LuaJIT pass strict canonical JSON native/plan/fresh across eight retained groups: healthy/identity/null/index producers, large-end free/receiver clipping, boundary effects, shared eight helper results/bridges/empty/null/Unicode/source roots/identity-matched keys, SONC-SC-selectedS/eager null snapshots, rejection/12 malformed no-effects, qualified SIL/slice domains and both mutation aliases.
  - [x] NO REGRESSION: Direct selected/nonempty defaults and interpreter/runner source loads pass both hosts. No full runner/malformed native patterns, declared5.4, magnitude matrix, complete portable/domain admission or Dart/Julia large-slice repair claim. Existing source scalarization and callback behavior stay on their published routes.
  - [x] LOCKSTEP: Retained public probe/test/safe runner, frozen all-five bounded progress, current qualified catalog/guide and canonical Lua/String/null facts/map plus task/live/resume align. Domain20 records both Lua hosts' width-omitted/Bool0 convention and now owns the immediate next action before portable admission. Book/history/diff/final staged memory/cadence/diagnosis checked before commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.19.5 - preserve Lua scalar String kinds and slice bounds`.


- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.5`
  Status: `implemented` / both real checks and focused controls pass; canonical closure after pressure20.1
  Goal: Remove the all-tracked-path argv limit from the path-portability and storage-locality doctrine checks.
  Reproduction: Normal pre-commit during73.1 reports scripts/check_repo_root_path_portability.sh:14 and scripts/check_project_data_storage_locality.sh:13 /usr/bin/perl: Argument list too long. Both consume git ls-files -z into a Bash array and pass all filenames to one Perl launch. A minimal Perl command using the retained actual vector fails OSError errno7 (E2BIG); a single-path launch succeeds. This proves the process-launch defect without rerunning policy scans or changing their rules.
  Evidence: docs/checkpoints/type-operation-inventory/gate-argv-limit-intake.json.gz retains the actual NUL filename vector, checker/input bytes, diagnostic, RED/GREEN commands/results and environment qualification. No portable exact threshold or complete environment/census claim.
  Impact: Two mandatory integrity gates fail before their Perl checks execute, independently of the existing document-pressure failures. Feature behavior is unaffected by this diagnosis.
  Priority/schedule: P1 after ordinary feature coverage in the existing infrastructure window after pressure20.1, before full23.4 and any push. LinkedSpec owns repair through verified closure; no dirty-feature pivot or cap increase.
  Acceptance: Stream NUL-delimited tracked paths through stdin or a repository-local manifest while preserving exact pathname handling, tracked parent-repository scope and both existing policy scans. Add distinguishing small/large-list launch controls, inspect direct consumers, and complete canonical infrastructure proof before closing. Do not mistake a process launch failure for a policy scan result.
  Verification tier: `canonical`
  Focused checks: Existing path/storage self-controls plus retained large filename-vector launch RED/GREEN, safe input-path cases and directly affected doctrine checks.
  Canonical trigger: Infrastructure/checker changes require canonical proof after pressure prerequisites and before admission/push.
  Claim verification: none: Finite input-bound process-launch diagnosis and planned repair; no repaired gate, portable threshold or population-completeness claim.

  Activation: clean79301cb16 after committed Perl73.1/post-hook0/brief0. Director explicitly prioritized addressing both gate failures now. Preserve scan semantics, exact pathname transport, failure propagation and five primary anchors. Repair two process launches first; pressure20.1 remains a named normal-hook/canonical blocker until repaired. No dependency implementation access or cap increase.

  - [x] **REPRODUCE / ISSUE**: Original actual normal-hook launches fail E2BIG, retained in gate-argv-limit-intake.json.gz. Independent oversized Perl argv reproduces errno7 while the same one-file launch succeeds.
  - [x] **ROOT CAUSE (WHY + WHERE)**: Both shell checkers collect every git ls-files filename into an argv array. Process launch fails before policy code runs; two exact launch locations and original bytes retained. No policy-scan finding is inferred from launch failure.
  - [x] **FIX**: Git's exact NUL path stream now goes to Perl stdin; the unchanged Perl source uses descriptor3. pipefail preserves Git failures, incomplete NUL records reject, and no argv grows with checkout size. Classification, binary/symlink skips and primary anchors stay.
  - [x] **ADDRESSED (verified)**: Both actual current tracked-tree scans return0. Actual checker controls pass small/oversized paths, spaces/newline filename, binary and symbolic files, policy rejection, truncated NUL and Git exit23 propagation. The independent oversized argv control still fails E2BIG, distinguishing the repaired transport.
  - [x] **NO REGRESSION**: Existing14 portability/28 storage classifier controls and five primary anchors pass within the real scans. Script syntax passes. Canonical CI registers the new actual-checker control; complete canonical proof remains blocked by independent pressure20.1, not claimed.
  - [x] **LOCKSTEP**: Book/Toolbox/fact/map/task/live/roadmap/history/resume reflect process repair and the explicit remaining pressure/canonical boundary. The original diagnosis remains immutable; new producer/inputs/raw outputs are retained in gate-path-streaming-intake.json.gz. Parent remains implemented until canonical verification closes it.
  Result: The E2BIG mechanism is repaired and both actual policy checks execute successfully. This is not normal-hook restoration: pressure20.1 and full canonical proof still remain. Director now prioritizes pressure20.1 immediately after committing this bounded process repair, before Rust73.2. Do not resume runtime feature work until normal hooks are restored. No broad claim-registry result or canonical receipt is claimed from focused checks.
  Verification: bash scripts/check_repo_root_path_portability.sh; bash scripts/check_project_data_storage_locality.sh; bash tools/run_python_project_data.sh tools/test_doctrine_path_streaming.py --evidence .linkedspec-data/gate-path-streaming/controls.json; Bash syntax/book/map/history/memory/diagnosis/diff. Canonical verification explicitly pending pressure20.1; node not closed.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.4.5 - stream tracked paths into doctrine checkers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.4`
  Status: `pending` / P2 owned backend-guide drift repair before admission
  Goal: Reconcile stale Lua guide continuation descriptions with current canonical method contracts.
  Reproduction: `rg -n -F -e 'matches is terminal' -e 'terminal in a' -e 'Downstream array receiver methods' lua/README.md` exposes legacy terminal-matches and pending split-to-Array wording. Current bounded String-predicate70/Array-family outcomes and the helper-contract catalog already describe compatible continuations. A targeted read during71.6.5 established these two documentary contradictions; no exhaustive guide-drift census is claimed.
  Impact: Backend guide readers can mistake implemented ordinary continuations for unsupported work. Canonical book remains the current authority; no new runtime defect is inferred.
  Priority/schedule: P2 after ordinary feature coverage, before full23.4 admission/final push. LinkedSpec owns correction through verified closure; preserve declared-host/context qualifications and immutable historical evidence.
  Acceptance: Read current guide passages and relevant canonical70/split/Array facts, correct the two named descriptions and any directly dependent examples, and check for contradictory wording on those same surfaces. Use existing focused proof or a minimal distinguishing public example if facts have changed. Keep the book and backend guide aligned without inferring complete family/context admission from these controls.
  Planned verification tier: focused
  Planned focused checks: Targeted guide/catalog/fact reconciliation, minimum public example only if required, documentation/continuity checks.
  Planned canonical trigger: Complete guide/context/portable admission remains23.4 and final clean push.
  Planned claim verification: none: Two observed documentary contradictions, no exhaustive population measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.3`
  Status: `pending` / P1 mandatory task-evidence backend-path coverage extension
  Goal: Extend the documented TASK-ACCEPTANCE path scope to owned Dart/Julia/Lua code/tests and shared fixtures before admission/push.
  Trigger: Dart70.3 stages interpreter/test changes but scripts/check_diagnosis_evidence.sh exits0 with the no-governed-changes message. Its explicit case list and canonical task-acceptance-evidence-gate-boundary card cover Perl/Rust but omit Dart/Julia/Lua/tests. This is an existing documented enforcement limitation; the current Dart feature checklist is manually reviewed, not mechanically enforced by that no-op.
  Evidence: docs/checkpoints/type-operation-inventory/task-acceptance-backend-scope-intake.json.gz retains the actual unchanged staged Dart candidate, gate source/instrument/dependencies and fresh stdout/stderr/exit0. No exhaustive omitted-path census or runtime feature failure is claimed.
  Priority/schedule: P1 after ordinary feature coverage, in the existing infrastructure/admission-prerequisite window after document-pressure20.1, before full23.4 and any push. Own through verified closure; do not pivot dirty feature work into a doctrine rewrite.
  Acceptance: Inventory the actual owned backend/shared-fixture paths and policy/registry consumers, preserving read-only dependency boundaries. Update the gate and canonical scope documentation together. Exercise real gate calls with isolated project-local alternate indexes: missing task evidence must reject each newly governed backend code/test/shared-fixture path, complete evidence must pass, existing Perl/Rust behavior and documentation-only no-op controls must remain. Retain distinguishing pre-repair negatives and repaired positives, actual producer/input identities and exact staged canonical proof; do not infer broader evidence truth or historical completeness from this shape gate.
  Planned verification tier: canonical.
  Planned focused checks: Actual staged-path gate controls across all owned backends/shared fixtures, missing/complete checklist and documentation-only compatibility, source/registry/docs/history/memory/map synchronization.
  Planned canonical trigger: Mandatory doctrine infrastructure admission prerequisite before23.4/final push.
  Planned claim verification: none: This node schedules repair of the documented path-scope limitation demonstrated by one current Dart candidate; no exhaustive coverage or measured repair is published.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.2`
  Status: `pending` / P2 mandatory direct-fixture capture-closure audit before admission/push
  Goal: Audit and repair declared direct fixture-input closure in earlier feature intake captures using their actual retained selected consumers and producers.
  Trigger: Custody67.6 confirms an inherited fixture-glob/changed-nearest-selector mismatch in five named67 packets. Its bounded companion closes only the thirteen specified edges. Reused earlier templates require an explicit review; no additional omission population or runtime regression is inferred without tools.
  Priority/schedule: After ordinary feature coverage, with admission prerequisites and in coordination with SESSION-STARTUP-READING.5 claim/producer audit, before23.4 admission/final push. This owner remains accountable until any explicit transfer; no dirty-feature global audit pivot.
  Acceptance: Inventory actual selected direct consumers and literal/constructed fixture loaders for the earlier captures, beginning source-role families63–66 and expanding through their real dependencies. Compare against retained byte identities, not filename lists or summary receipts alone. Own and repair each demonstrated omission with immutable companions/historical recovery and explicit original-observation limits; re-run focused behavior only where missing freshness or changed evidence requires it. Use distinguishing missing-input/provenance controls, retain actual producers/all direct artifact inputs and verify retrieval. Preserve original captures/results/history, black-box dependency boundaries and existing backend policies. Coordinate broader transitive/toolchain/producer census with its canonical owner; do not claim it from a direct-input inventory. Close only after verified repair and designated canonical proof.
  Planned verification tier: canonical.
  Planned focused checks: Retained-consumer/direct-input audit, historical-source recovery, distinguishing byte/provenance negatives and affected focused suites with exact input identities; original packet/history preservation and claim/book/continuity checks.
  Planned canonical trigger: Admission prerequisite/declared capture-closure closeout before push; infrastructure changes split into explicit canonical leaves if needed.
  Planned claim verification: none: This node schedules review of a demonstrated template-reuse risk; no additional missing-input census, measured repair or current runtime failure is claimed.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.1`
  Status: `pending` / P1 canonical admission prerequisite
  Goal: Register new bounded feature regressions in canonical CI before full admission/final push.
  Existing authority: docs/knowledge/perl-receiver-copy-canonical-selection.md states the runner uses exact explicit suites; future files require registration, with historical inverse/custody constraints.
  Reproduction: rg -n -F -e 't/string_predicate_result_receiver_contract.t' -e 't/emptiness_result_receiver_contract.t' -e 't/has_key_result_receiver_contract.t' tools/run_ci_local.sh returns no matches/exit1 after these fixtures are introduced. This confirms omission of these named direct selections; no complete omission population has been measured.
  Impact / ownership: Direct focused runs protect current feature commits, but merely retaining new t files does not add their execution to the final canonical receipt. This includes t/defined_default_receiver_contract.t, t/scalar_string_result_receiver_contract.t, t/reduction_result_receiver_contract.t, t/tagged_record_producer_contract.t, t/tagged_record_receiver_contract.t, t/logical_receiver_method_contract.t, t/computed_selection_noncall_contract.t, t/computed_selection_callable_compat.t and t/computed_selection_deferred_boundary.t; the approved primitive-copy producer/receiver add t/value_copy_function.t, t/value_copy_receiver.t and t/value_copy_interpreted.t; computed helper sources add t/computed_selection_helper_calls.t. Registered sources add t/computed_selection_functions.t; contextual grammar preservation adds t/computed_selection_contextual_boundary.t. Readonly capture composition adds t/capture_collection_selection.t. Inline condition producer repair adds t/inline_condition_value_blocks.t. Conditional bracket selection adds t/conditional_selection.t. Input/cursor reader composition adds t/input_cursor_result_continuations.t. Eager key/order repair adds t/set_key_block_operands.t. Static capture-name/function-fence repair adds t/named_capture_literal_names.t. Catalogued function-state fence adds t/user_function_parser_state_boundary.t. Noncatalogued parser-context fence adds t/user_function_parser_context_boundary.t. Number reader composition adds t/entry_match_number_result_continuations.t. Ordinary eager with Hash composition adds t/with_hash_result_continuations.t. Callback origin-label repair adds t/callback_identity.t. Callback snapshot repair adds t/with_callback_snapshot.t. Immediate with-result bracket composition adds t/with_result_selection.t. Anonymous capture Number composition adds t/capture_boundary_number_results.t; ordinary value-block reset adds t/capture_reset_value_block.t; readonly named-mark Number composition adds t/named_mark_number_results.t. Input-boundary mark value-block statements add t/input_mark_value_block_statements.t. Governed Number-reader name arguments add t/mark_name_number_arguments.t. Governed named writer statements add t/mark_name_write_arguments.t. Readonly named text/predicate names and unused calls add t/mark_name_text_arguments.t. Named advancing/bridge names add t/mark_name_advance_arguments.t. Reversed local-start named take guards add t/named_take_reversed_span.t. Sparse single-action AND classification adds t/sparse_and_single_action.t. Shared ordinary progress guard adds t/shared_rule_progress_guard.t. Standalone wiring adds t/emitted_rule_progress_guard.t. Repeated AND falsey group acceptance adds t/repeated_and_falsey_group.t and t/repeated_and_falsey_recognition.t. This owner must inventory all newly added feature fixtures/helpers, classify actual selection and repair every omission before admission/push; do not infer completeness from the three named controls.
  Schedule: Mandatory after feature coverage, before23.4 admission and before final clean push; no full-CI/policy detour during ordinary implementation.
  Acceptance: Inventory current feature fixtures and all producer/artifact inputs; add exact tracked-presence/syntax/execution selection through the published canonical runner/historical-inverse contract. Distinguish direct/indirect coverage; retain targeted selector RED/GREEN and actual full canonical receipt for exact staged candidate. Update runner docs/fact/card/current task records and commit as an infrastructure leaf before push.
  Planned verification tier: canonical; declare claim/inputs and focused selection at activation.


  Added ownership: t/computed_selection_helper_calls.t and t/computed_selection_functions.t require explicit canonical registration after the bounded computed-source rollout and before admission/push.

  Canonical fixture addition from33.1: Register t/capture_boundary_number_results.t alongside the other bounded Perl feature fixtures before full23.4/admission/push.

  Canonical fixture addition from45.3: Register t/pick_keys_operand_isolation.t and its retained fixture alongside direct capture/default consumers; current ordinary focused success does not establish canonical inclusion.

  Latest-child blind binding39.2.5.1 adds t/blind_child_retv.t; explicit canonical syntax/execution registration is required before admission/push, alongside all existing named bounded fixtures.

  Falsey blind iteration39.9.1 adds t/repeated_blind_falsey_group.t; explicit canonical syntax/execution registration is required before admission/push.

  Repeated blind parent publication39.9.2 adds t/repeated_blind_parent_acceptance.t; explicit canonical syntax/execution registration is required before admission/push.

  Lua intake39.4.0: tools/run_lua_local.sh also selects explicit files rather than automatically discovering new consumers. Register lua/test/sparse_and_structural_sequence_test.lua and subsequent bounded Lua feature consumers exactly once per installed ABI/declared host in ordinary and canonical owners before23.4 admission/push. Current direct focused102 assertions per host does not imply runner admission. No infrastructure change in the focused intake.

  Lua live progress39.4.6 adds lua/test/recognition_repetition_progress_test.lua to the required exact ordinary/canonical registration inventory; direct focused234 assertions per installed host does not imply discovery.

  Lua repeated-group39.4.2 adds lua/test/repeated_and_group_results_test.lua to the exact ordinary/canonical registration inventory before admission; direct390 assertions per installed host is not automatic discovery.

  Lua ordinary-minimum39.4.3 adds lua/test/minimum_miss_routes_test.lua to required explicit ordinary/canonical registration; direct289 assertions per installed host is not discovery/admission.

  Lua implicit-blind39.4.4 adds lua/test/blind_repetition_collection_test.lua to exact ordinary/canonical registration inventory. Current13active2owned dormant (Default .9/post-call .5) is direct focused proof only; remove satisfied dormancy before full admission.

  Lua Default-family39.4.9 adds lua/test/default_blind_generated_family_test.lua to required explicit ordinary/canonical registration. Current blind14active1post-call dormant/structural31fully active; direct304/230/205/234/222 assertions per installed host is not full admission.

  Lua post-call39.4.5.1 adds lua/test/blind_postcall_results_test.lua to required exact ordinary/canonical registration. All15 collection/all31 structural rows are active, no residual dormancy; direct274/240/289/390/234/205 per host is focused proof, not full admission.

  Lua nullable39.4.7.1 requires exact ordinary/canonical registration of lua/test/null_return_and_observation_test.lua. Its32qualified sources/52inputs pass506 per host; blind_LE one source/two inputs is explicitly excluded pending .5.2 and must be qualified/covered before full admission. Direct focused execution is not runner registration or canonical admission.

  Lua diagnostic39.4.8 requires exact ordinary/canonical registration of lua/test/runtime_unknown_helper_diagnostic_test.lua. Direct105 plus minimum289/callable449 per host is focused proof, not runner registration or full admission.

  Selected cursor38 adds dart/test/fixtures/gap_ls_broad_carrier.json as the original wildcard-carrier acceptance supplement. SDK/restored/plan current Dart/Julia proof is explicit; require actual separate-process Dart/Julia emitted replay of this supplemental1/1 before full admission/push. Existing core8-module fresh proof does not include it. Lua38.3 intake will include core plus broad from its RED epoch; exact new Lua normal registration remains required.

  Lua cursor38.3 requires exact ordinary/canonical registration of lua/test/gap_ls_selected_cursor_test.lua. It reads core+broad fixtures and passes118 assertions per installed host; direct nullable506/recognition246/gap controls6 are focused proof, not runner registration/full admission. Nine baseline modules per host include broad from RED and fresh; supplemental Dart/Julia broad emitted replay remains independently required.

  Perl boundary37 requires exact ordinary/canonical registration of t/emitted_boundary_catalog.t and its tests/fixtures/emitted_boundary_catalog.json input. Direct13-group native/arbitrary-package eval and separately retained13-source18-input fresh emitted proof do not imply canonical selection. Existing current nested boundary consumer remains; archival case/claim inputs are unchanged.

  Perl endpoint40.1 requires exact ordinary/canonical registration of t/capture_endpoint_absence.t and tests/fixtures/capture_endpoint_absence.json. Native/arbitrary-package eval16 groups and retained separate-process clean+seeded proof are focused coverage, not canonical selection. Existing typed-source4/Number7 controls stay selected; no blanket broader SESSION17 closure.

  Rust endpoint40.2 adds rust/linkedspec-runtime/tests/capture_endpoint_absence.rs over the frozen16-source fixture. Actual ordinary Cargo target discovery and three-route execution are verified; exact canonical presence/selection remains in this owner audit before admission/push. Temporary capture_endpoint_intake_probe.rs was snapshotted/removed and is not a normal consumer.

  Dart endpoint40.3 adds dart/test/capture_endpoint_absence_test.dart using the frozen16-source fixture. Ordinary target discovery/three SDK routes and retained separate-VM modules are verified; exact canonical presence/selection remains in this audit before admission/push. Adjacent named47 discovery has SDK-only proof and no normal/fresh completion credit.

  Julia endpoint40.4 adds julia/test/capture_endpoint_absence_test.jl and ordinary runtests registration using the frozen16-source fixture;112 normal assertions/three SDK routes and retained separate-process modules independently pass. Exact canonical selection remains required before admission/push, no peer/named completion inferred.

  Lua endpoint40.5 adds lua/test/capture_endpoint_absence_test.lua and ordinary run.lua registration.112 normal/three SDK routes plus retained separate-process modules pass independently on safe installed PUC5.5/LuaJIT; no declared5.4/unsafe formatter/full phase credit. Exact canonical selection remains required before admission/push.

  Native nested error41.1 adds t/nested_handler_error.t using frozen9-source/22-call fixture; ordinary discovery and selected30 groups/75 canonical nested assertions verified. Exact canonical selection remains required before admission/push, no full Phase0 or peer completion credit.

  Perl named endpoint47.1 adds t/named_capture_endpoint_absence.t using frozen15-source fixture; ordinary native/fresh target15 plus range11/Number3 groups verified, exact canonical presence/selection remains required before admission/push. Old emitted modules remain v2 accepted with original defects and require regeneration; no stale-artifact repair credit.

  Rust named endpoint47.2 adds rust/linkedspec-runtime/tests/named_capture_endpoint_absence.rs; ordinary Cargo discovery/three SDK routes and retained separately compiled emitted sources pass, exact canonical selection remains required before admission/push. Runtime relink consumes unchanged source, temporary probe removed; no writer49/peer/full admission credit.

  Dart47.3 adds dart/test/named_capture_endpoint_absence_test.dart using frozen15 target; ordinary discovery/current three SDK routes verified and separate VM reuses original15 emitted modules. Exact canonical presence/selection remains required before admission/push.

  Julia47.4 adds julia/test/named_capture_endpoint_absence_test.jl and explicit runtests include. Ordinary105 assertions and separate emitted current15 verified; exact canonical presence/selection remains before admission/push.

  Safe Lua47.5 adds lua/test/named_capture_endpoint_absence_test.lua and explicit run.lua registration; current15/four routes plus436 focused checks per installed host verified. Exact canonical presence/selection remains before admission/push; declared5.4 and unsafe formatter not covered.

  Perl49.1 adds t/named_writer_endpoint_absence.t using frozen15 target. Ordinary discovery/native+emitted15 groups and separate clean/seeded15-source proof verified; exact canonical presence/selection remains required before admission/push.

  Rust49.2 adds rust/linkedspec-runtime/tests/named_writer_endpoint_absence.rs with frozen15 current target. Ordinary Cargo discovery/three SDK routes and separate compiled original15 source proof verified; exact canonical presence/selection remains before admission/push. Temporary probe archived/removed.

  Dart49.3 adds dart/test/named_writer_endpoint_absence_test.dart with frozen15 writer target. Ordinary discovery/three SDK routes and original15 separate-VM modules verified; exact canonical presence/selection remains before admission/push.

  Julia49.4 adds julia/test/named_writer_endpoint_absence_test.jl with explicit runtests include. Ordinary105 assertions/current three SDK routes and separate emitted15-source proof verified; exact canonical presence/selection remains before admission/push.

  Safe Lua49.5 adds lua/test/named_writer_endpoint_absence_test.lua and explicit run.lua registration. Current15/four routes plus429 selected checks per installed host verified; exact canonical presence/selection remains before admission/push, no declared5.4/full suite credit.

  Perl48.1 adds t/referenced_blind_intermediate.t: focused12 groups cover8valid4reject and7native/fresh runtime controls. Exact canonical presence/selection remains required before admission/push.

  Rust48.2 adds referenced_blind_intermediate.rs compile-only regression; runtime closure48.2.3 remains open. Exact canonical selection must include final complete consumer before admission.

  Rust48.2.1 adds blind_fluent_return_values.rs consuming17 reference-qualified cases, with focused native/reconstructed/plan/fresh proof. Exact canonical presence/selection remains required before admission.

  Rust48.2.2 adds rule_invocation_accumulators.rs with3 qualified source fixtures, focused four-route proof and13 selected tests. Exact canonical selection required before admission; original parent-LX exclusions remain48.2.2.1.

  Rust48.2.3 adds referenced_blind_intermediate_qualified.rs and separate qualified12 target, four-route7-runtime proof and4 selected normals. Original compile consumer remains. Exact canonical selection must preserve original parent-LX authority exclusions.

  Rust48.2.4 adds blind_parent_push.rs with8 single-pass witnesses, four-route RED/GREEN and8 selected tests. Exact canonical selection must preserve repeated/Unicode/phase exclusions until their owners close.

  Rust48.2.5 adds blind_postcall_results.rs and5-source repeated composition in blind_parent_push.rs; main18/27 four-route proof/15 selected tests. Exact canonical selection must include both and preserve stated diagnostic/phase/cursor projection limits before admission.

  Perl48.2.6 adds t/unicode_rule_recognition_runtime.t (20 groups); exact canonical discovery must select it before admission. Static operand scanner48.2.6.1 remains separately owned immediately next.

  Perl48.2.6.1 adds t/unicode_recognition_operands.t (22 groups), with scanner/lowering/runtime closure and exact negative diagnostics; canonical discovery must include it before admission.

  Dart48.3 adds referenced_blind_intermediate_test.dart (16 checks); exact canonical selection must include it after48.3.1 removes the3 explicitly owned runtime exclusions.12 original compile sources, qualified runtime and4 strict negatives remain separate authority.

  Dart48.3.1 adds blind_parent_push_test.dart (13 shared PIPE/repeated controls); exact canonical selection must include it and referenced_blind_intermediate_test.dart after48.3.2 removes the3 remaining accumulator exclusions.

  Dart48.3.2 adds rule_invocation_accumulators_test.dart (3 Scope controls, implicit backend-qualified),92 selected checks.39.8.1, not completed Scope repair, owns3 referenced runtime exclusions. Candidate progress normal remains outside discovery; pure-code48.3.3 next. Canonical selection must preserve these qualifications.

  Dart48.3.3 adds pure_blind_targets_test.dart (15 cases incl3 bypass) and pure_blind_targets.json8. Exact canonical selection must include these and retain6 negative/immutable map/call-ref/entry-slot absence properties. Ordinary policy/source fixture candidates remain separately owned39.8.1.

  Julia48.4 adds referenced_blind_targets_test.jl with one runtests include,36 compiler roles plus strict bypass/real-empty and10 runtime controls (180 assertions). Qualified push3 excluded under48.4.1 with compile coverage; original parent-LX runtime unqualified48.2.2.1. Exact canonical selection must include this normal and completed runtime repair before admission.

  Julia48.4.1 adds blind_parent_push_test.jl with one runtests include,13 exact source controls104 assertions. Qualified coordinator3 runtime qualification moves to actual invocation-array owner48.4.2; original parent-LX remains unqualified. Exact canonical selection must include repaired normals before admission/push.

  Julia48.4.2 adds rule_invocation_accumulators_test.jl with one runtests include,3 original plus4 binding-scope controls56 assertions. Preserve explicit implicit-tail39.8.1 and undeclared-write48.4.2.1 qualifications; no portable credit until canonical authority/repair.

  Safe Lua48.5 adds referenced_blind_targets_test.lua with one run.lua registration,189 checks including36 source compiler roles/strict bypass/real empty/10 runtime controls. Both safe hosts809 selected assertions;3 coordinator runtime exclusions remain39.8.1 and original parent-LX unqualified48.2.2.1. Exact canonical selection before admission/push.

  Perl40.1.1 adds t/perl_match_local_declarations.t9 groups plus finite fixture. Exact canonical selection must include it and retain explicit OR warning40.1.1.1 ownership until repaired, with unsupported callback typed failure unchanged.

  Perl40.1.1.1 adds t/perl_or_match_local_declarations.t10 groups, closes prior AND normal OR warning allowance, and requires both normals in exact canonical selection. All new OR/AND generated loading checks now require0 warnings.

  Perl40.1.2 adds t/perl_blind_scalar_declarations.t24 source groups+1 context guard; exact canonical selection must cover nested scalar ownership/nonmutating diagnostic JSON and keep existing AND/OR declaration normals strict.

  New focused normal awaiting explicit canonical selection: `t/sorted_values_scalar_isolation.t` / `tests/fixtures/sorted_values_scalar_isolation.json`, producer repair45.11.1; native/fresh seeded scalar/Hash controls. Required before full23.4/push, alongside prior pick_keys normal.

  New focused normal from50.1: Register t/capture_boundary_text_results.t and shared fixture before full23.4/push; direct focused execution does not establish canonical inclusion.

  New focused normal from51.1: Register t/capture_advance_text_results.t/shared fixture before full23.4/push; focused execution alone is not canonical inclusion.

  New focused normal from52.1: Register t/capture_advance_number_results.t/shared fixture before full23.4/push; focused execution alone is not canonical inclusion.

  New focused normal from53.1: Register t/boundary_capture_fluent_results.t/shared fixture before full23.4/push; focused execution alone is not canonical inclusion.

  Queued normals from54: Explicitly register t/closed_named_selector_assignments.t, t/rule_call_result_selection.t and shared rule_call_selection_values fixture before full23.4/push; focused execution alone is not canonical inclusion.

  Queued normal from55: Explicitly register t/gap_slot_record_selection.t/shared fixture before full23.4/push; focused execution alone is not canonical inclusion.

  Queued normal56.0: Explicitly register t/cursor_statement_scope.t10 before full23.4/push; direct focused execution is not canonical inclusion.

  Queued normal56.1: Explicitly register t/cursor_rewind_result.t9/shared fixture before full23.4/push; focused execution alone is not canonical inclusion.

  Queued normal57.1: Explicitly register `t/gap_string_result.t` (15 groups) and its shared fixture before full23.4/push; focused execution is not canonical inclusion.

  Canonical fixture addition from58.0: Explicitly register t/push_payload_values.t (8 groups) for syntax/execution before23.4 admission/final push; direct focused execution is not canonical selection.

  Canonical fixture addition from58.1.1: Explicitly register t/push_result_selection.t (6 groups), push_result_selection_read_values.spec/.json and push_result_excluded_source_ast.json before23.4 admission/final push; full12 target remains separate.

  Canonical fixture addition from58.1.2: Explicitly register t/push_result_fluent.t (10 groups) and full push_result_selection_values.spec/.json before23.4 admission/final push; direct focused proof is not canonical selection.

  Canonical fixture addition from59.1: Explicitly register t/set_result_composition.t (11 groups), set_result_selection_values.spec/.json and set_result_excluded_source_ast.json before23.4 admission/final push; direct focused execution is not canonical registration.

  Added60.1 ownership: t/free_default_result_composition.t18/shared tests/fixtures/free_default_result_cases.json12/eight free_default_excluded_source_ast.json controls require explicit canonical registration before admission/push. Focused direct execution is not registration.

  Added61.0 ownership: t/perl_sort_scope.t11/shared tests/fixtures/perl_sort_scope_cases.json7 require explicit canonical selection before admission/push. Direct focused execution is not registration.

  Added61.1 ownership: t/constructor_result_composition.t25/shared constructor_result_cases.json15/eight public excluded AST-lowering controls retained in constructor-perl-intake.json.gz require explicit canonical registration before admission/push. Focused direct execution is not registration.

  Added62.1 ownership: t/free_string_result_composition.t18/t/free_string_source_fences.t9/shared free_string_result_cases.json16/free_string_excluded_source_ast.json9 require explicit canonical registration before admission/push. Direct focused execution is not registration.

  Added62.6.1 ownership: t/receiver_string_bridge_guards.t13/t/receiver_string_bridge_source_fences.t9/shared receiver_string_bridge_cases.json12/receiver_string_bridge_excluded_ast.json9 require explicit canonical registration before admission/push. Updated free String18 must assert admitted receiver readiness; historical unready qualifier retired with proof.

  Added63.1 ownership: t/free_numeric_result_composition.t17/t/free_numeric_source_fences.t14/shared free_numeric_result_cases.json17/free_numeric_excluded_source_ast.json14 require explicit canonical registration before admission/push. Focused execution is not canonical registration.

  Added64.1 ownership: t/free_numeric_comparison_result_composition.t19/t/free_numeric_comparison_source_fences.t14/shared free_numeric_comparison_result_cases.json19/free_numeric_comparison_excluded_source_ast.json14 require explicit canonical registration before admission/push. Focused execution is not canonical registration.

  Added65.1 ownership: t/logical_result_guard_composition.t22/t/logical_result_guard_source_fences.t16/shared logical_result_guard_cases.json22/logical_result_guard_excluded_ast.json16 require explicit canonical registration before admission/push; focused execution is not registration.

  Added66.1 ownership: t/lexical_result_guard_composition.t20/t/lexical_result_guard_source_fences.t18/shared lexical_result_guard_cases.json20/lexical_result_guard_excluded_ast.json18 require explicit canonical registration before admission/push; focused execution is not registration.

  Calibration28.0 adds t/definedness_native_numeric_contract.t (two native/fresh/readiness groups). Register exact syntax/execution before admission/push; current focused execution does not establish canonical selection.

  Added67.1 ownership: t/definedness_result_guard_composition.t21/t/definedness_result_guard_source_fences.t18/shared definedness_result_guard_cases.json21/definedness_result_guard_excluded_ast.json18 require explicit canonical registration before admission/push; focused execution is not registration.

  Added68.1 ownership: t/emptiness_result_guard_composition.t22/t/emptiness_result_guard_source_fences.t18/shared emptiness_result_guard_cases.json22/emptiness_result_guard_excluded_ast.json18 require explicit canonical registration before admission/push; focused execution is not registration.

  Added69.1 ownership: t/has_key_result_guard_composition.t22/t/has_key_result_guard_source_fences.t18/shared has_key_result_guard_cases.json22/has_key_result_guard_excluded_ast.json18 require explicit canonical registration before admission/push; focused execution is not registration. Existing null-source regression remains covered by its unchanged6-assertion contract.

  Added69.6.1 ownership: t/copied_null_presence_composition.t11 and tests/fixtures/copied_null_presence_cases.json10 require explicit canonical registration before admission/push; focused execution is not registration. Existing presence18 source fences remain unchanged.

  Added70.1 ownership: t/string_predicate_result_guard_composition.t22/t/string_predicate_result_guard_source_fences.t18/shared string_predicate_result_guard_cases.json22/string_predicate_result_guard_excluded_ast.json18 require explicit canonical registration before admission/push; focused execution is not registration.

  Added71.0 ownership: t/contains_block_operand_composition.t13/t/contains_result_guard_source_fences.t18/tests/fixtures/contains_block_operand_cases.json13 require explicit canonical registration before admission/push; focused execution is not registration.

  Added71.1 ownership: t/contains_result_guard_composition.t26/shared contains_result_guard_cases.json23/contains_null_prefix_guard_cases.json3 require explicit canonical registration before admission/push; fences18 already71.0-owned. Focused execution is not registration.

  Added71.6.1 ownership: t/copied_null_contains_composition.t11 and tests/fixtures/copied_null_contains_cases.json11 require explicit canonical registration before admission/push. Focused direct execution is not registration; existing contains18 fences remain unchanged.

  Added72.0 ownership: t/index_block_operand_composition.t15/t/index_result_guard_source_fences.t18/tests/fixtures/index_block_operand_cases.json15 require explicit canonical registration before admission/push; focused execution is not registration.

  Added72.1 ownership: t/index_result_guard_composition.t19/tests/fixtures/index_null_prefix_guard_cases.json3 require explicit canonical registration before admission/push alongside frozen shared16 and source18; focused execution is not registration.

  Added72.6.1 ownership: t/copied_null_index_composition.t14 (shared12 plus two inline source-exact diagnostics) and tests/fixtures/copied_null_index_cases.json12 require explicit canonical registration before admission/push. Focused execution is not registration; original index18 fences remain unchanged.

  Added73.0 ownership: t/count_block_source_composition.t14, t/count_result_guard_source_fences.t18 and tests/fixtures/count_block_source_cases.json14 require explicit canonical registration before admission/push. Original count excluded18 is consumed by the new fence; focused execution is not registration.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.20`
  Status: `active` / all bounded repairs targeted-checked; full admission separate
  Goal: Align three backend ordinary slice paths with existing Perl-reference optional/null/Boolean argument behavior.
  Dependencies: .23.2.20 substring-optional-arguments.md.
  Children: `.23.3.20.1` Dart, `.23.3.20.2` Julia, `.23.3.20.3` safe Lua.
  Acceptance: Preserve omitted versus explicit null, helper-specific Boolean1/0, source capture/eager SIWC, integer/fractional/negative/Unicode rules and dedicated mutation paths. Do not change global numeric converters/selectors/free arities or assert complete portable admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.20.1`
  Status: `completed`
  Goal: Repair Dart ordinary substring optional argument parity.
  Dependencies: .23.2.20.
  Acceptance: Follow substring-optional-arguments.md and shared reference fixture. Null width and Boolean start/width conversion; native/restored/plan. Independent RED/GREEN, direct scalar String/mutation and small compile checks; sync book/facts/task/live and commit before next backend. Full signature/context/portable admission remains23.4.
  Planned verification tier: focused
  Planned focused checks: Shared argument/effect fixture, direct scalar String controls and selected compilation/format, current book/history/staged continuity guards.
  Planned canonical trigger: None for bounded existing-ADR0006/0023 reference repair under director feature-first cadence; full admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `2bb2643d49498a7803466808502ad3d276d51de6`; frozen optional argument target committed, brief0/tree clean.
  Owned paths: Dart ordinary _callSubstr null-width/Boolean argument distinction, shared reference and direct scalar String tests/retained diagnostic; scoped frozen ledger/book/canonical facts/task/live continuity. Preserve global _intValue, free unary/extra-arity and dedicated mutation behavior.
  Verification tier: `focused`
  Focused checks: New shared native/restored/plan RED/GREEN, direct scalar String including named mutation/Unicode/eager effects and legacy arity controls, selected format/fatal analysis, book/history/staged continuity guards.
  Canonical trigger: None for bounded existing ADR0006/0023 reference repair under director feature-first cadence; full signature/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Completion: _callSubstr distinguishes a provided null width at ordinary three-argument arity and locally converts Bool slice arguments to1/0 only for supported ordinary two/three-argument forms. Global _intValue, numeric/selector conversion and existing unary/extra-argument behavior remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared reference test RED gives bc for null widths, abc/empty for true starts/widths and [abc!,SIWC,1,null]/[!,SIWC,1,null] rather than reference null/b!. Independent native/restored/plan observations were retained in20; legacy unary/extra-argument preservation test already passes before production.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart _callSubstr maps a provided null width to omitted and delegates Bool arguments to rejecting global _intValue. Eager operand staging/source capture already works, so repair the helper body only.
  - [x] FIX: Ordinary explicit-null width guard plus local Bool1/0 offset branch; preserve fractional/negative normalization and all other call arities. Update the older qualified substring expectations to the frozen reference; no global converter/selector or mutation change.
  - [x] ADDRESSED (verified): New shared fixture passes native/restored/plan with omitted/null/Bool/integer/text/fraction/negative/source-start-null distinctions and captured SIWC/one-source effects. Explicit legacy free unary/extra-arity controls remain passing; defined-width chain gives b!, present-null chain null.
  - [x] NO REGRESSION: New2/direct scalar String7 tests pass (nine total), preserving Unicode, identity kinds/typed Array indices, source roots/bridges, eager SIL/SONC/rejected prefix effects,12 malformed no-effects and both named regex mutation aliases. Selected runtime/tests format and fatal analysis pass. No full gate/large-slice2.14 repair or portable admission.
  - [x] LOCKSTEP: Frozen ledger/current book progress, canonical optional-argument/Dart facts/map and TYPE/SESSION/live/resume align; book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia20.2 next, safe Lua20.3 follows; broader signature/61.3/23.4 remain open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.20.1 - align Dart substring optional arguments`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.20.2`
  Status: `completed`
  Goal: Repair Julia ordinary substring optional argument parity.
  Dependencies: .23.3.20.1.
  Acceptance: Follow substring-optional-arguments.md and shared reference fixture. Null width distinction only; Boolean conversion already correct; strict native/plan/fresh. Independent RED/GREEN, direct scalar String/mutation and small compile checks; sync book/facts/task/live and commit before next backend. Full signature/context/portable admission remains23.4.
  Planned verification tier: focused
  Planned focused checks: Shared argument/effect fixture, direct scalar String controls and selected compilation/format, current book/history/staged continuity guards.
  Planned canonical trigger: None for bounded existing-ADR0006/0023 reference repair under director feature-first cadence; full admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `557efd381a16033fab2b5090d0104d2cf46a1f74`; Dart argument repair committed, brief0/tree clean.
  Owned paths: Julia ordinary _call_runtime_substr explicit-null width guard, strict shared/native-plan-fresh test/registration and direct scalar String expectation update; frozen ledger/book/Julia/optional-argument facts/task/live continuity. Existing Boolean argument conversion already correct; no global converter/free arity/selector/mutation or unsafe large-slice2.10 repair.
  Verification tier: `focused`
  Focused checks: New shared native/plan/fresh RED/GREEN with strict counter kinds and legacy arity controls, direct scalar String including Unicode/eager effects/named mutation, strict compilation and book/history/staged continuity guards.
  Canonical trigger: None for bounded existing ADR0006/0023 reference repair under director feature-first cadence; full signature/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Completion: Ordinary three-argument _call_runtime_substr now returns nothing for explicit null width before the unchanged character slicing body. Existing omitted width, Boolean1/0/global converter and unary/extra-arity paths are preserved; register the shared focused test.
  Verification:
  - [x] REPRODUCE / ISSUE: New strict native/plan/fresh shared reference has three observed value failures: null_width becomes bc/bc and null_effects bc! instead of null. Six counter-kind assertions and three legacy arity controls already pass; Boolean starts/widths and defined-width b!/SIWC are healthy.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _call_runtime_substr's optional width conditional maps explicitly provided nothing to absence. _runtime_int already accepts Bool via Integer, so no converter repair is necessary.
  - [x] FIX: Add only ordinary three-argument explicit-null guard, update older qualified test expectations/names and register new shared fixture test. Keep all conversion/selector/free-arity/mutation/Unicode and large-slice2.10 behavior unchanged.
  - [x] ADDRESSED (verified): Shared9 and legacy3 strict assertions pass native/plan/fresh after RED. Omitted/null/Bool/integer/text/fraction/negative/source-start-null distinctions and SIWC captured one-source effects now match reference, with counter Number-not-Bool checks.
  - [x] NO REGRESSION: Direct scalar String54 assertions also pass (66 combined), retaining identities/typed indices, Unicode, source roots/bridges, eager SIL/SONC, rejection/12 malformed no-effects and both named regex mutation aliases. Strict compilation passes; no full suite, unsafe large-slice2.10 or portable admission.
  - [x] LOCKSTEP: Registered fixture/frozen ledger/current book progress, Julia/optional argument facts/map and TYPE/SESSION/live/resume align; book/history/diff/final staged memory/cadence/diagnosis checked before commit. Safe Lua20.3 follows; signature/61.3/23.4 remain open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.20.2 - distinguish Julia null substring width`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.20.3`
  Status: `completed`
  Goal: Repair Lua ordinary substring optional argument parity.
  Dependencies: .23.3.20.2.
  Acceptance: Follow substring-optional-arguments.md and shared reference fixture. Null width and Boolean start/width conversion, preserving false and module-local ceiling; safe PUC5.5.1/LuaJIT native/plan/fresh only. No full runner/malformed native patterns/declared5.4 claim. Independent RED/GREEN, direct scalar String/mutation and small compile checks; sync book/facts/task/live and commit before next backend. Full signature/context/portable admission remains23.4.
  Planned verification tier: focused
  Planned focused checks: Shared argument/effect fixture, direct scalar String controls and selected compilation/format, current book/history/staged continuity guards.
  Planned canonical trigger: None for bounded existing-ADR0006/0023 reference repair under director feature-first cadence; full admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `2a4a655634c0a1971e6d70a42fac476414da8d85`; Julia null-width repair committed, brief0/tree clean.
  Owned paths: Lua ordinary substr branch explicit-null width/local Boolean arguments, strict shared/native-plan-fresh safe test/runner registration and direct String expectation update; frozen ledger/book/Lua/optional-argument facts/task/live continuity. Preserve module-local ceiling/global runtime_integer/free unary-extra arities/regex mutation/clipped intervals. Only safe available PUC5.5.1/LuaJIT; no malformed patterns/full runner/declared5.4.
  Verification tier: `focused`
  Focused checks: Independent both-host new shared/legacy arity RED/GREEN native/plan/fresh, direct scalar String Unicode/kinds/effects/mutation/large-end regression and interpreter/runner source loads, book/history/staged continuity guards.
  Canonical trigger: None for bounded existing ADR0006/0023 reference repair under director feature-first cadence; declared5.4/full signature/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Completion: Ordinary explicit-null width guard and branch-local Boolean1/0 offset conversion now match the frozen reference on both safe hosts. Preserve global runtime_integer, unary/extra-arity behavior, clipped intervals and dedicated mutation; no added module locals. Register the safe shared reference test.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent strict shared test on both PUC5.5.1/LuaJIT observes native null-width bc/bc, Boolean starts abc/abc and widths empty/empty, null effects abc!/SIWC and defined effects !/SIWC. Legacy free unary/extra arities already pass native/plan/fresh; assessment20 separately retained all three-route RED observations.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua pure substr branch maps provided json.null width to omission and delegates Boolean offsets to rejecting runtime_integer. Existing eager values/source capture and safe clipped interval already work.
  - [x] FIX: Three-argument null-width guard and ordinary-arity local offset function with explicit Boolean true1/false0 returns. Keep runtime_integer/free extra arities/character slicing/mutation/module locals unchanged; update older qualified slice expectations and safe runner registration.
  - [x] ADDRESSED (verified): Shared reference and legacy arity groups pass strict canonical JSON native/plan/fresh on both hosts after independent RED. Omitted/null/Boolean/integer/text/fraction/negative/source-start-null controls and SIWC captured source/one call now agree with the fixed Perl/Rust/Dart/Julia reference.
  - [x] NO REGRESSION: Direct eight scalar String groups pass both hosts, retaining Unicode, identity/typed indices, source roots/bridges, eager SIL/SONC, rejection/12 malformed effects, dedicated mutation aliases and prior PUC large-end clipping. Interpreter/runner load checks pass; no malformed native patterns/full runner/declared5.4 or portable admission.
  - [x] LOCKSTEP: Registered fixture/frozen ledger/current book examples, Lua/optional-argument/String facts/map and TYPE/SESSION/live/resume align; book/history/diff/final staged memory/cadence/diagnosis checked before commit. All bounded20 repairs are targeted-checked; return to remaining fluent feature selection23.1.1, with full signature/61.3/23.4 separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.20.3 - align Lua substring optional arguments`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.21`
  Status: `active` / all bounded result implementations targeted-checked; full admission separate
  Goal: Extend ordinary reduce_leaves(initial) immediate receiver blocks with compatible consumers of the actual accumulator kind.
  Dependencies: .23.1.1 reduction-result-continuations.md.
  Children: `.23.3.21.1` Perl, `.23.3.21.2` Rust, `.23.3.21.3` Dart, `.23.3.21.4` Julia, `.23.3.21.5` safe Lua.
  Acceptance: Preserve admitted Array/Hash root traversal, producer/callback scope/copy/order/restoration/errors and invalid-root/shape precedence. Actual scalar/null/Array/Hash results continue through compatible existing methods, with clean incompatible rejection and retained permitted effects. No free helper/global converter/deferred/context/mutation-bang change or complete portable admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.21.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl reduction accumulator result continuations.
  Dependencies: .23.1.1.
  Acceptance: Follow reduction-result-continuations.md; producer-first native/generated controls for Number/String/Bool/null/Array/Hash and empty initial kinds, compatible scalar/generic/container selection, source capture/eager initial/callback order/scoped restoration, clean wrong-family rejection and malformed no-effects. Small changed/direct traversal/compile checks/docs/commit per backend. Preserve root-kind traversal/callback errors/free domains and separate full admission.
  Planned verification tier: focused
  Planned focused checks: Independent public producer/result/effect/shape RED/GREEN and direct traversal/source compilation, selected formatting/analysis, book/history/staged continuity guards. Lua safe PUC5.5.1/LuaJIT only; no malformed native patterns/full runner/declared5.4 claim.
  Planned canonical trigger: None for bounded feature implementation under director feature-first cadence; full domain/context/portable admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `bd06af6bdd7040553bb843683fe9c3d3ebfcc675`; reduction result target frozen/committed, brief0/tree clean.
  Owned paths: Perl dedicated reduction result-family/continuation lowering with existing actual-kind bridge, shared data-result/effect/shape/copy fixture and native/fresh regression plus direct admitted traversal controls, current traversal book/fact/map/task/live docs. Preserve callback bodies/root-kind traversal/global converters and dedicated mutation routes; no scoped/deferred/context expansion.
  Verification tier: `focused`
  Focused checks: Retained public producer/nested/terminal/effect/shape RED, new shared native/fresh data-kind/actual-consumer/scoped restoration/order/rejection/shape/copy RED/GREEN, small direct Array/Hash walk/map traversal controls and syntax/book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen feature under director feature-first cadence; full domain/context/portable admission/final clean push separate.
  Claim verification: none: deterministic authored regressions/preservation controls; no population/completeness measurement.

  Owned implementation regression: First new feature run enables every shared value/kind/copy/scope/order/malformed/invalid-root field and direct wrong-family SIL rejection, but native/fresh prefix_effects is[null,empty] instead of[null,SILC]. Dedicated tree loop returns plain undef after a scalar-result incompatible tail, discarding the already-valid source/initial/callback/cat prefix. Reproduce via retained rejection_prefix Toolbox case; preserve that prefix once and skip incompatible operand before landing. Both source and expected fields remain fixed; no weakening of fixture.

  Completion: Reduction result classification/lowered pair use the existing default_result actual-kind bridge; first dedicated tree step starts as tree_source rather than prematurely using the result kind. Chains containing reduce stay on dedicated traversal instead of emitted-default bypass. Preserve source/initial/callback code and existing dynamic guards; terminal scalar-consumer rejection now evaluates its valid prefix once.
  Verification:
  - [x] REPRODUCE / ISSUE: Retained public native/fresh producer/nested controls pass, appended links return null and skip effects, appended coalesce leaks raw DSL. New permanent test initially passes six admitted traversal checks and fails result handler/value/fresh-load checks. First implementation fixes all shared fields except prefix effects, which give[null,empty] on native/fresh; Toolbox substitution confirms result=undef and drops the prefix.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering tree result classification/pair/Hash metadata marks reduction terminal; first-step family rejection happens before traversal, and emitted-default composition bypasses its callback lowerer. After actual-result composition, the tree loop's plain terminal return still drops an already-valid reduction/cat source prefix.
  - [x] FIX: Reuse existing dynamic actual-kind guard, distinguish input tree step from result family, exclude reduction chains from the generic emitted-default loop and bind the rejected valid prefix once before undef. Callback bodies/root-kind traversal/initial staging/global converters/mutation paths stay intact; no new free helper or deferred/context expansion.
  - [x] ADDRESSED (verified): New shared fixture passes native/fresh Number/String/Array/Hash/false/null/empty initial results, numeric/generic/container selection, named/reversed roots, SI(L*)C source snapshots, callback-scope restoration before consumer, invalid-root initial/callback skipping, malformed no-effects and independent copies. Numeric initial0 remains a valid typed Array write index. Direct wrong-family[null,SIL] and prefix[null,SILC] skip incompatible operand A.
  - [x] NO REGRESSION: Twelve combined checks pass, including admitted Array/Hash walk/map root traversal/copies/sorted-key and index-path order plus unchanged plain reduction; source syntax passes. No full phase0/corpus/gate, callback errors/domain/context/standalone admission or mutation policy claim.
  - [x] LOCKSTEP: Shared fixture/retained probe/frozen progress/current book examples and canonical traversal fact/map, TYPE/SESSION/live/resume align; new Perl fixture explicitly queued in23.4.1 before admission/push. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Rust21.2 independently assesses next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.21.1 - compose Perl reduction accumulator results`.

  Remaining compatible-consumer boundary: The actual-kind bridge explicitly excludes trailing traversal blocks, so exercise an Array accumulator into immediate map_leaves and Hash accumulator into map/reduce before declaring compatible existing methods complete. These are existing immediate callback contracts, not deferred/context expansion. Retained traversal_consumer public case precedes any routing change; keep all work within21.1 until the bounded cases pass.

  Immediate traversal completion: Public traversal_consumer independently observes handler/fresh compile failure near the callback brace. The default_result bridge has no trailing traversal route. A forward-declared existing tree lowerer now handles immediate traversal consumers before generic result guards, preserving its source/root/callback contract. Shared traversal fields[3,B,b,4,4] pass native/fresh: Array and Hash reduction accumulators map with the correct root kind, a pipeline reduction reduces again, and a container selected by coalesce reduces. Final focused test remains twelve assertions with all added fields; source syntax passes. No deferred callback or mutation-bang expansion.
  Continuity maintenance: Required engineering-notes rollover archives exact prior records as segment4954/3557559e9da5; current bounded history check passes without changing immutable older segments.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.21.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust reduction accumulator result continuations.
  Dependencies: .23.3.21.1.
  Acceptance: Follow reduction-result-continuations.md; producer-first native/generated controls for Number/String/Bool/null/Array/Hash and empty initial kinds, compatible scalar/generic/container selection, source capture/eager initial/callback order/scoped restoration, clean wrong-family rejection and malformed no-effects. Small changed/direct traversal/compile checks/docs/commit per backend. Preserve root-kind traversal/callback errors/free domains and separate full admission.
  Planned verification tier: focused
  Planned focused checks: Independent public producer/result/effect/shape RED/GREEN and direct traversal/source compilation, selected formatting/analysis, book/history/staged continuity guards. Lua safe PUC5.5.1/LuaJIT only; no malformed native patterns/full runner/declared5.4 claim.
  Planned canonical trigger: None for bounded feature implementation under director feature-first cadence; full domain/context/portable admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `2eb98f833f712bfeb78d0cdb416060e1905ff72c`; Perl reduction actual-result/immediate traversal feature committed, brief0/tree clean.
  Owned paths: Rust independent ordinary reduction producer/result/shape and callback traversal assessment/repair through native/restored/in-process generated plan, new shared/direct traversal test and any small body fixes justified by concrete observations; current book/frozen/canonical fact/task/live continuity. Preserve root-kind walk/reduce/callback scope/copy/order/errors/global conversion/serialized schema and no standalone/context/deferred admission.
  Verification tier: `focused`
  Focused checks: Public producer-first native/restored/plan RED/GREEN, shared exact result/immediate traversal/shape/rejection/copy/scope snapshots plus direct admitted walk/map/plain reduction, offline compilation/selected rustfmt and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary feature under director feature-first cadence; full signature/context/standalone/portable admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Independent intake: Existing accumulator producer and Array/Hash walk/map/plain-reduce tests pass native/restored/plan before production. Shared test instead stops at compile with callable_contract_arity_mismatch for malformed zero-initial reduction; Core compile enforces the admitted final-codeblock signature. Preserve that existing compile-time policy rather than forcing Perl's runtime-null form. Own separating malformed controls from the valid shared fixture, retaining them in backend-specific permanent tests (including moving Perl shape checks so no proof is lost), then observe real continuation RED. No signature/diagnostic schema change.

  Actual continuation RED: After separating malformed signatures, shared execution reaches copied=null then reports binding_kind_mismatch at its append. A minimal valid effect control independently gives[null,SILL,1,[9]] instead of[3!,SILLC,1,null]. engine eval_receiver_with_trailing_block_chain explicitly terminates after nonfinal reduce_leaves. Reuse its existing immediate callback/dynamic dispatch while retaining actual-kind container guards before incompatible consumer operands. Malformed callback timing/diagnostic discrepancy is separately owned/scheduled by1.2.1.4.1 before admission; preserve current errors in this feature.

  Owned P1 producer defect: First result-flow implementation passes every valid shared result/kind/traversal/copy/scope/effect/rejection field, but invalid_effects order is SIC rather than SC. Runtime eval_tree_receiver_trailing_block_call evaluates the initial and constructs/requires the callback before matching current root kind. An invalid scalar root therefore runs initial side effects despite the existing invalid-root skip contract. Reproduce non-chained scalar/null controls independently, then guard invalid root after shape validation but before initial/callback evaluation; fix now as a frozen-contract prerequisite, retaining malformed diagnostics and valid traversal behavior.

  Completion: Existing trailing-block chain retains the actual reduction value instead of terminal fencing. Once a reduction has run, later container-only consumers check actual kind before operands, with generic/copy/scalar and scalar min/max overloads preserved. Dedicated immediate map/reduce/with dispatch and callback bodies remain unchanged. A reduction-only invalid-root guard after shape validation now precedes initial/callback evaluation.
  Verification:
  - [x] REPRODUCE / ISSUE: Existing producer and admitted traversal controls pass native/restored/plan. Initial shared fixture exposes preserved Core compile-time callback arity errors; valid-only shared then reaches terminal null and copied binding-kind failure. Minimal order RED[null,SILL,1,[9]] independently confirms skipped consumer. First implementation fixes every valid result/shape/copy/scope/traversal field except invalid-root order SIC; standalone scalar/null RED is[null,null,SII] instead of[null,null,S].
  - [x] ROOT CAUSE (WHY + WHERE): engine eval_receiver_with_trailing_block_chain fences every nonfinal reduction; generic dynamic helper routing lacks actual-kind container admission after that result. eval_tree_receiver_trailing_block_call evaluates reduction initial/callback before matching root kind, contrary to the existing invalid-root skip rule. Core callable_contract separately enforces one initial before final codeblock; preserve those errors under ADR0030/0032, with parity repair owned1.2.1.4.1.
  - [x] FIX: Remove reduction fence, guard incompatible container-only consumers by the actual reduction-derived value before operands, and reject invalid reduction roots before initial/callback evaluation while retaining shape precedence. Existing immediate traversal/callback/copy/order/schema/global converters remain. Separate malformed controls into local permanent backend tests rather than weakening signature validation.
  - [x] ADDRESSED (verified): Six focused Rust tests pass native/CompiledSpec-JSON-restored/in-process plan for producer kinds, valid shared Number/String/Bool/null/Array/Hash/empty results, immediate Array/Hash maps/repeated/coalesced reductions, numeric/default/selection/typed index0, copies, SI(L*)C snapshots/scoped restoration and SIL/SILC rejection without A. Scalar/null roots skip initial/callback on direct/chained routes. Existing compile-time zero/two-initial errors remain.
  - [x] NO REGRESSION: Admitted Array/Hash walk/map/plain reduction/root-kind/path-order controls pass all three routes, offline compilation and selected rustfmt pass. Shared-fixture separation preserves Perl shape coverage in a local group; its eighteen native/fresh reference checks pass. No full suite/corpus/gate, standalone/deferred/context/bang or portable admission.
  - [x] LOCKSTEP: Shared valid fixture/local malformed tests/frozen progress, current book examples/qualifiers, canonical traversal fact/map and TYPE/SESSION/live/resume align; invalid-arity phase/diagnostic parity is explicitly scheduled1.2.1.4.1 before admission. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Dart21.3 independently follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.21.2 - compose Rust reduction accumulator results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.21.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart reduction accumulator result continuations.
  Dependencies: .23.3.21.2.
  Acceptance: Follow reduction-result-continuations.md; producer-first native/generated controls for Number/String/Bool/null/Array/Hash and empty initial kinds, compatible scalar/generic/container selection, source capture/eager initial/callback order/scoped restoration, clean wrong-family rejection and malformed no-effects. Small changed/direct traversal/compile checks/docs/commit per backend. Preserve root-kind traversal/callback errors/free domains and separate full admission.
  Planned verification tier: focused
  Planned focused checks: Independent public producer/result/effect/shape RED/GREEN and direct traversal/source compilation, selected formatting/analysis, book/history/staged continuity guards. Lua safe PUC5.5.1/LuaJIT only; no malformed native patterns/full runner/declared5.4 claim.
  Planned canonical trigger: None for bounded feature implementation under director feature-first cadence; full domain/context/portable admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `339e185d1ec3594f33fc66035857aaf4e359abd0`; Rust result/invalid-root repair and valid fixture separation committed, brief0/tree clean.
  Owned paths: Dart independent ordinary reduction producer/result/immediate traversal/shape/effect assessment and any concrete runtime fixes, new shared-valid/local-invalid native/restored/plan test, selected compile/format/analysis and current book/frozen/Dart/traversal facts/task/live continuity. Preserve callback/root/copy/scope/order/global converters/serialization; current callback error phase remains with1.2.1.4.1 parity owner, no normalization here.
  Verification tier: `focused`
  Focused checks: Independent producer-first native/restored/plan shared/local malformed/direct Array-Hash walk/map/plain reduction and invalid-root/order RED/GREEN, selected format/fatal analysis, book/history/staged continuity guards.
  Canonical trigger: None for frozen ordinary feature under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Independent intake: Existing producers/direct traversal, source/initial/callback/consumer snapshots, invalid-root skipping and compile-time malformed errors already pass native/restored/plan. Shared values/kinds/immediate traversals/copies/scope all agree except reduced Number.take returns[] and runs operand A (SILA) instead of null/SIL. interpreter _evaluateFluentCallsWithValue omits reduce_leaves from scalar producer metadata; its container checks also distinguish only scalar-result state, not Array versus Hash result family. Own direct wrong-container-family RED before the small result guard, leaving traversal bodies/root/initial/error behavior unchanged. Dart compile-time error phase joins scheduled1.2.1.4.1; no normalization here.

  Completion: Existing dynamic loop already preserves actual reduction values and immediate traversal consumers. Add reduce_leaves scalar producer metadata and a reduction-derived actual-kind guard for Array/Hash-only consumers before their operands. Traversal/root/initial/callback/copy/scope/order/serialization/global conversion bodies remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Existing producers/direct traversal/source-initial-callback-consumer snapshots/invalid-root skipping and static malformed errors already pass native/restored/plan. Shared RED differs only in direct reduced Number.take: []/SILA rather than null/SIL. Independent opposite-container-family test gives[[],SILKV]/[[],SILA] rather than two null/SIL results; wrong operands K/V/A execute.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart _evaluateFluentCallsWithValue omits reduce_leaves from mayProduceScalar and guards only marked scalar results, without distinguishing actual Array from Hash after a reduction. Existing dedicated traversal/dynamic callback paths otherwise compose correctly, including repeated/coalesced reductions.
  - [x] FIX: Register possible scalar reduction result and retain reduction-derived state for actual Array/Hash-only admission before argument evaluation. Preserve generic/copy, numeric overload and existing callback/root/error policies. No new names, grammar, free arity/global converter/deferred/context or mutation-bang behavior.
  - [x] ADDRESSED (verified): Seven native/restored/plan tests pass shared exact Number/String/Bool/null/Array/Hash/empty results, immediate Array/Hash mapping/repeated/coalesced reductions, numeric/default/selection/typed index0, copies and scoped SI(L*)C snapshots. Direct scalar rejection retains SIL; scalar prefix SILC and both opposite-container-family SIL controls skip incompatible operands. Scalar/null roots already skip initial/callback; compile-time malformed errors remain.
  - [x] NO REGRESSION: Admitted Array/Hash walk/map/plain reduction and sorted-key/index path order pass before/after; direct source capture/initial rebind/one source and scoped restoration remain. Runtime/test formatting and fatal selected analysis pass. No full suite/matrix/gate or full signature/context/portable admission.
  - [x] LOCKSTEP: New permanent test/frozen ledger/current book support/error-phase qualifiers, Dart/traversal facts/map and TYPE/SESSION/live/resume align; existing1.2.1.4.1 explicitly includes Dart static errors. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia21.4 independently follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.21.3 - guard Dart reduction result consumers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.21.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia reduction accumulator result continuations.
  Dependencies: .23.3.21.3.
  Acceptance: Follow reduction-result-continuations.md; producer-first native/generated controls for Number/String/Bool/null/Array/Hash and empty initial kinds, compatible scalar/generic/container selection, source capture/eager initial/callback order/scoped restoration, clean wrong-family rejection and malformed no-effects. Small changed/direct traversal/compile checks/docs/commit per backend. Preserve root-kind traversal/callback errors/free domains and separate full admission.
  Planned verification tier: focused
  Planned focused checks: Independent public producer/result/effect/shape RED/GREEN and direct traversal/source compilation, selected formatting/analysis, book/history/staged continuity guards. Lua safe PUC5.5.1/LuaJIT only; no malformed native patterns/full runner/declared5.4 claim.
  Planned canonical trigger: None for bounded feature implementation under director feature-first cadence; full domain/context/portable admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `0b9046522682d308b26d7935e09b0a279a7ab291`; Dart result-consumer guards committed, brief0/tree clean.
  Owned paths: Julia independent reduction producer/result/immediate traversal/scope/effect/shape assessment and any concrete fixes, strict native/plan/fresh shared-valid/local-invalid test and runner registration, source compilation/current book/frozen/Julia/traversal facts/task/live continuity. Preserve root/callback/copy/order/global conversion/serialization and existing malformed failure phase (parity1.2.1.4.1); no deferred/context/bang expansion.
  Verification tier: `focused`
  Focused checks: Independent producer-first strict Number-not-Bool/false/native-plan-fresh shared/local malformed/direct Array-Hash walk/map/plain reduction, invalid-root/order/opposite-family RED/GREEN, strict compilation/book/history/staged continuity guards.
  Canonical trigger: None for frozen ordinary feature under director feature-first cadence; full signature/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Independent intake: All twelve strict producer assertions pass before production; direct traversal/source/scoped order/invalid-root/static malformed controls also pass. Shared native/plan/fresh has three scalar-rejection failures (Any[]/SILA versus nothing/SIL), with strict counter-kind guards healthy. Opposite-container consumers independently give[[],SILKV]/[[],SILA] on all routes. Interpreter.jl fluent loop lacks reduce_leaves scalar metadata and reduction-derived actual container-kind guards; preserve its already-correct traversal/root/callback policies and repair only this boundary. Julia compile-time malformed errors match Rust/Dart and remain with1.2.1.4.1 before admission.

  Completion: Existing dynamic traversal/result loop already composes valid accumulator/immediate callback results. Add reduce_leaves may-produce-scalar metadata and actual reduction-derived Array/Hash consumer guards (including existing Array-only numeric reducers) before operands. Preserve callback/root/initial/copy/scope/order/registry/serialization and all converter bodies.
  Verification:
  - [x] REPRODUCE / ISSUE: Twelve strict producer assertions pass; direct traversal/source-scoped order/invalid-root and compile-time malformed controls also pass before production. Shared native/plan/fresh gives Any[]/SILA at scalar rejection instead of nothing/SIL, with counter kinds healthy. Opposite-family consumers give[[],SILKV]/[[],SILA] on all three routes.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl fluent loop omits reduction from may_produce_scalar and has scalar state without reduction-derived actual container-family admission. Existing dedicated traversal/callback/root checks already preserve valid results and skip invalid-root initials.
  - [x] FIX: Mark reduction scalar possibilities and guard actual Array/Hash-only consumers before their operands while allowing the existing generic/copy/numeric overload and container transitions. No traversal body, callback scope/copy/order, malformed contract, global conversion or deferred/context/bang normalization.
  - [x] ADDRESSED (verified): Registered forty-three strict native/plan/fresh assertions pass after RED: exact Number/String/false/null/Array/Hash/empty accumulator kinds, Number-not-Bool/false identity/counters, typed index0/copies, numeric/default/selection and immediate/coalesced/repeated traversals, SI(L*)C source capture/scoped restoration, invalid-root skipping and SIL/SILC/opposite-family rejection without operands.
  - [x] NO REGRESSION: Admitted Array/Hash walk/map/plain reduction and sorted-key/index path controls remain passing. Existing compile-time zero/two-initial diagnostics stay; strict package/source compilation passes. No full package/corpus/matrix/gate or full signature/context/portable admission.
  - [x] LOCKSTEP: Registered fixture/frozen ledger/current book support/error-phase qualifiers, Julia/traversal facts/map and TYPE/SESSION/live/resume align;1.2.1.4.1 includes Julia static errors. Book/history/diff/final staged memory/cadence/diagnosis pass. Broader document-pressure check fails on baseline collection/freshness debt; exact intake is retained and1.2.20.1 owns repair before admission/push under the existing feature-first deferral. Safe Lua21.5 independently follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.21.4 - guard Julia reduction result consumers`.

  Broader gate disclosure: Resulting-tree README pressure checker exits1 after document mutation self-tests; raw failures/actual staged patch/base and HEAD/index delta evidence are preserved in document-pressure-intake.*. All runtime43 strict tests, source compile, book render and ordinary memory/cadence/diagnosis checks pass. Existing20 schedule expressly defers policy maintenance until feature coverage. Continue Lua21.5;1.2.20.1 remains mandatory before admission/push, with no broad-gate PASS claim. Current CHANGES date/writer recurrence is corrected; historical heading/collection repairs stay owned.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.21.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua reduction accumulator result continuations.
  Dependencies: .23.3.21.4.
  Acceptance: Follow reduction-result-continuations.md; producer-first native/generated controls for Number/String/Bool/null/Array/Hash and empty initial kinds, compatible scalar/generic/container selection, source capture/eager initial/callback order/scoped restoration, clean wrong-family rejection and malformed no-effects. Small changed/direct traversal/compile checks/docs/commit per backend. Preserve root-kind traversal/callback errors/free domains and separate full admission.
  Planned verification tier: focused
  Planned focused checks: Independent public producer/result/effect/shape RED/GREEN and direct traversal/source compilation, selected formatting/analysis, book/history/staged continuity guards. Lua safe PUC5.5.1/LuaJIT only; no malformed native patterns/full runner/declared5.4 claim.
  Planned canonical trigger: None for bounded feature implementation under director feature-first cadence; full domain/context/portable admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `b871c827b492d46d2b71000aeeac38177e613eb4`; Julia result guards43 strict checks committed with broader document-pressure FAIL accurately retained/owned1.2.20.1 before admission, brief0/tree clean.
  Owned paths: Lua independent safe reduction producer/result/immediate traversal/effect/shape assessment and justified small runtime repair; retained malformed-phase probe, strict shared-valid/local-invalid native/plan/fresh test/runner registration, source loads and current book/frozen/Lua/traversal facts/task/live continuity. Preserve false/module-local ceiling/root/callback/copy/scope/order/global converters/current malformed policy. Only safe PUC5.5.1/LuaJIT; no full runner/native malformed patterns/declared5.4 claim.
  Verification tier: `focused`
  Focused checks: Independent both-host producer-first native/plan/fresh strict JSON shared/direct traversal/actual-kind/opposite-family/order/invalid-root/local malformed RED/GREEN, interpreter/runner loads, book/history/staged memory/cadence/diagnosis. Full document pressure repair remains1.2.20.1 under existing post-feature schedule, no repeated broad gate or PASS claim.
  Canonical trigger: None for frozen ordinary feature under director feature-first cadence; full signature/context/portable/declared5.4 admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement or broad doctrine admission.

  Independent malformed intake: Both safe hosts compile malformed zero/two-initial cases, then native/plan/fresh raise the existing RuntimeInterpreterException helper-arity message (generated routes retain their wrapper prefix). A public diagnostic_sink probe independently captures REDUCTION_ARITY_SOURCE_EFFECT before the zero-initial error on every route. Own this P1 source-before-invalid-signature effect defect here: the fluent preflight omits registered reduction arity and only validates inside evaluate_fluent_calls after receiver evaluation. Invoke existing metadata validation before receiver effects, preserving error class/text/runtime phase; full error parity still belongs1.2.1.4.1. No native malformed patterns are used.

  Independent valid-input RED: Both hosts pass admitted accumulator producers, Array/Hash walk/map/plain traversal and invalid-root skipping on native/plan/fresh. Shared fixture fails at copied binding kind after terminal null; minimal valid order gives[null,SILL,1,[9]] instead of[3!,SILLC,1,null]. Local malformed permanent controls preserve existing runtime error text but observe arity-source before both zero/two-initial failures on every route. Opposite-container tests currently pass only because the terminal fence skips all consumers; retain them through the feature implementation.

  Completion: Remove the nonfinal reduction fence, retain actual reduction-derived kind for container-only consumer guards and preserve scalar-result metadata through compatible bridges. Existing immediate traversal/callback bodies stay. The fluent preflight now calls existing reduction final-codeblock metadata validation before source evaluation, preserving runtime arity messages while fixing source effects. No new module locals.
  Verification:
  - [x] REPRODUCE / ISSUE: Both hosts independently pass producer/root/path/direct traversal and invalid-root controls. Native/plan/fresh shared fails copied binding kind after terminal null; valid order RED[null,SILL,1,[9]] confirms consumer skipped. Public diagnostic_sink and permanent zero/two-initial controls capture source events before existing arity errors on every route. No malformed native regex is used.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua evaluate_fluent_calls terminates after nonfinal reduce_leaves and lacks actual reduction result kind/scalar metadata. Its registered arity validation runs only there, after evaluate_expr has evaluated the receiver; ordinary fluent preflight omits reduction final-codeblock validation.
  - [x] FIX: Continue using actual accumulator, guard Array/Hash-only consumers before operands, mark reduction scalar possibilities with actual-container release and invoke existing reduce metadata validation in preflight before source. Keep callback/root/initial/copy/scope/order/global numeric/Unicode/serialization/mutation paths and existing runtime error class/text/wrappers unchanged.
  - [x] ADDRESSED (verified): Strict canonical JSON shared/native-plan-fresh plus local controls pass both PUC5.5.1/LuaJIT. Exact Number/String/false/null/Array/Hash/empty kinds, typed index0/copies, numeric/default/selection and immediate/coalesced/repeated traversals, scoped SI(L*)C and scalar/prefix/opposite-family rejection retain permitted effects and skip operands. Diagnostic sinks now stay empty for both malformed initial counts while exact arity errors remain.
  - [x] NO REGRESSION: Admitted Array/Hash walk/map/plain reduction/root-kind/sorted-key/index paths and direct invalid-root/source snapshot controls pass. Interpreter/runner source loads pass on both hosts without adding module locals. Only safe named fixtures run; no full runner/unsafe native patterns/declared5.4, full context or portable admission.
  - [x] LOCKSTEP: Safe runner registration/permanent test/probe, frozen progress/current book all-five bounded support and error-phase qualifications, Lua/traversal facts/map and TYPE/SESSION/live/resume align. Lua runtime errors join1.2.1.4.1 diagnostic parity; broad document-pressure FAIL remains owned1.2.20.1 before admission/push, no repeated global-gate PASS claim. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. All bounded21 backend children targeted-checked; next remaining ordinary fluent selection23.1.2.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.21.5 - compose Lua reduction accumulator results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.22`
  Status: `active` / all five bounded backend children targeted-checked; full admission separate
  Goal: Repair existing split_tagged_records eager value construction and meaningful text-to-Array receiver composition.
  Dependencies: .23.1.2 tagged-record-string-bridge.md; SESSION33 retains broader split-domain/admission authority.
  Children: `.23.3.22.1` Perl prerequisite/receiver, `.23.3.22.2` Rust, `.23.3.22.3` Dart, `.23.3.22.4` Julia, `.23.3.22.5` safe Lua.
  Acceptance: Preserve existing helper domains and current backend pure-split policies, argument snapshots/kinds/copy and normal method min-two-RHS shape. Named/literal/derived String sources feed record Arrays then compatible Array/selected scalar/container methods. Independent native/generated producer-first checks before repair; no full boundary/context/portable admission or source-category method promotion.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.22.1`
  Status: `completed` / bounded eager producer and receiver targeted-checked
  Children: `.23.3.22.1.1`, `.23.3.22.1.2`.
  Goal: Repair the current documented Perl eager helper prerequisite before its scalar receiver bridge.
  Dependencies: .23.1.2.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.22.1.1`
  Status: `completed`
  Goal: Repair Perl tagged-record ordinary eager argument snapshots and pure-split reuse.
  Dependencies: .23.1.2.
