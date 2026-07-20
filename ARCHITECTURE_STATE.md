# ARCHITECTURE STATE
Live architecture snapshot for LinkedSpec.

This document is the current high-level technical reading of the project shape. It is meant to steer implementation, record important architectural judgments, and give future sessions a fast way to re-enter the codebase with the right mental model.

## Status
- Last refreshed: `2026-07-20`
- `2026-07-20` semantic-introspection design refresh: ADR `0049` / `FUTURE-PARITY-BACKLOG.10.1` fixes the planned
  `linkedspec-semantic-model-v1` and `linkedspec-semantic-query-v1` before behavior. One immutable native
  `SemanticIndex` normalizes existing compiled/ActionIR/provenance/generated/diagnostic authorities plus optional
  caller-captured execution observations; exact snapshot-local ids/order, record/relation/shape/evidence vocabularies,
  page/budget accounting, source ceilings/redactions, and schema evolution prevent backend IR leakage. The outward
  descriptor stays separate: a toolbox probe proved its Perl compiled-regex/coderef values are not portable JSON.
  MCP is only registered-handle capabilities/query transport. Dependency-ordered `.10.2-.10.10` split neutral,
  five backend/six runtime, recurring, MCP, and public work; executable neutral contract `.10.2` is next. No current
  parser/compiler/runtime/descriptor/generated/CLI/trace/MCP behavior changed.
- `2026-07-20` repeated-action public closeout: repeated-action recurring/public no-drift is closed at 8 complete / 0 pending.
  The 25-document public contract denies 12 stale claims and rejects 54 mutations. Bare `OR` is minimum-one
  repetition, explicit repeated action returns collect one typed value per accepted hit, lifecycle returns retain
  whole-rule authority, pipe remains scalar, and generated source remains v2. Complete child inventory also closes
  `.9.1.1`, `.9.1.10`, `.9.1`, and `.9`; semantic-introspection design `.10.1` follows and is now complete.
- `2026-07-20` repeated-action recurring refresh: `FUTURE-PARITY-BACKLOG.9.1.10.6` adds no semantic path. One
  omission-sensitive driver composes the neutral model, exact Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT consumers,
  the contract-projected `success_explicit_repeated_action_results` case across five commands and two option
  environments, and generated/capability/language-coverage ledgers. Governance advances only recurring to
  seven of eight rollout legs and 44 rejected mutations at that recurring-only boundary. Canonical CI exposes the
  driver behind `LINKEDSPEC_RUN_REPEATED_ACTION_RESULT_MATRIX=1`; the following public leaf closes the rollout.
- `2026-07-20` rule-local cursor public no-drift refresh: `FUTURE-PARITY-BACKLOG.9.1.9` makes current public
  accuracy executable. README/toolbox/user guide, capability/CLI guidance, roadmaps, task/live architecture,
  ADR `0044`, Knowledge Map, and mdBook API/backend/runtime/status/user-model pages carry exact required markers;
  stale current global-option, pending-backend, generated-v1, and pending-public claims fail mechanically. Cursor
  governance closes at 75 migration files / 8 complete + 0 pending / 60 mutations, while `.9.1`/`.9` remain active
  because child `.9.1.10` separately owns explicit repeated-OR action-result shape. The recurring driver remains
  `tools/check_rule_local_cursor_five_backend.sh`; inter-match gap capture has satisfied its cursor prerequisite
  but still requires explicit activation.
- `2026-07-20` duplicate-slot recurring/public no-drift refresh: final leaf
  `FUTURE-PARITY-BACKLOG.9.1.8.1.7` adds no semantic execution path. One omission-sensitive recurring driver
  composes the exact Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT admissions, selected 5x2x1 primary AND-consume
  proof, and generated/capability/language-coverage ledgers. The executable contract requires 22 current public
  documents, forbids 12 stale current claims, rejects 59 mutations, and closes rollout at
  7 complete / 0 pending. Its two parse-mode-chapter scanner paths are classified under cursor public owner
  `.9.1.9`, advancing only that inventory to 75 files / 7 complete + 1 pending / 56 mutations. The driver is
  `tools/check_duplicate_regex_slot_identity_five_backend.sh`. KM 645/4,745, mdBook/four doctrines, canonical
  root 7+5, cursor 288, duplicate Perl 12, primary 65x2, and Phase 0 1,031/1,031 in 640 seconds pass.
- `2026-07-20` duplicate regex-slot contract refresh: ADR `0047` and
  `linkedspec-duplicate-regex-slot-identity-v1` make the audited boundary executable without changing a backend.
  Duplicate pattern text stays legal; structural identity is target rule plus regex index, with ADR `0045`'s
  future stable name resolving to that same identity. Ordered execution matches its known required slot and resets
  the sequence per repeated iteration. Choice prefers earliest start then lowest authored order. Descriptor/trace
  obligations carry typed identity, while generated source stays v2/format 2 because compiled payload identity
  survives. The checker passes 5 fixtures, 2 diagnostics, 6 runtime rows, 1 complete + 6 pending rollout, and 23
  drift mutations. KM 637/4,685, mdBook/four doctrines, canonical primary 65x2, and Phase 0 1,031/1,031 in 635
  seconds pass. Perl `.2` is the first behavior owner.
- `2026-07-20` duplicate regex-slot audit refresh: behavior-free `FUTURE-PARITY-BACKLOG.9.1.8.1.0` proves every
  parser/compiler/descriptor/generated payload retains two identical authored slots, while ordered execution
  diverges later. Perl `LinkedRE::oredRE` and Rust `CompiledAlternation` match one combined alternation, report
  the earlier duplicate branch, and fail their expected-sequence-index check. Dart `_matchSpecific`, Julia
  `_match_runtime_specific`, and Lua `match_specific` instead compile the already-required pattern alone and
  reattach its authored index. Exact ordinary native/generated probes return null for Perl/Rust and `ordered-ok`
  for Dart/Julia/PUC Lua/LuaJIT; every duplicate OR chooses the first authored slot. Repeated Perl live/emitted
  fails where both Lua ABIs native/generated preserve two pairs; a non-identical Perl repeated control is exact.
  Generated plan v2 stays minimal `{label,family}` because compiled payload identity survives. ADR/neutral contract
  `.1`, Perl/Rust repair `.2-.3`, preserving-backend locks `.4-.6`, and recurring/public closeout `.7` are frozen;
  no executable behavior changes in the audit. Signoff passes KM 636/4,678, mdBook/four doctrines, canonical
  primary 65x2, and Phase 0 1,031/1,031 in 619 seconds, followed by exact generated-output cleanup.
- `2026-07-19` recurring cursor-admission refresh: `FUTURE-PARITY-BACKLOG.9.1.8` adds no cursor semantics. One
  omission-sensitive driver composes the 14-role Perl consumer, exact 15-role Rust/Dart/Julia consumers, the same
  15-role Lua source on PUC Lua and LuaJIT, the selected 5x2x5 primary projection, and generated/capability/
  language-coverage ledgers. The neutral checker locks all six commands, role lists, case ids, support checks,
  canonical `LINKEDSPEC_RUN_CURSOR_MATRIX=1` registration, and seven new recurring mutations. Exact proof is
  Perl 288, Rust/Dart admission, Julia 104, Lua 119/119x2, primary 5x2x5, capability 80/0/0, and coverage
  246/105+1/122. Governance is now 72 migration files / 7 complete + 1 pending / 56 mutations. Identical-regex
  dependency identity `.9.1.8.1` and final public no-drift `.9.1.9` remain separate owners.
- `2026-07-19` root-selection public no-drift refresh: final admission `.9.1.1.2.6` closes the ADR `0046`
  rollout at 7 complete / 0 pending. `tools/check_root_rule_selection_five_backend.sh` composes Perl, Rust, Dart,
  Julia, PUC Lua, LuaJIT, the selected 5x2x6 primary projection, and the generated/capability/coverage ledgers.
  The neutral checker now requires 25 public/KM/task documents, forbids 19 stale current claims, requires both
  roadmap projections, and rejects 54 semantic, topology, recurring, public, and rollout mutations. Canonical CI
  passes primary 65/65x2 plus Phase 0 1,031/1,031 in 642 seconds. The root scanner's reference to the parse-mode-
  named mdBook chapter is explicitly owned by the adjacent cursor inventory, producing the then-current 71 files
  at unchanged 6+2/49 before recurring cursor admission.
- `2026-07-19` Lua root-selection-admission refresh: `FUTURE-PARITY-BACKLOG.9.1.1.2.5.3` composes every already-
  current Lua root-selection projection through one contract-declared 15-role source run unchanged on PUC Lua and
  LuaJIT. The consumer adds no semantic owner. Hand-authored selection evidence returns from lifecycle `I`; the
  fixed shared request-trace source preserves canonical `E` bytes. The root checker locks exact role order and
  completion, both backend-driver legs, canonical tracked input/optional registration, six primary case ids, Lua
  rollout, and five new omission mutations. Exact topology RED 3/3x2 becomes 139/139x2; package 177/177x2,
  primary 65/65x4, corpus 105/105x2, and the then-current root boundary was 6+1 / 44 mutations. KM
  633/4,653, mdBook/four doctrines, and canonical Phase 0 1,031/1,031 in 641 seconds pass. Safe cleanup removes
  reproducible book/Python/Julia-compiled output plus four closed repo-local logs. Only final recurring/public
  no-drift `.9.1.1.2.6` remains after the prepared commit.
- `2026-07-19` Lua cursor-admission refresh: `FUTURE-PARITY-BACKLOG.9.1.7.6` composes the already-current Lua
  normalization, native/normalized/loaded execution, descriptor v1, emitted/generated v2, trace, mixed/recursive,
  structural, removal, primary, and diagnostic owners through one exact 15-role consumer on PUC Lua and LuaJIT.
  The consumer introduces no second semantic route. The neutral checker locks every role, both backend-driver
  invocations, canonical optional registration, rollout state, and five new omission mutations. Exact pre-contract
  RED is 3/3 per ABI; green is 119/119 per ABI. Complete package is 177/177x2, primary is 65/65x4, corpus is
  105/105x2, and governance advances only Lua to 69 files / 6+2 rollout / 49 mutations. Knowledge Map 632/4,642,
  mdBook, four doctrines, canonical root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 647 seconds
  pass. The cursor parent is complete; only the clean commit boundary remains before separate root admission.
- `2026-07-19` Lua generated-source-v2 refresh: `FUTURE-PARITY-BACKLOG.9.1.7.4` advances newly emitted modules to
  `linkedspec-generated-source-v2` / format 2 while retaining only the minimal ordered `{label, family}` plan.
  Generated entry derives seek for default/OR families and consume for AND families; compact Pipe now classifies
  as OR/choice. Module load validates contract identity before decoding the embedded spec payload, so stale v1
  returns portable expected/actual/regeneration fields even when its payload is independently corrupt. The public
  v1 validator/executors/emitter are retired. Deterministic direct, traced, persisted-fresh, all-family, structural,
  and contract-sourced subset proof passes both PUC Lua and LuaJIT at 106/106 dedicated and 2,027 focused assertions
  per ABI. Package remains 176/177x2 only at staged help, every primary ABI/environment leg remains 32/65, corpus
  remains 105/105x2, and governance advances only to 69/5+3/44; public removal/admission remain `.5-.6`. KM is
  630/4,622; mdBook/four doctrines and canonical root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in
  644 seconds pass. Generated book/cache/native artifacts are removed.
- `2026-07-19` Lua cursor-descriptor refresh: `FUTURE-PARITY-BACKLOG.9.1.7.3` replaces the descriptor-global
  seek field with `linkedspec-rule-local-cursor-v1`. Each rule projects authored family, derived cursor policy,
  normalized aggregate ownership, and ordered semantic edge rows directly from `mode_metadata`, `action_edges`,
  and `blind_edges`; no decoder, mutable descriptor policy, or second edge-normalization path exists. Action rows
  expose resolved child slots, including omitted-to-zero normalization; blind rows expose JSON null. Handler,
  label/line/top-marker/mode, entry-rule identity, and the established function/dependency records remain exact.
  Direct, normalized `SpecFile` JSON, and loaded descriptor bytes agree with loaded AND execution. Identical
  364/776 RED becomes 875/875 green per ABI; seven focused consumers total 1,921 assertions per ABI. Generated
  v1, explicit outer options, primary help/request trace, and rollout remain staged for `.4-.6`. Final proof is
  KM 629/4,611, mdBook/four doctrines, and canonical root 7+5, cursor 288, primary 65x2, plus Phase 0
  1,031/1,031 in 621 seconds.
- `2026-07-19` Lua cursor-runtime refresh: `FUTURE-PARITY-BACKLOG.9.1.7.2` derives one execution policy at every
  ordinary `execute_rule(...)` entry. Exact AND consumes and sequences; OR/default seeks and chooses. Action,
  blind, direct-call, and recursive children carry the current cursor but re-enter the same owner and derive from
  their own compiled family. Live, loaded-default, normalized `SpecFile` JSON, and traced execution share this
  path; rule and regex trace records expose the effective family/policy. Missing engine policy means intrinsic
  behavior, while an explicit value remains the staged outer compatibility seam for `.5`. Generated-source v1
  remains separately derived from its validated legacy handler family with historical seek—including compact
  Pipe AND/sequence—until `.4`. Focused execution is 110 per ABI and six focused consumers total 1,046 per ABI;
  package remains 176/177x2, primary 32/65x4, corpus 105/105x2, and governance is 68/5+3/44 after registering the
  execution consumer. Descriptor, generated-v2, public-removal, and admission owners remain `.3-.6`.
- `2026-07-18` Julia cursor admission refresh: `FUTURE-PARITY-BACKLOG.9.1.6.6` adds one exact
  contract-declared 15-role consumer over native default/AND, normalized, loaded, descriptor v1, emitted/generated
  v2 direct/trace, mixed/recursive, both structural replacements, static removal, primary, and all diagnostics.
  The checker locks each role, the tracked consumer, complete Julia driver, optional canonical registration, and
  five new omission mutations. Focused composition is 104, complete Julia is 3,291, ten real-process families and
  shared primary 65/65x2 pass, corpus is 105/105, and governance is 67 files / 5+3 rollout / 44 mutations. Only
  Julia advances; `.9.1.6` closes and root admission `.9.1.1.2.4.3` is next.
- `2026-07-18` Julia cursor-option refresh: `FUTURE-PARITY-BACKLOG.9.1.6.5` removes the final caller-global
  high-level seam. `LinkedSpecRuntimeEngine` stores no cursor mode; engine construction, loaded `create_engine`,
  corpus execution, and primary execution derive only from entered rule family. Dynamic `parse_mode`/`parseMode`
  keys fail before input/user code with `prepare_options/parse_mode_override_removed` and normalized
  `option_name=parse_mode`. Primary help and request trace omit the field; retired `--parse-mode` returns exact
  usage exit 2 guidance; `--top-rule` is unchanged. `LinkedSpecParseMode` survives only in low-level matching.
  Focused removal is 53, complete Julia is 3,187, real-process primary is green, shared primary is 65/65x2,
  corpus is 105/105, and neutral governance is 66 files / 4+4 rollout / 39 mutations at that slice. Composed
  admission `.6` has since advanced the Julia row.
- `2026-07-18` Julia generated-source v2 refresh: `FUTURE-PARITY-BACKLOG.9.1.6.4` advances new artifacts to
  `linkedspec-generated-source-v2` / format 2 while retaining the minimal ordered label/family plan. Validation
  derives seek for default/OR/repetition families and consume for the five AND families; runtime uses that derived
  policy and structural interpretation at every generated rule entry. Contract validation precedes normalized
  payload reconstruction, so a v1 identity wins over even corrupt payload bytes with exact expected/actual fields
  and `.spec` regeneration guidance. The private forced-seek v1 engine is gone; compact `Pipe` is generated OR.
  Direct, traced, accepted-subset, root-route, diagnostic, logical, variadic, binding, punctuation, named-mark, and
  fresh isolated module roles pass. Complete Julia is 3,133 plus only the frozen help mismatch; primary remains
  32/65x2, corpus 105, and governance 67/4+4/39 at that slice. Public override removal and admission have since
  landed in `.5-.6`.
- `2026-07-18` Julia cursor descriptor refresh: `FUTURE-PARITY-BACKLOG.9.1.6.3` makes the outward descriptor a
  pure cursor-v1 projection. Root metadata replaces global `parse_mode` with
  `linkedspec-rule-local-cursor-v1`; each rule derives family/policy and projects aggregate ownership plus exact
  ownership/target/child-index/block/fluent edge rows from normalized compiled tables. Direct, normalized
  `SpecFile`-JSON, and loaded descriptor bytes agree; no descriptor decoder or cursor input exists. Focused proof
  is 809, complete package is 3,129 plus the frozen help mismatch, corpus 105, primary 32/65x2, and governance
  67/4+4/39 at that slice. Generated v2, public removal, and admission are now complete through `.6`.
- `2026-07-18` Julia cursor runtime refresh: `FUTURE-PARITY-BACKLOG.9.1.6.2` adds one entered-rule execution
  policy in `julia/src/runtime/Interpreter.jl`. Exact AND consumes and sequences; OR/default seeks and chooses.
  Blind, action, explicit-call, and recursive children receive only the current cursor and rederive from their own
  compiled family. Direct, loaded-default, normalized `SpecFile` JSON, and traced routes share this owner; rule
  trace scopes expose family plus effective policy. Missing engine option means intrinsic behavior, while an
  explicit value remains a temporary outer CLI/corpus adapter. Generated v1 uses a private seek/family adapter so
  its v1/format-1 meaning could not drift before `.4`. Focused execution is 104, generated proof 60, complete package
  2,320 plus the frozen help mismatch, corpus 105, shared primary 32/65x2, and governance 67/4+4/39. Generated-v2,
  descriptor `.3` followed; `.4` removed the generated-v1 adapter, `.5` has now removed public options, and
  admission `.6` is now complete.
- `2026-07-18` root-selection decision: ADR `0046` and `linkedspec-root-rule-selection-v1` order selection as
  explicit selector (including `--top-rule NAME`) > first authored `Rule::` > first authored ordinary `Rule:`.
  Authored `is_top` remains syntax identity, effective selection is execution state, request trace retains
  explicit/`<default>` identity, and strict-unused receives no synthetic reference or exemption. Eight selection,
  three failure, and three strict cases plus 34 mutations now govern 4/7: neutral, Perl, Rust, and Dart are
  admitted. Julia preflight `.9.1.1.2.4.0` measures exact shared primary at 31/65 in both environments. Its one
  root-owned failure is markerless validation; 22 help/usage and 11 request-trace failures belong to pending
  cursor migration `.9.1.6`. Julia now preserves ordered authored markers across all composed routes and `.9.1.6.5`
  has removed those 33 cursor-owned mismatches, producing exact shared 65/65x2. Root core `.4.1`, composed routes
  `.4.2` and cursor admission `.9.1.6.6` are now complete; exact root admission `.4.3` is next. Julia is
  marker-optional; Lua remains marker-required; final
  public no-drift remains `.6`.
- `2026-07-18` refresh: Rust cursor admission `FUTURE-PARITY-BACKLOG.9.1.4.7` declares one exact 15-role consumer
  spanning native default/AND, ordinary serialized, loaded, descriptor v1, emitted source v2, generated direct/
  trace, mixed parent/child, recursion, both structural replacements, static removal, primary command, and all
  eight portable diagnostic/removal outcomes. The consumer requires exact role-set equality and once-only
  completion. The neutral checker requires every source marker, canonical tracked-file registration, the complete
  runtime-package Rust gate, and canonical optional-Rust reachability; it rejects 34 mutations. Only
  `rust_parity` advances, so rollout is 3 complete / 5 pending at the unchanged 68-file migration inventory.
  Complete Rust and canonical proof are green at clean commit `288da21a`; the parent is closed. Dart preflight
  `.9.1.5.0` now records eleven governed paths, compact-pipe/bare-edge/global-propagation drift, descriptor and
  generated v1 seams, 104/104 focused plus 105/105 corpus proof, the exact staged 30/63x2 primary boundary, and
  dependency-safe implementation children `.1-.6` without executable changes. Dart normalization `.9.1.5.1` now
  removes compact-pipe identity drift, retains bare references only at a physical line's first member or header
  rest, resolves them after all labels are known, derives family-owned action/blind dispatch, and attaches exact
  neutral diagnostics to the existing validation exception. Compiled state carries those normalized tables while
  a named legacy adapter preserved pre-`.2` runtime interpretation. Dart execution `.9.1.5.2` now removes that
  compiled adapter and computes one immutable entry policy from exact rule family: AND consumes/sequences and
  OR/default seeks/chooses. Child action, blind, direct-call, and recursive entries derive again from their own
  metadata; live, loaded, normalized-JSON, and traced routes share this seam. The engine-global field is now read
  only by generated-v1 compatibility until `.4`. Descriptor `.9.1.5.3` now projects pure normalized state: root
  `cursor_contract`, per-rule family/derived policy/aggregate ownership, exact five-field resolved-edge rows, and
  existing label/line/top/mode identity. Direct, normalized-JSON, and loaded descriptors agree; no descriptor input
  or mutable cursor field exists. Generated-source `.9.1.5.4` now emits v2/format 2 and reconstructs only normalized
  `SpecFile` state plus one ordered label/family plan. Each validated family derives cursor and sequence/choice;
  no cursor field is serialized. Fresh modules reject v1 before payload reconstruction with exact contract ids and
  regeneration guidance. Public option/CLI `.9.1.5.5` now removes the engine, loader, corpus, and staged-parser
  global override seams, preserves only the low-level seek/consume matcher primitive, recognizes `--parse-mode`
  only for the targeted exit-2 migration error, and omits the request-trace field. Complete Dart is 260/260,
  primary is 63/63 in both environments, corpus remains 105/105, and the migration inventory contracts from 68 to
  66 files with all 34 mutations intact. Canonical CI passes Perl admission 288, reference primary 63x2, and Phase
  0 1,031/1,031 in 627 seconds. Composed admission remains `.9.1.5.6`.
- `2026-07-17` refresh: composed Perl cursor admission `FUTURE-PARITY-BACKLOG.9.1.3.6` declares one exact 14-role
  consumer spanning live default/AND, descriptor v1, emitted source v2, generated direct/trace, loaded spec,
  mixed parent/child, recursion, both structural replacements, dynamic removal, primary command, and all eight
  portable diagnostics. The neutral checker verifies the consumer markers plus canonical registration and rejects
  29 mutations. Only `perl_reference` advances, so rollout is 2 complete / 6 pending at the unchanged 72-file
  migration inventory; capability/current generated-source truth remains 80/0/0. Rust `.9.1.4` is next after the
  clean Perl parent closeout.
- `2026-07-17` refresh: ADR `0045` recovers historical “super split” as inter-match gap capture in repeated
  OR/default action rules, not blind calls. The enclosing rule owns repeated selection/gap orchestration; each
  action edge identifies the target rule and zero-based regex slot that own the match, and the target retains its
  lifecycle/code. Imported-baseline and current live proof confirm automatic prefix/interstitial capture followed
  by post-action boundary advance; no final tail is automatic. Accepted future `@capture_gaps`, typed invocation-local
  spans, exact failure/tail policy, and five-backend rollout remain dependency-gated. Stable named slots use the
  ratified future same-line `name=/regex/` declaration and `Rule[name]` selector with non-semantic horizontal
  spacing around `=`; that surface is also unimplemented. The audit additionally records current marker drift:
  Perl anonymous markers are rule-level, Lua's are preceding-slot events, and Rust/Dart/Julia do not execute them
  natively. Explicit helpers are separate; this decision slice changes no runtime behavior.
- `2026-07-17` refresh: Perl generated-source `FUTURE-PARITY-BACKLOG.9.1.3.4` now emits
  `linkedspec-generated-source-v2` / format 2 from intrinsic rule handlers. Its minimal ordered plan remains
  `{label, family}`; `LinkedSpec::GeneratedSource` owns the exact five seek/five consume derivation. Transitional
  option values cannot change source bytes. V1 reconstruction fails at `validate_generated_plan` with portable
  expected/actual contract fields and requires regeneration from `.spec`. Fresh load, direct/traced execution,
  source identity, and existing plan drift diagnostics remain intact. The token inventory at that boundary was 87:
  this slice makes
  `SpecEntry.pm` and the synchronized generated-handlers chapter token-free, and also reconciles the action/
  lifecycle chapter token removed by `ccf4cad7` without its required inventory update. API/CLI removal has since
  landed under `.9.1.3.5`.
- `2026-07-17` refresh: Perl API/CLI `FUTURE-PARITY-BACKLOG.9.1.3.5` now rejects both dynamic legacy option
  spellings at `prepare_options` with `parse_mode_override_removed` and normalized `option_name=parse_mode`;
  generated emission preserves that portable failure with source identity. The primary command removes the flag
  from help and request trace, recognizes it only for the exact targeted usage-exit-2 message, and replaces the
  two global-mode success cases with structural default-seek/AND-consume cases. All 63 cases pass in default and
  POSIX environments. Sixteen completed test/fixture paths become token-free; `GeneratedSource.pm` joins the
  error-envelope ownership set, leaving an exact 72-file migration inventory. Composed Perl admission remains
  `.9.1.3.6`.
- `2026-07-17` refresh: Perl descriptor projection `FUTURE-PARITY-BACKLOG.9.1.3.3` now identifies
  `linkedspec-rule-local-cursor-v1`, removes descriptor-wide global-mode metadata, and publishes each rule's
  intrinsic `cursor_policy` plus ordered `resolved_edges`. Every resolved row contains semantic ownership,
  target, regex index, block, and fluent facts; optional `source_form` provenance is observational only. The
  descriptor and live paths agree across all eight parent/child mechanisms and both structural replacements.
  That slice deliberately left standalone generated source v1 for `.9.1.3.4`; generated v2 and option/CLI removal
  are now current.
- `2026-07-17` refresh: Perl live cursor execution `FUTURE-PARITY-BACKLOG.9.1.3.2` now feeds normalized per-rule
  `cursor_policy` into normal live/loaded HandlerIR and LinkedRE calls. AND families consume; default/OR families
  seek; parent/option state does not propagate across top, blind/action, explicit-call, or recursive entry. Rule
  trace records the intrinsic policy. That slice retained a separately built generated-source-v1 artifact handler
  for the staged `.9.1.3.4` boundary; v2 has since removed it and `.9.1.3.5` has retired the API/CLI override. Focused live 38,
  normalization 272, and Phase 0 1,031 pass. A pre-existing identical-regex dependency-index alias is tracked by
  `.9.1.8.1` rather than folded into cursor semantics.
- `2026-07-17` refresh: Perl normalization `FUTURE-PARITY-BACKLOG.9.1.3.1` implements the preflight seam without
  crossing into live cursor execution. Bootstrap retains typed complete-line bare candidates after reserved
  lifecycle forms; Compiler supplies the full declaration set; RuleIR resolves forward references, lowers AND
  bare edges to blind ownership and OR/default bare edges to action ownership, validates one ownership set, and
  publishes derived per-rule `family`, `cursor_policy`, and `edge_ownership`. Exact portable failures survive
  RuntimeContext. The focused source contract covers 36 family spellings, 18 edge cases, and six ownership sets
  in 272 assertions. This is the normalization boundary consumed by live-execution slice `.9.1.3.2`.
- `2026-07-17` refresh: verified Perl cursor preflight `FUTURE-PARITY-BACKLOG.9.1.3.0` maps six implementation boundaries:
  bootstrap/validation, RuleIR normalization, live handler emission, descriptor state, generated v2, and primary
  CLI/tests. Toolbox bootstrap proof finds bare `Child` is currently dropped while bare fluent/block forms become
  arbitrary `ChildCODE`, so typed line-level candidates must resolve against the full declared-rule set before
  RuleIR validation. Removing the reference option changes 35 mandatory canonical cases; ten shared manifest/
  help/usage/trace files therefore migrate with `.9.1.3.5`, while `.9.1.8` retains final symmetric admission and
  shared documentation. Reference CLI 63x2 and all governance checks pass; no runtime behavior changes in the
  preflight.
- `2026-07-17` refresh: neutral cursor contract `FUTURE-PARITY-BACKLOG.9.1.2` makes ADR `0044` executable without
  behavior admission. `linkedspec-rule-local-cursor-v1` checks 36 family spellings, 18 edge cases, six ownership
  sets, eight parent/child mechanisms, two structural replacements, targeted option/CLI removal, per-rule
  descriptor facts, generated-source v2 derivation, eight portable diagnostics, an exact 91-file migration
  inventory, and 27 mutations. Rollout is 1 complete / 7 pending; capability/current-generated remain 80/0/0,
  coverage remains 246/105+1/122, and canonical local CI passes CLI 63x2 plus Phase 0 `1..1031`/634s. Current
  backend behavior remains unchanged.
- `2026-07-17` refresh: logical public no-drift `FUTURE-PARITY-BACKLOG.5.2.9` makes the native/generated/primary
  contract and recurring proof the one public story. Twenty authoritative documents cover the control/value
  guides, emitted Perl, four backend READMEs, mdBook catalog/reference/action/handoff/status, capability/CLI,
  roadmaps/architecture/live/task state, and Knowledge Map; 13 stale-current claims are forbidden. The checker
  rejects 26 semantic/topology/public mutations. Rollout is 8 complete / 0 pending and parent `.5.2` is closed;
  no runtime implementation changed.
- `2026-07-17` refresh: recurring logical admission `FUTURE-PARITY-BACKLOG.5.2.8` adds one strict
  omission-checked driver over `linkedspec-logical-helper-v1`, the exact native/generated role inventory for
  Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT, selected primary case `success_logical_helpers_eager` under five
  commands and two environments, and generated-source/capability/coverage ledgers. The offline checker rejects
  22 semantic/topology mutations, canonical local CI registers the all-toolchain leg behind
  `LINKEDSPEC_RUN_LOGICAL_MATRIX=1`; that boundary advanced the ledger to 7/1 before public no-drift `.5.2.9`.
  No runtime implementation changed.
- `2026-07-17` refresh: logical generated/primary rollout `FUTURE-PARITY-BACKLOG.5.2.7` expands the unchanged
  neutral consumers across every available direct/traced generated role. Perl proves emitted `Execute`,
  `ExecuteWithTrace`, and `Get`; Rust proves typed-v1 and compatibility direct/traced pairs; Dart, Julia, and Lua
  prove generated-plan plus standalone-emitted direct/traced roles. Values, eager effects, exact arity failures,
  source attribution, and ordinary trace/result identity agree. Rust intentionally retains direct values for v1
  and parse-output arrays for its legacy compatibility pair. Shared case `success_logical_helpers_eager` passes
  all five primary commands under default and POSIX options, expanding the manifest to 63 cases. The ledger is
  6 complete / 2 pending; recurring gate `.5.2.8` follows without runtime implementation changes.
- `2026-07-17` refresh: Lua logical rollout `FUTURE-PARITY-BACKLOG.5.2.6` makes `runtime_truthy` the exact typed
  seam for eager logical helpers and lazy controls on both ABIs. Built-in one-plus `and`/`or` and exact-one `not`
  arity reject before effects while registered user functions retain precedence; valid values remain eager once-
  left-to-right booleans. Four optional `RuntimeDiagnostic` fields preserve unrelated JSON. The unchanged neutral
  consumer moves from identical 51/238 baselines to 238/238 on PUC Lua and LuaJIT across native/reconstructed/
  generated-plan/loaded-emitted/primary roles. The authoritative gate passes diagnostic 119, full 177, CLI 62x2,
  and corpus 105/105; canonical local CI passes reference CLI 62x2 and Phase 0 `1..1031`/609s. The ledger is 5/3;
  generated/primary `.5.2.7` is next.
- `2026-07-17` refresh: Julia logical rollout `FUTURE-PARITY-BACKLOG.5.2.5` preserves the existing
  `_runtime_truthy` seam shared by eager logical values and lazy controls. Direct call dispatch resolves user
  functions first, then validates one-plus `and`/`or` and exact-one `not` before evaluating any operand; valid
  pure-helper operands retain eager once-only left-to-right collection and boolean composition. Four optional
  `RuntimeDiagnostic` fields expose the neutral code/name/actual/expected schema without changing unrelated JSON.
  The exact 177-assertion consumer covers all 17 typed rows, native/normalized/generated-plan/compiled-emitted/
  primary values and effects, receiver and lazy-control behavior, and four inert invalid calls. Full package,
  process CLI, shared CLI 62x2, and 105/105 corpus proof pass. Canonical local CI also passes reference CLI 62x2,
  Phase 0 `1..1031`/607s, and the optional complete Julia gate. That slice advanced the ledger to 4/4 before Lua.
- `2026-07-17` refresh: Dart logical rollout `FUTURE-PARITY-BACKLOG.5.2.4` makes
  `runtimeLogicalTruth` the one typed truth boundary for eager helpers and lazy controls. `ActionCallExpr` arity
  rejects empty `and`/`or`, empty `not`, multi-argument `not`, and non-positional calls before operand evaluation;
  valid operands are then collected once left-to-right before boolean composition. Optional `RuntimeDiagnostic`
  fields expose the exact neutral code/name/actual/expected schema only when supplied, preserving unrelated JSON.
  The unchanged fixture passes native, normalized reconstruction, generated-plan, compiled standalone-emitted,
  primary CLI, receiver, lazy-control, and inert typed-codeblock roles. The ledger is 3/5; Julia `.5.2.5` is next.
- `2026-07-17` refresh: Rust logical rollout `FUTURE-PARITY-BACKLOG.5.2.3` makes
  `RuntimeValue::as_bool` the one typed truth seam for logical helpers and lazy controls. A shared eager-helper
  guard validates positional one-plus `and`/`or` and exact-one `not` before any operand evaluation; valid operands
  retain eager once-only left-to-right evaluation and real boolean results. Native structured failures now expose
  `code`, `helper_name`, `actual_arity`, and `expected_arity` without changing unrelated diagnostic JSON. Neutral
  values/effects/receivers/controls/invalid calls pass through native, serialized, direct-value, generated-plan,
  and independently compiled standalone-emitted roles. That slice advanced the ledger to 2/6 before Dart.
- `2026-07-17` refresh: ADR `0044` / `FUTURE-PARITY-BACKLOG.9.1.1.1` ratifies the full future cursor and edge
  contract. AND-family rules consume; OR/default-family rules seek; nested rules retain their own policy. Bare
  rule-edge paragraph members normalize to blind calls in AND and action edges in OR/default, while explicit
  cross-family markers remain legal and resolved action/blind ownership remains non-mixable. Public/global
  `parse_mode` is removed with targeted API/CLI diagnostics. Descriptors use derived per-rule `cursor_policy` plus
  `linkedspec-rule-local-cursor-v1`; generated-source v2 derives policy from its ten-family plan without storing a
  second override. Implementation is dependency-split under `.9.1.2-.9`; no cursor behavior has changed and the
  logical rollout continues first.
- `2026-07-17` refresh: director capture `FUTURE-PARITY-BACKLOG.9.1.1.0` fixes rule-local cursor ownership. Parent
  OR/AND mode never propagates to or overrides a child; OR children remain seek and AND children remain consume
  through blind calls, action-edge dispatch, explicit calls, and recursion. This preserves one meaning for a rule
  in every composition context. Exact grammar/API/CLI/descriptor/generated/conformance ratification is now ADR
  `0044`; no runtime behavior has changed.
- `2026-07-16` refresh (historical pre-migration audit): cursor-ownership audit
  `FUTURE-PARITY-BACKLOG.9.1.0` found that Perl baked one selected `parse_mode` into every handler, Dart/Julia/Lua
  owned one seek-default engine mode, and Rust alone compiled AND as
  consume and OR/default as seek before permitting an execution-wide override. The same default `Top::AND` with
  leading junk therefore hits on Perl/Dart/Julia/Lua but returns null on Rust; explicit seek/consume agrees across
  all five, and the shared 62-case matrix omits this default case. AND+seek ordered-landmark extraction and
  OR+consume anchored choice are legitimate low-level algorithms, but no objective justifies a caller rewriting
  every nested rule. The audit recommends intrinsic rule-kind semantics, removal with targeted migration of the
  global API/CLI option, retained matcher primitives, and derived per-rule descriptor metadata. No behavior has
  changed. The child-ownership question recorded here was resolved by `.9.1.1.0`: every child retains its
  intrinsic mode and exact ratification continues in `.9.1.1.1`.
- `2026-07-16` refresh: Perl logical rollout `FUTURE-PARITY-BACKLOG.5.2.2` gives direct, nested, assignment,
  return, condition, function, block-value, and receiver `and`/`or`/`not` calls one typed ActionIR owner and
  `LinkedSpec::RuntimeLogical` seam. Arity rejects before operand lowering; valid operands run once left-to-right;
  results are real booleans; `if`/`switch`/`while` stay branch/body-lazy over the same typed truthiness. Raw Perl
  keyword calls and host `&&`/`||` are gone from admitted logical sites. Perl's shared false/zero scalar requires
  an explicit numeric-host edge before string precedence so numeric zero remains false while string `"0"` remains
  true. Native/live/standalone-emitted reference proof advances the neutral ledger to 1/7; Rust `.5.2.3` is next.
- `2026-07-16` refresh: neutral logical contract `FUTURE-PARITY-BACKLOG.5.2.1` adopts ADR `0043` and
  `linkedspec-logical-helper-v1`. `and`/`or` require one-plus operands and `not` exactly one; arity rejects before
  effects, valid operands run once left-to-right, and results are booleans. One typed seam makes null/false/zero/
  empty-string/empty-aggregate false and nonzero finite numbers/nonempty strings/nonempty aggregates/codeblocks
  true; lazy controls share truthiness without sharing eager evaluation. The independent checker locks 17 truth
  rows, ten helper cases, three effect scenarios, receiver/control contrast, four invalid arities, deterministic
  fixtures, projections, 0/8 rollout, and 15 mutations. Explicit codeblock literals remain `.11`-owned. No backend
  behavior changes; Perl `.5.2.2` is active.
- `2026-07-16` refresh: planning audit `FUTURE-PARITY-BACKLOG.5.2.0` decomposes logical normalization before
  behavior. Toolbox, descriptor, source, native, and generated probes expose two Perl mechanisms: conditions lower
  through lazy host `&&`/`||`/`!`, while direct return/assignment/receiver logical values remain raw/broken and
  `not(false, true)` can lose its first token as a legacy optional scope. Rust/Julia/Lua eagerly evaluate all
  arguments, Dart short-circuits, and pre-repair empty calls differ. At that audit boundary truthiness had three profiles:
  Perl/Lua (`"0"` false, empty aggregates true), Dart/Julia (all nonempty strings true, empty aggregates false),
  and Rust (`"0"` and `"false"` false, empty aggregates false). Generated execution matched native behavior on
  Rust, Dart, Julia, and both Lua ABIs, so neutral contract `.5.2.1` must precede backend `.2-.6`, generated/
  primary `.7`, recurring gate `.8`, and public no-drift `.9`. This audit changes no runtime semantics.
  Focused Perl 4, Rust 137, Dart 60, complete Julia, and dual-ABI Lua 177/177 proof passes; canonical local CI
  passes reference CLI 62x2 and Phase 0 `1..1031`.
- `2026-07-16` refresh: public diagnostic-output no-drift `.5.1.9` closes the eight-leg normalization program.
  The neutral contract now identifies 16 authoritative public documents and nine exact stale-current claims; the
  independent checker verifies every required contract marker and rejects 20 semantic, topology, documentation,
  and premature-admission mutations. Backend READMEs and the mdBook expose copyable native and generated sink
  examples for Perl, Rust, Dart, Julia, and Lua, with typed event/order/failure/exit behavior, quiet primary CLI,
  and rich-event versus ADR `0024` phase-trace separation stated consistently. Complete Rust, Dart, Julia, and
  dual-ABI Lua gates, the strict composed driver, unchanged 5x2x62 matrix, and canonical local CI all pass;
  canonical proof includes reference CLI 62x2, Phase 0 `1..1031`, and the registered driver. Capability remains
  80/0/0, the rollout ledger is 8 complete / 0 pending, parent `.5.1` is closed, and logical truthiness/arity/
  lowering `.5.2` is active. Runtime semantics did not change.
- `2026-07-16` refresh: recurring diagnostic-output gate `.5.1.8` turns the five host implementations into one
  omission-checked executable specification. The neutral contract now declares an exact ordered topology for Perl,
  Rust, Dart, Julia, PUC Lua, and LuaJIT native+generated consumers; the quiet five-command case; generated-source,
  80/0/0 capability, and 105-corpus coverage ledgers; and canonical local-CI registration. One strict driver runs
  that topology with disposable dual-ABI Lua adapters. The offline checker cross-checks the driver, source paths,
  CLI bytes/status, CI switch, and 16 semantic/topology/admission mutations. The direct driver and unchanged full
  5x2x62 matrix pass. Canonical local CI with `LINKEDSPEC_RUN_DIAGNOSTIC_MATRIX=1` also passes reference CLI 62x2,
  Phase 0 `1..1031`, and the registered driver. The rollout ledger is 7 complete / 1 pending and public no-drift
  `.5.1.9` is next.
- `2026-07-16` refresh: generated/primary diagnostic-output `.5.1.7` completes the sixth of eight neutral rollout
  legs. Perl emitted `Execute`/`ExecuteWithTrace`/`Get`, Dart and Julia emitted direct/traced functions, and Lua's
  option-bearing direct/traced functions now carry the invocation-local sink while preserving ordinary generated
  attribution, exact arbitrary caller failure, typed immediate exit, values, metadata, plans, and portable trace.
  Rust adds paired typed-v1 and compatibility direct/traced functions so every legacy signature stays intact;
  `GeneratedDiagnosticOutputExecutionError` distinguishes generated, compatibility, sink, and exit outcomes.
  All primary adapters deliberately omit the rich sink. Shared case 62 executes all three helpers but admits only
  canonical JSON plus newline, empty stderr, and status 0 across five commands and default/POSIX environments;
  ADR `0024` trace cases remain phase-only. Capability stays 80/0/0, the rollout ledger is 6 complete / 2 pending,
  and symmetric recurring gate `.5.1.8` is next. Complete backend gates, the 5x2x62 shared matrix, the generated-
  source checker, and canonical CLI 62x2 plus Phase 0 `1..1031`/623s all pass.
- `2026-07-16` refresh: Lua capability admission `.8.4` makes Lua the fifth exact backend in the executable
  16-capability census. Every Lua row is `pass` with direct implementation and recurring proof references, so the
  census is 80 pass / 0 partial / 0 gap; generated-source state is independently `pass`. Satisfied Lua-backend and
  variadic-function exclusions are removed, while the mixed generic callable-codeblock exclusion is narrowed to
  explicit callable values, arbitrary dynamic calls, and remaining Rust/Dart/Julia parity. PUC Lua 5.4 remains the
  conformance runtime and LuaJIT the behavior-identical compatibility leg. Focused proof is 177/177 on both ABIs,
  primary 61x2, corpus 105/105, and the shared matrix 5x2x61. Canonical local CI passes reference CLI 61x2 and
  Phase 0 `1..1031` in 625 seconds. The Lua parity tree is closed; post-parity work is eligible only after this
  slice commits cleanly.
- `2026-07-16` refresh: Lua generated accepted-subset `.8.3` adds `lua/test/run.lua` to the executable contract and
  makes its checker own exact count/order, full-manifest validation, interpreter-before-emission proof, independent
  load, metadata/plans/trace identity, cleanup, and unconditional registration. The test consumes the eight neutral
  names directly, validates all 105 fixtures first, proves every interpreter value, persists eight generated
  modules, and launches the exact selected PUC Lua or LuaJIT runtime with explicit package/native paths. The fresh
  host validates every plan, checks exact ordered values and metadata, executes fixed user functions, and observes
  portable first-case trace identity; stdout/stderr and root absence are exact. Both ABIs pass 177/177, primary
  stays 61x2, corpus stays 105/105, capability stays 64/0/0, and canonical Phase 0 passes `1..1031` in 620 seconds.
  Sole census admission and backend handoff `.8.4` are active.
- `2026-07-16` refresh: Lua generated family execution `.8.2` adds typed ordered plan rows and exact classification
  over the neutral ten-family vocabulary. Validation rejects row-count, label, known-family, and unknown-family
  drift before execution with portable attribution. The validated per-label map is threaded through every root and
  nested rule and authoritatively chooses regex versus blind dispatch; native execution without a plan retains its
  compiled-structure choice. Low-level trace adds `generated_rule_enter`, `generated_family_decision`, and
  `generated_rule_exit` with source identity/rule/family. One 26-row matrix proves all ten root families, nested
  dispatch, four failures, interpreter-equal values, and fresh-host load/run/cleanup on both ABIs; emitted source
  also reconstructs and executes the neutral variadic fixture through typed rest arrays. Initial classification
  exposed Lua's broader native default-repetition flag; exact neutral mode enumeration fixed the plan without
  changing runtime behavior. PUC Lua and LuaJIT pass 176/176, primary stays 61x2, corpus stays 105/105, capability
  stays 64/0/0, and canonical Phase 0 passes `1..1031` in 626 seconds. Accepted-subset `.8.3` is active; census
  admission remains `.8.4`.
- `2026-07-16` refresh: Lua generated-source isolation `.8.1.2` closes scaffold parent `.8.1`. The focused gate
  passes the exact current runtime command into each ABI test; one unique caller-owned temporary root contains a
  valid generated module, corrupt-payload module, runner, and captured channels. Fresh PUC Lua/LuaJIT processes
  receive explicit `LUA_PATH` and ABI-specific `LUA_CPATH` and prove exact Unicode metadata, direct/traced result
  identity, native trace presence, missing-rule attribution, and corrupt compile/load identity. Cleanup verifies
  root absence after normal completion and injected failure; no generated root remains. Both ABIs pass 173/173,
  primary stays 61x2, corpus stays 105/105, and capability stays 64/0/0. Exact ten-family plan/execution `.8.2` is
  active; subset/census remain `.8.3-.8.4`. Canonical Phase 0 passes `1..1031` in 607 seconds.
- `2026-07-16` refresh: Lua emitter core `.8.1.1` implements the deterministic half of the split created by
  `.8.1.0`. `lua/src/linkedspec/source_emitter.lua` reconstructs one effective typed `SpecFile` from immutable,
  source-ordered fixed-v1/variadic-v2/final-codeblock-v3 function definitions and last-definition rule order,
  canonicalizes it with strict-UTF-8 sorted-key JSON, and embeds payload plus Unicode identity as lowercase ASCII
  hex in a native Lua module. Public compatibility/source-identified emitters expose exact contract/version/
  identity metadata, typed portable emit/compile-load/execution errors, and direct/traced value roles over the
  ordinary runtime. Repeated equivalent input is byte-identical and focused PUC Lua/LuaJIT gates pass 172/172.
  Fresh-process valid/corrupt load/run/cleanup proof is now active under `.8.1.2`; exact plan/family/portable
  generated trace remains `.8.2`, subset admission `.8.3`, and sole census promotion `.8.4`. Public status and
  capability 64/0/0 remain unchanged.
- `2026-07-15` refresh: Lua primary no-drift `.7.3` confirms the native module, exact primary process contract,
  separate corpus adapter, checkout-local executable/native-module setup, public limitations, and recurring gates
  agree at `runtime-corpus-primary-cli`. It corrects stale mdBook foundation prose and a command setup that cleaned
  native adapters before later examples used them. Parent `.7` closes without runtime change; generated-source
  scaffold `.8.1` activates while census 64/0/0 remains unchanged.
- `2026-07-15` refresh: Lua primary admission `.7.2` replaces the focused command smoke with both unchanged
  61-case option environments and adds PUC Lua to the shared warmed matrix. The matrix builds its native adapters
  under caller-owned temporary storage, removes them on exit, and passes 5 backends x 2 environments x 61 exact
  cases. PUC Lua and LuaJIT remain 169/169, complete corpus execution remains 105/105, public status advances to
  `runtime-corpus-primary-cli`; final CLI/native/corpus no-drift `.7.3` has since closed parent `.7`. Generated
  source and the four-backend capability census 64/0/0 remain unchanged.
- `2026-07-15` refresh: Lua primary adapter `.7.1` replaces the exit-2 scaffold with a thin native-library command.
  `primary_cli.lua` owns only exact ADR `0023` options, strict UTF-8 process/file IO, phase ordering and headings,
  canonical JSON framing, and ADR `0024`'s deterministic independent phase trace. Named/file/inline semantics reuse
  existing loaders, staged compiler, identified engines, and runtime; a narrow native cwd query makes relative
  paths deterministic without a subprocess. Both ABIs pass 169/169 and the unchanged process manifest passes
  61/61 in default and POSIX diagnostic runs. `.7.2` has since made both legs recurring and admitted Lua to the
  shared matrix.
- `2026-07-15` refresh: Lua full-corpus `.6.3` closes interpreter-corpus parent `.6`. One selection-free
  `execute_corpus_fixtures(...)` regression validates and executes all 105 fixtures in manifest order with exact
  wrapped outputs, 105 passes, and zero failures. The separate developer corpus runner keeps validation-only
  default behavior and now projects the same native API behind bare `--execute`, ordered PASS/FAIL reporting, and
  exits 0/1/2 for success, fixture failure, and argument/manifest failure. PUC Lua and LuaJIT pass 167/167 and
  public status is `runtime-corpus-full`. The primary parser CLI was still an exit-2 scaffold at that boundary;
  `.7.1` has since implemented it. Generated source, coverage 246/105+1/122, and capability 64/0/0 remain unchanged.
- `2026-07-15` refresh: Lua advanced/shipped parent `.6.2` is closed. Planning `.6.2.0` measured exact offsets
  40-98 at the same 50/59 on PUC Lua and LuaJIT; four toolbox-proven repairs raised the unchanged window through
  56/59, 57/59, 58/59, and 59/59, and independent `.6.2.5` successor measurement found no residual. Permanent
  `.6.2.6` validates all 105 manifest entries, selects exact offsets 40-98, and locks all 59 literal names,
  one-level wrapped expected outputs, matches, byte/character endpoints, 59 passes, and zero failures. Both ABIs
  pass 166/166 at that boundary; complete-manifest `.6.3` has since closed. Production source, corpus/oracle data,
  generated-source state, coverage 246/105+1/122, and capability 64/0/0 remain unchanged.
- `2026-07-15` refresh: Lua governed corpus admission `.6.1.4` permanently executes exact manifest offsets 99-104.
  The cursor-control, pure-helper, position-helper, control-marker, anonymous-capture, and named-capture fixtures
  pass 6/6 in exact order with unchanged wrapped outputs and byte/character endpoints `2,1,2,1,5,5`. PUC Lua and
  LuaJIT pass 162/162. Public corpus exports, status `native-full-pipeline-trace-v1`, primary scaffold,
  validation-only developer corpus CLI, coverage 246/105+1/122, and capability 64/0/0 remain unchanged. No
  production source or corpus data changes. Parent `.6.1` closes at 46/46 across both permanent windows and `.6.2`
  activates for offsets 40-98. Canonical local CI exits 0 with CLI 61x2 and Phase 0 `1..1031` passing in 651
  seconds (1,328.76 seconds total under concurrent load).
- `2026-07-15` refresh: Lua core corpus admission `.6.1.3` turns the measured prefix into one permanent
  manifest-backed executor test. Exact offsets 0-39 stay ordered from `proof_edge_array_literal` through
  `terse_2_2_5_2_attached_switch_blocks`; all 40 match, equal one wrapping of unchanged expected JSON, retain byte
  and character endpoint 1, and carry no failure. PUC Lua and LuaJIT pass 161/161. This is a test/documentation
  admission only; production source, corpus data, status, capability census, CLI, and offsets 40-104 do not change.
  Canonical local CI exits 0 with CLI 61x2 and Phase 0 `1..1031` passing in 640 seconds (1,316.33 seconds total
  under concurrent load). Governed capability/no-drift `.6.1.4` follows and is now complete.
- `2026-07-15` refresh: Lua corpus execution `.6.1.2` is a library-owned composition boundary, not a CLI
  behavior. It validates the full manifest/inventory/UTF-8/typed JSON before named or offset/limit selection, then
  runs automatic function-aware parse, explicit validation/compile, exact source-identified engine construction,
  native runtime, and one-level wrapped structural JSON comparison. Typed result records copy actual value/output,
  retain match plus byte/character endpoints, per-fixture trace, runtime diagnostic, failure stage/text, and turn
  every fixture failure into data so later selected cases run. Controlled proof passes 160/160 on PUC Lua and
  LuaJIT; the developer CLI remains validation-only and ordered core admission `.6.1.3` follows. Canonical
  local CI passes CLI 61x2 plus Phase 0 `1..1031` in 623 seconds.
- `2026-07-15` refresh: Lua nested-path repair `.6.1.1` carries parser key/index identity through runtime reads and
  writes. Keys require harrays; normalized finite nonnegative indices require arrays. Nested assignment evaluates
  all segment expressions and then RHS before validation, mutates a copied root, and stores only after complete
  success, preserving null/no-autovivification/no-partial-mutation behavior. Exact offset 20 now passes unchanged;
  owned offsets 0-39 and 99-104 pass 46/46 on PUC Lua and LuaJIT, and focused suites pass 157/157. No fixture,
  expected value, parser grammar, public status, capability row, or corpus boundary changed. Reusable library
  corpus execution/result records `.6.1.2` follow. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031`
  in 619 seconds.
- `2026-07-15` refresh: Lua controlled-corpus planning `.6.1.0` defines exact owned windows at manifest offsets
  0-39 and 99-104 and measures them through the current automatic parse/validate/compile/engine/runtime pipeline.
  PUC Lua and LuaJIT both pass 45/46: all six governed capability fixtures and 39/40 core fixtures are exact. Sole
  residual offset 20 is an output mismatch caused by nested assignment erasing parsed key/index segment kinds;
  generic harray writing stringifies numeric segment `0` instead of rejecting the wrong-container transition.
  Repair `.6.1.1`, library execution `.6.1.2`, core admission `.6.1.3`, and capability/no-drift `.6.1.4` are now
  dependency-ordered. No implementation, fixture, public status, test count, endpoint, or census row changed.
- `2026-07-15` refresh: Lua no-drift `.5.3.3` confirms exact agreement across trace-aware public exports/options,
  `native-full-pipeline-trace-v1`, fixed-v1/variadic-v2/final-codeblock-v3 descriptor ownership, the two neutral
  trace capability definitions, dual-ABI descriptor/full-pipeline tests, public docs/book, task/roadmap/live state,
  and Knowledge Map. No hidden emitter construction or compiled/engine retention exists. PUC Lua and LuaJIT pass
  155/155; callable/loading/coverage/public checks remain green; capability intentionally stays four-backend
  64/0/0 until `.8.4`. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 611 seconds. No source/status/
  behavior/test/manifest change. Parents `.5.3`/`.5` close and corpus `.6.1` is active.
- `2026-07-15` refresh: Lua full-pipeline trace `.5.3.2` threads one caller-owned emitter through typed load
  options, deterministic resolution/content loading, function-parser cache/build/execute, shell projection,
  rule parsing, validation, function registry/rule compilation, staged resolve/load/compile/execute/stitch,
  loaded/runtime engine creation, and existing runtime rule events. The internal scope runner balances high-level
  success/failure events while rethrowing the original typed error; medium decisions expose construction choices.
  Compiled and engine state retain no emitter, and no hidden factory is called. Routed sinks, disabled/low/medium
  filtering, exact phase order, error attribution, and descriptor/runtime identity pass 155/155 on PUC Lua and
  LuaJIT with status `native-full-pipeline-trace-v1`. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031`
  in 608 seconds. Capability remains four-backend 64/0/0; `.5.3.3` is active.
- `2026-07-15` refresh: Lua descriptor implementation `.5.3.1` makes
  `capability_conformance/outward_descriptor_contract.json:function_record_variants` the executable source of
  truth for fixed-v1, variadic-v2, and final-codeblock-v3 outward records. The neutral checker locks exact ordered
  fields, versions, parameter storage, compatibility aliases, and the sole-final-parameter `codeblock` policy.
  Lua projects each variant directly from typed registry state, preserves identical staged metadata, and retains
  exact function order/count on PUC Lua and LuaJIT at 153/153. Perl's existing final-codeblock projection now uses
  outward version 3 without changing its internal definition/runtime model. Generic callable-codeblock capability
  and the four-backend 64/0/0 census do not change; one-emitter native-pipeline trace `.5.3.2` is active.
- `2026-07-15` refresh: Lua decision `.5.3.0.1` resolves the two neutral-policy dependencies from planning
  `.5.3.0`. ADR `0041` makes final-codeblock functions outward descriptor version 3, preserving exact fixed
  `params`/`arity` plus a sole final `parameter_kinds[name] = "codeblock"` entry without weakening fixed-v1 or
  variadic-v2. The executable schema/checker must land before Lua emission in `.5.3.1`; generic callable-codeblock
  capability and unrelated backend runtime work remain outside that leaf. Lua stays outside the four-backend
  all-pass census through `.5.3-.7`, and `.8.4` is the sole all-pass expansion owner. Runtime already accepts one
  caller emitter; loading, frontend, validation, compile, function-shell, and staged APIs do not. Descriptor
  `.5.3.1` is active, followed by one-emitter trace `.5.3.2` and census-preserving no-drift `.5.3.3`. No source,
  behavior, status, descriptor, capability, or test expectation changed in the decision slice.
- `2026-07-15` refresh: Lua now executes final-only `callback: codeblock` intent after preserving it end-to-end.
  Spec-produced fixed/codeblock fields canonicalize once to ordered fixed-v1 params/arity plus an exact one-entry
  `parameter_kinds` harray, and identical metadata survives body payload, staged job, typed AST, registry,
  stitching, and compiled state. All four invalid declarations and sidecar drift reject. Callable metadata
  normalizes attached and parenthesized blocks to one zero-positional `codeblock_argument`; parsed source remains
  unchanged, harrays are not promoted, and built-in contracts do not drift. The deferred argument crosses the
  isolated function-frame boundary, executes with current dynamic bindings, keeps nonparameter effects visible to
  later function statements, restores the outer caller, and returns chainable values. Registered functions and
  governed helpers retain static precedence; missing/harray/arity/recursion failures stay typed. Both ABIs pass
  146/146 before portable resolution/loading `.5.2.1` adds typed named/exact-path requests, caller-owned options,
  typed resolved/loaded/error values, deterministic first-regular-file selection, in-process byte reads, and strict
  UTF-8 preservation. Automatic spec-owned function parsing `.5.2.2` resolves the bundled grammar by one exact
  module-relative owner, validates/compiles it once, executes it in process, and composes only typed output through
  the existing Unicode projector/body dispatcher without a raw scanner. Loaded-source composition `.5.2.3` adds
  one typed nested identity/source/compiled result, exact parse/validation/compile error translation, and engine
  creation that copies options while attaching logical names only to name requests and resolved paths to both
  request kinds. Loaded top-level functions and runtime diagnostic identity pass 153/153 on PUC Lua and LuaJIT;
  status is `native-spec-pipeline-v1` and capability remains 64/0/0. No-drift `.5.2.4` closes parent `.5.2`
  without behavior change; descriptors/full-pipeline trace `.5.3` is active, while generated source `.8` and
  explicit/general dynamic codeblocks `.11.7` retain separate owners.
- `2026-07-15` documentation architecture: ADR `0040` keeps `docs/linkedspec-book/` as the sole normative,
  backend-neutral owner of `.spec` semantics and portable behavior, and adopts one optional implementation
  companion each for Perl, Rust, Dart, Julia, and Lua. Companions will explain host APIs, embedding, toolchains,
  ABIs, implementation architecture, trace/debug, generated artifacts, performance/deployment, and exact variant
  boundaries by linking to—not copying—the neutral contract. `BACKEND-COMPANION-BOOKS.1+` is dependency-gated
  until full current-backend parity; a read-only ownership inventory and mechanical build/link/drift governance
  precede any scaffold population or content migration.
- `2026-07-15` refresh: Lua variadic-v2 calls now execute through the same staged ActionIR function runtime as
  fixed calls. Caller arguments still evaluate exactly once left-to-right; the invocation frame copies every value,
  binds the fixed prefix normally, and copies extras again into one fresh typed array for the final rest name.
  Empty rest arrays are fresh, nested arrays/harrays and null/boolean/codeblock identities survive, caller values
  remain isolated, and returned arrays feed receiver chains. The unchanged neutral callable fixture passes exactly;
  minimum arity and keywords retain portable typed diagnostics. Both ABIs pass 139/139, status is
  `runtime-user-functions-variadic-v2`, capability remains 64/0/0, and that milestone handed off to contextual
  final-codeblock metadata `.5.1.4.1`. Outward descriptor admission later completed in `.5.3.1`; generated source
  remains `.8`.
- `2026-07-15` refresh: Lua now preserves the exact callable-signature storage union. Fixed version 1 retains only
  top-level `params`/`arity`; variadic version 2 retains only its six-field typed signature in serialized shell,
  AST, staged jobs, registry entries, and compiled state while internal positional mirrors remain identity-checked.
  Registry lookup accepts `arity >= min_arity`, reports `at least N`, and keeps the maximum unbounded. All seven
  invalid-definition classes, mixed-version storage, and sidecar signature drift fail through typed owners.
  At that milestone runtime variadic execution and outward descriptors deliberately failed closed for
  `.5.1.3.2` and `.5.3`; both are now complete through `.5.3.1`. Both
  ABIs pass 136/136, status is `runtime-user-functions-variadic-v2-state`, capability remains 64/0/0, and
  fresh-rest-array execution `.5.1.3.2` is active.
- `2026-07-15` refresh: Lua fixed-v1 functions now execute through the one ActionIR runtime. Raw registered names
  resolve before helper canonicalization; caller arguments evaluate once left-to-right; copied values bind into
  fresh scalar/array/harray stores; staged `body_ast` JSON is integrity-checked against reconstructed typed source;
  and protected execution restores caller stores/active paths. Final/local-return values compose through nested
  nonrecursive calls, standalone drop, and receiver chains. Typed arity, keyword, recursion-cycle, and body-staging
  failures remain function-owned. Both ABIs pass 133/133, status is `runtime-user-functions-fixed-v1`, capability
  remains 64/0/0, and variadic-v2 state `.5.1.3.1` is active.
- `2026-07-15` refresh: Lua now owns the minimal staged function-body registry in
  `linkedspec.staged_parser_registry`. Exact `StagedParseJob` values are defensively normalized and stable-sorted by
  parent path, source span, job id, then input order. The only provider resolves `actionir-body.spec` to
  `builtin:actionir-body.spec`, records the governed adapter digest and neutral cache/compiled identity, parses
  exact body text through the native ActionIR parser, and immutably stitches neutral `body_ast` JSON. Function
  sidecars, unsupported identities, invalid spans, duplicate jobs, and stitching policies are fenced. The composed
  shell+dispatch API passes 130/130 on PUC Lua and LuaJIT; status is `runtime-staged-registry`, capability remains
  64/0/0, and fixed-v1 registered-call execution `.5.1.2` is active.
- `2026-07-15` refresh: Lua staged-function `.5.1` is split before implementation. Existing code owns exact-v1
  function projection, staged sidecars, registry-first contract resolution, isolated pre-execution frames, compiled
  records, generic trailing-block AST, and built-in contextual block execution—but not body-job dispatch or
  registered-call runtime. `.5.1.1` now owns the minimal deterministic action-body provider/stitch path; `.2` fixed
  execution; `.3.1/.2` variadic typed state/runtime; `.4.1/.2` final-codeblock metadata/contextual runtime; `.5`
  no-drift. Descriptors/full trace stay `.5.3`, generated source `.8`, explicit callable literals/bound calls `.11.7`.
- `2026-07-15` refresh: Lua diagnostics/trace no-drift is closed at the precise native runtime boundary. The public
  API exports all ordered levels, immutable controls, environment mapping, structured events/scopes, log/dump
  primitives, stdout/route/mirror sinks, reset/append behavior, and direct/config-wrapper runtime entrypoints.
  Source/test inventory agrees on parse/rule, regex, dispatch, recursion, lifecycle, cursor, boundary, and governed
  mark/capture topics; traced/untraced identity remains locked on both Lua ABIs. Parent `.4.4` is done, status
  remains `runtime-trace-events`, and `.5.1` is active. Full native-pipeline propagation remains `.5.3`.
- `2026-07-15` refresh: Lua now instruments its one compiled-rule interpreter behind the optional trace emitter.
  High-level events cover balanced parse/rule scopes and lifecycle blocks; debug events cover recursion cutoffs,
  regex match/no-match, action/blind child dispatch, cursor and stack transitions, successful/unusable source
  boundaries, governed helper mark/capture positions, and post-mutation rule-slot capture/named marks. Absent or
  disabled emitters remain no-ops, and traced/untraced result JSON is exact across success, no-match, dispatch,
  and recursion paths. PUC Lua and LuaJIT pass 129/129, status is `runtime-trace-events`, capability remains
  64/0/0, and `.4.4.4` owns scoped runtime no-drift. Full loading/frontend/compiler/function/staged propagation
  remains dependency-gated `.5.3`.
- `2026-07-15` refresh: Lua now owns a zero-dependency native trace boundary in `linkedspec.trace`. Ordered typed
  levels/config/sink/event/scope/emitter records, exact aliases and numeric thresholds, immutable config updates,
  documented environment controls, structured event JSON, and deterministic indentation/emoji rendering feed
  caller-owned stdout, resettable/appending routed files, or mirror sinks. Direct emitter injection and config
  wrappers emit a balanced `lua_runtime:parse` scope without mutating caller options or parse results; absent or
  disabled trace records/writes nothing. PUC Lua and LuaJIT pass 128/128 at that controls boundary, whose
  historical status is `runtime-trace-controls`; `.4.4.3` later adds the runtime events recorded above.
- `2026-07-15` refresh: Lua runtime errors now carry typed neutral `RuntimeDiagnostic` payloads. Optional engine
  `spec_name` / `spec_path` flows only into failures; `top_rule_selection`, `runtime_input`, `rule_lookup`, and
  `runtime_execution` distinguish the mechanism. Each rule adds a fallback before local-state unwind, while outer
  wrappers preserve existing child/lookup payloads, so top and deepest-rule/`lua_runtime:rule:<label>` identity
  coexist without another failure stack. Deterministic diagnostic/error JSON omits unavailable fields; existing
  text and successful results stay unchanged. That `.4.4.1` boundary passes 126/126 with historical status
  `runtime-structured-diagnostics`; `.4.4.2` trace controls later supersedes the mechanism status as recorded above.
- `2026-07-15` refresh: Lua diagnostics/trace is split by mechanism and dependency. `.4.4.1-.4` now own neutral
  structured runtime failures, ordered controls/events/sinks, interpreter instrumentation, and scoped no-drift.
  Full loading/frontend/validation/compiler/function-shell/staged/runtime propagation remains `.5.3`, explicitly
  after staged-function `.5.1` and native-loading `.5.2` create those owners. The ordering follows completed Dart
  and Julia evidence. Current Lua already provides the typed runtime exception seam, parse-scoped rule stack,
  compiled source records, cursor/capture/mark state, and per-parse caller option boundary needed by `.4.4`; no
  behavior or capability changed in planning `.4.4.0`; structured diagnostic `.4.4.1` was the next leaf there.
- `2026-07-15` refresh: Lua's native helper/value/control boundary is now exhaustively closed. A defensive sorted
  inventory view drives all 246 admitted names through parse, compile, and runtime on both ABIs: 233 reach
  function-form owners and exactly thirteen governed structural/receiver-only forms remain non-functions. Focused
  direct `call(rule)` proof locks child value, refreshed `retv`, and cursor. Public status is
  `runtime-helper-value-control`; PUC Lua and LuaJIT pass 125/125, coverage remains 246/105+1/122, and capability
  remains 64/0/0. Source-history rechecking corrects the earlier duplicate-`or` audit note—every inspected revision
  contains one row. Parents `.4.3.9`/`.4.3` close and diagnostics/trace `.4.4` activates; generated source, general
  functions, corpus execution, and primary CLI retain later owners.
- `2026-07-15` refresh: Lua now executes eager boolean `and`/`or`/`not` through the existing runtime truthiness
  seam. Every authored argument is materialized once left-to-right before composition; empty calls are false/
  false/true, scalar `"0"` remains false, and empty aggregates remain true. That logical slice passes 123/123 and
  the complete helper boundary now passes 125/125 as recorded above. Global truthiness, arity,
  Dart evaluation/empty-`and`, and Perl keyword-lowering differences remain dependency-gated `.5.2`.
- `2026-07-15` refresh: the Lua helper closeout now has an executable negative-space measurement. Generating a
  minimal action for every exact admitted name yields 230 runtime-owned and 16 unsupported names. Thirteen are
  intentionally structural or named-receiver-only; `and`/`or`/`not` are the exact missing value helpers. That
  audit activated repair `.4.3.9.1`, now complete as recorded above; `.2` later closes the recurring admission.
  The audit also exposed stale `runtime-numeric-reducers` status, reported a duplicate source `or` row, found
  absent focused direct `call(rule)` proof, and exposed a
  separate Perl `and`/`or` keyword-precedence lowering defect. The cross-backend logical contract is durably owned
  by dependency-gated `FUTURE-PARITY-BACKLOG.5.2`; the closeout later disproves the duplicate-row report from exact
  source history.
- `2026-07-15` refresh: Lua diagnostic output is a synchronous caller-owned event boundary, not parser data.
  `runtime_parse(..., { diagnostic_sink = callback })` emits typed helper/rule/message records for eager
  `print`/`say`/`print_each`; missing sinks stay quiet without skipping side effects, Unicode bytes and message
  order are preserved, and `RuntimeParseResult` remains structural. `exit_now` remains an immediate typed failure.
  PUC Lua and LuaJIT pass 122/122 and `.4.3.9` is active. The source audit found Perl/Rust/Dart/Julia transport and
  optional-suffix drift, durably routed to `FUTURE-PARITY-BACKLOG.5.1` before structured-format execution. ADR
  `0042` and `linkedspec-diagnostic-output-v1` now define the exact backend-neutral arity, eager evaluation,
  rendering, typed event, quiet sink, failure, exit, generated, and phase-trace-separated target. Perl native
  `.5.1.2`, Rust native `.5.1.3`, Dart native `.5.1.4`, and Julia native `.5.1.5` now consume that exact target
  through separate per-invocation event seams; that historical rollout ledger was 4 complete / 4 pending before
  Lua formal native admission `.5.1.6`, which has since closed.
- `2026-07-15` refresh: Lua native capture/cursor parity is closed. A source-derived inventory finds 62 unique
  current capture/mark/input/cursor/control calls and exact 62/62 agreement across ActionIR contract family,
  admitted names, interpreter dispatch, and focused execution sources. Four placement-marker spellings remain
  separately timing-tested through typed post-action/pre-`LE` events. PUC Lua and LuaJIT pass 121/121; complete-
  mark, 246/105+1/122 coverage, selector 57/27/0, punctuation-light, and capability 64/0/0 gates pass. Parent
  `.4.3.7` closes without generated-source claims; `.8.1-.8.4` retain those obligations. That closure activated
  diagnostic output `.4.3.8`, which is now complete as described above.
- `2026-07-15` refresh: ADR `0036` adopts a post-current-parity direction for write-only missing-container
  creation and explicit receiver-mutating `map_leaves!`. The next evaluated segment selects a missing array versus
  harray; reads remain pure, existing wrong kinds are never coerced, arrays remain dense, and copy-on-write root
  commit is atomic. `map_leaves!` v1 accepts only a bare named binding, traverses the original snapshot with current
  root-kind rules, uses copied callback results as replacements, retains complete stable receiver-root-relative
  paths, and does not make `value` a writable alias. No other bang methods/identifiers are adopted. Current source
  and focused Perl/Rust/Dart/Julia/Lua proof confirm intermediate non-vivification and bang-invalid grammar;
  `.19.1-.19.7` are dependency-gated behind complete current parity; Lua `.4.3.7.6` was the then-active frontier.
- `2026-07-15` refresh: ADR `0035` makes terse, readable, and highly expressive authoring a hard constraint on
  future universal `.spec` evolution. Terseness removes redundant ceremony rather than semantic signal;
  readability keeps structure, value flow, mutation, scope, recovery, and typed diagnostics locally predictable;
  expressiveness comes from small typed orthogonal mechanisms rather than format-specific or host escapes.
  Uniform binding is the positive precedent: one four-kind value binding, runtime-kind dispatch, and typed
  wrong-kind failure. Recursive tree traversal keeps `walk_leaves`/`map_leaves`/`reduce_leaves`; shorter aliases
  would obscure recursive semantics. This planning slice changes no syntax or behavior; Lua `.4.3.7.6` was the
  executable frontier at that commit.
- `2026-07-15` refresh: Lua now represents placement-sensitive split/named-mark rule members as typed compiled
  events attached to the preceding regex slot. Compiled and outward state preserve those events; runtime applies
  them after slot action/child dispatch and before `LE` through the existing anonymous capture boundary and
  parse-scoped rule-label/name/UTF-8-byte-offset store. Same-slot actions see old state, later slots see the
  update, and no parallel marker state exists. Native and reconstructed `é(α🙂,βγ)` execution, all three anonymous
  spellings, two named marks, Unicode positions, the exact shipped EBNF `@move_pos`, and malformed-marker typed
  boundaries pass 121/121 on PUC Lua and LuaJIT. Canonical CI passes capability 64/0/0, coverage 246/105+1/122,
  selector admission 57/27/0, CLI 61x2, and Phase 0 `1..1031` in 633 seconds. Exhaustive capture/cursor no-drift
  `.4.3.7.6` was activated by that slice.
- `2026-07-15` refresh: ADR `0034` adopts a 91-row Unicode structured-text catalog as a requirements generator for
  post-parity `.spec` evolution. `STRUCTURED-TEXT-FORMAT-PROGRAM` hard-gates execution on complete current
  Perl/Rust/Dart/Julia/Lua parity, then establishes decoded-input/provenance, source-aware AST/trivia/diagnostics,
  conformance/differential/Unicode fuzzing, composition, and benchmark contracts before seven seed formats. Every
  format-discovered mechanism must land neutrally across all current backends before that format continues. Each
  composed format `.spec` graph is the sole parser source and is dynamically compiled for immediate use; generated
  host source/caches are reproducible derivatives only. Backend dialects and hidden host parsers are forbidden. Derived serializations reuse syntax foundations, HTML
  owns a full WHATWG tokenizer/tree-builder path, parsing stays distinct from evaluation/domain semantics, and
  non-UTF-8 input needs a future explicit decoder seam rather than weakening strict-UTF-8 current APIs. No format
  implementation starts before parity; performance will separate cold construction, warm reuse, and parsing.
- `2026-07-15` refresh: Lua now executes all governed rule-local named writers, stable/advancing spans, two-mark
  spans, and anonymous/named bridges over the single parse-scoped rule-label/name/UTF-8-byte-offset store. One
  guarded span seam enforces null/no-mutation behavior for missing, invalid, or reversed endpoints; public
  positions and lengths project to Unicode characters. Dispatch distinguishes anonymous `capture_take()` from
  named `capture_take(name)` without changing the shared 246-name inventory. The unchanged governed fixture
  passes native and reconstructed execution, the complete Lua gate passes 120/120 on PUC Lua and LuaJIT, and
  canonical CI preserves capability 64/0/0 and coverage 246/105+1/122, passes CLI 61x2 and Phase 0 `1..1031` in
  637 seconds, and clears every doctrine/documentation gate. Only placement-sensitive split/mark event execution
  was then active in `.4.3.7.4` before capture/cursor no-drift closure.
- `2026-07-15` refresh: Complete named-mark admission closes at one aligned 246-name Dart/Julia/Lua inventory.
  The coverage gate no longer relies on corpus discovery for reverse completeness: it derives 131 identifier-
  shaped Perl contracts, subtracts an exact classified set of nine compatibility/legacy/internal contracts, and
  requires all 122 public contracts in every backend inventory. The 105 corpus fixtures remain the broad behavior
  source and the exact named-mark fixture supplies the seven newly admitted calls. A simultaneous three-inventory
  `clear_mark` deletion is caught by both the exact-family and independent-public checks. Exact backend family
  views remain useful without being staging sets. Parent `.17` closes; Lua `.4.3.7.3` now extends the same admitted
  mark store instead of defining another backend-local surface. Canonical CI passes capability 64/0/0, coverage
  246/105+1/122, CLI 61x2, and Phase 0 `1..1031` in 633 seconds.
- `2026-07-14` refresh: Lua consumes the unchanged complete seven-helper named-mark contract through a parse-
  scoped `rule label -> mark name -> UTF-8 byte offset` store. Entry/local writers use the existing match
  registers; line, column, and position reads project to Unicode characters only at the public boundary; clear
  removes only the current rule bucket's name; and bare names stay symbolic. Native and serialized `SpecFile`
  reconstruction return the exact neutral parent/child result on PUC Lua and LuaJIT at 119/119. The seven names
  participate in known-call and capture/mark contract resolution while remaining separate from the legacy shared
  239-name inventory; `.17.5` owns the one final admission and independent omission guard, while Lua `.4.3.7.3`
  consumes this storage/dispatch foundation for the remaining governed named-span family. Canonical CI preserves
  capability 64/0/0 and shared coverage 239/105, passes CLI 61x2 and Phase 0 `1..1031` in 627 seconds, and clears
  every doctrine/documentation gate.
- `2026-07-14` refresh: Julia consumes the complete seven-helper named-mark contract over its existing rule-local
  code-unit store. Entry/local writers use established match registers; line/column values reuse the Unicode
  projection seam; clear is rule-local; and absent position/location reads remain undef. Native, generated-plan,
  emitted-state reconstruction, and primary-CLI execution agree with the exact Perl/Rust/Dart fixture. The seven
  names are staged in `COMPLETE_NAMED_MARK_ACTION_IR_CALL_NAMES`, folded into Julia's known-call boundary but kept
  outside the legacy shared 239-name set until `.17.5` admits them once. Canonical CI preserves
  capability 64/0/0 and shared coverage 239/105, passes CLI 61x2 and Phase 0 `1..1031`, closes `.17.3`, and
  activates Lua `.17.4`.
- `2026-07-13` refresh: Dart consumes the complete seven-helper named-mark contract over its existing rule-local
  code-unit store. Entry/local writers use the established match registers; line/column values reuse the Unicode
  projection seam; clear is rule-local; and absent `mark_pos` now remains undef instead of becoming position zero.
  Native, generated-plan, emitted-state reconstruction, and primary-CLI execution agree with the Perl/Rust exact
  fixture. The seven names are staged in `completeNamedMarkActionIrCallNames`, folded into Dart's known-call
  boundary but kept outside the legacy shared 239-name set until `.17.5` admits them once.
- `2026-07-13` refresh: Complete named marks now have one exact seven-helper neutral contract. Its multibyte
  parent/child fixture distinguishes entry/local edges, character positions, 1-based line/column values, missing
  undef, clear/existence, symbolic bare names, and rule-label isolation. Perl consumes it live and from standalone
  generated source; the generated preamble now delegates optional mark tracing through `GeneratedSource` instead
  of referencing a compiler-private callback. Rust stores marks as rule-label/name/byte-offset buckets, converts
  only public projections to characters, and returns undef rather than zero for absent `mark_pos`; native,
  serialized, emitted-plan, and generated execution agree. `.17.2-.17.4` subsequently align Dart/Julia/Lua;
  `.17.5` retains final admission/hardening.
- `2026-07-13` refresh: Lua input/live-cursor `.4.3.7.1` keeps one zero-based UTF-8 byte cursor internally and
  converts only at the DSL boundary for character-unit positions, lengths, slices, lines, and columns. One
  synchronized mutation seam preserves entry/local match snapshots while updating both live and register cursor.
  Parse-scoped cursor saves are LIFO; empty restore and absent-anchor rewinds are no-ops; consume continuation
  observes the changed cursor. PUC Lua and LuaJIT pass 115/115; full local CI passes CLI 61/61 twice and phase0
  `1..1031` in 918 seconds; anonymous capture-boundary `.4.3.7.2` is next.
- `2026-07-13` refresh: Lua block/control/contextual-built-in/tree-callback parent `.4.3.6` closes through
  no-drift/dependency leaf `.4.3.6.6`. The focused dual-ABI gate remains 114/114; independent callable-codeblock
  and punctuation-light contracts pass; capability census remains 64/0/0; and the preceding mandatory full local
  gate passes CLI 61/61 twice plus phase0 `1..1031`. Current built-in final blocks remain metadata-governed by one
  final `callback: codeblock` slot. General user-function declarations and contextual execution are explicitly
  handed to `.5.1`, `{|params| ...}` literals/dynamic calls stay `.11.7`, generated preservation stays `.8.1-.8.4`,
  and capture-slice/mark/input/cursor helpers `.4.3.7` become the next dependency-ready runtime family; its first
  input/cursor leaf subsequently closes at 115/115.
- `2026-07-13` refresh: Lua array-root `walk_leaves`/`map_leaves`/`reduce_leaves` now reuse the harray callback
  frame through one receiver-root-kind dispatcher. Array children are visited by source order with Lua offsets
  translated to zero-based `index` and `path`; only nested arrays recurse, so harrays remain opaque leaves just as
  arrays remain leaves below harray roots. Kind-specific result construction preserves typed trees while shared
  walk/map/reduce control retains copied scope, continuation, terminality, and lazy invalid/empty boundaries. The
  exact checked-in Perl oracle result matches, the prior harray case remains green, and PUC Lua/LuaJIT pass 114/114.
  Tree-callback parent `.4.3.6.5` closes and no-drift/dependency handoff `.4.3.6.6` subsequently closes `.4.3.6`.
- `2026-07-13` refresh: Lua harray `walk_leaves`/`map_leaves`/`reduce_leaves` now execute through one atomic
  multi-binding scope frame. Lexically sorted keys drive depth-first recursion through harray interiors; arrays
  remain leaves; callback `path` is copied and `depth == count(path)`; `walk` preserves side effects and returns a
  source copy, `map` rebuilds a copied harray, and `reduce` threads copied typed results and stays terminal. Empty
  trees run no callbacks, non-harray receivers return null before initial/callback evaluation, and exact prior or
  absent `value`/`key`/`path`/`depth`/`acc` stores restore after success or error. The exact Perl result is locked;
  PUC Lua and LuaJIT pass 113/113. Array-root traversal was then closed separately by `.4.3.6.5.2`.
- `2026-07-13` refresh: Current value-helper lowering now gives an already-valid authored argument list priority
  over the legacy optional-scope heuristic. The AST was already correct; `MethodExpr` now exposes the explicit
  precedence mode, and `MethodLowering`/`FlowExpr` use it for `cat`, variadic arithmetic/min/max, coalescing,
  optional-width `substr`, aggregate collection values, and coalesce family inference. Invalid raw counts may
  still fall back to optional-scope compatibility. Focused AST/lowering tests and phase0 `1..1031` pass. The hash-
  tree runtime proof now consumes `key`/`depth` as leading callback values; Lua harray execution closes in
  `.4.3.6.5.1.2`.
- `2026-07-13` refresh: Lua now consults copied built-in callable metadata before evaluating a final structural
  `block_value`. Helper/receiver `with` consume attached and parenthesized forms identically; optional values and
  receivers evaluate before scope entry; copied aggregate values/results remain isolated; and compatible receiver
  chains continue. A protected scoped-binding module snapshots all private stores before mutation, copies the
  temporary uniform `value` and result inside `pcall`, restores exact prior/absent state unconditionally, then
  rethrows the original failure. This distinguishes contextual blocks from ordinary eager braces without changing
  parser syntax. PUC Lua and LuaJIT pass 112/112. Tree callback work then extends this seam from one binding to an
  atomic frame and closes deterministic harray execution at 113/113 through `.4.3.6.5.1.2`. User-function blocks
  and first-class callable values keep their separate owners.
- `2026-07-13` refresh: Lua's indexed statement executor now dispatches attached while through a dedicated lazy
  loop seam. Body validation precedes condition evaluation; body mutations feed the next condition; false initial,
  action return, expression-block-local return, and Perl-reference inner-loop `next()` are exact. The configured
  limit permits that many bodies, rechecks once, and reports typed code/keyword/kind/limit/rule fields only if the
  condition stays true. Both Lua ABIs pass 108/108. Dart/Julia exact-limit timing and Rust/Dart/Julia `next` drift
  are routed to backlog `.5`; built-in final blocks/scoped `with` later close through `.4.3.6.4`.
- `2026-07-13` refresh: Lua's same indexed statement executor now consumes attached and marker switch chains.
  Structural validation happens before the subject runs; the subject runs once; first matching case or one default
  executes through the shared range/block seam; nested marker switches and optional `endcase` boundaries remain
  bounded; bare labels stay literal; and malformed/orphaned controls expose typed fields. Inline, attached, and
  marker forms share Perl-reference scalar equality: null equals empty text, booleans spell as `0/1`, and
  aggregates are not scalar-comparable. PUC Lua and LuaJIT pass 107/107; cross-backend boolean/number and aggregate
  comparison drift is routed to backlog `.5`. Perl also executes marker statements outside every branch while
  Rust/Dart/Julia/Lua skip them; `.5` owns that range boundary too.
- `2026-07-13` refresh: Lua's indexed statement executor now consumes attached if chains and nesting-aware marker
  ranges, evaluates conditions only until one branch is selected, preserves empty bodies and block-local return,
  and emits typed malformed/orphaned diagnostics with authored keyword, reason, ActionIR kind, and rule. Portable
  `when/otherwise` attached aliases and `i/elif` marker aliases pass 106/106 on both ABIs; broader alias-shape
  acceptance in Perl/Dart/Julia versus Rust is routed to backlog `.5`.
- `2026-07-13` refresh: Lua now executes ordinary no-pair brace values eagerly at 104/104 on both ABIs. Non-final
  statements reuse dropped-statement mutation; final expressions yield values; local return catches only the
  block's return flow; empty/keyed braces remain harrays; yielded values continue through receivers. This corrects
  the earlier Lua-only `callback = { return(...) }` inert-storage scaffold expectation. Contextual trailing blocks
  remain structural, explicit callable values remain future `.11.7`, and lazy inline controls `.4.3.6.2` are done.
- `2026-07-13` refresh: Lua's ActionIR parser/resolver already preserves eager blocks, generic final block
  arguments, and structured controls, but the interpreter currently returns inert block copies and has no
  control/callback executor. `.4.3.6.0` splits eager values, inline controls, statement controls, current built-in
  contextual blocks/`with`, callbacks, and no-drift. General user-function final blocks remain `.5.1`; explicit
  callable codeblock values remain future `.11.7`; the next refresh records eager block completion.
- `2026-07-13` refresh: Lua's ordinary harray family is closed at 103/103. All 13 names route through typed
  constructor/generic paths, the copied harray dispatcher, or uniform named/direct mutation; public guards lock
  updated direct snapshots and pure receiver set-key. `walk_leaves`/`map_leaves`/`reduce_leaves` remain the three
  block-bearing names under active codeblock/control/tree-callback parent `.4.3.6`. Cross-backend odd arity,
  flattened order, and rename-collision caveats remain backlog `.5`.
- `2026-07-13` refresh: Lua dropped-statement `set_key(target, key, value)` and direct harray assignment now share
  kind-checked lookup/store functions. Absent targets create harrays; incompatible targets raise neutral
  `binding_kind_mismatch` fields; saved direct-assignment results remain isolated after nested writes. Assigned/
  function/receiver `set_key` remains pure, and numeric array-index assignment is preserved. Both ABIs pass
  103/103; non-callback harray closeout `.4.3.5.5` is active.
- `2026-07-13` refresh: Lua copied harray transforms evaluate bare operands once, deep-copy nested results, merge
  in argument order with later override, and reuse harray/array-view receiver dispatch. Pure set/rename/drop/pick
  never mutate sources; invalid/missing boundaries are locked. Both ABIs pass 102/102. Rename collision probes
  split Perl/Julia old-value-wins from Dart/Rust destination-wins; Lua follows the reference and backlog `.5` owns
  normalization. Named set-key/direct mutation `.4.3.5.4` is active.
- `2026-07-13` refresh: Uniform binding supersedes the pre-July-12 `merge_hash` bare-base exception. Bare typed
  `base` and `overlay` values are accepted in their respective transform slots; later arguments override earlier
  keys; `copy(base)` is optional pure composition; the removed single-name selector remains rejected. Perl toolbox proof,
  selected Dart/Julia neutral-corpus runs, and Rust's 105-case oracle agree. Current Knowledge Map/runtime facts
  and mdBook guidance are corrected; Lua transform implementation `.4.3.5.3.1` is active.
- `2026-07-13` refresh: Lua harray views share one lexical key order. `sorted_keys` returns that array;
  `sorted_values` copies values in the same order; count and null-aware membership return numeric terminals.
  Function/receiver forms, array continuations, missing/wrong-kind `0`/`[]`, and source isolation pass 101/101 on
  both Lua ABIs. A Perl toolbox matrix corrected the public catalog's stale non-harray count result from undef to
  zero; the transform contract has since been revalidated and implementation `.4.3.5.3.1` is active.
- `2026-07-13` refresh: Lua harray construction separates runtime identity from parent splice intent. Generic
  `flat` returns a copied array or harray according to evaluated kind; direct/receiver `flat_hash` returns a copied
  harray. Only authored direct or terminal flat ASTs splice hash entries, ordinary harray values stay nested, and
  array list context sorts keys before emitting alternating key/value values. One-time evaluation, nested copies,
  deep source isolation, and unchanged odd-arity behavior pass 100/100 on PUC Lua and LuaJIT; deterministic views
  `.4.3.5.2` are active.
- `2026-07-12` refresh: Lua's 16-name hash family splits into 13 ordinary helpers plus three callbacks. Existing
  runtime support covers typed harray literals/constructors/copy and checked direct/nested assignment, but there is
  no general hash helper/receiver dispatcher and shared `flat` always takes the array route. `.4.3.5.1-.5` own
  construction/splicing, deterministic views, copied transforms, mutation, and no-drift; callbacks stay `.4.3.6`.
- `2026-07-12` refresh: Lua's 37-name ActionIR array family is fully routed before callbacks: 34 ordinary names
  plus six numeric terminals pass 99/99; `walk_leaves`/`map_leaves`/`reduce_leaves` remain `.4.3.6`. Closeout
  corrected public invalid count/take results, push result descriptions, and a residual statement-only end-
  mutation table row, then expanded the recurring guard. Direct implicit child-push expression results differ
  between Perl's host count and Lua's updated accumulator and are explicitly routed to backlog `.5`. Harray
  helpers `.4.3.5` are active.
- `2026-07-12` refresh: Lua `split_tagged_records` evaluates source and carried fields once, reuses the governed
  literal/PCRE2 split evaluator, and constructs fresh typed `[tag, item, fields...]` records. Direct and scalar-
  receiver forms compose with array terminals and copied carried containers do not alias later updates. Both Lua
  ABIs pass 99/99; complete array/public no-drift `.4.3.4.6` has since closed.
- `2026-07-12` refresh: Lua rule accumulators are typed arrays visible through uniform binding. Action-edge child
  push reuses one cached result and supports whole or zero-based indexed append into implicit/explicit targets;
  fluent push, ordinary append/end mutation, and mutable split share the same kind-checked copied-result seam.
  Both Lua ABIs pass 98/98; tagged records/remaining bridges `.4.3.4.5` are active.
- `2026-07-12` refresh: Lua copied array transforms now cover delimiter-first terminal joins, literal/PCRE2
  split-and-flatten, PCRE2 filters, trim/filter/case/uniq pipelines, and all seven Perl-reference dropped-call
  rebindings through one kind-checked seam. Both Lua ABIs pass 95/95; mutation/child flow `.4.3.4.4` is active.
  Toolbox proof found Rust/Dart/Julia omit three rebindings and disagree on invalid joins; `.5` owns repair.
- `2026-07-12` refresh: Lua copied array selection now covers last/take/drop defaults, zero-based slice, lexical
  order/reverse, scalar-text membership/index, and stable first-occurrence uniqueness through function and
  receiver chains without mutating sources. PUC Lua and LuaJIT pass 93/93; scalar/regex transforms `.4.3.4.3` are
  active. Pre-existing backend disagreement over negative counts is explicitly owned by helper-caveat leaf `.5`.
- `2026-07-12` refresh: Lua array constructors/literals now evaluate once left-to-right and preserve ordinary
  nested arrays while explicit direct/terminal-receiver `flat`/`flat_array` ASTs splice one level. Copied flat,
  concat, and saved-source values are isolated; PUC Lua and LuaJIT pass 92/92 and selection `.4.3.4.2` is active.
  Toolbox proof found Perl direct zero/variadic flat/concat rejection versus copied results on all newer runtimes;
  existing helper-caveat owner `FUTURE-PARITY-BACKLOG.5` now owns the normalization decision.
- `2026-07-12` refresh: Uniform-binding array-end mutation results are aligned. Perl's runtime primitive already
  returned copied updates, but the ActionIR fluent value path explicitly excluded all four end methods, leaving
  value-position generated calls raw. Named binding mutations now assign and return the copied update, feed
  compatible array continuations, preserve exact arity, and reject temporary receivers. Five focused backends and
  the recurring 48-file public/KM checker pass; `.12.1`/`.12` re-close and Lua construction `.4.3.4.1` is active.
- `2026-07-12` refresh: Lua array parity is split by runtime mechanism: explicit construction/splicing, copied
  selection/order/membership, scalar/regex transforms and rebinding, mutations/child-result routing, tagged
  records, and final no-drift. This audit found older statement-only array-end result prose contradicting the
  later admitted uniform-binding updated-value contract and routed the now-closed `.12.1.11` repair before Lua
  array behavior `.4.3.4.1`.
- `2026-07-12` refresh: Lua numeric helper parent `.4.3.3` is closed. The recurring proof combines the unchanged
  55-case six-runtime scalar contract with direct dual-ABI execution of every word/symbol call, number receiver,
  reducer canonical/alias spelling, terminal array receiver, and invalid boundary. Public/status surfaces agree at
  91/91; general array helper family `.4.3.4` is active and shipped-corpus proof remains under phase 6.
- `2026-07-12` refresh: Lua now has one strict copied-array numeric reducer owner for sum, average, odd/even
  median, range, and one-array min/max. Explicit arrays, bare typed bindings, aliases, and terminal array receiver
  methods agree; empty/invalid policy is exact and sources remain unchanged. Both ABIs pass 91/91 for the reducer
  slice.
- `2026-07-12` refresh: Lua numeric word aliases and all 11 arithmetic/comparison symbol callees now reach the
  strict scalar evaluator; fluent integer, float, and bare-scalar values inject as operand one, number-returning
  links compose, and comparisons terminate later links. The first full test exposed `/` callee versus regex-start
  ambiguity after harray colons; structural slash-call detection preserves grouped, class, zero-width, and invalid
  regex literals. Both ABIs pass 90/90; aggregate reducers/array terminals `.4.3.3.3` are active.
- `2026-07-12` refresh: Selector-retirement public no-drift now includes every immediate component README. The
  earlier 47-file root/capability/mdBook inventory omitted Rust, Dart, Julia, and Lua backend READMEs, allowing 14
  current positive selector forms to survive `.12.1.9`. Follow-up `.12.1.10` migrates those forms, discovers all
  component READMEs, requires exact 56-file/31-classified-reference inventories and backend bare-binding anchors,
  and re-closes `.12.1`/`.12` with zero current examples.
- `2026-07-12` refresh: Lua now routes canonical scalar numeric calls through one helper-local evaluator that owns
  strict finite-decimal admission, governed fixed/variadic arities, invalid/null and non-finite fences, half-away
  rounding, floor signed modulo, clamp/min/max, comparisons, and negative-zero normalization independently of host
  accidents. PUC Lua and LuaJIT each pass 89/89 and the unchanged 55-case fixture; the composed checker proves exact
  agreement across Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT. Alias/symbol/number-receiver admission
  `.4.3.3.2` is active.
- `2026-07-12` refresh: Director clarification joins the existing ADR 0012 staged parse graph with the missing
  `.spec` authoring doctrine. Typical rules use zero/one/two small readable regexes for coordination, leaves, or
  entry/exit boundaries; deep recursion belongs in action-edge OR and blind-call AND rule connections.
  Progressive parsing invokes loaded specs over cursor-relative extracted text during an active parse, while
  staged parsing refines selected fields after an AST level returns. Only the narrow function-body
  `body_parse_job` family is currently proven end to end; general in-parse composition, multiple parser families,
  public parse jobs, and recursive queues are future-owned by `FUTURE-PARITY-BACKLOG.14.1-.14.4`.
- `2026-07-12` refresh: Aggregate-selector retirement is admitted. `linkedspec-uniform-binding-v1` defines one observable typed
  binding is storage-neutral; `set` yields the post-assignment target value; mutable helpers yield updated targets;
  absent target creation and wrong-kind errors are typed; static rules precede array mutation in ambiguous push;
  two-argument split is pure and three-argument split mutates a bare target. Exact one-bare array/hash calls are
  removed and reject with `aggregate_selector_removed`; `[value]` is the one-element array constructor, while other
  non-selector constructors remain in v1. Perl `.12.1.2`, Rust `.12.1.3`, Dart `.12.1.4`, Julia `.12.1.5`, and
  Lua `.12.1.6` execute the replacement contract. Migration `.12.1.7.1-.3` removed all 600 file-backed exact
  selectors and all 1,356 positive embedded-source occurrences. Perl `.12.1.8.1` rejects exact selectors at the
  canonical ActionIR boundary before lowering; Rust `.12.1.8.2` and Dart `.12.1.8.3` validate complete compiled
  ActionIR before native or generated execution. Julia `.12.1.8.4` and Lua `.12.1.8.5` do the same. Cross-variant
  `.12.1.8.6` locks all five boundary implementations and zero runtime selector compatibility in canonical CI;
  `.12.1.9` admits the final public surface.
- `2026-07-12` refresh: Spec-facing aggregate-selector removal is fully split under
  `FUTURE-PARITY-BACKLOG.12.1`. Boundary-correct pre-migration scans found 600 `array(IDENTIFIER)` / `hash(IDENTIFIER)` calls across 82
  tracked specs, including 210 in 15 shipped specs. The one-binding public model does not require identical host
  storage layouts, but bare read/mutation semantics must be complete before sources migrate and selector-specific
  recognition is hard-deleted. Neutral contract `.12.1.1`, all five backend consumers `.12.1.2-.6`, and all source
  migration `.12.1.7.1-.3` are complete. Perl hard retirement `.12.1.8.1`, Rust `.12.1.8.2`, and Dart
  `.12.1.8.3`, Julia `.12.1.8.4`, Lua `.12.1.8.5`, cross-variant no-drift `.12.1.8.6`, and public admission
  `.12.1.9` are complete.
  The public-language decision is settled.
- `2026-07-12` refresh: Perl callable metadata now declares an exact final `name: codeblock` parameter for typed
  user functions and registered helper/receiver contracts. Generic receiver attached syntax parses without a
  method-name allowlist; lowering consults `LinkedSpec::CallableContract` and normalizes attached plus
  parenthesized contextual blocks into the same zero-positional `codeblock_argument`. Generated execution covers
  `with`, typed user functions, and tree traversal; explicit literals retain their own signatures, harrays remain
  harrays, and invalid declarations/final values carry typed diagnostics. `.11.3.4` has closed Perl no-drift;
  `.12.1` now removes spec-facing aggregate selectors before cross-backend rollout.
- `2026-07-12` refresh: Perl `cb(args)` resolution now runs after governed helpers and registered user functions.
  Generated calls pass explicit references to the rule's scalar working slots into `LinkedSpec::CodeblockRuntime`,
  which evaluates the stored typed ActionIR body without adding a coderef or captured environment to the record.
  Arguments evaluate before copied fixed/rest binding; prior parameter values restore on success/failure;
  nonparameter writes remain caller-visible; return, discard, receiver continuation, arity/keyword/not-callable,
  and recursion behavior match the neutral fixture. ADR 0032 now defines final-only `name: codeblock` with the
  value owning its `{|params| ...}` signature; Perl normalization `.11.3.3.2` has since completed.
- `2026-07-12` refresh: Perl now parses exact `{|params| body }` before harray/eager blocks into the neutral
  eight-field typed record, including fixed/rest signature, body AST, source, and containing spans. Generated
  construction canonicalizes pure data as UTF-8 JSON/ASCII hex and decodes it at runtime; this avoids the measured
  rewrite/interpolation corruption of visible dumped source strings and creates no coderef/environment capture.
  Assignment/copy and user-function argument/results passed the construction boundary; dynamic invocation has
  since landed under `.11.3.2`.
- `2026-07-12` refresh: `linkedspec-callable-codeblock-v1` now machine-locks ADR 0031 before backend behavior:
  exact `{|...|...}` versus harray/eager-block classification, typed signature/body/source/spans without capture,
  dynamic caller stores, temporary copied/restored params, block-local results, static precedence, diagnostics,
  contextual final blocks, and one deterministic future fixture. Its independent parser/invocation checker is in
  canonical CI. Perl typed construction `.11.3.1` and invocation `.11.3.2` have since completed; ADR 0032's
  declaration is adopted and generic Perl final blocks have since completed under `.11.3.3.2` before closeout.
- `2026-07-12` refresh: Dart now carries ADR 0030's v2 signature through the spec-defined shell, AST/staged jobs,
  registry/action contracts, public descriptors, native runtime, normalized emitted state, generated-plan
  execution, and reconstruction. Calls are positional-only, fixed v1 stays exact, v2 enforces its minimum, and
  extras bind as a fresh typed list in function-local stores after ordered eager evaluation. Six contract tests
  and the complete 190-test/61x2/105 Dart gate pass. Julia `.4.3.2` is active.
- `2026-07-12` refresh: Rust now carries ADR 0030's v2 `CallableSignature` through definition AST validation,
  compiled records, exact staged/public projection, serialized generated source, and native/generated-plan
  execution. Calls preserve exact v1 arity, enforce v2 minimum arity, evaluate once left-to-right, and allocate a
  fresh typed rest array in function-local stores. Seven contract tests and 196 core assertions pass. The neutral
  receiver case exposed and corrected Rust `length` returning zero for arrays; arrays now use cardinality and
  scalar text retains Unicode character count. The complete Rust gate passes both 105-case interpreter/generated
  proofs, 197 integration tests, and 61x2 CLI. Dart `.4.3.1` is active.
- `2026-07-12` refresh: the Perl reference now parses final `...rest`, validates/preserves version-2 signatures
  through staged payload/job and outward descriptors, eagerly evaluates positional arguments once left-to-right,
  and binds extras into a fresh scalar-held array in generated source. The unchanged neutral fixture passes all
  results and 66 focused assertions. Its array `.length()` case exposed and corrected the shared Perl lowerer's
  stale scalar-only implementation; scalar behavior is unchanged. Canonical CI passes 61x2 CLI plus Phase 0
  `1..1030` in 710 seconds after one measured 13-string lock migration. Rust `.4.2.2` is active.
- `2026-07-12` refresh: ADR 0030 and `linkedspec-callable-signature-v1` adopt final `...IDENTIFIER`, version-1
  exact functions, version-2 variadic signature records, positional eager calls, fresh typed rest arrays, and
  stable invalid-signature/arity/keyword diagnostics. The offline checker is in canonical CI; Perl now consumes
  the contract while cross-backend admission remains open.
- `2026-07-12` refresh: variadic audit `.4.0` finds built-in helper/method open maxima already purpose-specific,
  while user-function exact `arity` is repeated through the spec-owned shell, staged payload/job, exact outward
  descriptor, compiled registries, native/generated execution, and Lua invocation frames. Neutral versioned
  signature/fixture `.4.1` is active; no behavior changed in the audit.
- `2026-07-12` refresh: Dart and Julia now consume all 55 scalar numeric v1 cases through strict helper-local
  decimal, arity, result, rounding, and signed-modulo boundaries. Their authoritative package/analyzer/CLI/corpus
  gates pass. Lua exact six-runtime numeric admission is ready; director-prioritized callable-arity audit
  `FUTURE-PARITY-BACKLOG.4.0` is the next clean-tree frontier.
- `2026-07-12` refresh: Perl generated actions and the Rust runtime now consume scalar numeric v1 through dedicated
  strict adapters. Both pass all 55 unchanged cases; generic Perl scalar-to-text conversion and Rust
  `RuntimeValue::as_number` remain untouched. Dart/Julia alignment `.4.3.3.1.3` is complete.
- `2026-07-12` refresh: ADR `0029` adopts `linkedspec-scalar-numeric-v1`. A 55-case neutral fixture and independent
  offline evaluator/source renderer now own strict numeric inputs, arities, invalid/null, comparisons, rounding,
  clamp/division, and signed modulo. All four admitted backends are aligned; Lua `.1.4` follows.
- `2026-07-12` refresh: `LUA-BACKEND-PARITY.4.3.2.2.5.1` closes Lua scalar/string parity at 76/76 on both ABIs,
  corrects stale positive retired-helper prose to canonical `cat`, and advances to numeric helpers `.4.3.3`.
- `2026-07-12` refresh: `LUA-BACKEND-PARITY.4.3.2.2.4` originally added dropped-statement dispatch for the
  now-removed explicit aggregate selector; uniform-binding retirement later moved this to
  `split(target, source, delimiter)` through copied pure split values. Scalar-held and source
  values stay isolated. Both Lua ABIs pass 76/76; regex/split no-drift `.5` is active.
- `2026-07-12` refresh: `LUA-BACKEND-PARITY.4.3.2.2.3` adds dropped-statement dispatch for bare-scalar regex
  substitution, strict operation flags, `$0`/`$n`, Unicode-safe zero-width progress, and rule-attributed errors.
  Both Lua ABIs pass 75/75; explicit array split replacement `.4` is active.
- `2026-07-12` refresh: `LUA-BACKEND-PARITY.4.3.2.2.2` adds copied typed split values for literal and PCRE2
  delimiters, UTF-8 scalar empty-delimiter splitting, zero-width progress, and pure string receiver bridging.
  Both Lua ABIs pass 74/74; statement scalar regex substitution `.3` is active.
- `2026-07-12` refresh: `LUA-BACKEND-PARITY.4.3.2.2.1` adds internal typed helper regexes and strict flag
  normalization over the existing PCRE2 owner. Function/receiver `matches` fails closed for invalid inputs and
  passes 73/73 on PUC Lua/LuaJIT; pure split `.2` is active.
- `2026-07-12` refresh: `LUA-BACKEND-PARITY.4.3.2.2.0` splits regex/split/mutation by runtime mechanism. `.1`
  owns typed helper regex values, governed flags, and `matches`; `.2` pure split/receiver bridging; `.3`
  scalar substitution; `.4` explicit array split replacement; `.5` corpus/public no-drift.
- `2026-07-12` refresh: `LUA-BACKEND-PARITY.4.3.2.1.3` closes pure scalar/string parity with one typed
  scalar-to-text boundary. Perl generated lowering, Rust `RuntimeValue::to_scalar_text`, Dart `_scalarString`,
  Julia `_runtime_scalar_string`, and Lua `scalar_string` now give `cat` identical string/boolean/finite-number
  spelling and null propagation for non-text values. Regex/split/mutation `.4.3.2.2` follows.
- `2026-07-11` refresh: `LUA-BACKEND-PARITY.4.3.2.0` separates pure scalar/string evaluation and receivers from
  regex-aware replacement/split/statement mutation. `.4.3.2.1` is the sole executable frontier; no behavior or
  capability changes at this planning boundary.
- `2026-07-11` refresh: `LUA-BACKEND-PARITY.4.3.1` adds explicit four-kind runtime identity and copied local
  stores, checked mixed access/assignment, current-edge `retv`, and the complete entry/match read family. Both Lua
  ABIs pass 69 tests. A direct portability audit confirms `spec.spec` uses fixed-width negative lookbehind;
  PCRE2-backed PUC/LuaJIT tests and Dart's real spec.spec corpus path pass, so no current gap is routed.
- `2026-07-11` refresh: `LUA-BACKEND-PARITY.4.3.0` splits Lua's admitted 239-name runtime breadth by mechanism:
  core four-kind values/stores/access and entry/match reads, scalar/string, numeric, arrays, harrays,
  codeblocks/controls/callbacks, stateful capture/mark/input/cursor, diagnostic output, and exhaustive no-drift.
  `.4.3.1` is the only executable frontier; no helper capability was promoted by this planning leaf.
- `2026-07-11` refresh: `LUA-BACKEND-PARITY.4.2` adds the first executable Lua compiled-rule owner.
  `lua/src/linkedspec/interpreter.lua` composes compiled state with native PCRE2 matching and executes default/
  AND/OR/repetition modes, action/blind children, lifecycle flow, local stores, `retv`, narrow accumulators,
  explicit controls, direct output, and recursion/progress fences. The identical 66-test gate passes PUC Lua and
  LuaJIT. Broad helper/value behavior remains split-first work under active `.4.3.0`.
- `2026-07-11` refresh: `FUTURE-PARITY-BACKLOG.3.3.3` admits generated Dart source. Its recurring test consumes
  the contract's exact eight-case list, proves checked-in values through the interpreter before emission, then
  analyzes/runs all emitted libraries in one isolated offline package with exact metadata/plan/trace identity.
  The contract checker locks test path/count/order/host proof/cleanup/no-skip. Complete Dart gates pass 181 tests,
  61x2 CLI, and 105 corpus. Dart promotes gap→pass; census is 59/0/1 and Julia `.3.4.1` is active.
- `2026-07-11` refresh: `FUTURE-PARITY-BACKLOG.3.3.2` adds Dart's exact contract-v1 generated plan and direct
  structural executor. Compiled mode/regex/action/blind metadata classifies all ten neutral families. Four mutable
  plan defects reject before execution with distinct codes; validated typed families select acode/regex or
  bcode/blind dispatch on every rule entry and emit three portable trace roles. One isolated offline package runs
  all ten generated families against interpreter values. At that leaf, complete gates passed 180 tests, 61x2 CLI,
  and 105 corpus; `.3.3.3` has since admitted Dart at 59/0/1.
- `2026-07-11` refresh: `FUTURE-PARITY-BACKLOG.3.3.1` adds Dart's public deterministic generated-source scaffold.
  `emitDartSourceV1(...)` consumes effective ordered compiled state and emits a native library with stable v1
  metadata, source identity, ordinary/traced direct-value entrypoints, and portable emission/compile-load/execution
  failures. Normalized spec JSON is encoded as strict UTF-8 then Base64 inside Unicode Dart source. An isolated
  caller-owned package/private cache resolves offline, analyzes, runs, attributes failure, and deletes itself.
  At that leaf, complete Dart gates passed 178 tests, 61x2 CLI, and 105/105 corpus. Census remained 58/0/2;
  `.3.3.2` and `.3.3.3` have since closed exact family/direct execution and manifest admission.
- `2026-07-10` refresh: `FUTURE-PARITY-BACKLOG.1.5.1.6.3` closes the Perl primary-command reference.
  Help, manifest, task/roadmap/live docs, mdBook, and Knowledge Map agree on the strict preserved UTF-8 contract
  and 61 exact cases. Dated 53-case and pre-fix mojibake records remain historical evidence, not live defects.
  Focused suites, 61/61 default/POSIX, and full local CI through Phase 0 pass. Parent `.1.5.1`/`.1.5.1.6` are done;
  Rust `.1.5.2` is active to add a thin native-library CLI against the unchanged shared manifest.
- `2026-07-10` refresh: `FUTURE-PARITY-BACKLOG.1.5.1.6.2` closes the Perl primary UTF-8 adapter gap.
  `bin/linkedspec` strictly decodes valid argv and raw source/input files, preserves normalization/BOM/newlines,
  keeps invalid files in stable compilation/input-load phases, and emits recursively canonical UTF-8 JSON once.
  Eight exact cases cover inline/file/nested Unicode, composed/decomposed text, input U+FEFF/CRLF/LF, source BOM
  non-stripping, invalid bytes, and trace input/result byte counts; the current shared suite is 61/61 under default
  and POSIX environments. Unicode is the logical text model; UTF-8 is the selected wire encoding, not a synonym.
  `.6.3` has since closed final reference no-drift and activated Rust `.1.5.2`.
- `2026-07-10` refresh: `FUTURE-PARITY-BACKLOG.11.0` captures a correction to the closed trailing-block MVP.
  Current Perl/Rust/Dart/Julia runtimes support named `with` and tree-traversal block surfaces; Lua is absent, and
  generic attached/parenthesized equivalence is not implemented. The intended model has four object/value kinds—
  scalar, array, harray/hash, and codeblock—and lets a callable signature accept a final codeblock so
  `call(args) { block }` and `call(args, { block })` normalize identically. Parked `.11.1` owns canonical AST/IR,
  evaluation/diagnostics/parity, terminology, and whether `with` remains an ordinary helper or is removed.
  That capture left `.1.5.1.6.2` active at the time; `.6.3` has since closed Perl and activated Rust `.1.5.2`.
- `2026-07-12` refresh: ADR `0031` and `FUTURE-PARITY-BACKLOG.11.1` settle the callable-codeblock design.
  `{|params| body }` is a deferred typed codeblock literal; `{|| body }` has no params and final `...rest` reuses
  ADR `0030`. Exact `{|` recognition precedes the existing `{}`/colon harray and eager `{ statements }` block
  classifier. `cb(args)` uses ordered positional evaluation, temporary copied parameter/rest bindings, block-local
  return, and dynamic caller context for all nonparameter state; it captures no lexical environment. Static
  governed callables retain precedence, recursion is initially rejected, and `with` remains ordinary. Neutral
  schema/fixtures `.11.2` are adopted and checked. Perl typed construction `.11.3.1` and dynamic invocation
  `.11.3.2` are complete. Audit `.11.3.3.0` found the missing declaration, and ADR 0032 now adopts final-only
  `name: codeblock`: it carries no nested argument list because explicit values own `{|params| ...}` signatures.
  Perl normalization `.11.3.3.2` and diagnostics/docs/no-drift closeout `.11.3.4` are complete. Active `.12.1`
  has removed spec-facing aggregate selectors from all five backends, closed cross-variant no-drift, and admitted
  the public surface.
- `2026-07-10` refresh: `FUTURE-PARITY-BACKLOG.1.5.1.6.1` extends neutral manifest schema version 1 with exact
  `bytes_hex` input-file materialization. Exactly one checked-in source or non-empty lowercase even hex is allowed;
  raw workspace bytes and malformed/ambiguous pre-launch rejection are focused-locked. The then-existing 53 cases
  were unchanged; `.6.2` has since added strict Perl decoding plus eight valid/invalid behavior fixtures.
- `2026-07-10` refresh: `FUTURE-PARITY-BACKLOG.1.5.1.6.0` ratifies ADR `0025`: primary source/input/arguments,
  JSON, and trace are strict UTF-8 text, preserved without normalization/BOM stripping/newline conversion/trimming.
  Invalid spec/input file bytes map to compilation/input-load failures; binary input is not implicit. Direct decoded
  Perl native probes return exact Unicode, isolating mojibake to `bin/linkedspec`. `.6.1` is active for neutral
  hex-byte fixture materialization, then `.6.2` adapter/fixtures and `.6.3` closeout; no behavior changed here.
- `2026-07-10` refresh: `FUTURE-PARITY-BACKLOG.10.0` durably captures deep semantic introspection as a future
  first-class surface. One versioned, deterministic semantic model belongs to idiomatic in-memory APIs across all
  backends; MCP is a thin projection and owns no semantics. Stable ids/order, source spans/provenance, exact parity
  fixtures, cost/privacy controls, and an explicit anti-backend-IR boundary are mandatory design inputs in `.10.1`.
  Active execution remains `.1.5.1.6.1`; no implementation changed.
- `2026-07-10` refresh: `FUTURE-PARITY-BACKLOG.1.5.1.5` closes canonical primary trace at 53 cases and adopts
  ADR `0024`. The primary command emits a concise deterministic UTF-8 phase protocol across stdout/route/mirror,
  reset/persistence/append, every named level and alias, numeric thresholds, emoji, and all three failure phases;
  native embedding keeps rich backend trace. The local gate invokes the same manifest under default/POSIX
  environments. Signoff exposed raw UTF-8 argv mojibake in successful JSON; active `.1.5.1.6` owns that shared
  process boundary before pending Rust `.1.5.2`.
- `2026-07-10` refresh: `FUTURE-PARITY-BACKLOG.1.5.1.4` extends the neutral Perl baseline to 33 cases. Four
  operational families lock compile-before-input order, missing source/input, missing top rule, empty stdout,
  exact one-line backend-neutral stderr, exit `1`, and no files. When no CLI trace option is present, the adapter
  clears backend trace environment inputs and uses a below-`none` discard configuration; the general trace owner
  is unchanged. `.1.5.1.5` has since closed explicit trace combinations and reusable-runner local-gate integration.
- `2026-07-10` refresh: `FUTURE-PARITY-BACKLOG.1.5.1.3` extends the neutral Perl baseline to 29 cases. Seven new
  success families lock named/file/inline source, literal/file input, explicit top rule, seek/consume, nested
  canonical JSON, exact input-newline preservation, empty stderr, exit `0`, and one JSON-record newline. Toolbox
  probes reverified ADR `0020`'s known direct-default-rule `E` caveat, so portable action-edge returns own the
  fixtures. `.1.5.1.4` has since closed operational failures and stdout purity.
- `2026-07-10` refresh: `FUTURE-PARITY-BACKLOG.1.5.1.2` makes Perl primary argument parsing explicit and exact.
  Ambient `Getopt::Long` policy is gone; only case-sensitive ADR `0023` spellings and `-h` exist. A shared usage
  template plus channel variables yields 20 exact usage cases without duplicated help snapshots. With both help
  forms, 22/22 pass with `POSIXLY_CORRECT` unset and set; stdout is empty and exit is `2` for every usage failure.
  `.1.5.1.3` has since closed source/input/parser controls and canonical success bytes.
- `2026-07-10` refresh: `FUTURE-PARITY-BACKLOG.1.5.1.1` establishes the neutral primary-CLI fixture architecture.
  A strict JSON manifest and arbitrary command-array runner own canonical private workspaces, safe checked-in file
  materialization, explicit command/repo/workspace/case placeholders, raw stdout/stderr, exit status, generated
  files, and byte-offset mismatch diagnostics. Perl passes the exact backend-neutral help case; four runner
  subtests (13 assertions) and two trace subtests pass. `.1.5.1.2` has since closed strict argument/usage fixtures.
- `2026-07-10` refresh: `FUTURE-PARITY-BACKLOG.1.5.1.0` audits and splits the neutral CLI/Perl reference lane.
  The existing trace smoke passes, but direct processes prove ignored positionals, case/abbreviation/negated option
  aliases, `POSIXLY_CORRECT`-dependent parsing, uncontrolled `Getopt::Long` warnings, and timestamped `DUMP_NONE`
  failure records on stdout. Five ordered leaves own harness/help, arguments, success/IO, failures, and trace/gate;
  `.1.5.1.1` has since closed the neutral runner/help baseline.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.7.3.3` closes the local outer no-drift audit without closing the
  Julia parity tree. One mdBook limitation sentence inherited from `.7.3.2.1` incorrectly denied the exact primary
  CLI after later leaves implemented it; current surfaces now agree on `runtime-corpus-primary-cli`, 1,017 package
  assertions, nine process families, and 99/99. The Julia root remains active/delegated to global `.1.5` CLI
  identity, `.1.6` capability census, and `.3` generated-source equivalence; `.1.5.1.0` has since split the next
  neutral-fixture/Perl work.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.7.3.2.5` closes Julia-local primary CLI conformance. A standalone
  checker owns nine real-process help/success/usage/operational/route/mirror families with exact stdout/stderr/
  newline/file bytes and exit 0/1/2; the focused gate delegates to it, 1,017 package assertions, and 99/99 corpus.
  Public status is the precise `runtime-corpus-primary-cli`, not complete parity. `.7.3.3` has since closed the
  local audit; global CLI fixtures, capability census, and generated-source convergence remain separately owned.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.7.3.2.4` normalizes Julia's primary failure and trace-routing
  boundary. Source compilation precedes deferred input-file loading; stable compilation/input/invocation stderr
  exits `1`, usage exits `2`, and runtime diagnostics render ordered fields. Stdout/route/mirror, empty/missing/file
  sinks, reset, quiet, and level-specific emoji now compose through the existing emitter. Seventy-five focused
  assertions, the 1,017-assertion suite, and 99/99 pass; `.7.3.2.5` has since closed direct-process/no-drift.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.7.3.2.3` connects Julia's prepared primary requests to the same
  native rule-first/spec-driven-function fallback, compiler, and runtime used in memory. Top-rule, seek/consume,
  source identity, and one trace emitter propagate through the pipeline. The CLI serializes the direct top-rule
  value, not the corpus wrapper, through a recursive compact writer that sorts every object level. Twenty-two
  focused assertions, the 942-assertion suite, direct canonical primary smoke, and 99/99 pass; `.7.3.2.4` has since
  closed normalized failures/exits/trace routing.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.7.3.2.2` replaces Julia's rollout-era primary `status`/`corpus`
  dispatch with ADR `0023`'s exact option and preparation model. It rejects subcommands/positionals with usage `2`,
  validates selector/mode/trace contracts, resolves named specs through current path/current `.spec`/repository
  `specs`/sorted authored fallback precedence, and preserves exact file/inline source and input. Corpus tooling is
  separate. Fifty focused assertions, the 920-assertion suite, direct CLI checks, and 99/99 pass. `.7.3.2.3` has
  since connected prepared requests to native execution and canonical JSON.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.7.3.2.1` closes the trace prerequisite for Julia's exact primary
  CLI. One optional caller-owned `LinkedSpecTraceEmitter` now propagates through source parsing, every validation
  pass, compiled-state construction, spec-driven function-shell parse/projection/runtime execution, and staged
  normalize/queue/resolve/load/compile/execute. Existing levels and stdout/route/mirror/reset sinks remain the sole
  mechanism; omitted/disabled emitters stay quiet. Twenty-eight focused assertions, the full 868-assertion suite,
  CLI smokes, and 99/99 corpus gate pass. `.7.3.2.2` has since closed exact arguments/source/input loading.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.7.3.2.0` splits Julia primary CLI repair after source audit. Native
  rule/staged parsing, compile/runtime, diagnostics, and runtime trace sinks exist; missing mechanisms are compile/
  parser/staged trace (`.1`, now done), exact arguments/resolution (`.2`, active), execution/canonical JSON (`.3`), normalized
  failures/trace routing (`.4`), and direct-command conformance (`.5`). No implementation changed in the split.
- `2026-07-10` refresh: ADR `0023` closes `JULIA-BACKEND-PARITY.7.3.1`. Complete parity now means identical
  user-observable capability/behavior; distinct executable tokens expose one parser-oriented interface with the
  Perl source/input/parser/trace/help option set, no subcommands/positionals, canonical JSON, normalized errors,
  and 0/1/2 exits. `.7.3.2` is active for Julia; global CLI repair is `.1.5`, capability census `.1.6`, and public
  generated-source parity `.3`. Rust's exported emitter makes codegen mandatory for complete, not interpreter, parity.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.7.3.0` proves a cross-backend CLI architecture gap. ADR `0006`
  already requires the same user-visible features and semantics, and the director clarified that distinct backend
  executable names must expose an identical CLI contract. Perl currently has the parser CLI, Dart/Julia expose
  corpus/status CLIs, and Rust declares no binary target. `.7.3.1` has since ratified the durable contract/routing.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.7.2` deliberately defers generated Julia source. Native in-memory
  interpreter parity already passes 99/99; Rust evidence shows generated proof needs a separately split emitter/
  compile-run harness, typed family plan, direct structural-family execution, and curated corpus subset.
  `FUTURE-PARITY-BACKLOG.3` now owns separate Rust breadth and Dart/Julia generated-source lanes; `.7.3` has since
  been split by the strict user-facing CLI audit.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.7.1` closes public usage/status/limitation documentation. The mdBook
  now presents Julia as a native in-memory 99/99 interpreter backend, includes self-contained rule/function
  examples, and distinguishes current runtime trace parity from compile/parser trace non-claims. Generated Julia
  source was a separate `.7.2` decision and has since been deferred; no implementation behavior changed.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.4` adds `tools/run_julia_local.sh` as the repo-owned package/CLI/
  99-fixture gate. Julia executable and depot paths are configurable, with generated depot state outside the
  repository. Shared local CI includes the gate only under `LINKEDSPEC_RUN_JULIA=1`, so default core verification
  has no Julia SDK dependency. The focused gate passes 840 assertions plus 99/99; `.7.1` has since closed docs.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.3` closes the full Julia corpus gate. Complete manifest validation
  remains mandatory before execution; one atomic regression locks format/order/count/endpoints, 99/99 passes,
  zero failures, and every exact output. Unbounded CLI `--execute` now runs the full manifest, with selectors
  retained for diagnostics. Full tests pass with 840 assertions, status is `runtime-corpus-full`, and `.6.4` is
  active for verification wiring.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.5` closes the three routed top-level function fixtures. Julia
  compiles and caches `specs/user_function_definition.spec`, executes it over source in memory, normalizes neutral
  function nodes, and composes existing staged body parsing/registry/runtime paths. Corpus parsing falls back to
  this path only after rule-only source parsing fails. Full tests pass with 827 assertions; package/CLI status is
  `runtime-corpus-function-shells`; no raw scanner or fixture shortcut was added; `.6.3` is the full-manifest gate.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.6` closes shipped-corpus no-drift. One permanent test executes
  offsets 68–98 together and locks manifest/result counts, tclite-to-lib_reader endpoints, 31/31 passes, zero
  failures, and every exact output. Full Julia tests pass with 816 assertions; package/CLI status is
  `runtime-corpus-shipped` at that boundary; `.6.2.5` has since closed the top-level function fixtures.
- `2026-07-10` refresh: ADR `0022` ratifies native in-memory embedding as the reason for LinkedSpec's multiple
  backends. Perl `Get`, Rust core/runtime crates, Dart package APIs, and Julia module APIs already expose the
  structural host-process parse/compile/execute path. CLIs, corpus runners, and platform wrappers are secondary
  adapters with no exclusive semantics. Lua and future backends must meet the native library gate first. This
  architecture leaf changes no parser/compiler/runtime behavior; Julia `.6.2.4.6` has since closed no-drift.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.5.3` mirrors the public parser's leading blank/comment-line
  skip through Julia's existing in-memory cursor/register seam. History now matches the null-object public oracle
  without weakening scalar-held indexed reads. Full tests pass with 810 assertions, shipped smoke is 31/31,
  status is `runtime-corpus-leading-trivia` at that boundary; `.6.2.4.6` has since closed final no-drift.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.5.2` distinguishes statement regex substitution from pure
  string slicing. In statement context, four-argument `substr(...)` / `regex_subst(...)` mutates a bare scalar
  target through strict helper flags and `$n` replacement; numeric slicing remains pure. Both EBNF, both lib_reader,
  and simenv fixtures pass. Full tests pass with 808 assertions, shipped smoke is 30/31, status is
  `runtime-corpus-statement-mutation` at that boundary; `.6.2.4.5.3` has since closed history.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.5.1` executes `exit_now(...)` as immediate fatal parser
  control. The optional first argument is evaluated as a numeric status, absent/nonnumeric status defaults to `1`,
  and `RuntimeInterpreterException` retains structured rule/top/spec attribution. Simenv now reaches
  `exit_now(1) in rule begin_end_blocks`, exposing the earlier statement-form scalar mutation prerequisite under
  `.6.2.4.5.2`. Full tests pass with 801 assertions, shipped smoke remains 25/31, status is
  `runtime-corpus-exit-now` at that boundary; `.6.2.4.5.2` and `.5.3` have since closed.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.4` gives compiled-rule first arguments child-call precedence
  in action-edge `push(...)`, reuses cached edge child results, and supports implicit/explicit whole and indexed
  appends. All four spec.spec smokes pass. Both EBNF cases retain complete structures and route quote-only
  statement mutation to `.6.2.4.5.2`. Full tests pass with 793 assertions, shipped smoke is 25/31, status is
  `runtime-corpus-action-edge-child-push` at that boundary; `.6.2.4.5` has since closed.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.3` scopes explicit aggregate resets per rule invocation.
  First-reset snapshots restore prior scalar/array/hash bindings at rule exit; ordinary undeclared child mutations
  remain caller-visible, and registered user functions retain their independent whole-store isolation. All three
  recursive fixtures pass, full tests pass with 785 assertions, shipped smoke is 21/31, status is
  `runtime-corpus-recursive-rule-scope` at that boundary.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.2.2` adds eager diagnostic `print`/`print_each`/`say`
  execution through Julia's configured low-level trace sink. Helpers return `nothing`, never change parser output,
  and remain quiet without enabled tracing. Simenv advances from unsupported `print` to unsupported `exit_now`;
  history advances to the known leading-trivia output mismatch. Full tests pass with 780 assertions, shipped smoke
  remains 18/31, status is `runtime-corpus-diagnostic-output`, and `.6.2.4.2` closes.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.2.3` centralizes strict helper regex compilation. Meaningful
  `i`/`m`/`s`/`x` reach Julia `Regex`; execution-only `g` and Perl compile-once `o` are accepted no-ops; unknown
  flags and invalid patterns remain failures. Predicate and split helpers share the seam. Portmap constant passes,
  full tests remain 772, shipped smoke is 18/31, status is `runtime-corpus-helper-regex-flags`, and `.6.2.4.2.2`
  has since closed.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.2.1` adds eager boolean `and`/`or`/`not` through the existing
  runtime truthiness contract, including Rust-compatible empty arities. Three portmap cases and tablegrep pass;
  direct compacted-capture and trace probes route `portmap_constant` to `.6.2.4.2.3` because Perl's no-op `o` flag
  currently invalidates Julia helper regex compilation. Full tests pass with 772, shipped smoke is 17/31, status is
  `runtime-corpus-logical-helpers` at that boundary; `.6.2.4.2.3` has since closed portmap constant and
  `.6.2.4.5.3` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.1` executes the complete direct anonymous capture-boundary
  family over the existing rule-local register: start; match-start/cursor/input-end text and character lengths;
  origin position/line/column; and destructive take variants. Focused Unicode/location/mutation and corpus proofs
  bring full tests to 766, all three hlink delimiter fixtures pass, the shipped-smoke window is 13/31, and EBNF
  logging routes to structural output. Status is `runtime-corpus-capture-boundaries` at that boundary;
  `.6.2.4.2.1` has since moved the window to 17/31 and `.6.2.4.5.3` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.0` measures the complete shipped-spec/parser-smoke window at
  10 passed / 21 failed and decomposes it before behavior changes. Owned groups are anonymous capture boundaries,
  logical helpers, diagnostic-output helpers, recursive top-rule outputs, EBNF/spec.spec structural outputs,
  lib_reader quote normalization, and final 31/31 no-drift. Runtime status remains `runtime-corpus-middle` at 757
  assertions at that boundary; `.6.2.4.1` has since moved the window to 13/31 and `.6.2.4.5.3` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.3` proves the 25 non-function middle fixtures through bounded
  windows 40–56, 58–59, and 62–67 with no production or fixture correction. A permanent window/endpoint/count/
  failure regression also locks the exact top-level function offsets routed to `.6.2.5`. Full tests pass with 757
  assertions, status advances to `runtime-corpus-middle`, and shipped-spec/parser-smoke fixtures 68–98 are active
  under `.6.2.4`; `.6.2.4.0` has since split the 10/31 diagnostic boundary and `.6.2.4.5.3` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.2` proves manifest fixtures 0–39 green through bounded
  parse/compile/runtime execution with no production or fixture correction. A permanent endpoint/count/failure
  regression test brings the suite to 751 assertions and status `runtime-corpus-starter` at that boundary;
  `.6.2.3` has since closed 25/25 and `.6.2.4.5.3` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.1` adds ordered named and zero-based bounded corpus selection
  after complete manifest validation, plus opt-in runner PASS/FAIL reporting and stable exit codes. Validation-only
  default behavior remains; CLI execution requires a named case or positive limit until full parity. Thirty added
  assertions bring the suite to 745 and status `runtime-corpus-selection` at that boundary. `.6.2.2` and `.6.2.3`
  have since closed 40/40 and 25/25; `.6.2.4.5.3` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.0` decomposes the 99-fixture Julia rollout before behavior
  changes into bounded selection/reporting, starter 0–39, middle non-function 40–67, shipped-spec/parser-smoke
  68–98, and spec-defined function-shell owners. The executable architecture remains the 715-assertion
  `runtime-controlled-corpus` `.6.1` boundary at that planning point; `.6.2.1` through `.6.2.4.2.3` have since landed
  and `.6.2.4.5.3` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.1` adds Julia's controlled corpus composition layer.
  `execute_corpus_fixtures(...)` reuses manifest validation, parses/compiles/executes every fixture, structurally
  compares one-level wrapped output, captures optional trace lines and structured runtime diagnostics, and reports
  every failure without aborting. Six passing authored fixtures plus diagnostic/mismatch continuation add 24
  assertions; full tests pass with 715, status advances to `runtime-controlled-corpus`, and `.6.2` manifest batches
  are active. CLI `--execute` remains later work.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.5.3` locks neutral staged function descriptor shape through one
  executable fixture. Spec-returned definition order, payload provenance, normalized job ids/paths/policies,
  stitched ActionIR bodies, compiled registry order, public descriptor function metadata, and runtime output agree.
  No projection correction was required; status remains `runtime-user-functions` at that boundary and full tests
  pass with 691 assertions. `.6.1` through `.6.2.4.2.3` have since landed; `.6.2.4.5.3` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.5.2` adds registered exact-arity runtime calls before helper
  fallback. Arguments evaluate eagerly in caller scope; cached ActionIR bodies execute with fresh scalar/array/hash
  stores; caller stores restore exception-safely; final expressions/local returns feed value and receiver positions;
  standalone results drop; and direct/mutual recursion emits structured cycle diagnostics. Package status is
  `runtime-user-functions`, and the full suite passes with 671 assertions. `.5.3` has since closed `.5`, `.6.1`
  has since landed, `.6.2.0` has split the rollout, `.6.2.1` through `.6.2.4.2.3` have landed, and `.6.2.4.5.3` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.5.1` adds Julia's narrow staged function-body registry. It resolves
  the fixed built-in ActionIR adapter, orders jobs structurally, records portable cache/compiled/result metadata,
  parses typed ActionIR into neutral JSON, validates sidecars, and immutably stitches `body_ast`. Package status is
  `runtime-staged-registry` at that boundary, and the full suite passes with 662 assertions. `.5.2` and `.5.3` have
  since landed, `.5` is closed, `.6.1` through `.6.2.4.2.3` have since landed, and `.6.2.4.5.3` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.5.4` closes the scoped Julia diagnostics/trace container with no
  source correction. The 631-assertion suite, package/CLI `runtime-trace-events` status, book, KM, roadmap/task/live
  docs, and architecture agree on structured runtime diagnostics plus control/sink/event/runtime-instrumentation
  capabilities without overclaiming compile/parser tracing or staged/corpus parity. `.5.1` through `.5.3` have
  since landed, `.5` is closed, `.6.1` through `.6.2.4.2.3` have since landed, and `.6.2.4.5.3` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.5.3` instruments the existing Julia runtime path with optional
  rule scopes, regex/action/blind/recursion decisions, lifecycle marks, cursor/stack transitions, and boundary
  events. Absent/disabled emitters remain no-ops; scope cleanup is exception-safe; traced and untraced action,
  blind, and recursion results agree. Package status is `runtime-trace-events`, the full suite passes with 631
  assertions, and final diagnostics/trace no-drift advances to `.4.5.4`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.5.2` adds Julia-native ordered trace levels,
  environment/config controls, structured event/scope/decision/log/dump primitives, stdout/route/mirror sinks
  with reset, optional runtime emitter injection, and output-preserving traced wrappers. Package status is
  `runtime-trace-controls`, the full suite passes with 617 assertions, and instrumentation advances to `.4.5.3`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.5.1` exports neutral-field `RuntimeDiagnostic` payloads on Julia
  runtime exceptions, carries optional spec identity plus top/rule/handler attribution through nested failures,
  preserves richer inner diagnostics, and leaves successful parse output/textual errors unchanged. Package status
  is `runtime-diagnostics`, the full suite passes with 588 assertions, and trace controls advance to `.4.5.2`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.5.0` splits Julia diagnostics/trace before code into stable
  structured runtime diagnostics, reusable trace levels/config/events/sinks, interpreter instrumentation, and
  final no-drift owners. Runtime behavior and `runtime-cursor-boundary` status are unchanged; `.4.5.1` is the sole
  active frontier.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.4` adds Julia's explicit LIFO cursor stack, synchronized
  live/register cursor updates, entry/local anchor rewinds, character-based cursor/input helper projection, and
  earliest usable non-consuming named-rule boundary capture. Cursor moves preserve match records and semantic
  stores; normal follow-on matching retains the configured seek/consume mode. Package status is
  `runtime-cursor-boundary`, the full suite passes with 581 assertions, and diagnostics/trace advances to `.4.5`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.6` closes Julia helper/value no-drift. The 567-assertion suite,
  `runtime-value-control-tree` package status, mdBook contracts, live docs, and Knowledge Map agree; `.4.3.1`
  already supplied the final checked no-autovivification nested-write contract, so no runtime correction was
  required. Stale `.3`/`.4.3` parent metadata and central helper-catalog line-ending semicolons are reconciled;
  `.4.4` owns cursor controls and boundary capture.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.5` separates Julia rule-level action flow from block-local
  value flow; adds attached and marker controls, lazy inline branches, deterministic while guards, immediate
  helper/receiver with-blocks, scoped binding snapshots, and hash/array tree walk/map/reduce callbacks. Hash
  traversal is sorted-key depth-first; array traversal is zero-based depth-first; non-aggregate receivers do not
  evaluate callbacks or reduce initializers. Package status is `runtime-value-control-tree`; `.4.3.6` owns final
  helper/value no-drift.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.4` adds copied Julia hash helper/receiver dispatch, pure
  merge/pick/drop/rename/set-key transformations, statement-only named typed set-key mutation, direct hash-index
  assignment integration, base/overlay-aware merge resolution, and explicit flat-style constructor splicing.
  Ordinary map values stay nested. At that leaf package status was `runtime-hash-helpers`; `.4.3.5` has since
  added value/control/block/callback execution.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.3` adds a copied Julia array helper/receiver dispatcher,
  string/regex split and filter bridges, explicit flatten/constructor-splice semantics, numeric reducer terminals,
  typed split replacement, and isolated statement-only end mutation for named and scalar-held arrays.
  Value-position end methods return `nothing` without mutation. At that leaf package status was
  `runtime-array-helpers`; `.4.3.4` has since added hashes.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.2` adds a canonical Julia runtime pure-helper dispatcher.
  Current string/scalar transforms, predicates, regex operations, coalescing, definedness/emptiness, explicit
  lexical comparisons, numeric arithmetic/unary/reducers/comparisons, aliases and symbol callees, JSON-number
  normalization, and compatible fluent chains now share one execution path. Package status is
  `runtime-string-numeric`; `.4.3.3` owns array-aware helper and mutation behavior.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.1` extends the Julia interpreter with its portable core value
  model. `_RuntimeExecutionContext` now owns scalar, array, and hash stores; the evaluator preserves JSON-safe
  shapes through typed/bare snapshots, literals, assignment, append, hash-index mutation, indexed/nested reads,
  and final checked no-autovivification nested writes. Entry/local capture helpers now expose names, maps,
  character spans, and line-column positions. At that leaf package status was `runtime-core-values`; `.4.3.2` has
  since advanced it to `runtime-string-numeric`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.0` splits the Julia helper/value runtime container before
  broader evaluator code. `.4.3.1` owns core JSON-shaped values, stores, assignments/access, snapshots, and
  `entry_*` / `match_*` capture helpers; `.4.3.2` owns string/numeric helpers; `.4.3.3` arrays; `.4.3.4` hashes;
  `.4.3.5` value/control/block/callback execution; `.4.3.6` final no-drift. The split mirrors the proven Dart
  rollout and changes no Julia runtime behavior.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.2` adds the first Julia compiled-rule interpreter.
  `julia/src/runtime/Interpreter.jl` defines `LinkedSpecRuntimeEngine`, `runtime_parse(...)`,
  `runtime_execute(...)`, `RuntimeParseResult`, `RuntimeLifecycleEvent`, and `RuntimeInterpreterException`.
  It executes default/AND/OR/repetition modes, action and blind-call children, `I/LS/LE/IT/EX/LX/E` lifecycle
  order, `retv`, explicit returns, narrow array accumulators/capture reads, seek/consume matching, bounded and
  zero-progress termination, and same-rule/slot/cursor recursion cutoffs. Its initial evaluator was deliberately
  dispatch-facing; `.4.3.1` has since added the core value/store/capture model.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.1` adds Julia runtime regex matching and match-state tracking.
  `julia/src/runtime/Matching.jl` defines seek/consume parse modes, compiled regex alternatives with stable
  zero-based identity, complete and compact capture projections, named captures, zero-based code-unit spans,
  public character offsets, line/column projection, cursor/capture anchors, separate entry/local match registers,
  and zero-width/zero-progress predicates. Julia's native PCRE integration accepts the currently required named
  capture, POSIX, flag, possessive, and recursive constructs directly, so this leaf needs no dialect-rewrite layer.
  First executable rule dispatch has since landed in `JULIA-BACKEND-PARITY.4.2`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.3.4` adds Julia compiled-spec state.
  `julia/src/compiler/CompiledSpec.jl` defines `compile_spec(...)`, `CompiledSpec`, `CompiledRule`,
  `CompiledRuleModeMetadata`, `DependencyRef`, action/blind edge records, `CompiledActionPayload`,
  `CompiledDependencyRegexState`, `CompiledDependencyRegexEntry`, and `CompiledDescriptorState`. The compiler reuses
  `validate_spec(...)` by default, records ordered rule/last-definition metadata, derives dependency-regex rows,
  parses lifecycle/action payloads into `ActionBlock` ASTs, resolves payload contracts with the user-function
  registry, carries function registry projection, and emits descriptor-shaped JSON with `julia_interpreter_rule`
  handlers marked `compiled_state_only`. Runtime regex matching has since landed in `JULIA-BACKEND-PARITY.4.1`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.3.3` adds the Julia user-function registry seam.
  `julia/src/action/FunctionRegistry.jl` defines `UserFunctionRegistry`, `UserFunctionEntry`, and
  `UserFunctionCallResolution`, builds ordered entries from `SpecFile.functions`, exposes staged
  `body_parse_job` records, preserves `body_payload` and optional `body_ast`, rejects duplicate names, and provides
  `stitch_function_body_ast(...)` for immutable staged body-AST replacement. `julia/src/action/ActionContracts.jl`
  now accepts `function_registry=...` so exact-arity registered calls classify as `user_function` before helper
  fallback, while wrong-arity registered calls diagnose as `user_function_arity_mismatch`. Function bodies are not
  executed yet. Compiled-spec state has since landed in `JULIA-BACKEND-PARITY.3.4`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.3.2` adds Julia ActionIR contract resolution.
  `julia/src/action/ActionContracts.jl` exposes `resolve_action_block_contracts(...)`,
  `resolve_action_statement_contracts(...)`, `resolve_action_expression_contracts(...)`,
  `canonical_action_helper_name(...)`, and `is_known_action_ir_call_name(...)`. The resolver walks typed
  ActionIR calls, receiver methods, structural assignments, structured controls, nested arguments, block values,
  shape literals, and access expressions, recording JSON-shaped contract and diagnostic records. Unknown
  helper-looking calls diagnose generically as `unknown_helper`, and `raw_perl` fallback nodes remain explicit
  diagnostics. `julia/src/spec/Validator.jl` now shares the resolver's current helper/control name predicate for
  user-function collision checks. Function-registry-aware exact-arity user-call classification, compiled state,
  and runtime execution remain later Julia leaves. Function-registry-aware classification has since landed in
  `JULIA-BACKEND-PARITY.3.3`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.3.1` adds Julia typed ActionIR parsing.
  `julia/src/action/ActionAst.jl` defines action blocks, value-drop statements, call/argument nodes, literals,
  variables, indexed/nested access, shape literals, assignments, receiver chains, trailing block payloads, block
  values, structured controls, and raw fallback nodes with JSON projection. `julia/src/action/ActionParser.jl`
  exposes `parse_action_block(...)`, `parse_action_statement(...)`, and `parse_action_expression(...)`. The parser
  is structural only; canonical helper-contract resolution has since landed in `JULIA-BACKEND-PARITY.3.2`, while
  compilation, runtime execution, staged body dispatch, diagnostics/trace, and corpus execution remain later Julia
  leaves.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.2.4` adds Julia function-definition shell projection.
  `julia/src/spec/UserFunctionDefinitionShell.jl` consumes `function_definition` / `function_definition_error`
  nodes shaped by `specs/user_function_definition.spec`, validates source/body spans and staged sidecars,
  normalizes `functions.<index>.body_source` parse-job paths, strips function-definition spans before rule parsing,
  and keeps direct `parse_spec(...)` rule-only. Typed helper/action AST parsing has since landed in
  `JULIA-BACKEND-PARITY.3.1`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.2.3` adds Julia frontend validation.
  `julia/src/spec/Validator.jl` exposes `validate_spec(spec; strict_syntax=false)` and
  `SpecValidationException`, checking top-rule presence, duplicate labels/functions, user-function registry shape,
  raw fallback lines, mixed edge families, grouped action blocks, undefined references, regex-slot bounds, regex
  structure, and strict unused-rule behavior. Tests validate all checked-in specs and rule-only corpus specs.
  Top-level `fn` shell projection has since landed in `JULIA-BACKEND-PARITY.2.4`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.2.2` adds Julia source parsing.
  `julia/src/spec/Parser.jl` exposes `parse_spec(source)` and `SpecParseException`, producing the `.2.1` source AST
  types for rule headers/modes, regex slots, lifecycle blocks, action/blind-call edges, fluent continuations,
  markers, comments, and block boundaries. Tests parse all 21 checked-in `specs/*.spec` files and rule-only corpus
  specs. Frontend validation has since landed in `JULIA-BACKEND-PARITY.2.3`; top-level `fn` shells remain
  rule-only for direct `parse_spec(...)`, with spec-shaped projection added in `JULIA-BACKEND-PARITY.2.4`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.2.1` adds Julia source AST/data types.
  `julia/src/spec/Ast.jl` defines data records and JSON projection for spec files, function definitions, source
  spans, staged parse jobs, rule headers/modes, body element variants, edge targets, and fluent calls. The field
  names mirror the Rust/Dart/mdBook source contract (`functions`, `rules`, `source_span`, `body_span`,
  `body_parse_job`, `line_start`, `line_end`, `parent_ast_path`, `result_policy`, `failure_policy`). This is still
  the data contract; parser behavior has since landed in `JULIA-BACKEND-PARITY.2.2`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.1.3` adds Julia corpus manifest IO.
  `julia/src/corpus/CorpusManifest.jl` now uses JSON3 to parse `manifest.json` and expected JSON, validates format
  `1`, case count, case names, duplicates, missing/stale fixture directories, required fixture files, and expected
  JSON syntax over the checked-in 99-fixture corpus. The Julia CLI/corpus runner report the validated fixture count
  in non-execute mode, and `--execute` still returns not implemented. The `.1` foundation container is closed; the
  source AST/data boundary has since landed in `JULIA-BACKEND-PARITY.2.1`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.1.2` creates the minimal Julia backend package scaffold.
  `julia/` now contains `Project.toml`, committed `Manifest.toml`, `src/LinkedSpecJulia.jl`, CLI/corpus modules,
  `bin/linkedspec_julia.jl`, `bin/corpus_runner.jl`, README commands, and a Julia `Test` smoke suite.
  `Pkg.instantiate()`, `Pkg.test()`, Julia CLI help/status, and corpus-runner scaffold commands pass with
  `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot`. At that leaf the scaffold intentionally had no `.spec`
  parser, manifest IO, runtime interpreter, or corpus execution semantics; manifest IO has since landed in `.1.3`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.1.1` completes Julia toolchain/package-layout preflight.
  The local backend toolchain is Homebrew-managed Julia 1.12.6 at `/opt/homebrew/bin/julia`, matching the official
  current stable release. `Pkg` and `Test` are usable with a writable Julia depot; the managed harness should set
  `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot` or equivalent when the default `~/.julia` depot is not
  writable. The planned repo-owned scaffold is `julia/` with `Project.toml`, `src/LinkedSpecJulia.jl`, CLI/corpus/
  spec/action/compiler/runtime subtrees, `bin/linkedspec_julia.jl`, `bin/corpus_runner.jl`, and `test/runtests.jl`.
  `JuliaFormatter` and `JET` are absent global optional tools. That planned scaffold has since landed in `.1.2`;
  no Julia parser semantics exist yet.
- `2026-07-09` refresh: `FUTURE-PARITY-BACKLOG.1.2` creates `docs/tasks/JULIA-BACKEND-PARITY.md` as the
  dedicated Julia backend plan. Julia follows Dart in the ADR `0021` rollout and starts interpreter-first:
  package/toolchain preflight, typed `.spec` frontend, typed helper/action AST, compiled state, runtime
  interpreter, staged user-function execution, diagnostics/trace, corpus parity, and mdBook/live-doc closeout.
  Generated Julia source is a later proof decision, not the initial gate. At creation time, the next frontier was
  `JULIA-BACKEND-PARITY.1.1` for toolchain/package-layout and variant-specific CLI preflight.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.7.5` closes the scoped Dart interpreter-first milestone.
  Dart now has a repo-owned package, typed frontend and ActionIR layers, compiled-spec state, runtime
  interpreter, staged user-function execution, diagnostics/trace controls, focused local verification,
  variant-specific CLI productization, and 99/99 corpus execution. Generated Dart source remains deferred to a
  future split source-emitter proof lane. No active Dart frontier remains; future backend rollout returns to
  `FUTURE-PARITY-BACKLOG.1.2` for Julia planning.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.7.4` productizes the Dart-specific LinkedSpec CLI.
  `dart/bin/linkedspec_dart.dart` now owns help text plus a `corpus` command that validates or executes the
  manifest-backed corpus through the Dart parser, compiler, and runtime. `dart/bin/corpus_runner.dart` remains a
  compatibility wrapper over the same command implementation. `.7.5` has since closed the Dart scoped
  interpreter-first milestone.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.7.1` closes Dart mdBook usage/status/handoff documentation.
  The book now names `bash tools/run_dart_local.sh`, opt-in `LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh`,
  direct `dart test`, and full corpus-runner execution as the Dart command surface. Current Dart parity is
  interpreter-first and 99/99 corpus-green; `.7.2` has since deferred generated Dart source to a future split
  source-emitter lane, Dart-specific CLI productization has since closed in `.7.4`, and `.7.5` has closed the
  scoped milestone.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.7.2` deliberately defers generated Dart source implementation.
  A future Dart source-emitter proof must be split like the Rust source-emitter lane: scaffold/compile-run harness,
  generated family-plan metadata, direct structural-family execution, and curated manifest-backed corpus subset.
  The current Dart conformance gate remains the interpreter-first 99/99 corpus run; the frontier later advanced
  through `.7.4`, and `.7.5` closed the scoped milestone.
- `2026-07-09` refresh: `BACKTRACK-SURFACE-RUST-ALIGNMENT` defines the current cross-variant cursor-control
  surface. Perl, Rust, and Dart expose `save_cursor()` / `restore_cursor()` for explicit cursor-stack semantics,
  `rewind_match_start()` / `rewind_entry_start()` for direct local-match or entry/initial-match anchor rewinds, and
  `capture_until_boundary(rule[, ...])` for non-consuming structural boundary capture. The old `BACKTRACK()` /
  `IBACKTRACK()` names and lowercase `backtrack(label)` / `ibacktrack(label)` forms are not current portable API.
  `specs/ebnf.spec` uses `capture_until_boundary(semantic_annotation, grammar_rule)` so semantic annotation bodies
  stop before the next annotation or grammar rule without consuming that boundary.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.4` first extended Dart runtime cursor semantics in
  `dart/lib/src/runtime/interpreter.dart` and `dart/lib/src/runtime/matching.dart`. That slice landed local
  cursor rewinds and char-based cursor/input helpers such as `cursor_pos`, `cursor_rest`, `input_slice`, and
  `input_end_pos`. `BACKTRACK-SURFACE-RUST-ALIGNMENT.1` has since renamed the current portable surface to
  `save_cursor()` / `restore_cursor()` and `rewind_match_start()` / `rewind_entry_start()`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.6` closed the Dart helper/value no-drift slice in
  `dart/lib/src/runtime/interpreter.dart`. Nested value-path assignment now matches the Perl/Rust contract:
  successful writes return the updated root aggregate, missing or wrong intermediate paths return `null` without
  mutation, final hash keys may be created, final array writes only replace or append exactly at `len`, and missing
  intermediate containers are not autovivified. Segment index expressions evaluate before the RHS value expression,
  matching the Rust/Perl lowering order. Direct hash-index assignment on scalar-held map/list roots now preserves
  root ownership before named hash fallback. Later Dart slices closed cursor-control alignment, diagnostics/trace,
  full corpus parity, local verification wiring, and mdBook usage/status documentation.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.5` extended Dart runtime ActionIR execution in
  `dart/lib/src/runtime/interpreter.dart`. `LinkedSpecRuntimeEngine` now evaluates expression-valued blocks with
  block-local `return(...)` / `return_undef()`, attached `if` / `elseif` / `else` and `when` / `otherwise`
  branch chains, attached `switch` / `case` / `default`, attached `while` with the deterministic iteration guard,
  inline lazy `if(...)` / `switch(...)`, helper-form `with(value) { ... }` / `with() { ... }`, receiver
  `.with() { ... }`, and hash/array `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver callbacks.
  Callback frames scope and restore `value`, `path`, `depth`, hash `key`, array `index`, and reduce-only `acc`;
  hash traversal is sorted-key depth-first and array traversal is zero-based depth-first. This fed the `.4.3.6`
  helper/value no-drift closeout, which has since landed.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.7.3` recorded the director directive that each LinkedSpec backend
  variant should have a distinct CLI. This was a planning/documentation slice: Dart's backend-local corpus CLI
  was closed by `DART-BACKEND-PARITY.7.4`, and the scoped Dart milestone by `.7.5`. The later Julia `.7.3.0` audit
  proves this interface is not yet equivalent to Perl's parser CLI; exact cross-variant CLI repair is now active.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.4` extended Dart runtime hash helper execution in
  `dart/lib/src/runtime/interpreter.dart`. The evaluator now has hash-aware helper argument evaluation, bare hash
  working-variable receiver reads, pure hash receiver chains, key/value views, sorted key/value arrays, key
  predicates, `merge_hash`, `set_key`, `rename_key`, `drop_keys`, `pick_keys`, `flat_hash`, statement-form
  `set_key(...)` mutation, direct hash-index assignment values, and explicit flat-style hash splicing inside
  `hash(...)`. Later Dart slices landed `.4.3.5`, BACKTRACK/cursor controls, tracing, corpus output parity, and
  local verification wiring, mdBook usage/status documentation, and per-variant CLI productization in `.7.4`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.3` extended Dart runtime array helper execution in
  `dart/lib/src/runtime/interpreter.dart`. The evaluator now has array-aware helper argument evaluation, bare array
  working-variable receiver reads, pure array receiver chains, regex split/filter bridges, delimiter-first
  `join_values`, `flat_array` / `concat_arrays`, `split_tagged_records`, terminal array numeric reducers, and
  statement-only array end mutations. Later Dart slices landed hash helpers, value-block/control/tree traversal
  helpers, BACKTRACK/cursor controls, tracing, corpus output parity, and local verification wiring.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.2` extended Dart runtime helper execution in
  `dart/lib/src/runtime/interpreter.dart`. `LinkedSpecRuntimeEngine` now canonicalizes ActionIR helper names and
  executes current string/scalar helpers, explicit `str_*` lexical comparisons, numeric arithmetic/reducer/
  comparison helpers, numeric word aliases, arithmetic/comparison symbol callees, and compatible string/number
  receiver chains. Later Dart slices landed array/hash helpers, value-block/control/tree traversal helpers,
  BACKTRACK/cursor controls, tracing, corpus output parity, and local verification wiring.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.1` extended Dart runtime core values and capture reads in
  `dart/lib/src/runtime/interpreter.dart`. The interpreter now preserves scalar, array, hash, null, boolean, and
  number shapes through assignment and wrapper snapshots; supports `hash(...)`, `set(hash(...), ...)`, hash-index
  mutation, nested reads, non-numeric map indexing, aggregate `copy(...)`, and the named/map/length/start/end
  `entry_*` / `match_*` helper family. Later Dart slices landed the broader helper families, value-block/control
  and tree traversal helpers, BACKTRACK/cursor controls, tracing, corpus output parity, and local verification
  wiring.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.0` split the Dart runtime helper/value work before code.
  The first resulting frontier was `.4.3.1` for core runtime value/store behavior and capture helper reads,
  followed by string/number helpers, array helpers, hash helpers, value-block/control/tree traversal helpers, and
  a helper/value no-drift closeout before BACKTRACK work.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.2` added Dart's first runtime rule interpreter in
  `dart/lib/src/runtime/interpreter.dart`. `LinkedSpecRuntimeEngine` executes `CompiledSpec` rules over the
  `.4.1` matching layer and returns `RuntimeParseResult` with top-rule value, Rust-style one-element output,
  cursor offsets, and lifecycle events. It now covers default/AND/OR/repetition dispatch, action-edge and
  blind-call child execution, entry/local match handoff, explicit `return(...)` / `return_undef()`, `retv`,
  accumulator collection, bounded repetition, zero-progress cutoffs, and recursion cutoffs. Later Dart slices
  landed helper-family value semantics, BACKTRACK/cursor controls, diagnostics/tracing, corpus output parity, and
  local verification wiring.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.1` added Dart runtime regex/match-state primitives in
  `dart/lib/src/runtime/matching.dart`. `RuntimeRegexAlternation` consumes ordered compiled-rule regex lists and
  supports seek/consume matching with stable alternative identity. `RuntimeRegexMatch` records captures, named
  captures, code-unit spans, char offsets, line/column projection, and zero-progress helpers. `RuntimeMatchRegisters`
  keeps entry and local match registers separate for child dispatch and tracks cursor state. Rule dispatch
  landed on top of this state in `DART-BACKEND-PARITY.4.2`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.3.4` added Dart compiled-spec state in
  `dart/lib/src/compiler/compiled_spec.dart`. `compileSpec(...)` validates source ASTs by default, builds ordered
  `CompiledSpec` / `CompiledRule` state, carries `UserFunctionRegistry`, preserves rule redefinition metadata when
  validation is deliberately skipped, records mode metadata, regexes, dependency refs, edge and lifecycle ActionIR
  payloads, derives structured `CompiledDependencyRegexState`, and projects `CompiledDescriptorState` as
  `spec` / `functions` / `dependency_regex_map` / `meta`. Runtime match-state and interpreter execution now begin
  at `DART-BACKEND-PARITY.4.1`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.3.3` added Dart user-function registry infrastructure in
  `dart/lib/src/action/function_registry.dart`. `UserFunctionRegistry` preserves ordered `FunctionDefinition`
  records, staged `body_parse_job` records, `body_payload`, optional `body_ast`, params/arity, and source/body
  spans. `action_contracts.dart` can now resolve exact-arity user calls as `user_function` before helper fallback
  when passed a registry, and wrong-arity registered calls produce user-function arity diagnostics. Compiled-spec
  state remains `DART-BACKEND-PARITY.3.4`.
- `2026-07-09` refresh: `NONCURRENT-HELPER-CODE-PURGE.5` closed the final no-drift audit for retired helper
  spellings in active Perl/Rust code/test/tool/spec surfaces. Exact retired-helper call-shape, label/tag, and
  `?concat:` scans are clean. The last active Rust runtime unit-test fixture that still used retired helper-call
  strings for generic unknown-helper coverage now uses invented unknown names instead. `NONCURRENT-HELPER-CODE-PURGE`
  is complete; the next PNT frontier is `DART-BACKEND-PARITY.3.3`.
- `2026-07-09` refresh: `NONCURRENT-HELPER-CODE-PURGE.4` migrated active tests, tooling examples, generated Rust
  oracle corpus inputs, and checked-in `.spec` labels/source strings away from retired helper spellings. Generic
  unknown-helper regressions now use invented helper names. `ebnf.spec` and copied corpus inputs use
  `return_scalar_value` / `return_array_value`; `portmap.spec` and oracle/book examples use `?concatenation:` for
  concatenation nodes. Final no-drift closeout is `NONCURRENT-HELPER-CODE-PURGE.5`.
- `2026-07-09` refresh: `NONCURRENT-HELPER-CODE-PURGE.3` removed Rust source recognition and name-specific
  diagnostic paths for the retired `SPEC-FORMAT-TERSE.8` helper spelling set. `linkedspec-core` no longer lists
  retired helper spellings as known ActionIR calls and no longer preserves `declare(...)` keyword-argument syntax
  for retired-helper diagnostics. `linkedspec-runtime` no longer has a `retired_helper_error(...)` branch ahead of
  generic helper dispatch; retired helper-looking calls now use the generic unknown-helper fallback. Runtime context
  internals use neutral append/snapshot names, and Rust hash-literal display emits current `{ key : value }`
  syntax. `NONCURRENT-HELPER-CODE-PURGE.4` later closed active test/tool/generated fixture and checked-in `.spec`
  migration.
- `2026-07-09` refresh: `NONCURRENT-HELPER-CODE-PURGE.2.4` closed the Perl source purge container for the
  retired `SPEC-FORMAT-TERSE.8` helper spelling set. Focused exact call-shape scans over `perl/LinkedSpec.pm`
  and `perl/LinkedSpec` are clean for retired helper recognition paths; remaining exact-name hits are raw-compat
  comments or ordinary implementation words, not helper-call source branches. Current `cat(...)`, `copy(...)`,
  `set(...)`, and `push(...)` lowering still works, while retired value-position helper-looking calls such as
  `concat(...)`, `a(...)`, and `scalaref(...)` lower through the same generic unsupported-helper sentinel path as
  invented unknown helpers. `NONCURRENT-HELPER-CODE-PURGE.3` owns the next Rust source cleanup.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.3.2` added Dart ActionIR contract resolution in
  `dart/lib/src/action/action_contracts.dart`. `resolveActionBlockContracts(...)`,
  `resolveActionStatementContracts(...)`, and `resolveActionExpressionContracts(...)` walk typed ActionIR
  calls, receiver methods, structural assignments, structured controls, nested arguments, block values,
  shapes, and access expressions, then record current canonical helper/control contracts or generic
  diagnostics. `dart/lib/src/validation/spec_validator.dart` now shares the current helper/control name
  table through `isKnownActionIrCallName(...)` for function-name collision checks. Function registry
  construction later landed in `.3.3`, and compiled-spec state landed in `.3.4`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.3.1` added the Dart ActionIR AST parser.
  `dart/lib/src/action/action_ast.dart` defines typed action blocks, statements, expressions, arguments,
  access segments, literals, assignments, receiver chains, block values, and structured-control nodes.
  `dart/lib/src/action/action_parser.dart` exposes `parseActionBlock(...)`, `parseActionStatement(...)`,
  and `parseActionExpression(...)`. The parser covers calls, positional/keyword arguments, primitive and
  regex literals, variables, indexed/nested access, array/hash literals, scalar/array/hash/nested assignments,
  expression-valued blocks, attached `if`/`when`/`elseif`/`else`/`otherwise`, `while`, `switch`/`case`/`default`,
  receiver-dot fluent chains, trailing block arguments, standalone value-drop statements, and structural
  `raw_perl` fallback for unsupported expressions.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.2.4` closed the Dart frontend container by
  adding `dart/lib/src/parser/user_function_definition_shell.dart`. Dart now consumes the
  `function_definition` / `function_definition_error` nodes returned by `specs/user_function_definition.spec`,
  validates source/body spans and staged `body_payload` / `body_parse_job` sidecars, normalizes source-order
  parent paths and deterministic parse-job ids, strips returned definition spans before rule parsing, and
  attaches ordered `FunctionDefinition` records. This is intentionally not a raw `fn` source scanner; later corpus
  execution obtains the spec-returned AST nodes by running `specs/user_function_definition.spec` through Dart
  runtime shell code before projecting staged function bodies.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.2.3` added Dart frontend validation in
  `dart/lib/src/validation/spec_validator.dart`. `validateSpec(...)` now checks top-rule presence,
  duplicate labels/functions, function registry collisions/parameters, raw malformed body lines, mixed edge
  families, grouped action targets without shared blocks, undefined targets, regex-slot index ranges, and
  lightweight regex structural errors; `strictSyntax: true` adds unused-rule rejection. Validation is still
  source-AST only. Helper/action compilation and runtime semantics remain later lanes.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.2.2` added the Dart core `.spec` rule parser in
  `dart/lib/src/parser/spec_parser.dart`. `parseSpec(...)` now produces the source AST for rule
  paragraphs, headers/modes, header-rest body elements, regex literals, lifecycle blocks, action and
  blind-call edges, fluent continuations, split/conditional markers, comments, raw fallback lines, and
  nested block boundaries. Tests cover focused Rust parser parity seams, all checked-in `specs/*.spec`,
  and rule-only corpus `input.spec` files. Strict validation remains `.2.3`; top-level function-shell
  extraction/staging remains `.2.4`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.2.1` added Dart source-level AST/data types in
  `dart/lib/src/ast/spec_ast.dart`. The types mirror the Rust parsed-AST and staged parse-job field names:
  `SpecFile`, `FunctionDefinition`, `SourceSpan`, `StagedParseJob`, `Rule`, `RuleHeader`, `RuleMode`,
  body element variants, `EdgeTarget`, and `FluentCall` all round-trip through JSON. This is still data-only;
  parser code starts in `.2.2`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.1.3` added Dart corpus manifest IO scaffolding.
  `dart/lib/src/corpus/manifest_runner.dart` now loads `manifest.json`, validates format/case-count/case
  name shape, detects missing and stale fixture directories, requires `input.spec` / `input.txt` /
  `expected.json`, parses expected JSON, and reports the 99 checked-in fixtures without executing parser
  semantics. The `.1` toolchain/workspace/foundation container is closed; next frontier is `.2.1` AST/data types.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.1.2` created the repo-owned Dart package scaffold
  under `dart/`. The package has `pubspec.yaml`, committed `pubspec.lock`, analyzer options, README,
  public library entrypoint, CLI smoke entrypoint, corpus-runner entrypoint, and a `package:test`
  smoke test. `.dart_tool/` and build outputs are ignored. This is scaffold only: manifest IO starts
  in `.1.3`, and parser/compiler/runtime semantics remain later leaves.
- `2026-07-09` refresh: `FUTURE-PARITY-BACKLOG.1.1` scoped the Dart lane into
  `docs/tasks/DART-BACKEND-PARITY.md`. Dart parity starts interpreter-first: `.spec` parser, typed
  helper/action AST, compiled-spec state, Dart runtime interpreter, then manifest-backed corpus parity.
  Generated Dart source was later deferred by `DART-BACKEND-PARITY.7.2`, not made the primary gate. No
  backend implementation code changed in this scoping slice.
- `2026-07-09` refresh: `FUTURE-PARITY-BACKLOG.0` created the active future parity backlog and ADR
  `0021` accepted Lua as a scheduled future backend target. Future full-parity backend rollout is now Dart
  first, Julia second, and Lua third, all under the same `.spec`, text-to-AST, staged parsing, runtime,
  diagnostics, and corpus parity contracts as Perl5 and Rust. No parser/runtime/backend code changed in this
  tracking slice.
- `2026-07-08` refresh: `ROADMAP-DRIFT-RECONCILE.2` refreshed the dated status/count layer after
  the terse-format and Rust-oracle follow-ons; `SPEC-FORMAT-TERSE.12.2` later raised the phase0 lock count with
  the Perl hash-tree traversal regression, `.12.3` raised the Rust oracle with hash-tree traversal parity, `.12.4`
  closed docs/KM/live no-drift alignment for that hash-tree traversal lane, `SPEC-FORMAT-TERSE.13.3` added
  Rust/oracle parity for array-tree traversal receiver blocks, `.13.4` closed the array-tree docs/KM/live
  no-drift alignment, `.13.5` reconciled the parent terse-format task tree closed, and
  `SPEC-SOURCE-TERSE-CLOSEOUT.1` completed the root-spec source-format closeout. The Rust variant now has a
  green 99-fixture
  manifest-backed interpreter oracle with missing/stale fixture drift guards. The generated Rust-source path
  emits a module with embedded `CompiledSpec`, validated generated-family plan, and `parse(input)` entry point;
  it directly executes every currently supported structural family (`Default`, OR/AND acode, AND/OR bcode, and
  the four explicit REP subfamilies) and is proven by an all-family compile/run matrix plus a curated
  manifest-backed corpus subset. The full 99-fixture corpus remains the interpreter oracle gate;
  generated-source corpus coverage is intentionally a subset until a future leaf broadens it. Current phase0 is
  `PASS 1..1028` over 21 shipped `.spec` files with `PERL5LIB=` cleared after the non-consuming boundary helper
  regression landed.
- `2026-07-04` refresh: RUST-PARITY follow-on closed. The Rust variant then had a green 88-fixture
  manifest-backed interpreter oracle with missing/stale fixture drift guards, and the generated Rust-source path
  emitted the first validated generated-family module/corpus proof.
- `2026-06-14` refresh: COMPAT-ALIAS-RETIREMENT-V2.2 removed 5 legacy return helpers (return_a, return_m, return_ma, return_imatch, return_im) from all 7 implementation files. LIFECYCLE-FAMILY-AUDIT tree completed — all 7 lifecycle markers verified. ROADMAP-V2-TRACKER-SYNC tree completed — trackers synchronized. DOC-BOOK-SYNC tree active for documentation/book sync.
- `2026-06-13` refresh: MEDIUM-IMPACT task tree substantially advanced. HandlerVariantEmitter now has structured HandlerIR (10 variant builders → IR hashrefs → dispatched emitter templates), a backend dispatch table (`%BACKEND_EMITTERS` with `perl` default), and a JSON/AST diagnostic backend (`_emit_handler_json` via `JSON::PP`). Validation.pm fuzzing harness (`t/phase0_validation_fuzz.t`) covers 5 surfaces with 168+ combinatorial cases across rule labels, edge scanning, and DSL syntax. BootstrapSpec.pm now has dual-path parse: `_build_spec_spec_parser()` lazily builds spec.spec parser via bootstrap seed and caches it; `run_bootstrap_parse()` runs spec.spec alongside bootstrap as a diagnostic side channel (bootstrap always primary; recursion guard active). Cross-check at 2/20 exact match (tablegrep, verilog); remaining 18 specs tracked in .3.4 parity gap. AND handler MIXED_ACTIONS conflict resolved (.3.4.4): RuleIR routes AND I-blocks to `and_icode_entries`, EmitContext processes them, HandlerVariantEmitter prepends assignment for result capture. Comment/blank-line skip in Runtime.pm wrapper. RuntimeContext reusable via populated scalar-slot contract.
- `2026-06-04` refresh: removed two stale references that still presented the deleted `perl/LinkedSpec/ActionRewriter.pm` module as a live owner-dispatch participant. That module was deleted in Phase 1 (`PHASE1-PARSER-CORE-ISOLATION.2`, commit `4f8e0b6`); the focused helper-rewrite compatibility entrypoint now lives solely in `LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat(...)`, reachable through the façade helper `LinkedSpec::call_spec_handler_subst(...)`.
- Scope of this snapshot:
  - `perl/LinkedSpec.pm`
  - the main owner modules it dispatches into
  - the ActionIR lowering subtree
  - the current legacy plugin/runtime branch
  - current Rust variant architecture (`rust/` workspace, interpreter oracle, generated-source emitter)
  - new: `LinkedSpec::HandlerVariantEmitter` (HandlerIR + backend dispatch + JSON/AST backend)
  - new: `t/phase0_validation_fuzz.t` (Validation.pm systematic fuzzing harness, 5 surfaces)
  - new: `tools/cross_check_spec_parsers.pl` (oracle vs candidate cross-check harness)

## Maintenance Policy
- Treat this as a live document, not a one-off memo.
- Refresh it at the start of a new session when the current architectural reading has changed materially or when a new deep codebase pass produces a better model.
- Update it when package ownership, major runtime boundaries, compile/lowering seams, or strategic judgments shift.
- Keep it aligned with:
  - `README.md` for discoverability,
  - `ROADMAP.md` for execution direction,
  - `DEVELOPMENT_NOTES.md` for rationale,
  - `MEMORY.md` for interruption-safe continuity.

## Executive Summary
- `perl/LinkedSpec.pm` is now a deliberately thin lazy facade rather than the real implementation center.
- Its static import tree is intentionally shallow; the real architecture is the lazy owner tree it dispatches into.
- In practice that static tree is now almost just `File::Basename` plus `LinkedSpec::OwnerDispatch`; even the public trace globals are simple aliases into `LinkedSpec::Trace`.
- `LinkedSpec::OwnerDispatch` is now the small shared seam for thin-wrapper lazy loading, callback/value lookup, and delegated owner calls.
- `LinkedSpec::OwnerDispatch` now also anchors lazy owner loading to an absolute repo `perl` path at module load time, so later `chdir(...)` does not strand the file-oriented parser/runtime owner tree on stale relative `@INC` entries.
- `Runtime`, `BootstrapSpec`, and `ParserFactory` no longer keep one-shot local `OwnerDispatch` callback-loader or `$@`-preservation wrappers either; the live compile/bootstrap/parser-factory orchestration bodies now spend the shared seam directly where those pass-through helpers were the only consumer.
- `Runtime` no longer keeps a one-shot runtime-owner generated-handler label wrapper either; fallback diagnostics ask `RuntimeContext` for selected top-rule handler-source labels directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a one-shot generated-handler label wrapper either; parser-factory fallback diagnostics ask `RuntimeContext` for selected top-rule handler-source labels directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot top-rule generated-handler label wrapper either; top-rule-only fallback diagnostics ask `RuntimeContext` for selected top-rule handler-source labels directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot rule-or-top generated-handler label wrapper either; rule-attributed diagnostics ask `RuntimeContext` for concrete-rule-or-selected-top-rule handler-source labels directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot parser-source flush wrapper either; final parser-source output asks `RuntimeContext` to flush captured parser-source text directly through the owner-dispatch seam.
- `Compiler` no longer keeps one-shot runtime-context last-error read wrappers either; parser invocation asks `RuntimeContext` for last-error type/detail reads directly through the owner-dispatch seam when preserving deeper runtime-handler context.
- `Compiler` no longer keeps a one-shot runtime-context top-rule setter wrapper either; selected-top-rule writes ask `RuntimeContext` to update shared top-rule state directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot runtime-context top-rule reader wrapper either; parser-source emission, final descriptor tracing, parser-ready trace metadata, and parser closure capture ask `RuntimeContext` for selected top-rule state directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot runtime-context last-error clear wrapper either; operation-boundary and parser-invocation stale-error cleanup asks `RuntimeContext` to clear `last_error` directly through the owner-dispatch seam.
- `Compiler` no longer keeps a parser-source emission pass-through wrapper either; parser-source line emission asks `RuntimeContext` to append captured source text directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot low-level rule-table runtime-context preparation wrapper either; `build_compiled_rule_table(...)` now inlines its small `top_rule` selection before asking `RuntimeContext` to prepare shared rule-table state.
- `Compiler` no longer keeps a one-shot validation callback availability wrapper either; `run_get_pipeline(...)` checks `Validation::validate_spec_content(...)` availability directly through the owner-dispatch seam.
- `Compiler` no longer keeps a Trace loader wrapper either; its trace helper bodies load `LinkedSpec::Trace` directly through the owner-dispatch seam.
- `Compiler` no longer keeps a pass-through compiler-pipeline last-error setter wrapper either; compiler error boundaries ask `RuntimeContext` to write structured error state directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot active dependency-regex rule-label reader wrapper either; final-descriptor failure attribution reads that active label directly at the diagnostic boundary.
- `Compiler` no longer keeps a one-shot active dependency-regex rule-label clearer wrapper either; dependency-regex boundaries reset that transient diagnostic label directly.
- `Compiler` no longer keeps a scalar-position reset wrapper either; `run_get_pipeline(...)` resets the spec-content scalar position directly at validation and bootstrap-parse boundaries.
- `Compiler` no longer keeps a first parsed-rule label wrapper either; rule-table preparation and final top-rule selection derive the first label directly at each decision point.
- `Compiler` no longer keeps a one-shot final-descriptor error-detail normalizer wrapper either; that trapped error detail is normalized directly at the structured last-error write.
- `Compiler` no longer keeps a one-shot parser-input ref describer wrapper either; top-level parser invocation builds invalid-input diagnostics directly at the runtime-parser last-error write.
- `Compiler` no longer keeps a one-shot bootstrap-parse result detail wrapper either; invalid intermediate-representation diagnostics are built directly at the structured last-error write.
- `Compiler` no longer keeps a one-shot rule-table failure-detail reader wrapper either; the pipeline fallback reads retained rule-table failure detail directly.
- `Compiler` no longer keeps a one-shot rule-table failure-detail clearer wrapper either; rule-table and pipeline boundaries reset retained failure detail directly.
- `Compiler` no longer keeps a one-shot rule-table failure-detail setter wrapper either; rule-table failure sites write retained failure detail directly.
- `Compiler` no longer keeps a one-shot rule-table entries-result describer wrapper either; invalid parsed-entry-list diagnostics are built directly at the rule-table boundary.
- `Compiler` no longer keeps a one-shot rule-table entry-result describer wrapper either; invalid per-entry diagnostics are built directly at the rule-table boundary.
- `Compiler` no longer keeps a one-shot compile-spec-entry tuple describer wrapper either; invalid tuple diagnostics are built directly at the rule-table boundary.
- `Compiler` no longer keeps a one-shot final-descriptor state-result describer wrapper either; invalid descriptor-state diagnostics are built directly at the final descriptor boundary.
- `Compiler` no longer keeps a one-shot final-descriptor dependency-regex describer wrapper either; invalid normalization diagnostics are built directly inside the CompilerState callback.
- `Compiler` no longer keeps a one-shot dependency-regex map spec-result describer wrapper either; invalid compiled-spec input diagnostics are built directly inside the CompilerState callback.
- `Compiler` no longer keeps a one-shot dependency-regex map rule-info describer wrapper either; invalid rule-info diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map `dependency_refs` describer wrapper either; invalid dependency-list diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency-ref describer wrapper either; invalid dependency-ref diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency-label describer wrapper either; invalid dependency-label diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency-index describer wrapper either; invalid dependency-index diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map missing-rule describer wrapper either; missing dependency-rule diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency-rule-info describer wrapper either; invalid referenced dependency-rule info diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency regex-list describer wrapper either; invalid referenced regex-list diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a compiled-spec state constructor pass-through wrapper either; rule-table build asks `CompilerState` for new state directly through the shared owner seam.
- `Compiler` no longer keeps a compiled-spec state predicate pass-through wrapper either; compiler-pipeline validation asks `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps a compiled-spec rule-count pass-through wrapper either; trace and parser-generation counts ask `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps the unused compiled-spec rules-by-label pass-through wrapper either; rules-by-label map access stays owned by `CompilerState` without a compiler-local mirror.
- `Compiler` no longer keeps a compiled-spec has-rule pass-through wrapper either; dependency-regex validation asks `CompilerState` directly whether referenced dependency rules exist.
- `Compiler` no longer keeps a compiled-spec rule-info pass-through wrapper either; dependency-regex validation retrieves referenced dependency-rule metadata directly from `CompilerState`.
- `Compiler` no longer keeps the unused compiled-rule-order pass-through wrapper either; compiled-rule ordering remains a `CompilerState` concern without a compiler-local mirror.
- `Compiler` no longer keeps a compiled-spec rule-rows pass-through wrapper either; dependency-regex map iteration asks `CompilerState` directly for compiled rule rows.
- `Compiler` no longer keeps a compiled-spec definition-order pass-through wrapper either; compiled-state trace output asks `CompilerState` directly for definition order.
- `Compiler` no longer keeps a compiled-spec redefined-labels pass-through wrapper either; compiled-state trace reporting asks `CompilerState` directly for redefined rule labels.
- `Compiler` no longer keeps a compiled-spec legacy projection pass-through wrapper either; legacy spec-hash projection asks `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps a compiled-spec record-rule pass-through wrapper either; rule-table construction records compiled rules by asking `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps a compiled descriptor legacy projection pass-through wrapper either; final descriptor projection asks `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps the unused `_build_final_descriptor(...)` legacy projection helper either; the active path builds descriptor state with `_build_final_descriptor_state(...)` and projects through `CompilerState` at the boundary that needs the compatibility descriptor.
- `Compiler` no longer keeps a compiled-descriptor metadata pass-through wrapper either; final-descriptor assembly asks `CompilerState` to build descriptor metadata directly through the shared owner seam.
- `Compiler` now uses full `final_descriptor` local naming and `FINAL_DESCRIPTOR` trace banners on the active path instead of compressed `final_descr` wording.
- `Compiler` no longer keeps a compiled dependency-regex state constructor pass-through wrapper either; dependency-regex enrichment asks `CompilerState` to construct the state directly through the shared owner seam.
- `Compiler` no longer keeps a compiled descriptor state constructor pass-through wrapper either; final descriptor assembly asks `CompilerState` to construct the state directly through the shared owner seam.
- `Compiler` no longer keeps a compiled descriptor state predicate pass-through wrapper either; final descriptor assembly asks `CompilerState` to validate the state shape directly through the shared owner seam.
- `Compiler` no longer keeps the unused compiled descriptor metadata pass-through wrapper either; descriptor metadata reads stay owned by `CompilerState` without a compiler-local mirror.
- `SpecEntry` no longer keeps a one-shot runtime-context top-rule setter wrapper either; discovered top-rule writes ask `RuntimeContext` to update shared top-rule state directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a parser-source emission pass-through wrapper either; generated-handler source emission asks `RuntimeContext` to append captured source text directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a pass-through runtime-handler last-error setter wrapper either; rule-handler compile/eval errors ask `RuntimeContext` to write runtime-handler error state directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a one-shot runtime-context dependency-reader wrapper either; `compile_spec_entry(...)` reads the optional `runtime_ctx` dependency inline beside RuleIR setup.
- `SpecEntry` no longer keeps a one-shot RuleIR callback availability wrapper either; `compile_spec_entry(...)` checks `RuleIR::_collect_rule_ir(...)` availability directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a one-shot emit-context callback availability wrapper either; `compile_spec_entry(...)` checks `RuleIR::EmitContext::build_rule_ir_emit_context(...)` availability directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a Trace loader wrapper either; its trace wrapper bodies load `LinkedSpec::Trace` directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a one-shot runtime-context preparation wrapper either; `run_get_parser(...)` asks `RuntimeContext` to prepare file-oriented parser state directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a one-shot runtime-context spec-path setter wrapper either; resolved-spec-path writes ask `RuntimeContext` to update shared file identity directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a pass-through preserve-existing last-error setter wrapper either; compile-stage fallback writes ask `RuntimeContext` to preserve deeper compile errors directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a pass-through direct last-error setter wrapper either; setup, validation, resolution, and load errors ask `RuntimeContext` to write parser-factory error state directly through the owner-dispatch seam.
- `Runtime` no longer keeps a one-shot runtime-context preparation wrapper either; `run_get(...)` asks `RuntimeContext` to prepare inline runtime state directly through the owner-dispatch seam.
- `Runtime` no longer keeps an unused direct last-error setter wrapper either; runtime-owner fallback writes stay on the preserve-existing `last_error` path.
- `Runtime` no longer keeps a pass-through preserve-existing last-error setter wrapper either; fallback writes ask `RuntimeContext` to preserve deeper error state directly through the owner-dispatch seam.
- `Runtime` no longer keeps a one-shot compiler callback-loader wrapper either; `run_get(...)` resolves `Compiler::run_get_pipeline(...)` directly through the owner-dispatch seam.
- `Compiler` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still `_require_runtime_ctx(...)` and `run_get_pipeline(...)`, and those now validate the required runtime/pipeline dependencies inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::ValueExpr` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the value-expression lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::FlowExpr` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the flow-expression lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::ControlFlow` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the control-flow lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::MethodLowering` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the method/value/assignment/return lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::DeclareMethod` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the declare/assign lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ParserFactory` no longer keeps second top-level dependency-validator wrappers either; its meaningful local setup seam is still `run_get_parser(...)`, and that setup path now validates the required trace/resolve/compile callbacks plus trace-level values inline instead of bouncing through separate `_require_dep(...)` or `_require_value_dep(...)` subdefs.
- `PPlugin` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local compatibility seam is still `_load_legacy_registry(...)`, and that loader now validates the required parser/discovery/registry callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `Resolver` no longer keeps local Trace-loader or `$@`-preservation wrappers either; its live trace helper bodies now spend `OwnerDispatch` directly in the same way `Validation` already did.
- `ActionIR::Scanner` no longer keeps local callback-loader or `$@`-preservation wrappers either; its live owner helper bodies now spend `OwnerDispatch` directly while still keeping `_require_scanner_core_pkg(...)` as the meaningful local scanner-core seam.
- `Compiler`, `SpecEntry`, and `RuleIR` no longer keep generic package-loader wrappers either; their Trace / `Data::Dumper` / `LinkedRE` helper seams now spend `OwnerDispatch::require_pkg(...)` directly instead of bouncing through a local `_require_pkg(...)` pass-through.
- `Compiler` no longer keeps a separate `Data::Dumper` loader wrapper either; its meaningful local dump-formatting seam is still `_dump_value(...)`, and that helper now spends `OwnerDispatch::require_pkg(...)` directly inside its `$@`-preserving body.
- `SpecEntry` no longer keeps a separate `Data::Dumper` loader wrapper either; its meaningful local dump-formatting seam is still `_dump_value(...)`, and that helper now spends `OwnerDispatch::require_pkg(...)` directly inside its `$@`-preserving body.
- `SpecEntry` no longer keeps a one-shot generated-handler label wrapper either; runtime-handler construction now asks `RuntimeContext` for rule-metadata generated-handler source labels through the existing owner-dispatch seam.
- `RuleIR` no longer keeps a separate `Data::Dumper` loader wrapper either; its meaningful local dump-formatting seam is still `_dump_value(...)`, and that helper now spends `OwnerDispatch::require_pkg(...)` directly inside its `$@`-preserving body.
- `Compiler` no longer keeps a separate `LinkedRE` loader wrapper either; its meaningful local regex seam is still `_ored_re(...)`, and that helper now spends `OwnerDispatch::require_pkg(...)` directly inside its `$@`-preserving body.
- `Compiler` and `SpecEntry` no longer keep generic callback-loader wrappers either; their named bootstrap/spec-entry/validation and RuleIR/emit-context helper seams now spend `OwnerDispatch::require_pkg_cb(...)` directly instead of bouncing through a local `_require_pkg_cb(...)` pass-through.
- `BootstrapSpec` no longer keeps a separate bootstrap-core loader wrapper either; its meaningful local bootstrap grammar seam is still `build_bootstrap_spec(...)`, and that helper now spends `OwnerDispatch::require_pkg_cb(...)` directly inside its `$@`-preserving body.
- `RuleIR::EmitContext` no longer keeps a generic package-loader wrapper either; its meaningful local seam is `_actionir_owner_package(...)`, and that owner-key registry now spends `OwnerDispatch::require_pkg(...)` directly instead of bouncing through a second local `_require_pkg(...)` layer.
- `ActionIR::StatementSplit::Core` no longer keeps a generic package-loader wrapper either; its meaningful local seams are the statement-split-mode and `MethodExpr` loader helpers, and both now spend `OwnerDispatch::require_pkg(...)` directly instead of bouncing through a second local `_require_pkg(...)` layer.
- `BootstrapSpec::Core` no longer keeps a separate `LinkedRE` loader wrapper either; its meaningful local bootstrap regex seams are still `_linkedre_or(...)` and `_linkedre_ored_re(...)`, and both now spend `OwnerDispatch::require_pkg(...)` directly inside their `$@`-preserving bodies.
- `BootstrapSpec::Core` no longer keeps a single-use `$@`-preservation wrapper either; its meaningful local seams are still `_linkedre_or(...)` and `_linkedre_ored_re(...)`, and both now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `PluginBridge` no longer keeps a local `$@`-preservation wrapper either; its meaningful compatibility seams are still `_exec_legacy_plugin(...)`, `_get_legacy_plugin(...)`, `_lookup_plugin_name(...)`, and `_dispatch_plugin_name(...)`, and those now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `PluginBridge` no longer keeps a second top-level dependency-validator wrapper either; its meaningful compatibility seams are still `_lookup_plugin_name(...)` and `_dispatch_plugin_name(...)`, and those helpers now validate the required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `Compiler` no longer keeps a local `$@`-preservation wrapper either; its meaningful local seams are still `_dump_value(...)`, `_ored_re(...)`, `_trace_log_output(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_apply_trace_options(...)`, and `_trace_level_name_for_current_verbosity(...)`, and those now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `SpecEntry` no longer keeps a local `$@`-preservation wrapper either; its meaningful local seams are still `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_dump_value(...)`, and `_trace_runtime_mark_event(...)`, and those now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `RuleIR` no longer keeps a local `$@`-preservation wrapper either; its meaningful local trace/dump seams are still `_trace_should_dump(...)`, `_trace_log_output(...)`, `_trace_decision(...)`, `_trace_rule_ir_decision(...)`, and `_dump_value(...)`, and owner delegation now spends `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `RuleIR::EmitContext` no longer keeps a local `$@`-preservation wrapper either; its meaningful local seams are still `_actionir_owner_default_deps(...)`, `_call_actionir_owner(...)`, `_call_actionir_owner_with_deps(...)`, `_accumulate_action_rewrite_diagnostics(...)`, and `rewrite_action_code_for_compat(...)`, and those now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `ActionIR::Contracts` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seam is still `_require_lowering_deps(...)`, and that helper now validates required lowering callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::ScannerCore` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seam is still `_scanner_rule_dep_bindings(...)`, and that helper now validates required scanner callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::StatementSplit` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seam is still `_split_action_ir_statements(...)`, and that helper now validates the required `trim_action_ir_value` callback inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::StatementSplit` no longer keeps a single-use `StatementSplit::Core` loader wrapper either; `_split_action_ir_statements(...)` now lazy-loads the core owner directly through `OwnerDispatch::require_pkg(...)` inside its live `$@`-preserving delegation body.
- `ActionIR::CanonicalEvents` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seam is still `_build_canonical_action_ir_events(...)`, and that helper now validates the required trim/split callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::CanonicalEvents` no longer keeps a single-use `CanonicalEvents::Core` loader wrapper either; `_canonicalize_helper_action_ir_event(...)` now lazy-loads the core owner directly through `OwnerDispatch::require_pkg(...)` inside its live `$@`-preserving delegation body.
- `ActionIR::Diagnostics` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still `_find_unresolved_action_helpers(...)` and `_collect_action_helper_ir_nodes(...)`, and those helpers now validate the required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::RewritePipeline` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still `_build_action_rewrite_rules(...)` and `_rewrite_action_code_with_diagnostics(...)`, and those helpers now validate the required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::ArrayPipeline` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still `_normalize_split_delimiter_expr(...)` and `_build_array_pipeline_plan_from_expr(...)`, and those helpers now validate the required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `BootstrapSpec::Core`, `ActionIR::ScannerCore`, and `LinkedSpec::PluginBridge` no longer keep single-use generic package-loader wrappers either; their remaining LinkedRE, scanner-rule-family, and legacy-`PPlugin` helper seams now spend `OwnerDispatch::require_pkg(...)` directly instead of bouncing through local `_require_pkg(...)` pass-throughs.
- `LinkedSpec.pm` and `LinkedSpec::ParserFactory` no longer keep dead local pass-throughs around that seam; once the active facade/parser-factory paths spent `OwnerDispatch` directly, the shadow `_require_pkg(...)`, `_call_preserving_err(...)`, `_require_pkg_cb(...)`, and `_require_pkg_value(...)` wrappers became removable compatibility debris rather than real architecture.
- The dep-map-only ActionIR owners no longer keep dead local `_require_pkg(...)` or `_call_preserving_err(...)` wrappers around that seam either; once `default_deps_for_package(...)` moved to `OwnerDispatch::build_dep_map(...)`, those local pass-through bodies stopped being part of the real lowering path.
- `Runtime`, `BootstrapSpec`, and `ActionIR::Scanner` no longer keep dead local package-loader wrappers either, and `RuleIR::EmitContext` no longer keeps a dead local Trace-loader wrapper; the active runtime/bootstrap/scanner/emit-context paths now make their remaining callback-loader and owner-registry seams explicit instead of keeping zero-call helper shadows around them.
- `Trace`, `Validation`, `ActionIR::CanonicalEvents`, and `ActionIR::StatementSplit` now also spend `OwnerDispatch` directly inside their live helper bodies instead of keeping one-shot local wrappers for a single Data::Dumper/Trace/core-owner load or `$@`-preservation call.
- Delegated owner calls now resolve their target callbacks through the same `OwnerDispatch::require_pkg_cb(...)` loader path used by dependency maps and thin wrappers, so `dispatch_owner_call(...)` no longer carries a second symbol-call route internally.
- Thin wrapper callback lookup now routes through that seam for `Runtime`, `Compiler`, `BootstrapSpec`, `SpecEntry`, `ActionIR::Scanner`, and `RuleIR::EmitContext`'s ActionIR owner dispatch; direct callback probing is reserved for `OwnerDispatch` itself.
- `LinkedSpec::OwnerDispatch` now also owns shared dependency-map assembly for active ActionIR owners and a mixed callback/value bundle builder for the parser-factory path, so owner-side dependency wiring is centralizing instead of drifting back into local registries.
- `LinkedSpec::PluginBridge` now also spends that same owner-dispatch seam for its default compatibility plumbing: lazy `PPlugin` loading, registered-plugin lookup through `PluginRegistry`, successful `$@` preservation, and default callback-map assembly no longer require bridge-local eval/restore branches or a hand-built dependency hash.
- The former Perl-only legacy domain-utility owners and the `.plg` plugin corpus are no longer part of the active `perl/` tree; two retirement passes resolved them, and `t/phase0_regression.t` is green (`PASS 1..1028`) without any of them.
  - **Deleted** (`LEGACY-VHDL-RETIRE`, the Perl-only non-portable VHDL/RTL/FSM-generation subsystem with no Rust/Dart/Julia/Lua counterpart): `RTLUtils`, `FSMGen`, `VHDL::ConstantEval`, and the six `.plg` files that depended exclusively on them (`fsmgen`/`lte_digital_rf`/`mbist`/`msword`/`regtest`/`rtl`). The stale `generic_fake_memory_module.plg` / `wrapgen.plg` / `get_log2`->`ceil_log2` prose carried here described files already deleted earlier; it is gone with the subsystem.
  - **Relocated to `noncore/`** (`NONCORE-QUARANTINE`, proven unreachable from the `LinkedSpec.pm` union shipped-`specs/*.spec` closure): the remaining non-core domain owners — `HTTP::FileAccess`, `HTML::PathLinks`, `InteractivePrompt`, `Text::VariableSubstitution`, `MSOffice::Excel`, `QC::Flow`, `QC::Summary`, `QC::TclInterconn`, `Table::GenericFilter`, `Timing::SetupHold`, `Timing::StanBackend`, `Timing::StanOmap2430cBackend` (plus the flat domain `.pm`) — and the 13 surviving `.plg`, all `git mv`'d into `noncore/` with layout preserved (`noncore/README.md` is the parked-fate ledger). The root `plugin/` directory no longer exists; `perl/` is now core-only.
- A fresh 2026-04-11 bootstrap pass confirmed that the recent compiler naming cleanup is now on the active facade/compiler path: `LinkedSpec.pm` exposes `build_compiled_rule_table(...)`, `Compiler.pm` / `CompilerState.pm` speak in terms of compiled-spec / compiled dependency-regex / compiled-descriptor state, and the former bootstrap-local `spec_descr` / `gdata` vocabulary has now been renamed to rule-descriptor / dispatch-state terminology.
- The legacy `ActionRewriter` compatibility module has now been deleted entirely (Phase 1 / `PHASE1-PARSER-CORE-ISOLATION.2`): it had become a pure forwarding shim over `RuleIR::EmitContext`, so the focused helper-rewrite compatibility entrypoint now lives solely in `LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat(...)` and there is no separate `ActionRewriter` surface to keep thin.
- The practical core path is:
  - `ParserFactory -> Runtime -> Compiler`
- The frontend syntax/bootstrapping truth still concentrates in:
  - `BootstrapSpec::Core`
  - `Validation`
- Rule compilation and emitted runtime behavior still concentrate in:
  - `SpecEntry`
  - `RuleIR`
  - `RuleIR::EmitContext`
- Backend-neutral action semantics now largely live in:
  - `LinkedSpec::ActionIR::*`
- `RuntimeContext` is one of the cleanest and most important boundaries in the tree.
- `Compiler.pm` now also has one explicit internal compiled-spec state model, so descriptor assembly no longer treats loose parallel compiled-rule-table / `build_dependency_regex_map` hashes as its own source of truth.
- Dynamic plugin loading is still present in the public facade, but current project direction treats it as legacy-removal territory rather than a feature family to preserve.
- The Rust variant's production path is still an interpreter over `CompiledSpec`/`CompiledRule`, but it is now
  parity-tested through a checked-in 99-fixture oracle corpus generated from the Perl reference and guarded against
  manifest drift.
- The Rust generated-source path is no longer just a scaffold: `linkedspec_runtime::source_emitter` emits
  compilable Rust modules with a generated family plan, and the plan-aware executor directly handles every current
  non-REP and REP structural family. Its corpus proof is deliberately curated rather than exhaustive.

## LinkedSpec Facade Reading
`perl/LinkedSpec.pm` does almost no real work itself. Its main roles are:

- expose the public API,
- lazily load owner modules,
- preserve `$@` across owner dispatch through `LinkedSpec::OwnerDispatch`,
- no longer carry dead local `_require_pkg(...)` / `_call_preserving_err(...)` pass-through helpers now that the shared owner-dispatch seam is the real implementation,
- normalize flat option pairs,
- re-export trace-oriented globals from `LinkedSpec::Trace`.

Its direct static imports are intentionally narrow:
- `File::Basename` at `BEGIN` time for local path setup,
- `LinkedSpec::OwnerDispatch` for shared lazy owner dispatch.

That means the important import tree is the runtime owner tree, not the `use` list in `LinkedSpec.pm` itself.

The facade surface currently falls into four bands.

### Trace Surface
- `configure_trace`
- `trace_enter`
- `trace_exit`
- `trace_decision`
- `log_output`
- `log_dump`
- `should_dump`

### Compile/Runtime Surface
- `Get`
- `build_compiled_rule_table`
- `call_spec_handler_subst`
- `get_parser`

### Registry Maintenance Surface
- `register_plugin`
- `register_plugins`
- `clear_registered_plugins`

### Legacy Transition Surface
- `run_plugin`
- `get_plugin`
- `dispatch_plugin_autoload_name`
- `AUTOLOAD`

The important conclusion is that `LinkedSpec.pm` should be read as a facade and routing layer, not as the place where most semantics live anymore.

One supporting detail matters now: the repeated thin-wrapper plumbing for lazy package loading, callback/value lookup, delegated owner calls, and `$@` preservation is no longer reimplemented separately in each owner. `LinkedSpec.pm`, `LinkedSpec::Trace`, `Runtime.pm`, `ParserFactory.pm`, `BootstrapSpec.pm`, `BootstrapSpec::Core`, `Compiler.pm`, `SpecEntry.pm`, `RuleIR.pm`, `RuleIR::EmitContext.pm`, `Resolver.pm`, and `Validation.pm` now share that seam through `LinkedSpec::OwnerDispatch` (the former `ActionRewriter.pm` listed here was deleted in Phase 1), and the same seam is now also being spent inside active ActionIR owners such as `LinkedSpec::ActionIR::RewritePipeline`, `LinkedSpec::ActionIR::Scanner`, `LinkedSpec::ActionIR::ScannerCore`, `LinkedSpec::ActionIR::StatementSplit`, `LinkedSpec::ActionIR::StatementSplit::Core`, `LinkedSpec::ActionIR::CanonicalEvents`, `LinkedSpec::ActionIR::Diagnostics`, `LinkedSpec::ActionIR::ValueExpr`, `LinkedSpec::ActionIR::FlowExpr`, `LinkedSpec::ActionIR::ArrayPipeline`, `LinkedSpec::ActionIR::ControlFlow`, `LinkedSpec::ActionIR::Contracts`, `LinkedSpec::ActionIR::MethodLowering`, and `LinkedSpec::ActionIR::DeclareMethod`.
One more concrete consequence of that shift is now visible on the parser-factory path too: `ParserFactory.pm` no longer hand-builds its mixed trace/resolve/compile callback plus trace-verbosity value bundle locally, because `LinkedSpec::OwnerDispatch` now owns a shared mixed dependency-bundle builder for that active compile-path surface.

## Current Owner Tree
The current practical owner tree is:

```text
LinkedSpec
├─ LinkedSpec::OwnerDispatch
├─ LinkedSpec::Trace
├─ LinkedSpec::Runtime
│  ├─ LinkedSpec::RuntimeContext
│  └─ LinkedSpec::Compiler
│     ├─ LinkedSpec::Trace
│     ├─ LinkedRE
│     ├─ LinkedSpec::BootstrapSpec
│     │  └─ LinkedSpec::BootstrapSpec::Core
│     │     └─ LinkedRE
│     ├─ LinkedSpec::SpecEntry
│     │  ├─ LinkedSpec::RuleIR
│     │  ├─ LinkedSpec::RuleIR::EmitContext
│     │  │  ├─ LinkedSpec::ActionIR::RewritePipeline
│     │  │  ├─ LinkedSpec::ActionIR::MethodExpr
│     │  │  ├─ LinkedSpec::ActionIR::Scanner
│     │  │  │  └─ LinkedSpec::ActionIR::ScannerCore
│     │  │  │     ├─ Scanner::PrimitiveBasicRules
│     │  │  │     ├─ Scanner::PrimitivePipelineRules
│     │  │  │     ├─ Scanner::FlowRules
│     │  │  │     └─ Scanner::LegacyRules
│     │  │  ├─ LinkedSpec::ActionIR::CanonicalEvents
│     │  │  │  └─ CanonicalEvents::Core
│     │  │  ├─ LinkedSpec::ActionIR::Diagnostics
│     │  │  ├─ LinkedSpec::ActionIR::StatementSplit
│     │  │  │  └─ StatementSplit::Core
│     │  │  │     └─ StatementSplit::Mode
│     │  │  ├─ LinkedSpec::ActionIR::Contracts
│     │  │  ├─ LinkedSpec::ActionIR::FlowExpr
│     │  │  ├─ LinkedSpec::ActionIR::ArrayPipeline
│     │  │  ├─ LinkedSpec::ActionIR::ControlFlow
│     │  │  ├─ LinkedSpec::ActionIR::MethodLowering
│     │  │  ├─ LinkedSpec::ActionIR::DeclareMethod
│     │  │  ├─ LinkedSpec::ActionIR::ValueExpr
│     │  │  └─ LinkedSpec::Trace
│     │  ├─ LinkedSpec::Trace
│     │  └─ LinkedSpec::RuntimeContext
│     ├─ LinkedSpec::Validation
│     ├─ LinkedSpec::CompilerState
│     └─ LinkedSpec::RuntimeContext
├─ LinkedSpec::ParserFactory
│  ├─ LinkedSpec::RuntimeContext
│  ├─ LinkedSpec::Trace
│  ├─ LinkedSpec::Resolver
│  └─ LinkedSpec::Runtime
├─ LinkedSpec::PluginRegistry
└─ LinkedSpec::PluginBridge
   ├─ LinkedSpec::PluginRegistry
   └─ PPlugin
      └─ LinkedSpec
Project/domain utility owners - removed from core (`perl/` is now core-only)
  - Deleted   (LEGACY-VHDL-RETIRE):  RTLUtils, FSMGen, VHDL::ConstantEval
  - Relocated (NONCORE-QUARANTINE):  HTTP::FileAccess, HTML::PathLinks, InteractivePrompt,
                                     Text::VariableSubstitution, MSOffice::Excel, QC::Flow,
                                     QC::Summary, QC::TclInterconn, Table::GenericFilter,
                                     Timing::SetupHold, Timing::StanBackend,
                                     Timing::StanOmap2430cBackend (+ the flat domain .pm)
                                     -> noncore/  (parked-fate ledger: noncore/README.md)
```

## What the Main Owners Do
### `LinkedSpec::Trace`
- owns trace state, indentation, formatting, verbosity, and output routing,
- lazily uses `Data::Dumper` only when needed,
- now also owns richer trace rendering such as mark-position pointer excerpts.

### `LinkedSpec::Runtime`
- owns the small orchestration layer around the compile pipeline,
- builds or normalizes runtime context,
- delegates into `Compiler`,
- writes fallback runtime-owner errors only when deeper owners did not already write a structured failure.

### `LinkedSpec::RuntimeContext`
- owns shared runtime state and structured error payload helpers,
- owns parser-source chunk capture and capture-reset helpers,
- normalizes `runtime_ctx_ref` for direct hashrefs plus scalar slots, including reuse after a scalar slot already contains the shared context hashref,
- carries `spec_name`, `spec_path`, `top_rule`, and `last_error`,
- now clears stale `last_error` during `run_get(...)`, `get_parser(...)`, and low-level rule-table preparation so reused contexts begin each boundary with a failure-only diagnostics channel,
- now also keeps `last_error` more self-contained by copying the known `top_rule` into the structured payload alongside `spec_name` and `spec_path`,
- now also owns top-rule generated-handler source-label construction for runtime/parser-factory/compiler diagnostics, including parser-invocation labels that know the selected handler variant,
- now also owns compiler-style rule-or-top generated-handler source-label fallback, where a concrete rule label wins and selected `top_rule` is the fallback,
- now also owns rule-metadata generated-handler source-label construction for `SpecEntry`, including selected handler variants stored in compiled rule metadata,
- now also seeds an explicitly requested `top_rule` during both inline and file-oriented preparation, so earlier parser-factory/compiler failures can still report the caller’s intended entrypoint before final parser selection happens,
- now also owns the paired stale `spec_name` / `spec_path` reset as a distinct helper from `top_rule` selection, so file identity cleanup and selected-entrypoint continuity stay separate,
- now also owns the low-level `build_compiled_rule_table(...)` runtime-context preparation path, so compiler-side rule-table diagnostics no longer hand-normalize `runtime_ctx_ref` or hand-clear stale context identity/parser-source capture state in `Compiler.pm`,
- is now reached through one shared `OwnerDispatch::dispatch_owner_call(...)` delegation shape across the active runtime/compile owners instead of one dispatch style in `ParserFactory.pm` and another in `Runtime.pm` / `Compiler.pm` / `SpecEntry.pm`,
- is one of the cleanest and highest-value seams in the project.

### `LinkedSpec::ParserFactory`
- owns `get_parser(...)`,
- validates the requested spec name,
- resolves the target `.spec`,
- loads file content,
- prepares trace/runtime context,
- now assembles its default trace/resolve/compile callback dependencies plus trace dump-level values through one shared `OwnerDispatch` bundle helper instead of another owner-local registry,
- no longer keeps dead local `_require_pkg(...)`, `_require_pkg_cb(...)`, or `_require_pkg_value(...)` pass-through wrappers around that now-shared dependency/owner-dispatch path,
- delegates actual compilation to the runtime/compiler path.

### `LinkedSpec::Resolver`
- is the real owner of named spec lookup,
- resolves direct paths first,
- tries module-relative spec paths next,
- falls back to `PathSearch` last.

This module, not the plugin branch, is the real home of the "ask for `foo`, get `foo.spec`" behavior.

### `LinkedSpec::Compiler`
- is the main compile pipeline coordinator,
- owns validation/bootstrap/descriptor-build orchestration,
- now treats `_require_runtime_ctx(...)` and `run_get_pipeline(...)` as its direct runtime/pipeline dependency-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them,
- now coordinates one explicit internal compiled-state model first and treats that as the source of truth for later descriptor assembly,
- now emits the outward descriptor `{ spec => ..., dependency_regex_map => ... }` at the outer boundary, but that is now a projection of the compiled-spec state rather than the compiler's own working model,
- carries much of the compile-stage structured-diagnostics normalization,
- is one of the project's main implementation centers.

One concrete architectural consequence matters now:

- `build_compiled_rule_table(...)` is now the active low-level seam and still exposes the historical rule-label => info hash by default,
- but internally it first builds a `compiled_spec_state` record with:
  - `definition_order`
  - `compiled_rule_order`
  - `rules_by_label`
  - `redefined_rule_labels`
- default `build_dependency_regex_map(...)` now consumes that state directly and, on the active path, first builds an explicit internal `compiled_dependency_regex_state` record,
- final descriptor assembly now first builds an explicit internal `compiled_descriptor_state` record that composes compiled-spec state plus dependency-regex state, generated-descriptor validation now consumes that state directly, and only then does the compiler project outward `spec` / `dependency_regex_map` hashes while also exposing state-derived metadata such as `meta.descriptor_model`, `meta.definition_order`, `meta.compiled_rule_order`, and `meta.redefined_rule_labels`,
- generated-descriptor validation now also walks that descriptor state directly instead of routing back through the historical legacy `validate_dependency_regex_references(...)` entrypoint, so compatibility descriptor projection is fully deferred until after descriptor-state validation succeeds,
- and descriptor-level migration summary generation now also consumes compiled-spec state directly, so even that metadata no longer needs to bounce back through a legacy spec-hash working model.

That is a real structural improvement, not only a diagnostics tweak:

- the compiler now has one explicit internal state-model owner behind its descriptor model,
- derived dependency regexes now also have one explicit internal state model,
- final descriptor assembly now also has one explicit internal descriptor-state model,
- generated-descriptor validation now also consumes that same descriptor-state model directly on the active path,
- the last legacy compatibility-shape normalization seams for compiled spec and compiled dependency-regex maps now also route through that same owner instead of living as local compiler glue,
- and read-side compiled-state access for definition-order, duplicate-label, and descriptor-to-rule-map reads now also routes through that same owner instead of peeking raw state fields directly,
- while compiled-rule recording during rule-table construction now also routes through that same owner instead of a compiler-local mutation pass-through,
- while ordered compiled-rule iteration now also comes from one owner-provided `rule_rows` view instead of being rebuilt ad hoc from `compiled_rule_order + rules_by_label` in compiler consumers,
- and compiled-spec dependency existence / rule-info lookup now also routes through that same owner instead of direct compiler-side map probing during `build_dependency_regex_map(...)`,
- while compiled-descriptor metadata assembly now also routes through that same owner instead of `Compiler.pm` mutating owner metadata locally,
- and descriptor migration-summary shaping now also routes through that same owner instead of being computed as a large compiler-local reduction over compiled rules,
- ordering is first-class instead of incidental,
- duplicate-label tracking is first-class instead of ad hoc,
- and `build_dependency_regex_map(...)` is now clearly a derived-enrichment phase over compiled-spec state rather than a peer loose hash the compiler happens to juggle beside `spec`, while the outward descriptor now calls that derived payload `dependency_regex_map`.

### `LinkedSpec::CompilerState`
- owns the internal compiled-spec, dependency-regex, and compiled-descriptor state records,
- owns normalization of legacy compatibility hashes into those explicit state records,
- owns the preferred read-side accessors for that state as well,
- owns the preferred ordered-rule iteration view for compiled-spec state as well,
- owns the preferred by-label compiled-rule lookup helpers as well,
- owns compiled-descriptor metadata assembly over compiled-spec state as well,
- owns migration-summary shaping over compiled-spec state as well,
- owns the preferred descriptor-state validation views as well,
- owns validation-friendly shape checks for those records,
- owns projection back to outward `spec` / `dependency_regex_map` hashes,
- is now the one place where the compiler's state model is defined instead of splitting that logic between `Compiler.pm` and `Validation.pm`,
- which means `Compiler.pm` and `Validation.pm` no longer need to carry raw-state field reads, local ordered-rule reconstruction, direct rule-map probing, migration-summary reduction, descriptor-meta mutation, repeated descriptor-validation owner dispatch inside validation loops, descriptor-validation map flattening, or leftover local “accept legacy hash or compiled-state record” conversion seams beside the state owner.

One more boundary is now tighter too:

- malformed compiled dependency-regex-map callback output is rejected directly at final descriptor assembly,
- instead of being allowed to drift into later generated-descriptor validation before the contract problem is identified.

### `LinkedSpec::BootstrapSpec` and `LinkedSpec::BootstrapSpec::Core`
- own the hardcoded bootstrap grammar,
- parse `.spec` syntax before self-hosting is fully realized,
- also carry bootstrap-side parsing/rendering intelligence for method-chain and attached control-flow syntax normalization,
- remain a major syntax and safety hotspot,
- now use explicit `rule_descriptors` and `dispatch_state` naming for bootstrap parser handler plumbing. The old `spec_descr` / `gdata` words should be read as history/compatibility context, not active compiler descriptor/dependency-regex terminology,
- **new in MEDIUM-IMPACT.3.5**: `BootstrapSpec.pm` now has `_build_spec_spec_parser()` which lazily builds the spec.spec-generated parser via the bootstrap seed path (BootstrapSpec::Core → Compiler → spec.spec → parser) and caches the result. `run_bootstrap_parse()` runs the spec.spec parser alongside the bootstrap parser as a **diagnostic side channel** — bootstrap output is always primary for format compatibility. A recursion guard (`$BUILDING_SPEC_SPEC_PARSER` package variable) prevents infinite loop when spec.spec tries to parse itself. The cross-check harness (`tools/cross_check_spec_parsers.pl`) compares oracle (bootstrap) vs candidate (spec.spec) output: currently 2/20 exact match (tablegrep, verilog); remaining 18 specs have inflated candidate counts due to spec.spec `rule_paragraph:AND` handler lacking E-block body collection (MEDIUM-IMPACT.3.4 parity gap).

### `LinkedSpec::Validation`
- is the front-end DSL validation owner (1,368 lines, 30+ subs),
- provides three public entry points that gate the compile pipeline:

  **`validate_spec_content($spec_content, $option)`** — envelope validation:
  - checks the input is a SCALAR ref with non-empty content,
  - verifies the first non-comment/non-blank line starts with a valid rule label,
  - requires at least one top rule (`RuleName::`) as the parser entry point,
  - rejects malformed rule label syntax (extra colons, invalid mode suffixes),

  **`validate_dsl_syntax($spec_content, $option)`** — full paragraph-level validation:
  - parses rule labels (label, colon vs double-colon, mode suffix, RHS),
  - detects duplicate rule definitions,
  - rejects rule definitions inside still-open `{ }` blocks,
  - scans action edges (`->`) and blind-call edges (`=>`) with block-depth tracking,
  - rejects mixed action/blind-call code blocks within a single rule,
  - validates regex literals (`/pattern/`) for Perl compile-ability,
  - validates rule-header RHS start (regex cluster then valid paragraph member content),
  - checks split-marker syntax (`@capture_slice`, `@mark(name)`, etc.),
  - reports unused and undefined rule references,
  - when `strict_syntax => 1` is set, promotes reference warnings to hard errors,

  **`validate_dependency_regex_references($dependency_regex_map, $spec, $option)`** — cross-reference validation:
  - checks every dependency-regex entry references an existing rule,
  - verifies every rule reference targets a valid regex index within the referenced rule's `re` array,
  - validates each rule definition's `dependency_refs` entries have `label` and `idx` keys,

  plus two shared back-end validation entry points:
  - `validate_compiled_descriptor_state($descriptor_state, $option)` — validates compiled descriptor state shape and cross-references via the `CompilerState` validation-view seam,
  - `validate_rule_definition($rule_name, $rule_def)` — validates a single rule's handler field, `re` array, and regex syntax,

- error reporting routes through `_report_dsl_validation_failure` which passes structured `summary`/`detail`/`rule_label` info to the `on_failure` callback and logs via `_trace_log_output`,
- `get_dsl_context($spec_content, $position)` provides line-number/context extraction for error messages,
- `_parse_rule_label_line($line)` is the single rule-label parser used across Validation, Compiler, and BootstrapSpec — it recognizes all supported label forms (`:`, `::`, `:AND+`, `:OR{2,4}`, etc.) and flags invalid modes,
- `_scan_rule_edges_in_fragment($fragment, $start_depth)` is the edge scanner that tracks block depth across `{ }`, `( )`, `[ ]`, string literals, and regex literals while extracting action/blind-call target labels — it powers both same-line validation and cross-line paragraph-member validation,
- for debugging validation failures: look at `_trace_log_output` messages (logged at `DUMP_NONE` for errors, `DUMP_LOW` for warnings), check the `on_failure` callback for structured payloads, and use `get_dsl_context` to correlate line numbers in error messages with source content.

### `LinkedSpec::SpecEntry`
- compiles parsed rule entries into generated runtime handler code,
- still assembles Perl source strings and `eval`s them,
- remains the clearest backend-portability ceiling in the current implementation,
- **new in MEDIUM-IMPACT.1**: handler-variant building is now delegated to `LinkedSpec::HandlerVariantEmitter` which provides:
  - a structured **HandlerIR** (hashref-based AST with `kind`/`label`/`parse_mode`/lifecycle slots / dispatch refs) — each of the 10 variant builders returns an IR node instead of raw Perl source,
  - `_emit_handler($ir, %opts)` dispatches through a `%BACKEND_EMITTERS` table (default: `perl` backend → `_emit_handler_perl`),
  - a JSON/AST diagnostic backend (`_emit_handler_json`) that serializes HandlerIR as canonical pretty-printed JSON via `JSON::PP`, proving backend pluggability,
  - `$BACKEND` package variable + `$deps->{backend}` threading so callers can request alternative backends per compilation.

### `LinkedRE`
- is a small (56-line) regex composition utility living at `perl/LinkedRE.pm`,
- provides two functions: `or(...)` and `oredRE(...)`,
- `oredRE(@regexes)` joins an array of regex references into a single compiled regex via `(?{$pos=N})` position-tracking alternation (`qr/$re0(?{$pos=0})|$re1(?{$pos=1})|.../`),
- `or($stref, $oredRE, $mode_or_parent, $parent_info)` executes the compiled alternation against a scalar ref in seek mode (ungrounded `//gcp`, matches anywhere) or consume mode (`\G`-anchored `//gcp`, contiguously from `pos()`), and returns a match-info hash with `index`, `match`, `match_list`, `match_hash`, and optional `marks`,
- the position-tracking `(?{$pos=N})` embedded in each alternation branch lets callers identify which regex alternative matched via the returned `index` field,
- consumers:
  - `Compiler.pm` (via `_ored_re`): builds compiled regex alternative tables for the dependency-regex map,
  - `SpecEntry.pm`: generates `LinkedRE::or(...)` calls in handler source strings for rule dispatch at runtime,
  - `BootstrapSpec::Core.pm` (via `_linkedre_or` and `_linkedre_ored_re`): uses both functions for bootstrap grammar matching without any `eval`,
- all three consumers load LinkedRE through `OwnerDispatch::require_pkg(...)` rather than direct `use` or local loader wrappers,
- `use re 'eval'` is required for the `(?{...})` embedded code blocks in the compiled regex alternation.

### `LinkedSpec::RuleIR`
- owns rule-level intermediate structure and metadata planning,
- drives handler-variant selection and rule execution metadata.

### `LinkedSpec::RuleIR::EmitContext`
- is the bridge from rule IR into ActionIR scanning and lowering,
- is the main gateway into backend-neutral action rewriting,
- now also centralizes its internal ActionIR owner package registry and owner default-dependency lookup instead of hardwiring those contracts separately across dozens of local wrappers,
- now emits debug-level trace scopes and `emit_context:<phase>:<label>:<decision>` decisions for owner package/callback
  resolution, default dependency bundles, function-registry and bare-symbol-kind injection, top-level rewrite
  fallback/orchestration, and rule emit-context build boundaries while staying lazy for require-only consumers that
  have not loaded `LinkedSpec::Trace`,
- and now treats that owner-key registry plus shared owner dispatcher as the only package/callback-loading seams on the bridge instead of keeping a second layer of owner-specific `_require_*_pkg(...)` shims.

## ActionIR Reading
The ActionIR subtree is now large, but structurally it is much healthier than the older monolithic style.

Current reading:

- `MethodExpr`
  - parses method-like expressions.
- `Scanner` and `ScannerCore`
  - find helper-like and compatibility-like surfaces.
- scanner rule families are split deliberately:
  - `PrimitiveBasicRules`
  - `PrimitivePipelineRules`
  - `FlowRules`
  - `LegacyRules`
- `CanonicalEvents`
  - turns scanned helper hits into canonical event forms.
  - its thin owner wrapper now also uses `LinkedSpec::OwnerDispatch` for lazy loading, callback lookup, and `$@` preservation.
  - now lazy-loads `CanonicalEvents::Core` directly through `LinkedSpec::OwnerDispatch::require_pkg(...)` inside `_canonicalize_helper_action_ir_event(...)` instead of keeping a second single-use core-loader wrapper.
- `Diagnostics`
  - tracks unresolved helpers, readiness, and compatibility-surface telemetry.
  - its thin owner wrapper now also uses `LinkedSpec::OwnerDispatch` for lazy loading, callback lookup, and `$@` preservation.
- `Diagnostics`, `StatementSplit`, `CanonicalEvents`, `ArrayPipeline`, `ControlFlow`, `Contracts`, `RewritePipeline`, and `Scanner`
  - now also assemble their default callback maps through the shared `OwnerDispatch::build_dep_map(...)` seam instead of hand-building those maps inline.
  - dep-map-only owners no longer keep local `_require_pkg_cb(...)` wrapper bodies around that shared seam; `Scanner` still has one because it directly resolves `ScannerCore`.
- `StatementSplit`
  - owns safe statement splitting.
  - now lazy-loads `StatementSplit::Core` directly through `LinkedSpec::OwnerDispatch::require_pkg(...)` inside `_split_action_ir_statements(...)` instead of keeping a second single-use core-loader wrapper.
- `StatementSplit::Core`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy package loading of statement-split helper packages.
- `ScannerCore`
  - now lazy-loads scanner-rule families directly through `LinkedSpec::OwnerDispatch` inside the shared family-registry loop instead of through a single-use local generic package-loader wrapper.
  - now also centralizes the scanner-rule family registry, and the remaining helper rebinding symbols are derived straight from `_scanner_dep_specs()` instead of living in a second hardwired registry.
  - now also centralizes the scanner dependency contract consumed by `Scanner::default_deps_for_package(...)`, so dependency assembly and dependency rebinding both spend that same dep-spec table instead of drifting in parallel.
- `Contracts`
  - is the contract catalog for supported helper surfaces and how they lower.
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
- `FlowExpr`, `ArrayPipeline`, `ControlFlow`, `MethodLowering`, `DeclareMethod`, and `ValueExpr`
  - make up the main lowering families.
- core lowering owners such as `FlowExpr`, `ValueExpr`, `MethodLowering`, and `DeclareMethod` now also assemble their default callback maps through one shared `OwnerDispatch::build_dep_map(...)` helper instead of hand-building those callback registries inline.
  - those dep-map-only lowering owners no longer keep dead local `_require_pkg(...)`, `_call_preserving_err(...)`, or `_require_pkg_cb(...)` wrappers once `build_dep_map(...)` owns dependency callback resolution.
- `FlowExpr`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_looks_like_array_value_expr(...)`, `_looks_like_hash_value_expr(...)`, `_lower_is_empty_expr(...)`, `_lower_defined_target_expr(...)`, and `_lower_flow_composite_expr(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them.
- `ArrayPipeline`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
- `ControlFlow`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_lower_control_flow_value_expr(...)`, `_lower_switch_case_value_expr(...)`, `_normalize_bare_zero_arg_flow_marker_expr(...)`, `_lower_if_flow_statement(...)`, `_lower_elseif_flow_statement(...)`, `_lower_else_flow_statement(...)`, `_lower_endif_flow_statement(...)`, `_expand_flow_branch_action_exprs(...)`, `_parse_method_expr_with_optional_attached_block(...)`, `_lower_flow_branch_single_statement(...)`, `_lower_inline_if_branch_expr(...)`, `_lower_inline_switch_branch_expr(...)`, `_lower_switch_flow_statement(...)`, `_lower_case_flow_statement(...)`, `_lower_default_flow_statement(...)`, `_lower_endcase_flow_statement(...)`, `_lower_endswitch_flow_statement(...)`, `_lower_say_statement(...)`, `_lower_print_statement(...)`, and `_lower_print_each_statement(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them.
- `MethodLowering`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_lower_typed_declare_statement(...)`, `_normalize_method_tag_expr(...)`, `_lower_method_value_expr(...)`, `_lower_return_payload_expr(...)`, `_lower_return_general_statement(...)`, `_lower_assign_statement(...)`, `_lower_regex_subst_statement(...)`, and `_lower_return_undef_statement(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them. The old `push_value(...)` / `push_nonempty(...)` statement-specific seams have since been removed from the current helper surface.
- `DeclareMethod`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_parse_declare_binding_entry(...)`, `_lower_declare_value_expr(...)`, `_lower_declare_initializer_expr(...)`, and `_lower_assign_method_statement(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them. The removed declaration helper statement extractor/lowerer no longer belongs to the active source-owner path.
- `ValueExpr`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_extract_scalar_symbol_name(...)`, `_extract_array_symbol_name(...)`, `_extract_hash_symbol_name(...)`, `_lower_scalar_access_key_expr(...)`, `_split_nested_access_path_segments(...)`, `_lower_nested_access_segment_expr(...)`, `_infer_scalar_container_kind(...)`, `_lower_assignment_source_expr(...)`, and `_strip_literal_delimiters(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them.
- `RewritePipeline`
  - glues the scan, classify, and lower pipeline together.

The important judgment here is:
- the language-neutral `.spec` story does not live in `LinkedSpec.pm`,
- it lives mostly in `RuleIR::EmitContext` and the `ActionIR::*` subtree.

## Legacy Plugin Branch Reading
The current public facade still exposes a plugin/runtime branch, but the architecture direction has shifted.

### `LinkedSpec::PluginRegistry`
- owns the clean explicit in-memory registry surface.

### `LinkedSpec::PluginBridge`
- is the transition bridge,
- checks explicit registration first,
- falls back to legacy behavior only when needed,
- assembles its default dependency callback map through `LinkedSpec::OwnerDispatch::build_dep_map(...)`,
- routes its default registered-plugin lookup and legacy runtime load through `LinkedSpec::OwnerDispatch`,
- spends that legacy runtime load directly inside `_load_legacy_plugin_runtime(...)` instead of through a single-use local generic package-loader wrapper,
- and does not own discovery itself; it is a registry-first dispatch shim over the older `.plg` runtime.

### `PPlugin`
- owns legacy `.plg` discovery,
- reads legacy `.plg` files through explicit file IO rather than global diamond-reader state,
- parses `.plg` files through the `pplugin` parser,
- caches discovered handlers,
- executes them dynamically,
- lazy-loads its default `pplugin` parser callback through `LinkedSpec::OwnerDispatch` rather than a local `require LinkedSpec` branch,
- now also treats `_load_legacy_registry(...)` as its direct parser/discovery/registry dependency-validation seam instead of keeping a second top-level `_require_dep(...)` wrapper above it,
- is treated as an internal compatibility adapter reachable only through the deprecated `LinkedSpec` plugin-bridge stubs; the legacy `.plg` corpus it used to discover has been relocated to `noncore/plugin/`, so the active `perl/` tree no longer ships any `.plg` file for it to load,
- and still closes the remaining lazy compatibility cycle:
  - `LinkedSpec -> PluginBridge -> PPlugin -> LinkedSpec::get_parser('pplugin')`

Current project direction does not treat that branch as a target architecture.

### Retired and quarantined domain owners

The project's former domain-utility owners — the RTL/VHDL/FSM generation helpers, the QC and timing report backends, the HTTP/HTML/text/Office/table helpers — and the legacy `.plg` plugin corpus they came from are **no longer part of the active `perl/` tree**. They were the Perl reference backend's legacy island, not part of the backend-neutral `.spec` contract, and two retirement passes resolved them once `t/phase0_regression.t` confirmed the `.spec` engine has zero functional dependency on any of them:

- **Deleted** (`LEGACY-VHDL-RETIRE`): the Perl-only, non-portable VHDL/RTL/FSM-generation subsystem — `RTLUtils`, `FSMGen`, `VHDL::ConstantEval`, and the six `.plg` files that depended exclusively on them — has no Rust/Dart/Julia/Lua counterpart, so it was removed rather than ported (which also cleared a catastrophic-backtracking regex hang that used to block the regression gate). The earlier `generic_fake_memory_module.plg` / `wrapgen.plg` / `get_log2`->`ceil_log2` prose described files that had already been deleted; it is gone with the subsystem.
- **Relocated to `noncore/`** (`NONCORE-QUARANTINE`): every remaining non-core domain owner — `HTTP::FileAccess`, `HTML::PathLinks`, `InteractivePrompt`, `Text::VariableSubstitution`, `MSOffice::Excel`, `QC::Flow`, `QC::Summary`, `QC::TclInterconn`, `Table::GenericFilter`, `Timing::SetupHold`, `Timing::StanBackend`, `Timing::StanOmap2430cBackend`, plus the flat domain `.pm` — and the 13 surviving `.plg` were `git mv`'d into `noncore/` with layout preserved. `noncore/README.md` is the parked-fate ledger (refactor / port / publish / delete each on its own merits later), and the root `plugin/` directory no longer exists.

The historical narrative — how each helper family graduated out of `.plg` plugin subdefs into a package owner — lived here as a faithful record of the reference backend's plugin-retirement work. That work is now moot: the code itself has left the core. `git log` for `LEGACY-VHDL-RETIRE` and `NONCORE-QUARANTINE` preserves the detail.

The current intended direction is:
- keep deterministic named `.spec` resolution,
- treat dynamic `.plg` loading and plugin execution as legacy-removal territory,
- move executable helper logic into explicit package ownership outside `LinkedSpec::*`,
- keep LinkedSpec focused on parser/spec/runtime responsibilities.

## Strongest Current Boundaries
These are the seams that currently look healthiest and most worth preserving.

### 1. Thin `LinkedSpec.pm` facade
This is good architectural movement. The public entrypoint is no longer trying to own everything itself.

### 2. `ParserFactory -> Runtime -> Compiler`
This is the practical core spine of the system and gives a readable ownership model to parser construction.

### 3. `RuntimeContext`
This is one of the best extractions in the project so far. It reduced drift and made structured diagnostics much more coherent.

### 4. Compiler-owned compiled-spec state
This is now one of the healthiest improvements in the compile path. The compiler no longer has to reason about “legacy spec hash” as its own internal truth; it has one explicit compiled-spec state model and emits legacy compatibility shapes only at the edges.

### 5. ActionIR modularization
The lowering stack is big, but it now has real sub-owners instead of one giant mixed-semantics file.

## Main Hotspots and Risks
### `BootstrapSpec::Core`
- dense syntax hotspot,
- difficult to change safely,
- still central until self-hosting is stronger,
- the former bootstrap-only `spec_descr` / `gdata` vocabulary has been renamed to `rule_descriptors` / `dispatch_state`, so the remaining risk is the density of the bootstrap syntax logic rather than a known active naming island.

### `SpecEntry`
- still relies on generated Perl source plus `eval`,
- strongest backend-portability ceiling,
- still a likely long-term refactor target.

### Public visibility of legacy plugin surface
- `run_plugin`, `get_plugin`, `dispatch_plugin_autoload_name`, and `AUTOLOAD` still sit in `LinkedSpec.pm`,
- even though the project direction now says dynamic plugin loading is not a core target to preserve.

### Remaining compatibility drag
- the broad owner-dispatch cleanup has paid off and Backbone Item 3 is much thinner now than it was,
- but the public plugin compatibility surface still over-advertises a branch the docs already treat as transition/removal machinery,
- and future effort should bias back toward semantic/runtime/self-hosting milestones unless fresh duplication is clearly material.

## Current Strategic Judgments
### 1. LinkedSpec is no longer best understood as a plugin-hosting framework
The clearer core story is:
- named `.spec` lookup,
- parser compilation,
- parser runtime,
- action lowering,
- diagnostics.

Dynamic plugin loading was historically useful, but it is not the architectural center anymore.

### 2. Spec/resource lookup and plugin loading should stay separate in our thinking
The justified behavior to preserve is:
- `get_parser('foo')` should locate `foo.spec` without path burden.

That does not imply that LinkedSpec must keep a dynamic plugin system.

### 3. Future portability still runs through `SpecEntry`
Even with a much stronger ActionIR story, runtime handler generation still bottoms out in emitted Perl and `eval`.

### 4. ActionIR maturity is now more about semantics and architecture than helper count
The helper family is much richer than it used to be. The bigger future wins are now around:
- cleaner semantics,
- lowering discipline,
- validation,
- self-hosting,
- and eventual backend decoupling.

As of the 2026-05-11 phase0 guard, every discovered target `.spec` must compile to descriptor metadata with `language_agnostic_ready_ratio == 1.0000`, no language-agnostic blocked rules, and no compatibility-surface rules. That makes future DSL migration work a matter of preserving the all-target ActionIR-ready contract while improving semantics and architecture.

### 5. `build_compiled_rule_table` / `build_dependency_regex_map` should now be read as phases, not as the ideal long-term data model
The information they represent is still needed. What changed is the ownership model:
- `build_compiled_rule_table(...)` is now best read as "build compiled-spec state",
- `build_dependency_regex_map(...)` is now best read as "build compiled dependency-regex state from compiled-spec state and project the outward dependency_regex_map hash when a caller wants the normal descriptor surface",
- and the legacy hash forms are compatibility outputs rather than the compiler's own preferred representation.

## Suggested Session-Start Refresh Checklist
At the start of a future session, this document should be re-read and adjusted if any of the following changed:

- the public API surface of `LinkedSpec.pm`,
- the practical compile spine,
- the role of `RuntimeContext`,
- the biggest architectural hotspots,
- the status of `SpecEntry` code generation,
- the status of bootstrap/self-hosting,
- the status of the legacy plugin-removal track,
- or the project's own understanding of what LinkedSpec should and should not own.

## Bottom Line
Current best reading:

- `LinkedSpec.pm` is a facade,
- `ParserFactory`, `Runtime`, and `Compiler` are the practical parser-build spine,
- `BootstrapSpec::Core` and `Validation` still define much of the frontend truth,
- `Compiler.pm` now has one explicit compiled-spec state model internally and only emits outward `spec` / `dependency_regex_map` hashes at descriptor boundaries,
- `SpecEntry` remains the biggest portability hotspot, though `HandlerVariantEmitter` now isolates the 10 variant builders into their own module (first step toward HandlerIR and backend pluggability),
- `RuleIR` plus `ActionIR::*` are where backend-neutral action semantics really live,
- `RuntimeContext` is one of the strongest architectural boundaries in the project,
- and the legacy plugin branch should be treated as transition/removal machinery, not as the future identity of LinkedSpec.
