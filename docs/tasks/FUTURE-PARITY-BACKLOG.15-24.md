- ID: `FUTURE-PARITY-BACKLOG.15`
  Status: `done; canonical-signoff-complete`
  Goal: Make any standalone/dangling rule-level `{ ... }` block exact syntax sugar for `I { ... }`.
  Children: `.15.0`, `.15.1`, `.15.2`, `.15.3`
  Acceptance: At top-level rule-body item parsing, accept a standalone `{ ... }` anywhere an item may occur and
    normalize it to the existing `I` lifecycle AST rather than adding runtime semantics. Action-edge and blind-call
    blocks remain owned by their preceding edge productions and therefore are not standalone/dangling; nested
    expression/callable blocks remain owned after entering code parsing. Apply the same rule to OR, AND, zero-regex,
    one-regex, and two-regex rules; preserve explicit `I { ... }`; inherit its ordering/duplicate behavior; align
    all admitted backends, source generation, diagnostics, examples, and complete gates.
  Verification: **PASS 2026-08-29.** Decision `.15.0`, Perl/Rust `.15.1`, and remaining-backend/self-hosted/public
    `.15.2` close the exact neutral contract across five source backends, six runtime routes, generated carriers,
    self-hosting, capability 90/0/0, public teaching, and canonical recurring no-drift. Post-closeout repair `.15.3`
    replaces one stale false-positive Lua fixture with its intended action-edge ownership and recomposes the complete
    dual-ABI boundary without changing admitted lifecycle or runtime behavior.

- ID: `FUTURE-PARITY-BACKLOG.15.0`
  Status: `done; canonical-signoff-complete` (2026-08-29; task-tree-first from exact clean typed-authoring-model closeout commit
    `bc35ada0444f94eed2eb23d6c931b9c65734dc09`; no push)
  Goal: Audit and ratify the anywhere-in-rule standalone-block normalization contract before behavior code.
  Acceptance: Use parser/toolbox evidence to distinguish the Perl reference's rejected/non-semantic dangling
    brace from the four native source parsers' dormant `PlainBlock` nodes, and enumerate every non-dangling brace
    owner: action-edge/blind-call suffixes, function/callable bodies, and nested code/control/value blocks. Ratify
    direct source-parse normalization to lifecycle `I`, authored-order duplicates, exact source/line provenance,
    compatibility treatment of old plain nodes, and explicit-twin malformed diagnostics before behavior code.
  Dependencies: `.14.8`.
  Verification tier: `canonical` — behavior remains unchanged, but the mandatory engineering-notes rollover moves
    bounded-history collection infrastructure and its exact finite capacity authorization.
  Focused checks: exact clean activation and tool-first Perl parser probes; source-backed inventories of the Perl,
    Rust, Dart, Julia, and Lua rule-body dispatch plus self-hosted grammar ownership; explicit `I` equivalence,
    action-edge/blind-call and nested code/callable exclusions, OR/AND/zero-/one-/two-regex placement, ordering,
    duplicate, span, and malformed-form evidence; Knowledge Map, ADR, roadmap, mdBook, task/index, bounded-live,
    memory, doctrine, history-pressure, render, and exact no-behavior-movement checks.
  Canonical trigger: `DEVELOPMENT_NOTES.md` crosses rollover pressure when this required design record is added;
    the resulting immutable segment, manifest member, route limits, and indexed capacity ADR are infrastructure
    changes that require an exact staged receipt-bound local CI run under ADR `0073`.
  Ownership: `.15.0` owns only the evidence-backed neutral decision and downstream leaf split. `.15.1` exclusively
    owns Perl/Rust behavior; `.15.2` exclusively owns Dart/Julia/Lua, generated paths, examples, and final no-drift.
  Checklist: [x] clean activation/task ownership [x] Knowledge/decision/toolbox retrieval [x] current parser probes
    [x] five-backend/self-hosted source inventory [x] normalization/exclusion/order/span/malformed decision
    [x] downstream acceptance refinement [x] durable Knowledge/ADR/book/live synchronization [x] canonical signoff
    [x] atomic commit/brief/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` is empty at
    `bc35ada0444f94eed2eb23d6c931b9c65734dc09`; `git_message_brief.txt` is zero bytes; the committed canonical
    receipt matches that HEAD; no generated mdBook output or background job remains. `.14.8` and parent `.14` are
    committed complete at typed 14/0/231 with all six recurring authorities and public no-drift green.
  Audit evidence: `LinkedSpec::Get` rejects `Top::` followed by `{ return("bare") }` at
    `compiler_pipeline:validate_dsl_syntax` with exact summary `Unsupported top-level rule paragraph content`; its
    bootstrap `CURLY_BRACE` scanner returns a balance sentinel rather than `ICODE`. Two explicit `I` blocks return
    `first-second`, and Perl RuleIR joins authored chunks while retaining its existing placement-sensitive regex
    lowering. Rust parses `PlainBlock` then drops it and assigns repeated explicit `I` to one `Option`, last wins.
    Dart, Julia, and Lua parse/compile plain metadata but execute only lifecycle payloads; direct Julia, PUC Lua,
    and LuaJIT probes return null for the bare form and `first-second` for the explicit pair. Direct self-hosted
    output omits the bare form and misclassifies line-start `I { ... }` through generic bare-edge ownership.
  Decision evidence: ADR `0094` and [[standalone-lifecycle-block-audit]] freeze direct lifecycle-`I`
    normalization, actual-source/opening-line provenance, explicit-twin interior spans/diagnostics, exact brace
    ownership, authored duplicates, Rust repair ownership, and inert legacy plain carriers. The roadmaps,
    architecture, Toolbox, task/index, bounded live surfaces, and sole-facing mdBook now state the current marker-
    required boundary and the `.15.1-.2` rollout without claiming behavior early.
  Capacity evidence: the required complete-record notes rollover creates immutable segment
    `docs/history/development-notes/segment-4988-0b8be5746afe.md` from activation commit `bc35ada0` and leaves the
    current root at 242/512 lines and 24,556/65,536 bytes. ADR `0095` authorizes only collection 19→20 files and
    manifest 18→19 lines; the collection remains 24,276/27,000 lines and 2,599,177/3,145,728 bytes, with every
    other root/member/aggregate/owner/lifecycle/verifier/storage control unchanged.
  Canonical attempt one: all nine doctrines, five-source/six-route staged, progressive, gap, recognition, typed-
    source, MCP, semantic-introspection, duplicate-slot, and sparse-AND proof pass. The repeated-action contract
    then rejects only the compacted `MEMORY.md` because its separately owned next-owner handoff to
    `FUTURE-PARITY-BACKLOG.10.1` was omitted. The required pointer is restored without changing `.15.0` scope;
    the exact corrected staged candidate reruns from the beginning.
  Signoff evidence: the exact bare rejection and explicit `first-second` reference probes pass; source ownership
    inventory, `git diff --check`, Knowledge Map 912/7,758, task partition/index, both bounded-history checks,
    16-row live status, README/memory, rendered sole-facing mdBook, all nine doctrines, exact no-behavior-file
    movement, and receipt-bound staged canonical CI pass. Commit:
    `FUTURE-PARITY-BACKLOG.15.0 - ratify standalone lifecycle blocks`.

- ID: `FUTURE-PARITY-BACKLOG.15.1`
  Status: `done; focused-signoff-complete` (2026-08-29; task-tree-first from exact clean standalone-block contract commit
    `836c351e7261a49d3d31166047269c09881eefb2`; no push)
  Goal: Implement the ratified bare rule-level lifecycle shorthand on the Perl reference and Rust backend.
  Dependencies: `.15.0`.
  Verification tier: `focused` — this leaf changes only the already-ratified Perl reference and Rust private
    implementation plus their direct neutral consumers; cross-backend admission, self-hosted grammar, public
    examples, capability state, parent closeout, and the push boundary remain owned by `.15.2`.
  Focused checks: neutral Perl/Rust contract consumers; Perl bootstrap/validation, ActionIR, generated-source, and
    cursor dependents; Rust parser/compiler/runtime/serialized/emitted/generated paths and parser unit suite;
    exact ownership and malformed twins; formatting, whitespace, Knowledge, task/index, bounded histories, memory,
    all nine doctrines, and rendered mdBook.
  Canonical trigger: `none` — escalate only if verification requires cross-backend/public admission, self-hosted
    grammar or generated-format movement, infrastructure/storage/doctrine changes, or a mandatory history rollover;
    otherwise `.15.2` retains the designated exact staged canonical boundary.
  Acceptance: The Perl bootstrap/validation path and Rust source parser normalize a rule-item-leading balanced
    `{ ... }` directly to the same `I` lifecycle entry/node as an explicit marker at that exact body position.
    Preserve the authored block text/opening line while giving its interior the same ActionIR spans as the explicit
    twin; keep edge/function/callable/nested braces owned; make malformed twins diagnose equivalently. Lock bare/
    explicit equivalence across OR/AND and zero/one/two regex placements, including mixed explicit/bare duplicates
    in authored order. Repair Rust's existing last-`I`-wins compiler defect so duplicate explicit and shorthand
    blocks preserve that order without changing Perl's established placement-sensitive lifecycle lowering.
  Checklist: [x] clean activation/task ownership [x] Knowledge/toolbox retrieval [x] neutral twin fixture
    [x] Perl normalization/order/provenance/diagnostics [x] Rust normalization/order repair/provenance/diagnostics
    [x] direct/generated dependent proof [x] durable docs/memory/task/index synchronization [x] focused signoff
    [x] atomic commit/brief/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` is empty at
    `836c351e7261a49d3d31166047269c09881eefb2`; `git_message_brief.txt` is zero bytes; the committed canonical
    receipt matches that HEAD; the reproducible mdBook output is removed and no background job remains. `.15.0`
    is committed complete with ADR `0094` fixing direct lifecycle normalization and `.15.1` ownership.
  Pre-implementation finding: Rust's block consumer returns an interior string even when the outer close is
    missing, after which brace validation cannot see the removed opening delimiter. Its body-line loop also drops
    an unsupported remainder after a recognized element. This is the exact malformed-twin surface already owned
    here: retain exact consumed block source for balance proof and preserve unsupported remainder as invalid input,
    with explicit and shorthand lifecycle forms locked to the same failure.
  Implementation evidence: the neutral `linkedspec-standalone-lifecycle-block-v1` contract now owns nine OR/AND
    placement twins across zero/one/two regex slots, exact multiline/nested/quoted source, four authored-order
    duplicate mixes, the action/blind/callable/nested/function ownership boundary, three malformed twins, generated
    Perl/Rust carriers, and the legacy inert-node policy. Perl bootstrap metadata records explicit versus bare form,
    exact marker/block source, and opening line while lowering both forms to `ICODE`; validation scans nested and
    quoted delimiters and accepts a recognized same-line successor without swallowing an unsupported suffix. Rust
    retains exact outer source in `ConsumedBlock`, parses the bare form directly as lifecycle `I`, preserves only a
    same-line unsupported remainder for validation, and appends repeated `I` statements so the compiled ABI remains
    unchanged. A deliberately broad first Rust remainder check exposed a shipped function-body raw node and was
    narrowed to the lifecycle-`I` same-line boundary. Final review also preserves the prior interior-brace fallback
    for programmatic/older serialized lifecycle nodes whose source is empty or descriptive, while authored block
    nodes use exact outer source to expose a missing close; both compatibility repairs have dedicated proof and are
    recorded in `DEVELOPMENT_NOTES.md`.
  Focused signoff evidence: Perl syntax checks pass; the standalone Perl contract passes seven top-level
    tests, and the combined ActionIR/generated/cursor/standalone set passes 324 tests. Rust's 32 parser unit tests
    and the eight standalone parser/compiler/runtime/serialized/emitted/generated tests pass. `cargo fmt --check`,
    `git diff --check`, Knowledge Map 912/7,758, task partition/index, both bounded-history checks, the 16-row live
    view, exact repo/storage/readme/memory/acceptance/cadence invariants, rendered sole-facing mdBook, and all nine
    doctrines pass; the reproducible render is removed and no background job remains.
  Planned verification: focused — bounded Perl/Rust parser/compiler behavior with direct backend and generated-
    carrier dependents; no public/capability admission or infrastructure movement.
  Planned checks: neutral twin fixtures; Perl bootstrap/validation/live/generated probes and focused regressions;
    Rust parser/compiler/runtime/serialized/emitted/generated tests; explicit duplicate-order regression; existing
    action/blind/callable ownership and malformed diagnostics; doctrines, histories, memory, Knowledge, task/index,
    mdBook if behavior teaching moves, and whitespace.
  Planned canonical boundary: none; `.15.2` owns cross-backend/public admission and the next push boundary.
  Commit: `FUTURE-PARITY-BACKLOG.15.1 - implement Perl and Rust lifecycle shorthand`.

- ID: `FUTURE-PARITY-BACKLOG.15.2`
  Status: `done; canonical-signoff-complete` (2026-08-29; task-tree-first from exact clean Perl/Rust implementation commit
    `9321357507a7dd39d49793b5674c130b5b805ca4`; no push)
  Goal: Align Dart, Julia, Lua, generated paths, public examples, Knowledge Map, and complete no-drift proof.
  Dependencies: `.15.1`.
  Verification tier: `canonical` — this leaf changes the remaining three source backends/four runtime routes,
    self-hosted grammar authority, public examples/capability truth, recurring governance, parent closeout, and the
    batch push boundary together.
  Focused checks: neutral contract on Dart, Julia, PUC Lua, and LuaJIT; self-hosted/bootstrap precedence and AST
    equality; direct/serialized/reconstructed/emitted/generated carriers; legacy plain-node inertness; ownership,
    placement, authored duplicates, malformed twins, capability/language/public no-drift and adjacent progressive/
    gap/recognition/typed-source dependents; Knowledge, task/index, bounded histories, memory, all nine doctrines,
    rendered mdBook, and exact staged diff.
  Canonical trigger: `cross-backend/public admission + self-hosted grammar + parent closeout + push boundary` — the
    exact staged candidate must pass receipt-bound canonical local CI before commit and the resulting exact clean
    HEAD must pass the pre-push boundary before the batch push.
  Acceptance: Dart, Julia, and shared Lua source parsing normalize bare rule-item blocks to lifecycle `I` with the
    exact neutral equivalence, ordering, provenance, ownership, placement, and malformed boundaries; PUC Lua and
    LuaJIT prove the shared implementation independently. New source parsing emits no `PlainBlock`; legacy
    programmatic/serialized plain nodes and compiled `plain_action_payloads` remain inert compatibility data until
    a separately versioned retirement. `specs/spec.spec` gains the standalone production and can no longer
    misclassify reserved explicit lifecycle blocks as bare edges. All available reconstructed/emitted/generated,
    corpus, capability, diagnostics, examples, mdBook, Knowledge, roadmap, and no-drift projections agree; parent
    `.15` closes.
  Planned verification: canonical — cross-backend language admission, self-hosted grammar, public/capability state,
    generated carriers, parent closeout, and push boundary move together.
  Planned checks: all five source backends/six runtimes consume the neutral twin contract; self-hosted/bootstrap
    AST equality and reserved lifecycle precedence; available generated/reconstructed/emitted roles; capability,
    language coverage, public no-drift, mdBook render, doctrines, histories, task/index, Knowledge, memory, and
    whitespace.
  Planned canonical boundary: exact staged full local CI is mandatory for cross-backend/public admission, self-hosted
    grammar movement, parent closeout, and the final batch push boundary under ADR `0073`.
  Checklist: [x] clean activation/task ownership [x] Knowledge/toolbox and backend-authority retrieval
    [x] Dart normalization/provenance/order/diagnostics [x] Julia normalization/provenance/order/diagnostics
    [x] shared Lua normalization/provenance/order/diagnostics on both ABIs [x] self-hosted grammar precedence/equality
    [x] reconstructed/emitted/generated/legacy compatibility proof [x] recurring/capability/language/public admission
    [x] parent/roadmap/book/Knowledge/live synchronization [x] focused and exact staged canonical signoff
    [x] atomic commit/brief/clean push boundary.
  Activation evidence: exact `git status --short --untracked-files=all` is empty at
    `9321357507a7dd39d49793b5674c130b5b805ca4`; `.15.1` passes Perl 324/324, Rust neutral 8/8, Rust parser 32/32,
    rendered mdBook, and all nine doctrines; `git_message_brief.txt` is zero bytes, reproducible book output is
    removed, no background job remains, and no push occurred.
  Retrieval and RED evidence: `KNOWLEDGE_MAP.md` resolves the standalone lifecycle audit/ADR before source review;
    `TOOLBOX.md` selects the repository-routed Dart, Julia, PUC-Lua, LuaJIT, and self-hosted probes. Exact primary-
    command twins at activation HEAD return `"first-second"` for `Top:: I { return("first-second") }` and `null`
    for `Top:: { return("first-second") }` on Dart, Julia, PUC Lua, and LuaJIT. Source inspection locates the same
    cause in `dart/lib/src/parser/spec_parser.dart`, `julia/src/spec/Parser.jl`, and
    `lua/src/linkedspec/spec_parser.lua`: each bare branch emits its legacy plain node, while its compiler already
    preserves explicit lifecycle payloads in authored lists and its runtime consumes those lists. The repair is
    therefore parser/validation-local; legacy AST/compiled plain carriers stay readable and inert.
  Implementation evidence: Dart, Julia, and Lua now emit their existing lifecycle-`I` body kind for a bare block,
    retain exact authored outer source/opening line, preserve same-line unsupported remainder for validation, and
    use quote-aware outer balance with the prior interior fallback for programmatic/older nodes. No source parser
    emits a new plain node. All four duplicate mixtures return `first-second` through native, JSON-reconstructed,
    generated-plan, and emitted-source roles; legacy serialized plain nodes and compiled plain payloads remain
    readable and inert. The stable consumers pass Dart 6 tests, Julia 103 assertions, and shared Lua 109 assertions
    on each of PUC Lua and LuaJIT.
  Dart/Julia precedence repair: canonical attempts three and four exposed that the first suffix-preservation
    implementations also retained a recognized same-line `Child::AND /x/` header-shaped tail as raw body text. The
    generic validator failure masked the earlier typed recursive-observation target/operand diagnostics. Each
    frontend now preserves a lifecycle suffix only when its existing rule-header scanner does not recognize it;
    malformed twins remain exact and the existing dependent consumers pass without fixture changes. Shared Lua's
    corresponding fixtures use real line boundaries and remain correctly stopped by its existing header collector.
  Self-hosted/recurring evidence: `specs/spec.spec` adds `standalone_lifecycle_block` and a complete-line lifecycle
    route before generic bare-edge matching. Its four governed `spec_spec_*` corpus mirrors are byte-identical at
    SHA-256 `03cfb50459984806c806e9ec3f2b072add897c207a2cb93fd267d640a5808004`. The 25-test consumer proves explicit/
    bare semantic equality and all seven reserved markers retain lifecycle ownership. The recurring driver composes
    the neutral 9-placement/4-duplicate/6-owner/3-malformed/11-mutation checker, Perl 7, self-hosted 25, Rust 8,
    Dart 6, Julia 103, PUC Lua 109, LuaJIT 109, generated-source, capability 90/0/0, and language 250/105+1/126;
    all pass.
  Public/capacity evidence: the all-pass `language.standalone_lifecycle_block` row, ADR `0094`, Knowledge fact,
    user/backend guides, capability guide, roadmaps, architecture, and both mdBook chapters state the current
    five-backend/six-route contract. The required change record mechanically rolls exact activation-source lines
    235-450 into immutable `docs/history/changes/segment-4988-4251613b7181.md` (216 lines / 19,833 bytes), leaving
    the final hot shard at 252/512 lines and 22,201/65,536 bytes. The exact collection is 25 files / 47,264 lines /
    3,390,743 bytes with a 24-line manifest; ADR `0096` authorizes only finite capacity 24→25 files and manifest
    23→24 lines while retaining every byte, aggregate, per-segment, owner, lifecycle, verifier, route, and storage
    control.
  Signoff evidence: the composed standalone driver and its six runtime routes pass; focused formatting, syntax,
    adjacent contract, Knowledge/task/history/memory/doctrine/whitespace checks and rendered mdBook pass. The exact
    fully staged candidate passes receipt-bound canonical local CI with the standalone matrix enabled, then the
    atomic commit, zero-byte brief, exact clean pre-push boundary, and batch push complete without residue.
  Canonical attempt one: the Unicode rule-label freshness contract stops at the first stale `spec_spec_minimal_rule`
    mirror because canonical `specs/spec.spec` moved without its four byte-exact corpus snapshots. All four governed
    mirrors are synchronized through the same three grammar hunks; exact SHA equality and the focused checker pass
    before the corrected staged candidate restarts canonical CI from the beginning.
  Canonical attempt two: the corrected candidate passes all nine doctrines and reaches fresh Rust dependency
    compilation. Every active independent `rustc` child then receives simultaneous signal 15 with no crate
    diagnostic; the gate command has no internal timeout and a process census finds no survivor. This is external
    termination, not accepted proof or a code classification; the exact restaged candidate restarts from the now-
    warm repository-local build cache and must reach the real canonical terminus.
  Canonical attempt three: the warmed retry passes standalone, progressive, gap, and recognition admission across
    every backend, then the Dart typed-source/recursive-observation set catches the lifecycle-remainder diagnostic-
    precedence regression documented above. The corrected parser and exact existing dependent consumer pass before
    task/index/Knowledge/live surfaces are refreshed. A focused Dart fatal-warning check then removes one unused
    import from the new contract test; the fully restaged candidate restarts canonical CI only after that clean
    analysis and the corrected cross-backend recurring driver both pass.
  Canonical attempt four: the exact stage passes all nine doctrines and staged/progressive/gap/recognition admission
    across every backend. The repaired Dart typed-source/recursive-observation set passes 11/11, then Julia exposes
    its homologous two masked diagnostics. Root-cause audit covers Dart, Julia, and shared Lua; Julia receives the
    same rule-header exclusion, while Lua needs no slice-induced repair because its fixtures reach the existing
    line-boundary header collector. Exact Julia and recurring proof pass before canonical attempt five.
  Canonical attempt five: all changed-surface and broad language checks pass through ActionIR and primary CLI proof.
    The tool project-data oracle then rejects its deliberately frozen Python-entrypoint count because the owned
    standalone lifecycle checker is the 33rd maintained entrypoint. Inspection confirms it has no temporary
    allocator and already runs through the managed Python wrapper. Focused proof after the exact 32→33 repair then
    rejects the five-backend driver's governed repository-local `mktemp` workspace as a new 15th shell owner; both
    exact inventories, its workflow-routing enrollment, and the canonical Knowledge fact advance before the next
    exact staged retry.
  Canonical attempt six: the exact repaired candidate passes all prior language/admission checks and the corrected
    tool-storage oracle, then stops only when the outer Codex sandbox denies the process-locality oracle's nested
    macOS `sandbox-exec` with the known status 71 before its representative relocated driver starts. Canonical
    Knowledge already classifies this harness boundary; an unchanged permission-authorized full retry supplies the
    authoritative proof, with no production or oracle weakening.
  Canonical attempt seven: the permission-authorized exact candidate passes process containment, moved-root/outside-
    CWD execution, both 66-case CLI matrices, and every earlier gate. Phase 0 then reports one failure in 1,032:
    its bootstrap function-ownership guard raw-scans serialized payload text and mistakes `return(value)` inside the
    now-preserved lifecycle `ICODE` node for a function-definition payload. The repair traverses only structural
    array tags and hash identity fields, retaining exact `fn`/function-node rejection while allowing lifecycle body
    text; focused bootstrap proof passes before the next exact authorized canonical retry.
  Commit: `FUTURE-PARITY-BACKLOG.15.2 - complete standalone lifecycle parity`.

- ID: `FUTURE-PARITY-BACKLOG.15.3`
  Status: `done; canonical-signoff-complete` (2026-08-30; activated from exact clean focused write-vivification contract
    commit `81d0e863d59396e62159d3fe46bebed4a2988b8a`)
  Goal: Repair the stale Lua runtime-control fixture exposed by completed standalone lifecycle normalization.
  Dependencies: `.15.2`; `.19.1.1` clean commit boundary
  Verification tier: `canonical` — the runtime/test repair is narrow, but its mandatory complete engineering-notes
    record crosses the 90% hot-shard line threshold. The resulting official rollover, new immutable member,
    manifest update, finite route-capacity authorization, and final batch push boundary require exact staged
    receipt-bound local CI under ADR `0073`.
  Acceptance: Replace the accidental `/skip/ { next() }` fixture, whose bare block now correctly normalizes to
    lifecycle `I`, with an exact action-edge-owned skip case. Preserve the asserted consumed cursor and `keep`
    result; run the complete `lua/test/run.lua` harness on both ABIs; record the false-positive history and root
    cause in the standalone-lifecycle Knowledge owner. Do not weaken ADR `0094`, the neutral shorthand contract,
    or the runtime-control assertion. Repair any exact canonical census made stale by the already-committed
    `.19.1.1` checker only after the gate identifies it, preserving all project-data locality controls.
  Discovery evidence: exact PUC runs deterministically report only test 115 as failed: expected `keep`, got
    `json.null`. Direct AST/compiled projection shows `{ next() }` as the ratified lifecycle-`I` payload, and a
    minimal runtime probe returns matched/null at cursor 0 because entry lifecycle executes before regex
    iteration. The test was introduced with the original Lua interpreter while bare blocks were inert, so it
    passed without ever exercising `next()`; `.15.2` made the intended bare-block semantics executable and exposed
    the stale ownership. This is unrelated to write vivification and was queued here before any repair edit.
  Focused checks: complete `lua/test/run.lua` on PUC Lua and LuaJIT through the project-data wrapper; exact
    runtime-control assertion/result/cursor; standalone lifecycle contract and Knowledge owner; task/index,
    bounded histories, memory, tool project-data storage, rendered mdBook only if public teaching changes, all nine
    doctrines, and whitespace.
  Canonical trigger: `mandatory engineering-notes rollover + final batch push boundary` — the pre-record shard is
    already 460/512 lines. Add the complete `.15.3` record, apply the official content-addressed rollover, authorize
    only the exact finite collection/manifest capacity delta if required, and run canonical CI on the exact staged
    candidate. Parser/compiler/runtime behavior, neutral/public lifecycle contracts, generated formats, and
    capability state remain unchanged.
  Checklist: [x] exact clean activation/task ownership [x] Knowledge/ADR/toolbox/root-cause retrieval
    [x] action-edge fixture correction [x] complete PUC Lua harness [x] complete LuaJIT harness
    [x] standalone lifecycle no-drift [x] required notes rollover/capacity authorization
    [x] durable Knowledge/live-memory/task-index synchronization [x] exact staged canonical signoff
    [x] atomic commit/brief/clean push handoff.
  Activation evidence: `git status --short --untracked-files=all` is empty at exact `81d0e863`; the preceding
    `.19.1.1` hook passes all nine doctrines and its post-commit activation boundary; `git_message_brief.txt` is
    zero bytes; reproducible mdBook output is absent; no background verification remains. The clean commit queues
    this exact defect before `.19.1.2`, satisfying the pivot rule.
  Repair evidence: the fixture now uses `-> Skip { next() }` and child rule `Skip: /skip/`; direct execution returns
    `keep` at cursor 8. Complete `lua/test/run.lua` passes 178/178 independently on PUC Lua and LuaJIT. The neutral
    standalone checker remains 9 placements / 4 duplicate forms / 6 ownership cases / 3 malformed twins / 6 runtime
    routes / 15 public documents / 7 stale denials / 14 mutations, and its shared Lua consumer passes 109 assertions
    on each ABI. No production parser/compiler/runtime or public contract byte changes.
  Capacity evidence: the mandatory complete engineering-notes record triggers official content-addressed segment
    `docs/history/development-notes/segment-4987-d0f32351bfe7.md`, retaining a 236/512-line current root. ADR `0097`
    authorizes only collection 20→21 files and manifest 19→20 lines; the resulting store is 24,502/27,000 lines and
    2,623,818/3,145,728 bytes, with all root, member, aggregate, owner, lifecycle, verifier, storage, and path controls
    unchanged. No mdBook source moves because current user-visible semantics were already correct.
  Canonical attempt one: every preceding doctrine, contract, backend, MCP, semantic, fixture, and storage check
    passes through the Perl project-data oracle. The tool-storage oracle then rejects only its exact 35-entrypoint
    census because committed `.19.1.1` added repository-routed `tools/check_write_vivification_contract.py` as the
    36th Python tool. The checker allocates no temporary workspace and already runs through
    `tools/run_python_project_data.sh`; this leaf owns the stale census/KM repair before rerunning the exact staged
    canonical candidate from the beginning.
  Signoff evidence: direct result/cursor proof, both complete Lua harnesses, both standalone consumers, neutral
    contract/no-drift, Knowledge Map, task partition/index, both bounded histories, rendered sole-facing mdBook,
    all nine doctrines, whitespace, and the exact staged receipt-bound canonical local CI pass. The commit hook and
    final clean pre-push boundary reuse that proof before the accumulated batch is pushed.
  Verification: **PASS 2026-08-30.** Exact staged canonical signoff completes the fixture repair and notes-capacity
    transition without behavior movement; `.19.1.2` is the next clean roadmap-aligned leaf.
  Commit: `FUTURE-PARITY-BACKLOG.15.3 - repair Lua next fixture ownership`

- ID: `FUTURE-PARITY-BACKLOG.16`
  Status: `done`
  Goal: Complete the deliberately narrow punctuation-light zero-argument call surface without creating a general
    parenthesis-free call grammar.
  Children: `.16.0`, `.16.1`, `.16.2`, `.16.3`, `.16.4`, `.16.5`, `.16.6`, `.16.7`
  Acceptance: Standalone zero-argument flow markers accept `else`, `endif`, `default`, `endcase`, `endswitch`,
    and `next` wherever their parenthesized forms are valid; the final call in an ActionIR receiver chain may use
    `.method` exactly when it has no authored arguments; existing parenthesized forms remain valid; intermediate
    receiver calls, calls with arguments, ordinary helper/user-function calls, and condition-bearing `if`/`while`
    headers retain parentheses. All five backends, available generated paths, diagnostics, examples, and public
    contracts agree; future generated Lua preservation remains owned by `LUA-BACKEND-PARITY.8.1-.8.4`.
  Verification: **PASS 2026-07-13.** Design/contract leaves `.16.0-.16.2`, backend leaves `.16.2.1-.16.6`, and
    public/capability no-drift `.16.7` are complete. One recurring five-backend/two-Lua-ABI command locks the
    exact alias and exclusion surface. Capability census is 64/0/0, current examples prefer the admitted syntax
    selectively, and no path claims parenthesis-free condition headers or nonexistent generated Lua.

- ID: `FUTURE-PARITY-BACKLOG.16.0`
  Status: `done`
  Goal: Audit and ratify the exact existing/missing punctuation-light zero-argument surfaces before behavior code.
  Acceptance: Distinguish rule-edge/lifecycle fluent suffix parsing from ActionIR expression parsing; inventory
    bare `else`/`endif`/`default`/`endcase`/`endswitch` and `next` across Perl, Rust, Dart, Julia, and Lua; inventory
    final bare receiver parsing and contract resolution; prove the final-segment boundary is unambiguous; record
    exclusions for intermediate bare calls, attached final-codeblock calls, arbitrary helpers/user functions, and
    parenthesis-free condition headers; split backend and no-drift leaves from source-backed evidence.
  Verification: **PASS 2026-07-13.** Source-backed audit distinguishes established rule-edge/lifecycle fluent
    suffix handling from the five ActionIR parsers. Perl, Dart, and Julia normalize the five existing bare control
    markers; Rust parses them as variables outside attached-control synthesis; Lua normalizes only bare
    `else`/`otherwise`/`default`. No backend recognizes bare `next` as the current call. Perl, Rust, Dart, and Julia
    require parentheses for every ActionIR receiver segment; Lua currently accepts a bare identifier in every
    segment. All five rule/lifecycle suffix parsers already preserve zero-argument bare suffixes. ADR 0033 adopts
    the narrow six-marker plus final-receiver contract, keeps condition headers/calls-with-arguments/general calls
    parenthesized, and splits one neutral contract plus five backend and no-drift leaves. No behavior source changed.
  Commit: `FUTURE-PARITY-BACKLOG.16.0 - ratify zero-argument call aliases`

- ID: `FUTURE-PARITY-BACKLOG.16.1`
  Status: `done`
  Goal: Add one backend-neutral syntax/AST/diagnostic fixture contract for the ratified zero-argument aliases.
  Dependencies: `.16.0`
  Acceptance: Positive cases cover all six standalone markers and terminal `.method`; negative cases preserve
    parentheses on condition headers, argument-bearing calls, non-final bare receiver segments, and nonzero-arity
    terminal methods; the contract is reusable by native and generated backends.
  Verification: **PASS 2026-07-13.** Strict contract `linkedspec-punctuation-light-zero-arg-v1` fixes six
    standalone equivalences, four terminal-receiver equivalences, three retained bare value reads, six invalid
    syntax classes, two arity-resolution cases, and one deterministic future fixture. The independent checker
    proves bare/parenthesized AST equality, final-only receiver recognition, unchanged condition-header/general-
    call/trailing-block boundaries, existing method-contract delegation, exact fixture rendering/evaluation, and
    three mutation failures. Canonical local CI passes capability 60/0/0, primary CLI 61/61 twice, and Phase 0
    `1..1031` in 604 seconds. No backend parser/runtime behavior changed and the capability remains future-owned.
  Commit: `FUTURE-PARITY-BACKLOG.16.1 - adopt zero-argument syntax contract`

- ID: `FUTURE-PARITY-BACKLOG.16.2`
  Status: `done`
  Goal: Implement and regression-lock the ratified aliases on the Perl reference backend after calibrating the
    neutral arity example against the existing helper contract.
  Dependencies: `.16.1`
  Children: `.16.2.0`, `.16.2.1`
  Acceptance: Statement splitting, typed control parsing, `next` scanning/lowering, and fluent AST parsing map
    aliases to the same zero-argument nodes/descriptors/runtime behavior as parenthesized calls; generic bare
    receiver parsing is final-only; generated Perl and normal execution agree; exclusions diagnose unchanged.
  Verification: **PASS 2026-07-13.** Arity calibration `.16.2.0` and Perl implementation `.16.2.1` close the
    parent. The Perl reference consumes all six standalone aliases and four terminal receiver cases while keeping
    general calls, intermediate receiver segments, receiver trailing blocks, and condition-bearing `if`/`while`
    headers unchanged. Live and standalone generated execution match the neutral fixture exactly.
  Commit: completed by `.16.2.0` and `.16.2.1`

- ID: `FUTURE-PARITY-BACKLOG.16.2.0`
  Status: `done`
  Goal: Correct the neutral nonzero-arity receiver example exposed by the Perl reference preflight before parser
    behavior changes.
  Dependencies: `.16.1`
  Acceptance: LinkedSpec toolbox output and the canonical helper-arity table prove `drop_front` has zero-or-one
    authored receiver arguments; replace it with an actually required-argument receiver method without changing
    the ratified terminal-call rule, fixture, or any backend parser/runtime; update durable facts and rerun the
    strict contract plus canonical gates.
  Verification: **PASS 2026-07-13.** `call_spec_handler_subst` proves `.drop_front()` lowers as the established
    default-one operation and `.contains()` follows the missing-argument unsupported-helper path. The canonical
    `%ast_aggregate_call_arity` table records function-form `drop_front` `[1,2]` and `contains` `[2,2]`, hence
    authored receiver arities `[0,1]` and `[1,1]`. The neutral required-argument example now uses `contains`; the
    strict checker and mutations pass unchanged, capability remains 60/0/0, CLI passes 61/61 twice, and Phase 0
    passes `1..1031` in 605 seconds. No backend parser/compiler/runtime behavior changed.
  Commit: `FUTURE-PARITY-BACKLOG.16.2.0 - calibrate receiver arity fixture`

- ID: `FUTURE-PARITY-BACKLOG.16.2.1`
  Status: `done`
  Goal: Implement the unchanged punctuation-light contract on the Perl reference backend.
  Dependencies: `.16.2.0`
  Acceptance: Statement splitting, typed control parsing, `next` scanning/lowering, and fluent AST parsing map
    aliases to the same zero-argument nodes/descriptors/runtime behavior as parenthesized calls; generic bare
    receiver parsing is final-only; generated Perl and normal execution agree; exclusions diagnose unchanged.
  Verification: **PASS 2026-07-13.** The Perl typed parser maps all six standalone bare forms to the same semantic
    ASTs as their parenthesized calls and accepts a bare generic receiver identifier only as the final segment.
    Exact bare `next` scans as canonical `NEXT`, lowers identically to `next()`, and no longer enters compatibility
    metadata; labeled `next LABEL` remains separately compatible. Ordinary value-position `next` stays a variable,
    all six neutral exclusions retain their existing raw/invalid reasons, and method resolution remains unchanged.
    The deterministic fixture returns `{result: "yes", picked: "a", count: 2}` in live and standalone generated
    Perl. Focused AST/contract tests pass; canonical CI passes capability 60/0/0, CLI 61/61 twice, and Phase 0
    `1..1031` in 611 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.16.2.1 - implement Perl zero-argument aliases`

- ID: `FUTURE-PARITY-BACKLOG.16.3`
  Status: `done`
  Goal: Implement and regression-lock the ratified aliases on the Rust backend and Rust oracle/generated paths.
  Dependencies: `.16.1`, `.16.2`
  Acceptance: Rust ActionIR parsing emits the same typed calls/controls for aliases and parenthesized forms,
    preserves final-only receiver and condition-header boundaries, executes the neutral contract identically,
    and passes native, oracle, and generated-source proof.
  Verification: **PASS 2026-07-13.** Rust recognizes the six enumerated names only at an exact statement
    boundary and admits a generic bare receiver identifier only when it is terminal. Bare and parenthesized forms
    share the same typed `Expr::Call` / `Expr::FluentChain`; value-position `next` remains a variable and all six
    excluded forms retain their prior parse failures. The unchanged fixture returns
    `{result: "yes", picked: "a", count: 2}` natively, after compiled-state serialization, through emitted source
    validation, and through generated-plan execution. The rebuilt CLI returns that exact object for bare and
    parenthesized `.spec` files. The complete Rust gate passes 137 runtime unit tests, 105-fixture Perl oracle,
    105 generated-source classifications, 197 integration tests, the new 5-test contract, focused source/loader/
    trace/Unicode suites, and CLI 61/61 twice. Preflight also exposed a pre-existing helper gap: Rust
    `.contains()` defaults an absent needle to empty text and returns `0`, unlike Perl's missing-argument
    rejection; the new alias preserves the parenthesized Rust outcome and backlog `.5` now owns normalization.
  Commit: `FUTURE-PARITY-BACKLOG.16.3 - implement Rust zero-argument aliases`

- ID: `FUTURE-PARITY-BACKLOG.16.4`
  Status: `done`
  Goal: Implement and regression-lock the ratified aliases on the Dart backend and generated path.
  Dependencies: `.16.1`, `.16.2`
  Acceptance: Dart normalizes all six standalone forms and final generic receiver form to the same typed AST,
    retains the negative boundaries and diagnostics, and passes native plus generated execution of the unchanged
    neutral contract.
  Verification: **PASS 2026-07-13.** Dart's statement parser recognizes exact bare `next` only in statement
    context, preserving expression/value-position `next` as a variable, while its existing control-head
    normalization already covers the other five standalone markers. Fluent parsing admits a generic bare
    identifier only in the terminal receiver segment and synthesizes the same empty-argument typed call as `()`.
    The neutral contract proves six statement and four receiver semantic-AST equivalences, ordinary identifier
    retention, all six unchanged exclusions, and existing arity outcomes. The fixture returns
    `{result: "yes", picked: "a", count: 2}` through native execution, generated-plan execution, emitted-state
    reconstruction, and exact bare/parenthesized CLI twins. The complete Dart gate passes format, strict analysis,
    211 package tests, CLI 61/61 twice, and corpus 105/105. Dart's pre-existing `.contains()` missing-argument
    result matches its parenthesized twin at `0`; helper normalization remains owned by `.5`.
  Commit: `FUTURE-PARITY-BACKLOG.16.4 - implement Dart zero-argument aliases`

- ID: `FUTURE-PARITY-BACKLOG.16.5`
  Status: `done`
  Goal: Implement and regression-lock the ratified aliases on the Julia backend and generated path.
  Dependencies: `.16.1`, `.16.2`
  Acceptance: Julia normalizes all six standalone forms and final generic receiver form to the same typed AST,
    retains the negative boundaries and diagnostics, and passes native plus generated execution of the unchanged
    neutral contract.
  Verification: **PASS 2026-07-13.** Julia's statement parser recognizes exact bare `next` only in statement
    context, preserving expression/value-position `next` as a variable, while its existing control-head
    normalization already covers the other five standalone markers. Fluent parsing admits a generic bare
    identifier only in the terminal receiver segment and synthesizes the same empty-argument typed call as `()`.
    The neutral contract proves six statement and four receiver semantic-AST equivalences, ordinary identifier
    retention, all six unchanged exclusions, and existing arity outcomes. The fixture returns
    `{result: "yes", picked: "a", count: 2}` through native execution, generated-plan execution, emitted-state
    reconstruction, and exact bare/parenthesized CLI twins. The complete Julia gate passes 1,394 package
    assertions, primary CLI conformance, and corpus 105/105. Julia's pre-existing `.contains()` missing-argument
    result matches its parenthesized twin at `0`; helper normalization remains owned by `.5`.
  Commit: `FUTURE-PARITY-BACKLOG.16.5 - implement Julia zero-argument aliases`

- ID: `FUTURE-PARITY-BACKLOG.16.6`
  Status: `done`
  Goal: Align Lua's parser-ahead bare receiver behavior with the final-only contract and add all standalone aliases
    on both PUC Lua and LuaJIT without preempting the parked runtime leaf.
  Dependencies: `.16.1`, `.16.2`
  Acceptance: Lua normalizes all six standalone forms; generic bare receiver calls are accepted only in the final
    segment; existing rule/lifecycle control-marker suffixes and attached `else`/`default` remain valid; both ABIs
    pass the neutral typed-AST, serialized-state, native execution, and negative-diagnostic contract without
    changing `.4.3.6.4` runtime scope. Lua generated source does not yet exist and remains owned by
    `LUA-BACKEND-PARITY.8.1-.8.4`; that later emitter must preserve the already-normalized typed state.
  Verification: **PASS 2026-07-13.** Lua now normalizes all five structural markers in `parse_control(...)` and
    exact bare `next` only while constructing a complete statement, preserving expression/value-position `next`
    as a variable. The parser-ahead generic bare receiver path is narrowed from every segment to the terminal
    segment and explicitly rejects a receiver trailing block without `()`. The neutral contract proves six
    statement and four receiver semantic-AST equivalences, three retained identifiers, all six negative classes,
    method-resolution twins, and the exact fixture after public SpecFile JSON serialization/reconstruction. The
    fixture returns `{result: "yes", picked: "a", count: 2}` natively on PUC Lua 5.4 and LuaJIT. Both complete
    local gates pass 109/109 plus corpus validation/scaffold checks. Lua's pre-existing `.contains()` no-needle
    result remains `0` and joins Rust/Dart/Julia under helper owner `.5`. No Lua emitter exists; generated-source
    preservation remains explicitly owned by `LUA-BACKEND-PARITY.8.1-.8.4`.
  Commit: `FUTURE-PARITY-BACKLOG.16.6 - implement Lua zero-argument aliases`

- ID: `FUTURE-PARITY-BACKLOG.16.7`
  Status: `done`
  Goal: Migrate current examples where useful and close mdBook, grammar, Knowledge Map, roadmap, generated-source,
    corpus, capability, and complete no-drift alignment.
  Dependencies: `.16.2`, `.16.3`, `.16.4`, `.16.5`, `.16.6`
  Acceptance: Current examples prefer the punctuation-light spelling where it improves readability; all public
    text clearly preserves parentheses for the general call grammar and condition headers; recurring scans and
    complete backend gates prove no parser, available generated-source, diagnostic, or documentation drift; Lua's
    future generated-source preservation remains explicitly owned by `LUA-BACKEND-PARITY.8.1-.8.4`; `.16` closes.
  Verification: **PASS 2026-07-13.** The capability census promotes
    `language.punctuation_light_zero_argument_aliases` to pass on all four established census backends and removes
    its future exclusion, advancing the exact census from 60/0/0 to 64/0/0. Public examples selectively prefer
    bare markers and terminal receivers while explicitly retaining parenthesized twins and condition headers.
    `tools/check_punctuation_light_five_backend.sh` composes the neutral checker, Perl 7 assertions, Rust 5 tests,
    Dart 5 tests, Julia 55 assertions, and the complete Lua 109/109 PUC plus 109/109 LuaJIT gates. Native,
    serialized, and every available generated route return the exact fixture; Lua generated-source ownership
    stays with `.8.1-.8.4`. A closeout scan found the generated-source checker and current public summaries still
    hard-coded the former 15/60 census; the checker now derives status totals from the manifest and reports
    64/0/0. Capability, docs, ADR, Knowledge Map, roadmap, task, and canonical CI wiring agree.
  Commit: `FUTURE-PARITY-BACKLOG.16.7 - admit punctuation-light aliases`

- ID: `FUTURE-PARITY-BACKLOG.17`
  Status: `done`
  Goal: Reconcile the complete documented current named-mark helper surface across every backend and its coverage
    inventory.
  Children: `.17.0`, `.17.1`, `.17.2`, `.17.3`, `.17.4`, `.17.5`
  Acceptance: The seven public current helpers outside the governed 239-name inventory—`mark_entry_start/end`,
    `mark_match_start/end`, `mark_line`, `mark_col`, and `clear_mark`—have one neutral exact contract and execute
    identically on Perl, Rust, Dart, Julia, and Lua; generated paths preserve them where available; inventory and
    coverage gates cannot pass through a symmetric omission; public docs, capabilities, KM, and task state agree.
  Verification: **PASS 2026-07-15.** One exact contract and five-backend execution rollout admit the seven names
    into the aligned 246-name inventories. Coverage supplements the 105-case corpus with the exact named-mark
    fixture, independently derives all 122 public Perl contracts, and rejects the exact nine classified
    compatibility/legacy/internal names. A simultaneous three-inventory `clear_mark` mutation is detected by both
    the exact-family and independent reverse checks. Complete backend and canonical gates pass.
  Commit: `FUTURE-PARITY-BACKLOG.17.5 - admit complete named mark inventory`

- ID: `FUTURE-PARITY-BACKLOG.17.0`
  Status: `done`
  Goal: Classify the inventory blind spot and split complete named-mark parity before behavior changes.
  Acceptance: Compare all non-compatibility Perl contract diagnostics with the aligned backend inventories;
    distinguish internal operators, legacy/compatibility names, and public current calls; prove the seven-helper
    gap from source and book evidence; define neutral/backend/admission owners and return to the Lua `.4.3.7.1`
    frontier without changing parser/compiler/runtime behavior.
  Verification: **PASS 2026-07-13.** Direct contract/inventory comparison produces exactly 16 names and classifies
    seven public current marks, two compatibility map aliases, two legacy capture names, and five internal lowering
    operations. The still-green 239-name/105-fixture report proves the corpus-seeded blind spot. `.17.1-.17.5`
    own exact neutral/Perl/Rust, Dart, Julia, Lua, and admission/gate work. Knowledge Map, memory architecture, task
    metadata, doctrines, mdBook, and whitespace checks pass; no runtime, inventory, corpus, or capability changed.
  Commit: `FUTURE-PARITY-BACKLOG.17.0 - split complete named mark parity`

- ID: `FUTURE-PARITY-BACKLOG.17.1`
  Status: `done`
  Goal: Adopt the exact seven-helper neutral contract and align Perl/Rust execution.
  Dependencies: `.17.0`
  Acceptance: One unchanged fixture covers entry/local start/end mark writes, Unicode position/line/column reads,
    clear/existence behavior, symbolic bare names, absent marks, rule-local isolation, and generated preservation;
    Perl proves the reference result and Rust native/oracle/generated paths match it.
  Verification: **PASS 2026-07-13.** The strict neutral checker locks seven helpers, the unchanged Unicode
    parent/child fixture, and three rejected drift mutations. Perl live and standalone-generated execution match;
    Rust native, serialized, emitted-plan, and generated execution match the same value. The complete Rust package
    passes 188 core, 137 runtime, 105 oracle, 105 generated-corpus, 197 integration, and all specialized suites.
    The first canonical gate measured only two stale Phase-0 top-level source-lock subtests; migrating their exact
    19 guarded trace-edge strings produces capability 64/0/0, CLI 61/61 twice, and Phase 0 `1..1031` in 983 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.17.1 - align Perl Rust complete named marks`

- ID: `FUTURE-PARITY-BACKLOG.17.2`
  Status: `done`
  Goal: Align Dart complete named-mark execution and inventory.
  Dependencies: `.17.1`
  Acceptance: Dart consumes the unchanged neutral contract through native/generated/emitted-state/CLI paths,
    preserves code-unit storage with character-based public values, and adds exactly the seven current names.
  Verification: **PASS 2026-07-13.** The exact staged seven-name inventory is
    exported and folded into Dart's known-call/capture-mark boundaries while remaining disjoint from the legacy
    shared 239-name set. Native, generated-plan, emitted-state reconstruction, and primary-CLI execution return
    the unchanged Unicode parent/child value. Format and fatal analysis pass; the focused compatibility set passes
    68 tests, and the complete Dart gate passes all 214 package tests, CLI 61/61 twice, and corpus 105/105. The
    canonical repository gate passes capability 64/0/0, the unchanged shared 239-name/105-fixture coverage check,
    CLI 61/61 twice, and Phase 0 `1..1031` in 1,061 seconds; docs/KM/governance/book/whitespace also pass.
  Commit: `FUTURE-PARITY-BACKLOG.17.2 - align Dart complete named marks`

- ID: `FUTURE-PARITY-BACKLOG.17.3`
  Status: `done`
  Goal: Align Julia complete named-mark execution and inventory.
  Dependencies: `.17.2`
  Acceptance: Julia consumes the unchanged neutral contract through native/generated/emitted-state/CLI paths,
    preserves code-unit storage with character-based public values, and adds exactly the seven current names.
  Verification: **PASS 2026-07-14.** The exact staged seven-name inventory is
    exported and folded into Julia's known-call/capture-mark boundaries while remaining disjoint from the legacy
    shared 239-name set. Native, generated-plan, emitted-state reconstruction, and primary-CLI execution return
    the unchanged Unicode parent/child value. The focused contract passes 13 assertions, and the complete Julia
    gate passes 1,414 package assertions, shared CLI 61/61 twice, and corpus 105/105. The canonical repository
    gate passes capability 64/0/0, the unchanged shared 239-name/105-fixture coverage check, CLI 61/61 twice, and
    Phase 0 `1..1031` in 614 seconds; docs/KM/governance/book/whitespace also pass.
  Commit: `FUTURE-PARITY-BACKLOG.17.3 - align Julia complete named marks`

- ID: `FUTURE-PARITY-BACKLOG.17.4`
  Status: `done`
  Goal: Align Lua complete named-mark execution and inventory without a backend-only dialect.
  Dependencies: `.17.1`, `.17.2`, `.17.3`, `LUA-BACKEND-PARITY.4.3.7.2`
  Acceptance: Lua consumes the unchanged neutral contract on PUC Lua and LuaJIT through its rule-local named-mark
    frame and Unicode projection seam; the seven calls join the shared inventory only with all established
    backends aligned, and `LUA-BACKEND-PARITY.4.3.7.3` consumes rather than duplicates the implementation.
  Verification: **PASS 2026-07-14.** Lua resolves exactly the seven staged calls through a parse-scoped
    rule-label/mark-name/UTF-8-byte-offset store, existing entry/local match registers, and Unicode public
    projections. Bare names remain symbolic, clear is rule-local, and a same-name child mark cannot replace its
    parent's checkpoint. Native and serialized `SpecFile` reconstruction return the unchanged neutral value.
    `bash tools/run_lua_local.sh` passes 119/119 on separately built PUC Lua and LuaJIT adapters plus syntax,
    CLI-scaffold, and exact 105-fixture manifest checks. The legacy shared inventory remains exactly 239 names.
    Canonical CI passes capability 64/0/0, shared coverage 239/105, CLI 61/61 twice, and Phase 0 `1..1031` in
    627 seconds; doctrine, Knowledge Map, mdBook, and whitespace checks also pass.
  Commit: `FUTURE-PARITY-BACKLOG.17.4 - align Lua complete named marks`

- ID: `FUTURE-PARITY-BACKLOG.17.5`
  Status: `done`
  Goal: Admit complete named-mark inventory and close the symmetric-omission gate weakness.
  Dependencies: `.17.1`, `.17.2`, `.17.3`, `.17.4`
  Acceptance: Coverage derives or checks the complete public-current contract set independently of corpus seeding;
    inventories, neutral fixtures, exact outputs, all available generated paths, mdBook, capability census, KM,
    roadmaps, and complete local gates agree; `.17` closes and Lua `.4.3.7.3` may claim full named-mark parity.
  Verification: **PASS 2026-07-15.** Dart, Julia, and Lua admit the exact seven names into equal 246-name shared
    inventories while retaining exact family views. The coverage gate now uses 105 corpus fixtures plus the
    complete named-mark fixture, independently checks all 122 public identifier-shaped Perl contracts, and locks
    nine compatibility/legacy/internal exclusions. A simultaneous three-backend `clear_mark` deletion reports it
    through both the exact-family and independent-public checks. Exact contract and Perl/Rust focused proofs pass;
    complete Dart 214/CLI 61x2/corpus 105, Julia 1,414/CLI 61x2/corpus 105, Lua 119/119 on both ABIs, and the full
    Rust package/CLI 61x2 gates pass. Canonical CI passes capability 64/0/0, coverage 246/105+1/122, CLI 61x2,
    and Phase 0 `1..1031` in 633 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.17.5 - admit complete named mark inventory`

- ID: `FUTURE-PARITY-BACKLOG.18`
  Status: `proposed`
  Goal: Govern the post-current-backend-parity Unicode structured-text-to-AST format program.
  Children: `.18.0`, `.18.1`, `.18.2`, `.18.3`; detailed execution trees:
    `STRUCTURED-TEXT-FORMAT-PROGRAM`, `NATIVE-PARSER-ACCELERATOR`
  Acceptance: The agreed program is dependency-gated on complete Perl/Rust/Dart/Julia/Lua parity, enumerates every
    eligible catalog row, makes the dynamically compiled `.spec` graph the sole parser source, uses real formats
    as requirements evidence for reusable `.spec` features, forbids hidden host parsers, separates parsing from
    evaluation/domain semantics, governs those features as terse/readable/highly expressive without discarding
    semantic signal, and keeps roadmap/book/KM/live state exact.
    Dynamic format-parser construction and execution are also correlated through the neutral trace contract, with
    exact emission-only rule filters and shared non-interference proof owned after current parity.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.18.0`
  Status: `done`
  Goal: Ratify and durably decompose the post-parity Unicode structured-text format program.
  Dependencies: director/engineer agreement; execution dependencies live in `STRUCTURED-TEXT-FORMAT-PROGRAM.1`.
  Acceptance: ADR, dedicated detailed tree, exact 91-row eligible inventory, exclusion boundary, parity-first gate,
    dynamic `.spec`-graph sole-source contract, roadmap/index/live-doc/mdBook/Knowledge Map sync, and no behavior change.
  Verification: **PASS 2026-07-15.** Direct source/task extraction reports 91/91 unique eligible row names with
    zero missing/extra; the dedicated tree preserves exact binary/container exclusions. ADR `0034`, roadmap/index/live docs, mdBook,
    and Knowledge Map agree on full-current-backend parity first, dynamic `.spec`-graph sole-source construction,
    format-driven general features, no hidden host parser, layered syntax reuse, independent full HTML,
    parsing/evaluation separation, explicit future decoder
    seams, and measured correctness-preserving performance. Governance/book/count/whitespace checks pass; no
    parser/compiler/runtime/helper/fixture/capability or format behavior changed.
  Commit: `FUTURE-PARITY-BACKLOG.18.0 - adopt structured text requirements program`

- ID: `FUTURE-PARITY-BACKLOG.18.1`
  Status: `done`
  Goal: Govern terse, readable, and highly expressive universal `.spec` authoring without erasing semantic signal.
  Dependencies: `.18.0`
  Acceptance: A durable neutral doctrine defines concision, readability, expressiveness, orthogonal composition,
    diagnostic precision, representative-format evidence, and the uniform value-binding precedent; explicitly
    retains semantically informative recursive traversal names; synchronizes ADR, roadmap, dedicated program tree,
    mdBook, Knowledge Map, and live docs; and changes no parser/compiler/runtime behavior.
  Verification: **PASS 2026-07-15.** ADR `0035`, the structured-format program, roadmap/index/live docs, mdBook,
    and Knowledge Map define terseness as removal of redundant ceremony, readability as local predictability, and
    expressiveness as small typed orthogonal composition. Uniform binding is the positive precedent. Recursive
    `walk_leaves`/`map_leaves`/`reduce_leaves` retain their semantic suffix and gain no short aliases. Memory
    architecture, Knowledge Map, doctrines, mdBook, task metadata, and whitespace checks pass. No syntax,
    parser/compiler/runtime, helper, alias, fixture, inventory, capability, or format behavior changed.
  Commit: `FUTURE-PARITY-BACKLOG.18.1 - govern expressive spec authoring`

- ID: `FUTURE-PARITY-BACKLOG.18.2`
  Status: `done`
  Goal: Govern end-to-end, selectively focused observability for dynamically constructed format parsers.
  Dependencies: `.18.1`; execution remains gated by `STRUCTURED-TEXT-FORMAT-PROGRAM.1`.
  Acceptance: A durable neutral contract requires compile-time tracing from `.spec` graph load through staged
    parsing, validation, contract resolution, cache identity, and compiled plan; runtime tracing through rule,
    branch, cursor/capture, AST-emission, recovery, and diagnostic behavior; the existing ordered trace levels and
    sinks; exact rule-label filtering that changes emission only; correlated source/spec/rule identity; bounded
    diagnostic payloads; traced/untraced semantic identity; reusable cross-backend fixtures; and roadmap/program/
    mdBook/Knowledge Map/live-doc synchronization without changing current parser/compiler/runtime behavior.
  Verification: **PASS 2026-07-15.** Knowledge Map-first trace inspection confirms the existing neutral ordered
    levels/sinks and completed Perl/Rust plus Dart/Julia full native-pipeline propagation; Lua runtime trace is
    complete while full frontend/compiler/function/staged propagation remains correctly owned by `.5.3`. ADR
    `0037` makes construction plus execution observability a format-readiness contract, adopts future exact
    rule-label allowlists as emission-only filters, correlates spec/cache/rule/source/position identity, bounds
    payloads, and requires shared traced/untraced parity proof. `STRUCTURED-TEXT-FORMAT-PROGRAM.2.7` owns the
    executable neutral contract after current parity. The stale pre-full-pipeline Dart mdBook section and one
    duplicated Julia bullet are removed. Memory architecture, Knowledge Map, doctrines, task metadata, mdBook,
    and whitespace checks pass; no parser/compiler/runtime/CLI/trace behavior changes.
  Commit: `FUTURE-PARITY-BACKLOG.18.2 - govern selective parser observability`

- ID: `FUTURE-PARITY-BACKLOG.18.3`
  Status: `done`
  Goal: Govern an optional backend-native acceleration tier derived from dynamic `.spec` parsers.
  Dependencies: `.18.2`; implementation requires at least one completed dynamic format parser and objective
    benchmark evidence.
  Acceptance: Audit generated-source v1 before planning; preserve load-`foo.spec` immediate dynamic parsing as the
    primary contract and sole source of truth; distinguish current semantic source wrappers from an optimizing
    compiler; define native artifacts as fingerprinted disposable derivatives of normalized compiled IR; require
    exact AST/diagnostic/Unicode/recovery/trace equivalence, source/rule correlation, safe trust/toolchain
    boundaries, deterministic invalidation and dynamic fallback, correctness-preserving cold/warm/parse
    benchmarks, backend-specific strategies without making acceleration a format-support or semantic-parity gate,
    a separate detailed horizon tree, and roadmap/program/mdBook/Knowledge Map/live-doc synchronization without
    changing current behavior.
  Verification: **PASS 2026-07-15.** Knowledge Map-first generated-source audit confirms v1 already supplies
    deterministic identity, normalized compiled state, independent host loading, portable trace roles, and
    dynamic-oracle equivalence, but its current wrappers/state reconstruction make no optimizing-compiler or speed
    claim. ADR `0038` and `NATIVE-PARSER-ACCELERATOR` preserve dynamic/warm/native tiers, the dynamic parser as
    primary/oracle/fallback, exact behavioral/trace equivalence, complete fingerprint/invalidation, explicit
    toolchain/trust boundaries, objective build/load/break-even proof, backend-specific internal strategies, and
    optional Perl participation. Program/roadmap/index/live-doc/mdBook/Knowledge Map alignment and governance/
    book/whitespace checks pass; no code, behavior, capability, format support, or benchmark claim changes.
  Commit: `FUTURE-PARITY-BACKLOG.18.3 - plan optional native parser acceleration`

- ID: `FUTURE-PARITY-BACKLOG.19`
  Status: `in progress; Rust .19.3.1 active`
  Goal: Add portable explicit nested-write vivification and receiver-mutating method semantics without hidden
    reads, host-language aliasing, or backend drift.
  Children: `.19.0`, `.19.1`, `.19.2`, `.19.3`, `.19.4`, `.19.5`, `.19.6`, `.19.7`
  Acceptance: The language distinguishes reads from creating writes, defines path/container/conflict/gap semantics
    neutrally, uses `!` only for methods that genuinely mutate their receiver and have a clear non-mutating twin,
    preserves root-kind traversal and stable callback paths, reaches exact Perl/Rust/Dart/Julia/Lua parity, and
    closes capability/public/book/KM/no-drift proof before the parent is done.

- ID: `FUTURE-PARITY-BACKLOG.19.0`
  Status: `done`
  Goal: Audit current nested-path/traversal/method grammar and ratify the portable write-vivification/receiver-
    mutation direction before syntax or runtime code.
  Dependencies: `.18.1`
  Acceptance: Knowledge Map and exact current-contract evidence establish the non-vivifying nested-write boundary,
    uniform-binding top-level creation, both root-kind traversal contracts, callback path/value scope, and current
    identifier grammar; a durable decision fixes accepted creation/gap/conflict/method invariants and exclusions
    while routing exact AST/diagnostic/re-entrancy contracts to `.19.1`; implementation is split per backend plus
    admission; roadmap, mdBook, KM, and live docs align; no syntax/parser/compiler/runtime behavior changes.
  Verification: **PASS 2026-07-15.** Knowledge Map retrieval plus exact five-backend source/tests confirm current
    intermediate non-vivification, dense array replace/append, updated-root results, root-kind traversal, scoped
    complete paths, and identifier-only method grammar. Perl's direct probe, Rust three-test `terse_11_4`, Dart's
    exact no-autovivification test, Julia's complete local suite through the stacked installed depot, and Lua
    121/121 on PUC Lua/LuaJIT pass. The first Julia command with an empty writable depot alone failed only because
    it attempted forbidden registry/network resolution; the documented stacked-depot rerun passed. ADR `0036`,
    roadmap/book/KM/live docs, and the detailed neutral/backend/admission split align. Memory architecture,
    Knowledge Map, doctrines, task metadata, mdBook, and whitespace checks pass. No behavior changed.
  Commit: `FUTURE-PARITY-BACKLOG.19.0 - plan write vivification and bang mutation`

- ID: `FUTURE-PARITY-BACKLOG.19.1`
  Status: `done; focused-signoff-complete`
  Goal: Lock an executable backend-neutral v1 contract for nested write-vivification and approved `!` mutation.
  Children: `.19.1.1`, `.19.1.2`, `.19.1.3`
  Dependencies: `.19.0`; complete current Perl/Rust/Dart/Julia/Lua parity (satisfied by
    `LUA-BACKEND-PARITY.8.4`; not selected ahead of `.5.1`)
  Acceptance: Strict fixtures define syntax/AST, write-only creation, path segment/container selection, gaps,
    kind conflicts, copied results, mutation identity, callback return replacement, original-shape traversal,
    stable copied paths, exact exclusions, and typed diagnostics before backend code.
  Verification: **PASS 2026-08-31.** `.19.1.1-.3` freeze both unchanged future mechanisms and their strict shared
    composition before backend code. No syntax, runtime, capability, generated, or public-current state is
    admitted; Perl implementation starts at `.19.2.1`.
  Commit: closed by `FUTURE-PARITY-BACKLOG.19.1.3 - compose neutral future mutations`

- ID: `FUTURE-PARITY-BACKLOG.19.1.1`
  Status: `done; focused-signoff-complete` (2026-08-30; activated from exact clean pushed mdBook-drift closeout commit
    `b108cd692893dde1258a0c425d574e7633ccfd62`)
  Goal: Lock the neutral nested write-vivification syntax, AST, evaluation, creation, conflict, dense-array, result,
    and diagnostic contract.
  Dependencies: `.19.0`; complete current-backend parity
  Verification tier: `focused` — this leaf changes only the future neutral contract fixture/checker and its exact
    design documentation; current parsers, compilers, runtimes, public behavior, and capability state remain
    non-vivifying until the separately owned backend/admission leaves.
  Focused checks: contract schema/fixture validation and rejected-mutation corpus; current five-backend nested-write
    boundary probes and direct ActionIR dependents; ADR/Knowledge/task/index/roadmap/book/live-memory alignment;
    both bounded histories, all nine doctrines, rendered mdBook, and whitespace.
  Canonical trigger: `none` — escalate before landing only if the slice moves executable backend behavior,
    capability/public-current admission, generated formats, doctrine/storage infrastructure, or requires a bounded-
    history rollover; final cross-backend/public admission remains owned by `.19.7`.
  Acceptance: Freeze ordinary-assignment syntax and one dedicated neutral AST shape; left-to-right single path-
    segment evaluation followed by single RHS evaluation; missing-root and missing-intermediate creation chosen
    only by the next evaluated segment; quoted-numeric string keys distinct from integer indexes; no partial
    structural root change on invalid segment kinds, existing-kind conflicts, negative/fractional indexes, or
    dense-array gaps while completed expression side effects retain normal semantics; replace-or-exact-append
    array behavior; detached updated-root results; exact typed diagnostic identities,
    paths, and source locations; and explicit read/non-write exclusions. No backend behavior is enabled here.
  Checklist: [x] exact clean activation and task ownership [x] prerequisite ADR/Knowledge retrieval
    [x] current five-backend boundary/toolbox probes [x] neutral fixture/schema and mutation corpus
    [x] syntax/AST/evaluation/creation/conflict/gap/result/diagnostic acceptance proof
    [x] durable docs/Knowledge/live-memory/task-index alignment [x] focused signoff
    [x] atomic commit/brief/clean handoff.
  Activation evidence: `git status --short --untracked-files=all` is empty at the exact pushed activation commit;
    local HEAD equals upstream; `git_message_brief.txt` is zero bytes; the committed canonical receipt matches
    HEAD; generated mdBook output is absent; no background job remains. `.19.0` is committed complete, current
    five-backend parity is satisfied, and ADR `0036` remains the sole accepted direction.
  Contract evidence: `linkedspec-write-vivification-v1` keeps ordinary bare-binding bracket assignment but gives
    every one-or-more-segment write one `assign_nested_access` node. Each segment contains its ordinary typed
    expression and exact authored half-open Unicode-scalar span; evaluated string/nonnegative integer selects
    harray/array, quoted numeric string remains a key, and invalid kinds diagnose exactly. Root/intermediate
    creation uses current/next selectors; bound null/wrong kind never coerce; dense arrays replace or exact-append.
    Segments then RHS evaluate once before isolated validation, expression failures propagate unchanged, completed
    same-binding effects settle before the snapshot, structural commit is atomic, values detach, and reads remain
    non-creating. Five AST, seven syntax, 11 success, 16 structural-failure, three expression-failure, three read-
    exclusion cases plus detachment pass; all 105 independent mutations are rejected.
  Current-boundary evidence: Perl toolbox lowering/runtime proves quoted key versus computed integer-index static
    ownership and unchanged missing-intermediate failure. Rust exact `terse_11_4` integration is 3/3; Dart's exact
    no-autovivification test is 1/1; Julia's exact corpus case is 1/1; direct byte-identical current nested-write
    scenarios pass on PUC Lua and LuaJIT. No backend source or current capability moves. The unfiltered Lua harness
    exposed an unrelated stale `next()` fixture after `.15.2`; exact AST/runtime/root-cause evidence is durably
    queued before repair as `.15.3`, preserving this leaf's clean ownership and the correct lifecycle contract.
  Focused signoff evidence: the neutral checker, Knowledge Map 916/7,792, task partition/index, both bounded
    histories, rendered sole-facing mdBook, all nine doctrines, and `git diff --check` pass. Review confirms only
    future contract/checker and synchronized design/continuity surfaces move; current parsers, compilers, runtimes,
    fixtures, generated formats, capability/public-current state, facades, schemas, MCP, and CLI remain unchanged.
  Verification: **PASS 2026-08-30.** Focused signoff complete; no canonical trigger fired. `.15.3` repairs the
    discovered stale Lua test from the clean commit boundary, then `.19.1.2` resumes the neutral parent.
  Commit: `FUTURE-PARITY-BACKLOG.19.1.1 - lock neutral write vivification`

- ID: `FUTURE-PARITY-BACKLOG.19.1.2`
  Status: `done; canonical-signoff-complete` (2026-08-31; activated from exact clean pushed standalone-fixture repair commit
    `c013f3d58480deeee2bc47f7609f3d395a7857bb`)
  Goal: Lock the neutral `map_leaves!` parser, addressable receiver, callback, stable path, original-shape,
    atomic-commit, re-entrancy, result, continuation, and exclusion contract.
  Dependencies: `.19.0`; complete current-backend parity
  Verification tier: `canonical` — the future-neutral contract itself changes no backend behavior, but its new
    maintained Python checker advances the exact tool-project-data entrypoint census from 36 to 37; ADR `0073`
    therefore requires one receipt-bound canonical proof for the staged storage-governance candidate.
  Focused checks: exact current five-backend bang-syntax rejection and non-mutating traversal behavior; source-
    backed parser/receiver/callback/continuation audit; strict fixture/schema validation and rejected-mutation
    corpus; ADR/Knowledge/task/index/roadmap/book/live-memory alignment; both bounded histories, all nine doctrines,
    rendered mdBook, and whitespace.
  Canonical trigger: `tool-project-data storage census 36→37` — exact staged candidate must pass canonical local
    CI. Final cross-backend/public admission remains separately owned by `.19.7`.
  Acceptance: Freeze exact receiver-method syntax and a dedicated neutral AST shape for the sole v1 bang method;
    require one bare named uniform binding as the addressable receiver; preserve existing root-kind traversal over
    an isolated original-shape snapshot; define callback value/path/key/index/depth scope, copied stable paths,
    callback-result replacement, replacement-subtree non-revisit, atomic receiver rebinding, detached returned
    updated value, continuation behavior, same-receiver/re-entrant mutation rejection, typed diagnostics and source
    spans; and reject function form, temporary/literal/helper/nested receivers, arbitrary bang names,
    `walk_leaves!`, `reduce_leaves!`, aliases, writable callback references, and hidden receiver mutation through
    the non-bang twin. No backend behavior is enabled here.
  Checklist: [x] exact clean activation and task ownership [x] prerequisite ADR/Knowledge retrieval
    [x] current five-backend boundary/toolbox probes [x] parser/AST/receiver/continuation source audit
    [x] neutral fixture/schema and mutation corpus [x] callback/path/original-shape/atomicity/re-entrancy proof
    [x] durable docs/Knowledge/live-memory/task-index alignment [x] focused and exact staged canonical signoff
    [x] atomic commit/brief/clean handoff.
  Activation evidence: `git status --short --untracked-files=all` is empty at exact pushed commit `c013f3d5`;
    local HEAD equals upstream; `git_message_brief.txt` is zero bytes; pre-push reuses the committed canonical
    receipt; generated mdBook output is absent; no background job remains. `.19.1.1` and intervening `.15.3` are
    committed complete, current five-backend parity is satisfied, and ADR `0036` remains the sole accepted
    direction.
  Current-boundary evidence: the checked-in `terse_13_3_array_tree_traversal_receiver_blocks` action-edge fixture
    returns its exact expected nested value on Perl/Rust/Dart/Julia/Lua. A minimal action-edge control using only
    `items.map_leaves()` likewise returns `['a',['b','c'],{'h':'H'}]` on all five. Replacing only that method token
    with `map_leaves!` yields null on Perl/Rust, with Rust's exact stopped-identifier warning, and nonzero generic
    parser-invocation failure on Dart/Julia/Lua. The discarded initial lifecycle probe is not evidence because its
    non-bang twin also returned null.
  Parser/toolbox evidence: Perl `call_spec_handler_subst` fully lowers the non-bang chain but leaves the bang chain
    raw; direct ActionIR parsing identifies `raw_perl` / `invalid_fluent_chain`. Perl `_parse_method_function_expr`,
    Rust `parse_name`, Dart `_parseCallee`, Julia `_action_parse_callee`, and Lua `parse_callee` all restrict current
    fluent method names to identifier characters. Existing receiver dispatch, callback-frame copies, binding
    snapshots/restoration, and chain loops provide the audited implementation seams; no backend source moves.
  Contract evidence: `linkedspec-map-leaves-mutation-v1` reserves only
    `IDENTIFIER.map_leaves!() { ACTION_BLOCK }`, owns one dedicated `receiver_mutation_chain`, resolves one existing
    bare harray/array binding identity, traverses a detached original-shape root-kind snapshot, and copies callback
    `value`/`path`/`depth`/`key|index`. Callback results replace but are not revisited. The active identity rejects
    direct/nested/helper-mediated writes before mutation; unrelated bindings and same-spelling shadow identities
    remain legal. Success commits once, returns a detached root, and precedes ordinary continuation. Four valid
    syntax, fourteen syntax-failure, five exclusion, ten success, eight pre-commit-failure, continuation/shadow/
    guard-release/non-bang/detachment cases pass; all 167 independent mutations are rejected.
  Focused/canonical evidence: both future contract checkers, Python syntax, Knowledge 918/7,810, exact task
    partition/index, both bounded-history pressure checks, rendered 81-file/15,920-KiB sole-facing mdBook, all nine
    doctrines, memory architecture, whitespace, and exact no-backend/no-fixture/no-capability/no-format scope pass.
    The new repository-routed checker owns no temporary allocator; tool storage passes at 37 Python entrypoints,
    three Python temporary owners, and fifteen shell allocator owners. That exact census movement fires the
    canonical tier; the complete staged candidate and receipt-bound local CI pass before commit.
  Verification: **PASS 2026-08-31.** Canonical signoff complete; no future syntax/runtime behavior is admitted.
    `.19.1.3` is the next clean-boundary composition leaf.
  Commit: `FUTURE-PARITY-BACKLOG.19.1.2 - lock neutral map_leaves mutation`

- ID: `FUTURE-PARITY-BACKLOG.19.1.3`
  Status: `done; focused-signoff-complete` (2026-08-31; task-tree-first from exact clean future `map_leaves!` contract commit
    `4f06e4a6a261d7b084d3c68e76664781f2df4068`; no push)
  Goal: Compose strict future fixtures/checkers for both v1 mechanisms and prove current backends fail only at the
    expected pre-implementation boundary.
  Dependencies: `.19.1.1`, `.19.1.2`
  Verification tier: `focused` — this leaf composes the two already frozen future-only contracts and their strict
    checkers without admitting syntax, lowering, runtime behavior, generated carriers, capability state, or public
    current behavior on any backend.
  Focused checks: exact cross-contract schema/reference and mutation-rejection proof; valid/invalid composed future
    fixtures covering nested vivification inside `map_leaves!` callbacks, protected receiver identity, detached
    traversal/commit, rollback, continuation, reentrancy, shadowing, and diagnostic precedence; current Perl,
    Rust, Dart, Julia, PUC Lua, and LuaJIT probes that stop only at the typed pre-implementation boundary; direct
    contract/checker dependents, Knowledge Map, task/index, bounded histories, memory, all nine doctrines, rendered
    mdBook, and whitespace.
  Canonical trigger: `none planned` — escalate if composition adds a maintained executable entrypoint or changes
    the exact tool-storage census, doctrine/infrastructure, generated/public/capability behavior, a mandatory
    history rollover, or any backend implementation.
  Ownership: `.19.1.3` owns only strict composition governance and current-boundary proof. Perl behavior remains
    exclusively owned by `.19.2.1-.2`; Rust and remaining backend behavior remain owned by `.19.3-.6`; admission,
    recurrence, and public current claims remain owned by `.19.7-.9`.
  Checklist: [x] clean activation/task ownership [x] Knowledge/decision/toolbox retrieval [x] composed contract
    and fixture design [x] strict checker and mutation governance [x] six-runtime current-boundary proof
    [x] durable Knowledge/roadmap/book/live synchronization [x] focused signoff [x] atomic commit/brief/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` is empty at
    `4f06e4a6a261d7b084d3c68e76664781f2df4068`; `.19.1.2` is committed canonical-signoff-complete with receipt
    candidate `e1dd1eb36ad33e8cd6fef085768e720a72109f865143c609fc01cf3568df8f73`; `git_message_brief.txt` is zero
    bytes, reproducible mdBook output is absent, the canonical background job is consumed, and no push occurred.
  Contract evidence: `linkedspec-write-map-leaves-composition-v1` digest-binds the two unchanged neutral mechanism
    contracts and feeds both existing checker entrypoints. The write checker validates eight embedded writes; the
    map checker executes six callback compositions and one post-commit continuation, retains all 167 base
    mutations, and rejects 593 scalar/container-shape composition mutations. Cases freeze callback-local
    vivification/replacement non-revisit, unrelated success and callback-failure persistence, structural write
    rollback with completed RHS effects, same-receiver guard precedence before segment/RHS evaluation, distinct
    same-spelling shadow identity, detachment, and receiver-write failure after bang commit/guard release. No new
    executable entrypoint, temporary allocator, storage census, backend behavior, or admission is introduced.
  Current-boundary evidence: the exact JSON-owned non-bang source returns `{"leaf":[]}` through the primary Perl,
    Rust, Dart, Julia, PUC Lua, and LuaJIT routes. Replacing only the method token with the composed bang/callback-
    write source stops before callback lowering: Perl exits 0 with null; Rust exits 0 with its exact stopped-
    identifier warning and null; Dart, Julia, and both Lua ABIs exit 1 with generic parser-invocation failure.
    Disposable Lua native probe outputs were repository-volume-local and removed; no background job remains.
  Focused signoff evidence: both neutral checkers pass at 8 composed writes / 105 write mutations and 6 callback
    plus 1 continuation composition / 167 base map + 593 composition mutations. Python syntax, exact unchanged
    37-entrypoint project-data storage, capability 90/0/0, language coverage 250/105+1/126, Knowledge Map
    919/7,821, task partition/index, both bounded-history checks, rendered sole-facing mdBook, all nine doctrines,
    memory architecture, and whitespace pass. Review confirms only future contract/checker governance and aligned
    design/continuity surfaces move; no canonical trigger fires and complete local CI is correctly deferred.
  Verification: **PASS 2026-08-31.** Focused signoff complete; no future syntax/runtime behavior is admitted.
    `.19.1` closes and Perl implementation `.19.2.1` is the next clean-boundary leaf.
  Commit: `FUTURE-PARITY-BACKLOG.19.1.3 - compose neutral future mutations`

- ID: `FUTURE-PARITY-BACKLOG.19.2`
  Status: `done` (2026-08-31; corrected canonical signoff complete)
  Goal: Implement the unchanged v1 contract on the Perl reference backend.
  Children: `.19.2.1`, `.19.2.2`
  Dependencies: `.19.1`
  Verification: **PASS.** Both Perl reference slices implement the unchanged neutral nested-write and
    `map_leaves!` contracts without changing another backend or admitting a portable/public capability.
  Commit: `.19.2.1` `FUTURE-PARITY-BACKLOG.19.2.1 - implement Perl write vivification`; `.19.2.2`
    `FUTURE-PARITY-BACKLOG.19.2.2 - implement Perl map leaves mutation`

- ID: `FUTURE-PARITY-BACKLOG.19.2.1`
  Status: `done` (2026-08-31; focused signoff from exact clean neutral-composition parent
    `db71152ad4f7f981402b3a503601d184046bbc54`; no push)
  Goal: Implement Perl reference nested write-vivification over scalar-held typed value trees.
  Dependencies: `.19.1.3`
  Verification tier: `focused` — this leaf implements only the unchanged, already frozen nested-write v1 contract
    on the Perl reference path. It does not implement `map_leaves!`, change another backend, admit a capability or
    public-current claim, move generated formats, add an executable/storage owner, or alter doctrine infrastructure.
  Focused checks: exact Perl ActionIR AST/source-span and syntax diagnostics; typed evaluated-segment order, absent
    root/intermediate creation, bound-null/wrong-kind/gap failures, post-evaluation same-binding snapshots,
    expression-failure propagation, detached commit/results, and read/non-write no-drift; direct lowering/source
    inspection, focused plus appropriate broad Perl phase0, both neutral/composition checkers, Knowledge/task/index,
    bounded histories, memory, all nine doctrines, rendered mdBook, and whitespace.
  Canonical trigger: `none planned` — escalate if the implementation changes generated/public/capability formats,
    current non-Perl behavior, tool/storage/doctrine infrastructure, or forces a bounded-history rollover. Final
    five-backend admission and recurring/public proof remain owned by `.19.7-.9`.
  Ownership: `.19.2.1` owns only Perl parsing/lowering/runtime behavior for `linkedspec-write-vivification-v1` and
    exact Perl-focused tests/docs. Perl `map_leaves!` remains exclusively `.19.2.2`; Rust/Dart/Julia/Lua remain
    `.19.3-.6`; no cross-backend/public admission occurs here.
  Checklist: [x] clean activation/task ownership [x] Knowledge/decision/toolbox retrieval [x] exact current Perl
    AST/lowering/runtime seam audit [x] parser/AST typed-segment implementation [x] isolated vivifying runtime and
    typed diagnostics [x] focused/exclusion/detachment regression proof [x] durable docs/Knowledge/live sync
    [x] focused signoff [x] atomic commit/brief/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` is empty at
    `db71152ad4f7f981402b3a503601d184046bbc54`; `.19.1.1-.3` and neutral parent `.19.1` are committed complete;
    `git_message_brief.txt` is zero bytes; generated mdBook/runtime-probe output is absent; no background job
    remains; and no push occurred after the focused neutral-composition commit.
  Implementation evidence: one- and many-segment writes now parse as one `assign_nested_access` with exact
    expression-bearing `path_segment` source/spans and seven frozen typed syntax failures. Perl lowering evaluates
    segments left-to-right then RHS, snapshots presence/root afterward, and delegates isolated structural work to
    `BindingRuntime::nested_write`. Evaluated strings/nonnegative integers select harray/array; absent roots and
    unambiguous missing children create, bound null/wrong kinds conflict, and arrays replace/append without gaps.
    Typed errors retain the exact code/operation/binding/failing index/copied prefix/authored span and kind/gap
    fields. Commit/result/initial/RHS aggregate boundaries detach and reads remain unchanged.
  Presence/evaluation evidence: RuleIR adds invocation-local presence state only for rules with nested-write
    targets; tracked assignments distinguish explicitly bound null from absence. User functions own fresh presence
    state per call, mark parameters present, and reset absent locals. Tied-scalar proof shows every segment once
    left-to-right then RHS; expression failure stops structural work; same-binding segment/RHS effects settle
    before the outer snapshot and survive only as completed expression state after later structural failure.
  Regression evidence: `t/write_vivification_perl_contract.t` projects all frozen 5 AST, 7 syntax, 11 success, and
    16 structural-failure cases plus four-way detachment, evaluation failure, same-binding composition, live
    bound-null, dynamic scalar-kind fidelity, and repeated function-local state. ActionIR/trace/uniform plus the new contract pass 50 permanent
    tests. The first complete Phase 0 run proves 1,020 unaffected subtests and identifies exactly 12 stale source
    expectations; after expectation-only repair, an exact replay proves all 12. A fresh post-review exact-tree
    Phase 0 then passes all 1,032 in 963 seconds. Both unchanged neutral checkers pass at 105 write and 167 base +
    593 composition mutations.
  Focused signoff evidence: all changed Perl modules pass syntax; whitespace, Knowledge/task/index, bounded
    histories, project storage, capability/language no-drift, rendered sole-facing mdBook, all nine doctrines, and
    memory architecture pass. Review confirms no non-Perl runtime, neutral contract, generated format, capability,
    facade/schema/MCP, CLI, tool/storage owner, doctrine, or public admission moves; no canonical trigger fires.
  Verification: **PASS 2026-08-31.** Perl-only implementation complete; parent `.19.2` stays open for `.19.2.2`.
  Commit: `FUTURE-PARITY-BACKLOG.19.2.1 - implement Perl write vivification`

- ID: `FUTURE-PARITY-BACKLOG.19.2.2`
  Status: `done` (2026-08-31; task-tree-first from exact clean Perl write-vivification
    commit `6b960624ead7be7ac55d835253e2013d7a514a6a`, resumed after blocker-record commit
    `be3d58dda7e89919e63c380c70180432b303dbbe`; no push)
  Goal: Implement Perl reference `map_leaves!` parsing, controlled leaf-value replacement, atomic updated-tree
    commit, and typed boundaries without granting callback code direct receiver mutation.
  Dependencies: `.19.2.1`
  Verification tier: `canonical` — implementation scope remains the unchanged, already frozen `map_leaves!` v1
    and write-composition contracts on the Perl reference path, without another backend or portable/public
    admission. The leaf began focused, but its required complete change record forces a bounded-history rollover,
    finite capacity ADR, and doctrine-infrastructure movement; ADR `0073` therefore requires a staged receipt.
  Focused checks: expanded exact Perl ActionIR AST/source-span and syntax diagnostics; bare receiver resolution;
    root-kind traversal over a detached original-shape snapshot; copied callback frames, replacement/non-revisit, receiver-
    identity guard and shadow boundary; atomic receiver rebind, detachment, guard release, callback/continuation
    failures, and nested-write composition; direct lowering/source inspection, focused plus appropriate broad Perl
    regression, both neutral/composition checkers, Knowledge/task/index, bounded histories, memory, all nine
    doctrines, rendered mdBook, and whitespace.
  Canonical trigger: `fired by required bounded change-history rollover` — immutable segment `4987`, ADR `0098`,
    and the exact 26-file/25-manifest-line finite capacity step move storage/doctrine infrastructure. Receipt-bound
    canonical local CI is therefore required. Final five-backend admission and recurring/public proof remain owned
    by `.19.7-.9`.
  Ownership: `.19.2.2` owns only Perl parsing/lowering/runtime behavior for
    `linkedspec-map-leaves-mutation-v1`, its frozen nested-write composition, and exact Perl-focused tests/docs.
    Rust/Dart/Julia/Lua remain `.19.3-.6`; no cross-backend/public admission occurs here.
  Checklist: [x] clean activation/task ownership [x] Knowledge/decision/toolbox retrieval [x] exact current Perl
    AST/lowering/traversal seam audit [x] director resolves neutral/user-function scope conflict
    [x] bang parser and dedicated typed AST [x] isolated traversal, receiver guard,
    atomic rebind, and typed diagnostics [x] nested-write composition and focused regression proof
    [x] durable docs/Knowledge/live sync [x] focused signoff [x] corrected staged canonical signoff
    [x] atomic commit/brief/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` is empty at
    `6b960624ead7be7ac55d835253e2013d7a514a6a`; `.19.2.1` is committed focused-signoff-complete after all nine
    doctrine hooks and a fresh 1,032-test Phase 0 pass; `git_message_brief.txt` is zero bytes; generated mdBook and
    runtime-probe output are absent; no background job remains; and no push occurred.
  Blocking conflict evidence: the frozen helper-mediated and post-commit composition cases label unparameterized
    user-function `tree`/`audit` names as caller identities. The already-admitted portable function contract instead
    gives every parameter and working variable a fresh function-local scope and explicitly defers implicit caller-
    state capture/mutation. An exact Perl probe returns caller `[{"a":"A"},[]]` unchanged while the helper
    returns its own `[{},["entered"]]`, confirming this is semantic, not parser wording. Implementing the fixture
    literally would silently widen user functions on Perl and later all backends beyond this leaf's ownership.
  Decision alternatives recorded at discovery: **A (recommended)** preserves pure functions and corrects only the future-neutral fixtures:
    use existing explicit-target `set(tree, ...)` for helper-mediated callback rejection and a caller-scoped
    `.with() { tree[...] = ...; return(value) }` continuation for post-commit write proof; exact Perl controls prove
    both constructs already reach the caller binding. **B** opens a separately ratified five-backend program for
    implicit caller-binding capture before resuming bang implementation. No behavior or contract bytes change
    until the director chooses.
  Director clarification (2026-08-31): choose A. `foo.map_leaves!()` authorizes the traversal mechanism to replace
    selected leaf values and atomically publish the rebuilt tree after callback success; it does **not** authorize
    callback code to assign, nested-write, change root kind/topology, or otherwise mutate `foo` itself. The binding
    identity and original root-kind/key-or-index traversal topology remain protected; only callback-selected leaf
    values may differ. Ordinary functions retain fresh local scope. The implementation's copy-on-write root swap is
    invisible atomic publication machinery, not a general receiver-write permission. `myfunc!` is illustrative
    notation here; v1 remains the specifically ratified `map_leaves!` surface, with arbitrary user-defined bang
    methods outside this leaf.
  Blocker-record verification: both then-unchanged neutral checkers passed at 105 write / 167 map / 593 composition
    mutations; the exact no-capture and two caller-scope alternative probes produce the recorded values; Knowledge
    Map 921/7,834, task partition/index, bounded histories, rendered sole-facing mdBook, whitespace, and all nine
    doctrines pass. The reproducible book output is removed. No production/test/fixture/capability/generated/
    facade/schema/MCP/CLI file moves, no canonical trigger fires, and no background job remains.
  Contract correction evidence: option A changes only the two impossible carriers while preserving their intended
    observations: the helper-mediated case is inline callback code using explicit-target `set(tree, {})`, and the
    post-commit receiver-write case is a caller-scoped `.with()` continuation. The resulting digest-bound corpus
    has 592 current composition mutations; the historical pre-correction freeze/checker record above remains 593.
  Implementation evidence: Perl now parses only bare `IDENTIFIER.map_leaves!() { ACTION_BLOCK }` into a dedicated
    `receiver_mutation_chain` with the frozen 4 valid / 14 invalid / 5 exclusion boundary and exact authored spans.
    Lowering supplies copied `value`, `path`/`@path`, `depth`, and `key|index` bindings, accepts the callback result
    as the replacement leaf, and routes ordinary continuations after commit. `BindingRuntime::map_leaves_mutation`
    snapshots the receiver, traverses only its original root kind and shape, never revisits replacement containers,
    rebuilds completely, and publishes one detached root atomically only after every callback succeeds.
  Receiver-safety evidence: one invocation-local guard keys the actual Perl scalar-slot identity, so same-spelling
    shadows remain independent. It rejects direct assignment, nested write, nested bang, `set`, `set_key`, `push`,
    array-end mutation, and binding-target array pipelines before their write/evaluation seam while allowing
    unrelated binding effects. Audit caught and closed the initially missed pipeline seam; expanded signoff then
    found three-argument `split(target, source, delimiter)` stopped at AST value-helper arity before that owner.
    Recognized pipeline statements now route to the existing owner first. Live proof covers all eight binding-
    target pipeline names, a composed pipeline, and all four array-end methods with exact spans. Guard release is
    exception-safe; callback failure leaves the receiver unchanged, and a later continuation failure cannot roll
    back an already completed bang commit.
  Regression evidence: `t/map_leaves_mutation_perl_contract.t` projects every frozen parser/runtime/composition
    case plus exact callback-scoped bindings, detachment, source spans, guard precedence/release, shadows,
    function scope, array-pipeline rejection, and post-commit behavior. With fatal warnings, the focused five-file
    suite passes 58 tests. The write checker passes 105 mutations; the map checker passes 167 base + 592
    composition mutations. A fresh broad Perl `t/phase0_regression.t` passes all 1,032 tests in 1,016 seconds.
  Focused signoff evidence: all changed Perl modules pass syntax; whitespace, Knowledge/task/index, bounded
    histories, project storage, capability/language no-drift, rendered sole-facing mdBook, all nine doctrines, and
    memory architecture pass. The complete `CHANGES.md` record forces a governed rollover: segment `4987` from
    clean activation `be3d58dd`, ADR `0098`, and exact 26/25 capacity preserve every aggregate/byte/owner/lifecycle/
    verifier/storage control. That infrastructure movement fires canonical proof. No generated format, executable
    owner, other backend, facade/schema/MCP, CLI, portable capability, or public-current surface moves.
  Canonical attempt one: all stages through diagnostic output, complete named marks, and punctuation-light zero-
    argument syntax pass. `check_uniform_binding_mutation_result_surface.py` then rejects two stale required
    phrases: `.19.2.1` correctly generalized typed-path assignment prose from a hash snapshot to a typed-root
    snapshot because integer selectors update arrays, but the recurring checker's literal anchors still demand
    the superseded hash-only wording. This leaf owns restoring checker/book agreement without reverting accurate
    public semantics, adding direct drift proof, and rerunning the exact staged canonical candidate from the start.
  Canonical attempt two: the corrected recurring checker requires the accurate typed-root sentences and passes 53
    public files / 12 current anchors / 9 classified historical cards. The exact staged run passes all nine
    doctrines, every five-backend admission family, and every later product/public check through primary CLI and
    tool-storage proof. It then stops only when the outer Codex sandbox denies the process-locality oracle's nested
    macOS `sandbox-exec` with known status 71 before the relocated driver starts. Existing canonical Knowledge
    classifies this harness boundary; no source, contract, checker, or oracle correction is warranted.
  Canonical attempt three: the unchanged permission-authorized exact candidate passes process containment and the
    complete receipt-bound canonical gate from the beginning. The receipt matches current `HEAD` plus the complete
    staged diff before the atomic commit.
  Verification: **PASS 2026-08-31.** Perl `map_leaves!`, the pure-function carrier correction, direct receiver-
    safety proof, bounded history rollover, and typed-root checker repair are signoff-complete. Parent `.19.2`
    closes without another backend or portable/public capability admission; Rust `.19.3.1` is next.
  Commit: `FUTURE-PARITY-BACKLOG.19.2.2 - implement Perl map leaves mutation`

- ID: `FUTURE-PARITY-BACKLOG.19.3`
  Status: `done; focused-signoff-complete through .19.3.4.0` (2026-09-02)
  Goal: Implement the unchanged v1 contract on Rust, including interpreted and supported generated routes.
  Children: `.19.3.1`, `.19.3.2`, `.19.3.3`, `.19.3.4`
  Dependencies: `.19.2`
  Verification: **PASS 2026-09-02.** Rust `.19.3.1-.2` implement both frozen mutation contracts, `.19.3.3`
    supplies exact staged canonical cross-backend root-target proof, and `.19.3.4.0` closes the measured external
    launch-latency question without repository repair. No Rust implementation frontier remains.
  Commit: closed by `FUTURE-PARITY-BACKLOG.19.3.4.0 - classify macOS Rust launch latency`

- ID: `FUTURE-PARITY-BACKLOG.19.3.1`
  Status: `done; canonical-signoff-complete` (2026-09-01; task-tree-first from exact clean Perl `map_leaves!` commit
    `67e9a90f2307fd48dde77f52894c9999b11b1fb4`; no push)
  Goal: Implement Rust nested write-vivification through typed parsed/serialized/emitted state and runtime.
  Dependencies: `.19.2`
  Verification tier: `canonical` — this leaf implements the unchanged frozen nested-write v1 contract on Rust and
    necessarily moves typed serialized/emitted/generated carriers. ADR `0073` classifies generated-format movement
    as a canonical boundary even though no other backend or portable/public capability is admitted here.
  Focused checks: exact Rust parsed ActionIR/source spans and syntax diagnostics; typed serialized `SpecFile`,
    generated-plan, emitted-source, and generated Rust reconstruction; evaluated segment order and kinds; absent
    root/intermediate creation; bound-null/wrong-kind/gap failures; post-evaluation same-binding snapshots;
    expression-failure propagation; detached commit/results; read/non-write no-drift; Rust package and direct
    generated-corpus dependents; both neutral/composition checkers; Knowledge/task/index, bounded histories,
    memory, all nine doctrines, rendered mdBook, whitespace, and the staged receipt-bound canonical local gate.
  Canonical trigger: `generated-format movement` — stage the exact candidate and run canonical CI before commit.
    Final five-backend admission and recurring/public proof remain owned by `.19.7-.9`.
  Ownership: `.19.3.1` owns only Rust parsing/compiler/runtime behavior for
    `linkedspec-write-vivification-v1` plus its typed serialized/emitted/generated carriers and exact Rust-focused
    tests/docs. Rust `map_leaves!` remains exclusively `.19.3.2`; Dart/Julia/Lua remain `.19.4-.6`; no portable or
    public-current admission occurs here.
  Checklist: [x] clean activation/task ownership [x] Knowledge/decision/toolbox retrieval
    [x] exact current Rust AST/compiler/runtime/carrier seam audit [x] parser and typed AST implementation
    [x] isolated vivifying runtime and typed diagnostics [x] serialized/emitted/generated route proof
    [x] focused/exclusion/detachment regression proof [x] durable docs/Knowledge/live sync [x] canonical signoff
    [x] atomic commit/brief/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` is empty at
    `67e9a90f2307fd48dde77f52894c9999b11b1fb4`; `.19.2.1-.2` and parent `.19.2` are committed complete; the
    committed canonical receipt matches that HEAD; `git_message_brief.txt` is zero bytes; generated mdBook and
    runtime-probe output are absent; no background job remains; and no push occurred.
  Verification finding: the required complete 105-case Perl oracle regeneration reproducibly changes the unrelated
    `capability_position_helper_surface` expectation from its committed rich record to `[null]`. Git history shows
    the source fixture's `copy(Top)` selector migration landed on 2026-07-13 while the expected output last moved
    on 2026-07-11. This leaf restores the unrelated derived file unchanged, records the drift for `.19.3.3`, and
    changes only its owned nested-write corpus case. The same audit confirmed that many older generator fixtures
    carry inert regexes on directly entered `Top`; all new `.19.3.1` executable fixtures instead use a zero-regex
    root whose loop matches `Done`. Systematic oracle cleanup remains exclusively `.19.3.3`.
  Implementation evidence: Rust now represents every authored bracket segment as `WritePathSegment` with typed
    expression, source, and Unicode-scalar span, and unifies one/many segments under `AssignNestedAccess`. Parser
    pre-scan preserves scalar-assignment RHS writes and exact comma/outer-assignment boundaries. Compiler,
    callable-contract, source-emitter, decoded generated-plan, and direct engine entry all validate the node and
    fail closed on malformed programmatic/serialized state.
  Runtime evidence: segment expressions evaluate left-to-right and RHS once before the binding snapshot. Strings
    select harrays and nonnegative integral numbers select dense arrays; absent roots/intermediates create only
    from those selector kinds, while bound null, wrong kinds, invalid selectors, and gaps produce exact typed
    errors without partial structural publication. Completed expression effects remain ordinary state; committed,
    returned, initial, and RHS aggregates detach. Fresh user-function locals begin absent and parameters present.
  Carrier evidence: permanent `write_vivification_contract.rs` projects all frozen 5 AST / 7 syntax / 11 success /
    16 structural-failure cases plus expression ordering/failure, presence, detachment, corrupt-node rejection,
    native, serde, generated-plan, emitted-source, and independently compiled emitted Rust. New executable sources
    use `Top:: -> Done` plus child-owned regex, matching parent-loop/target-regex semantics.
  Focused verification: `cargo fmt --check` and whitespace pass; parser boundary tests pass 3/3; runtime nested-
    write units pass 4/4; the permanent contract passes 5/5; the complete runtime integration target passes
    197/197; the manifest oracle passes all 105 fixtures; both neutral checkers pass 105 write and 167 base + 592
    composition mutations. A full Perl generator pass emits all 105 cases with a project-local 60-second timeout;
    only the pre-existing `.19.3.3` drift described above is restored outside this leaf.
  Canonical signoff: the exact staged candidate passes all nine doctrines, Knowledge Map 924/7,852, task/index,
    bounded-history, rendered mdBook, complete Rust local/package/generated/relocation proof, five-backend and
    product no-drift, both 66-case primary matrices, resource/storage containment, and Phase 0 through the exact
    `local CI gate passed` receipt marker. No unrelated oracle expectation is accepted and no portable/public
    capability, Rust bang method, other backend, facade/schema/MCP, or CLI behavior moves.
  Verification: **PASS 2026-09-01.** Rust nested-write vivification is signoff-complete through every supported
    typed carrier; `.19.3.2` is the next clean-boundary leaf.
  Commit: `FUTURE-PARITY-BACKLOG.19.3.1 - implement Rust write vivification`

- ID: `FUTURE-PARITY-BACKLOG.19.3.2`
  Status: `done; focused-signoff-complete` (2026-09-01; task-tree-first from exact clean Rust nested-write commit
    `c1dc84baeaa6f2d1d9644d01ae25e32d9f67f046`; no push)
  Goal: Implement Rust `map_leaves!` through typed parsed/serialized/emitted state and runtime.
  Dependencies: `.19.3.1`
  Verification tier: `focused` — this leaf changes only the already-ratified Rust private implementation and its
    direct neutral/generated consumers; Dart/Julia/Lua, portable capability, public examples, parent admission,
    and the push boundary remain owned by `.19.4-.19.9`. The required Rust component gate also owns correction of
    the one pre-existing `trace_controls` route-sink assertion that expected `Top`'s own regex to match on entry;
    systematic positive target-regex fixture/oracle cleanup remains `.19.3.3`.
  Focused checks: unchanged neutral checker and exact Rust projection of all 4 valid syntax, 14 invalid syntax,
    5 exclusions, 10 successes, 8 pre-commit failures, continuation/shadow/guard-release/nonbang/detachment proof,
    167 base mutations, and 592 nested-write compositions; core/runtime parser, compiler, serde, emitted-source,
    generated-plan, independently compiled source, corpus, and integration dependents; formatting, Knowledge,
    task/index, bounded histories, memory, all nine doctrines, rendered mdBook, cross-backend no-drift, and the
    complete Rust component local gate.
  Canonical trigger: `none` — escalate only if verification requires cross-backend/public admission,
    infrastructure/storage/doctrine movement, a mandatory bounded-history rollover, or repair of the separately
    owned oracle reproducibility drift; otherwise later admission/push leaves retain the canonical boundary.
  Acceptance: Parse only `IDENTIFIER.map_leaves!() { ACTION_BLOCK }` as the dedicated typed
    `receiver_mutation_chain`, retaining receiver/call/callback/continuation structure and exact authored Unicode-
    scalar spans across serde, compiler validation, emitted plans, source emission, and independently compiled
    generated Rust. Resolve one existing bare uniform-binding identity containing an harray or array; traverse a
    detached original-shape snapshot in sorted-key or index order; provide detached `value`, complete copied
    `path`, `depth`, and `key|index`; replace each leaf with the detached callback result without revisiting
    replacement aggregates; then commit the rebuilt binding once and return a detached updated root before
    ordinary fluent continuation. Guard that resolved identity during callbacks so direct, nested-write, nested-
    bang, helper-mediated, array-end, and binding-target pipeline writes fail before mutation with exact
    `receiver_mutation_reentrant`, while unrelated and distinct same-spelling shadow identities remain legal.
    Callback/re-entrant failure leaves the receiver unchanged and releases the guard; continuation failure keeps
    the prior commit. Preserve non-bang behavior and compose exactly with Rust `.19.3.1` nested writes.
  Ownership: `.19.3.2` owns Rust parser/compiler/runtime/carrier implementation and its direct proof. It also owns
    the exact Rust `trace_controls` route-sink assertion correction discovered by its required local gate: lock
    that a directly entered `Top` does not test its own inert regex, while preserving the test's output, lifecycle,
    and routed-trace purpose. It must not bless `.19.3.3` oracle drift, perform the systematic inert-root/positive-
    dispatch inventory, change Dart/Julia/Lua, or claim portable/public capability; `.19.3.3` and `.19.4-.19.9`
    retain those boundaries.
  Checklist: [x] clean activation/task ownership [x] Knowledge/ADR/toolbox retrieval [x] tool-first Rust seam audit
    [x] typed parser/compiler/serde/emitted carrier [x] atomic guarded runtime [x] base/composition/generated proof
    [x] focused dependent/no-drift proof [x] durable docs/memory/task/index synchronization [x] complete Rust
    component gate after the owned trace-fixture repair [x] focused signoff [x] atomic commit/brief/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` was empty at
    `c1dc84baeaa6f2d1d9644d01ae25e32d9f67f046`; `git_message_brief.txt` was zero bytes; `.19.3.1` is committed
    signoff-complete with its canonical receipt; no background job or generated mdBook output remained. The
    Knowledge Map routed this leaf to the neutral mutation, pure-function carrier resolution, write-composition,
    and Rust nested-write facts plus ADR `0036` and Toolbox §4.8.3-.4 before behavior inspection.
  Carrier evidence: Rust now reserves bang parsing only for the exact bare-receiver `map_leaves!` surface and
    retains one `ReceiverMutationChain` with typed receiver, mutation, callback ActionIR, continuation, exact
    source, and authored Unicode-scalar spans. Compiler/callable visitors, direct Engine entry, serde,
    source-emitter, generated-plan decode, and independently compiled emitted Rust validate the same node and fail
    closed on malformed serialized state.
  Runtime evidence: `RuntimeContext` assigns stable visible-binding identities, replaces/restores them across
    scoped and function-local lifetimes, and guards the resolved receiver identity during callbacks. Every owned
    assignment/append, nested-write/bang, helper, array-end, and binding-target pipeline route rejects before
    operand/segment/RHS evaluation when it targets that identity; unrelated and same-spelling shadow identities
    remain legal. A detached original-shape root-kind traversal publishes once after complete callback success,
    never revisits replacement aggregates, releases the guard on all exits, and begins continuation after commit.
  Proof evidence: permanent `map_leaves_mutation_contract.rs` passes 9/9 across the frozen 4/14/5 syntax inventory,
    all base/special/composition behaviors, Unicode spans, non-bang isolation, detachment, corrupt-state rejection,
    native/serde/generated/emitted/independently compiled execution, and exact parent-loop/target-regex fixtures.
    Three private runtime tests prove state visible only after failure: receiver atomicity/guard release, completed
    unrelated write effects, same-receiver pre-evaluation precedence, and post-commit continuation failure. The
    unchanged neutral oracle rejects all 167 base and 592 composition mutations.
  Focused verification: `cargo fmt --check` and whitespace pass; `linkedspec-core` passes 201/201; the complete
    Rust runtime integration target passes 197/197; the manifest oracle passes 3/3 while comparing all 105 fixtures
    with the Perl reference; the permanent mutation and write-composition contracts pass 9/9 and 5/5; private
    receiver-failure units pass 3/3; and the unchanged Perl contract passes all 8 top-level tests. Both neutral
    checkers, capability 90/0/0, 250-name language coverage, the mutation-result surface, Knowledge Map 925/7,861,
    task/index, bounded-history checks, and rendered mdBook pass. The first complete Rust component-gate attempt
    passed every preceding core/runtime target but stopped at `trace_controls` 10/11 because its route-sink test
    expected a `regex_match` from an inert `/x/` on directly entered `Top`; the runtime correctly entered `Top`'s
    loop without testing that regex. The exact task-owned assertion now requires lifecycle execution and forbids
    an entry-implied regex match. A complete rerun passes `trace_controls` 11/11, all Rust core/runtime/generated
    targets, repository-local storage proof for 17 Rust owners and 195 locked registry packages, and both 66/66
    primary CLI matrices.
    The reproducible book output and independent emitted-source workspace are removed; no full CI is run because
    no ADR `0073` canonical trigger moved.
  Verification: **PASS 2026-09-01.** Direct owned proof and the complete Rust component gate are green; the stale
    trace assertion is corrected without production dispatch movement, and `.19.3.3` is the next clean-boundary
    leaf.
  Commit: `FUTURE-PARITY-BACKLOG.19.3.2 - implement Rust map leaves mutation`

- ID: `FUTURE-PARITY-BACKLOG.19.3.3`
  Status: `done; canonical-signoff-complete` (2026-09-02; task-tree-first from Rust `map_leaves!` commit
    `7fabe7371e4e98eea394d5f455286122452caab6`; no push)
  Goal: Restore exact Perl-oracle regeneration and make controlled corpus roots teach parent-loop/child-regex
    semantics without changing accepted backend behavior.
  Dependencies: `.19.3.2`
  Verification tier: `canonical` — this leaf repairs the cross-backend oracle authority and may move the complete
    generated corpus; exact staged receipt-bound CI is mandatory under ADR `0073`.
  Focused checks: toolbox-first Perl/Rust source/result/trace reproduction; exact generator source and committed
    expectation ownership; controlled inert-root/target-regex fixture inventory; all available backend corpus,
    capability-position, root-selection, recursive-observation, and trace consumers; two complete repository-data-
    routed 105-fixture generation passes; Knowledge, task/index, bounded histories, memory, all nine doctrines,
    rendered mdBook when teaching moves, whitespace, and exact no-unowned-behavior-drift proof.
  Canonical trigger: `cross-backend oracle authority + potentially generated corpus + parent Rust closeout` — stage
    the exact candidate and run receipt-bound `tools/run_ci_local.sh` before the atomic commit. The required
    closeout note crosses engineering-history rollover pressure, so its immutable segment, manifest member, and
    finite capacity ADR are infrastructure changes covered by the same final exact canonical boundary.
  Acceptance: Reproduce and root-cause the `capability_position_helper_surface` source/expected split through
    current Perl and Rust execution, then fix the correct owner rather than blessing drift. Inventory controlled
    generator/corpus/trace fixtures whose directly entered root carries an inert regex or whose assertion assumes
    entry tests that regex; rewrite those roots to the established zero-regex form while retaining the reachable
    child's regex and byte-equivalent outputs. Verify across every available backend consumer that entry starts
    the selected rule's mode-driven loop and each outgoing `->` match edge tests its target rule's regex, never the
    entered rule's regex merely because it was selected as root. Two complete project-data-routed generator passes must
    emit all 105 fixtures and leave the committed corpus clean; all available backend corpus consumers,
    capability-position proofs, trace contracts, task/Knowledge/book surfaces, and the designated canonical gate
    must agree.
  Ownership: `.19.3.3` owns the exact pre-existing `capability_position_helper_surface` source/expected drift and
    the controlled fixture/assertion cleanup needed to lock entry-versus-target-regex semantics. It may correct the
    generator, committed oracle, backend tests, traces, the exact Dart/Julia fluent-call whitespace parsing defect,
    the exact Dart complete-line `blkLBL`/`blkSLB` structural-regex bridge omissions, the exact stale Dart `next()`
    test whose bare block became lifecycle `I`, and their durable explanations only after toolbox evidence identifies
    the causal owner. It also owns routing this leaf's new absent-match evidence into a separate Knowledge card
    because the canonical rollout card has only six bytes of remaining bounded capacity. It must not change
    dispatch semantics, extend general PCRE support or unrelated ActionIR syntax, extend `map_leaves!`, admit
    another mutation backend, or move portable/public mutation capability. This leaf also owns durable diagnosis
    and task-tree opening for the unexpectedly slow macOS first launch of newly linked repository-local Rust test
    binaries; implementation remains outside this dirty leaf under queued `.19.3.4`.
    Canonical verification may also repair exact stale phase-0 expected rewrite strings for the same owned Perl
    local-match projection family; that is test-oracle alignment only and must not alter the repaired lowering.
    This leaf also owns the mechanically required engineering-notes rollover triggered by its complete closeout
    evidence and only the exact finite collection/manifest capacity adjustment needed to admit that new immutable
    segment; all byte, aggregate, root, member, lifecycle, storage, and verifier ceilings remain unchanged.
  Checklist: [x] clean activation/task ownership [x] Knowledge/decision/toolbox retrieval [x] two-route drift RED
    [x] causal source/expected owner proof [x] controlled root/target-regex inventory [x] correct owner repair
    [x] bounded all-backend blocker root cause/ownership [x] two-pass 105-fixture reproducibility
    [x] Dart/Julia corpus blocker repair [x] stale Dart `next()` fixture ownership [x] bounded Knowledge evidence routing
    [x] all-backend direct-dependent proof [x] durable sync
    [x] stale phase-0 local-match rewrite expectations aligned [x] mandatory notes rollover/capacity ADR
    [x] final exact staged canonical signoff [x] atomic commit/brief/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` was empty at
    `7fabe7371e4e98eea394d5f455286122452caab6`; `git_message_brief.txt` was zero bytes; `.19.3.2` was committed after
    its complete Rust component gate and post-commit hooks; no background job or generated mdBook output remained.
  Causal RED evidence: current Perl `LinkedSpec::Get` executes the governed position source on `ab`, enters
    `Value`, then skips it after `match_col()` throws typed `source_location_position_out_of_range` with an absent
    local-match offset, producing `[null]`; the exact Rust governed test passes the committed rich record. History
    proves selector migration intentionally preserved that rich value. `call_spec_handler_subst`, `return_descriptor`,
    and emitted-source inspection locate the defect after successful ActionIR classification: the 2026-08-02 typed-
    projection conversion sends undefined `$LSPOS`/`$LMATCH` bounds into strict span projections instead of
    preserving absent-local-match null length/positions and 1-based line/column defaults. This leaf owns correction
    of that complete Perl local-match projection family plus a present zero-width control; entry-match semantics and
    other backends do not move.
  Repair evidence: Perl ActionIR now guards all nine local-match length/position/line/column projections on both
    `$LMATCH` and `$LSPOS`. A genuinely absent local match returns null for structural length/start/end offsets and
    the documented one-based `1` for display lines/columns; a present zero-width match at offset zero retains
    concrete zero length/offsets and column one. The governed live position source again equals its committed rich
    record with no runtime diagnostic, and an independently emitted/loaded Perl parser returns the same record.
    Focused syntax and `t/typed_source_location_perl_contract.t` proof passes 4 top-level tests, including 202
    complete projection assertions and 10 absent/zero-width assertions.
  Controlled-fixture evidence: exact inventory found 67 inline generator rows and the source-backed control-marker
    fixture with an inert `Top` `/x/` before `-> Done`; one additional inline wrapper already used the correct form.
    All 68 generator-owned inline wrappers now use zero-regex entry dispatch, the source-backed control does too,
    and the first complete regeneration changes exactly 68 derived `input.spec` files with zero `input.txt`,
    `expected.json`, or manifest changes. New neutral guard `t/oracle_root_target_regex_semantics.t` passes 7/7,
    rejects the old form in generator/source/corpus, retains the exact 105-case authority, and requires every
    rewritten zero-regex wrapper. The first corpus-diff digest is
    `4df3a7eec18215dc05d823089abc2635fbd9f7df3827fc4fe5cfcafb8eba7e21`.
    A second independent complete `ORACLE_TIMEOUT=30` pass emits the same 105 fixtures, byte-identical corpus diff,
    and exact digest. No expectation, input text, or manifest byte changes in either pass.
  Trace evidence: the existing direct-entry control remains regex-negative. A new positive zero-regex-root fixture
    proves Rust compiles no authored `Top` regex slot, projects `Done`'s `/x/` into the parent dispatch plan, emits
    `target_rule=Done`, enters `Done`, and records exactly one successful regex match. The focused test passes; no
    backend production dispatch implementation changes. The final repository-managed command
    `bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls`
    passes all 12 tests in 2.23 seconds after a 2m07s rebuild and delayed first launch. An initial wrapper call
    without `--manifest-path rust/Cargo.toml` fails before Cargo discovery and changes no file; it is not counted.
  Cross-backend blocker ownership: complete Dart and Julia corpus execution proves every controlled rewritten
    zero-regex-root case passes, so their target-dispatch semantics agree with Perl, Rust, PUC Lua, and LuaJIT.
    The same complete runs expose two pre-existing, unrelated tail defects that prevent truthful all-backend
    admission: Dart and Julia parse `I.return ([])` as an empty `return()` plus invalid `([])` remainder because
    their fluent scanners do not admit whitespace before an argument list; Dart additionally sends the
    self-hosted complete-line `lifecycle_block_line` and `standalone_lifecycle_block` patterns with recursive named
    groups `blkLBL`/`blkSLB` to native `RegExp` because its bounded structural bridge recognizes only the older
    inline `blkLB` family. History
    locates both boundaries in the already-committed standalone-lifecycle rollout even though its durable evidence
    claimed a green full corpus. Before any backend repair, this leaf expands exact ownership only to whitespace-
    tolerant Dart/Julia fluent parsing and the exact Dart `blkLBL`/`blkSLB` complete-line structural families, with focused
    parser/matcher regressions and unchanged expected corpus outputs. It does not admit general PCRE recursion,
    change dispatch semantics, or broaden any other ActionIR syntax.
  Cross-backend blocker repair: Dart and Julia fluent scanners now ignore legal horizontal whitespace between a
    method name and its parenthesized argument list, so `I.return ([])` lowers to `return([])` without a raw tail.
    Dart's bounded structural bridge recognizes only the exact self-hosted complete-line `blkLBL` explicit-
    lifecycle and `blkSLB` standalone-lifecycle families, preserves their positional/named captures and physical-
    line boundary, and continues to reject a non-whitespace suffix. Focused Dart parser/matcher tests pass 19 and
    Julia's direct parser assertion passes. The corrected complete Dart and Julia corpus gates each pass 105/105;
    Rust passes its 3-test manifest/oracle target across all 105 fixtures, and complete PUC Lua and LuaJIT corpus
    routes also pass 105/105. The complete Julia component gate additionally passes its package suite, repository-
    local project-data proof, primary CLI conformance, and final 105/105 corpus route. All committed expected
    outputs remain unchanged.
  Dart gate blocker evidence: the complete Dart component gate reaches one stale interpreter test whose
    `/skip/ { next() }` source now correctly means a regex item followed by standalone lifecycle `I`. The entry
    `next()` therefore exits before regex iteration; the old expectation could pass only while the bare block was
    incorrectly inert. This is the exact Dart analogue of the test-only Lua ownership repair committed by `.15.3`.
    This leaf owns rewriting only that fixture to `-> Skip { next() }` plus child `Skip: /skip/`, where the action
    edge owns the block and the established result remains `keep` at cursor eight. No Dart parser or interpreter
    behavior moves for this repair. The exact focused Dart interpreter test passes 1/1 with result `keep` and
    cursor eight. The corrected complete Dart component gate then passes format, analysis, all 441 tests,
    repository-local project-data proof, both 66/66 CLI matrices, and the 105/105 corpus route.
  Knowledge routing evidence: the first doctrine pass correctly rejects adding this leaf's 825-byte absent-match
    record to `typed-source-location-runtime-rollout-plan.md`, whose clean-HEAD size was 65,530/65,536 bytes. The
    rollout card is restored byte-for-byte to its bounded clean-HEAD content; new focused card
    [[perl-absent-local-match-projection-repair]] owns the causal and reverify detail. After the separate Rust
    launch-latency finding card is added, the regenerated Knowledge Map passes at 927 facts / 7,878 question keys,
    and README routed-destination closure passes without raising any per-file, collection, aggregate, or README
    limit.
  Rust launch-latency finding: the first repository-local `trace_controls` build finishes in 55m44s after
    prolonged per-crate waits. The resulting test process then remains at 112 KiB and zero test output for more
    than three minutes. A process census shows Cargo and the test binary alive while macOS `syspolicyd` consumes
    substantial CPU; an exact one-second stack sample contains only `_dyld_start`, proving the test has not entered
    Rust code and the new semantic fixture is not looping. The sample tool's exact off-volume report is consumed,
    deleted, and verified absent. This environment/toolchain latency is fishy enough to require queued task-tree
    audit `.19.3.4`; no trust bypass or speculative workflow change belongs in `.19.3.3`. The initiating trace
    command was also plain Cargo and therefore read the user-home registry even though its target stayed repository-
    local. Its 12/12 result is diagnostic only; this leaf owns an exact rerun through `tools/run_cargo_local.sh`
    before accepting trace signoff, and no off-volume dependency access will be counted as final evidence. The
    managed root-selection Rust admission build subsequently takes 117m57s, while the managed trace rebuild takes
    2m07s and its launched test remains silent for about 98 seconds before completing its 12 tests in 2.23s. These
    clean-versus-warm measurements strengthen `.19.3.4.0`; they do not justify a trust or workflow change here.
  Direct-dependent evidence: `tools/check_recursive_observation_six_runtime.sh` passes all six runtime routes plus
    capability 90/0/0 and language coverage 250 current names / 105 corpus fixtures + one named-mark fixture / 126
    independent public Perl contracts. `tools/check_root_rule_selection_five_backend.sh` passes the neutral and
    Perl routes; exact Rust 1/1, Dart 1/1, Julia 137/137, PUC Lua 139, and LuaJIT 139 admission consumers; the five-
    backend × two-environment × six-case primary matrix; generated-source Rust 105/105; capability 90/0/0; and the
    same language-coverage ledger. The managed Rust trace target passes 12/12. The mdBook renders successfully and
    its generated output is removed; Knowledge Map regeneration/check passes at 927 facts / 7,878 keys.
  Canonical attempt evidence: the first complete staged run reaches the sandbox locality probe only after every
    preceding semantic/runtime check passes, then the restricted harness denies `sandbox-exec` with status 71.
    The exact unchanged elevated rerun passes that process-locality proof and every preceding check, including the
    five-backend root-selection contract and focused Perl root routes, before Phase 0 reports exactly one failed
    subtest out of 1,032: three expected strings still encode the pre-repair unguarded `match_start_pos()`,
    `match_len()`, and `match_end_pos()` lowerings. The emitted lowerings equal the focused 202-projection contract
    and correctly require both `$LMATCH` and `$LSPOS`; this leaf therefore owns aligning only those three stale
    Phase-0 expectations, rerunning the focused regression, and restarting canonical on the restaged candidate.
    Syntax, the 4-test/202-projection focused contract, and direct substitution probes pass; the complete
    repository-routed Phase-0 file then passes 1,032/1,032 in 1,046 seconds.
  Canonical signoff evidence: the exact staged candidate passes all nine doctrines; six-runtime staged,
    progressive, gap, recognition, typed-source, and recursive-observation proof; the five-backend root-selection
    contract and focused Perl root routes; six-runtime MCP and semantic-introspection composition; duplicate-slot,
    repetition, lifecycle, cursor, callable, diagnostic, generated-source, storage/process-locality, and relocated-
    root checks; both 66/66 CLI environments; and Phase 0 1,032/1,032 in 1,000 seconds. The gate writes the required
    staged receipt from clean activation HEAD, and the final closeout-only status/index edits are recomposed on the
    exact landing candidate before commit.
  Canonical latency evidence: a read-only process census during that run found an independent Claude-owned shell
    deleting this checkout's `rust/target/debug/incremental`, `rust/target/es19_boot`, `rust/target/audit_notest`,
    and `rust/target/coldprobe` directories and invoking `cargo sweep --time 7`; no tracked file changed, but the
    concurrent cleanup invalidated Rust incremental artifacts during receipt-bound CI. A later Rust MCP binary
    remained at 112 KiB in macOS `_dyld_start` for more than five minutes, then executed its three tests in 2.43
    seconds. The one-second sample report written by macOS under `/tmp` was consumed, deleted exactly, and verified
    absent. These are measured inputs for `.19.3.4.0`, not a semantic failure or permission to weaken trust,
    locality, or verification.
  Closeout rollover trigger: the complete canonical/latency record raised `DEVELOPMENT_NOTES.md` to 465/512
    lines, crossing the enforced 90% rollover threshold. This node owns the mechanical immutable segment,
    manifest/root update, finite capacity ADR, index/Knowledge synchronization, and final canonical restart; no
    executable scope expands.
  Closeout rollover evidence: the governed tool archives 218 complete clean-HEAD lines as immutable segment
    `4986` (23,232 bytes, SHA-256 prefix `1f25a697bee5`) from activation commit `7fabe737`, leaving the hot root at
    247/512 lines and 25,482/65,536 bytes. The resulting collection is 22 files / 24,732 lines / 2,648,238 bytes
    with a 21-line, 12,558-byte manifest. ADR `0099` advances only `max_files` 21→22 and manifest `max_lines`
    20→21; every root, byte, segment, aggregate, owner, lifecycle, verifier, route, and storage control remains
    unchanged.
  Verification: **PASS 2026-09-02.** Focused and all-backend direct-dependent proof, mandatory bounded-history
    rollover, exact staged canonical CI/receipt, atomic commit, brief clearing, and clean handoff are complete;
    `.19.3.4.0` is the next clean-boundary leaf.
  Commit: `FUTURE-PARITY-BACKLOG.19.3.3 - restore oracle root semantics`

- ID: `FUTURE-PARITY-BACKLOG.19.3.4`
  Status: `done; no repository-controlled repair required` (2026-09-02)
  Goal: Measure and safely contain abnormal macOS first-launch validation latency for repository-local Rust test
    binaries without weakening operating-system trust, project-data locality, or verification coverage.
  Children: `.19.3.4.0`, `.19.3.4.1`
  Dependencies: `.19.3.3`
  Verification: **PASS 2026-09-02.** Controlled `.0` evidence classifies external per-artifact macOS policy/cache
    state; `.1` is explicitly not required and no speculative workaround is admitted.
  Commit: closed by `FUTURE-PARITY-BACKLOG.19.3.4.0 - classify macOS Rust launch latency`

- ID: `FUTURE-PARITY-BACKLOG.19.3.4.0`
  Status: `done; focused-signoff-complete` (2026-09-02; task-tree-first from exact clean oracle/root-semantics
    commit `5c20f95859118574e1daaf5f5a70b28abb4774bf`; no push)
  Goal: Reproduce and classify the cold-build/first-launch latency before selecting any repair.
  Dependencies: `.19.3.3`
  Verification tier: `focused` — read-only process/toolchain/filesystem evidence and an evidence-backed closeout
    only; no workflow, trust, storage, CI, test, runtime, or language behavior changes.
  Focused checks: controlled managed-run first/warm inventory timing on two existing distinct code hashes; live
    process/CPU census; exact xattr/signature/`spctl` metadata; same-device and run-lifecycle proof; two fresh unique
    isolated builds and untouched first/warm launches; task/index, Knowledge, Toolbox/book, bounded histories,
    memory/live/roadmap synchronization, mdBook render, all nine doctrines, and whitespace.
  Canonical trigger: `none` — the classification changes no executable, build, cache, trust, storage, CI, test, or
    public language contract. `.19.3.3` already supplied the designated canonical parent behavior boundary; any
    future repair would require separate `.19.3.4.1` activation and canonical infrastructure proof.
  Acceptance: From a clean boundary, use repository-local controlled probes to separate dependency compilation,
    linking, first process launch, and test execution time. Record process states, CPU/OS-validation ownership,
    executable metadata and extended attributes, repository-volume/cache topology, concurrent-versus-serial Cargo
    behavior, and warm rerun contrast. Prove whether `syspolicyd`/Gatekeeper, artifact attributes, SSD execution,
    redundant isolated targets, or another exact seam owns the delay; remove every diagnostic artifact, especially
    any OS tool output written outside project storage. Ratify a narrowly safe `.1` repair or close with durable
    external-toolchain evidence if no repository-controlled defect exists. Never disable Gatekeeper, change global
    trust policy, clear ambiguous shared metadata, or bless off-volume project data.
  Checklist: [x] clean activation [x] Knowledge/toolbox retrieval [x] controlled timing reproduction
    [x] process/stack/metadata evidence [x] warm/concurrency/storage comparison [x] exact causal classification
    [x] `.1` acceptance refinement or evidence-backed no-project-defect closeout [x] durable sync [x] focused proof
    [x] atomic commit/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` is empty at committed clean HEAD
    `5c20f95859118574e1daaf5f5a70b28abb4774bf`; the committed canonical receipt matches that HEAD,
    `git_message_brief.txt` is zero bytes, reproducible mdBook output is absent, and no canonical, commit, Cargo,
    Rust compiler, or LinkedSpec test process remains. The Knowledge Map resolves
    [[macos-rust-first-launch-validation-latency]] before diagnostics; its dated evidence requires controlled serial
    cold/warm reproduction that separates the previously observed `_dyld_start`/`syspolicyd` delay from the
    independently observed Claude-owned target deletion and `cargo sweep` interference.
  Queued evidence: `.19.3.3` separates long cold builds and pre-main launch delay from fast test execution, observes
    macOS `syspolicyd` plus `_dyld_start`, and catches a separate Claude-owned cleanup process deleting four
    repository-local Rust target/cache directories and running `cargo sweep --time 7` during canonical CI. `.0`
    must reproduce under controlled serial ownership and distinguish OS validation from concurrent artifact
    invalidation before selecting any repair.
  Controlled baseline evidence: with no Linkedspec Cargo/Rust/cleanup process present, the checkout and
    `rust/target`, `rust/target/debug`, and `rust/target/debug/deps` directories carry
    `com.apple.provenance`; the authored Rust source and installed `rustc`/`cargo` executables do not. Both current
    `trace_controls` Mach-O binaries inherit provenance, are arm64 ad-hoc linker-signed with distinct code-directory
    hashes and no team identifier, and each read-only `spctl -a -vv -t execute` assessment takes about one minute
    before returning `rejected`. A plain `mktemp` file inside a managed repository-local run also inherits the same
    provenance, proving the attribute is not emitted specifically by Rust or the linker.
  Controlled direct-launch evidence: inside one serial managed run, the current
    `trace_controls-ac091f2e380dee79` binary's first `--list` launch took 45.32 seconds at 0.00 user/system CPU,
    while `syspolicyd` reached 51.1% CPU and the Rust process was not yet visible in the process census. The
    immediately repeated launch of the identical binary and twelve-test inventory took 0.00 seconds. This
    reproduces policy/loader startup latency independently of dependency compilation, linking, and test-body work.
    The distinct `trace_controls-8a91930698b7f9a7` hash independently reproduces 51.75 seconds versus 0.00 seconds
    for its ten-test inventory, with 0.00 user/system CPU, no visible Rust process, no Cargo/compiler/cleanup
    competitor, and `syspolicyd` at 57.8% CPU during the first launch. Suite contents and one specific code hash
    are therefore excluded; a controlled disposable-copy metadata comparison remains before final causality.
  Disposable metadata-probe evidence: two exact managed-run copies were explicitly re-signed under distinct
    identifiers. Attempting to delete `com.apple.provenance` from one exact throwaway copy returned success, but an
    immediate read showed the attribute already present again; this checkout's macOS policy therefore prevents a
    stable provenance/no-provenance A/B without an out-of-scope trust change. Explicit signing changed both copies
    from `adhoc,linker-signed` to normalized `adhoc`, and their first direct inventory launches took only 0.50 and
    0.43 seconds despite retained provenance. That is a candidate signing/registration seam, not a conclusion:
    `codesign` itself may have warmed each new hash, so `.0` still requires an untouched freshly linked hash and an
    explicitly signed fresh copy compared before either is executed.
  Fresh serial evidence: a default isolated no-run rebuild reused the already warm `ac091f2e` artifact hash and is
    therefore excluded from first-launch causality. Two behavior-equivalent isolated builds then forced genuinely
    new hashes only through test-profile debug metadata: `3960e8c0` built in 37.18 seconds, and untouched linker-
    signed `14e07002` built in 23.17 seconds. Both retained provenance. The first run's explicitly signed copy and
    untouched original launched in 0.44/0.45 seconds; the second run performed no copy or forced signing and its
    untouched first/warm inventory launches took 0.41/0.00 seconds. Fresh compile/link/launch is therefore healthy
    with repository-local Cargo cache and isolated same-device targets. Provenance, ad-hoc linker signing,
    executable size, high `syspolicyd` CPU, and first launch are each insufficient alone to reproduce the defect.
  Classification: the 45.32/51.75-second measurements prove an external per-artifact macOS policy/cache wait for
    two older, previously unexecuted hashes; the 0.41-second untouched unique control proves no persistent
    Linkedspec source/build/storage/signing defect. The contaminated canonical interval additionally had
    independent target deletion/`cargo sweep` interference, while this serial audit used no competing Linkedspec
    Cargo/compiler/cleanup process. Host identity is macOS 26.5.2 build 25F84 / Darwin 25.5.0. Sampling
    `syspolicyd` itself requires ungranted `sudo`; the managed failed attempt retained no artifact, and the earlier
    unprivileged test-process sample already fixes the wait before Rust main at `_dyld_start`. No global trust,
    xattr, cache, coverage, or workflow mutation is justified; `.19.3.4.1` is not required.
  Focused signoff: **PASS 2026-09-02.** The derived Knowledge Map is synchronized at 928 facts / 7,883 question
    keys; both bounded histories pass at changes 371/512 lines and 33,684/65,536 bytes plus engineering notes
    266/512 and 27,425/65,536. The sole-facing mdBook renders successfully after routing the diagnosis into its
    own bounded page; README routing pressure passes 20 surfaces / 62 routes / 32/32 mutations. Task metadata,
    exact partition index, bounded memory handoff, project-data residue census, whitespace, and all nine registered
    doctrines pass. The candidate contains only task, Knowledge, Toolbox/book, roadmap, and live continuity
    documentation; no executable, test, build, cache, trust, storage, CI, or language contract changed, so the
    recorded focused tier remains exact under ADR `0073`.
  Commit: `FUTURE-PARITY-BACKLOG.19.3.4.0 - classify macOS Rust launch latency`

- ID: `FUTURE-PARITY-BACKLOG.19.3.4.1`
  Status: `not-required; .19.3.4.0 proves no persistent repository-controlled defect`
  Goal: Implement only the measured repository-controlled latency repair, if `.0` proves one is necessary.
  Dependencies: `.19.3.4.0`
  Verification: `not applicable` — `.0` selects no repair; activation would require new contradictory controlled
    evidence plus canonical infrastructure ownership under ADR `0073`.
  Acceptance: Apply the smallest `.0`-ratified project-local repair, preserve exact test coverage and failure
    propagation, keep all generated/cache/temp data on the repository filesystem, and leave OS trust protections
    enabled. Prove bounded cold and warm timings against the frozen reproduction plus unchanged Rust focused and
    canonical consumers; synchronize task, Knowledge, Toolbox/book guidance, storage/doctrine evidence, and clean
    handoff. If `.0` proves the latency is wholly external and no safe repository repair exists, mark this leaf
    not-required with that exact evidence rather than introducing a speculative workaround.
  Closure evidence: fresh isolated same-device builds complete in 23.17-37.18 seconds; the first hash's signed-
    copy/original comparison runs in 0.44/0.45 seconds, and the second wholly unmanipulated provenance-tagged
    linker-signed hash first-launches in 0.41 seconds. Only older unwarmed artifacts reproduce 45.32/51.75-second
    macOS policy waits, and the original canonical evidence was independently contaminated by target deletion and
    `cargo sweep`. Re-signing, clearing provenance, prelaunching, weakening Gatekeeper, or changing cache/test
    topology would therefore be speculative and is prohibited.
  Commit: `not required`; `.19.3.4.0` records the evidence-backed closeout.

- ID: `FUTURE-PARITY-BACKLOG.19.4`
  Status: `done; closed by .19.4.2` (2026-09-02)
  Goal: Implement the unchanged v1 contract on Dart across native and supported generated/emitted routes.
  Children: `.19.4.1`, `.19.4.2`
  Dependencies: `.19.3`
  Verification: `focused-signoff-complete`; both Dart mechanisms and the parent-loop/target-regex invariant pass
    native/generated/direct-dependent proof; Julia `.19.5.1` is the next independent backend leaf.
  Commit: `FUTURE-PARITY-BACKLOG.19.4.2 - implement Dart map leaves mutation`

- ID: `FUTURE-PARITY-BACKLOG.19.4.1`
  Status: `done; canonical-signoff-complete` (2026-09-02; task-tree-first from exact clean Rust closeout commit
    `1247316d7d51c60243a21fb65209f3b7f851207d`; no push)
  Goal: Implement Dart nested write-vivification through typed parsed/emitted state and runtime.
  Dependencies: `.19.3`
  Verification tier: `canonical` — this leaf implements the frozen nested-write v1 contract on a new backend and
    moves Dart typed parsed/generated/emitted carriers. ADR `0073` classifies backend admission and generated-
    format movement as a designated exact staged boundary.
  Focused checks: frozen neutral 5 AST / 7 syntax / 11 success / 16 structural / 3 expression-failure / 3 read-
    exclusion cases; all 105 write-vivification mutations; Dart parser/compiler/runtime native, serialized,
    generated-plan, emitted-state/source, and primary CLI routes; adjacent scalar assignment, access, helper,
    `map_leaves!`-absence, diagnostics/span, corpus, and complete Dart component dependents; format/analyze,
    project-data containment, Knowledge, task/index, bounded histories, memory/live/roadmap/book, mdBook render,
    whitespace, and all nine doctrines.
  Canonical trigger: `Dart backend implementation + typed generated/emitted carrier movement` — stage the exact
    candidate with no unstaged inputs and run receipt-bound `bash tools/run_ci_local.sh` before atomic commit.
  Acceptance: Preserve `linkedspec-write-vivification-v1` unchanged. Parse one typed nested-write node whose
    segments retain authored expressions and Unicode-scalar spans; evaluate all segment expressions left-to-right
    and then the RHS exactly once; snapshot binding state only afterward; isolate dense harray/array container
    creation and publish atomically only on success; detach stored/returned mutable values; distinguish absent from
    present null; preserve exact errors and non-write read behavior. Carry the typed node through every supported
    Dart native/serialized/generated/emitted route without admitting `map_leaves!`, Julia/Lua behavior, or a
    portable/public capability early.
  Checklist: [x] clean activation/task ownership [x] Knowledge/decision/toolbox retrieval [x] Dart owner inventory
    [x] exact RED through frozen neutral contract [x] typed parse/serialized/generated/emitted carrier
    [x] isolated dense runtime publication/evaluation/detachment [x] diagnostics/read exclusions
    [x] focused Dart/direct-dependent proof [x] durable docs/task/index synchronization
    [x] exact staged canonical signoff [x] atomic commit/brief/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` is empty at committed clean HEAD
    `1247316d7d51c60243a21fb65209f3b7f851207d`; `git_message_brief.txt` is zero bytes; reproducible mdBook output
    is absent; repository-managed run residue is zero; post-commit activation-pointer and all nine doctrines pass;
    and an escalated process census finds no LinkedSpec gate, Cargo, Rust compiler, or test job beyond its own
    filter process. `.19.3.4.0` is committed complete and closes Rust `.19.3` without a speculative repair.
  Retrieval/RED evidence: ADR `0036`, [[write-vivification-neutral-contract]], the Perl/Rust realization cards,
    frozen contract/checker, and `.19.1.1`/`.19.2.1`/`.19.3.1` task evidence are read before source changes. The
    neutral checker passes 5 valid AST / 7 syntax / 11 success / 16 structural / 3 expression-failure / 3 read-
    exclusion cases, eight composition writes, and 105 rejected mutations; Dart's exact legacy no-autovivification
    test remains green. Source inventory finds an existing dormant `ActionAssignNestedAccessExpr` and isolated-
    clone runtime, but quoted segments are parser-tagged keys, one-segment writes collapse to
    `ActionAssignHashIndexExpr`, missing roots/intermediates return null, spans include brackets/code units, and no
    typed v1 structural diagnostic exists. New permanent Dart RED proves both seams: the first frozen syntax case
    is the wrong AST node and an absent mixed root returns `[null, null]` instead of the detached created tree.
  Implementation evidence: authored one- and many-segment writes now lower to one
    `ActionAssignNestedAccessExpr`; each `ActionWritePathSegment` retains its typed expression, source, and exact
    Unicode-scalar span. Parser/callable/compiled-state/generated/emitted/runtime seams reject corrupt or empty
    typed segment state. Runtime evaluates segments then RHS, snapshots presence afterward, selects harray/array
    from evaluated string/nonnegative integer values, creates only dense unambiguous missing state on an isolated
    copy, publishes once, detaches mutable boundaries, and preserves completed expression effects. Exact typed
    diagnostics own invalid selector, kind conflict, and array gap; reads remain non-creating.
  Carrier evidence: the same node executes natively, after `SpecFile` JSON reconstruction, in validated generated
    plans, through emitted source, in a fresh independently analyzed/executed caller package, and through the
    primary CLI. Malformed carriers fail closed. Dart `map_leaves!`, Julia/Lua, capability/public admission, and
    recurring cross-backend proof remain unchanged.
  Verification evidence: the neutral checker passes 5 AST / 7 syntax / 11 success / 16 structural-failure / 3
    expression-failure / 3 read-exclusion cases, eight composed writes, and 105 rejected mutations. Permanent Dart
    proof covers the complete fixture, detachment, function presence, astral spans, malformed carriers, and every
    supported route. Focused parser/runtime/contract proof passes 67/67 + 6/6; the full package passes 450/450.
    The complete corrected Dart gate passes format 110/0, strict analysis, 24 managed temporary owners / 47 locked
    packages, CLI 66/66 in default and POSIX environments, and corpus 105/105. Its first run correctly stopped on
    the new test becoming the 24th `Directory.systemTemp` owner; exact registration and rerun restore containment.
  Signoff evidence: task/index, ADR/Knowledge Map, architecture, roadmaps, bounded live/history surfaces, memory,
    and the sole-facing mdBook identify Perl/Rust/Dart as current nested-write implementations and retain Dart
    bang plus Julia/Lua/public boundaries. Canonical attempt one passes through punctuation-light behavior, then
    catches a stale 61-file aggregate-selector public cardinality guard after `.19.3.4.0` added the macOS launch-
    latency mdBook page. The corrected checker, current mdBook status, and two Knowledge owners lock 62 files with
    unchanged 32 classified references / zero current examples. Render, histories, storage, whitespace, all nine
    doctrines, and the restarted exact receipt-bound staged canonical CI pass against the final candidate; no
    generated output or background job remains.
  Verification: `canonical-signoff-complete`
  Commit: `FUTURE-PARITY-BACKLOG.19.4.1 - implement Dart write vivification`

- ID: `FUTURE-PARITY-BACKLOG.19.4.2`
  Status: `done; focused-signoff-complete` (2026-09-02; task-tree-first from exact clean Dart nested-write commit
    `6f0ae8706c497497fcfd5e085753aebb1ae310b8`; no push)
  Goal: Implement Dart `map_leaves!` through typed parsed/emitted state and runtime.
  Dependencies: `.19.4.1`
  Verification tier: `focused` — this leaf changes only the already-ratified Dart private implementation and its
    direct neutral/generated consumers. Julia/Lua, portable capability, public examples, recurring cross-backend
    admission, and the push boundary remain owned by `.19.5-.9`.
  Focused checks: unchanged neutral checker and exact Dart projection of all 4 valid syntax, 14 invalid syntax,
    5 exclusions, 10 successes, 8 pre-commit failures, continuation/shadow/guard-release/nonbang/detachment proof,
    167 base mutations, and 592 nested-write compositions; parser, compiler, reconstructed `SpecFile`, generated-
    plan, emitted-source, independently executed caller, primary CLI, package, corpus, and storage dependents;
    formatting/analyzer, Knowledge, task/index, bounded histories, memory, all nine doctrines, rendered mdBook,
    cross-backend no-drift, and whitespace. Also lock the discovered composition-boundary fixture repair from an
    inert `/x/ -> Done` root to the established zero-regex `-> Done` form on all six primary routes.
  Canonical trigger: `none` — escalate only if verification requires cross-backend/public admission,
    infrastructure/storage/doctrine movement, or a mandatory bounded-history rollover. Otherwise `.19.7-.9`
    retain portable/public admission and the exact staged canonical/push boundary.
  Acceptance: Parse only `IDENTIFIER.map_leaves!() { ACTION_BLOCK }` as the dedicated typed
    `receiver_mutation_chain`, retaining receiver/call/callback/continuation structure and exact authored Unicode-
    scalar spans through contracts, reconstructed `SpecFile`, generated plans, source emission, and an independent
    emitted-source caller. Resolve one existing bare uniform-binding identity containing an harray or array;
    traverse a detached original-shape snapshot in sorted-key or index order; provide detached `value`, complete
    copied `path`, `depth`, and `key|index`; replace each leaf with the detached callback result without revisiting
    replacement aggregates; then commit the rebuilt binding once and return a detached updated root before an
    ordinary fluent continuation. Guard the resolved receiver identity during callbacks so direct, nested-write,
    nested-bang, helper-mediated, array-end, and binding-target pipeline writes fail before operand/segment/RHS
    evaluation with exact `receiver_mutation_reentrant`, while unrelated and distinct same-spelling shadow
    identities remain legal. Callback/re-entrant failure leaves the receiver unchanged and releases the guard;
    continuation failure keeps the prior commit. Preserve non-bang behavior and compose exactly with Dart
    `.19.4.1` nested writes; reject malformed typed carriers; do not admit Julia/Lua or portable/public capability.
  Ownership: `.19.4.2` owns Dart parser/compiler/runtime/carrier implementation, direct proof, Dart status/docs,
    parent `.19.4` closeout, and the exact behavior-neutral stale root spelling discovered in the required frozen
    composition boundary. It must not otherwise change the frozen neutral contracts, Julia/Lua behavior, public
    current examples, capability/facade/schema/MCP surfaces, recurring cross-backend admission, or push state.
  Checklist: [x] clean activation/task ownership [x] Knowledge/ADR and sibling-contract retrieval
    [x] Toolbox-first Dart owner inventory [x] exact RED and stale-root cause through frozen neutral contract
    [x] typed parser/compiler/reconstructed/generated/emitted carrier [x] atomic identity-guarded runtime
    [x] base/composition/generated/CLI proof [x] focused dependent/no-drift proof
    [x] durable docs/Knowledge/live sync [x] focused signoff [x] atomic commit/brief/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` was empty at
    `6f0ae8706c497497fcfd5e085753aebb1ae310b8`; `git_message_brief.txt` was zero bytes; the committed canonical
    receipt matched that HEAD; `.19.4.1` was committed with all nine doctrine hooks after exact staged canonical
    proof; reproducible mdBook output was absent; and a permission-authorized process census found no LinkedSpec
    gate, Dart, Cargo, compiler, or test job in flight. The Knowledge Map routed this leaf to the frozen neutral
    mutation/composition contracts, the pure-function carrier resolution, Dart uniform-binding owner, and the
    completed Perl/Rust realization boundaries before behavior inspection.
  Pre-implementation finding: the required primary-command RED exposed that the composition contract's
    `current_boundary.source` and non-bang twin still used `Top:: /x/ -> Done`, contrary to the established
    parent-loop/target-regex invariant and `.19.3.3`'s complete controlled-fixture cleanup. Explicit Dart CLI proof
    with `--top-rule Top` compiled and invoked both stale forms successfully but returned `null`, because the inert
    parent regex cannot serve as the child-owned dispatch control. Removing only `/x/` makes the non-bang twin
    return `{"leaf":[]}` and the bang twin reach Dart's exact parser-invocation failure. This leaf owns correcting
    that fixture and checker anchors across all six declared routes before using it as Dart implementation proof;
    the frozen map/write semantics and route expectations do not change.
  Implementation evidence: Dart parses only the exact bare-identifier bang form into
    `ActionReceiverMutationChainExpr` with typed binding, callback, and ordinary-continuation records. Callable,
    compiled-state, reconstruction, emitter, generated-plan, and direct runtime boundaries preserve or validate
    the carrier with Unicode-scalar spans and reject corrupt state. The runtime maps a detached original-shape
    snapshot under root-kind recursion, copies every callback/replacement boundary, publishes once, returns a
    detached result, and starts continuation only after commit and guard release.
  Identity/guard evidence: execution assigns stable visible-binding identities and fresh scoped/function-local
    identities. Direct assignment/append, nested write/bang, `set`, `set_key`, `push`, `split`, four array-end
    methods, regex substitution, and every binding-target array pipeline reject the active receiver before
    operand/segment/RHS evaluation. Unrelated and distinct same-spelling identities remain legal. `finally`
    releases the guard on callback, rebuild, or store failure. The separately owned ordinary Dart write-back gap
    for `split_each`, `filter_match`, and `uniq` remains unchanged under backlog `.5`.
  Dart proof evidence: eleven permanent tests project all 4 valid / 14 invalid / 5 excluded syntax rows, 10
    successes, 8 failures, special state/continuation/shadow/guard/nonbang/detachment cases, six callback and one
    continuation composition, malformed state, reconstructed `SpecFile`, native/generated-plan/emitted-source,
    independently analyzed/executed caller, and primary CLI. The complete Dart gate passes format 111/0, strict
    analysis, package 461/461, 25 managed temporary owners / 47 locked packages, CLI 66/66 in default and POSIX
    environments, and corpus 105/105. Both neutral checkers retain 167 base + 592 composition and 105 write
    mutation rejections.
  Cross-backend/root evidence: unchanged Perl mutation proof passes all 8 top-level tests and unchanged Rust
    mutation proof passes 9/9. The dedicated root-selection driver passes its 8/3/3 neutral contract with 54
    mutations; Perl 12/12, Rust 1/1, Dart 1/1, Julia 137/137, PUC Lua 139, and LuaJIT 139 native admission; the
    exact 5 backends x 2 environments x 6 selected primary matrix; and generated-source/capability/language
    ledgers. This directly locks the corrected zero-regex `Top` loop selecting `Done`'s regex. The first Rust
    focused build took 19m20s; its new binary then waited pre-main entirely at macOS `_dyld_start`, matching the
    already-classified `.19.3.4.0` external per-artifact boundary. The one-second sample was consumed, its exact
    off-volume report deleted, and residue proved absent; once entered, all nine tests ran in 29.23s.
  Signoff evidence: Knowledge regenerates and validates at 930 facts / 7,904 keys; task/index, bounded histories,
    memory/live status, architecture, both roadmaps, ADR/index, Toolbox, and the sole-facing mdBook are aligned.
    The book renders successfully and its generated output is removed. `git diff --check`, 60-line memory, all
    nine doctrines, exact project-storage routes, and residue checks pass. This remains a focused leaf: no
    capability/public admission, infrastructure/doctrine movement, rollover, or push-boundary trigger occurred.
  Verification: `focused-signoff-complete`
  Commit: `FUTURE-PARITY-BACKLOG.19.4.2 - implement Dart map leaves mutation`

- ID: `FUTURE-PARITY-BACKLOG.19.5`
  Status: `done; canonical-signoff-complete` (2026-09-03; both Julia mechanisms implemented, no push)
  Goal: Implement the unchanged v1 contract on Julia across native and supported generated/emitted routes.
  Children: `.19.5.1`, `.19.5.2`
  Dependencies: `.19.4`
  Verification: `.19.5.1` canonical 406-assertion write proof plus `.19.5.2` canonical 496-assertion mutation proof;
    complete Julia package/CLI/corpus, repository storage, neutral mutations, durable sync, and doctrines pass.
  Commit: `.19.5.1` `FUTURE-PARITY-BACKLOG.19.5.1 - implement Julia write vivification`; `.19.5.2`
    `FUTURE-PARITY-BACKLOG.19.5.2 - implement Julia map leaves mutation`

- ID: `FUTURE-PARITY-BACKLOG.19.5.1`
  Status: `canonical-signoff-complete` (activated 2026-09-02; completed 2026-09-03 from exact clean Dart
    mutation commit `0fdb809556aa2229360973b2746b06a9bbf2e105`; no push)
  Goal: Implement Julia nested write-vivification through typed parsed/emitted state and runtime.
  Dependencies: `.19.4`
  Verification tier: `canonical` — this leaf implements the frozen nested-write v1 contract on a new backend and
    moves Julia typed parsed/reconstructed/generated/emitted carriers. ADR `0073` classifies backend admission
    and generated-format movement as a designated exact staged boundary.
  Focused checks: frozen neutral 5 AST / 7 syntax / 11 success / 16 structural / 3 expression-failure / 3 read-
    exclusion cases and all 105 mutations; Julia parser/compiler/runtime native, reconstructed, generated-plan,
    emitted-source, independent-caller where supported, and primary CLI routes; adjacent assignment/access/helper,
    `map_leaves!`-absence, diagnostics/span, corpus, and complete Julia component dependents; formatting/static
    checks, project-data containment, Knowledge, task/index, bounded histories, memory/live/roadmap/book, rendered
    mdBook, whitespace, and all nine doctrines.
  Canonical trigger: `Julia backend implementation + typed generated/emitted carrier movement` — stage the exact
    candidate with no unstaged inputs and run receipt-bound `bash tools/run_ci_local.sh` before atomic commit.
  Acceptance: Preserve `linkedspec-write-vivification-v1` unchanged. Parse one typed nested-write node whose
    segments retain authored expressions and Unicode-scalar spans; evaluate every segment left-to-right and then
    the RHS exactly once; snapshot binding presence only afterward; create dense selector-determined harray/array
    state on an isolated copy; publish once only after structural success; and detach initial, RHS, stored, and
    returned mutable values. Distinguish absent from present null, preserve completed expression effects and exact
    typed errors, keep reads non-creating, and preserve fresh rule/function invocation state. Carry and validate
    the node through every supported Julia native/reconstructed/generated/emitted route without admitting
    `map_leaves!`, Lua behavior, or portable/public capability early.
  Ownership: `.19.5.1` owns Julia parser/compiler/runtime/carrier implementation, permanent direct proof, Julia
    status/docs, and compatibility evidence only. It must not alter the frozen neutral/composition contracts,
    Perl/Rust/Dart/Lua behavior, public current examples, capability/facade/schema/MCP surfaces, or push state.
  Checklist: [x] clean activation/task ownership [x] Knowledge/ADR and sibling-contract retrieval
    [x] Toolbox-first Julia owner inventory [x] exact RED through frozen neutral contract
    [x] typed parser/compiler/reconstructed/generated/emitted carrier [x] isolated dense runtime publication
    [x] diagnostics/evaluation/detachment/read exclusions [x] focused Julia/direct-dependent proof
    [x] durable docs/Knowledge/live sync [x] exact staged canonical signoff [x] atomic commit/brief/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` was empty at
    `0fdb809556aa2229360973b2746b06a9bbf2e105`; `git_message_brief.txt` was zero bytes; post-commit activation
    boundary and all nine hooks passed; reproducible mdBook output and the consumed off-volume sample report were
    absent; and no prior result remained to consume. Dart `.19.4.2` and parent `.19.4` are committed complete.
  Implementation evidence: added `ActionWritePathSegment` and unified every authored Julia one/many-segment
    bracket assignment under `ActionAssignNestedAccessExpr`; carried and validated it through action visitors,
    callable/semantic contracts, compiled state, source emission, generated plans, reconstruction, and runtime.
    The interpreter evaluates segments then RHS exactly once, snapshots presence afterward, builds only dense
    selector-determined containers on an isolated copy, publishes once, detaches mutable boundaries, preserves
    completed expression effects and original evaluation failures, rejects bound null/wrong kinds/gaps through
    exact typed diagnostics/spans, and leaves reads non-creating. Corrupt typed carriers fail closed.
  Permanent proof: `julia/test/write_vivification_contract_test.jl` consumes the unchanged neutral fixture and
    passes 406 assertions across 5 AST / 7 invalid / 4 excluded forms, 11 successes, 16 structural failures,
    3 evaluation failures, 3 read exclusions, astral spans, detachment, invocation-local presence, corruption,
    native/reconstructed/generated-plan/emitted-module/CLI routes. The independent checker retains 105 rejected
    mutations. The complete Julia package suite, primary CLI, corpus 105/105, and project-data containment at
    21 temporary owners / 5 locked package trees pass; the stale hard-coded 20-owner success sentence was
    corrected after its already-exact 21-versus-21 inventory comparison passed.
  Durable sync: Knowledge, ADR `0036`/index, architecture, both roadmaps, task registry/index, Toolbox, memory/live,
    bounded histories, and the sole-facing mdBook distinguish Julia write support from its still-pending bang
    support. Two stale mdBook Dart-bang sentences and the stale pre-Dart task-registry frontier are corrected;
    dated historical records remain unchanged. Julia `map_leaves!`, Lua, recurring proof, capability/public
    admission, and every other backend remain outside this leaf.
  Verification: `canonical-signoff-complete` — focused neutral 105-mutation, Julia 406-assertion, complete package,
    storage 21/5, primary CLI, and corpus 105/105 proofs pass. Knowledge/task/history/doctrine checks, rendered
    mdBook, whitespace, and exact staged receipt-bound `bash tools/run_ci_local.sh` pass on the final candidate.
  Commit: `FUTURE-PARITY-BACKLOG.19.5.1 - implement Julia write vivification`

- ID: `FUTURE-PARITY-BACKLOG.19.5.2`
  Status: `canonical-signoff-complete` (activated and completed 2026-09-03 from exact clean Julia nested-write
    commit `5b3d7adc0cce9bc862b9b3aa00cbbce924dbf916`; no push)
  Goal: Implement Julia `map_leaves!` through typed parsed/emitted state and runtime.
  Dependencies: `.19.5.1`
  Verification tier: `canonical` — this began as a focused private Julia implementation, but its mandatory
    complete `CHANGES.md` record crossed the bounded rollover threshold. The resulting immutable history member
    exhausts the prior finite collection/manifest route, so ADR `0100` and receipt-bound canonical proof are now
    required in this same leaf. Lua, portable capability, public examples, recurring cross-backend admission, and
    the push boundary remain owned by `.19.6-.9`.
  Focused checks: unchanged neutral checker and exact Julia projection of all 4 valid syntax, 14 invalid syntax,
    5 exclusions, 10 successes, 8 pre-commit failures, continuation/shadow/guard-release/nonbang/detachment proof,
    167 base mutations, and 592 nested-write compositions; parser, compiler, reconstructed compiled state,
    generated-plan, emitted-source, independently executed caller where supported, primary CLI, package, corpus,
    and storage dependents; formatting/static checks, Knowledge, task/index, bounded histories, memory, all nine
    doctrines, rendered mdBook, cross-backend no-drift, and whitespace.
  Canonical trigger: `mandatory bounded change-history rollover and exact finite capacity ADR 0100` — stage the
    complete candidate and run receipt-bound `bash tools/run_ci_local.sh`. `.19.7-.9` still retain portable/public
    admission and the later push boundary.
  Acceptance: Parse only `IDENTIFIER.map_leaves!() { ACTION_BLOCK }` as the dedicated typed
    `receiver_mutation_chain`, retaining receiver/call/callback/continuation structure and exact authored Unicode-
    scalar spans through contracts, reconstructed compiled state, generated plans, source emission, and an
    independent emitted-source caller where supported. Resolve one existing bare uniform-binding identity
    containing an harray or array; traverse a detached original-shape snapshot in sorted-key or index order;
    provide detached `value`, complete copied `path`, `depth`, and `key|index`; replace each leaf with the detached
    callback result without revisiting replacement aggregates; then commit the rebuilt binding once and return a
    detached updated root before an ordinary fluent continuation. Guard the resolved receiver identity during
    callbacks so direct, nested-write, nested-bang, helper-mediated, array-end, and binding-target pipeline writes
    fail before operand/segment/RHS evaluation with exact `receiver_mutation_reentrant`, while unrelated and
    distinct same-spelling shadow identities remain legal. Callback/re-entrant failure leaves the receiver
    unchanged and releases the guard; continuation failure keeps the prior commit. Preserve non-bang behavior and
    compose exactly with Julia `.19.5.1` nested writes; reject malformed typed carriers; do not admit Lua or
    portable/public capability.
  Ownership: `.19.5.2` owns Julia parser/compiler/runtime/carrier implementation, direct proof, Julia status/docs,
    parent `.19.5` closeout, and the mechanically required bounded change-history rollover plus its one exact
    finite route-capacity decision. It must not alter the frozen neutral/composition contracts, Perl/Rust/Dart/Lua
    behavior, public current examples, capability/facade/schema/MCP surfaces, recurring cross-backend admission,
    or push state.
  Checklist: [x] clean activation/task ownership [x] Knowledge/ADR and sibling-contract retrieval
    [x] Toolbox-first Julia owner inventory [x] exact RED through frozen neutral/composition contracts
    [x] typed parser/compiler/reconstructed/generated/emitted carrier [x] atomic identity-guarded runtime
    [x] base/composition/generated/CLI proof [x] focused dependent/no-drift proof
    [x] durable docs/Knowledge/live sync [x] exact staged canonical signoff [x] atomic commit/brief/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` was empty at
    `5b3d7adc0cce9bc862b9b3aa00cbbce924dbf916`; `git_message_brief.txt` was zero bytes; `.19.5.1` was committed with
    all nine doctrine hooks after exact staged canonical proof and its receipt was promoted to that HEAD; the
    prior canonical job was fully consumed; and no generated mdBook output or background job remained. The clean
    boundary permits this task-tree pivot; no implementation file changes precede this ownership record.
  Implementation evidence: the unchanged neutral checkers pass at 4/14/5 syntax, 10 successes, 8 pre-commit
    failures, 167 base mutations, 8 composed writes, 6 callbacks, one continuation, and 592 composition mutations.
    The exact zero-regex `Top:: -> Done` Julia control first returned generic parser-invocation failure. Julia now
    owns a dedicated typed receiver/mutation/callback/continuation carrier with authored Unicode-scalar spans,
    fail-closed compiled-state validation at compiler/runtime/generated-plan/source-emitter boundaries, stable
    binding identities across ordinary writes, fresh callback/function-shadow identities, original-shape copied
    traversal, one guarded commit, detached results, and post-commit ordinary continuation. The permanent focused
    suite passes 496/496 across every frozen syntax row plus all 10 success and 8 failure rows by stable ID, every direct/helper/array-end/pipeline
    pre-evaluation guard, nested-write composition, shadowing, non-bang isolation, malformed state, reconstructed
    state, native/generated-plan/emitted-module/primary-CLI routes, and the director-confirmed zero-regex parent
    semantics.
  Dependent finding: adding the 22nd Julia temporary-workspace owner passed the oracle's exact array comparison,
    but its success sentence still printed the hard-coded prior total 21. The same owned storage update now derives
    the displayed total from the checked array; no containment rule or external path changed.
  Rollover finding: the complete change record reached 465/512 lines and required the governed rollover. It creates
    immutable content-addressed segment `4986` from clean activation commit `5b3d7adc`, leaving the hot root at
    252/512 lines. The resulting 27-file collection and 26-line manifest exceed only the previous finite 26/25
    route; ADR `0100` owns the exact 27/26 capacity step with every byte and aggregate ceiling unchanged.
  Director review note: `ROADMAP.md` is the primary long-form/historical plan and `ROADMAP_V2.md` is its shorter
    execution-focused companion, as the latter's `Relationship to ROADMAP.md` section and ADR `0001` require.
    This slice preserves their lockstep contract. Mechanically deriving or retiring one would reduce duplication
    risk but is not authorized here and would require a separately activated task-tree owner and consumer audit.
  Validation finding: final review proved a caller-corrupted top-level typed node `kind` could suppress the
    validator's own kind-based dispatch. The validator now detects the receiver/mutation/continuation structure
    independently and requires the exact kind; all four compiler/runtime/generated-plan/emitter rejection routes
    cover both this corruption and an invalid receiver projection.
  No-regression finding: the initial early guard widened three-argument `substr` into the four-argument statement-
    mutation path and moved invalid-target `set` failure ahead of RHS evaluation. Final integration preserves the
    old ordinary semantics while still rejecting a valid active receiver before operand evaluation; a focused
    pure-discarded `substr` check locks the boundary.
  Signoff evidence: the focused 496-assertion suite, unchanged 167 base + 592 composition and 105 write mutation
    oracles, complete Julia package suite, primary CLI, corpus 105/105, and 22-owner / five-package-tree storage
    proof pass. The mdBook renders, both history-pressure checks pass after the exact rollover, Knowledge and task
    indexes regenerate, all nine doctrines and whitespace pass, and exact staged receipt-bound canonical CI passes
    on the final candidate. Generated book output is removed before commit.
  Verification: `canonical-signoff-complete`
  Commit: `FUTURE-PARITY-BACKLOG.19.5.2 - implement Julia map leaves mutation`

- ID: `FUTURE-PARITY-BACKLOG.19.6`
  Status: `pending`
  Goal: Implement the unchanged v1 contract on PUC Lua and LuaJIT through public compiled-state reconstruction.
  Children: `.19.6.1`, `.19.6.2`
  Dependencies: `.19.5`
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.19.6.1`
  Status: `pending`
  Goal: Implement Lua nested write-vivification through typed parsed/reconstructed state on both ABIs.
  Dependencies: `.19.5`
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.19.6.2`
  Status: `pending`
  Goal: Implement Lua `map_leaves!` through typed parsed/reconstructed state on both ABIs.
  Dependencies: `.19.6.1`
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.19.7`
  Status: `pending`
  Goal: Admit the portable surface and close public/capability/book/KM/cross-backend no-drift.
  Dependencies: `.19.2`, `.19.3`, `.19.4`, `.19.5`, `.19.6`
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.20`
  Status: `proposed`
  Goal: Add evidence-based Rust mutation testing as a targeted verification layer.
  Children: `.20.0`, `.20.1`, `.20.2`, `.20.3`, `.20.4`; detailed execution tree: `RUST-MUTATION-TESTING`
  Acceptance: The Rust workspace gains a measured mutation-testing policy that focuses hand-written semantic code,
    records justified exclusions, converts meaningful survivors into focused tests or documented equivalents,
    keeps all mutation execution outside per-commit/pre-commit/ordinary-local-CI gates, uses only explicit
    on-demand or milestone/admission campaigns, bounds resources and artifacts, and integrates a stable manual
    command rather than turning mutation score into an unexamined vanity metric.

- ID: `FUTURE-PARITY-BACKLOG.20.0`
  Status: `done`
  Goal: Audit and ratify targeted `cargo-mutants` use for the Rust backend before configuration or test changes.
  Dependencies: `.18.3`
  Acceptance: Check the Knowledge Map and current Rust/local-CI test architecture; confirm available tool/version;
    inventory candidate production files and mutations without executing the full mutation campaign; define scope,
    exclusions, baseline/survivor/timeout/unviable handling, resource/artifact safety, explicit campaign cadence
    cadence, and follow-on implementation/admission leaves in a detailed task tree; synchronize roadmap/index/live
    docs/mdBook/KM without changing Rust behavior or claiming a mutation score before measurement.
  Verification: **PASS 2026-07-15.** Knowledge Map and Rust workspace/test/local-CI audit found no prior mutation
    plan or config. Installed `cargo-mutants 27.0.0` list-only inventory reports 3,333 candidates across 19 files:
    core 1,217, runtime 2,116; largest files `engine.rs` 1,343, `expr.rs` 522, `parser.rs` 320. No mutant executed.
    ADR `0039` and `RUST-MUTATION-TESTING` prohibit all per-commit/pre-commit/ordinary-local-CI mutation runs,
    require explicit targeted or milestone/release campaigns, typed survivor/timeout/unviable dispositions,
    resource/artifact controls, and only the generator-backed Unicode table as the initial exclusion. Roadmap,
    index, live docs, mdBook, Knowledge Map, governance, and whitespace checks pass; no Rust code/test/CI behavior
    or mutation-score claim changes.
  Commit: `FUTURE-PARITY-BACKLOG.20.0 - plan targeted Rust mutation testing`

- ID: `FUTURE-PARITY-BACKLOG.21`
  Status: `proposed`
  Goal: Add backend-specific implementation companion books around the canonical neutral mdBook.
  Children: `.21.0`, `.21.1`; detailed execution tree: `BACKEND-COMPANION-BOOKS`
  Acceptance: The neutral mdBook remains the sole normative language/portable-behavior owner; independently
    buildable Perl/Rust/Dart/Julia/Lua companions document only user-relevant variant implementation, embedding,
    operation, performance, debugging, and limitation material; cross-links, canonical-owner metadata, and
    registered drift checks prevent five copied manuals.

- ID: `FUTURE-PARITY-BACKLOG.21.0`
  Status: `done`
  Goal: Adopt and dependency-order the companion-book architecture before scaffolding or migration.
  Dependencies: `.20.0`
  Acceptance: Record ADR `0040`, the detailed task tree, exact content boundary, five companion scope, risks,
    parity dependency, and one future inventory frontier across task/index/roadmaps/live/KM/mdBook; change no book
    layout or current content ownership.
  Verification: **PASS 2026-07-15.** ADR `0040` and `BACKEND-COMPANION-BOOKS` define one normative neutral book,
    five optional implementation companions, precise what-versus-how routing, shared-template/independent-build/
    canonical-owner/drift gates, and a read-only inventory first. `.21.1` remains dependency-gated until current
    backend parity completes. No scaffold, content move, runtime behavior, or capability changed.
  Commit: `FUTURE-PARITY-BACKLOG.21.0 - plan backend companion books`

- ID: `FUTURE-PARITY-BACKLOG.21.1`
  Status: `pending` / parity prerequisite satisfied
  Goal: Execute the detailed `BACKEND-COMPANION-BOOKS.1-.8` inventory/scaffold/population/closeout program.
  Dependencies: `.21.0`, complete current Perl/Rust/Dart/Julia/Lua parity (satisfied by
    `LUA-BACKEND-PARITY.8.4`; detailed inventory remains separately activatable)
  Acceptance: All five companions and the neutral book satisfy the detailed tree's build/navigation/ownership/
    no-duplication gates; ordinary portable readers never require a companion.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.22`
  Status: `done; canonical-signoff-complete` (2026-08-29; task-tree-first from exact clean pushed codegen-inspector
    closeout commit `65eb4aa46fcdec0ad50c6e0dfc048df70d7999ec`)
  Children: `.22.1`, `.22.2`; `.22.1` complete and `.22.2` pending
  Goal: Make immutable cross-contract status markers survive mutable task-index frontier rewrites by construction.
  Activation: `2026-08-29` from exact clean pushed commit
    `65eb4aa46fcdec0ad50c6e0dfc048df70d7999ec`; the committed canonical receipt matches HEAD, the worktree and
    brief are clean, and the Knowledge Map names this leaf as the structural owner of the then-retained MEMORY
    handoff.
  Verification tier: `canonical`
  Focused checks: exact checker-to-marker inventory; repeated-action plus every discovered dependent checker;
    active-row rewrite mutation proof; task-tree metadata/index, Knowledge Map, memory, document history, README
    routing, mdBook render/cleanup, doctrines, project-data storage, and diff hygiene.
  Canonical trigger: the leaf changes cross-contract governance/checker ownership and the canonical task index;
    ADR `0073` therefore requires an exact staged canonical receipt before commit and push.
  Acceptance: Inventory every contract checker that anchors an unrelated closed-state marker inside a mutable
    `docs/TASK_TREE.md` active-row summary; move or derive those markers through one stable governed status section
    without weakening current public claims; prove an active-row rewrite cannot erase repeated-action or another
    closed contract; update checker diagnostics, task-tree guidance, Knowledge Map, roadmaps, and mdBook together.
  Finding: `.10.2`, `.10.3.0`, `.10.3.2.0`, `.10.4.0.1`, and `.10.4.1` canonical runs independently lost the
    exact repeated-action closeout sentence when the same active row was refreshed. The existing checker prevents
    a bad commit, but the mutable anchor repeatedly burns a full canonical restart. A complete tracked-consumer
    census finds 8 affected families, 12 exact marker fragments, and 15 code/JSON consumers. Several facts already
    occupied an ad-hoc stable section, semantic-introspection markers survived only in later chronology, and the
    repeated-action checker separately required immutable next-owner history in overwrite-only `MEMORY.md`.
  Implementation evidence: `tools/check_task_tree_closed_capability_markers.py` governs one sentinel-delimited
    stable section after the active table, forbids its registered markers in the mutable active surface, exact-
    compares discovered consumers, and verifies every family marker remains in every declared consumer. Four
    mutations permit arbitrary `FUTURE-PARITY-BACKLOG` row replacement while rejecting repeated-action deletion,
    repeated-action relocation into that row, and independent callable deletion. The repeated-action checker now
    validates next owner `.10.1` only in immutable task-tree evidence, not current memory. The guard composes through
    the existing `TASK-TREE-METADATA` doctrine; no runtime, parser, compiler, `.spec`, format, or public API changes.
  Focused signoff evidence: the registry reports 8 families / 12 markers / 15 consumers / 4 mutations; all eight
    dependent contract checkers pass at their unchanged closed counts, and the project-data oracle accepts 34
    Python entrypoints with three Python and 15 shell temporary owners. Task partitions, Knowledge Map 913/7,767,
    memory, document history, README routing, repo-root portability, rendered 81-file mdBook inspection/cleanup,
    `git diff --check`, and all nine doctrines pass.
  Canonical signoff evidence: the exact staged candidate passes receipt-bound canonical local CI, including the
    strengthened task metadata doctrine, broad backend/contract dependents, and Phase 0; the resulting commit is
    the designated clean pre-push boundary.
  Checklist: [x] clean activation/task ownership [x] Knowledge/toolbox retrieval [x] complete checker/marker census
    [x] stable governed owner [x] active-row rewrite mutation proof [x] dependent focused proof
    [x] docs/Knowledge/memory/task/index lockstep [x] canonical signoff [x] atomic commit/brief/clean push.

  ### FUTURE-PARITY-BACKLOG.22 Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — `rg -n` consumer census plus repeated-action canonical history showed immutable
    marker and handoff assertions coupled to mutable `docs/TASK_TREE.md` frontier prose and bounded `MEMORY.md`.
  - [x] **ROOT CAUSE (WHY + WHERE)** — tool-backed inspection located 12 exact checker markers across 15 consumers;
    no location/census invariant guarded `docs/TASK_TREE.md`, and `tools/check_repeated_action_result_contract.py`
    read the immutable next owner from overwrite-only layer-A memory.
  - [x] **FIX** — add the stable sentinel section registry and four mutations to the existing task metadata doctrine;
    retain repeated-action next-owner proof only in its immutable task tree.
  - [x] **ADDRESSED (verified)** — focused registry and all eight dependent contract families pass at 8 families /
    12 markers / 15 consumers / 4 mutations; active-row replacement is PASS and all three destructive cases reject.
  - [x] **NO REGRESSION** — project-data storage, `bash scripts/check_doctrines.sh`, exact staged canonical CI,
    `git diff --check`, mdBook render/inspection, and clean generated-output cleanup pass.
  - [x] **LOCKSTEP** — task/index, roadmaps, doctrine architecture/registry, Toolbox, Knowledge Map, `MEMORY.md`,
    bounded histories/status, changes/notes, and sole-facing mdBook all describe the governed stable boundary.
  Verification: **PASS 2026-08-29.** The immutable status boundary is mechanically governed without changing any
    parser, compiler, runtime, `.spec`, serialized/generated format, backend capability, or public API behavior.
  Commit: `FUTURE-PARITY-BACKLOG.22 - govern stable task-index markers`

- ID: `FUTURE-PARITY-BACKLOG.22.1`
  Status: `done; canonical-signoff-complete` (2026-08-29; task-tree-first from exact clean pushed `.22` commit
    `b024ea3ee45b30938979cc280f78cee18b1746f7`)
  Goal: Repair and mechanically reject a completed clean handoff whose bounded resume pointer still claims that
    the completed leaf is staged, uncommitted, or awaiting commit/push.
  Depends on: `.22`
  Verification tier: `canonical`
  Focused checks: exact committed `MEMORY.md`/live-status reproduction; current memory-architecture and commit-
    pointer authorities; post-landing consistency mutations; task/index, Knowledge Map, bounded histories, README,
    doctrines, rendered mdBook if public continuity teaching moves, and `git diff --check`.
  Canonical trigger: this defect changes the mechanically enforced layer-A memory architecture and commit/handoff
    integrity boundary, so ADR `0073` requires an exact staged canonical receipt before commit and push.
  Acceptance: Correct the `.22` post-landing `MEMORY.md` and live-status fields from exact Git truth; extend the
    existing memory architecture owner so a task-tree leaf marked done cannot coexist with a same-leaf
    `in_flight_uncommitted` claim or a next action that still says to stage/commit/push that leaf; lock valid active-
    work and clean-handoff twins plus destructive mutations; synchronize task/index, Knowledge Map, continuity
    docs, and verification evidence without changing parser/compiler/runtime/public behavior. Queue the separately
    discovered global task-definition ambiguity for `.22.2` rather than widening this handoff leaf.
  Finding: The immediate clean pushed audit of `b024ea3e` found `MEMORY.md` still naming `.22` as the active staged
    canonical boundary, instructing the next session to commit/push it, and claiming its implemented candidate was
    uncommitted. Git, the task owner, `LIVE_ACHIEVEMENT_STATUS.md`, and the promoted canonical receipt all prove the
    leaf is already committed and pushed. Existing gates validate activation-commit ancestry and pointer shape but
    not post-landing semantic consistency.
  RED evidence: after the checker parser was calibrated against current task formatting, the unchanged pushed
    pointer failed exactly with `completed active_work_unit 'FUTURE-PARITY-BACKLOG.22' still describes pre-landing
    state`. The prior `.13.1` committed pointer independently carries the same staged/uncommitted/commit-push shape.
  Implementation evidence: `tools/check_memory_handoff_state.py` parses four required fields, resolves only the
    referenced current task statuses, requires the latest completion to be done, couples idle state to no in-flight
    work, and rejects pre-landing active text, nonempty in-flight work, or same-leaf landing actions after completion.
    Three active/completed/idle twins pass and six destructive mutations reject. It composes through `MEMORY-ARCH`,
    canonical required-file discovery, and repository-routed Python; storage advances 34→35 entrypoints with three
    Python and 15 shell temporary owners unchanged.
  Calibration finding: global discovery exposed conflicting `active`/`done` definitions of
    `RUST-FUNCTIONAL-PARITY.7` in one legacy unpartitioned task file. `.22.1` treats a referenced ambiguity as an
    error but does not widen into global metadata repair; queued `.22.2` owns census, correction, and prevention.
  Focused signoff evidence: the real repository and internal proof pass at four fields / three active-completed-idle
    cases / six rejected mutations; the composed memory architecture, 11 activation-boundary fixtures, task
    metadata, tool-storage census 35/3/15, Knowledge Map 914/7,772, both bounded histories, `git diff --check`,
    all nine doctrines, and the inspected 15,864-KiB sole-facing mdBook render pass. Generated book output is removed.
  Canonical signoff evidence: the exact staged candidate passes receipt-bound canonical local CI; the promoted
    receipt and clean pre-push boundary own the atomic commit/push proof without any post-receipt tracked edit.

  ### FUTURE-PARITY-BACKLOG.22.1 Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — exact committed `b024ea3e` Git/task/receipt truth contradicts its three pre-landing
    `MEMORY.md` operational fields; the checker produces the expected completed-active RED.
  - [x] **ROOT CAUSE (WHY + WHERE)** — `scripts/check_memory_architecture.sh` enforced size, ancestry, and layer
    presence but never compared operational fields with current task status, despite the existing `COMMIT.md` rule.
  - [x] **FIX** — add the four-field task-status checker, three valid twins, six rejection mutations, doctrine and
    canonical required-file composition, exact live-pointer repair, and project-data census update.
  - [x] **SEPARATE FINDING OWNED** — queue global duplicate task-definition audit `.22.2`; do not silently repair or
    widen `.22.1` around the conflicting legacy `RUST-FUNCTIONAL-PARITY.7` definitions.
  - [x] **ADDRESSED / NO REGRESSION** — focused checker/memory/pointer/task/storage/Knowledge/history/doctrine/book
    proof and exact staged canonical CI pass.
  - [x] **LOCKSTEP / HANDOFF** — task/index, roadmaps, architecture, workflow, Toolbox, Knowledge, bounded live docs,
    changes/notes, and sole-facing mdBook agree; atomic commit/push is clean and `.22.2` is the next action.
  Verification: **PASS 2026-08-29.** The layer-A pointer is task-status-consistent without changing parser,
    compiler, runtime, `.spec`, serialized/generated format, backend capability, or public API behavior.
  Commit: `FUTURE-PARITY-BACKLOG.22.1 - enforce clean memory handoffs`

- ID: `FUTURE-PARITY-BACKLOG.22.2`
  Status: `done; canonical-signoff-complete` (2026-08-30; task-tree-first from exact clean pushed clean-handoff commit
    `e6cf4ba1b2bd84fc15edfd2d888c9c1a8c2a59d1`)
  Goal: Audit and mechanically enforce unique current task definitions across partitioned and unpartitioned task
    files after `.22.1` exposed a conflicting legacy duplicate outside the partition checker.
  Depends on: `.22.1`
  Acceptance: Use the current task metadata tools to census every exact `- ID:` definition; root-cause and repair
    the two conflicting `RUST-FUNCTIONAL-PARITY.7` statuses without rewriting genuine history; extend the owning
    metadata doctrine so future duplicate current definitions fail regardless of task storage form; synchronize
    task/index, Knowledge Map, continuity docs, and focused/canonical evidence before resuming `.23.1`.
  Activation finding: `docs/tasks/RUST-FUNCTIONAL-PARITY.md` defined `RUST-FUNCTIONAL-PARITY.7` twice, first as
    `active` and then as `done`. `scripts/check_task_tree_partitions.pl` proves unique IDs only inside the
    partitioned `FUTURE-PARITY-BACKLOG` collection, so the broader task metadata doctrine remains green.
  Verification tier: `canonical` — this leaf changes the repository-wide TASK-TREE-METADATA doctrine, its current
    task census, mutation proof, canonical registry wiring, and continuity surfaces.
  Focused checks: exact all-current-task definition/status census; duplicate-ID RED and repaired GREEN; partitioned
    FUTURE compatibility; adversarial duplicate mutations across partitioned and unpartitioned storage; task/index,
    memory, Knowledge Map, bounded histories, doctrines, rendered mdBook, whitespace, and exact staged diff.
  Canonical trigger: this leaf changes the repository-wide `TASK-TREE-METADATA` doctrine and canonical CI behavior,
    so ADR `0073` requires an exact staged canonical receipt before commit and push.
  Checklist: [x] clean activation/task ownership [x] Knowledge/decision retrieval [x] all-task census and root cause
    [x] conflicting legacy definition repair without history rewrite [x] repository-wide uniqueness enforcement
    [x] adversarial mutation proof [x] durable docs/memory/task/index synchronization [x] canonical signoff
    [x] atomic commit/brief/clean handoff.
  Activation evidence: exact `git status --short --untracked-files=all` is empty at pushed
    `e6cf4ba1b2bd84fc15edfd2d888c9c1a8c2a59d1`; HEAD equals upstream, `git_message_brief.txt` is zero bytes, the
    committed canonical receipt matches HEAD, no generated mdBook output remains, and `.22.1` is committed complete.
  Retrieval/root-cause evidence: [[task-tree-metadata-gate-boundary]], [[future-parity-task-partition-contract]],
    ADRs `0001`/`0068`, and exact current metadata tooling establish the intended boundary before editing. The first
    all-current census reports 1,719 definitions / 1,718 unique IDs and only
    `RUST-FUNCTIONAL-PARITY.7` duplicated at lines 182/187. `git log -S` and `git show` identify `0e43f4ae` as the
    finalization commit that inserted a second `done` parent block instead of changing the existing `active` block.
  Checker-first and repair evidence: `scripts/check_task_tree_current_ids.pl` first fails exactly on the two source
    locations while the pre-existing composed metadata doctrine remains green. The repair changes the original
    `active`/inserted `done` pair into one authoritative `done` parent at the same container position; genuine
    historical evidence remains in Git. The checker then passes 1,718 definitions / 1,718 unique IDs across 96
    current files while excluding one tracked-index-registered immutable history file.
  Enforcement evidence: `scripts/check_task_tree_metadata.sh` composes the global current-ID checker after exact
    partition validation. History exclusions are derived only from tracked JSONL indexes whose matching part is
    explicitly immutable; unregistered history-named files remain current. Ten in-memory mutations cover unique
    definitions, same-file duplicates, cross-unpartitioned duplicates, partitioned/unpartitioned duplicates,
    multiple duplicates, exact-line recognition, safe registered-history paths, closed-index-registry drift,
    registered exclusion, and unregistered-history inclusion.
  Focused and lockstep evidence: Perl syntax, the standalone current-ID checker, composed task metadata, all nine
    doctrines, Knowledge Map, task/index consistency, both bounded-history pressure checks, `git diff --check`, and
    the rendered sole-facing mdBook pass. `DOCTRINE_ENFORCEMENT.md`, task-tree guidance, Toolbox, both roadmaps,
    architecture, Knowledge, bounded continuity, memory, and public development/status teaching agree. No parser,
    compiler, runtime, `.spec`, fixture, serialized/generated format, backend capability, or public API byte moves.
  Canonical completion and handoff evidence: the exact fully staged candidate clears receipt-bound
    `bash tools/run_ci_local.sh`; pre-commit revalidates that receipt and the fast doctrines. Intended atomic subject:
    `FUTURE-PARITY-BACKLOG.22.2 - enforce unique current task ids`; clear the brief after commit, verify the promoted
    receipt and clean pushed handoff, then activate mdBook contrast repair `.23.1` task-tree-first.

  ### FUTURE-PARITY-BACKLOG.22.2 Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — `perl scripts/check_task_tree_current_ids.pl` produces the exact two-location RED
    after the pre-existing task metadata doctrine had accepted the conflicting current definitions.
  - [x] **ROOT CAUSE (WHY + WHERE)** — `git show 0e43f4ae -- docs/tasks/RUST-FUNCTIONAL-PARITY.md` proves the
    finalization patch inserted a second `.7` block at the container boundary instead of updating the original.
  - [x] **FIX** — collapse the adjacent `.7` pair into one authoritative `done` parent at the same container
    position and compose one all-current-ID checker through the existing task metadata doctrine.
  - [x] **ADDRESSED (verified)** — the repository passes at 1,718 definitions / 1,718 unique current IDs across 96
    files, with one registered immutable history file excluded and all ten mutations green.
  - [x] **NO REGRESSION** — partition proof remains 596/596 stable IDs; task status/evidence and all 8 marker
    families / 12 markers / 15 consumers remain green; no product, fixture, format, capability, or API byte moves.
  - [x] **LOCKSTEP** — task/index, Knowledge, doctrine catalog, Toolbox, task guide, roadmaps, architecture, bounded
    live docs, memory, and sole-facing mdBook agree; exact staged canonical CI owns the clean commit/push handoff.
  Verification: **PASS 2026-08-30.** Repository-wide current task-ID uniqueness is mechanically enforced without
    changing LinkedSpec parser, compiler, runtime, `.spec`, generated format, backend, capability, or public API behavior.
  Commit: `FUTURE-PARITY-BACKLOG.22.2 - enforce unique current task ids`

- ID: `FUTURE-PARITY-BACKLOG.23`
  Status: `done; canonical-signoff-complete`
  Goal: Repair and mechanically guard mdBook current-state drift exposed by a complete startup review.
  Children: `.23.1`, `.23.2`
  Acceptance: Root-cause every recorded current-facing contradiction against executable contracts and git history;
    repair only under dependency-correct leaves; strengthen the owning no-drift checks so semantic meaning, not
    merely anchor/count presence, is enforced; preserve genuinely dated history; synchronize book/KM/live docs;
    pass focused and canonical gates before closure.
  Finding: The 2026-07-21 full 46-page startup review found two distinct drift classes. Commit `ac217f6c`
    mechanically removed aggregate-selector spellings from the migration examples themselves, yielding meaningless
    identity rewrites such as ``items` becomes `items``; `check_public_aggregate_selector_surface.py` validates
    classified-occurrence counts and bare-binding anchors but does not require an old-selector-to-new-binding
    contrast. Separately, current-facing pages retain superseded rollout statements, including semantic
    introspection at 50 mutations/no backend, bare-edge rollout as Perl-only, logical-helper rollout as pending,
    and formal-grammar backend/marker status that contradicts admitted current contracts. At discovery this task
    was queued only: active Rust `.10.4.2` remained the dirty-tree frontier, so no pivot was authorized before its
    clean commit.
  Verification: **PASS 2026-08-30.** `.23.1` restores semantic migration contrasts; `.23.2` reconciles the
    remaining current rollout/backend claims, extends their exact no-drift owners, preserves dated history, passes
    complete book/doctrine/canonical proof, and closes the two-child parent without executable behavior movement.
  Commit: `FUTURE-PARITY-BACKLOG.23.2 - reconcile mdBook current status`

- ID: `FUTURE-PARITY-BACKLOG.23.1`
  Status: `done; focused-signoff-complete` (2026-08-30; task-tree-first from exact clean pushed current-ID uniqueness commit
    `be36e3dbda8e13b6aaa968735b2ac1ff04ed0be2`)
  Goal: Restore meaningful aggregate-selector migration examples and guard their semantic contrast.
  Depends on: `.23`
  Acceptance: Inventory every mechanically collapsed old-to-new selector example, restore exact rejected
    `array(IDENTIFIER)` / `hash(IDENTIFIER)` source only in explicit migration context, and extend the public
    checker with exact contrast mutations so another broad replacement cannot produce identity guidance while
    retaining the expected file/reference counts.
  Verification tier: `focused` — this leaf repairs one already-rejected public migration teaching surface and its
    direct no-drift checker; `.23.2` retains the broader current-status audit, parent closeout, and canonical boundary.
  Focused checks: Knowledge Map and history retrieval; exact current example census and `ac217f6c` provenance;
    checker RED mutations for lost old-selector/new-binding contrast; checker positive path; documentation-history,
    README-routing, Knowledge Map, task/index, memory, all doctrines, mdBook build/render review, and whitespace.
  Canonical trigger: `none` — escalate only if the repair changes executable parser/compiler/runtime behavior,
    capability admission, shared infrastructure, or mandatory bounded-history capacity; otherwise `.23.2` owns the
    designated exact staged canonical closeout.
  Ownership: `.23.1` owns aggregate-selector migration examples and semantic-contrast governance only. `.23.2`
    exclusively owns semantic-introspection, bare-edge, logical-helper/truthiness, structured-control, and root-
    marker current-status reconciliation plus parent closure.

  ### FUTURE-PARITY-BACKLOG.23.1 Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate from exact clean pushed `be36e3db`, zero-byte brief,
    matching local/upstream HEAD, valid canonical receipt, no rendered-book output, and no background job.
  - [x] **RETRIEVE / REPRODUCE** — Use Knowledge Map and indexed history before code archaeology; inventory every
    collapsed migration contrast and reproduce why the current checker accepts identity guidance.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Prove the mechanical replacement and checker blind spot from exact source,
    history, and mutation evidence; distinguish explicit rejected-syntax teaching from executable positive examples.
  - [x] **FIX / GUARD** — Restore every intended old-selector-to-bare-binding contrast and make exact mutations fail
    if old syntax, replacement syntax, pairing, classification, or expected public counts drift.
  - [x] **NO REGRESSION / LOCKSTEP** — Pass focused checker/docs/book/doctrine proof; synchronize task/index,
    Knowledge, bounded live docs, memory, and sole-facing mdBook without changing executable product behavior.
  - [x] **COMMIT / CLEAN HANDOFF** — Commit with the leaf id, clear the brief, verify the exact receipt requirement,
    leave the repository clean, and hand `.23.2` the next frontier without pushing before its canonical closeout.

  Activation evidence: exact `git status --short --untracked-files=all` was empty at pushed
  `be36e3dbda8e13b6aaa968735b2ac1ff04ed0be2`; local and upstream HEAD matched, `git_message_brief.txt` was zero
  bytes, the committed canonical receipt matched, and no rendered book or background job remained. Parent `.23`
  and `.23.1` were activated before implementation; the mutable partition index was refreshed immediately.

  Audit/RED evidence: [[mdbook-mechanical-migration-contrast-drift]] was retrieved before code inspection, and
  indexed live-history query preserved the earlier aggregate-selector census. Exact `git show`/parent-source
  evidence assigns the collapse to `ac217f6c`: only one explicit migration section lost seven historical forms,
  while the commit's other replacements correctly migrated current examples. The unchanged public checker then
  passed the broken section at 61 files / 25 classified references / zero current examples, proving its count-and-
  context model could not express semantic contrast.

  Implementation evidence: the mdBook again shows exact rejected `set(array(items), ...)` /
  `set(hash(meta), ...)` source and five ordered selector-to-bare mappings. The checker bounds that section by
  unique anchors, exact-compares the rejected block and ordered pair tuple, requires distinct sides with a removed
  selector only on the old side, and runs eleven collapse/omission/wrong-replacement/reorder mutations. Negative
  fixture strings are constructed from split tokens so the unchanged executable-source scanner sees no positive
  `.spec` source. The composed checker passes at public 61/32/0, executable 0/20, five-backend rejection, and
  capability 90/0/0.

  Focused signoff evidence: public selector proof, task metadata 596 stable IDs plus 1,718/1,718 globally unique
  current IDs, Knowledge Map 915/7,778, memory architecture, both bounded-history controls, and whitespace pass.
  The complete mdBook builds; rendered HTML inspection confirms both rejected examples, all five mappings, the
  project-status section, and normal navigation/content markup before generated output removal. The first doctrine
  run correctly rejected a redundant three-line CI-page addition at 2,051/2,048 lines; removing that duplicated
  teaching restores the exact 2,048-line pressure boundary, after which all nine doctrines pass. No canonical
  trigger is present under ADR `0073`; `.23.2` retains the designated parent-closeout boundary.
  Verification: **PASS 2026-08-30.** Documentation semantics and no-drift governance change; executable product,
  fixture, format, capability, and API bytes remain unchanged.
  Commit: `FUTURE-PARITY-BACKLOG.23.1 - restore selector migration contrasts`

- ID: `FUTURE-PARITY-BACKLOG.23.2`
  Status: `done; canonical-signoff-complete` (2026-08-30; task-tree-first from exact clean focused migration-contrast commit
    `e0ec59a04ed56b07e79863d8ea75913e951077bd`; batch intentionally not yet pushed)
  Goal: Reconcile remaining current-facing mdBook rollout and backend-status claims with executable contracts.
  Depends on: `.23.1`
  Acceptance: Audit the startup finding set plus adjacent prose; correct semantic-introspection, bare-edge,
    logical-helper/truthiness, structured-control, and root-marker current status from their canonical contracts;
    distinguish dated history from current guidance; add omission/stale-claim checks at the owning gates; build and
    review the complete book before closing `.23`.
  Verification tier: `canonical` — this leaf changes multiple current public projections and their no-drift gates,
    closes parent `.23`, and owns the accumulated batch push boundary.
  Focused checks: Knowledge Map and indexed history retrieval before source inspection; exact stale-claim census;
    canonical contract/checker and runtime/toolbox evidence for every claim; mutation RED/GREEN at the narrow owning
    gates; complete public checker set, task/index, Knowledge, bounded histories, memory, all doctrines, mdBook
    build/render review, whitespace, and no executable behavior movement.
  Canonical trigger: `public current-state reconciliation + parent closeout + batch push boundary` — the exact
    staged candidate must pass receipt-bound canonical local CI before commit; the clean committed HEAD then passes
    pre-push receipt reuse before the accumulated `.23.1-.2` batch is pushed.
  Ownership: `.23.2` owns only the recorded semantic-introspection, bare-edge, logical-helper/truthiness,
    structured-control, and root-marker current-facing claims plus their omission/stale-claim governance. Any newly
    discovered executable defect requires its own task owner rather than being hidden as prose correction.

  ### FUTURE-PARITY-BACKLOG.23.2 Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate from exact clean `e0ec59a0`, zero-byte brief, no rendered
    book/background job, and intentional unpushed `.23.1` batch state before any non-task edit.
  - [x] **RETRIEVE / COMPLETE CENSUS** — Use Knowledge Map and indexed history before archaeology; enumerate every
    startup finding and adjacent current-facing statement, separating current guidance from dated milestone history.
  - [x] **ROOT CAUSE / CURRENT AUTHORITY** — For each claim, identify the exact stale-producing edit plus canonical
    executable contract, task/decision owner, checker gap, and current backend/rollout truth.
  - [x] **FIX / GOVERN** — Correct only current-facing prose and add narrow omission/stale-claim mutations at the
    owning checker(s) so the same contradiction cannot recur while dated history remains intact.
  - [x] **NO REGRESSION / LOCKSTEP** — Prove all affected public and executable contracts, full book render,
    task/index, Knowledge, roadmaps, bounded live docs, memory, histories, doctrines, and whitespace with no hidden
    parser/compiler/runtime/fixture/format/capability/API movement.
  - [x] **CANONICAL CLOSEOUT / COMMIT / PUSH** — Close `.23`, pass exact staged canonical CI, commit with the leaf id,
    clear the brief, verify clean receipt-bound HEAD, push the accumulated `.23.1-.2` batch, and name the next PNT
    frontier from durable state.

  Activation/retrieval evidence: exact clean `e0ec59a04ed56b07e79863d8ea75913e951077bd`, zero-byte brief,
  intentional unpushed `.23.1`, no rendered book, and no background job preceded task-tree/index activation.
  Knowledge cards and indexed live-history queries were read before code/history archaeology for all recorded
  families. Exact source/Git inspection separated current claims from dated milestones and assigned each stale
  paragraph to the closeout that had not expanded its owning public projection.

  Root-cause/current-authority evidence: semantic introspection is 9/9/128 with six runtime admissions; cursor and
  bare edges are 8/0/60 across five backends; standalone lifecycle shorthand is current on five backends/six
  routes; logical helpers/truthiness are 8/0/26; attached/inline structured controls are current on all five
  backends; and root selection is 7/0/54 with explicit selector > first `Rule::` > first ordinary `Rule:`. Named
  slots and inter-match gaps are current through six routes while guarded outward schemas remain absent. Typed
  `.14.8` is complete at 14/0/231. README routing, not behavior drift, explains the root 25/19→24/17 transition;
  one newly denied formal-grammar claim makes the live inventory 24/18 while dated 25/19 evidence remains intact.

  Implementation/governance evidence: current book prose now teaches those exact boundaries. Cursor governance is
  30 documents / 28 denials / 60 mutations; standalone lifecycle is 15 / 7 / 14; semantic remains 128 while the
  exact former 50/no-backend sentence is denied; logical is 19 / 14 / 26; root is 24 / 18 / 54; gap is
  8 documents / 15 denials / 10 outward guards / 34 public mutations; its typed mirror is identical; typed public
  governance remains 8/8/6/10 and 14/0/231; capability conformance adds four structured-control omission/stale
  mutations bound to the all-pass `language.current_mdbook_surface` row. No parser/compiler/runtime/fixture/
  generated-format/capability-state/facade/schema/semantic/MCP/CLI/public-API behavior moves.

  Verification evidence: all eight focused checkers pass together; exact stale-claim census is empty; Knowledge
  Map remains 915 facts / 7,778 question keys; task/index, bounded histories, memory, whitespace, and all nine
  doctrines pass. The first doctrine run caught a duplicate typed-rollout card note at 65,913/65,536 bytes; routing
  that note to its existing composition card restores the rollout card to its exact 65,530-byte boundary and leaves
  its next edit split/reroute-required. The complete mdBook builds twice. Because in-app browser control was
  unavailable, generated HTML was directly inspected for corrected headings, paragraphs, tables, examples,
  navigation, and stale-claim absence before safe output removal. Exact fully staged canonical local CI and
  receipt-bound commit/push reuse pass at the designated public/batch boundary.
  Verification: **PASS 2026-08-30.** Documentation semantics and executable no-drift governance change; executable
    product, fixtures, generated formats, capability states, and outward APIs remain unchanged.
  Commit: `FUTURE-PARITY-BACKLOG.23.2 - reconcile mdBook current status`

- ID: `FUTURE-PARITY-BACKLOG.24`
  Status: `done`
  Goal: Make capability `excluded_or_future` narratives status-fresh and mechanically governed.
  Children: `.24.0`, `.24.0.1`, `.24.0.2`, `.24.1`, `.24.2`
  Dependencies: `.11.7.2`
  Acceptance: Audit every exclusion against its current task/decision/rollout authority; distinguish retained
    legacy exclusions from genuinely pending directions; remove or correct satisfied future narratives; make the
    capability checker reject a closed owner with stale pending prose and omission/duplication/status mutations;
    synchronize capability docs, Knowledge Map, roadmaps, and mdBook without changing capability rows or behavior.
  Finding: While `.11.7.1` corrected `future.generic_final_codeblock`, the same manifest still described semantic
    introspection/MCP as parked under completed `.10.1` and rule-local cursor rollout as 5 complete / 3 pending
    under completed `.9.1.2`, despite their committed complete/public states. `check_capability_conformance.pl`
    validates only record fields, unique ids, and tracked owner existence, so the 80/0/0 census can coexist with
    stale exclusion narratives. This queued owner does not widen or block the active callable leaf.

- ID: `FUTURE-PARITY-BACKLOG.24.0`
  Status: `done`
  Goal: Freeze the exact exclusion-freshness model and RED mutation plan before changing governance.
  Children: `.24.0.1`, `.24.0.2`
  Dependencies: `.11.7.2`
  Acceptance: Classify every current exclusion as retained legacy or pending future from canonical decisions/tasks;
    reproduce each stale claim; define allowed owner states, supersession/removal rules, and exact mutations without
    changing manifest status or production behavior.
  Verification: **PASS 2026-08-01.** Exact four-record authority audit and 24-mutation schema-v2 model are
    behavior-free; capability remains 80/0/0; Knowledge Map 783/6,343, sole-facing mdBook 79/14,056 KiB, all
    seven doctrines, and canonical RAM 52% plus Phase 0 1,031/1,031 in 651 seconds pass.
  Commit: `FUTURE-PARITY-BACKLOG.24.0 - freeze exclusion freshness model`

### `FUTURE-PARITY-BACKLOG.24.0` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate task-tree-first from clean callable-admission commit
  `47b40c7a` (125/300), with a zero-byte brief and no rendered-book, bytecode, managed-run, or stray-log residue.
- [x] **RETRIEVE CANONICAL AUTHORITIES** — Read the Knowledge Map pointers, every exclusion owner and governing
  decision/task, the manifest checker, capability docs, roadmaps, and sole-facing mdBook projections before
  classifying status or designing mutations.
- [x] **FREEZE THE COMPLETE EXCLUSION CENSUS** — Account for every current exclusion exactly once, distinguishing
  retained compatibility/legacy records, live future directions, and satisfied/stale narratives with evidence.
- [x] **DEFINE STATUS / SUPERSESSION RULES** — Specify allowed owner states and the exact retain, rewrite, remove,
  or supersede rule without assuming that every completed owner makes a legacy exclusion invalid.
- [x] **FREEZE RED MUTATIONS AND ORDERED HANDOFF** — Record omission, duplication, owner/status, satisfied-claim,
  and false-current/future mutations that `.24.1` must reject; route the two audit-discovered prior-closeout
  defects through `.24.0.1-.2`, then keep `.24.2` as the public no-drift closeout.
- [x] **LOCKSTEP / NO BEHAVIOR / COMMIT / CLEAN HANDOFF** — Synchronize task-tree, continuity, roadmap, Knowledge
  Map, and mdBook planning truth; change no manifest row, checker behavior, runtime, capability status, or public
  contract; pass focused governance/docs/canonical gates, commit `.24.0`, clear the brief, and prove clean before
  `.24.1` activation.

Activation evidence 2026-08-01: `.11.8.4` landed at `47b40c7a` with all hooks green. Git status was empty,
`git_message_brief.txt` was zero bytes, and rendered-book/Python-bytecode residue was absent. The empty managed
run namespace remains the stable repository-local allocator parent; zero Rust logs were found, while 606 normal
incremental `.bin` records remain retained reusable SSD cache. This leaf owns only the exclusion census,
authority classification, status/supersession model, and RED mutation plan. Manifest/checker behavior, capability
rows, parser/compiler/runtime/emitter/MCP behavior, root README, push, and `.24.1` implementation are excluded.

Audit/model evidence 2026-08-01: the exact four-record census is now classified from canonical authority.
`legacy.perl_plugin_registry` remains a deprecated Perl-only compatibility exclusion under pending `.6`.
`future.general_parse_job_authoring` remains genuinely future, but its broad `.2` owner was superseded by the
structural/progressive/staged program: closed `STAGED-LINKED-PARSING` transfers it to `.14`, and ADR `0056` refines
progressive/staged work into `.14.6-.7`. `.24.0.1` repairs `.2`'s two cross-slice corruptions and records the
supersession; `.24.1` re-owners the manifest record to active parent `.14`. Semantic/MCP is complete under `.10`
at public rollout 9/9, native admission 6/6, and MCP 5/5 implementations + 6/6 runtimes; rule-local cursor is
complete under `.9` at 8/0 with six-runtime recurrence. Both satisfied future records must be removed. Capability
rows remain 80/0/0.

Frozen governance model 2026-08-01: `.24.1` advances the manifest to schema v2 and adds exact exclusion fields
`disposition` (`legacy`/`future`) plus nullable `retention_authority`. Future owners may be proposed, pending, or
active and never use retention authority. Open legacy owners use no retention authority; a completed legacy owner
is accepted only with an existing repository-relative durable retention authority. Exact current objects/order are
the unchanged plugin legacy record and a rewritten general parse-job future record owned by `.14`; all satisfied
ids are denied. The checker parses unique task ids plus their leading status enum, removes redundant hard-coded
owner insertions, and runs 24 in-memory RED mutations: schema downgrade; missing/unknown disposition; both
id/disposition mismatches; future/open-legacy retention misuse; completed legacy without retention; completed
future even with retention; missing task/status, duplicate id, invalid status; extra/omitted/duplicated/reordered
records; both reason drifts; both owner drifts; and reintroduction of each satisfied semantic/cursor record. No
temporary workspace is required.

Signoff evidence 2026-08-01: focused capability conformance remains exactly 16 capabilities and 80/0/0; the
Knowledge Map passes at 783 facts / 6,343 question keys; the sole-facing mdBook builds 79 files / 14,056 KiB; and
memory, task-tree metadata, whitespace, plus all seven doctrines pass. The definitive authorized canonical gate
passes semantic/MCP admissions, repository containment and moved-root/outside-CWD execution, callable governance
at 25 documents, CLI 66x2, RAM 52%, and Phase 0 1,031/1,031 in 651 seconds before `local CI gate passed`. The diff
changes no manifest/checker behavior, capability row, parser/compiler/runtime/emitter/MCP behavior, root README,
or public language contract. Commit and exact clean-boundary proof are the only remaining workflow actions.

- ID: `FUTURE-PARITY-BACKLOG.24.0.1`
  Status: `done`
  Goal: Repair the broad `.2` owner's cross-slice provenance corruption and reconcile its supersession by `.14`.
  Dependencies: `.24.0`
  Acceptance: Use Git blame/diffs to preserve the exact two introducing commits; replace `.2`'s unrelated
    verification/commit fields with truthful supersession by `.14`/`.14.6-.7`; reconcile the stale `.14.1-.4`
    closed-tree reference, both current Knowledge-card `.14.2-.4` references, and `.2`'s stale pending frontier
    row; add the narrowest durable
    metadata guard that rejects the proven pending-node contamination without invalidating legitimate parent/
    historical records; synchronize task/KM/live evidence; change no manifest, capability, parser/runtime, MCP,
    or public language behavior.
  Finding: Commit `e96d389e` accidentally wrote the completed `.9.1.7.4` commit identity into pending `.2`, and
    commit `7dd70a2d` accidentally wrote `.9.1.7.6` activation/admission detail into `.2` verification. Git history
    proves both were patch-context placement errors; `.2` goal/acceptance/status remained pending throughout.
  Finding: The exact current-reference census after RED proof found a third stale owner projection in current card
    `staged-linked-parsing-architecture`, introduced with structural clarification commit `96179766`; it joins the
    closed staged tree and current `structural-progressive-staged-authoring-doctrine` card in this repair. Dated
    2026-07-12 roadmap/live/change/development prose remains truthful history and is not rewritten.
  Finding: The same census found `.2`'s current-frontier row still pending from original commit `7083eb61`, despite
    the superseded node repair. It is the fourth current projection and must become superseded with the same exact
    replacement; broad active-tree frontier/body correspondence remains outside this leaf's low-noise guard.
  Verification: **PASS 2026-08-01.** Exact Git provenance, RED-before-repair metadata diagnostics, four repaired
    current projections, four checker fixtures, capability 80/0/0, Knowledge Map 783/6,345, sole-facing mdBook
    79/14,060 KiB, all seven doctrines, CLI 66x2, RAM 50%, and Phase 0 1,031/1,031 in 640 seconds pass.
  Commit: `FUTURE-PARITY-BACKLOG.24.0.1 - repair staged owner metadata`

### `FUTURE-PARITY-BACKLOG.24.0.1` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate task-tree-first from clean exclusion-model commit
  `7a5d0af3` (126/300), with zero-byte brief and no rendered-book, untracked, or in-flight process residue.
- [x] **RETRIEVE / REVERIFY EXACT PROVENANCE** — Use the Knowledge Map before Git blame/show and current task/
  decision authorities; preserve exact introducing commits, original `.2` metadata, current status enums, and the
  `.14`/`.14.6-.7` supersession chain before editing the corrupted node or a checker.
- [x] **RED-GUARD THE PROVEN CONTAMINATION CLASS** — Add the narrowest mutation-sensitive task-metadata denial
  that catches unrelated descendant commit/verification text in an open node without rejecting legitimate parent,
  historical, planned, or superseded records; prove RED before changing `.2`.
- [x] **REPAIR `.2` / RECONCILE SUPERSESSION** — Replace only the two cross-slice insertions with truthful
  no-implementation supersession evidence, use an allowed status, and update the two stale `.14.1-.4` /
  `.14.2-.4` forms plus the stale pending frontier row across all four current references to parent `.14` plus
  progressive `.14.6` and staged `.14.7` ownership; preserve dated historical claims.
- [x] **LOCKSTEP / NO BEHAVIOR / COMMIT / CLEAN HANDOFF** — Synchronize task-tree, Knowledge Map, roadmaps, live
  continuity, and sole-facing mdBook only where current architectural truth changes; preserve manifest/checker
  capability meaning, rows 80/0/0, parser/runtime/MCP/public language behavior, and root README; pass focused,
  doctrine, book, and warranted canonical gates, commit `.24.0.1`, clear the brief, and prove clean before `.24.0.2`.

Activation evidence 2026-08-01: `.24.0` landed at `7a5d0af3` with pre/post memory-boundary checks and all seven
doctrines green. Git status and both diffs were empty, `git_message_brief.txt` was zero bytes, rendered-book output
was absent, and no background result remained to consume. Existing `.linkedspec-data` Python bytecode and migrated
trace caches plus tracked PGEN issue logs are retained project-local authorities/caches, not disposable residue.
This leaf owns only exact task metadata, four stale current owner references, one narrow metadata guard, and their durable
projections. Manifest/exclusion implementation, capability rows, parser/compiler/runtime/emitter/MCP behavior,
root README, callable count repair `.24.0.2`, `.24.1`, push, and unrelated artifact deletion are excluded.

Provenance/RED evidence 2026-08-01: Knowledge Map retrieval led to the existing narrow doctrine boundary before
Git archaeology. Original commit `59cbf0be` created pending `.2` with both evidence fields `pending`; `e96d389e`
misplaced completed `.9.1.7.4` identity into its `Commit`, and `7dd70a2d` replaced its `Verification` with unrelated
`.9.1.7.6` activation/admission prose. Status vocabulary explicitly allows `superseded` with a named replacement.
A complete pending-node census showed seven legacy files with non-pending evidence but exactly one node claiming
task-tree-first activation and exactly one naming a foreign same-tree commit: `.2` in both cases. The first run of
the expanded checker therefore exited 1 with exactly those two diagnostics before any `.2` repair.

Repair/guard evidence 2026-08-01: `.2` now says `superseded`, names parent `.14` plus progressive `.14.6` and staged
`.14.7`, states no implementation/activation landed, and has no completion commit. Its current-frontier row, closed
staged-tree authority, and both current architecture cards agree; dated 2026-07-12 history remains unchanged. The
checker retains its completed-tree frontier rule and adds only pending activation/foreign-same-tree-commit denials.
Four in-memory fixtures prove ordinary pending and explicit supersession pass while each exact corruption fails.
Focused `bash -n`, checker/census/old-owner scans, capability 80/0/0, Knowledge Map 783/6,345, sole-facing mdBook
79/14,060 KiB, whitespace, and all seven doctrines pass; rendered output is removed. The definitive authorized
canonical gate passes all seven doctrines, semantic/MCP admissions, repository containment and moved-root/outside-
CWD execution, CLI 66x2, RAM 50%, and Phase 0 1,031/1,031 in 640 seconds before `local CI gate passed`.

### `FUTURE-PARITY-BACKLOG.24.0.1` TOOLBOX Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `git show`/`git blame` and `rg -n` prove two unrelated cursor insertions, four stale
  current node/frontier/authority projections, and the unchanged manifest owner reserved for `.24.1`.
- [x] **ROOT CAUSE (WHY + WHERE)** — WHY: broad patch context selected `.2`'s first evidence fields; WHERE:
  `docs/tasks/FUTURE-PARITY-BACKLOG.md:1428` plus introducing commits `e96d389e` and `7dd70a2d`; later ADR `0056`
  refined ownership without reconciling three other current projections.
- [x] **FIX** — Mark `.2` superseded without implementation, align four current projections to `.14`/`.14.6-.7`,
  and extend `scripts/check_task_tree_metadata.sh` with two narrow contradictions plus four in-memory fixtures.
- [x] **ADDRESSED (verified)** — Exact pre-repair checker exit 1 names both `.2` violations; post-repair checker,
  zero-result current stale-owner/census scans, Knowledge Map 783/6,345, and mdBook build 79/14,060 KiB pass.
- [x] **NO REGRESSION** — Focused capability 80/0/0, memory, all seven doctrines, book, and whitespace pass;
  canonical `bash tools/run_ci_local.sh` passes CLI 66x2, RAM 50%, and Phase 0 1,031/1,031 in 640 seconds.
- [x] **LOCKSTEP** — Task/index, doctrine registry/mirror/card, staged-architecture cards/tree, continuity, roadmaps,
  changes/development/live state, and sole-facing book must agree before commit and clean `.24.0.2` handoff.

- ID: `FUTURE-PARITY-BACKLOG.24.0.2`
  Status: `done`
  Goal: Repair and guard the sole-facing mdBook callable public-document count.
  Dependencies: `.24.0.1`
  Acceptance: Correct project status from 24 to the actual governed 25 public documents; make the callable
    checker require the exact current count there and reject the stale count; rebuild/review the complete book;
    preserve callable behavior, 22 existing governance mutations except for the explicit new count mutation,
    capability 80/0/0, and every backend/runtime route.
  Finding: `.11.8.4` added the helper catalog as document 25 and guarded the capability README count, but its new
    opening mdBook project-status paragraph was authored as 24. The page was inventoried without an exact count
    marker, so both the checker and rendered build passed while the user's sole-facing surface drifted.
  Verification: Exact neutral 7/11/9/7/4/8 plus all 23 mutations; five-backend/six-runtime callable driver;
    capability 80/0/0; Knowledge Map 783/6,345; sole-facing mdBook 79 files / 14,060 KiB with rendered exact-line
    inspection; memory/task/whitespace and all seven doctrines; canonical CLI 66x2, RAM 61%, Phase 0
    1,031/1,031 in 646 seconds, and `local CI gate passed`.
  Commit: `FUTURE-PARITY-BACKLOG.24.0.2 - guard callable book count`

### `FUTURE-PARITY-BACKLOG.24.0.2` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate task-tree-first from clean pending-owner repair commit
  `094ed840` (127/300), with zero-byte brief and no rendered-book, untracked, or background-process residue.
- [x] **RETRIEVE / REVERIFY EXACT PUBLIC INVENTORY** — Use the Knowledge Map and callable contract before source
  inspection; reverify the governed 25-document inventory, existing 22 mutations, the sole-facing 24 claim, and
  every current count projection without changing production behavior.
- [x] **RED-GUARD THE SOLE-FACING COUNT** — First prove the current checker accepts the stale book count, then add
  the smallest exact marker plus one mutation that rejects 24 or any non-25 current claim while preserving all 22
  existing topology/route/status/public mutations.
- [x] **REPAIR / RENDER / REVIEW THE COMPLETE BOOK** — Correct the sole-facing project-status count from 24 to 25,
  rebuild all 79 rendered files, inspect the affected output and surrounding current callable guidance, and remove
  generated output after measurement.
- [x] **LOCKSTEP / NO BEHAVIOR / COMMIT / CLEAN HANDOFF** — Synchronize task/index, Knowledge Map, roadmaps, live
  continuity, changes/development/architecture, and the mdBook; preserve callable/runtime/emitter/MCP/capability
  behavior and rows 80/0/0, root README, and `.24.1`; pass focused/doctrine/book/warranted canonical gates, commit,
  clear the brief, and prove clean before `.24.1`.

Activation evidence 2026-08-01: `.24.0.1` landed at `094ed840` after its pre/post activation-pointer checks and all
seven doctrines passed. Exact post-commit proof found empty status plus staged/unstaged diffs, a zero-byte brief,
no rendered book, synchronized Knowledge Map 783/6,345, and no background result. This leaf owns only the exact
sole-facing callable count, its narrow checker mutation, and lockstep projections. Callable implementation/routes,
the existing 22 mutations, capability rows/manifest semantics, parser/compiler/runtime/emitter/MCP behavior, root
README, `.24.1`, push, and unrelated artifact cleanup are excluded.

Reproduction/root-cause evidence 2026-08-01: Knowledge Map retrieval led directly to the callable-count drift and
five-backend admission cards. The contract contains exactly 25 documents and 12 stale-claim denials, while the
unchanged checker passes 7/11/9/7/4/8 plus all 22 governance mutations even though sole-facing project status says
24. `git blame` proves commit `47b40c7a` authored the stale paragraph and added only the generic five-backend marker
to the pre-existing project-status inventory entry; exact numeric text was never required or denied. The existing
22 mutation targets remain fixed. This leaf adds one project-status `25 public documents` marker, one path-scoped
stale-24 denial, and one explicit count-drift mutation, then repairs the book only after the checker is RED.

RED/GREEN evidence 2026-08-01: after the checker and JSON contract required project status to contain `25 public
documents`, denied path-scoped `24 public documents`, and appended `project_status_public_count_drift` after the
unchanged 22 mutations, the routed checker exited 1 with exact `callable_public_marker_missing` on the sole-facing
page. Changing only that page's current line to 25 documents and 23 total mutations made the same checker pass
7/11/9/7/4/8 plus all 23 governance mutations. The complete book then builds 79 files / 14,060 KiB; rendered
project status contains the exact corrected line, rendered local-CI guidance says 23 mutations and 25 documents,
and rendered project status contains no `24 public documents`. Exact generated output is removed after review.

Signoff evidence 2026-08-01: the rooted callable driver passes neutral 7/11/9/7/4/8+23, Perl 10, Rust 18, Dart
21, Julia 125+118+239, and the same Lua consumer at 449 assertions on PUC Lua and LuaJIT. Capability remains
80/0/0; Knowledge Map is 783/6,345; memory/task/whitespace and all seven doctrines pass. The definitive authorized
canonical gate proves semantic/MCP admissions, callable 25 documents/23 mutations, repository containment,
moved-root/outside-CWD execution, CLI 66x2, RAM 61%, and Phase 0 1,031/1,031 in 646 seconds before
`local CI gate passed`. No callable implementation, backend route, capability, parser/runtime/emitter/MCP, root
README, or push movement occurs.

### `FUTURE-PARITY-BACKLOG.24.0.2` TOOLBOX Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Show the governed inventory says 25 while the sole-facing book says 24 and the
  current checker still passes.
- [x] **ROOT CAUSE (WHY + WHERE)** — Identify the exact closeout patch and checker inventory/count boundary that
  allowed a listed public document's own numeric status claim to escape validation.
- [x] **FIX** — Make the book say 25 and make callable governance require that exact current marker.
- [x] **ADDRESSED (verified)** — Prove the corrected marker passes and the isolated stale-24 mutation fails.
- [x] **NO REGRESSION** — Preserve all existing 22 mutations, backend/runtime routes, capability 80/0/0, complete
  rendered book, all seven doctrines, and warranted canonical proof.
- [x] **LOCKSTEP** — Task/index, Knowledge Map, roadmaps, live docs, checker, capability guidance, and sole-facing
  book agree before commit and clean `.24.1` handoff.

- ID: `FUTURE-PARITY-BACKLOG.24.1`
  Status: `done`
  Goal: Correct stale exclusion records and enforce owner/status freshness in capability governance.
  Dependencies: `.24.0.2`
  Acceptance: Advance manifest governance to schema v2 with explicit legacy/future disposition and nullable
    durable retention authority; retain the exact plugin legacy record, rewrite/re-owner general parse-job work to
    active `.14`, remove satisfied semantic/cursor records, parse unique owner task states instead of existence
    alone, and reject the frozen 24 in-memory schema/status/retention/omission/duplication/order/reason/owner/
    satisfied-record mutations while preserving capability rows at 80/0/0.

### `FUTURE-PARITY-BACKLOG.24.1` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate task-tree-first from clean readability-intake commit
  `f1cd59d3` (129/300), with zero-byte brief and no rendered-book, untracked, or background-result residue.
- [x] **RETRIEVE / REVERIFY FROZEN MODEL** — Use the Knowledge Map, `.24.0` audit evidence, exact manifest,
  checker, task statuses, and retention authority before editing; confirm the two retained records and all 24
  frozen mutation classes still match current committed truth.
- [x] **RED SCHEMA / STATUS GOVERNANCE** — Make the checker reject schema v1, missing/unknown/mismatched
  disposition, invalid retention combinations, missing/duplicate/invalid owner status, completed future owners,
  record omission/duplication/reordering, reason/owner drift, and both satisfied-record resurrections before
  repairing the manifest.
- [x] **IMPLEMENT EXACT SCHEMA V2 STATE** — Retain only deprecated Perl plugin legacy under `.6` and general
  parse-job future work re-owned to active `.14`; add exact disposition/nullable retention fields; remove satisfied
  semantic/MCP and rule-local cursor narratives; preserve all 16 capability rows at 80/0/0.
- [x] **LOCKSTEP / NO BEHAVIOR** — Synchronize task/index, Knowledge Map, roadmaps, live docs, capability guidance,
  and sole-facing mdBook wherever current exclusion truth changes; reserve independent public no-drift/parent
  closure for `.24.2`; change no parser/compiler/runtime/emitter/MCP or root README behavior.
- [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass all 24 mutations, capability 80/0/0, focused task/memory/
  doctrine/book checks and warranted canonical proof; commit, clear the brief, and prove clean before `.24.2`.

Activation evidence 2026-08-01: callable-count repair landed clean at `5bc31609`; non-urgent rendered-readability
intake then landed clean at `f1cd59d3` without book or behavior changes. Exact post-commit proof found empty status
and both diffs, zero-byte brief, synchronized Knowledge Map 783/6,345, no rendered book, and no background result.
This leaf owns only the schema-v2 manifest/checker implementation and its lockstep current-truth projections.
Capability rows, parser/compiler/runtime/emitter/MCP behavior, root README, `.24.2` final public no-drift/parent
closure, push, and unrelated artifact cleanup are excluded.

Authority/root-cause evidence 2026-08-01: Knowledge Map retrieval led directly to the frozen four-record audit and
checker-gap cards. Current task truth remains exact: plugin owner `.6` is pending, broad `.2` is superseded,
replacement parent `.14` is active, and satisfied parents `.9`/`.10` are done. The original prose says 24
mutations but enumerates only 23 labels. Root cause is a bookkeeping omission, not a wrong total: schema v2
requires `retention_authority` to exist even when null, so `missing_retention_authority` is the omitted exact 24th
mutation. The implementation and Knowledge card make that class explicit rather than silently changing the total.

RED/GREEN evidence 2026-08-01: after syntax passed, the checker-first run against the unchanged manifest exited
255 with exact `schema_version must be 2`. The manifest then moved from schema 1/four narratives to schema 2/two
records: plugin legacy remains under pending `.6`, general parse-job future work moves from superseded `.2` to
active `.14`, and satisfied semantic/MCP plus cursor records are absent. The same checker passes exactly
`schema v2; 16 capabilities; backend states pass=80 partial=0 gap=0; 2 exclusions; 24 governance mutations`.
Task parsing derives unique ids and leading status enums from tracked sources; unrelated legacy status suffixes
remain readable, while every referenced owner must use the current status vocabulary.

Signoff evidence 2026-08-01: focused schema-v2 proof remains exact at 16 capabilities / 80 pass / 0 partial /
0 gap / two ordered exclusions / 24 governance mutations; the adjacent callable contract remains 23 mutations.
Knowledge Map passes 783/6,346, the sole-facing mdBook builds 79 files / 14,068 KiB with affected rendered pages
inspected, and all seven doctrines pass. The definitive canonical gate proves semantic/MCP admissions,
repository containment, moved-root/outside-CWD execution, CLI 66x2, RAM 52%, and Phase 0 1,031/1,031 in 660
seconds before `local CI gate passed`. No capability row or parser/compiler/runtime/emitter/MCP/root-README
behavior moves. Commit subject is `FUTURE-PARITY-BACKLOG.24.1 - enforce exclusion status freshness`; `.24.2`
follows only after brief clearing and exact clean proof.

- ID: `FUTURE-PARITY-BACKLOG.24.2`
  Status: `done`
  Goal: Close public no-drift for capability exclusion freshness.
  Dependencies: `.24.1`
  Acceptance: Capability README, Knowledge Map, roadmaps, mdBook, live status, manifest, tasks, and mutation proof
    agree on retained legacy versus active future work; focused/canonical gates pass and parent `.24` closes.

### `FUTURE-PARITY-BACKLOG.24.2` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate task-tree-first from clean `.24.1` commit `b576c646`
  (130/300; no push), with zero-byte brief and no rendered-book, bytecode, untracked, or background-result residue.
- [x] **RETRIEVE / RECOMPOSE COMMITTED AUTHORITY** — Use the Knowledge Map and committed `.24.0-.24.1` evidence
  before re-derivation; independently rerun schema-v2/two-record/24-mutation/80-0-0 proof from clean HEAD.
- [x] **AUDIT COMPLETE PUBLIC SURFACE** — Inventory capability guidance, Knowledge cards, roadmaps, mdBook, live
  status, manifest, tasks, and governed checker prose for exact retained-legacy/active-future/satisfied-absent truth;
  classify historical statements rather than rewriting history.
- [x] **RED / PUBLIC NO-DRIFT** — Prove the current checker accepts at least one stale, omitted, or contradictory
  public exclusion claim, then add the smallest mutation-sensitive public marker/denial boundary justified by the
  audit without duplicating the manifest's semantic authority.
- [x] **ALIGN / CLOSE** — Correct only audit-proven public drift, keep paragraphs readable in rendered HTML, align
  the Knowledge Map and all live projections, mark `.24` and `.24.2` done, and name the next clean PNT frontier.
- [x] **NO BEHAVIOR / VERIFY / COMMIT / CLEAN** — Preserve manifest rows 80/0/0 and schema-v2 semantics plus all
  parser/compiler/runtime/emitter/MCP behavior and root README; pass focused/public/doctrine/book/canonical gates,
  commit, clear the brief, and prove clean before any pivot.

Activation evidence 2026-08-01: `.24.1` landed at `b576c646` with all hooks green after exact schema-v2/two-record/
24-mutation, Knowledge Map 783/6,346, rendered book 79/14,068 KiB, all-doctrine, CLI 66x2, RAM 52%, and Phase 0
1,031/1,031 in 660-second signoff. Post-commit proof found empty status and staged/unstaged diffs, zero-byte brief,
synchronized Knowledge Map, no rendered book or Python bytecode, and no background result. This leaf owns only
independent public no-drift, exact current projection repair if proven, and parent `.24` closure. Manifest semantics,
capability rows, parser/compiler/runtime/emitter/MCP behavior, root README, rendered-readability audit, push, and
unrelated cleanup are excluded.

Recomposition/audit evidence 2026-08-01: committed HEAD independently passes exact schema v2 / 16 capabilities /
80-0-0 / two exclusions / 24 manifest mutations. The standard 59-file public Markdown inventory has six current
exclusion projections—capability README, both roadmaps, architecture state, and two mdBook pages—and no unclassified
stale semantic/MCP, cursor, or `.2`-owner claim. Six continuity/retrieval projections complete the governed set:
live achievement status, task index, this task tree, two canonical Knowledge cards, and derived `KNOWLEDGE_MAP.md`
(12 total).
Historical rollout/audit prose remains classified history; root README has no exclusion detail and remains bounded.
The existing capability checker governs only manifest/task semantics, so the smallest closeout extends that same
checker with an exact 12-projection marker/denial contract and in-memory public mutations—no new script, workflow,
allocator, schema, capability row, or runtime route.

RED evidence 2026-08-01: a transient sole-facing project-status contradiction changed the exact current marker
from `schema v2 with exactly two status-fresh records` to `schema v1 with four stale records`. The unchanged
checker still exited 0 with its exact schema-v2/80-0-0/two-exclusion/24-mutation line, proving that manifest truth
did not protect the book. The project-status text was immediately restored byte-for-byte; its working-tree diff is
empty. Checker-first implementation must now reject that marker drift before final closeout prose is repaired.

GREEN/closure evidence 2026-08-01: checker-first validation rejected the missing close marker before any public
repair. The existing checker now owns an exact ordered 12-projection contract across six current user-facing and
six continuity/retrieval surfaces, ten path-scoped stale-current denials, and six in-memory public mutations for
projection/marker/denial omission, contract drift, the reproduced rendered-book contradiction, and forbidden-claim
injection. Manifest semantics remain independently governed by the original 24 mutations at two exclusions and
80/0/0. Capability exclusion freshness is public-closed under `FUTURE-PARITY-BACKLOG.24`. The sole-facing book
uses a separate closeout paragraph rather than extending an existing prose blob; `.14.1` is the next clean PNT
frontier after commit.

Focused/rendered evidence 2026-08-01: exact checker output is `schema v2; 16 capabilities; backend states pass=80
partial=0 gap=0; 2 exclusions; 24 governance mutations; 12 governed projections; 6 public mutations`. Knowledge
Map generation is 783 facts / 6,348 keys. The complete mdBook builds 79 files / 14,072 KiB; direct rendered-HTML
inspection proves each new closeout is an isolated `<p>` block between neighboring paragraphs on both affected
pages. In-app browser control is not exposed in this session, so no visual viewport claim is made. Generated book
output is removed after inspection.

Signoff evidence 2026-08-01: the final focused chain preserves exact capability output at schema v2 / 16 rows /
80-0-0 / two exclusions / 24 manifest mutations / 12 governed projections / six public mutations, adjacent
callable governance at 23 mutations, Knowledge Map 783/6,348, the complete sole-facing mdBook at 79 files /
14,072 KiB, isolated rendered closeout paragraphs, whitespace, memory/task alignment, and all seven doctrines.
The definitive canonical gate proves semantic/MCP admissions, repository containment, moved-root/outside-CWD
execution, CLI 66x2, RAM 52%, and Phase 0 1,031/1,031 in 651 seconds before `local CI gate passed`. Manifest rows,
schema-v2 semantics, parser/compiler/runtime/emitter/MCP behavior, and root README remain unchanged. Commit subject
is `FUTURE-PARITY-BACKLOG.24.2 - close exclusion public no-drift`; `.14.1` follows only after brief clearing and
exact clean proof.

## `FUTURE-PARITY-BACKLOG.17.0` Read-only audit

Comparing every identifier-shaped, non-compatibility `diag_name` in the Perl lowering contracts with the aligned
239-name Dart/Julia/Lua inventories produces 16 differences. They are not one semantic class:

| Classification | Names | Disposition |
| --- | --- | --- |
| Public current named-mark helpers | `mark_entry_start`, `mark_entry_end`, `mark_match_start`, `mark_match_end`, `mark_line`, `mark_col`, `clear_mark` | `.17.1-.17.5` neutral/backend/admission parity. |
| Documented compatibility aliases | `entry_named_map`, `match_named_map` | Retain compatibility classification; do not inflate the current inventory. |
| Legacy capture surface | `capture`, `capture_macro` | Retain legacy classification; no current-backend admission. |
| Internal lowering operations | `array_append_operator`, `array_end_mutation_method`, `hash_index_assignment_operator`, `scalar_assignment_operator`, `value_drop` | Structural IR/lowering names, not public calls. |

The seven public calls are each listed as current mark helpers in the source-boundary reference and have concrete
Perl lowerings. Rust's earlier mark-family audit independently recorded the entry/match writers as follow-on gaps.
The exact 239-name checker compares Dart/Julia/Lua inventories, requires every inventoried name in the book and
neutral corpus, then reverse-checks only Perl current calls already found in that corpus. Because no governed
fixture calls the seven helpers, the symmetric omission is invisible. `.17.5` must replace or supplement that
corpus-seeded reverse leg with an independent public-current source of truth after exact backend execution lands.

## `FUTURE-PARITY-BACKLOG.16.0` Read-only audit

The parser inventory intentionally separates two surfaces that previously looked like one feature:

| Surface | Perl | Rust | Dart | Julia | Lua |
| --- | --- | --- | --- | --- | --- |
| Rule-edge/lifecycle dotted suffix without `()` | already parsed as zero-argument suffix | already parsed | already parsed | already parsed | already parsed |
| Standalone bare five control markers | all five normalize to calls/typed controls | bare words remain value reads outside attached-control synthesis | all five normalize | all five normalize | only `else`/`otherwise`/`default` normalize |
| Standalone bare `next` | not a call | not a call | not a call | not a call | not a call |
| Bare ActionIR receiver segment | rejected | rejected | rejected | rejected | accepted in every segment |

Source owners are Perl `ActionIR/ControlFlow.pm`, `StatementSplit/Core.pm`, and `AST/Parser.pm`; Rust
`linkedspec-core/src/expr.rs` plus the separate `parser.rs` suffix parser; Dart and Julia ActionParser/spec-parser
pairs; and Lua `action_parser.lua` plus `spec_parser.lua`. The existing mdBook statement that bare fluent control
markers are equivalent is accurate for rule/lifecycle suffix parsing but overstated for standalone typed ActionIR
paths across every backend.

ADR `0033` resolves the scope without expanding the grammar: six enumerated standalone zero-argument markers,
plus a bare final receiver segment lowered to an ordinary zero-argument call and checked by the existing arity
resolver. A generic bare receiver segment followed by another dot remains invalid; existing control-marker fluent
syntax is the named exception. A following `(...)`, `{ ... }`, or another dot preserves the existing productions,
so final-segment recognition needs no condition-expression lookahead. `if(condition)` and `while(condition)` keep
their parentheses; `if condition { ... }` / `while condition { ... }` remain a separate deferred design candidate.

### `FUTURE-PARITY-BACKLOG.16.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Existing docs promise bare marker aliases, but source inspection finds differing
  standalone ActionIR support and no bare `next`; Lua alone accepts generic bare receiver segments broadly.
- [x] **ROOT CAUSE (WHY + WHERE)** — Rule/lifecycle suffix parsers already encode missing parentheses as empty
  arguments, while typed ActionIR parsers use separate control normalization and receiver-call productions.
- [x] **FIX / SPLIT** — ADR 0033 fixes the narrow target; `.16.1` owns the neutral contract, `.16.2-.16.6` own
  Perl/Rust/Dart/Julia/Lua alignment, and `.16.7` owns generated/public/no-drift closeout.
- [x] **ADDRESSED (verified)** — Exact positive and excluded forms, terminality, arity behavior, retained
  parenthesized syntax, and parenthesis-free-header deferral are durable before parser behavior changes.
- [x] **NO REGRESSION** — Planning only: no parser/compiler/runtime/fixture behavior source changes.
- [x] **LOCKSTEP** — Task tree, ADR, roadmaps, mdBook status/grammar correction, Knowledge Map, live docs, and
  resume pointer all identify `.16.1` as the next leaf; parked Lua `.4.3.6.4` remains clean and recoverable.

### `FUTURE-PARITY-BACKLOG.16.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The ratified syntax had no backend-neutral executable artifact capable of rejecting
  accidental general parenthesis-free calls or premature backend-specific interpretations.
- [x] **ROOT CAUSE (WHY + WHERE)** — Existing fixtures exercise backend behavior, while this language boundary
  requires a parser-independent contract for equivalence, terminality, arity delegation, and negative classes.
- [x] **FIX** — Add `punctuation_light_zero_arg_contract.json` and an independent strict checker covering six
  standalone aliases, four final receiver aliases, three retained value reads, six invalid forms, two arity
  outcomes, and one deterministic future fixture; wire both into canonical CI.
- [x] **ADDRESSED (verified)** — Bare and parenthesized forms produce identical neutral ASTs; the future fixture
  renders exactly and evaluates to `{result: "yes", picked: "a", count: 2}`; all three contract mutations fail.
- [x] **NO REGRESSION** — Capability remains excluded/future-owned at 60/0/0; canonical CLI passes 61/61 twice and
  Phase 0 passes `1..1031` in 604 seconds; no backend parser/compiler/runtime behavior changes in this leaf.
- [x] **LOCKSTEP** — Contract README, capability manifest, mdBook grammar, Knowledge Map, task/live/roadmap docs,
  and CI agree; Perl implementation `.16.2` is the sole next leaf while Lua `.4.3.6.4` stays cleanly queued.

### `FUTURE-PARITY-BACKLOG.16.2.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — LinkedSpec `call_spec_handler_subst` lowers `return(values.drop_front())` as a valid
  default-one operation, contradicting the neutral contract's required-argument example.
- [x] **ROOT CAUSE (WHY + WHERE)** — `perl/LinkedSpec/ActionIR/MethodLowering.pm` records function-form
  `drop_front` arity `[1,2]`; subtracting the implicit receiver yields authored method arity `[0,1]`. `contains`
  is `[2,2]`, hence authored method arity `[1,1]`, and its zero-argument form takes the existing rejection path.
- [x] **FIX** — Replace only the method-resolution example with `values.contains` / `values.contains()`; preserve
  the syntax policy, AST cases, future fixture, and every backend implementation.
- [x] **ADDRESSED (verified)** — The strict contract/checker remains green with 6 standalone, 4 receiver, 6
  invalid, exact future fixture, and all mutation checks; the new fact card makes receiver-slot subtraction durable.
- [x] **NO REGRESSION** — Capability remains 60/0/0; canonical CLI passes 61/61 twice and Phase 0 passes
  `1..1031` in 605 seconds; no parser/compiler/runtime source changed.
- [x] **LOCKSTEP** — Contract, formal grammar, task/live/roadmap docs, Knowledge Map, and resume pointer agree;
  Perl implementation `.16.2.1` is next while Lua `.4.3.6.4` remains cleanly queued.

### `FUTURE-PARITY-BACKLOG.16.2.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Toolbox AST/lowering probes showed exact bare `next` was a variable plus legacy
  compatibility event and generic final bare receivers were invalid, unlike the ratified parenthesized twins.
- [x] **ROOT CAUSE (WHY + WHERE)** — Standalone statement parsing, statement splitting, scanner contract routing,
  and fluent-segment parsing are separate Perl ActionIR seams; the old `next_bare` scanner also claimed exact
  `next` before canonical lowering could own it.
- [x] **FIX** — Normalize the six named standalone markers in statement/control scanning, route exact bare `next`
  through canonical `next_stmt` while retaining labeled `next LABEL`, and admit an identifier-only generic
  receiver segment solely when it is terminal.
- [x] **ADDRESSED (verified)** — The neutral Perl contract proves six statement and four receiver semantic-AST
  equivalences, retained value reads, all six unchanged exclusions, delegated arity outcomes, canonical `NEXT`,
  and exact live plus standalone generated fixture output.
- [x] **NO REGRESSION** — Focused AST/contract suites pass; capability stays 60/0/0, CLI passes 61/61 in both
  environments, and canonical Phase 0 passes `1..1031` in 611 seconds. Labeled `next LOOP` remains compatible.
- [x] **LOCKSTEP** — CI, capability README, formal grammar/helper guidance, task/live/roadmap docs, Knowledge Map,
  and resume pointer agree; Rust `.16.3` is next while parenthesis-free `if`/`while` headers stay deferred.

### `FUTURE-PARITY-BACKLOG.16.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The existing Rust CLI compiled the bare neutral fixture with a dropped action block
  and returned `null`, while the parenthesized fixture returned the exact expected object.
- [x] **ROOT CAUSE (WHY + WHERE)** — `linkedspec-core/src/expr.rs` required `()` for every generic receiver segment
  and parsed standalone bare markers as ordinary variables; its generic variable lookahead also consumed the
  newline after a marker before statement-separator accounting.
- [x] **FIX** — Recognize only the six named aliases at exact statement boundaries before generic expression
  parsing, and synthesize an empty argument list only for a terminal generic receiver identifier.
- [x] **ADDRESSED (verified)** — Contract tests prove six statement and four receiver typed-AST equivalences,
  ordinary identifier retention, six unchanged exclusions, exact CLI parity, and native/serialized/emitted/
  generated execution of the unchanged fixture.
- [x] **NO REGRESSION** — The complete Rust gate passes 137 runtime unit tests, 105-fixture oracle, 105 generated
  classifications, 197 integration tests, focused contract/source/loader/trace/Unicode suites, and CLI 61x2.
- [x] **LOCKSTEP / FINDING** — Task/live/roadmap/book/capability/KM state advances Dart `.16.4`; the pre-existing
  Rust `.contains()` missing-argument default is recorded under helper-normalization owner `.5`, not changed here.

### `FUTURE-PARITY-BACKLOG.16.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Dart already normalized five standalone control markers, but bare `next` remained a
  value expression and every generic receiver segment still required `()`; the bare neutral CLI fixture failed.
- [x] **ROOT CAUSE (WHY + WHERE)** — `action_parser.dart` has distinct statement, control-head, expression, and
  fluent-segment seams. The terminal segment position was already explicit, so no grammar-wide lookahead was needed.
- [x] **FIX** — Normalize exact bare `next` only in `parseStatement()` and allow an identifier-only fluent segment
  only when it is the final segment, synthesizing the existing empty argument list.
- [x] **ADDRESSED (verified)** — The neutral Dart contract proves six statement and four receiver typed-AST
  equivalences, retained value reads, six unchanged exclusions, and exact native/generated/emitted/CLI fixture output.
- [x] **NO REGRESSION** — The complete Dart gate passes format, strict analysis, 211 package tests, CLI 61x2, and
  corpus 105/105. Parenthesized syntax and all excluded grammar classes are unchanged.
- [x] **LOCKSTEP / FINDING** — Task/live/roadmap/book/capability/KM state advances Julia `.16.5`; Dart's pre-existing
  `.contains()` zero-argument result is recorded with Rust under helper-normalization owner `.5`, not changed here.

### `FUTURE-PARITY-BACKLOG.16.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Julia already normalized five standalone control markers, but bare `next` remained a
  value expression and every generic receiver segment still required `()`; the bare neutral fixture failed.
- [x] **ROOT CAUSE (WHY + WHERE)** — `ActionParser.jl` has distinct statement, control-head, expression, and
  fluent-segment seams. The terminal segment position was already explicit, so no grammar-wide lookahead was needed.
- [x] **FIX** — Normalize exact bare `next` only in `parse_action_statement(...)` and allow an identifier-only
  fluent segment only when it is final, synthesizing the existing empty argument list.
- [x] **ADDRESSED (verified)** — The neutral Julia contract proves six statement and four receiver typed-AST
  equivalences, retained value reads, six unchanged exclusions, and exact native/generated/emitted/CLI fixture output.
- [x] **NO REGRESSION** — The complete Julia gate passes 1,394 package assertions, primary CLI conformance, and
  corpus 105/105. Parenthesized syntax and all excluded grammar classes are unchanged.
- [x] **LOCKSTEP / FINDING** — Task/live/roadmap/book/capability/KM state advances Lua `.16.6`; Julia's pre-existing
  `.contains()` zero-argument result is recorded with Rust/Dart under helper-normalization owner `.5`, not changed here.

### `FUTURE-PARITY-BACKLOG.16.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua normalized only bare `else`/`otherwise`/`default`, left bare `next` as a value,
  accepted generic bare receiver identifiers in every segment, and accepted `.with { ... }` without `()`.
- [x] **ROOT CAUSE (WHY + WHERE)** — `action_parser.lua` used one unconditional identifier fallback inside
  `parse_fluent_call(...)`, while block/public statement construction bypassed a shared statement-context seam.
- [x] **FIX** — Normalize all five structural markers, route exact bare `next` only through shared statement-node
  construction, and permit the generic identifier fallback only for a terminal non-block receiver segment.
- [x] **ADDRESSED (verified)** — The neutral Lua contract proves six statement and four receiver typed-AST
  equivalences, retained value reads, six negative classes, method twins, public SpecFile JSON reconstruction, and
  exact native fixture output on PUC Lua and LuaJIT.
- [x] **NO REGRESSION** — `luac -p` passes changed source/tests and the complete dual-ABI local gate passes 109/109
  on each runtime plus corpus validation and the explicit unavailable-primary-CLI scaffold check.
- [x] **LOCKSTEP / FINDINGS** — Public/task/KM state advances no-drift `.16.7`; Lua's `.contains()` result joins
  Rust/Dart/Julia under `.5`, and absent Lua generated-source proof stays with `.8.1-.8.4` rather than being faked.

### `FUTURE-PARITY-BACKLOG.16.7` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — All implementations were green, but the capability manifest still classified the
  syntax as future, public surfaces still named `.16.7` as pending, and no one command reran every backend proof.
- [x] **ROOT CAUSE (WHY + WHERE)** — Admission had intentionally waited for Lua `.16.6`; the four-backend census,
  five-backend runtime evidence, public examples, and future Lua emitter have distinct honest boundaries.
- [x] **FIX** — Admit one 64/0/0 census row, remove the future exclusion, add a composed recurring five-backend
  script and optional local-CI leg, derive generated-checker census totals, selectively migrate current examples,
  and preserve the `.8.1-.8.4` emitter owner.
- [x] **ADDRESSED (verified)** — The composed gate passes Perl 7, Rust 5, Dart 5, Julia 55, PUC Lua 109, and LuaJIT
  109 checks plus the exact neutral fixture, typed/serialized paths, and every currently available generated path.
- [x] **NO REGRESSION** — The strict neutral checker retains six invalid classes and three mutations; public
  examples keep `if(condition)` / `while(condition)`, general calls, intermediate receiver `()`, and block-call `()`.
- [x] **LOCKSTEP** — ADR/capability/task/roadmap/live/KM/mdBook state closes `.16` without claiming generated Lua;
  `LUA-BACKEND-PARITY.4.3.6.4` is the clean-pivot resume target.

### `FUTURE-PARITY-BACKLOG.14.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Preserve the director's exact distinction between linked-rule structural recursion,
  progressive in-parse parser composition, and staged post-AST enrichment without collapsing them into regex work.
- [x] **ROOT CAUSE (WHY + WHERE)** — Locate current canonical architecture, mdBook, toolbox, capture/extraction,
  spec-loading/invocation, and staged-dispatch evidence before making implementation-completeness claims.
- [x] **FIX** — Create ordered doctrine, progressive-composition, staged-enrichment, and final audit leaves; make
  explicit that later behavior or public examples require proof against the current implementation.
- [x] **ADDRESSED (verified)** — The task tree preserves simple zero/one/two-regex roles, graph-owned recursion,
  cursor-relative extraction, any-number spec composition as the intended contract, and multi-level AST parsing.
- [x] **NO REGRESSION** — Planning only: no parser, runtime, grammar, fixture, or accepted behavior changes.
- [x] **LOCKSTEP** — Task/index, roadmap, Knowledge Map/live docs, memory, and mdBook status point at the durable
  future owner; the arc remains queued behind selector retirement while Dart `.12.1.8.3` is active.

### `FUTURE-PARITY-BACKLOG.12.1.8.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — With all positive executable sources migrated, prove exact one-bare-identifier
  `array(name)` / `hash(name)` calls still enter Perl compatibility recognition and can still execute as selectors.
- [x] **ROOT CAUSE (WHY + WHERE)** — Use the Knowledge Map and LinkedSpec toolbox/tests to identify every Perl
  parser/scanner/lowering/runtime recognition and diagnostic seam that distinguishes selector calls from retained
  constructors; do not confuse generated Perl sigils with `.spec` language surface.
- [x] **FIX** — Emit the adopted `aggregate_selector_removed` diagnostic for both exact forms and delete public
  selector acceptance/dispatch while retaining non-selector constructors, literals, bare typed bindings,
  `flat_array(...)`, `flat_hash(...)`, and ordinary private host-language storage/normalization.
- [x] **ADDRESSED (verified)** — Exact selector calls fail deterministically through live and generated Perl paths;
  no authored selector node crosses the canonical lowering boundary, and retained constructor/control cases still
  execute. Private generated-Perl storage machinery is not a `.spec` surface and remains separately classified.
- [x] **NO REGRESSION** — Neutral uniform-binding and executable-source checkers, focused parser/ActionIR/runtime/
  generated-source suites, capability contracts, CLI 61x2, Phase 0, doctrines/KM/mdBook/whitespace, and artifact
  cleanup pass at their true stopping points.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, architecture, Knowledge Map, changes/notes/live, and memory
  identify Perl hard rejection complete and Rust `.12.1.8.2` as next.

### `FUTURE-PARITY-BACKLOG.12.1.8.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Consume the neutral six invalid-selector cases and prove Rust still parses/executes
  exact one-bare-identifier `array(...)` / `hash(...)` calls after all executable sources migrated.
- [x] **ROOT CAUSE (WHY + WHERE)** — Identify the typed AST/compiler/runtime/generated-plan seams that distinguish
  exact selectors from retained zero/multi/quoted/computed constructors; keep private runtime maps out of the
  public-language decision.
- [x] **FIX** — Reject exact selector nodes with `aggregate_selector_removed` plus portable surface/identifier/
  replacement fields before native or generated execution, and remove public selector dispatch while retaining
  bare bindings, constructors, literals, `flat_array(...)`, `flat_hash(...)`, and private host storage.
- [x] **ADDRESSED (verified)** — Direct parser/compiler, native execution, serialized/generated-plan, dead/nested,
  and unused-function paths reject deterministically; the eight retained constructor/literal classes still pass.
- [x] **NO REGRESSION** — Neutral/executable checkers, focused core/runtime/generated suites, complete Rust package,
  105 interpreted/generated corpus, CLI 61x2 where warranted, docs/KM/doctrines/mdBook/whitespace, and artifact
  cleanup pass at their true stopping points.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, architecture, Knowledge Map, changes/notes/live, and memory
  identify Rust hard rejection complete and Dart `.12.1.8.3` as next.

### `FUTURE-PARITY-BACKLOG.12.1.8.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Consume all six neutral invalid-selector cases and prove exact one-bare-identifier
  `array(name)` / `hash(name)` calls still survive Dart parsed/compiled/native/generated paths after migration.
- [x] **ROOT CAUSE (WHY + WHERE)** — Use the Knowledge Map, focused contract test, typed frontend/compiler models,
  runtime interpreter, and generated adapter to locate every selector recognition and trust boundary; distinguish
  exact selectors from retained zero/multi/quoted/computed constructors and direct literals.
- [x] **FIX** — Reject exact selector nodes with `aggregate_selector_removed` plus portable surface/identifier/
  replacement fields before native or generated execution, and delete selector-specific Dart dispatch while
  preserving bare typed bindings, retained constructors/literals, and private host storage.
- [x] **ADDRESSED (verified)** — Direct compile/native/generated paths, nested/dead code, unused functions, and
  decoded/emitted compiled state reject deterministically; all eight retained constructor/literal classes execute.
- [x] **NO REGRESSION** — Neutral/executable checkers, 15 focused tests, format, strict analysis, docs/KM/doctrines/
  mdBook/whitespace, and artifact cleanup pass. The complete package leg reaches 203 passes; its only two failures
  are the independently root-caused variadic `spec.spec` bridge drift owned by `.12.1.8.3.2`, not selector code.
- [x] **LOCKSTEP** — Task/index, live docs, Knowledge Map, changes/notes, and memory identify selector implementation
  complete, full Dart no-drift pending `.12.1.8.3.2`, and Julia `.12.1.8.4` only after the parent closes.

### `FUTURE-PARITY-BACKLOG.12.1.8.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Reproduce all four `spec_spec_*` failures through the real Dart corpus runner and
  capture the exact invalid recursive group after the shipped function-definition pattern became variadic.
- [x] **ROOT CAUSE (WHY + WHERE)** — Retrieve the bounded structural-regex bridge fact and prove its detector,
  prefix matcher, capture list, and named-capture map know fixed `blkFN` only while `spec.spec` now emits `blkVFN`.
- [x] **FIX** — Extend only the exact shipped variadic family with fixed/rest captures and `blkVFN` named block;
  preserve the existing fixed family and avoid claiming general recursive-PCRE support.
- [x] **ADDRESSED (verified)** — Focused runtime matching locks fixed and variadic definitions, and all four
  `spec_spec_*` corpus cases execute with unchanged expected outputs.
- [x] **NO REGRESSION** — Format/analyze, complete Dart tests, CLI 61x2, all 105 corpus cases, selector focused/
  neutral/source gates, docs/KM/doctrines/mdBook/whitespace, and cleanup pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, architecture, Knowledge Map, changes/notes/live, and memory
  close Dart `.12.1.8.3` and identify Julia `.12.1.8.4` as next.

### `FUTURE-PARITY-BACKLOG.12.1.8.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Prove all six exact selector-shaped neutral cases still compile on Julia, including
  whitespace, nested, target, and receiver shapes.
- [x] **ROOT CAUSE (WHY + WHERE)** — Retrieve the Julia uniform-binding fact and trace selector compatibility
  through typed ActionIR, deferred user-function/fluent sources, generated boundaries, and runtime dispatch.
- [x] **FIX** — Add recursive whole-compiled-state rejection with the portable diagnostic at native and generated
  boundaries, then delete every selector-only runtime recognition/dispatch branch.
- [x] **ADDRESSED (verified)** — Lock all six neutral cases, dead/fluent/unused-function coverage, caller-constructed
  generated payload rejection, and all eight retained constructor/literal classes.
- [x] **NO REGRESSION** — Focused Julia proof, zero-positive executable scan, 1,339 package assertions, CLI 61x2,
  105 corpus, canonical local CI, docs/KM/doctrines/mdBook/cleanup/whitespace all pass.
- [x] **LOCKSTEP** — Task/index, live docs, roadmaps, README/book, architecture, Knowledge Map, changes/notes, and
  memory close Julia and identify Lua `.12.1.8.5` as next.

### `FUTURE-PARITY-BACKLOG.12.1.8.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Prove all six exact selector-shaped neutral cases still compile on Lua, including
  whitespace, nested, target, and receiver shapes.
- [x] **ROOT CAUSE (WHY + WHERE)** — Retrieve the Lua uniform-binding fact and trace compatibility through typed
  ActionIR, deferred function/fluent source, runtime-engine admission, and every wrapper dispatch branch.
- [x] **FIX** — Add recursive whole-compiled-state rejection at compile/runtime-engine boundaries and delete every
  selector-only runtime recognition/dispatch branch.
- [x] **ADDRESSED (verified)** — Lock all six neutral cases, dead/fluent/function and caller-mutation coverage, and
  all eight retained constructor/literal classes on both PUC Lua and LuaJIT.
- [x] **NO REGRESSION** — Dual-ABI 88/88 full tests, zero-positive executable scan, exact 105-manifest/CLI scaffold,
  docs/KM/doctrines/mdBook/cleanup/whitespace all pass.
- [x] **LOCKSTEP** — Task/index, live docs, roadmaps, README/book, architecture, Knowledge Map, changes/notes, and
  memory close Lua and activate cross-variant no-drift `.12.1.8.6`.

### `FUTURE-PARITY-BACKLOG.12.1.8.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Audit all five backend validators/tests/runtime sources and identify any remaining
  unguarded drift or stale selector-compatibility statement.
- [x] **ROOT CAUSE (WHY + WHERE)** — Prove existing backend tests are individually strong but no single recurring
  gate requires their shared contract consumption, portable fields, validation boundaries, and runtime deletions.
- [x] **FIX** — Add and register the cross-variant retirement checker; remove stale compatibility commentary.
- [x] **ADDRESSED (verified)** — Checker requires all five contract-driven rejection suites/boundaries and forbids
  known runtime selector symbols/patterns while composing the executable-source scan.
- [x] **NO REGRESSION** — Cross-variant checker, all five focused/dual-ABI rejection suites, canonical registration,
  docs/KM/doctrines/mdBook/cleanup/whitespace all pass.
- [x] **LOCKSTEP** — Task/index, live docs, roadmaps, README/book, architecture, Knowledge Map, changes/notes, and
  memory close `.12.1.8` and activate final public admission `.12.1.9`.

### `FUTURE-PARITY-BACKLOG.12.1.9` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Audit all current public docs, mdBook examples, capability status, diagnostics, tests,
  and executable sources after hard retirement; distinguish normative drift from historical/rejection evidence.
- [x] **ROOT CAUSE (WHY + WHERE)** — Identify why implementation/source no-drift alone cannot prevent a stale public
  compatibility statement, positive authoring example, or future-capability exclusion from surviving admission.
- [x] **FIX** — Add/register a deterministic public-surface retirement checker; remove every current-facing caveat
  or positive selector example; retire the capability future exclusion and align public/live status.
- [x] **ADDRESSED (verified)** — Public guidance teaches bare typed bindings and literals/retained constructors only;
  removed exact selectors appear solely in classified rejection, migration-history, or durable fact evidence.
- [x] **NO REGRESSION** — Public-surface, uniform-binding, aggregate-retirement, capability, canonical local CI,
  docs/KM/doctrines/mdBook/cleanup/whitespace all pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, architecture, Knowledge Map, changes/notes/live, and memory
  close `.12.1` and point at the next dependency-correct PNT leaf.

### `FUTURE-PARITY-BACKLOG.12.1.10` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Scan every backend README and prove current positive selector examples survived the
  admitted 47-file public gate while executable sources and the root/capability/mdBook set remain clean.
- [x] **ROOT CAUSE (WHY + WHERE)** — Show that `check_public_aggregate_selector_surface.py` enumerates a curated
  root/capability/mdBook set but does not discover tracked backend READMEs, allowing public language drift.
- [x] **FIX** — Migrate current backend README prose/snippets and extend the checker with deterministic backend
  README discovery plus stable classification/count assertions.
- [x] **ADDRESSED (verified)** — Every backend README teaches bare typed bindings and exact selectors occur only in
  explicit removed/rejected/history evidence accepted by the canonical classifier.
- [x] **NO REGRESSION** — Expanded public/runtime/capability checker, relevant backend gates, docs/KM/doctrines,
  mdBook, artifact cleanup, and whitespace all pass with no runtime or fixture behavior change.
- [x] **LOCKSTEP** — Task/index, roadmaps, root/backend README/book, architecture, Knowledge Map, changes/notes/live,
  and memory re-close `.12.1`/`.12` and resume Lua numeric alias/receiver `.4.3.3.2`.

### `FUTURE-PARITY-BACKLOG.12.1.11` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Inventory all current statement-only/no-value array-end result claims against the
  adopted contract, five backend implementation facts/tests, and public examples that already chain updates;
  reproduce Perl leaving value-position calls raw until generated execution fails in `SpecEntry::push_back`.
- [x] **ROOT CAUSE (WHY + WHERE)** — Distinguish valid dated history from current normative drift introduced when
  `.12.1.1-.6` superseded the earlier terse slice without revisiting every book/KM/backend summary; prove Perl's
  `BindingRuntime::array_end_mutation` already returns the independent update while the ActionIR fluent-chain value
  path explicitly rejects all four methods.
- [x] **FIX** — Correct public/KM/backend semantics, preserve explicit supersession provenance, lower the first
  array-end mutation on a named typed binding as an array-valued assignment that may feed compatible continuations,
  replace the superseded statement-only Perl regression lock, and add a recurring checker that rejects future
  current-facing statement-only array-end result claims.
- [x] **ADDRESSED (verified)** — Public guidance says all four end methods mutate and return independent updated
  arrays, pop discards only the removed element, saved results stay isolated, and receiver continuations consume
  the update; historical cards identify their original slice and later supersession.
- [x] **NO REGRESSION** — Uniform-binding checker, five backend focused tests, public checker, mdBook, KM,
  doctrines, cleanup, and whitespace pass.
- [x] **LOCKSTEP** — `.12.1`/`.12` re-close and the single frontier returns to Lua array construction `.4.3.4.1`.

### `FUTURE-PARITY-BACKLOG.12.1.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Count exact selector-shaped calls and prove that current bare alternatives are not
  yet uniformly executable, rather than assuming source replacement is mechanical.
- [x] **ROOT CAUSE (WHY + WHERE)** — Locate public ambiguity and each backend's selector recognition, target
  extraction, constructor special case, store lookup, and mutation dispatch seams.
- [x] **FIX** — Split neutral semantics, Perl/Rust/Dart/Julia/Lua enablement, three source-migration surfaces, five
  hard-retirement backends plus no-drift, and final public documentation before behavior code.
- [x] **ADDRESSED (verified)** — Boundary-correct inventory covers 600 calls/82 specs, 210 calls/15 shipped specs,
  parent-helper and
  receiver categories, toolbox lowering, and concrete backend owner locations.
- [x] **NO REGRESSION** — Read-only inventory and task/docs/KM updates only; no grammar, lowering, runtime,
  generated-source, fixture, or accepted `.spec` behavior changes.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, Knowledge Map, changes/notes/live, and bounded memory route
  exact selector removal through neutral contract `.12.1.1`; selector survival is not an open question.

### `FUTURE-PARITY-BACKLOG.12.1.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Encode the concrete bare push/split ambiguity and selector-shaped constructor/read/
  target problem as neutral cases before any backend changes.
- [x] **ROOT CAUSE (WHY + WHERE)** — Define one observable typed binding independently of backend host storage;
  callable purpose, arity, static rule registry, and runtime value—not wrapper syntax—must govern dispatch.
- [x] **FIX** — Add a strict versioned contract/checker with canonical migration mappings, valid binding/mutation/
  constructor cases, exact future selector diagnostics, deterministic future fixture source/results, and CI wiring.
- [x] **ADDRESSED (verified)** — Independent evaluation checks set/push/split/hash mutation/copy/read/chaining,
  absent binding creation, static rule precedence, silent drop, result values, and invalid selectors.
- [x] **NO REGRESSION** — Contract/docs/checker only: current Perl/Rust/Dart/Julia/Lua parsing, lowering, runtime,
  generated source, shipped specs, corpus fixtures, and current capability census remain unchanged.
- [x] **LOCKSTEP** — Contract README, task/index, roadmaps, README/book, Knowledge Map, changes/notes/live, memory,
  and canonical CI identify Perl `.12.1.2` as the first behavior consumer.

### `FUTURE-PARITY-BACKLOG.12.1.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Consume the neutral future fixture and focused bare set/push/split/hash/read/chaining/
  static-precedence/wrong-kind cases on live and standalone generated Perl, preserving measured failure evidence.
- [x] **ROOT CAUSE (WHY + WHERE)** — Remove observable bare-target dependence across `MethodLowering`,
  `ArrayPipeline`, `Contracts`, `ControlFlow`, `FlowExpr`, and `EmitContext` type/declaration memory while preserving
  static child-rule push precedence and temporary wrapper compatibility.
- [x] **FIX** — Lower bare typed mutations through one scalar-held value binding (or an observationally identical
  private representation), return post-operation values, auto-create absent required kinds, reject wrong kinds,
  and make three-argument bare split mutate without changing pure two-argument split.
- [x] **ADDRESSED (verified)** — Neutral checker plus focused live/generated proof cover all seven execution cases,
  deterministic fixture, expression chaining/drop, static precedence, diagnostics, compatibility selectors, and
  current constructor classification.
- [x] **NO REGRESSION** — Shipped specs, wrapper-era Phase-0 locks, ActionIR, generated source, CLI, capability,
  doctrines, Knowledge Map, whitespace, and mdBook reach their true stops before source migration.
- [x] **LOCKSTEP** — Code/tests/task/index, roadmaps, README/book, KM, changes/notes/live, and memory describe Perl
  selector-free enablement as current while exact selector rejection remains deferred until `.12.1.8.1`.

### `FUTURE-PARITY-BACKLOG.12.1.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run the neutral future fixture and the seven binding/mutation cases through Rust
  native and generated execution, retaining exact failures for bare push, mutable split, hash update, chaining,
  static precedence, or wrong-kind diagnostics.
- [x] **ROOT CAUSE (WHY + WHERE)** — Trace bare reads and mutation ownership through parsed ActionIR,
  `RuntimeContext`, `execute_call`, receiver dispatch, target resolvers, generated plans, and diagnostic projection;
  distinguish public binding semantics from private scalar/array/hash stores.
- [x] **FIX** — Make bare set/push/append/mutable split/hash/index/collection mutations observe and return one
  `RuntimeValue`, auto-create only missing required kinds, reject incompatible existing kinds, preserve static-rule
  push precedence, and retain selectors solely as migration compatibility.
- [x] **ADDRESSED (verified)** — Focused Rust native/generated fixtures match the neutral expected values and error
  fields, including saved mutation results, `set(...).sorted().first()`, array-end result continuation, pure versus
  mutable split, and silent drop.
- [x] **NO REGRESSION** — Core/runtime/integration/oracle/generated-source/CLI/capability/doctrine/Knowledge Map/
  whitespace/mdBook gates reach their true stops without migrating or rejecting tracked selector sources.
- [x] **LOCKSTEP** — Rust code/tests/task/index, roadmaps, README/book, KM, changes/notes/live, and memory identify
  Rust as the second enabled backend and Dart `.12.1.4` as next.

### `FUTURE-PARITY-BACKLOG.12.1.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run the neutral future fixture and all seven binding/mutation cases through Dart
  native and generated-plan execution, preserving exact push/split/hash/result/chaining/precedence/wrong-kind gaps.
- [x] **ROOT CAUSE (WHY + WHERE)** — Trace `ActionVariableExpr`, statement interception, `_RuntimeExecutionContext`
  variable/array/hash stores, target-name helpers, fluent dispatch, generated plans, and diagnostic projection;
  separate one public typed binding from private migration storage.
- [x] **FIX** — Make bare set/push/append/mutable split/hash/index/array-end/collection mutations read, validate,
  update, and return one typed value; auto-create only absent required kinds; preserve static-rule push precedence;
  keep exact selectors solely as temporary migration input.
- [x] **ADDRESSED (verified)** — Native/generated fixtures match the neutral result/error fields, saved snapshots,
  `set(...).sorted().first()`, mutation continuation, pure/mutable split, collection rebinding, and silent drop.
- [x] **NO REGRESSION** — Dart format/analyze/unit/corpus/generated/CLI plus neutral/capability/doctrine/KM/mdBook/
  whitespace gates reach their true stops without migrating or rejecting tracked selector sources.
- [x] **LOCKSTEP** — Dart code/tests/task/index, roadmaps, README/book, KM, changes/notes/live, and memory identify
  Dart as the third enabled backend and Julia `.12.1.5` as next.

### `FUTURE-PARITY-BACKLOG.12.1.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run the neutral future fixture and all seven binding/mutation cases through Julia
  native and generated execution, preserving exact push/split/hash/result/chaining/precedence/wrong-kind gaps.
- [x] **ROOT CAUSE (WHY + WHERE)** — Trace `ActionVariableExpr`, statement interception, `_read_runtime_store`,
  private variable/array/hash stores, target-name helpers, fluent dispatch, generated execution, and diagnostic
  projection; separate one public typed binding from private migration storage.
- [x] **FIX** — Make bare set/push/append/mutable split/hash/index/array-end/collection mutations read, validate,
  update, and return one typed value; auto-create only absent required kinds; preserve static-rule push precedence;
  keep exact selectors solely as temporary migration input.
- [x] **ADDRESSED (verified)** — Native/generated fixtures match the neutral result/error fields, saved snapshots,
  `set(...).sorted().first()`, mutation continuation, pure/mutable split, collection rebinding, and silent drop.
- [x] **NO REGRESSION** — Julia formatting/package/corpus/generated/CLI plus neutral/capability/doctrine/KM/mdBook/
  whitespace gates reach their true stops without migrating or rejecting tracked selector sources.
- [x] **LOCKSTEP** — Julia code/tests/task/index, roadmaps, README/book, KM, changes/notes/live, and memory identify
  Julia as the fourth enabled backend and Lua `.12.1.6` as next.

### `FUTURE-PARITY-BACKLOG.12.1.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run the neutral future fixture and all seven binding/mutation cases through PUC Lua
  and LuaJIT, preserving exact push/split/hash/result/chaining/precedence/wrong-kind gaps.
- [x] **ROOT CAUSE (WHY + WHERE)** — Trace variable reads, `lookup_binding`, scalar/array/harray stores,
  `target_descriptor`, call/statement interception, fluent dispatch, and diagnostic projection; separate one public
  typed binding from private migration storage.
- [x] **FIX** — Make bare set/push/append/mutable split/hash/index/array-end/collection mutations read, validate,
  update, and return one typed value; auto-create only absent required kinds; preserve static-rule push precedence;
  keep exact selectors solely as temporary migration input.
- [x] **ADDRESSED (verified)** — Both Lua ABIs match neutral result/error fields, saved snapshots,
  `set(...).sorted().first()`, mutation continuation, pure/mutable split, collection rebinding, and silent drop.
- [x] **NO REGRESSION** — Dual-ABI Lua package/corpus/CLI plus neutral/capability/doctrine/KM/mdBook/whitespace gates
  reach their true stops without migrating or rejecting tracked selector sources.
- [x] **LOCKSTEP** — Lua code/tests/task/index, roadmaps, README/book, KM, changes/notes/live, and memory identify all
  five enabled backends and source migration `.12.1.7.1` as next.

### `FUTURE-PARITY-BACKLOG.12.1.7.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Recount exact selector-shaped calls in the 15 affected shipped `specs/*.spec` files,
  classify every occurrence as typed read/target/receiver versus intended one-element construction, and preserve a
  file-by-file baseline before editing. Require a left identifier boundary so `flat_array(name)` is not counted.
- [x] **ROOT CAUSE (WHY + WHERE)** — Use the recorded parent-call/receiver inventory plus parser/runtime proof to
  select bare bindings for reads and mutation targets, `[value]` for intended one-element arrays, and ordinary
  retained constructors only where the neutral contract permits them. The first migrated Lispish CLI proof also
  exposed a Perl-only lowering split: uniform mutations write scalar-held typed values (`$name`), while legacy
  read-only array/hash helper fast paths still read `@name` / `%name`; repair that bounded read seam in this leaf.
- [x] **FIX** — Remove every exact `array(IDENTIFIER)` / `hash(IDENTIFIER)` occurrence from shipped specs without
  changing unrelated syntax, helper choice, or rule behavior; make Perl pure collection helpers consume the same
  scalar-held bare typed binding that mutation helpers update.
- [x] **ADDRESSED (verified)** — Shipped source scan is zero and reference/generated descriptors/execution preserve
  the intended values for every affected spec and shipped proof fixture.
- [x] **NO REGRESSION** — Focused shipped-spec, generated-source, backend corpus, capability/doctrine/KM/mdBook/
  whitespace gates reach their true stops; derived expectations change only when selector-free syntax requires it.
- [x] **LOCKSTEP** — Shipped specs/task/index, roadmaps, README/book, KM, changes/notes/live, and memory identify
  shipped migration complete and neutral/oracle/corpus migration `.12.1.7.2` as next.

### `FUTURE-PARITY-BACKLOG.12.1.7.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Preserve the boundary-correct 390-occurrence/67-file baseline: five occurrences in
  two capability fixtures, 366 in 62 neutral Rust-oracle inputs, and 19 in three legacy corpus inputs; identify
  intended `[undef]` one-element construction separately from binding selectors.
- [x] **ROOT CAUSE (WHY + WHERE)** — Treat capability fixtures and their mirrored oracle inputs as one source
  contract, preserve quoted/multi/computed constructors, and distinguish scalar-held typed array/harray reads from
  explicit construction before mechanical replacement.
- [x] **FIX** — Remove every exact selector from file-backed capability/oracle/corpus `.spec` inputs, using bare
  bindings for reads/targets/receivers and `[undef]` for the three intended one-element arrays; regenerate only
  expectations or classifications whose derived bytes genuinely change.
- [x] **ADDRESSED (verified)** — All tracked file-backed `.spec` inputs scan at zero exact selectors; capability
  mirrors agree; Perl/Rust/Dart/Julia/Lua corpus results preserve their expected values.
- [x] **NO REGRESSION** — Strict uniform/capability/generated/native contracts, full corpus and generated-source
  breadth, CLI, doctrines/KM/mdBook/whitespace, and the canonical local gate reach their true stops.
- [x] **LOCKSTEP** — Corpus inputs/derived expectations/task/index, roadmaps, README/book, KM, changes/notes/live,
  and memory identify file-backed migration complete and embedded source-string migration `.12.1.7.3` as next.

### `FUTURE-PARITY-BACKLOG.12.1.7.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Preserve the boundary-correct baseline of 1,356 positive exact occurrences across 25
  test/tool/backend files or test-only source sections, separated from 28 implementation/neutral-contract
  occurrences in recognizers, diagnostics, comments, two explicit compatibility-path tests, and the removed-syntax
  checker; exclude four dotted Lua host `json.array(...)` calls, documentation/history, and ordinary constructors.
- [x] **ROOT CAUSE (WHY + WHERE)** — Identify tests and tools that still compile or execute legacy selector source,
  distinguish source assertions from host implementation text, and preserve the hard-rejection evidence owned by
  `.12.1.8` without allowing compatibility syntax to remain an executable positive fixture.
- [x] **FIX** — Migrate every positive embedded test/tool/backend spec source to bare typed bindings and literals;
  update derived AST/source expectations only where those embedded inputs genuinely change.
- [x] **ADDRESSED (verified)** — A boundary-correct executable-source scan reaches zero positive selector inputs;
  any remaining exact spellings are mechanically classified as implementation recognition/diagnostic text,
  neutral rejection/migration contract data, or non-executable historical documentation.
- [x] **NO REGRESSION** — Focused Perl/Rust/Dart/Julia/Lua parser/runtime/generated-source tests, complete backend
  gates, uniform/capability contracts, canonical CI, doctrines/KM/mdBook/whitespace, and artifact cleanup pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, KM, changes/notes/live, and memory identify all source
  migration complete and Perl hard rejection `.12.1.8.1` as next.

### `FUTURE-PARITY-BACKLOG.13.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Preserve exact raw-expression and lifecycle/action-chain inspector failures showing
  plugin AUTOLOAD receives `_rewrite_action_code_with_diagnostics` and `_render_method_call_chain`.
- [x] **ROOT CAUSE (WHY + WHERE)** — Confirm current implementations/ownership, thin-facade history, tool callers,
  and whether any supported public probe seam should replace direct private-owner calls.
- [x] **FIX** — Route all four documented snippet forms through explicit current owners or one deliberate stable
  inspection API; do not expose unrelated internals through the public facade.
- [x] **ADDRESSED (verified)** — Raw helper, lifecycle block, lifecycle chain, and action-edge block/chain examples
  print generated Perl plus canonical diagnostics without plugin dispatch.
- [x] **NO REGRESSION** — Add a recurring smoke test and pass focused tool/ActionIR, Phase-0, doctrine/KM/mdBook,
  whitespace, and canonical local gates.
- [x] **LOCKSTEP** — Task/index, TOOLBOX/README, Knowledge Map, changes/notes/live, and memory identify the restored
  inspector contract and next PNT frontier.

Activation/implementation evidence 2026-08-29: from exact clean pushed `82d0b85f`, five separate documented-form
probes reproduce status 2 and the two exact unknown-plugin names. Git `2984fb50` introduced the tool; Phase 1A
`e964d9a4` removed dead facade wrappers while leaving the implementations in `BootstrapSpec::Core` and
`RuleIR::EmitContext`. Existing focused tests directly call those internal owner packages, so the repair uses that
established seam rather than widening `LinkedSpec`. One five-case smoke requires generated Perl, canonical nodes,
zero fallback/unresolved counts, explicit owner call sites, and no stale facade call. Syntax, smoke, ActionIR AST,
and trace-pipeline focused proof passes; complete documentation and canonical proof remain before closeout.

Closeout candidate 2026-08-29: focused tool/ActionIR, project-storage, memory/task/Knowledge/history/README-routing,
nine-doctrine, rendered-book/cleanup, and whitespace proof passes. TOOLBOX and the dedicated sole-facing mdBook
page teach exact invocations; root README stays unchanged under its stable-landing policy. ADR `0073` requires the
fully staged canonical gate because `tools/run_ci_local.sh` changes; its receipt, commit, clean-tree check, and push
are the remaining mechanical boundary, not additional source work.

### `FUTURE-PARITY-BACKLOG.12.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Duck-typed values coexist with legacy wrapper-selected scalar/aggregate namespaces,
  while earlier expression and trailing-codeblock doctrine was distributed across several completed trees.
- [x] **ROOT CAUSE (WHY + WHERE)** — The `.spec` language retained `array(name)` / `hash(name)` selector and
  mutation forms after bare assignments became typed value bindings, leaving two public ways to identify storage.
- [x] **FIX** — Capture one uniform-expression doctrine and create `.12.1` to design/split removal of temporary
  compatibility, especially `array(name)`/`hash(name)` as type or mutation authority.
- [x] **ADDRESSED (verified)** — Existing records prove assignment, inline if/switch, user/helper calls, VALUE_DROP,
  and generic trailing-codeblock ownership; the new card joins them and states the missing retirement contract.
- [x] **NO REGRESSION** — Planning-only: no parser, compiler, runtime, fixture, or active Lua frontier changed.
- [x] **LOCKSTEP** — Future task, index, roadmaps, mdBook status, KM, changes/notes/live, and memory agree.

### `FUTURE-PARITY-BACKLOG.17.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Compare current Perl contract diagnostics against the aligned 239-name inventories
  and show why the existing coverage report remains green while seven public mark calls are missing everywhere.
- [x] **ROOT CAUSE (WHY + WHERE)** — Classify every difference as internal operator, legacy/compatibility spelling,
  or public current helper; trace the checker's corpus-seeded reverse direction that preserves symmetric omissions.
- [x] **FIX** — Create `.17.1-.17.5` for neutral/Perl/Rust, Dart, Julia, Lua, and final admission/gate hardening;
  make Lua `.4.3.7.3` depend on the shared resolution instead of adding an isolated extension.
- [x] **ADDRESSED (verified)** — Task, book/status, Knowledge Map, roadmap, live docs, and memory record the exact
  seven names, affected surfaces, dependency order, and clean return to Lua `.4.3.7.1`.
- [x] **NO REGRESSION** — Planning changes no parser/compiler/runtime/inventory/corpus/capability behavior; focused
  coverage, memory, task, doctrine, Knowledge Map, book, and whitespace checks pass.
- [x] **LOCKSTEP** — `.17` remains owned by its implementation leaves, `.17.0` closes only the tracking/audit slice,
  and Lua input/cursor `.4.3.7.1` resumes without a false named-mark parity claim.

### `FUTURE-PARITY-BACKLOG.17.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The exact Unicode parent/child fixture shows that Perl already has the seven public
  helpers, while Rust lacks their dispatch and keeps all mark names in one execution-global bucket; standalone
  generated Perl also fails when emitted mark writers call a trace delegate absent from the generated package.
- [x] **ROOT CAUSE (WHY + WHERE)** — `LinkedSpec::call_spec_handler_subst` and generated-handler source inspection
  prove the Perl lowerings and missing generated delegate; the Rust runtime/engine audit proves global mark storage,
  absent `mark_pos` coercion to zero, and missing entry/local/location/delete helper arms.
- [x] **FIX** — Adopt one strict seven-helper contract and unchanged fixture; make Perl generated source provide the
  safe trace delegate; make Rust store marks by rule label, preserve every named capture operation through that
  bucket, expose character locations, return undef when absent, and implement all seven helpers.
- [x] **ADDRESSED (verified)** — The neutral checker rejects three semantic drifts; Perl live and standalone-generated
  execution and Rust native/serialized/emitted-plan/generated execution return the exact same nested value.
- [x] **NO REGRESSION** — Focused Perl and Rust contracts pass; the complete Rust core/runtime package gate passes
  188 core, 137 runtime, 105 oracle, 105 generated-corpus, 197 integration, and all specialized suites. The
  canonical repository gate passes capability 64/0/0, CLI 61/61 twice, and Phase 0 `1..1031` in 983 seconds.
- [x] **LOCKSTEP** — The exact contract, CI wiring, public helper reference/example, task/index/roadmap/live state,
  Knowledge Map evidence, and backend handoff agree; Dart `.17.2` is the next backend consumer after commit.

### `FUTURE-PARITY-BACKLOG.17.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The neutral fixture proves Dart's existing rule-local/code-unit mark store lacks the
  four entry/local writers, two location readers, and clear dispatch, while absent `mark_pos` incorrectly becomes
  public character position zero.
- [x] **ROOT CAUSE (WHY + WHERE)** — The runtime dispatch and capture/mark contract set omit all seven calls; the
  existing store and Unicode projection seams are otherwise correct. Direct admission to the legacy shared
  239-name set would also make the exact Dart/Julia/Lua inventory comparison fail before Julia/Lua alignment.
- [x] **FIX** — Route all seven calls through the current rule bucket and match registers, preserve code-unit
  storage plus character public values, return undef for missing positions/locations, and expose a separate exact
  staged inventory folded into Dart's known-call boundary.
- [x] **ADDRESSED (verified)** — One contract test returns the unchanged exact value through native execution,
  generated-plan execution, emitted-state reconstruction, and the primary CLI; it also locks exactly seven staged
  names and their deliberate disjointness from the legacy shared inventory.
- [x] **NO REGRESSION** — Focused format/analyze/68 and complete 214-package/CLI-61x2/corpus-105 gates pass; the
  canonical repository gate passes capability 64/0/0, shared inventory 239/105, CLI 61x2, and Phase 0 `1..1031`
  in 1,061 seconds.
- [x] **LOCKSTEP** — Source, test, capability README, task/index/roadmap/live docs, mdBook, Knowledge Map, and
  governance agree; Julia `.17.3` is the next backend consumer after the prepared commit and clean pivot.

### `FUTURE-PARITY-BACKLOG.17.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The neutral fixture proves Julia's existing rule-local/code-unit mark store lacks
  the four entry/local writers, two location readers, and clear dispatch even though absent position behavior and
  character projection are already correct.
- [x] **ROOT CAUSE (WHY + WHERE)** — Runtime dispatch and the capture/mark contract set omit all seven calls; the
  store, match registers, and Unicode projection seams are otherwise correct. Direct admission to the legacy
  shared 239-name set would also break exact Dart/Julia/Lua inventory equality before Lua alignment.
- [x] **FIX** — Route all seven calls through the current rule bucket and match registers, preserve code-unit
  storage plus character public values, and export a separate exact staged inventory folded into Julia's
  known-call boundary.
- [x] **ADDRESSED (verified)** — One 13-assertion contract returns the unchanged exact value through native,
  generated-plan, emitted-state reconstruction, and primary-CLI execution while locking exactly seven staged
  names and their deliberate disjointness from the legacy shared inventory.
- [x] **NO REGRESSION** — The complete Julia gate passes 1,414 package assertions, shared CLI 61x2, and corpus
  105/105; canonical CI passes capability 64/0/0, shared inventory 239/105, CLI 61x2, and Phase 0 `1..1031` in
  614 seconds.
- [x] **LOCKSTEP** — Source, test, capability README, task/index/roadmap/live docs, mdBook, Knowledge Map, and
  governance agree; Lua `.17.4` is the next backend consumer after the prepared commit and clean pivot.

### `FUTURE-PARITY-BACKLOG.17.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The unchanged Unicode parent/child fixture proves Lua had no runtime named-mark
  bucket or dispatch for the four entry/local writers, two location readers, and explicit clear, even though its
  match registers and byte/character projection seams were already sufficient.
- [x] **ROOT CAUSE (WHY + WHERE)** — `interpreter.lua` routed no governed named-mark helpers and execution context
  owned no rule-label mark store; `action_call_names.lua` also lacked the seven staged names. Directly changing the
  legacy shared 239-name set would prematurely perform `.17.5` admission.
- [x] **FIX** — Add one parse-scoped rule-label/name/byte-offset store; route the exact seven calls through existing
  match snapshots and Unicode projections; preserve symbolic bare names; and expose a disjoint staged known-call
  set without changing the shared count.
- [x] **ADDRESSED (verified)** — Native and serialized `SpecFile` reconstruction return the exact neutral value,
  including same-name child/parent isolation, missing undef, clear/existence, and 1-based character locations.
- [x] **NO REGRESSION** — The complete Lua gate passes 119/119 on PUC Lua and LuaJIT plus syntax, CLI scaffold,
  and all 105 manifest checks; canonical CI passes capability 64/0/0, shared coverage 239/105, CLI 61x2, Phase 0
  `1..1031` in 627 seconds, and every doctrine/documentation gate.
- [x] **LOCKSTEP** — Source, focused tests, capability README, task/index/roadmap/live docs, mdBook, and Knowledge
  Map agree; `.17.5` is the next clean-pivot admission/hardening leaf and Lua `.4.3.7.3` consumes this foundation.

### `FUTURE-PARITY-BACKLOG.17.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The former checker stayed green when one current public call was omitted from every
  backend inventory and every corpus fixture because its Perl reverse check was seeded only by corpus source.
- [x] **ROOT CAUSE (WHY + WHERE)** — `tools/check_language_capability_coverage.pl` had no independent definition
  of the public Perl contract set and treated the 105-case corpus as both coverage evidence and discovery input.
- [x] **FIX** — Admit the exact seven helpers into all three shared inventories; supplement the corpus with the
  exact named-mark fixture; independently derive 122 public Perl contracts; and lock the exact nine excluded
  compatibility, legacy, and internal lowering names.
- [x] **ADDRESSED (verified)** — A simultaneous Dart/Julia/Lua deletion of `clear_mark` is reported by both the
  exact seven-helper family check and the independent 122-contract reverse check, even though backend equality is
  preserved by the mutation.
- [x] **NO REGRESSION** — The exact neutral/Perl/Rust proofs and complete Dart, Julia, Lua, and Rust local gates
  pass; shared coverage reports 246 names, 105 corpus fixtures plus one exact fixture, and 122/122 public contracts.
- [x] **LOCKSTEP** — Source, tests, capability material, task/index/roadmap/live docs, mdBook, Knowledge Map, and
  canonical CI agree; parent `.17` is closed and Lua `.4.3.7.3` is the next active executable leaf.

### `FUTURE-PARITY-BACKLOG.9.1.1.1` Acceptance Checklist

- [x] **RETRIEVE / CURRENT MECHANISM** — Read the cursor/edge Knowledge Map facts and exact Perl compiler,
  HandlerIR, validation/bootstrap, descriptor, generated-v1, CLI, and Rust/Dart/Julia/Lua owner seams before
  choosing the future contract.
- [x] **ROOT CAUSE / AUTHORITY** — Preserve the measured distinction between authored rule family, low-level
  matcher algorithm, parent composition, child-owned semantics, and explicit action/blind match ownership.
- [x] **RATIFY EXACTLY** — ADR `0044` fixes family-to-cursor mapping, bare normalization and lexical boundary,
  explicit/indexed/grouped/fluent legality, mixed ownership, structural cross-combinations, API/CLI retirement,
  descriptor facts, generated-v2 family derivation, diagnostics, and conformance.
- [x] **SPLIT BEFORE CODE** — `.9.1.2-.9` separately own neutral contract/inventory, Perl, Rust, Dart, Julia,
  Lua/LuaJIT, symmetric admission, and public no-drift; no implementation is hidden in the decision leaf.
- [x] **ADDRESSED (verified)** — ADR/index, task/frontier, roadmaps, architecture, guide, mdBook, live status,
  bounded memory, and a generated Knowledge Map fact agree on accepted versus currently shipped behavior.
- [x] **NO REGRESSION / LOCKSTEP** — Memory architecture, Knowledge Map, task metadata, doctrines, mdBook, and
  whitespace pass. No parser/compiler/runtime/descriptor/generated/CLI/fixture/test/capability behavior changes;
  Rust logical `.5.2.3` resumes after the clean commit.

<!-- Source ranges and their immutable migration digest are recorded in docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl. -->
