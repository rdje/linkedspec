# Grammar, recursion, cursor and capture readiness

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.1`. Measured 2026-09-27 from clean activation
`30b2cc3a0d4ecca2a207d46b658287fd6bbb4c7a`. This is an evidence inventory, not a new language contract.

## Scope and classification

The structured-format campaign remains parked until `.spec` is strong enough and required backend parity is
proved. Its existing catalog supplies requirements. This inventory covers four of the nine self-containment
areas; `.1.1.2` owns state, callables, control, transformation and results, and `.1.1.3` owns composed objectives.
An EBNF-like authoring profile is a later frontend option, separate from the language's parsing power.

**Implemented/admitted** below means the canonical contract records completed runtime admission. Fresh checks
in this slice execute neutral fixtures and structural governance, not each backend or each generated carrier.
**Partial** records a narrower capability or a known defect, not a revocation of unrelated admitted behavior.
**Missing** requires demonstrated absence against an agreed objective. **Compatibility-only** is retained old
behavior outside the portable preferred surface. **Backend-host** identifies substrate or caller orchestration,
not an authored escape hatch. **Forbidden** is deliberate ambient non-authority. **Unassessed** means no bounded
objective proof has yet been collected; it must never be converted into a missing-feature claim by inference.

## Capability ledger

| Mechanism and exact authority | Perl | Rust | Dart | Julia | Lua (PUC and LuaJIT) | Boundary relevant to the campaign |
| --- | --- | --- | --- | --- | --- | --- |
| Entry selection: `capability_conformance/root_rule_selection_contract.json`, `precedence` and `implementation_inventory` | admitted | admitted | admitted | admitted | admitted on both | Explicit selection, then first authored marker, then first authored rule. Selection does not itself match the entry rule's regex. |
| Linked rule families and cursor composition: `capability_conformance/rule_local_cursor_contract.json`, `policy` | admitted | admitted | admitted | admitted | admitted on both | AND consumes, OR/default seeks; child policy is local. Explicit action/blind edges remain distinct. A whole-document grammar must prevent unwanted skipping and prove EOF itself. |
| Recognition-only attempt and progress: `capability_conformance/recognition_transaction_contract.json`, `policy`, `effect_model`, `fixtures` | admitted; known abort defect below | admitted | admitted | admitted | admitted on both | One attempt per linear token; strict match presence is separate from falsey result values. Rollback covers cursor, boundary and marks, not arbitrary AST/user-state mutation. This is not general automatic backtracking or left-recursion support. |
| Source positions/spans and recursive observations: `capability_conformance/typed_source_location_contract.json`, `policy`, `recursive_observations` | admitted internal core | admitted internal core | admitted internal core | admitted internal core | admitted internal core on both | Unicode-scalar half-open spans with same-source identity; detached observations do not grant dispatch authority. Position/Span remain private architectural values, not a new public first-class value syntax. |
| Named regex slots and lossless gaps: `capability_conformance/inter_match_gap_capture_contract.json`, `authored_surfaces`, `segmentation_cases`, `lifecycle_matrix` | admitted | admitted | admitted | admitted | admitted on both | `name=/.../`, target `[name]`, `@capture_gaps`, prefix/interstitial/tail and empty spans. Matching belongs to the target slot; payload/AST construction is authored separately. |

The root and cursor contracts locate each backend consumer in `recurring_gate.consumers`. The typed-source
contract locates value/projection and recursive-observation consumers in `recurring_gate.consumer_sources`.
The transaction contract's `rollout[].paths` and gap contract's `recurring_gate.consumers` supply exact test paths.
These current references preserve separate native, reconstructed, generated-plan and independently emitted roles;
the inventory does not flatten them into a claim that every route ran today.

## Concrete five-backend proof locations

| Family | Perl consumer | Rust consumer | Dart consumer | Julia consumer | Shared Lua consumer |
| --- | --- | --- | --- | --- | --- |
| Entry selection | `t/root_rule_selection_perl_core.t` and `t/root_rule_selection_perl_routes.t` | `rust/linkedspec-runtime/tests/root_rule_selection_admission.rs` | `dart/test/root_rule_selection_admission_test.dart` | `julia/test/root_rule_selection_admission_test.jl` | `lua/test/root_rule_selection_admission_test.lua` |
| Cursor composition | `t/rule_local_cursor_perl_contract.t` | `rust/linkedspec-runtime/tests/rule_local_cursor_contract.rs` | `dart/test/rule_local_cursor_contract_test.dart` | `julia/test/rule_local_cursor_contract_test.jl` | `lua/test/rule_local_cursor_contract_test.lua` |
| Recognition | `t/recognition_transaction_perl_contract.t` | `rust/linkedspec-runtime/tests/recognition_transaction_contract.rs` | `dart/test/recognition_transaction_contract_test.dart` | `julia/test/recognition_transaction_contract_test.jl` | `lua/test/recognition_transaction_contract_test.lua` |
| Typed spans | `t/typed_source_location_values.t` and `t/typed_source_location_perl_contract.t` | `rust/linkedspec-runtime/tests/typed_source_location_contract.rs` | `dart/test/typed_source_location_contract_test.dart` | `julia/test/typed_source_location_contract_test.jl` | `lua/test/typed_source_location_contract_test.lua` |
| Gaps | `t/inter_match_gap_capture_perl_contract.t` | `rust/linkedspec-runtime/tests/inter_match_gap_capture_contract.rs` | `dart/test/inter_match_gap_capture_contract_test.dart` | `julia/test/inter_match_gap_capture_contract_test.jl` | `lua/test/inter_match_gap_capture_contract_test.lua` |

## Limits, defects and follow-up ownership

- **Known partial implementation boundary:** `docs/knowledge/perl-recognition-unwind-actual-state-gap.md` records
  public `Get` plus `exit_now` leaving the input cursor advanced after an uncommitted attempt. Startup `.40.1/.40.2`
  own repair and recurrence; the independent invalidated-token issue remains startup `.38`. Their minimized
  evidence must be considered before claiming abort-safe speculative parsing. This slice has not rerun or fixed them.
- **Compatibility-only:** the typed-source contract lists seven callable aliases and two internal record IDs.
  Legacy `@move_pos` marker semantics do not define portable `@capture_gaps`; see
  `docs/knowledge/inter-match-gap-capture-origin-and-contract.md`. Do not infer portable support from a legacy spelling.
- **Backend-host and forbidden boundary:** engines implement matching and source authority; callers authorize
  input and any parser registry. That does not grant authored filesystem/process/network/environment access.
  ADR0064 is the closure authority. RGX/PGEN are black boxes; their implementation is not inventory evidence.
- **Unassessed objectives:** nesting with exact rejection/EOF and source spans; indentation or context-dependent
  closing delimiters; lossless extraction followed by bounded child parsing. `.1.1.3` must use small representative
  grammars, exact positive/negative outcomes, progress limits and backend/carrier evidence. Existing complete
  S-expression document work is a reusable baseline, not evidence that XML, YAML or a programming language is complete.
- **Confirmed evidence-description defect:** general manifest row `runtime.top_rule_and_parse_mode_controls`
  still says native execution accepts parse-mode controls. The cursor contract explicitly removes global overrides.
  The general checker requires only a string for this row's `contract` field; exact mutation-capability text guards
  do not cover it. Both checkers currently pass. `.1.1.5` owns correction and recurrence before closure-definition
  work; startup `.41.2` remains the broad cursor-guide owner. Use the specific cursor authority in the meantime.

The non-progress contract requires advancing accepted repetition/recursive cycles. This alone is no proof of
arbitrary grammar coverage, guaranteed resource bounds for every host regex, left-recursive grammar support,
or comfortable authoring. Any such objective needs its own explicit requirement and probe before a primitive is proposed.

## Fresh evidence and how to repeat it

All seven commands below passed in this slice. No source/runtime behavior changed.

```bash
env PERL5LIB= bash tools/project_data_run.sh perl tools/check_capability_conformance.pl
env PERL5LIB= bash tools/project_data_run.sh perl tools/check_language_capability_coverage.pl --report
bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py
bash tools/run_python_project_data.sh tools/check_rule_local_cursor_contract.py
bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py
bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py
```

| Check | Observed result |
| --- | --- |
| General census | 20 capabilities; 100 pass, 0 partial, 0 gap states; one legacy exclusion. These are manifest states, not a defect census. |
| Name coverage | 250 calls, 105 corpus sources plus one exact named-mark fixture, 126 independently derived public Perl contracts; zero coverage omissions. This does not execute the corpus. |
| Root selection | 8 selection / 3 failure / 3 strict cases; 7 complete / 0 pending; 54 rejected drift mutations. |
| Cursor families | 36 spellings / 18 edges / 8 parent-child cases; 8 complete / 0 pending; 60 rejected mutations. |
| Recognition | 138 node rows / 250 calls; 8 positive / 17 negative tokens; 6 effect graphs / 6 mark / 8 progress cases; 9/9 rollout; 58 rejected mutations. |
| Typed source | 14 complete / 0 pending; 231 rejected mutations; 92 helper projections / 7 aliases / 2 internal IDs. |
| Gaps | 8 positive / 10 negative selectors; 16 transitions / 10 segmentation cases; 9 complete / 0 pending; 63 semantic plus 34 public mutations. |

Logs are retained under `.linkedspec-data/scratch/selfcontain111-*.log`; the task node retains their digest summary.
The seven commands and committed contract/consumer paths are the durable reproduction source if scratch is absent.
