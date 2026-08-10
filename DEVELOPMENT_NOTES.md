# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.3.0` — dormant Rust recognition-transaction RED): use a file-level
  custom cfg so the final-path integration target is tracked and syntax-visible to Cargo while ordinary and
  canonical discovery execute zero tests. A second nested cfg can freeze later compiler/runtime/carrier behavior
  without competing with the first missing private-authority boundary.
- Derive the future Rust API from the neutral contract and the admitted Perl mechanism, not from host convenience:
  one source authority owns opaque monotonic invocation/frame/mark/token generations and detached snapshots;
  match presence is distinct from staged payload truthiness; terminal or unwind paths restore before invalidating.
- Freeze all carriers before implementation: dedicated non-eager AST lowering, recursive effect closure,
  cursor-only progress, native and reconstructed execution, generated-plan execution, and independently compiled
  emitted source. The explicit outer cfg must fail solely at missing
  `linkedspec_runtime::recognition_transaction`; any earlier syntax/fixture error invalidates the RED slice.
- Keep technical capability guidance outside the three-page mdBook public-sequence inventory as an explicit
  separate guard. Atomic 187 added current 2/9 prose without deleting its adjacent 1/9 predecessor; two required
  markers, two forbidden stale claims, and six mutations now catch path, marker, duplication, deletion, and both
  stale-text regressions while leaving semantic 41 and public 14 counts stable.
- Definitive signoff must run host-authorized when the canonical storage proof invokes its own macOS sandbox. An
  outer-sandbox run reached that proof but denied nested `sandbox-exec` with status 71; a complete authorized rerun
  passed repository-contained/moved-root IO, both CLI environments at 66/66, RAM 55%, and Phase 0 1,031/1,031 in
  700 seconds. Treat harness denial separately from a repository assertion failure and still rerun the full gate.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.2.3` — Perl recognition-transaction admission): admission is a
  registry/ledger/public-current slice, not another implementation seam. Require the exact final-path file once,
  syntax-check it once, and execute it once through ordinary `prove`; make all four occurrences omission- and
  duplication-sensitive in the independent checker without changing production Perl.
- A final-path consumer can contain admission-state assertions even when its behavioral proof is already GREEN.
  Advancing neutral-only status and all-backends-unavailable metadata changed exactly two assertions; the other 49
  still prove the integrated ActionIR, effects, tokens, marks, progress, compatibility, and generated-source routes.
- Preserve two distinct mutation domains. The semantic corpus advances 40→41 by retaining premature Rust promotion
  rejection and adding Perl complete→RED regression. The three-page public projection advances 13→14 by separately
  rejecting neutral regression, Perl regression, and premature next-backend promotion.
- Current support is runtime-scoped: Perl now admits the exact `recognition_*` forms, but this does not complete
  recurring or public-no-drift governance and does not make the forms portable to Rust, Dart, Julia, or Lua.
- Treat the full canonical result as the admission boundary: exact registration is insufficient until the same
  staged tree passes CLI 66/66 in both option environments, RAM policy, and Phase 0 1,031/1,031. This slice closes
  at 34% RAM and 733 wall-clock seconds with production implementation bytes unchanged.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.2.2` — integrated Perl recognition transactions): scan the four special
  forms before generic statement families, but preserve the established lowering-contract metadata order with
  `call` first. Dedicated event arguments are the only source of token/result/static-callee lowering; generic
  assignment and nested call scans must not duplicate or eagerly execute them.
- Run transaction policy only after ordinary final-descriptor construction/validation. The first broad Phase 0 run
  proved why: an earlier hook stole the established malformed-`dependency_refs` diagnostic owner, while placing
  transaction contracts first changed stable public metadata. Preserve both pre-existing contracts, fail closed on
  malformed policy input, then apply recursive effect closure.
- Invocation completion is an internal acceptance channel, not a second result API. Publish child completion only
  while a recognition scope is active, consume it at bcode edges, and keep payload truthiness irrelevant inside
  `recognize_once`. This avoids ordinary parses accumulating unused completion records.
- Progress is stricter only in an active recognition attempt. Accepted repeated edges and same-cursor direct/mutual
  re-entry require `end_offset > start_offset`; marks, bindings, transaction state, and backward movement never
  count. Existing ordinary recursion cutoff and repetition compatibility remain unchanged.
- Internal behavior and admission are separate commits. Production modules enter canonical tracked/syntax
  inventory in `.2`, while `t/recognition_transaction_perl_contract.t` remains undiscovered until `.3`. Public
  prose must describe the internal GREEN proof without promoting neutral rollout 1/9 or an authored capability.
- Identifier-shaped lowering diagnostics are not automatically ordinary helper calls. The canonical coverage gate
  caught the four transaction intrinsics after implementation; classify those exact grammar-owned dedicated nodes
  alongside the nine established non-public contracts, require their Perl presence and helper-inventory absence,
  and keep the shared inventory at 246 with all 122 ordinary public calls independently covered.
- Definitive composition after that repair passes all eight doctrines, repository-contained and relocated process
  proofs, both primary CLI environments at 66/66, RAM 58%, and Phase 0 at 1,031/1,031 in 727 seconds. Keep the
  GREEN final-path consumer absent from canonical discovery until the separate admission leaf.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.2.1` — private Perl transaction authority): follow the typed-source
  inside-out pattern for linear transaction state. Opaque scalar handles prevent caller-visible owner hashes while
  module-owned tables retain source authority, invocation/generation identity, snapshots, attempt state, staged
  payload presence/value, and terminal status. Detached frame snapshots clone marks before crossing the seam.
- Invocation frames must be distinct from current rule-label mark buckets before either is wired together. Fresh
  frame marks plus monotonic non-reused ids prove recursive same-label isolation privately; `.14.3.2.2` must route
  live marks and child entry/exit through that owner atomically rather than partially shadowing legacy buckets.
- Dynamic misuse is restore-before-report. Escape, retry, cross-authority use, missing terminal, token/frame drop,
  and nesting restore the owning snapshot and clear active-token ownership before a typed neutral diagnostic or
  destructor return. Commit alone retains candidate state, and it invalidates before exposing staged payload.
- Canonical execution of `t/recognition_transaction_perl_authority.t` is a private foundation proof, not backend
  admission. Keep the final-path `t/recognition_transaction_perl_contract.t` absent until `.14.3.2.3`; its unchanged
  four-node RED is the mechanical guard against confusing an internal module with authored/runtime support.
- Definitive signoff preserves that separation across all eight doctrines, repository-contained and relocated
  runtime proofs, both CLI environments at 66/66, RAM 71%, and Phase 0 at 1,031/1,031 in 688 seconds. Rendered
  documentation explicitly says private prerequisite rather than authored support, and generated book output is
  removed after inspection.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.2.0` — dormant Perl transaction RED): the accepted four-form specimen
  already passes bootstrap/descriptor construction, so do not describe the current boundary as missing grammar.
  Current scalar assignment lowering hides checkpoint, attempt, and commit behind three unsupported-helper
  sentinels, while statement-only rollback falls through as raw Perl. Require all four dedicated `RECOGNITION_*`
  nodes, zero unresolved helpers, zero raw dependencies, and language-agnostic readiness as one atomic RED seam.
- A dormant consumer should execute stable neutral facts before its implementation boundary. Here 49 assertions
  independently lock the authored strings, 8/17 token fixtures, six effect graphs, six mark cases, eight progress
  cases, 9/11 effects, fifteen codes/fields, and exact counts before one RED assertion. The later live/generated
  behavior stays behind one skip, so current canonical CI remains green without weakening future coverage.
- Keep admission mechanically distinct from final-path tracking. Explicit commands in `tools/run_ci_local.sh`
  define ordinary/canonical Perl discovery; a tracked `t/*.t` file is dormant when those registries contain zero
  references. Stage it before canonical signoff so the tracked-input audit sees the final repository shape, but
  do not register or execute it until `.14.3.2.3`.
- Definitive signoff proves that staging a dormant final-path consumer does not silently admit it: all eight
  doctrines, repository-contained six-family process I/O, moved-root/outside-CWD execution, both CLI environments
  at 66/66, RAM 69%, and Phase 0 1,031/1,031 in 672 seconds pass while the consumer still has zero registry
  references and retains its exact intended RED result.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.1.2.0` — public sequence governance): derive documentation status from
  the semantic artifact's rollout instead of duplicating it as an independent claim. The guard requires neutral
  complete and every non-neutral leg RED before checking exact page markers, so public prose cannot move ahead of
  or lag behind rollout without one deterministic failure.
- Keep semantic and public mutation accounting separate. The JSON still owns forty syntax/token/effect/inventory/
  rollout mutations; the checker owns thirteen additional in-memory public inventory/marker/claim/text/rollout
  mutations. This preserves contract identity while making the three-page milestone order fail closed.
- `git ls-files --error-unmatch` is the right tracked-source proof here: all public inputs remain root-relative,
  exact, and canonical without introducing a new tool entrypoint or widening project-storage topology.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.1.2` — rendered milestone-order repair): status statements can each be
  historically correct yet become contradictory when a later slice inserts new truth without retiring old
  sequencing prose. Commit `7c2ff407` said the neutral checker was next; `e0cc7182` inserted its executable status
  two paragraphs earlier but missed the original sentence. Source-only searches did not expose the juxtaposition;
  rendered paragraph inspection did.
- The neutral checker's `current_boundary` mutation protects artifact policy and false current-capability claims,
  not mdBook milestone ordering. Do not widen the semantic artifact's exact 40-mutation boundary during a public-
  text repair. Correct the sentence narrowly, preserve the cause, and let `.14.3.1.2.0` add a separate governed
  public-sequence projection with its own mutation proof before backend work.
- Definitive recomposition signoff passes all eight doctrines, exact repository-contained process and moved-root
  proofs, primary CLI 66x2, RAM 59%, and Phase 0 1,031/1,031 in 695 seconds without changing an executable owner.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.1.1` — executable neutral recognition transactions): distinguish
  inventory domains before freezing counts. Perl currently exposes 128 unique canonical ActionIR node kinds, while
  the language coverage checker reports 122 public identifier-shaped Perl call contracts and 246 aligned
  cross-backend call names. Treating 122 as the node count would silently omit six node kinds; the new Knowledge
  card and checker preserve the distinction.
- A single base-effect row must be conservative across overloaded call spellings. `split`, `set_key`, and array-end
  mutation calls therefore classify as aggregate writes even where a value-only form can return a copy; `with`
  and tree traversal classify as dynamic callables; compatibility save/restore/rewind never masquerade as
  transaction state. Readable rows live in the artifact, while independent canonical digests reject reclassification.
- Falsey-safe recognition requires two channels. `recognize_once` returns only a strict accepted bit, while commit
  retrieves the separately staged payload; `false`, `0`, empty string, and `undef` are four successful payloads.
  Ordinary `CALL` results cannot be reinterpreted by truthiness and compatibility cursor helpers have no token,
  invocation generation, staged result, effect barrier, or progress authority.
- Recursive effect analysis is a monotone set-union fixed point over named rules, not depth-first sampling. This
  terminates for direct and mutual SCCs and ensures a forbidden transitive callee remains visible. Progress is a
  separate cursor-edge obligation: effect, variable, mark, or transaction-state changes never substitute for
  `end_offset > start_offset` on accepted repetition or recursive-cycle edges.
- The neutral artifact is deliberately executable before any parser understands its syntax. Canonical CI proves
  132 node rows, 246 call rows, token 8/17, graphs 6, marks 6, progress 8, diagnostics 15, and 40 mutations while
  rollout remains 1/9. This isolates target-contract mistakes from six later backend implementations and prevents
  neutral proof from being misreported as current authored capability.
- Definitive signoff must run where the gate can apply its own `sandbox-exec` profile. An outer sandbox correctly
  blocked nested profile application with `Operation not permitted`; the unchanged host-authorized rerun passed
  repository-contained process I/O, moved-root execution, CLI 66x2, RAM 55%, and Phase 0 1,031/1,031 in 675
  seconds. Treat that first result as an execution-context denial, never as permission to weaken containment.

- 2026-08-10 (`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.4` — unchanged four-store recomposition): the four routed
  records already have their final normal shape: `state=current`, bounded controls, executable verifiers, and
  empty `baseline`/`transition` objects. Closeout therefore must not invent another transition ADR, rewrite the
  migration owners, or refresh old debt facts. It independently composes the committed history/task/consumer/
  rollover/route checks and updates only durable status/frontier owners. This preserves the exact contracts while
  proving they work together and returns product work to `FUTURE-PARITY-BACKLOG.14.3.1.1` after the clean commit.
- The first closeout canonical run rejects a shortened `docs/TASK_TREE.md` future-backlog row because it dropped
  the capability checker-owned marker “exclusion public closeout `.24.2` remains closed”. The parent `.24`
  statement is not an equivalent projection. The focused rerun then rejects “remains public-closed” in place of
  the exact parent “is public-closed” marker. Restore both exact projections and rerun the focused consumer plus
  the complete canonical gate; do not weaken the checker or classify either failure away.
- Corrected closeout signoff passes capability 80/0/0 and one uninterrupted definitive repository-volume gate:
  all eight doctrines, MCP complete/141, Rust semantic 1/1 in 85.71 seconds, Julia semantic 416/416 in 29.9
  seconds, cursor 288, process containment, moved-root execution, CLI 66x2, RAM 49%, and Phase 0 1,031/1,031 in
  673 seconds. The two failures therefore remain useful exact-projection regression evidence, not open blockers.

- 2026-08-10 (`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3` — bounded chronology hot stores): reverse-chronological
  roots need insertion headroom that immutable legacy segment IDs cannot provide after landing. Changes and notes
  therefore reserve initial archive IDs from `5000` upward. Each later rollover removes only an exact suffix of
  complete records already present at clean HEAD, assigns the next lower ID, and prepends that content-addressed
  segment to the manifest. IDs remain ascending in manifest/read order while later rollover generations naturally
  sort before older history; the reserve supports 4,999 rollovers without renaming an immutable target.
- Initial legacy records may split at any line because their only rendering contract is exact reconstruction.
  Once the bounded roots exist, `CHANGES.md` rolls only at `^## ` and engineering notes at a dated-entry or `^## `
  boundary. The rollover tool rejects rewritten/reordered HEAD records and refuses to archive uncommitted entries,
  so every new segment is an exact Git-addressable source suffix rather than conversational or working-tree state.
- Warning, action, and completion are distinct: 80% reports pressure without failing; 90% requires rollover; the
  resulting root must be at or below both 256 lines and 32,768 bytes. The doctrine independently rejects a root at
  the action boundary, so the author workflow cannot defer rollover into the next slice.
- Exact legacy notes include historical trailing spaces. Archive reconstruction forbids normalization, so the
  existing raw-segment attribute exempts only `docs/history/**/segment-*.md` from blank-at-EOL/EOF reporting.
  Current hot roots and every non-archive path remain under the ordinary whitespace gate.
- Pre-signoff review found the first rollover draft published the bounded root before its manifest. An
  interruption in that window could remove current records before the query index named their already-written
  segment. The corrected transaction publishes segment, then manifest, then root. A rerun accepts an exact orphan
  segment or recognizes the exact pending first manifest record and completes the retained-root installation;
  mismatched existing bytes fail closed. Thus every interruption point retains either the unchanged author root or
  a fully queryable archive generation, and recovery is deterministic.
- Definitive signoff uses one uninterrupted approved repository-volume gate: all eight doctrines, six-family
  containment, moved-root/outside-CWD execution, both 66-case CLI option environments, the 51% RAM checkpoint,
  and Phase 0 at 1,031/1,031 in 716 seconds pass before the atomic commit workflow begins.
