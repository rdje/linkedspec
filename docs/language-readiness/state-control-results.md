# State, callables, control, transformation and result readiness

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.2`. Measured 2026-09-27 from clean activation
`e9c2eb2ad1c6aa799e50c879c0549a9ccd1f36e3`. This extends
[the grammar/cursor/capture inventory](grammar-cursor-capture.md), using its classification and evidence rules.
It does not change semantics, activate named arguments, or start a format implementation.

## Capability ledger

The entries below describe existing portable contracts and their admitted consumers. All five columns are
source/contract evidence, not fresh execution of those backends. Known narrower implementation defects follow.

| Objective and canonical source | Perl | Rust | Dart | Julia | Lua (both ABIs) | Exact boundary |
| --- | --- | --- | --- | --- | --- | --- |
| Typed working state: `capability_conformance/uniform_binding_contract.json`, `policy` | implemented | implemented | implemented | implemented | implemented | One identifier holds a scalar, array, harray or codeblock; bare reads, kind-checked mutation and typed results. Host storage is not a second namespace. This contract alone does not establish arbitrary recursive grammar-local state restoration. |
| Pure reusable computation: `capability_conformance/callable_signature_contract.json` and `docs/knowledge/terse-user-defined-functions-mvp-contract.md` | implemented | implemented | implemented | implemented | implemented | Positional fixed/final-rest signatures; eager once-only argument evaluation; fresh function-local state and ordinary value results. No implicit caller capture, recursive user functions, defaults or named arguments. Grammar recursion is a distinct capability. |
| Deferred callbacks: `capability_conformance/callable_codeblock_contract.json`, `policy` | admitted | admitted | admitted | admitted | admitted on both | Inert brace-pipe values; copied temporary parameters; live caller nonparameters at invocation; local return. No captured lexical environment; recursive callback invocation is rejected. |
| Branching/iteration: `capability_conformance/logical_helper_contract.json`, `policy`, plus the formal grammar and runtime semantics appendices | implemented, bounded proof | implemented, bounded proof | implemented, known mixed-control defect | implemented, bounded proof | implemented, bounded proof | `if`, `switch`, `while` use typed truthiness and selected-branch/body evaluation. `and`/`or` are eager value helpers. The logical checker does not certify every loop, nesting or return-context combination. |
| Structural transformation: `capability_conformance/write_vivification_contract.json` and `capability_conformance/map_leaves_mutation_contract.json`, `policy` | admitted, known callback defect | admitted, known guard defect | admitted | admitted | admitted on both | Dense typed nested writes publish atomically after expression evaluation. `map_leaves!` transforms an isolated original shape and guards the receiver identity; unrelated effects are not rolled back. Root kind fixes traversal: arrays recurse through arrays, harrays through harrays. This is not unrestricted mixed-tree rewriting. |
| Result construction: uniform binding, callable results and `capability_conformance/scalar_numeric_contract.json` | implemented, known constructor/kind defects | implemented | implemented | implemented | implemented | Structured array/harray values and detached mutation results compose without host constructors. Scalar numerics define their own invalid/null, arity and rounding rules; aggregate reducers have separate ownership and require strict JSON-kind oracles. |

Current admission for the two structural mutations is external: `capability_conformance/manifest.json` records
`language.nested_write_vivification` and `language.map_leaves_receiver_mutation`; `.19.7-.19.9` own admission,
recurrence and public closeout. Their frozen neutral files retain historical pre-implementation strings on purpose.
See `docs/knowledge/mutation-capability-admission.md`. Those strings must not be edited into a new freeze or
misread as current absence. The mutation checkers also consume the unchanged composition authority.

## Five-backend source locations

| Family | Perl | Rust | Dart | Julia | Lua |
| --- | --- | --- | --- | --- | --- |
| Uniform binding | `t/uniform_binding_contract.t` | `rust/linkedspec-runtime/tests/uniform_binding_contract.rs` | `dart/test/uniform_binding_contract_test.dart` | `julia/test/uniform_binding_contract_test.jl` | `lua/test/run.lua`, uniform-binding cases |
| Fixed/rest calls | `t/variadic_user_function_contract.t` | `rust/linkedspec-runtime/tests/variadic_user_function_contract.rs` | `dart/test/variadic_user_function_contract_test.dart` | `julia/test/variadic_user_function_contract_test.jl` | `lua/test/run.lua`, signature-union/variadic cases |
| Callable values | `t/callable_codeblock_literal_contract.t` | `rust/linkedspec-runtime/tests/callable_codeblock_literal_contract.rs` | `dart/test/callable_codeblock_literal_contract_test.dart` | `julia/test/callable_codeblock_literal_contract_test.jl` | `lua/test/callable_codeblock_literal_contract_test.lua` |
| Logical/control contrast | `t/logical_helper_perl_contract.t` | `rust/linkedspec-runtime/tests/logical_helper_contract.rs` | `dart/test/logical_helper_contract_test.dart` | `julia/test/logical_helper_contract_test.jl` | `lua/test/logical_helper_contract_test.lua` |
| Nested writes | `t/write_vivification_perl_contract.t` | `rust/linkedspec-runtime/tests/write_vivification_contract.rs` | `dart/test/write_vivification_contract_test.dart` | `julia/test/write_vivification_contract_test.jl` | `lua/test/write_vivification_contract_test.lua` |
| Receiver transformation | `t/map_leaves_mutation_perl_contract.t` | `rust/linkedspec-runtime/tests/map_leaves_mutation_contract.rs` | `dart/test/map_leaves_mutation_contract_test.dart` | `julia/test/map_leaves_mutation_contract_test.jl` | `lua/test/map_leaves_mutation_contract_test.lua` |

`tools/check_callable_codeblock_five_backend.sh` composes the exact six runtime callback routes.
`logical_helper_contract.json` records per-backend native/reconstructed/generated/emitted roles in its recurring
consumer list. `tools/check_mutation_six_runtime.sh` composes both structural mechanisms and their frozen
composition proof. `tools/check_scalar_numeric_six_runtime.sh` names the exact 55-case runtime routes, including
the Dart named test, inline Julia contract evaluation and shared Lua suite. None of these full runtime drivers
was executed by this inventory slice; their source locations and existing admission records are evidence pointers.

## Confirmed limitations and ownership

| Classification | Concrete evidence / consequence | Existing owner and next use |
| --- | --- | --- |
| Partial: state isolation defects | `docs/knowledge/perl-wrong-kind-collection-host-slot-drift.md` records wrong-kind/absent helpers depending on host arrays/hashes. Do not use a green uniform-binding neutral check as proof of ambient isolation. | Startup `.17`; require current public native/emitted controls before a selected objective depends on this boundary. |
| Partial: mixed control execution | `docs/knowledge/dart-mixed-control-value-block-gap.md` records loss of attached-control return locality/else selection inside marker-selected value ranges. | `DART-STARTUP-READING.2.9`; selected grammars must exercise their actual control nesting, not just each helper separately. |
| Partial: mutation guard/substitution | Startup `.58` records Rust final-assignment receiver-guard bypass; `.59` owns Perl/Rust statement-substitution and guard discrepancies. | Existing startup repair leaves retain ownership; block affected transformation claims until fixed and reverified. |
| Partial: numeric result construction | Startup `.94` records Perl `array(3)` lowering as an aggregate name; `.95` records numeric-string min/max/odd-median results retaining string JSON kind. | Existing `.94/.95`; direct shape literals and strict value-kind oracles are required in representative probes. A workaround does not close either defect. |
| Deliberately outside current callable contract | Recursive pure functions, lexical closures, implicit caller-state capture and user-defined receiver methods are not admitted by these contracts. Natural rule recursion remains separate. | Self-containment `.1.1.3/.1.1.4` must establish an actual parsing/transformation objective before proposing an extension; a limitation alone is not automatic approval. |
| Approved future feature, currently absent | Named binding for fixed user-function parameters is director-approved direction, with positional/rest compatibility and strict errors. Implementation remains parked; defaults are separate. | `PARSER-AUTHORING-APIS.4`; this inventory does not activate it. |
| Compatibility-only / backend-host | Raw host fallback and the legacy Perl plugin registry are not portable grammar tools. Native backends and caller-authorized registries remain execution substrates. | ADR0064 and the general capability exclusion ledger; `.1.1.4` must classify any actual host escape found in an objective and own its replacement. |
| Forbidden ambient authority | No language-strength objective grants arbitrary filesystem, process, network, environment, clock, randomness or FFI access. | ADR0064 / `.1.2` closure boundary. This design rule is not a claim of sandbox security. |

The rule/callable distinctions matter for the upcoming probes. A helper `fn` receives explicit values in fresh
local state; a deferred codeblock sees invocation-time caller state; grammar rules have recognition/cursor
lifecycles. Indentation, matching opening/closing delimiters and nested AST construction must choose and verify
the appropriate mechanism rather than assume these three forms have identical scoping or recursion semantics.

## Fresh neutral evidence

All seven commands passed, with unchanged production and authority files:

```bash
bash tools/run_python_project_data.sh tools/check_uniform_binding_contract.py
bash tools/run_python_project_data.sh tools/check_callable_signature_contract.py
bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py
bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py
bash tools/run_python_project_data.sh tools/check_scalar_numeric_contract.py
bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py
bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py
```

| Check | Observed result |
| --- | --- |
| Uniform binding | 11 migrations / 7 executions / 6 invalid selectors / 8 constructors in the neutral model. |
| Signature | 3 definitions / 9 calls / 7 invalid definitions. |
| Callable blocks | 7 literals / 11 calls / 9 invalid literals / 7 invalid calls / 4 invalid declarations / 8 contextual forms; 23 governance mutations. |
| Logical | 17 truthiness / 10 helper / 3 effect cases; rollout 8 complete / 0 pending; 26 drift mutations. |
| Scalar numeric | 55 cases / 18 helpers. |
| Nested writes | 5 valid / 7 invalid syntax, 11 success / 16 structural failure / 3 evaluation failure / 3 read exclusions, 8 composed writes; 105 rejected mutations. |
| Receiver mutation | 4 valid / 14 invalid syntax, 5 exclusions, 10 success / 8 pre-commit failures, continuation/shadow/guard/nonbang/detachment, 6 callback / 1 continuation composition; 167 base + 592 composition mutations. |

Logs are optional retained `.linkedspec-data/scratch/selfcontain112-*.log` transcripts; the owning task retains
their digests. The next leaf executes small representative objectives with exact authored source, positive and
negative inputs, output kinds/spans and tool evidence. No complete-standard, general closure, resource-bound or
all-backend runtime claim follows from these neutral counts.
