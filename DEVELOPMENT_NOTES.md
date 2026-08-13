# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`

- 2026-08-13 (`INTER-MATCH-GAP-CAPTURE.1.1` — executable-neutral contract): activation base is clean `31f3e664`.
  The checker must remain independently executable through `bash tools/run_python_project_data.sh
  tools/check_inter_match_gap_capture_contract.py`; checker-first absence is an intentional hard failure, not an
  optional fixture state.
- Keep artifact and checker semantic authorities visibly distinct. The artifact is transport-neutral data; the
  checker owns exact schema validation, executable scalar-span/state recomposition, and one reason-checked deep-
  copy corruption for each of the 50 frozen mutation IDs.
- Python decoded-string indexing is used only as the checker oracle after rejecting surrogate code points. That
  makes the three source fixtures an executable Unicode-scalar proof while backend implementations remain free to
  retain byte or UTF-16 registers behind the existing typed-source authority.
- Preserve the rollout boundary: only `neutral_contract` is complete. All six runtime rows, recurrence, and public
  no-drift stay pending; recording planned consumer paths and routing owners does not register or execute them.
- A new `tools/*.py` entrypoint must advance `tools/test_tool_project_data_storage.sh`'s exact census. That census
  is containment coverage, not `.1.2` canonical feature routing; `.1.1` therefore moves 29 → 30 and nothing else.
- Do not infer syntax availability from a current JSON contract. Named declarations, named selectors,
  `entry_slot()`, `@capture_gaps`, and all three gap accessors remain rejected/absent until their implementation
  leaves. `.1.2` adds topology/storage/no-overclaim governance; it must not promote a runtime row.
- The exact RED is exit 1 with `inter-match gap capture contract is missing`. GREEN is 8 positive + 10 negative,
  3 sources, 16 transitions, 10 segmentations, 9 diagnostics, rollout 1/8, and 50 rejected semantic mutations.
- Canonical signoff first caught the exact Python-tool containment census at stale 29 versus new 30. After the
  lock moved to 30, the sandboxed restart reached only the expected outer-harness denial of nested macOS
  `sandbox-exec` at status 71. The unchanged permission-authorized run passes all eight doctrines, six-family
  containment, all-five-anchor relocation, CLI 66/66 twice, RAM 55%, and Phase 0 1,031/1,031 in 737 seconds
  through exact local-CI success. The book passes 79 files / 14,628 KiB and Knowledge 830 / 6,950.

- 2026-08-13 (`INTER-MATCH-GAP-CAPTURE.1.0` — executable-neutral plan): activation base is clean `3d0384d1`.
  Keep `.1.0` behavior-free and make `.1.1` the first artifact/checker mutation.
- Reuse existing authorities. Named slots use pinned Unicode 17 `XID_Continue`; gap spans use immutable same-source
  scalar offsets; gap state joins the existing monotonic invocation/transaction snapshot. Do not add a second
  identifier classifier, cursor, invocation stack, span kind, matcher object, or rollback scope.
- Keep selection provenance explicit: selector kind + authored selector + target rule + current index + nullable
  stable slot id. Numeric/name equivalence at one declaration does not make numeric syntax reorder-stable.
- Keep lifecycle timing exact: select and install candidate before `LS`; expose through edge/target/`LE`; commit
  accepted post-`LE` cursor; clear before `IT`; expose successful terminal tail to existing `LX`/`EX`/`E` path.
  Empty gaps and falsey accepted payloads remain first-class.
- Preserve ADR `0048` return channels: repeated edge return is an accepted per-hit value and finalizes normally;
  default-loop edge return and lifecycle returns keep whole-rule authority, clear candidates on unwind, and do not
  manufacture a commit or tail.
- Preserve compatibility instead of conflating it. Anonymous marker members are not `@capture_gaps` aliases and
  conflict when mixed; named marks and explicit capture helpers remain independent. No forced gap emission exists.
- Neutral artifact path/id/checker, nine rollout legs, consumer files, repository-local routing, mutation families,
  diagnostics, and carrier roles are frozen in the task/ADR/Knowledge/book. Semantic revision requires a new owning
  leaf and ADR amendment before code.
- Focused preflight is green unchanged: duplicate-slot five-backend 59 mutations; typed-source six-runtime 114.
- Preserve the unrelated capability-exclusion closeout marker when condensing the current task index:
  `capability exclusion public closeout .24.2 remains closed` is a required capability no-drift input.
- Preserve the semantic no-drift marker verbatim in both roadmaps too: `128 mutations, rollout 9/9` is a required
  closed-state projection even while the surrounding future-backlog summary advances.
- Canonical signoff first reached only the outer harness's expected nested-`sandbox-exec` denial at representative
  containment. The unchanged permission-authorized retry passes all eight doctrines, six-family containment,
  all-five-anchor relocation, CLI 66/66 twice, RAM 52%, and Phase 0 1,031/1,031 in 735 seconds through exact local-
  CI success. The book passes 79 files / 14,628 KiB and Knowledge passes 830 facts / 6,950 keys. `.1.1` remains the
  next owner after the clean atomic-218 commit; no behavior or rollout moved.

- 2026-08-13 (`FUTURE-PARITY-BACKLOG.14.5.0` — lossless-gap cross-tree handoff): keep this leaf strictly
  behavior-free. Retrieve committed slot, gap, marker, typed-source, and task authorities before archaeology; use
  descriptors and live historical probes rather than inferring semantics from source layout.
- Preserve one implementation owner. `INTER-MATCH-GAP-CAPTURE.1-.7` owns named declarations/selectors,
  `@capture_gaps`, lifecycle/compatibility, prefix/interstitial/tail and empty spans, failure/commit/recursion,
  six runtimes, carriers, and public admission. `.14.5.1` only composes its closed proof into typed source.
- Treat numeric and named selectors as one possible compiled slot type but different authored identities:
  `Rule[N]` follows position across reordering; `Rule[name]` follows the stable declaration name. Retain source
  provenance for diagnostics and migration.
- Do not add `Rule.N` or `Rule.name` aliases. Dot already owns fluent behavior. Likewise, keep the first fluent
  dot mandatory in `-> Rule[name].method(...)`; whitespace-only attachment saves one character while obscuring
  receiver binding, making whitespace significant, and treating the first method differently from later calls.
- A Perl diagnostic spec embedded in `qq{...}` must escape `\@move_pos`; otherwise host interpolation removes
  the marker and creates false cumulative-gap evidence. The corrected live probe returns exact prefix and
  interstitial pairs with target lifecycle output and no automatic tail.
- The unchanged focused gates pass duplicate-slot identity at 59 mutations and typed source at 9/5/114. Land this
  audit cleanly before pivoting to `INTER-MATCH-GAP-CAPTURE.1`.
- The first canonical attempt correctly rejected a bounded MEMORY rewrite that dropped the unrelated closed
  repeated-action next owner `FUTURE-PARITY-BACKLOG.10.1`; restore it and retain the focused 8/10/54 proof.
- The sandboxed restart passes every gate through tool locality and stops only when the outer harness denies the
  nested macOS containment sandbox with status 71. The unchanged permission-authorized run is authoritative: all
  eight doctrines, containment/relocation, CLI 66/66 twice, RAM 68%, and Phase 0 1,031/1,031 in 771 seconds pass
  through exact local-CI success. This is signoff evidence, not behavior movement.

- 2026-08-12 (`FUTURE-PARITY-BACKLOG.14.4.8` — recursive-observation public closeout): preserve the accepted
  14-row rollout. This leaf governs the observation projection independently; it must neither invent a fifteenth
  row nor consume combined program-wide `recurring_public_no_drift` before `.14.8`.
- Treat “public projection” as current documentation plus fail-closed absence proof, not a public API admission.
  Require six exact current markers, reject six stale milestone claims, and scan ten public facade/API/schema
  surfaces for private observation names.
- Write the complete checker-side oracle first. RED must fail only with `recursive-observation public no-drift
  contract is missing`; GREEN must preserve 9 complete / 5 pending and advance mutations from 87 to 114.
- Keep the five exact observation sources, six runtime routes, support ledgers, storage initializer, and CI switch
  unchanged. Focused recomposition passes Perl/Rust/Dart 7 each, Julia 30, Lua 43 per ABI, and all support ledgers.
- Close parent `.14.4` only after the mdBook, capability guide, Toolbox, ADR, Knowledge, both roadmaps, architecture,
  and bounded live layers agree that no helper/value/facade/schema/semantic/MCP/CLI/README/runtime surface moved.
- The fully staged sandboxed canonical run passes every doctrine and executable gate through the task-specific
  matrix, then stops only when the outer harness denies nested macOS `sandbox-exec` at representative containment
  with status 71. The unchanged permission-authorized run passes containment/relocation, CLI 66/66 in both option
  environments, RAM 57%, Phase 0 1,031/1,031 in 713 seconds, and the complete observation matrix through exact
  `[ci] local CI gate passed` with exit 0.

- 2026-08-12 (`FUTURE-PARITY-BACKLOG.14.4.7` — recursive-observation recurrence): keep the existing broad typed-
  source driver and add one narrower observation-only proof; do not create a seventh implementation or oracle.
- Bind five exact consumer sources to six ordered runtime routes. Shared Lua must remain one tracked source run
  independently on PUC Lua and LuaJIT; neutral precedes runtimes and all three support ledgers follow them.
- Lock exact commands, source binding, order, multiplicity, support checks, project-data initialization, outside-
  CWD workflow routing, canonical tracked input, and opt-in registration through independent mutations.
- Promote only `recursive_observation`; leave combined `recurring_public_no_drift` pending for final `.14.8`.
  Current truth is 9/5/87 with no parser/runtime/API/schema/semantic/MCP/CLI/README behavior movement.
- RED is the intentional fail-first proof of the absent recurring gate; GREEN is the same checker and full driver
  passing after implementation. The mdBook now explains these test-first terms explicitly.
- Focused signoff passes Perl/Rust/Dart 7 each, Julia 30, Lua 43 per ABI, all support ledgers, storage locality,
  outside-CWD routing, and the broader six-runtime typed-source gate.
- The staged sandboxed canonical run passes all eight doctrines and every earlier executable gate before the outer
  harness denies nested macOS `sandbox-exec` at representative containment with status 71. The unchanged permission-
  authorized recurrence opt-in passes containment/relocation, CLI 66/66 in both environments, RAM 62%, Phase 0
  1,031/1,031 in 723 seconds, and all six observation routes/support ledgers through exact local-CI success.
- Land atomic 215 cleanly before public closeout `.14.4.8`; final public no-drift remains intentionally pending.

- 2026-08-12 (`FUTURE-PARITY-BACKLOG.14.4.6` — shared Lua recursive observation): parse the exact special form
  into one Lua-5.1-compatible `observe_recognition` node; keep the static rule operand unevaluated, and close the
  existing `binding_write` recognition effect through ordinary rule and user-function call graphs.
- Extend the existing private recognition transaction authority with direct-parent snapshots and fresh rejected-
  attempt reservation. A pending scope intercepts only its intended child and disarms at entry, so later ordinary
  nested recursion retains the existing cutoff.
- Publish a terminal completion only inside an active observation boundary, consume it immediately, and bind the
  recursively detached nine-field harray before returning the unchanged payload or propagating the unchanged typed
  failure. Retain no source text, parser/runtime object, second invocation stack, or parse-wide history.
- Keep cursor, boundary, match, and mark registers in zero-based UTF-8 bytes. Project entry, selected match, and
  accepted exit through the existing private `source_location` authority only when constructing the record.
- Treat an observed action edge as its one child dispatch and retain the existing repeated-action collection
  topology. Native, reconstructed, generated-plan, and independently loaded emitted-source execution all use the
  shared engine; the exact 43-assertion consumer and combined 704-assertion focused set pass on each ABI.
- Add the shared Lua recurring path and CI locks plus one omission mutation. Typed-source proof is 8/6/75 with all
  six runtimes recorded on the pending observation row; recognition stays 129+4/246/58, language stays
  246/105+1/122, repeated-action stays 8 governed seams / 54 mutations, and facade/schema/CLI/README stay closed.
- Complete ordinary Lua and storage 18/3 pass; exact six-runtime typed-source and five-backend repeated-action
  compositions are green. Recurrence `.14.4.7` remains a no-behavior composition leaf and must follow only after
  this admission lands cleanly. Rendered book 79/14,548 KiB, Knowledge 826/6,897, and all eight doctrines pass.
- The first staged canonical run correctly rejects ADR `0056` at 653/640 lines. Preserve every decision while
  compacting recent backend amendments and consequence wrapping to exactly 640 lines; do not raise the reviewed
  cap or weaken the README-policy routed-destination guard.
- The corrected sandboxed canonical restart passes doctrines and every earlier gate, including task-specific Lua
  43/43 per ABI, before the outer harness denies nested macOS `sandbox-exec` at representative containment with
  status 71. The unchanged permission-authorized command then passes containment/relocation, CLI 66/66 in both
  environments, RAM 61%, Phase 0 1,031/1,031 in 734 seconds, and the complete six-runtime typed-source matrix
  through exact `[ci] local CI gate passed` with exit 0.

- 2026-08-12 (`FUTURE-PARITY-BACKLOG.14.4.5` — Julia recursive observation): parse the exact special form into one
  private `ActionObserveRecognitionExpr`; keep the static rule operand unevaluated, and close the existing
  `binding_write` recognition effect through ordinary rule and user-function call graphs.
- Extend the existing `RecognitionInvocationAuthority`, not the public module, with direct-parent snapshots and
  fresh rejected-attempt reservation. A pending scope intercepts only its intended child and disarms at entry, so
  later ordinary nested recursion retains the existing cutoff.
- Publish a terminal completion only inside an active observation boundary, consume it immediately, and bind the
  recursively detached nine-field harray before returning the unchanged payload or propagating the unchanged typed
  failure. Retain no source text, parser/runtime object, second invocation stack, or parse-wide history.
- Keep cursor, boundary, match, and mark registers in zero-based UTF-8 code units. Project entry, selected match,
  and accepted exit through the existing `SourceLocation` authority only when constructing the detached record.
- Treat an observed action edge as its one child dispatch and retain the existing repeated-action collection
  topology. Native, reconstructed, generated-plan, and independently loaded emitted-module execution all use the
  shared engine; the exact seven-group/30-assertion consumer and combined 526-assertion focused set pass.
- Add the Julia recurring path and CI locks plus one omission mutation. Typed-source proof is 8/6/74 with Perl,
  Rust, Dart, and Julia recorded on the pending observation row; recognition stays 129+4/246/58, language stays
  246/105+1/122, repeated-action stays 8 governed seams / 54 mutations, and facade/schema/CLI/README stay closed.
- Final full Julia package and storage 19/5 rerun pass after runtime cleanup. Book 79/14,528 KiB, Knowledge
  825/6,883, and all eight doctrines pass.
- The first fully staged canonical run correctly rejected a bounded `MEMORY.md` rewrite that had lost the
  repeated-action contract's historical next owner `FUTURE-PARITY-BACKLOG.10.1`. The existing marker-anchor
  Knowledge card identifies this structural coupling; restore the compact fact within the 60-line cap, keep the
  checker unchanged, and preserve the repair until future owner `.22` moves the marker to a stable governed home.
- The sandboxed canonical restart reached representative-process containment and stopped only because the outer
  harness denied nested macOS `sandbox-exec` with status 71. The unchanged permission-authorized command passes
  containment/relocation, CLI 66/66 in both environments, RAM 60%, Phase 0 1,031/1,031 in 725 seconds, and the
  complete six-runtime typed-source matrix before exact `[ci] local CI gate passed` with exit 0.

- 2026-08-12 (`FUTURE-PARITY-BACKLOG.14.4.4` — Dart recursive observation): parse the exact special form into one
  private `ActionObserveRecognitionExpr`; keep the static rule operand unevaluated, and close the existing
  `binding_write` recognition effect through ordinary rule and user-function call graphs.
- Extend the existing `RecognitionInvocationAuthority`, not the runtime facade, with direct-parent snapshots and
  fresh rejected-attempt reservation. A pending scope intercepts only its intended child and disarms at entry, so
  later ordinary nested recursion retains the existing false cutoff.
- Publish a terminal completion only inside an active observation boundary, consume it immediately, and bind the
  recursively detached nine-field harray before returning the unchanged payload or propagating the unchanged typed
  failure. Retain no source text, parser/runtime object, second invocation stack, or parse-wide history.
- Keep cursor, boundary, match, and mark registers in UTF-16 code units. Project entry, selected match, and accepted
  exit through the existing `SourceAuthority` only when constructing the record; the astral fixture freezes
  code-unit offset 2 as Unicode-scalar offset 1.
- Treat an observed action edge as its one child dispatch and retain the existing repeated-action collection
  topology. Native, reconstructed, generated-plan, and independently analyzed/executed emitted source all use the
  shared engine; the exact seven-test consumer and combined 24-test focused set pass.
- Add the Dart recurring path/CI/storage locks and one omission mutation. Typed-source proof is 8/6/73 with Perl,
  Rust, and Dart recorded on the pending observation row; recognition stays 129+4/246/58, language stays
  246/105+1/122, repeated-action stays 8 governed seams / 54 mutations, and the facade/schema/CLI/README stay closed.
- Exact composition passes all six typed-source runtimes and all five repeated-action backends, including the
  latter's 5x2 CLI case. The final book renders 79 files / 14,524 KiB and Knowledge indexes 824/6,869.
- All eight doctrines pass. The first staged canonical invocation reached the representative-process containment
  proof and stopped solely because the outer harness denied nested macOS `sandbox-exec` with status 71. Treat
  that as a harness permission boundary, not a project failure; do not weaken or bypass the containment oracle.
- The unchanged permission-authorized rerun proves containment and repository relocation, both 66/66 CLI option
  environments, RAM 57% under the 88% ceiling, Phase 0 1,031/1,031 in 752 wall-clock seconds, and the complete
  six-runtime typed-source opt-in before exact `[ci] local CI gate passed` with exit 0. Land atomic 212 cleanly
  before activating Julia `.14.4.5`.

- 2026-08-12 (`FUTURE-PARITY-BACKLOG.14.4.3` — Rust recursive observation): lower the exact special form into one
  serialized `Expr::ObserveRecognition` and keep its static rule operand unevaluated. Reject nested targets,
  dynamic/malformed/missing operands, and observation effects reachable from `recognize_once` through either rule
  or user-function calls.
- Extend the existing `RecognitionTransactionAuthority`, not runtime context, as the sole monotonic identity and
  direct-parent authority. A rejected attempt reserves the next id without frame entry; a live frame captures
  entry cursor and its last selected match before publishing one ephemeral completion.
- Arm observation interception for only the pending observed child. Disarm it immediately after that child enters,
  so ordinary nested recursion retains its existing cutoff and cannot be mislabeled as direct/mutual observation
  rejection.
- Bind the detached nine-field harray to the rule-local target before returning the unchanged child payload or
  propagating its unchanged typed error. Convert internal UTF-8-byte entry/match/exit registers through the existing
  typed source authority only at projection time.
- Route action-edge observation through one dispatch and emitted source through the effective private runtime.
  Seven final-path groups cover native, serialized reconstruction, generated plan, independent emitted compilation,
  falsey success, failed/zero-regex/action-edge outcomes, detachment, recursion rejection, and abort propagation.
- Keep observation-only and existing self-finalizer action edges on one `execute_block` plus
  `collect_or_return_action_value!` path. The first staged canonical run exposed a ten-versus-eight seam drift;
  consolidation restores the exact governed eight sites, with observation 7/7 and repeated-action 3/3 green.
- Exact composition passes Perl 17, Rust observation 7 plus typed source 4, Dart 4, Julia 127, Lua 240 per ABI,
  generated Rust 105/105, capability 80/0/0, and language 246/105+1/122. Typed source is 8/6/72 with Perl and Rust
  current on the pending observation row; recognition is unchanged at 129+4/246/58.
- Rendered documentation passes 79 files / 14,512 KiB, Knowledge passes 823 facts / 6,856 question keys, and all
  eight doctrines pass. Definitive canonical proof passes containment/relocation, CLI 66x2, RAM 46%, and Phase 0
  1,031/1,031 in 744 seconds through exact `[ci] local CI gate passed` with exit 0.

- 2026-08-12 (`FUTURE-PARITY-BACKLOG.14.4.2` — Perl recursive observation): recognize the exact special form as
  one dedicated ActionIR event before generic assignment/call scans. Validate one bare target, exact arity, one
  static existing `call(Rule)`, and diagnostic context before generated execution.
- Reuse `RecognitionTransaction` as the sole parse-local invocation-id and parent-lineage authority. A rejected
  recursive attempt consumes the next id under the active frame but never enters a frame; accepted/failed/aborted
  children publish only one ephemeral completion consumed immediately by `observe_static`.
- Entry is captured before the child's lifecycle and matching. Action-edge observation forwards parent match info;
  direct observation creates no match. Each generated child continues to derive seek/consume from its own family,
  and every `note_match` overwrites the terminal selected-match span.
- Preserve payload and failure identity independently of observation outcome: `false`, `0`, `""`, `undef`, and
  ordinary failures retain their exact channels; aborted and rejected records bind before the identical typed
  failure propagates. Detached records contain no source text, path, authority, frame, match object, or coderef.
- Classify `OBSERVE_RECOGNITION` as `binding_write` in the closed recognition-transaction effect inventory. The
  recognition checker therefore advances from 128 to 129 current nodes without weakening transaction rollback
  safety. Language coverage treats `observe_recognition` as the fourteenth grammar-owned/non-public contract.
- Admitted transaction consumers deliberately snapshot mutable neutral metadata. The first canonical run stopped
  at Rust's stale `128` assertion; exhaustive review found the same snapshot in Dart, Julia, and Lua, plus the
  derived `132` aggregate in Dart, Julia, and Lua. Advance them to `129` and `133` respectively as contract-consumer
  alignment, with no backend transaction implementation or rollout change.
- The final-path consumer was RED before production edits, then passes seven top-level groups across live and
  independently loaded generated source. Neutral governance is 8 complete / 6 pending / 71, with only Perl listed
  on the still-pending recursive-observation row; all non-Perl and public boundaries remain future.
- Final signoff passes book 79/14,508 KiB, Knowledge 822/6,843, all eight doctrines, repository containment and
  relocation, primary CLI 66/66 in both option environments, RAM 50%, Phase 0 1,031/1,031 in 723 seconds, and the
  complete six-runtime typed-source opt-in through the exact local-CI success marker.

- 2026-08-12 (`FUTURE-PARITY-BACKLOG.14.4.1` — executable neutral recursive observation): the selected future
  special form is `value = observe_recognition(observation, call(Child))`. Require one bare rule-local harray
  target and one unevaluated statically named call; return the ordinary child payload unchanged and bind the
  observation separately so falsey success never collapses into failure.
- The carrier is an ordinary detached harray rather than another authored value kind. Its exact fields are source,
  rule, invocation, parent, entry position, terminal selected match, accepted exit, outcome, and diagnostic;
  positions/spans are detached nested harrays and existing `value["field"]` access is sufficient.
- Model automatic action edges and explicit observed calls through the same record builder. Capture entry before
  child `I`, take family policy from the child, overwrite local-match state on every selection, publish exit only
  on normal acceptance, and reserve rejected attempted-child identity before any frame push.
- Retain at most one pending record until the explicit boundary, detach it immediately, then make stale boundary
  reads fail with the existing typed unavailable diagnostic. Never introduce a parse-wide observation ledger.
- The neutral checker now executes 33 transitions and reason-checks ten state corruptions plus three surface/
  topology drifts. Current typed-source governance is 70 mutations at unchanged rollout 8/6; backend work begins
  independently with Perl `.14.4.2` only after this leaf lands cleanly.
- Definitive signoff composes Perl 10, Rust/Dart 4/4, Julia 127, and Lua 240/240 per ABI with strict generated Rust
  105/105, capability 80/0/0, and language 246/105+1/122. The rendered book, Knowledge 821/6,831, all eight
  doctrines, host-permitted six-family containment, relocation, CLI 66x2, RAM 35%, and canonical Phase 0
  1,031/1,031 in 714 seconds pass through the exact success marker and exit 0.

- 2026-08-12 (`FUTURE-PARITY-BACKLOG.14.4.0.1` — recursive observation lineage correction): keep invocation ids
  numeric at the neutral boundary. `bool` must be rejected explicitly because Python treats it as an `int`; ids
  must otherwise be positive, unique, and drawn monotonically from the existing parse-local authority.
- Validate lineage after row field/source/span validation but before exact tuple comparison. This preserves useful
  structural failures and ensures lineage invariants are independently executable rather than consequences of a
  pinned fixture. Parent-before-child is `parent_id < invocation_id`; represented-parent traversal separately
  detects cycles so that cycle mutations fail for the intended reason.
- Model each pre-entry progress rejection as an attempted child, not as the active frame: direct rejection is
  child `9` under parent `8`, and mutual rejection is child `11` under parent `10`. No child frame is pushed and no
  second stack or completed-history ledger is introduced.
- Exact RED with the committed artifact failed `recursive invocation identity must be a positive integer` after
  the validator landed. The corrected artifact passes six observation roles and 57 total mutations, including
  reason-checked self-parent, reuse, parent-order, and cycle regressions. Runtime and public surfaces stay inert.
- Definitive proof repeats the composed six-runtime typed-source route, generated-source/capability/language
  ledgers, the rendered 79-file/14,460-KiB book, Knowledge 821/6,826, all eight doctrines, repository containment
  and relocation, CLI 66x2, RAM 34%, and Phase 0 1,031/1,031 in 739 seconds through exact canonical success.
  Commit atomic 208 cleanly before activating executable neutral observation `.14.4.1` task-tree-first.

- 2026-08-12 (`FUTURE-PARITY-BACKLOG.14.4.0` — recursive observation audit): committed audit authorities at
  `3ac018f8` are neutral `7663edf5`/`80b85e86`; Perl `07ff872d`/`2cc9cefa`/`a020f1c1`; Rust
  `5801b30f`/`d7f39fcb`/`1bf17d9b`; Dart `770a183e`/`0867a6de`/`534ad289`; Julia
  `bf55e355`/`aa060778`/`9f1390d4`; and shared Lua `5ad6f644`/`2b8f4050`/`6982f7b9`/`11d8e464`.
- `call_spec_handler_subst` proves `call(Leaf)` receives the current match-info object; `return_descriptor` proves
  the child still owns family/cursor policy; `dump_parser_source` and `LinkedSpec::Get` prove action-edge entry
  match `[0,1]` at cursor 1 versus direct-call entry at current cursor with no invented selected match.
- Capture entry before child `I` lifecycle/family matching. Preserve the invocation's terminal local regex match,
  not a parent's match or backend match object. Publish accepted exit only on normal accepted return. Preserve
  `accepted`, `failed`, `aborted`, and `rejected` as distinct outcomes with explicit absence.
- Reuse the transaction invocation authority. Rust/Dart/Julia/Lua guards run before recognition-frame entry; Perl's
  wrapper guard runs before the generated handler and raises typed progress only in recognition mode. A rejected
  attempt needs a fresh reserved child id linked to the active parent, but no pushed frame or second stack.
- The original neutral `direct_nonprogress` row at `e8f6198b` self-parents. The checker validates source/span bounds
  and exact tuple equality only; it has no self-parent/reuse/order/cycle invariant. Finish `.14.4.0` cleanly, then
  activate corrective `.14.4.0.1` before `.14.4.1` executable observation work.
- Avoid enabling broad debug trace while the bootstrap parser is being built: it can emit the entire compilation
  path at very high volume. Build first, then enable a focused runtime trace or use the dedicated probe/test route.
  The audit's accidental broad probe left no file or process residue and was not used as evidence.
- Definitive canonical proof requires the host-permitted run because its representative process-I/O test invokes
  macOS `sandbox-exec`; an outer workspace sandbox rejects that nested sandbox with status 71. The unchanged host
  run passes the six-family containment proof, both 66-case CLI environments, RAM 59%, and Phase 0 1,031/1,031 in
  832 seconds through exact local-CI success. This is an execution-environment requirement, not a weakened gate.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.8` — recognition public closeout): the ninth row owns only the final
  public projection. Its exact paths are the capture/source chapter, backend-handoff appendix, project-status page,
  and capability guide; it does not add a seventh implementation, another runtime route, or a public facade.
- Keep semantic/topology governance at 58. Replace the obsolete premature-public-promotion mutation with a
  complete-to-RED regression so final current truth is protected without inflating the causal mutation census.
- Close recurring-era prose explicitly. Three stale book claims move public governance from 3/23/42 to 3/26/45;
  two stale guide claims move its independent guard from 1/12/16 to 1/14/18.
- Every admitted consumer snapshots mutable status/availability/rollout metadata, so the final promotion updates
  all six exact consumers while preserving their assertion counts and backend behavior: 51, 12, 10, 207, 246,
  and 246. The five-source/six-runtime recurring route and all three support ledgers remain byte-unchanged.
- Close only transaction parent `.14.3`. Recursive source observation `.14.4` is next after the clean commit, while
  the broader typed-source recurring/public row `.14.8` remains pending and must not be inferred from 9/9 here.
- Definitive proof passes all eight doctrines, containment/relocation, CLI 66x2, RAM 60%, and Phase 0 1,031/1,031
  in 722 seconds through exact canonical success. Land atomic 206 cleanly before `.14.4` activates task-tree-first.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.7` — recurring recognition-transaction proof): recurrence is
  orchestration, not another transaction implementation. Keep the neutral checker first and the already admitted
  Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT consumers exact; support ledgers follow all runtime routes.
- Freeze source and runtime cardinality separately. There are five backend source groups but six runtime routes
  because the one shared Lua source must execute independently on PUC Lua and LuaJIT. Exact command strings plus
  order and multiplicity are stronger evidence than filename presence alone.
- No primary recognition-transaction CLI case exists, so this driver must not invent a CLI projection. Its
  compatibility boundary is instead the neutral contract, exact runtime consumers, and existing support ledgers.
- Enter `tools/project_data_env.sh` at the driver boundary and keep all nested language wrappers. Canonical CI owns
  tracked-input, path-audit, syntax, and opt-in execution; `tools/test_project_data_workflow_routing.sh` proves the
  new entrypoint from outside cwd without creating another storage root.
- Count governance causally: eleven source/route/command/support/storage/CI mutations plus recurring regression move
  46 to 58. Public stale-claim growth adds three forbidden claims and one rollout mutation, moving 3/20/38 to
  3/23/42; the guide analog moves 1/10/14 to 1/12/16. Promote only recurring and retain public no-drift `.14.3.8`.
- Every admitted consumer snapshots mutable ledger metadata. Updating status, availability, mutations, and rollout
  raises current Julia proof to 207 and Lua to 246 per ABI without changing runtime behavior. Full recurring proof
  passes Perl 51, Rust 12, Dart 10, Julia 207, Lua 246x2, and all three support ledgers.
- The first canonical run caught a cross-contract prose collision: semantic public governance reserves generic
  `rollout 8/9` as a stale semantic claim. Keep the exact semantic `128 mutations, rollout 9/9` anchor and express
  recognition as “eight of nine rollout legs complete” in both roadmaps; no governed state or count changes.
- The repaired definitive run passes all eight doctrines, containment/relocation, CLI 66x2, RAM 62%, and Phase 0
  1,031/1,031 in 745 seconds through exact canonical success. Land atomic 205 cleanly before `.14.3.8` recomposes
  the public boundary and closes the transaction activity.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.6.3` — dual-ABI Lua recognition admission): admission is a topology
  change, not another runtime layer. Remove the selector and RED diagnostics, keep the 243-assertion body and both
  private production modules unchanged, and execute the same Lua-5.1 source independently on both ABIs.
- Ordinary proof belongs in `tools/run_lua_local.sh`: one direct command under the PUC native path and one under
  the LuaJIT native path. Canonical proof separately requires the tracked consumer and uses one project-data-routed
  command per ABI. Governance counts exact marker multiplicity rather than merely searching for the filename.
- Treat PUC Lua and LuaJIT as independent rollout rows even though they share source. Promotion therefore adds two
  complete-to-RED semantic mutations and two exact rollout paths, moving 44 to 46 and 5/9 to 7/9. Recurring and
  public no-drift are still later responsibilities; do not collapse them into admission.
- Every admitted consumer snapshots mutable neutral metadata. Lua promotion changes no Perl/Rust/Dart/Julia runtime
  behavior, but their expected status, availability, mutation count, and later-row assertions must advance. Julia
  consequently moves from 203 to 205 current assertions solely through two new rollout-row checks.
- Current admission governance replaces, rather than pretends to execute, the historical RED oracle: 22 mutations
  lock canonical and ordinary omission/duplication, direct private lookup, stale selector/diagnostics, result
  identity, and facade privacy. Retain 22 authority and 19 integration suites as independent implementation locks.
- Public truth must move with admission. The mdBook now teaches the exact dual-ABI commands and private/public
  boundary; checker-governed sequence truth is 3/20/38 and capability-guide truth is 1/10/14.
- Canonical signoff caught and rejected two accidental documentation-projection omissions before acceptance: the
  retained `.24.2` capability-exclusion marker in `docs/TASK_TREE.md` and exact `128 mutations, rollout 9/9`
  semantic text in both roadmaps. Restoring those historical/current anchors made the independent guards pass;
  final locality, relocation, CLI 66x2, RAM 65%, and Phase 0 1,031/1,031 in 758 seconds are green.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.6.2` — shared Lua recognition-transaction integration): parse the four
  exact authored forms after ordinary argument parsing, then replace them with dedicated nodes. In particular,
  retain only the token slot and static child label for `recognize_once`; never evaluate its `call(Rule)` operand as
  a generic helper and never add the four grammar-owned intrinsics to the 246-name call inventory.
- Keep effect closure and progress separate. Effects propagate through direct and mutual recursion to a fixed point
  over the neutral 9-allowed/11-rejected vocabulary; only accepted repetition and recursive-cycle edges require
  cursor movement. Binding, mark, boundary, or transaction changes do not count as progress.
- Bind live state through one private adapter. Every invocation gets a fresh same-label mark bucket and authority
  frame; checkpoint/attempt/terminal operations synchronize the UTF-8-byte cursor, nullable anonymous boundary,
  and marks. Attempt presence remains separate from payload so a successful `false` commits intact.
- `interpreter.lua` was already at Lua 5.1's 200-local main-chunk ceiling. A cohesive private
  `recognition_transaction_runtime.lua` module avoids crossing that structural limit and keeps one implementation
  shared by PUC Lua and LuaJIT instead of scattering adapter functions through the interpreter.
- Native, reconstructed, generated-plan, and emitted-module carriers all re-enter the effective compiler/runtime;
  no emitter-specific transaction fork or filesystem workspace is needed. Exact integration is 243/243 per ABI.
- Keep integration distinct from admission: facade and ordinary/canonical discovery stay unchanged, rollout remains
  5/9, and the checker adds 19 private-integration mutations beside 22 authority and 12 dormancy mutations.
- A supplemental apparent miss anomaly was an invalid probe assumption: `E { return(false) }` is a final lifecycle
  return and therefore accepts after a regex miss. The corrected `LE` probe proves hit=`false`/cursor 2 and
  rollback=`"miss"`/cursor 0 identically on both ABIs; existing lifecycle knowledge already owns that behavior.
- Final proof passes book 79/14,412 KiB, KM 817/6,781, all eight doctrines, every mandatory admission, containment/
  relocation, CLI 66x2, RAM 65%, and Phase 0 1,031/1,031 in 736 seconds through exact canonical success. Land
  atomic 203 cleanly before `.14.3.6.3` changes discovery or rollout truth.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.6.1` — private shared Lua recognition-transaction authority): follow the
  existing private `source_location.lua` pattern: opaque tables backed by one module-local weak-key store and a
  non-exported direct module. This keeps handles unforgeable enough for the internal contract without public API.
- Keep the module within Lua 5.1 syntax and behavior. One source must run unchanged on PUC Lua and LuaJIT; the
  authority owns no parser/runtime carrier until `.14.3.6.2` integrates it.
- Separate matched presence from payload at every boundary. Lua's `condition and payload or fallback` idiom loses
  `false`; explicit branches are mandatory for staged values and diagnostic projections. Use `json.null` for an
  encodable miss and `json.array()` for empty ordered diagnostic fields rather than ambiguous `{}`.
- Restore snapshots before invalidating tokens on rollback, discard, misuse, and invocation unwind. Monotonic ids
  plus private ownership checks make cross-source, cross-invocation, wrong-generation, nesting, retry, reuse, and
  escape failures deterministic and prevent a failed operation from leaving staged state live.
- Authority proof is 187/187 on both ABIs. Integration compiles the real authored source and then stops at one
  stable missing-dedicated-ActionIR diagnostic; do not add effects, progress policy, runtime adapters, or carriers
  to this authority-only slice.
- Keep dormant topology and private-authority governance separate: 12 mutations prove absence from ordinary/
  canonical/facade routes; 22 prove the authority surface and next RED. Neutral 132/246/44 and rollout 5/9 stay exact.
- Final proof passes book 79/14,412 KiB, KM 816/6,772, all eight doctrines, every mandatory admission, containment/
  relocation, CLI 66x2, RAM 82%, and Phase 0 1,031/1,031 in 753 seconds through the exact canonical success marker.
  Land atomic 202 cleanly before `.14.3.6.2` adds any ActionIR/effect/progress/runtime/carrier integration.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.6.0` — shared Lua recognition-transaction RED): use one source for both
  PUC Lua and LuaJIT. The existing interpreter, typed source authority, byte registers, mark/cursor stores,
  generated plan, and in-memory source loader are shared; an ABI-specific transaction implementation would be drift.
- Freeze `authority` and `integration` modes as an ordered handoff. Both modes load the future private direct module
  first, yielding one stable failure today; `.14.3.6.1` can close authority before `.14.3.6.2` closes compiler/runtime
  integration without weakening the final-path consumer.
- Preserve Lua's explicit null sentinel when match presence and payload are separated. A successful `false`, zero,
  empty string, or `json.null` is staged independently from the strict match boolean and reaches commit unchanged.
- Load emitted Lua in memory with `loadstring or load`; the RED creates no filesystem workspace or project-data owner.
  Ordinary and canonical command lists must remain path-free until admission `.14.3.6.3` removes dormancy.
- Keep RED topology governance separate from semantic rollout. Twelve mutations lock the dual-ABI dormant boundary,
  while the neutral artifact remains 132/246/44 at 5/9 and all public/guide claims remain Julia-current/Lua-future.
- Cross-check frozen future branches against the real current serialization API even when the missing authority
  prevents execution today: Lua compiled specs expose `rules_by_label`, not a positional `rules` array.
- Final proof passes book 79/14,412 KiB, all eight doctrines, every mandatory contract/admission, containment and
  relocation, CLI 66x2, RAM 60%, and Phase 0 1,031/1,031 in 740 seconds through the exact canonical success marker.
