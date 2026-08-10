# ROADMAP V2
Execution-oriented companion to `ROADMAP.md`.

Rule-local cursor rollout is closed at 74 files / 8 complete + 0 pending / 60 mutations, with
selected 5x2x5 recurring and public proof.
Duplicate-slot rollout is closed at 7 complete / 0 pending; recurring proof remains
`tools/check_duplicate_regex_slot_identity_five_backend.sh`.
Repeated-action rollout is closed at 8 complete / 0 pending; recurring proof remains
`tools/check_repeated_action_result_five_backend.sh`.

Accepted long-horizon direction: ADR `0064` plus `SPEC-LANGUAGE-SELF-CONTAINMENT` define portable `.spec`
problem-domain closure without ambient effects and an optional honest EBNF-like frontend over the same canonical
AST/HandlerIR/runtime. Lossless authored source maps, explicit semantic differences/extensions, realistic trials,
and Perl/Rust/Dart/Julia/Lua parity are mandatory. `.0` is behavior-free routing; `.1+` remains unscheduled behind
current callable-codeblock parity.

Completed continuity correction: `MEMORY-COMMIT-POINTER-ENFORCEMENT` / ADR `0065` correct the self-referential
`MEMORY.md latest_commit == post-commit HEAD` expectation. Git owns current commit identity; the tracked pointer
names the clean `activation_commit` (`HEAD` before the leaf commit, `HEAD^1` afterward). `.0` ratifies the
contract; `.1` implements shared pre/post enforcement and 11 hermetic cases; `.2` independently recomposes the
committed state from `ed136df2`, annotates two historical supersessions, and closes the correction. Dart `.11.5.1`
closes construction at `5e80be32`, `.11.5.2` closes dynamic invocation at `74725ff0`, and `.11.5.3` lands generic
contextual normalization and closes Dart parent `.11.5` at `bdae816a`. Julia construction `.11.6.1` is
committed clean at `3a38338d`; dynamic invocation `.11.6.2` lands clean at `bc85c0fa`; generic contextual
final-block equivalence `.11.6.3` is signoff-complete from that boundary and closes Julia parent `.11.6`;
behavior-free `.11.7.0` proves the four current backends focused-green and splits recurring/public governance from
dependency-complete Lua construction/invocation/generation/admission. `.11.7.1` composes one routed four-backend
driver, 17 topology/status mutations, optional canonical registration, and a Lua-only future exclusion while
capability remains 80/0/0. Public no-drift `.11.7.2` historically inventories 23 documents and closes the four-
implementation boundary; Lua implementation/admission `.11.8.0-.4` then completes the remaining runtime.
Completed behavior-free `.11.8.0` freezes one focused dual-ABI Lua consumer and dependency-orders inert ActionIR
state `.1`, dynamic call/access/diagnostics `.2`, existing-emitter route identity `.3`, then five-backend admission
`.4`. Inert construction `.11.8.1` is now signoff-complete on both Lua ABIs with exact typed records/spans/nine
malformed codes, deferred bodies, preserved copies, function/compiled/generated/emitted effective state, and
semantic signatures. Focused 168x2, complete Lua, neutral+20, KM 777/6,301, mdBook, all doctrines, and canonical
Phase 0 1,031/1,031 plus the callable matrix pass. Dynamic invocation `.11.8.2` is signoff-complete at
focused 232x2 plus the complete dual-ABI Lua gate. Emitted identity `.11.8.3` is signoff-complete at focused
449x2 plus complete Lua 177x2, CLI 66x2, corpus 105/105, 17 storage owners, KM 779/6,322, sole-facing mdBook
79/14,048 KiB, all doctrines, canonical Phase 0 1,031/1,031 in 809 seconds, and the callable matrix.
Five-backend callable recurring/public admission is complete under `.11.8.4`: one rooted neutral/Perl/Rust/Dart/Julia/PUC-Lua/
LuaJIT driver, two Lua rows over one consumer, 22 governance mutations, 25 public documents, satisfied-exclusion
removal, unchanged census 80/0/0, and parent `.11.8`/`.11` closure. Signoff passes complete Lua 177x2, CLI
66x2, corpus 105/105, 17 storage owners, Knowledge Map 780/6,328, sole-facing mdBook 79/14,052 KiB, all doctrines,
canonical containment/moved-root proof, RAM 54%, Phase 0 1,031/1,031, and the exact five-backend matrix. Separate
exclusion-freshness plan `.24.0` is signoff-complete after classifying all four records: retain plugin legacy, move
valid future parse-job ownership from superseded `.2` to active `.14`, and schedule removal of satisfied semantic/
cursor records. Schema-v2 disposition/retention/status governance plus 24 mutations was frozen; `.24.0.1-.2`
repair `.2` provenance/ownership and the sole-facing callable 24→25 count before `.24.1-.2` implementation and
closeout. Capability rows stay 80/0/0;
Knowledge Map 783/6,343, sole-facing mdBook 79/14,056 KiB, all doctrines, canonical RAM 52%, and Phase 0
1,031/1,031 in 651 seconds pass.
Pending-owner repair `.24.0.1` is signoff-complete: `.2` truthfully records no-implementation supersession, four
current node/frontier/authority projections align to parent `.14` plus progressive `.14.6` and staged `.14.7`, and
one narrow doctrine rejects pending activation/foreign same-tree commit claims through four fixtures. Capability
stays 80/0/0; Knowledge Map 783/6,345, sole-facing mdBook 79/14,060 KiB, all doctrines, canonical RAM 50%, and
Phase 0 1,031/1,031 in 640 seconds pass.
Sole-facing count repair `.24.0.2` is signoff-complete from clean `094ed840`: project status and independent
governance agree on 25 public documents through 23 mutations, preserving the original 22 targets and all runtime
routes. Five-backend/six-runtime callable proof, capability 80/0/0, Knowledge Map 783/6,345, sole-facing mdBook
79/14,060 KiB with rendered inspection, all doctrines, canonical CLI 66x2, RAM 61%, and Phase 0 1,031/1,031 in
646 seconds pass. Schema-v2 implementation `.24.1` then followed from that clean landing.
Exclusion implementation `.24.1` is signoff-complete from clean `f1cd59d3`: schema v2 keeps plugin legacy under
pending `.6` and parse-job future work under active `.14`, removes satisfied semantic/cursor narratives, and
rejects 24 exact mutations while capability stays 80/0/0. The previously unlabeled 24th class is missing required
`retention_authority`. Knowledge Map 783/6,346, sole-facing mdBook 79/14,068 KiB, all doctrines, canonical CLI
66x2, RAM 52%, and Phase 0 1,031/1,031 in 660 seconds pass. Public closeout `.24.2` then binds 12 governed
projections and ten stale-current denials through six public mutations. Capability exclusion freshness is
public-closed under `FUTURE-PARITY-BACKLOG.24` without manifest, row, runtime, or root README movement. Final
signoff passes Knowledge Map 783/6,348, sole-facing mdBook 79/14,072 KiB with isolated rendered paragraphs, all
doctrines, canonical CLI 66x2, RAM 52%, and Phase 0 1,031/1,031 in 651 seconds.

Closed README-sustainability revision: `README-STABILITY-POLICY` and ADR `0063` make root `README.md` a stable,
bounded landing page. A full 1,615-line / 159,437-byte audit routes all changing/deep detail before a reviewed
105-line / 5,072-byte trim; hard maxima are 128 lines / 6,144 bytes. `.0` is committed at `adcc89fe`; `.1` has
adopted `README_POLICY.md`, the exact trim, and registered enforcement at `ca846e7a`; `.2` recomposes those owners
unchanged under a second canonical gate and closes the original adoption. Director-priority `.4.0` ratifies 62
reader/overflow routes over 20 lifecycle-controlled surfaces, records immutable pressure debt for live status,
task evidence, changes, and engineering notes, opens `LIVE-DOCUMENT-PRESSURE-CONTAINMENT`, and root-causes the
nonexistent `test_input/` layout marker introduced by `ca846e7a`. `.4.1` now implements the local policy revision,
strict registry, unconditional resulting-tree checker, stale-route correction, and 32/32 mutation classes.
Canonical signoff passes CLI 66x2 and Phase 0 1,031/1,031 in 694 seconds before atomic commit and unchanged `.4.2`
closeout. `.4.2` proves seven admitted owner hashes and independently passes CLI 66x2 plus Phase 0 1,031/1,031 in
673 seconds, closing `.4` atomically at `0bcb5a36`. Bounded-view audit `.0` accepts ADR `0066` and lands at
`dc8dd896`. Live migration `.1` transfers all 13 capability consumers to indexed ADR `0067`, preserves the exact
clean 14,872-line source as four immutable manifest segments, installs query plus the eighth doctrine, replaces
the stable root with a five-section bounded current view, and lands at `99fe03f3`. Semantic future-task partition
`.2` now preserves 510 stable IDs across seven mutable semantic parts plus immutable history, installs a strict
nine-record index with root-derived lookup/update tools, transfers all eleven direct machine consumers, and ratchets
task evidence to current bounded limits under 26/26 metadata mutations. Changes/notes hot stores `.3` preserve the
exact clean 44,270-line and 21,308-line sources across eleven/six immutable segments, install bounded roots with
complete-record rollover, and make both pressure checks mandatory under ADR `0069`. Unchanged `.4` independently
recomposes history 34/34, task metadata 26/26 over 510 IDs, rollover recovery 12/12, all eleven consumers, and
routing 20 surfaces / 62 routes / 32/32, closing the program. No parser/runtime/backend/MCP/CLI/fixture/protocol/
`.spec` behavior changes.
Recurring MCP `.10.9.7.1.1.4`
recomposes the committed rooted promotion unchanged and closes its implementation parents; `.10.9.7.2` now
independently recomposes the full chain, closes `.10.9.7` and `.10.9`, and hands the clean boundary to public
semantic/MCP no-drift `.10.10`. The
absence of a project-level license is stated truthfully and tracked
separately in proposed `.3`; nested/vendor terms are not authority to choose one.

Completed critical project-data locality lane: ADR `0053` plus `PROJECT-DATA-SSD-ROOTING` require every project-owned
artifact, cache, package depot, log, and temporary workspace to live on the repository filesystem. Runtime roots
derive from the current checkout; cross-volume reads are limited to explicit caller paths and documented strictly
necessary external tool/OS dependencies. Planning `.0` freezes 67 retained temporary directories/135,756 KiB,
two Dart checkout records, one shared-log LinkedSpec stanza, an initially reported 100 tracked allocation owners,
and 24 executable off-repository defaults. Rust `.2.2` corrects the initial total to 101 and Rust to 17 after
recognizing an imported `env::temp_dir()` spelling. `.1.1` now implements ignored
`/.linkedspec-data/{scratch,cache}`, current-file root
discovery, same-device override validation, standard temp/Cargo/Dart/Julia exports, and hostile outside-cwd proof.
`.1.2` now routes hook/doctrine/Knowledge Map, canonical Perl, four backend, and mdBook entrypoints through the
initializer, with an outside-cwd oracle. `.1.3` now wraps those boundaries in checkout-namespaced,
collision-safe runs with exact cleanup, explicit failure retention, cache preservation, and guarded recovery.
Perl `.2.1` adds the routed standalone primary matrix and a recurring 24-owner `File::Temp`/trace/CLI storage
oracle. Its 65 exact old CLI workspaces were copied to the root-relative SSD cache, verified at 17 files/1,590
bytes plus canonical hash, exercised, and deleted. Rust `.2.2` adds a complete 195-package offline Cargo cache and
proves all 17 temp owners, generated projects, traces, and a copied binary stay on repository storage; no exact old
Rust temp residue exists. Dart `.2.3` adds the complete 47-package offline cache and proves all 18 temporary owners
plus generated and trace paths on repository storage; after successful offline/full-gate use, its two exact shared
checkout records were deleted while ambiguous shared package payload remained untouched. Julia `.2.4` adds a
complete five-package offline depot and 17-owner temp/generated/trace oracle, migrates 88 current durable commands,
and deletes both exact old depots plus the former-checkout shared-log stanza after full-gate use. The shared
developer depot remains untouched and unused; only Julia-managed system depots remain necessary external reads.
Lua `.2.5` roots all 13 allocation owners, both ABI native-module pairs, generated output, traces, primary 66x2,
and corpus 105/105 on repository storage. Its guarded builder rejects other-filesystem output before creation; exact
old Lua workspace residue was zero. Tool leaf `.2.6` is complete across Python, shell, book, Knowledge Map,
conformance, and other tool artifacts: it freezes three Python temporary owners, 13 shell allocators, and 21 Python
tool entrypoints; routes bytecode/map/book/conformance/TAP/oracle output; validates external/symlink rejection;
migrates 177 current command references; and deletes the sole exact disposable old audit list. Both frozen old
roots are zero. Parent `.3.1` is split by reconciliation evidence; migration remains copy/verify/use/delete and
ambiguous shared caches are not deleted wholesale. Reconciliation `.3.1.1` confirms every
frozen off-repository record absent, retires one missed exact same-SSD target-era root after canonical cache and
locked-offline proof, and reruns all six storage oracles. It also establishes the marker-v1 descendant-liveness
RED: a live descendant can outlast recorded wrapper/direct-child PIDs while its run is deleted. Remediation
`.3.1.2` closes that RED with a dedicated marker-v2 process group, whole-group drain and signal forwarding,
double-checked recovery/purge liveness, conservative reuse/indeterminate retention, and normal/orphan descendant
proof. Final residue leaf `.3.2` independently proves both runtime-derived old temporary roots and bounded shared
Dart/Julia metadata are empty before and after all six storage oracles. It has zero deletion targets, retains the
verified Perl/Julia copies, and closes migration parent `.3`. Structural `.4.1` registers the read-only `PROJECT-
DATA-STORAGE` doctrine across current tracked storage/command surfaces. Process `.4.2` extends the boundary to 28
rejected/accepted cases and 38 routed entrypoints, gives Dart a repository-local child HOME, and kernel-contains a
relocated checkout running real Perl/Rust/Dart/Julia/Lua/tool probes from an outside-filesystem cwd. Mutations reject
external writes, shared-cache reads, symlink escapes, incomplete probes, denied-access diagnostics, and Apple
`xcrun_db-` writes. Parent `.4` is complete. Final `.5` passes every backend local gate, primary 660/660, Unicode
10/10, every maintained focused parity matrix, six-runtime scalar numeric 55/55, canonical Phase 0 1,031/1,031,
and a fresh zero-residue pre/post census with exact retained-copy and same-device proof. Post-closeout `.6` repairs
one process-oracle-only discovery error: inherited host `TMPDIR` is captured before SSD routing, preserved across
nested sources, and required to be an existing other-filesystem root; missing or repository-device substitutions
fail. Focused storage proof and canonical Phase 0 1,031/1,031 pass, so the tree is complete at 41/300 without push.

Completed critical repository-relocation lane: ADR `0052` plus `REPO-ROOT-PATH-PORTABILITY` require every persisted
repository-content path to be root-relative and every runtime checkout root to be discovered from the current
script/module/executable or an explicit caller root. Completed audit `.0` is behavior-free: 0 tracked checkout
literals, 0 symlinks, 25/27 self-rooted shell/hook files plus 2 root-independent wrappers, and green outside-cwd Perl/Dart/
Julia/Lua named-spec probes. Rust `.1.1` replaces the exact production RED with current-executable then cwd marker
discovery; its copied-binary moved-root reproduction and complete signoff are green. The eight frozen legacy
config/source owners `.1.2` are complete with relative project defaults, PATH-selected tools, and configured
network command/input ownership. The initial 12 Julia fact-card commands `.1.3` are path-portable; storage leaf
`PROJECT-DATA-SSD-ROOTING.2.4` now routes all 88 current Julia reverify cards through self-rooted managed wrappers
and removes disposable usage metadata containing runtime absolute paths. Ordered remediation `.1.1-.1.3` is complete;
structural doctrine `.2.1` now scans tracked parent text, self-tests 14 reject/accept classes, and locks all five
primary runtime anchors through E3/E4. Closeout `.2.2` is complete: its Rust integration test makes a freshly
copied primary choose a synthetic moved repository over a conflicting ambient cwd and fail when the moved marker
is removed. The composed self-rooted oracle repeats exact named-spec execution for Perl, Dart, Julia, and Lua from
a same-SSD cwd outside the checkout, is canonical-CI registered, and raises current routing to 40 entrypoints
after the recurring six-runtime semantic-introspection gate joined the governed boundary.
The relocation tree is complete. Explicit caller paths and OS/tool data remain valid; project-owned temporary/cache
state must use the repository filesystem.

Semantic-introspection neutral leaf `.10.2` makes ADRs `0049`/`0050` executable before backend behavior.
`linkedspec-semantic-model-v1` / `linkedspec-semantic-query-v1` is one immutable native index of normalized
rules/regex slots/edges/lifecycle, calls/shapes, staged/generated provenance, portable diagnostics/explanations,
and optional caller-captured execution observations. Snapshot-local ids/order, exact pages/logical traversal cost,
source ceilings/redactions, schema evolution, and shared answers are contract behavior. The outward descriptor is
reusable native input, not the wire model. MCP is only capabilities/query over a registered handle and owns no
compile, path, traversal, or explanation semantics. ADR `0054` fixes one exact MCP contract across five native
server implementations and six runtime admissions, with one Lua source shared by PUC Lua and LuaJIT; a future
aggregator is outside `.10.9` and may only route. ADR `0055` selects stable modern MCP `2026-07-28` over stdio:
per-request metadata, mandatory discovery, explicit registered handles, two read-only tools, no legacy
initialization/session/ping, and lowering-only deployment policy. Machine leaf `.10.9.1.1` now pins one neutral
manifest/schema/payload/corpus/JSONL bundle plus its deterministic materializer; `.10.9.1.2` independently checks
28 accepted/seven rejected frames and rejects 68 mutations. No-change `.10.9.1.3` makes ordered materialization
and independent validation unconditional in canonical CI, rejects omission/order drift, and closes the neutral
contract. ADR `0057` and behavior-free Perl audit `.10.9.2.0` freeze a direct in-process server, generated
filesystem-free contract binding, strict duplicate-safe JSON wire, CSPRNG/monotonic handle lifecycle, authorization/
policy seams, and `.1-.4` implementation/admission order. `.10.9.2.1` implements the generated binding,
private schema runtime, secure registry, and decoded dispatch; `.10.9.2.2` now implements strict bounded stdio,
canonical output, pre-emission cancellation, sanitized logging, and EOF/I/O cleanup. Exact unchanged-contract
admission `.10.9.2.3` now composes one twelve-role public-server consumer and a separate implementation/admission
ledger: Perl is complete at 1/5 implementations + 1/6 runtimes, shared rollout remains pending, and 28 mutations
lock transport-digest/topology/authority/canonical order. Focused and canonical proof are green.
Six fixture groups now derive 20 digest-locked responses and
reject 105 mutations; static rule facts cross-check `linkedspec-rule-local-cursor-v1` after correction `.10.3.2.0`
repaired stale default-family and no-edge ownership rows. Generated-plan correction `.10.3.3.0` uses the same
contract's v2 authority to replace stale/illegal calls family `and_acode` with exact `default`. Spec-identity
correction `.10.3.3.1.0` derives exact `calls_and_staging` from caller logical identity. Staged payload/job/result records are explicitly separate
from generated artifacts. Neutral
rollout is 7 complete / 2 pending, backend admission is 6 complete / 0 pending, and `.10.3-.10.10` split all
backends/ABIs, recurring, MCP, and public rollout. Perl authority audit `.10.3.0` maps strict source/canonical
bytes, descriptor, typed ActionIR, staged/failure/generated inputs, missing source mapping, and missing typed event
capture. `.10.3.1` implements opaque strict source/map/compiled-or-failed construction without path reads or
execution. Corrected projection `.10.3.2.1` retains exact private static records/relations for graph, privacy,
failure, and runtime-static targets. Corrected calls/staging leaf `.10.3.3.1.1` privately matches all 22 records/
25 relations with typed source-preorder calls, explicit staged roles, and a shared generated-v2 family owner.
Query leaf `.10.3.4` exposes immutable Perl capabilities/query and matches all 19 static canonical digests;
`.10.3.5-.10.3.6` retain observations/routes and exact Perl admission.

Duplicate-slot audit `.9.1.8.1.0` is clean without behavior changes. Exact six-runtime ordered/choice
and repeated/control evidence isolates Perl/Rust combined-alternation slot aliasing while structural identity
survives every compiled/descriptor/generated artifact. Neutral `.1` adopts ADR `0047` and executable
`linkedspec-duplicate-regex-slot-identity-v1`: required-slot ordered matching, earliest/first-authored choice,
repeated reset, two typed invariants, and unchanged generated-source v2. Governance is 5 fixtures / 2 diagnostics /
6 runtime rows. Perl `.2` now directly matches required compiled rows, preserves first-authored choice, embeds
generated-v2 slot payload without plan widening, and passes one 12-role consumer. Rust `.3` now directly matches
required compiled slots in ordinary/generated-plan execution, preserves combined choice, validates malformed
compiled identity across artifact/runtime routes, and passes one exact 15-role consumer. Dart `.4` now uses a
direct authored-alternative matcher instead of recompiling one pattern and rewriting its index; compiler/runtime/
descriptor/emitter validation, trace identity, generated-v2 reconstruction, and one exact 15-role consumer pass.
Julia `.5` now directly matches authored alternatives, validates structural identity across compiler/runtime/
generated boundaries, publishes descriptor/emitted/trace identity, and passes the same exact 15-role shape.
Dual-ABI Lua `.6` applies the same mechanism through one shared PUC Lua/LuaJIT consumer. Final `.7` composes all
six runtime legs plus selected primary/support proof in `tools/check_duplicate_regex_slot_identity_five_backend.sh`.
Duplicate-slot rollout is closed at 7 complete / 0 pending with 59 mutations.

Root-selection contract (ADR `0046`, 2026-07-18): an explicit selector, including primary-command
`--top-rule NAME`, may name any declared rule and wins over authored markers. Without one, the first authored
`Rule::` wins; without any `::`, the first authored ordinary `Rule:` wins. Subtree
`FUTURE-PARITY-BACKLOG.9.1.1.2` owns the rollout. Executable neutral contract `.0`, composed Perl, Rust, Dart,
Julia, and dual-ABI Lua `.1-.5`, and recurring/public admission `.6` are complete. Root-selection rollout is closed
at 7 complete / 0 pending with 54 rejected mutations. Both roadmap projections are required checker inputs, and
`bash tools/check_root_rule_selection_five_backend.sh` owns the exact six-runtime plus 5x2x6 recurring proof.
Root-selection rollout is closed at 7 complete / 0 pending.
Canonical signoff passes primary 65/65x2 and Phase 0 1,031/1,031 in 642 seconds.
Julia's separate cursor and root 15-role
admissions pass package 3,428, primary 65/65x2, corpus 105, and canonical Phase 0 1,031/1,031; its authored
selection fixtures use entry lifecycle `I` to prove entry. Behavior-free Lua preflight `.5.0` proves identical
PUC Lua/LuaJIT boundaries: all four default/POSIX primary legs are 31/65, with one root-owned markerless failure,
22 cursor-owned help/usage failures, and 11 cursor-owned request-trace failures. Each ABI passes 176 package
groups plus the one cursor help mismatch and corpus 105/105. The frozen order is root core `.5.1`, composed
loaded/reconstructed/generated-v1/emitted/trace/diagnostic routes `.5.2`, cursor `.9.1.7`, then exact dual-ABI
15-role admission `.5.3`. That admission is now green from one shared source: exact topology RED 3/3x2 becomes
139/139x2, package is 177/177x2, primary is 65/65x4, corpus is 105/105x2, and canonical Phase 0 is 1,031/1,031
in 641 seconds. Final composed public no-drift `.6` is now complete: its 25-document contract, 19 stale-claim
guards, six-runtime recurring driver, 5x2x6 selected primary proof, and 54 mutations close the public boundary.
Lua core `.5.1` is now implemented identically on PUC Lua and LuaJIT: marker-optional one-or-more-rule validation,
one pre-effect compiled-state resolver, portable zero/unknown failures, authored-edge-only strict analysis, and
immutable descriptor identity pass 99 focused assertions per ABI. All four default/POSIX primary legs move by
only the root-owned row to 32/65; package is 176/177 with the cursor-help mismatch and corpus is 105/105 per ABI.
Composed route `.5.2` now passes 101 assertions per ABI over loaded/normalized, generated-v1/emitted direct/traced,
portable wrapper failures, low trace, and plan-first ordering while retaining contract v1/format 1 plus the
minimal label/family plan. Its canonical closeout passes root 7+5, cursor 288, primary 65x2, and Phase 0
1,031/1,031 in 643 seconds. Cursor `.9.1.7`, root admission `.5.3`, and final no-drift `.6` are complete, so
root-selection rollout is 7 complete / 0 pending.
Clean route commit `c3bdca44` activates behavior-free cursor preflight `.9.1.7.0`; implementation and dual-ABI
admission are split dependency-safely across `.9.1.7.1-.6`.
Typed normalization `.1` now passes 258/258 assertions on both PUC Lua and LuaJIT after an identical 44/166 RED
baseline. All 36 authored families, 18 edge rows, six ownership sets, typed JSON/provenance, portable diagnostics,
and compiled ownership are exact. Package remains 176/177x2, primary 32/65x4, corpus 105/105x2, and normalization
governance was 67/5+3/44 because runtime/artifact/public behavior and rollout remained `.2-.6`.
Clean normalization commit `67909eb6` activates intrinsic live/loaded/normalized/recursive/traced runtime `.2`
task-tree-first. Its identical 44/110 RED now passes 110/110 per ABI: every normal entry derives AND-consume/
sequence or OR-default-seek/choice, every child rederives, and all eight mixed mechanisms plus both structural
rows are exact. Explicit outer policy and generated-v1 historical seek/family behavior remain isolated until
`.5` and `.4`; its registered consumer makes current inventory 68/5+3/44, while descriptor/generated/public/
admission owners remain `.3-.6`. Clean runtime commit `d4b910e8` activates descriptor v1 `.3` task-tree-first.
Descriptor `.3` now replaces root global mode with cursor-contract v1 and projects normalized per-rule family,
policy, ownership, and ordered semantic edges. Identical 364/776 RED becomes 875/875 green per ABI; direct,
normalized, and loaded bytes agree; seven focused consumers total 1,921 assertions per ABI. Package, primary,
corpus, governance, and rollout stay staged, so generated v2, option removal, and admission remain `.4-.6`.
KM 629/4,611, mdBook/four doctrines, and canonical Phase 0 1,031/1,031 in 621 seconds pass. Clean descriptor commit
`79422858` activates generated-source v2 `.4` task-tree-first. New Lua modules now use v2/format 2 and the unchanged
minimal ordered label/family plan; generated execution derives the exact five-seek/five-consume split, compact
Pipe is OR/choice, and stale v1 fails before payload reconstruction. Identical 44/106 RED is 106/106 green on both
ABIs; eight focused consumers total 2,027 assertions per ABI. Package remains 176/177x2 only at staged help,
primary remains 32/65x4, corpus 105/105x2, and governance is 69/5+3/44. KM 630/4,622, mdBook/four doctrines, and
canonical Phase 0 1,031/1,031 in 644 seconds pass; safe generated artifacts are removed. Public removal/admission
remain `.5-.6`.
Clean generated-v2 commit `d472c136` activates Lua public/global cursor option removal `.5` task-tree-first.
Option removal is now implemented on both ABIs. Exact focused proof moves from 75/96 RED to 96/96; engine, parse,
loaded, corpus, generated, primary-help, and request-trace ownership are removed; legacy keys and the retired flag
receive targeted migration diagnostics; and `--top-rule` remains higher priority than authored `Rule::`. Package
passes 177/177x2, primary 65/65x4, corpus 105/105x2, and governance 68/5+3/44. Canonical signoff now passes
through Phase 0 1,031/1,031 in 646 seconds and safe cleanup passes at clean commit `e96d389e`. Exact dual-ABI
15-role admission `.6` then activated task-tree-first and is now signoff-complete.
That admission now passes 119/119 on both ABIs after exact 3/3 pre-contract RED. One consumer composes all 15
declared roles without a semantic implementation fork; package 177/177x2, primary 65/65x4, corpus 105/105x2,
and governance 69/6+2/49 pass. Canonical Phase 0 is 1,031/1,031 in 647 seconds. Clean cursor commit `7dd70a2d`
activates `.9.1.1.2.5.3` task-tree-first.

This file exists to make the active plan easier to follow without replacing the fuller historical and architectural roadmap in `ROADMAP.md`.

## Purpose
- Keep a concise execution view of what we are doing now.
- Keep the live four-level tracker easy to inspect.
- Make the active policy contracts explicit enough that future slices do not drift.

## Operating Rules
- Status levels are limited to:
  - `done`
  - `mostly done`
  - `in progress`
  - `not started`
- Execution is dependency-first by default, not strict waterfall by phase number.
- If strict phase-by-phase execution is desired, it must be requested explicitly.
- Before every commit, update the tracker if the completed slice materially changes what is done, what is left, or which area is active.
- In commit close-outs:
  - show changed tracker rows when a level changes,
  - otherwise show only the tracker rows affected by the slice,
  - show the full tracker only when explicitly requested.

## Core Policy Contracts
- `.spec` authoring is intended to become permanently raw-Perl-free.
- Raw Perl inside `.spec` is obsolete compatibility debt, not an acceptable long-term authoring surface.
- Remaining raw Perl occurrences in `.spec` should be flagged loudly and migrated to canonical method-like DSL equivalents.
- Descriptor migration metadata should also surface compatibility-shaped ready rules separately, so “ready” never hides older Perl-shaped syntax or legacy helper wrappers that still need migration.
- Staged linked parsing is a core, implementation-language-neutral architecture:
  a stage may emit source-provenance text islands as parse jobs, and later `.spec`
  parsers may refine those payloads into deeper AST through a deterministic parse
  graph. This is separate from spec-file import/composition. All staged syntax,
  AST metadata, dispatch/cache identity, diagnostics, fixtures, and docs must be
  specified as `.spec`/AST contracts; backend mechanics are adapters only.
- Typical `.spec` authoring keeps regexes small and readable: zero-regex coordination,
  one-regex leaves, and two-regex entry/exit nodes are the common structural roles;
  recursion belongs in linked action-edge OR and blind-call AND rule graphs. Progressive
  in-parse composition over cursor-relative extracted text is distinct from later
  returned-AST staged enrichment. ADR `0056` adds one accepted immutable source-location
  algebra: Unicode-scalar positions, half-open spans, provenance, bounded effect-safe
  cursor transactions, recursive boundaries, progress checks, and span-native parser
  dispatch. Existing helpers project that core; gap syntax/lifecycle stays separately
  owned by ADR `0045`. `FUTURE-PARITY-BACKLOG.14.1-.14.8` owns complete contract,
  implementation, admission, documentation, and proof beyond the current narrow
  function-body prototype.
- Documentation is a product contract:
  - optimize for readability,
  - remove ambiguity directly,
  - explain semantics plainly,
  - use representative examples when they help,
  - add thorough worked examples for every newly landed user-facing surface,
  - hold older already-landed DSL methods to that same bar and backfill thin documentation when needed for adoption,
  - treat documented examples as part of the end-user contract we should not casually weaken,
  - do not intentionally obfuscate behavior or tradeoffs,
  - maintain `ARCHITECTURE_STATE.md` as the live architecture snapshot and refresh it when a new deep reading changes the best current model of the project.

## Lifecycle-Wide Structured DSL Contract
Semicolon-light structured authoring is intended to apply across the full lifecycle family:
- `I`
- `LS`
- `LE`
- `E`
- `EX`
- `IT`
- `LX`

Current regression anchors are `I { ... }` and `LX { ... }`, but those are only proof points. They are not the intended limit of the policy. If semicolon-light structured authoring applies to one lifecycle block family, it should apply to the others too unless an explicit documented exception is introduced.

## Spec-Authoring Quality Contract

ADR `0035` and `FUTURE-PARITY-BACKLOG.18.1` make terse, readable, and highly expressive authoring one hard
constraint for future `.spec` evolution. Terseness removes redundant ceremony rather than meaning; readability
keeps structure, value flow, mutation, scope, recovery, and diagnostics locally predictable; expressiveness comes
from small typed orthogonal mechanisms instead of format-specific or host-language escape hatches. Uniform binding
is the positive precedent. Recursive traversal retains `walk_leaves` / `map_leaves` / `reduce_leaves`, because
their suffix distinguishes leaf recursion from conventional shallow operations; no short aliases are planned.

ADR `0037` / `FUTURE-PARITY-BACKLOG.18.2` make correlated construction/runtime observability another future
format-readiness constraint. Existing levels and sinks remain; exact rule-label filters affect emission only,
high-volume payloads are bounded/redactable, and `STRUCTURED-TEXT-FORMAT-PROGRAM.2.7` owns the shared
five-backend/two-Lua-ABI traced/untraced proof after current parity. Lua full-pipeline trace is complete under
`.5.3.2`; census-preserving no-drift `.5.3.3` closes parents `.5.3`/`.5` before the shared proof.

ADR `0038` / `FUTURE-PARITY-BACKLOG.18.3` govern a separate optional native-acceleration horizon. Only after a
realistic dynamic format parser is correct and measured may a backend derive a fingerprinted artifact from
normalized compiled `.spec` state. Exact semantic/Unicode/diagnostic/recovery/trace equivalence and objective
build/load/break-even benefit are mandatory; the dynamic parser stays primary/oracle/fallback, the horizon does
not block the 91-format program, and Perl acceleration is not required.

ADR `0039` / `FUTURE-PARITY-BACKLOG.20.0` adopt Rust `cargo-mutants` as an explicit on-demand or milestone/
release test-strength campaign. Mutation execution is forbidden in per-commit, pre-commit, and ordinary-local-CI
paths. The list-only baseline is 3,333 candidates across 19 files; targeted pilots precede any resource-guarded
sharded breadth, survivor dispositions matter more than a raw score, and no mutant has yet executed.

ADR `0036` / `FUTURE-PARITY-BACKLOG.19` own the separate future mutation direction after complete current-backend
parity. Nested writes may create a missing root/intermediate only when the next evaluated segment unambiguously
selects array or harray; reads remain pure, existing wrong-kind values are not coerced, and arrays do not gain
implicit null-filled gaps. `map_leaves!` is the sole v1 bang candidate: it atomically rebinds a bare named receiver
after successful original-shape/root-kind traversal and returns the updated value. Callback `path` remains the
complete stable receiver-root-relative path and `value` is not an alias. Other bang spellings remain excluded.

Lua diagnostic output `.4.3.8` is also complete: an optional per-parse caller sink receives typed ordered Unicode
events, default execution stays quiet and parse-result neutral, `exit_now` remains immediate, and both Lua ABIs
pass 122/122. Exhaustive helper no-drift `.4.3.9` has since closed. The audit found pre-existing Perl/Rust/Dart/
Julia transport and formatting drift; Lua `.8.4` satisfies its parity dependency. Planning `.5.1.0` now proves
that arity, evaluation, scalar formatting, transport, and host process control need separate ownership. It splits
neutral contract `.5.1.1`, five native leaves `.2-.6`, generated/CLI `.7`, symmetric gate `.8`, and no-drift `.9`.
Neutral policy, all five native event seams, generated/primary `.5.1.7`, recurring symmetric gate `.5.1.8`, and
public no-drift `.5.1.9` are complete at 8 complete / 0 pending. Every emitted direct/traced role exposes an
idiomatic optional or paired sink without changing legacy signatures, all five primary commands remain quiet
under the shared 63-case default/POSIX matrix, and one strict driver composes all six native/generated consumers
plus capability/generated-source/corpus ledgers. Sixteen authoritative documents, nine forbidden stale claims,
and 20 drift mutations lock the public contract. Parent `.5.1` is closed; logical audit `.5.2.0` is complete. It
separates lazy condition-only Perl lowering and broken direct values, Dart short-circuiting, eager Rust/Julia/Lua,
and three truthiness profiles before neutral/backend/generated/gate/public leaves `.5.2.1-.9` change behavior;
neutral `.5.2.1` now adopts ADR `0043` and executable `linkedspec-logical-helper-v1`. Its eager arity/effect,
typed truthiness, receiver/lazy-control, fixture, projection, and 26-mutation proof passes with all eight rollout
legs initially pending. Perl `.5.2.2` now consumes the contract through typed ActionIR/runtime lowering and moves
the ledger to 1/7. Rust `.5.2.3` aligns its shared truth seam and pre-effect arity; Dart `.5.2.4` removes helper
short-circuit drift; Julia `.5.2.5` preserves eager `_runtime_truthy` composition while rejecting all four invalid
arities before effects across native, normalized, generated-plan, compiled-emitted, and primary roles. Every available direct/traced generated role now
preserves the neutral values, eager effects, typed failures, and source attribution; Rust's compatibility pair
retains its established output-array signature while typed v1 returns the direct value. Shared case
`success_logical_helpers_eager` passes all five commands under default and POSIX options. One strict recurring
driver now locks the neutral checker, exact native/generated roles for six runtime consumers, selected 5x2x1
projection, three support ledgers, and canonical opt-in registration. Public `.5.2.9` locks 20 authoritative
documents, 13 forbidden current claims, and public topology mutations; the ledger is 8 complete / 0 pending and
parent `.5.2` is done.
Director-priority cursor-ownership audit `.9.1.0`
rejects public/global `parse_mode`, recommends
intrinsic OR/default seek and AND consume, and exposes default-AND parity drift. Director capture `.9.1.1.0`
confirms that parent mode never propagates to or overrides a child. ADR `0044` / `.9.1.1.1` now ratifies exact
mode-sensitive bare edges, explicit cross-family legality, removal diagnostics, per-rule descriptor facts,
generated-source v2 family derivation, and conformance. Implementation is split under `.9.1.2-.9`; generated/
primary logical projection `.5.2.7`, recurring logical gate `.5.2.8`, and public no-drift `.5.2.9` are complete;
neutral cursor `.9.1.2` is verified with an executable 36-family/18-edge/8-parent-child contract, a token-derived
migration inventory and 27 drift mutations. Perl `.9.1.3` is split into
`.0-.6`; verified gate-safety preflight `.9.1.3.0` maps exact implementation
seams and assigns ten shared reference byte fixtures to `.9.1.3.5` because their removal affects 35 canonical
cases. Normalization `.9.1.3.1` implements typed complete-line candidates, forward-declaration resolution,
family-derived action/blind ownership, reserved lifecycle precedence, per-rule cursor facts, and portable
diagnostics. Live slice `.9.1.3.2` makes normal Perl rules spend those policies independently. Descriptor
projection `.9.1.3.3` now publishes the v1 cursor identity, removes root global-mode metadata, projects ordered
resolved-edge facts, and proves live/descriptor agreement. Generated-source `.9.1.3.4` now emits and validates
Perl v2 from the exact ten-family/five-seek/five-consume map, rejects v1 reconstruction with mandatory `.spec`
regeneration, and makes transitional option values source-byte neutral. API/CLI `.9.1.3.5` now rejects both dynamic
legacy spellings during option preparation, removes the primary flag/help/request field with exact usage exit 2,
and keeps the reference matrix at 63x2 through structural default-seek/AND-consume cases. The token-derived
migration inventory is 72 after sixteen completed Perl test/fixture paths become token-free and
`GeneratedSource.pm` gains the emitter-removal envelope. Composed admission `.9.1.3.6` now requires 14 exact
live/descriptor/emitted/generated/loaded/trace/diagnostic/recursive/structural/primary roles, registers that
consumer in canonical CI, rejects 29 total drift mutations, and advances only `perl_reference` to complete. The
cursor rollout reached 2 complete / 6 pending at a 72-file Perl-admission inventory; Rust gate hardening `.9.1.4.1` is
committed. Verified normalization `.9.1.4.2` now retains typed bare edges, derives family ownership, and emits exact
portable diagnostics. Verified live execution `.9.1.4.3` now derives policy from every entered rule through
live/loaded/ordinary reconstructed paths and removes mutable compiled policy. Verified descriptor `.9.1.4.4` now
publishes cursor v1 family/policy/resolved-edge facts without root/rule global fields and agrees across direct,
loaded, reconstructed, and live paths. Generated-source `.5` now emits v2/format 2 with only ordered label/family
rows, derives all ten family policies, rejects v1 reconstruction, and passes the exhaustive classifier. Public
override projection is removed in implemented `.6`: execution options retain entry selection only, the primary
flag returns the targeted usage error, request traces omit the global field, and Rust passes the exact 63-case
matrix in both environments. Focused and canonical signoff pass at commit `2bba1e91`; composed admission/parent
closeout `.7` now composes 15 exact Rust roles, requires canonical registration, retains the 68-file inventory,
rejects 34 mutations, and advances only `rust_parity` to reach 3/5. Complete Rust and canonical proof pass at clean
commit `288da21a`; parent `.9.1.4` is closed. Dart preflight `.9.1.5.0` fixes the exact current boundary and
dependency-ordered `.1-.6` implementation split without executable changes; focused proof is 104/104 plus corpus
105/105, and the staged reference-migration boundary is 244/1 package plus 30/63 primary twice.
Dart normalization `.9.1.5.1` now classifies compact `|` as OR, retains complete-line/header-rest bare references
as typed AST, derives and validates family-owned action/blind edges, lowers them into compiled dispatch tables,
and exposes the portable diagnostic envelope. Dart execution `.9.1.5.2` removes the compiled legacy adapter and
derives cursor plus sequence/choice policy independently at every normal live, loaded, normalized-JSON, nested,
recursive, and traced rule entry. Descriptor `.3` is now implemented: root metadata identifies
`linkedspec-rule-local-cursor-v1`, every rule projects family/policy/ownership/ordered semantic edges, and direct,
normalized-JSON, and loaded projections agree. Generated v1 retained its bounded compatibility behavior through
`.3`; `.4` is now implemented and emits v2/format 2 with cursor-free ordered label/family rows, derives policy and
structure from all ten families, rejects v1 exactly, and passes fresh-host/direct/trace/family/subset proof. Public
option/CLI `.5` now removes every Dart caller-owned global override, omits the help/request-trace field, returns the
targeted retired-flag error, and passes 260 package tests plus exact primary 63x2 and corpus 105/105. The governed
inventory reaches 67 files with 39 effective mutations. Composed admission `.6` locks one exact 15-role consumer,
advances only Dart to 4/4, and closes `.9.1.5`; Julia follows its clean commit.
Behavior-free duplicate-slot audit `.9.1.8.1.0` proved compiled/artifact identity survives while its pre-repair
ordered baseline diverged: Perl/Rust combined alternations aliased a later identical slot to the first and returned null;
Dart/Julia/dual-ABI Lua match the required slot directly; all six runtime legs make duplicate OR first-authored.
Neutral decision `.1`, Perl/Rust repairs `.2-.3`, preserving-backend locks `.4-.6`, and recurring/public
admission `.7` are complete before public cursor closeout.

The first exhaustive `.4.3.9.0` pass now measures every admitted Lua name: 230 reach an owner, thirteen are
intentional statement/receiver-only forms, and eager `and`/`or`/`not` are the exact missing family. `.4.3.9.1`
repairs that family; `.2` closes recurring ownership/status/direct-call admission. Perl `and`/`or` keyword
lowering and the existing five-backend logical truthiness/arity drift are explicitly gated under
`FUTURE-PARITY-BACKLOG.5.2` rather than being hidden by the Lua-local repair.

Lua `.4.3.9.1` first closes that local three-name gap at 123/123 on PUC Lua and LuaJIT: all logical arguments are
eager and ordered, results are booleans, empty calls are false/false/true, and established Lua truthiness is reused.
Exact `.4.3.9.2` then accounts for all 246 names as 233 function-form owners plus thirteen documented structural/
receiver-only forms, focuses direct `call(rule)`, and publishes `runtime-helper-value-control`. Both ABIs pass
125/125; parent `.4.3` closes and diagnostics/trace `.4.4` activates. `.5.2` still owns global
truthiness, arity, Dart evaluation/empty-`and`, and Perl lowering normalization.

Planning-only `.4.4.0` now resolves the diagnostics/trace dependency order. `.4.4.1-.4` own structured runtime
failures, controls/sinks, interpreter events, and runtime no-drift; `.4.4.1-.4` are done, parent `.4.4` is closed,
and planning `.5.1.0` splits staged dispatch, fixed/variadic runtime, contextual-codeblock metadata/runtime, and
closeout. Minimal staged dispatch `.5.1.1` passes 130/130; fixed-v1 runtime `.5.1.2` passes 133/133. Variadic-v2
state `.5.1.3.1` preserves exact signature state and minimum/unbounded registry resolution at 136/136. Fresh
rest-array runtime `.5.1.3.2` executes the unchanged neutral fixture and locks copied mixed/empty values, eager
order, receiver chains, and typed failures at 139/139 with status `runtime-user-functions-variadic-v2`. Exact
final-codeblock metadata/normalization `.5.1.4.1` passes 142/142, and contextual dynamic execution `.5.1.4.2`
passes 146/146 with status `runtime-user-functions-contextual-codeblock-v1`; no-drift `.5.1.5` closes parent
`.5.1` without behavior change and activates native loading `.5.2`. Portable resolution/loading `.5.2.1` adds
typed requests/options/results/errors, deterministic direct candidate selection, in-process byte loading, and
strict UTF-8 preservation and consumes all shared 14/9/4 cases. Automatic spec-defined function parsing `.5.2.2`
then resolves the bundled grammar module-relatively, validates/compiles it once, executes it in process, and
composes typed output without a raw scanner. Both Lua ABIs pass 151/151 with status
`native-spec-defined-functions-v1`. Full loaded-source `.5.2.3` now retains exact identity/source/compiled state,
maps neutral parse/validate/compile failures, and builds named/path-attributed engines at 153/153 with status
`native-spec-pipeline-v1`; no-drift `.5.2.4` closes parent `.5.2` without behavior change. Planning `.5.3.0`
then audits and splits the exact descriptor/full-trace/admission boundary. Fixed-v1 and variadic-v2 outward shapes
are governed; final-codeblock `parameter_kinds` lacked a neutral outward record shape; and original immediate-census
wording conflicted with the newer completion-time Lua admission policy. Decision `.5.3.0.1` and ADR `0041` adopt
exact final-codeblock descriptor v3 over fixed `params`/`arity` plus final-only `parameter_kinds`, keep the census
at four all-pass backends through `.5.3-.7`, and reserve expansion for all-pass `.8.4`. Executable descriptor
contract/emission `.5.3.1` now locks and emits fixed-v1/variadic-v2/final-codeblock-v3 records on both Lua ABIs,
with Perl's existing final-codeblock projection aligned to outward v3. One-emitter pipeline trace `.5.3.2` now
crosses native IO, frontend/compiler/function/staged phases, engine construction, and runtime at 155/155 on both
ABIs with status `native-full-pipeline-trace-v1`. Census-preserving `.5.3.3` closes parents `.5.3`/`.5` without
behavior or census change. Controlled/core planning `.6.1.0` measured exact offsets 0-39 and 99-104 at 45/46 on
both ABIs. Typed nested-path repair `.6.1.1` closes unchanged offset 20 and both windows at 46/46, with focused
suites at 157/157. Library execution `.6.1.2` adds strict selection, automatic full native composition, exact
wrapped comparison, and typed non-aborting proof records at 160/160 per ABI. Core admission `.6.1.3` permanently
locks exact offsets 0-39 at 40/40 with endpoint 1/1 and focused suites at 161/161 on both ABIs.
Governed admission `.6.1.4` permanently locks exact offsets 99-104 at 6/6 with endpoints `2,1,2,1,5,5` and
focused suites at 162/162 on both ABIs. Parent `.6.1` closes, offsets 40-98 `.6.2` activate, and capability remains
four-backend 64/0/0 until `.8.4`, which now admits Lua all-pass.
ADR `0040` separately adopts one normative neutral mdBook plus five linked backend implementation companions.
`BACKEND-COMPANION-BOOKS.1+` starts with a read-only content inventory only after current backend parity; shared
build/navigation/canonical-owner/drift gates precede any migration. No companion scaffold exists yet.
One-emitter native loading, frontend, compiler, function-shell, staged, engine, and runtime propagation is complete
under `.5.3.2`; `.5.3.3` closes exact no-drift without changing the capability census. Corpus planning `.6.1.0`
and typed segment-kind repair `.6.1.1`, reusable library executor `.6.1.2`, and ordered core window `.6.1.3` are
complete; governed capability/no-drift `.6.1.4` closes parent `.6.1`. Advanced/shipped planning `.6.2.0` measures
offsets 40-98 identically at 50/59 on both Lua ABIs and splits four current mechanisms before runtime changes:
action-edge child-call reuse `.6.2.1`, receiver copy `.6.2.2`, flat-array hash splicing `.6.2.3`, and public
leading-trivia initialization `.6.2.4`; `.6.2.5` remeasures successor residuals before `.6.2.6` permanent 59-case
admission. `.6.2.1` now caches the matching current-edge call once, skips passive-terminal re-search, preserves
unrelated calls, and closes all three HLink, both EBNF, and SimEnv cases unchanged. Both ABI suites pass 163/163
and the exact window is 56/59. Receiver-copy `.6.2.2` now deep-copies the already evaluated fluent value once,
preserves typed continuations, closes the exact hash-receiver fixture, and raises both ABIs to 164/164 with the
window at 57/59. Flat-array hash splicing `.6.2.3` now consumes direct/receiver `flat_array(...)` values as ordered
hash pairs, closes unchanged `pplugin_empty`, and raises the window to 58/59. Public leading-trivia initialization
`.6.2.4` now mirrors complete leading blank/`#` comment lines through the cursor/register seam, preserves ordinary
indexed reads, closes unchanged history, and raises both ABIs to 59/59. Successor remeasurement `.6.2.5`
independently validates the full 105-case manifest and confirms exact offsets 40-98 at 59/59 with zero failures on
both ABIs. Permanent `.6.2.6` locks all 59 literal names, unchanged wrapped outputs, matches, and exact endpoints
at 166/166 per ABI. Complete-manifest `.6.3` then passes one ordered 105/105 library gate and bare developer-runner
`--execute`, preserves validation-only default use plus exact 0/1/2 outcomes, and advances public status to
`runtime-corpus-full` at 167/167 per ABI. Parent `.6` closes. Primary adapter `.7.1` now implements exact ADR
`0023` options, strict UTF-8/native execution/canonical JSON, stable failures/exits, and canonical phase trace at
169/169 per ABI plus diagnostic shared CLI 61x2. Admission `.7.2` now makes both Lua process legs recurring and
extends the warmed shared matrix to 5x2x61. Public status is `runtime-corpus-primary-cli`; final no-drift `.7.3`
closes parent `.7`. Generated-source planning `.8.1.0` then corrects the pre-ADR-0041 v1/v2-only scope. Emitter
core `.8.1.1` now returns deterministic native Lua from exact fixed-v1/variadic-v2/final-codeblock-v3 effective
state, with contract/version/Unicode identity metadata, typed portable errors, direct/traced roles, and canonical
strict-UTF-8 JSON embedded as ASCII hex. Fresh-process PUC Lua/LuaJIT valid/corrupt load/run/cleanup proof `.8.1.2`
closes scaffold `.8.1` at 173/173 per ABI. Exact plan/family execution `.8.2` closes at 176/176 per ABI with ten
ordered families, four rejections, authoritative nested dispatch, portable trace, an isolated all-family host,
and emitted variadic proof. Contract-sourced `.8.3` closes at 177/177 per ABI with exact ordered interpreter-first
8/105 fresh-host modules, metadata/plans/trace identity, fixed user-function execution, and cleanup. Sole census
admission and backend handoff `.8.4` are complete at five-backend 80/0/0.

Lua `.4.4.1` now carries neutral `RuntimeDiagnostic` values on typed runtime exceptions. Optional source identity,
top/deepest-rule/handler attribution, specific selection/input/lookup/execution stages, deterministic JSON, richer
child-payload preservation, unchanged text, and unchanged successful parse results pass 126/126 on both ABIs.
Lua `.4.4.2` now adds typed ordered levels/config/events, documented environment controls, caller-owned
stdout/route/mirror sinks with reset/append, and result-neutral direct/config-wrapper parse scopes. Both ABIs pass
128/128. Rule/regex/dispatch/recursion/lifecycle/cursor/boundary/mark-capture events pass 129/129. Minimal staged
dispatch `.5.1.1` adds the governed provider/queue/cache/stitch path at 130/130. Public status is
`runtime-user-functions-variadic-v2` after `.5.1.2` adds registry-first fixed calls, copied fresh stores,
local returns, returned-value composition, and typed function-owned fences at 133/133, then `.5.1.3.1` preserves
the exact fixed-v1/variadic-v2 union and minimum/unbounded resolution at 136/136, then `.5.1.3.2` executes fresh
typed rest arrays at 139/139. `.5.1.4.1` preserves final metadata and normalization at 142/142; `.5.1.4.2`
executes contextual blocks at 146/146; `.5.1.5` closes the parent; `.5.2.0` splits native loading; `.5.2.1`
implements portable resolve/load, `.5.2.2` automates the cached spec-owned function parser at 151/151, `.5.2.3`
composes loaded functions and source identity at 153/153, and `.5.2.4` closes parent `.5.2`; `.5.3` was next and
capability remained 64/0/0 at that boundary. `.5.3`, corpus `.6`, primary CLI `.7`, generated source `.8.1-.8.3`,
and final admission `.8.4` have since closed; Lua is the fifth exact backend and the current census is 80/0/0.

## Current Live Tracker

Dart semantic static projection is exact across all five private construction targets. `.10.5.2.1` owns the
compiled graph/source/evidence and `.10.5.2.2` owns both privacy ceilings, projection-only failure normalization,
runtime-static absence semantics, and clone/host isolation with no public query or runtime surface. `.10.5.2.3`
composition-closes the parent after repair child `.10.5.2.3.0` serialized concurrent untracked-selector probes
outside Dart formatter traversal. Behavior-free calls audit `.10.5.3.0` freezes the 22/25 authority map and split;
typed core `.10.5.3.1` now deep-equals the neutral 18/16 non-staged subset with exact authored order, nested calls,
bindings, resolution, Unicode source evidence, and conservative shapes. Exact completion `.10.5.3.2` maps native
payload/job/result sidecars plus the retained selected generated-v2 row into distinct provenance records and now
deep-equals the complete private 22/25 target. Documentation-only closeout `.10.5.3.3` passes composed 22/22 plus
complete Dart/public/canonical signoff and closes the parent. Behavior-free query audit `.10.5.4.0` freezes 19
static digests, 26 neutral validation boundaries, fresh detached-projection authority, and the `.1-.4` split.
Typed record/source kernel `.10.5.4.1` now matches nine exact static responses through immutable owned values and
package-private capabilities/list/get/explain/source privacy. Traversal/limits `.10.5.4.2` adds directional
breadth-first relations, canonical pages, logical budgets/costs, deterministic prefixes, and all 16 successful
static digests. Public `.10.5.4.3` exposes `capabilities`, typed `query`, and raw-neutral `queryNeutral` through one
detached evaluator at all 19 static digests and 26 validation boundaries. Closeout `.4` now composition-closes the
query parent. Runtime audit `.10.5.5.0` freezes exact post-match slot and successful final-result capture,
absent-sink/no-query authority, generated-wrapper exception identity, immutable derivation, and the `.1-.4`
dependency order. Typed live capture `.1` now exports exact immutable events and an optional invocation-local sink
across direct/loaded/reconstructed/traced/generated-plan engine routes with unchanged results, cursors, traces,
diagnostics, and failure identity. Immutable observed-index derivation `.2` now returns a separate topology-
validated canonical snapshot at the twentieth digest. Generated/emitted direct and traced propagation `.3` now
preserves exact observations, outputs, trace bytes, exit omission, and caller callback identity without changing
generated-source v2/format 2. Composition-only closeout `.4` now closes the runtime-observation parent on committed
code while rollout/admission stay 3/9 and 2/6. Exact composed admission `.10.5.6` now runs one ordered 12-role
Dart consumer across strict source, compiled/failed/runtime snapshots, loaded and JSON-reconstructed state,
generated-plan/public-helper/standalone-emitted direct and traced execution, native/neutral JSON, all 20 digests,
bounded query behavior, immutability, and host-leak denial. Eight Dart-specific topology mutations advance only
Dart to 6/20/81, rollout 4/9, and native admission 3/6; parent `.10.5` closes and Julia `.10.6` is next after the
clean handoff.

Behavior-free Julia audit `.10.6.0` maps typed staged/compiled/action/diagnostic/generated/runtime authorities and
the missing opaque API/source-map/observation seams. It also proves the prerequisite host-PCRE2 Unicode 16 `\w`
boundary is not pinned Unicode 17 `XID_Continue`: 5,175 required scalars are absent, 923 forbidden scalars are
accepted, required `A·B` fails, forbidden `²` compiles, `Top:::` truncates, and external AST targets bypass label
validation into artifacts. Julia is now dependency-split into Unicode closure `.10.6.1`, source/outcome `.2`,
static `.3`, calls/staging/generated `.4`, query `.5`, runtime observation `.6`, and exact admission `.7`. No Julia
behavior, response digest, rollout, or admission state changes in the audit. Planning `.10.6.1.0` freezes the
generated internal 806-range classifier/scanner, five parser and four validator roles, exact identity/negative/
isolation suites, and `.1-.4` gates. Implementation `.10.6.1.1` now emits/checks all 806 ranges, routes complete
headers and action/blind/bare targets without prefix truncation, and validates parsed/external AST labels with one
portable diagnostic. Focused 1,755, complete Julia 5,466/primary/105, 5x2x66, and the Unicode manifest pass.
Identity `.10.6.1.2` now derives ten unique labels from all nine positives and both distinct pairs and proves exact
identity through AST, compiled/generated/reconstructed/emitted/loaded routes, selectors, diagnostics, traces, and
inline/file commands. It adds 130 assertions (focused 1,885; Julia 5,596/primary/105), passes 5x2x66 plus the
ten-leg manifest plus canonical Rust 80.21s/Dart 1/1/primary 66x2/Phase 0 1,031/645s, and changes no production or
semantic governance. Exact cleanup reclaims 1.57 GB. Negative/isolation `.10.6.1.3` now rejects all eight neutral
negatives across complete source tokens, programmatic/reconstructed declaration/action/blind/bare trust, native/
generated selectors, strict loading, primary commands, and every artifact boundary. Independent function,
parameter, ActionParser, lifecycle, mark, regex, and mode grammars do not inherit the rule-label class. Its 1,946
new assertions compose to focused 3,831 and Julia 7,542/primary/105; 5x2x66, ten Unicode-manifest legs, and
no-drift contracts plus canonical Rust 79.56s/Dart 1/1/primary 66x2/Phase 0 1,031/645s and exact 1.57-GB cleanup
pass without production or governance change. Composed `.10.6.1.4` now reruns the committed four-suite topology at
focused 3,831, Julia 7,542/primary/105, 5x2x66, all ten manifest legs, and unchanged Unicode/semantic/capability/
generated/public ledgers without production/test/API/format change. Canonical Rust 78.46s/Dart 1/1/primary 66x2/
Phase 0 1,031/630s and exact 1.57-GB cleanup pass. Parent `.10.6.1` closes; source/outcome plan `.10.6.2.0`
follows the clean commit. Source `.10.6.2.1`, outcome `.2`, and closeout `.3` now complete the opaque strict
source/compiled-or-failed foundation at focused 220 and Julia 7,762/primary/105 without record/query/execution or
promotion. Behavior-free static plan `.10.6.3.0` freezes five exact targets at graph 12/14, privacy text 4/3,
privacy identity 4/3, failed 6/4, and runtime-static 7/8. It composes source/map, parsed members, typed compiled
state, entry identity, and native diagnostics; normalizes Julia `Default` to neutral non-repetition; excludes
cross-rule parent matchers from slot records while retaining self-indexed slots; and maps native unknown-target
failure only at projection. Graph `.1`, remaining targets/isolation `.2`, and closeout `.3` are dependency-ordered
without public query, runtime observation, format, rollout, or admission movement.
Plan proof passes focused 220, Julia 7,762/primary/105, 5x2x66, ten Unicode legs, unchanged no-drift ledgers,
Knowledge Map 683/5,188, mdBook/doctrines, canonical Rust 78.75s + Dart 1/1 + primary 66x2 + Phase 0 1,031/632s,
and exact 1.56-GB cleanup preserving 517 Pgen artifacts. Graph `.10.6.3.1` followed only after the clean plan commit.
Graph `.10.6.3.1` now implements exact private 12/14/7 graph/source/evidence. Remaining-target leaf `.10.6.3.2`
deep-equals privacy text 4/3, privacy identity 4/3, failed 6/4, and runtime-static 7/8; preserves Julia's native
failure under projection-only neutral normalization; and proves repeated lifecycle identity, no observation state,
detached/immutable copies, generic failure fallback, private omission, and host denial. New 99/focused 389, Julia
7,931/primary/105, 5x2x66, ten Unicode legs, unchanged ledgers, canonical Rust 78.27s + Dart 1/1 + primary 66x2 +
Phase 0 1,031/697s, and exact 1.56-GB cleanup pass. No-change composition `.10.6.3.3` follows the clean `.3.2`
commit and now passes the committed four-suite focused 389, complete Julia 7,931/primary/105, 5x2x66, ten Unicode
legs, unchanged ledgers, and canonical Rust 80.89s + Dart 1/1 + primary 66x2 + Phase 0 1,031/653s without
replacement code. Parent `.10.6.3` closes with no public API/query/observation/format/rollout/admission movement;
behavior-free calls/staging/generated plan `.10.6.4.0` now freezes exact 22/25 authority: typed core is 18/16,
staged/generated completion adds four records and nine relations, and `.1` / `.2` / `.3` own implementation and
closeout without trace, target execution, public query, or promotion. Plan signoff passes focused 389, Julia
7,931/primary/105, 5x2x66, ten Unicode legs, unchanged ledgers, KM 684/5,231, and canonical Rust 77.84s + Dart 1/1
+ primary 66x2 + Phase 0 1,031/625s.
Private typed core `.10.6.4.1` now deep-equals the non-staged neutral subset at 18/16 from registry/function/edge
Action AST plus contracts, with exact authored order/source, nested calls, user/helper resolution, fixed/rest
signatures, conservative shapes, binding relations, recursive freeze, and host/no-execution fences. A bounded
quote/regex-aware scanner correlates typed traversal to UTF-8 byte and Unicode-scalar evidence. New 79/focused 468,
Julia 8,010/primary/105, 5x2x66, ten Unicode legs, unchanged ledgers, and canonical Rust 77.41s + Dart 1/1 +
primary 66x2 + Phase 0 1,031/622s pass. mdBook/KM 685/5,252 and exact 1,618,660-KiB cleanup preserving 517 Pgen
artifacts pass. Staged/generated `.10.6.4.2` now validates native payload/job/result sidecars and the retained
generated-v2 contract/identity/order/selected row, then deep-equals the complete private target at 22/25. The
three roles and nine directed provenance relations remain distinct without exposing native sidecars, body AST, or
generated implementation. New 62/focused 530, Julia 8,072/primary/105, 5x2x66, ten Unicode legs, unchanged
ledgers, and canonical Rust 76.95s + Dart 1/1 + primary 66x2 + Phase 0 1,031/622s pass. Closeout `.3` now reruns
committed focused 530, Julia 8,072/primary/105, 5x2x66, ten Unicode legs, unchanged ledgers, and canonical Rust
77.68s + Dart 1/1 + primary 66x2 + Phase 0 1,031/622s without replacement code or promotion. Parent `.10.6.4`
is composition-closed. Query audit `.10.6.5.0` now freezes one fresh detached projection as the sole evaluator
authority, all 19 static hashes and 26 malformed boundaries, exact immutable typed/raw-neutral values, Julia's
explicit Boolean/integer fence, and the private kernel `.1` / traversal-limit `.2` / public completion `.3` /
no-change closeout `.4` order. Runtime events remain `.10.6.6`; this audit changes no behavior or promotion.
Full proof passes neutral 6/20/81, focused Julia 530 plus detached 22/25/10, Julia 8,072/primary/105, primary 5x2x66,
ten Unicode legs, unchanged ledgers, canonical Rust/Dart admission + primary 66x2 + Phase 0 1,031/655s, book/KM
687/5,277, doctrines, and exact 1,812,240-KiB cleanup preserving 517 Pgen artifacts.
Private kernel `.10.6.5.1` now matches nine exact capabilities/list/get/explain/source hashes with complete
immutable tuple-backed values behind an unexported evaluator. Each call consumes one fresh detached projection and
cannot reach source/compiler/staged/AST/IR/generated/runtime/trace/path/host state. New 100/focused 630, Julia
8,172/primary/105, primary 5x2x66, ten Unicode legs, and unchanged governance pass. At that boundary, traversal/
pages/budgets/costs and the remaining ten static hashes were assigned to `.2`; raw validation and complete public
exposure stayed `.3`. Canonical
Rust 80.95s + Dart 1/1 + primary 66x2 + Phase 0 1,031/662s, book/KM 688/5,287, doctrines, and exact
1,613,088-KiB cleanup preserving 517 Pgen artifacts pass.
Private completion `.10.6.5.2` now evaluates canonical after-id pages, outgoing/incoming/both filter-constrained
breadth-first relations, record/relation/depth budgets, deterministic incomplete prefixes, and exact logical costs
without widening detached-projection authority. New 118/focused 748 and complete Julia 8,290/primary/105 pass;
the remaining ten and therefore all 19 static hashes are exact. Public typed/raw-neutral exposure plus the 26 raw
validation boundaries stay `.3`, and runtime events stay `.10.6.6`. Primary 5x2x66, ten Unicode legs, unchanged
ledgers, canonical Rust 82.53s + Dart 1/1 + primary 66x2 + Phase 0 1,031/647s, book/KM 689/5,298, doctrines, and
exact 1,613,224-KiB cleanup preserving 517 Pgen artifacts pass.
Public completion `.10.6.5.3` now exports the frozen immutable query types and `semantic_capabilities`, typed
`semantic_query`, and raw-neutral `semantic_query_neutral` together. Both entries use one validator/evaluator and
one detached projection; typed/raw calls match all 19 static hashes, and raw-neutral validation locks all 26
portable malformed boundaries including Julia Boolean/numeric separation. New 315/focused 1,063 and complete
Julia 8,605/primary/105 pass with clone/privacy/non-execution/host-denial proof. Runtime `.10.6.6` and semantic
rollout/admission remain unchanged. Full primary 5x2x66, ten Unicode legs, canonical Rust 79.96s + Dart 1/1 +
primary 66x2 + Phase 0 1,031/634s, mdBook/KM 690/5,307, doctrines, and exact 1,613,820-KiB cleanup preserving 517
Pgen artifacts pass. No-change closeout `.10.6.5.4` now recomposes committed focused 1,063,
complete Julia 8,605/primary/105, primary 5x2x66, ten Unicode legs, and unchanged ledgers without replacement code
or promotion. Parent `.10.6.5` is composition-closed; runtime authority planning `.10.6.6.0` follows only after
the closeout commit is clean. Canonical Rust 79.55s + Dart 1/1 + primary 66x2 + Phase 0 1,031/635s, book/KM
690/5,307, doctrines, and exact 1,613,872-KiB cleanup preserving 517 Pgen artifacts pass.
Behavior-free runtime-observation audit `.10.6.6.0` now freezes exact Julia authority before code. Existing trace
slot strings and diagnostic output are not semantic events. Accepted slot capture uses the matched end offset
before effects; successful final capture uses `RuntimeParseResult.cursor_char_offset`. Direct, loaded,
reconstructed, generated-plan, fresh emitted, and traced routes converge on those seams, while generated broad
error translation requires semantic callback-identity passthrough. The absent sink allocates no event and hashes
no input. Detached derivation validates static rule/edge/slot topology and shapes, returns a new observed index at
the twentieth digest, and leaves query execution-free. Work is split as typed direct capture `.1`, derivation `.2`,
generated/emitted propagation `.3`, and no-change closeout `.4`; `.0` changes no behavior or promotion.
Typed direct capture `.10.6.6.1` now exports immutable v1 slot/result events and threads an optional sink through
native parse/execute, traced convenience, loaded/reconstructed engines, and validated generated-plan direct/traced
helpers. It locks matched-end Unicode-scalar positions, final UTF-8 input identity, exact callback exception
identity, no-sink zero work, failure omission, and result/trace/diagnostic non-interference at new 66/focused 1,129
and complete Julia 8,671/primary/105. Immutable derivation `.10.6.6.2` now validates typed observations against
detached static topology and returns an isolated `has_execution=true` snapshot with the exact twentieth digest.
New 157/focused 1,286 and complete Julia 8,828/primary/105 pass without execution or host-authority widening.
Generated/emitted propagation `.10.6.6.3` now threads the same sink through fresh direct/traced wrappers and proves
canonical events/digest, exact callback identity, exit omission, and result/diagnostic/trace non-interference at
new 51/focused 1,337 and complete Julia 8,879/primary/105. Generated source stays v2/format 2; rollout and admission
remain 4/9 and 3/6.
No-change `.10.6.6.4` now recomposes all twelve committed owners at focused 1,337 and closes the runtime-
observation parent without behavior, format, rollout, or admission change. Exact Julia admission `.10.6.7` adds
one ordered twelve-role consumer and eight topology mutations without a second semantic path; Julia alone advances
governance to 6/20/89 at rollout 5/9 and native admission 4/6.
Lua audit `.10.7.0` is behavior-free and exact: current PUC Lua/LuaJIT share reusable compiled/ActionIR/staged/
generated/loader/trace/runtime/JSON owners but no semantic/source-map/SHA/query/typed-observation owner. ASCII rule
labels pass only 3/9 positives, omit 149,158 required Unicode 17 scalars, and external AST labels bypass validation.
Dependency order is Unicode `.1`, source/outcome `.2`, static `.3`, calls `.4`, query `.5`, observation `.6`, then
one byte-identical dual-ABI admission `.7`; semantic governance remains 6/20/89 at 5/9 + 4/6.
The audit is fully verified by unchanged dual-ABI package `1..177`, PUC primary 66x2/corpus 105, full primary
5x2x66, ten Unicode legs, every ledger, book/KM/doctrines, canonical CI, and safe cleanup. Behavior-free
`.10.7.1.0` freezes one generated Lua-5.1-compatible 806-range classifier, exactly five parser routes, one
authoritative four-role validator, a shared diagnostic, and the identity/negative/isolation proof split.
Implementation `.10.7.1.1` now lands the deterministic private classifier, strict UTF-8 scanner, every parser and
post-AST validation authority, portable diagnostics, dual-ABI focused proof, and omission-sensitive registrations
without public API, format, semantic, rollout, or admission movement. Exact identity `.10.7.1.2` now proves ten
unique positive/distinct labels through every AST/compiled/descriptor/plan/loaded/generated/emitted/selector/
diagnostic/trace/primary route at 359 assertions per ABI, including normalization-sensitive separation and portable
path/host denial. Negative/isolation audit `.10.7.1.3.0` freezes one pre-existing body-fluent suffix-loss defect.
Narrow `.3.1` now propagates the already returned remainder, making all seven measured suffixes exact raw
validation failures while retaining no-prefix/newline controls, ASCII methods, and recognized body continuations
at 166 assertions per ABI.
Exhaustive `.3.2` now derives all eight neutral negatives and proves every source/trust/artifact/runtime/selector/
diagnostic/trace/loader/primary rejection plus adjacent grammar at 1,542 assertions per ABI. Parent `.3` closes;
no-change recomposition `.4` now passes every committed owner and closes `.10.7.1` without semantic promotion.
Behavior-free source/outcome plan `.10.7.2.0` now freezes the exact weak-key opaque constructor, strict source
ceilings/coordinates, dependency-free SHA-256, typed error/outcome boundary, no-path/no-target-execution topology,
and `.1` source / `.2` staged outcome / `.3` closeout split from identical PUC Lua/LuaJIT probes. Strict source-
only `.10.7.2.1` now implements the root constructor, copied UTF-8, portable SHA-256, exact private coordinates,
four ceilings, opaque values, typed map errors, and dual-ABI isolation at 378 assertions per ABI. Staged outcome
`.10.7.2.2` adds one retained parse/validate/compile/select/plan result plus detached snapshot, authority,
diagnostic, entry, and generated-v2 plan at 122 assertions per ABI. No-change `.10.7.2.3` recomposes the committed
378+122 proof and closes the parent without target execution, format, query, observation, or semantic ledger
movement. Behavior-free `.10.7.3.0` now freezes exact graph 12/14, privacy text 4/3, privacy identity 4/3, failed
6/4, and runtime-static 7/8 targets from byte-identical PUC Lua/LuaJIT probes. Full authored-line scanning plus
parsed/compiled occurrence correlation owns source and identity; parent/self/duplicate matchers, repeated
lifecycle markers, neutral `Default` repetition, failure normalization, detachment, and host-state denial are
fixed. `.10.7.3.1` retains the exact private immutable 12-record/14-relation/seven-source-reference graph on both
ABIs. Behavior-free `.10.7.3.2.0` reconciles private source authority with ADR-0049 outward redaction; implementation
child `.10.7.3.2.1.1` now completes privacy 4/3 + 4/3, failed 6/4, runtime-static 7/8, and isolation on both ABIs.
Final clean-dependency canonical closeout `.10.7.3.2.1.2` passes six doctrines, corrected containment, moved-root
proof, Rust/Dart/Julia semantic admission, primary 66x2, and Phase 0 1,031/1,031 in 637 seconds. `.10.7.3.2` is
complete. No-change `.10.7.3.3` recomposes committed 379/122/64/122 dual-ABI suites, complete Lua, both five-
backend matrices, six ledgers, and canonical Phase 0 1,031/1,031 in 649 seconds. Parent `.10.7.3` is composition-
closed without query or ledger movement. Behavior-free calls/staging/generated audit `.10.7.4.0` is complete and
freezes exact static 6/6 -> typed 18/16 -> staged/generated 22/25 ownership, merged authored definition order,
typed/staged integrity, occurrence-safe Unicode source correlation, registry-before-helper resolution, retained generated-v2
plan authority, and no-execution/host/privacy fences. Typed core `.10.7.4.1` now deep-equals the governed
non-staged subset at 18 records / 16 relations / 10 source refs on PUC Lua and LuaJIT, preserving exact typed call
preorder, source identity, signatures, shapes, decision/explanations, recursive freeze/detachment, and privacy.
Staged/generated `.10.7.4.2` now completes exact private 22/25/10 from validated native sidecars and retained plan
authority. No-change `.10.7.4.3` recomposes all six committed suites at exact focused 920 per ABI and closes
parent `.10.7.4`. Behavior-free immutable-query authority audit `.10.7.5.0` now freezes one detached projection-
only evaluator, exact public vocabulary, 19 static hashes, 26 raw boundaries, explicit dual-ABI JSON/numeric
policy, source redaction, traversal/pages/budgets/costs, and private `.1` -> private `.2` -> complete public `.3` ->
closeout `.4` dependency order without behavior change. Private non-traversal `.10.7.5.1` now matches nine exact
hashes with protected recursively frozen protocol values, one detached materialization, and no public query name;
its new 159 assertions compose at focused 1,080 per ABI. Private traversal/limits `.10.7.5.2` now completes all 19
static hashes with canonical pages, filtered directional BFS, deterministic record/relation/depth budget prefixes,
logical costs, and portable typed errors at query 283/focused 1,204 per ABI. Public completion `.10.7.5.3` now
exposes four protected root helpers plus index capabilities, typed query, and raw-neutral query together. Both
paths share one evaluator and detached materialization, match all 19 static hashes, and lock all 26 malformed
boundaries, explicit JSON kinds, portable numeric/cursor rules, recursive detachment, host denial, and
non-execution at query 571/focused 1,492 per ABI. Signoff passes primary 5x2x66, Unicode 10/10, all six unchanged
ledgers, and the complete elevated local gate (Rust admission 1/1 in 78.05 s, Dart 1/1, Julia 416/416 in 27.3 s,
containment, moved-root, reference 66x2, and Phase 0 1,031/1,031 in 624 s), the mdBook build, and Knowledge Map 729
facts / 5,824 keys. No-change `.10.7.5.4` now recomposes all seven committed suites at focused 1,492 per ABI and
closes parent `.10.7.5` without replacement code, runtime observation, format, or promotion. Its complete signoff
passes primary 5x2x66, Unicode 10/10, all six unchanged ledgers, canonical Rust 77.93 s + Dart 1/1 + Julia
416/27.4 s + containment/moved-root + reference 66x2 + Phase 0 1,031/622 s, mdBook, and Knowledge Map 729/5,824.
Fully verified behavior-free runtime-observation audit `.10.7.6.0` freezes exact accepted match-end and normally returned
result seams, Unicode-scalar/input identity, no-sink/callback policy, every dual-ABI execution route, detached
static-only derivation, the twentieth digest, and `.1-.4` order without behavior or governance movement. Audit
signoff passes Lua semantic 1,492 and diagnostics 119 per ABI, primary 5x2x66, Unicode 10/10, all six ledgers,
canonical CI through Phase 0 1,031/1,031 in 624 s, mdBook, and Knowledge Map 730/5,838. Typed direct capture
`.10.7.6.1` adds protected invocation-local slot/result events across native direct/loaded/reconstructed/traced
routes; immutable derivation `.10.7.6.2` validates those exact handles against one detached static projection and
exposes the twentieth typed/raw digest. Generated/emitted propagation `.10.7.6.3` now carries the same sink through
public generated direct/traced and fresh emitted direct/traced routes, including isolated PUC Lua/LuaJIT hosts.
Its generated-only callback carrier preserves exact arbitrary failure identity and marker fences while
deterministic v2/format 2 bytes, minimal plans, native capture/derivation, results/trace/diagnostics/no-sink work,
rollout, admission, and ledgers stay unchanged. New 80/focused 1,964 pass per ABI; complete Lua, primary 5x2x66,
Unicode 10/10, six ledgers, canonical Rust 82.65 s + Dart 1/1 + Julia 416/29.5 s + containment/moved-root + reference
66x2 + Phase 0 1,031/667 s, mdBook, and Knowledge Map 733/5,874 pass. No-change composition `.10.7.6.4` now
reruns the unchanged ten owners at focused 1,964 per ABI from clean `04ab4fec` and closes parent `.10.7.6` without
replacement code, format movement, or promotion. Complete Lua, primary 5x2x66, Unicode 10/10, all ledgers, and
canonical Rust 81.52 s + Dart 1/1 + Julia 416/29.0 s + containment/moved-root + reference 66x2 + Phase 0
1,031/656 s pass. Exact dual-ABI admission `.10.7.7` adds one unchanged twelve-role Lua source that passes 408
assertions on each ABI, identical PUC Lua/LuaJIT topology, nine mutations, and Lua-only promotion. Governance
advances to 6/20/98 at 6/9 + 6/6 and `.10.7` closes. Recurring six-runtime proof `.10.8` then composes every
admitted consumer unchanged through one routed driver, three 5x2 primary no-drift cases, generated/capability/
language ledgers, canonical opt-in, seven topology mutations, premature-MCP denial, and recurring-only promotion.
It passes exact 6/20/105 at rollout 7/9 and admission 6/6. Behavior-free MCP architecture leaf `.10.9.0` is
complete: exact contract `.1`, Perl `.2`, Rust `.3`, Dart `.4`, Julia `.5`, shared Lua `.6`, and recurring
six-runtime `.7` follow in dependency order. Protocol-policy `.10.9.1.0`, machine artifact `.10.9.1.1`, and
independent validator/mutations `.10.9.1.2` and no-change ordered canonical closeout `.10.9.1.3` are complete under
ADR `0055`. ADR `0057` and behavior-free `.10.9.2.0` freeze exact Perl native/wire/security seams and the `.1-.4`
dependency order; in-process registry/decoded dispatch `.10.9.2.1` is complete with canonical signoff, while
strict stdio/lifecycle `.10.9.2.2` is complete with canonical signoff. Exact Perl admission/ledger `.10.9.2.3` is
complete at 1/5 implementations, 1/6 runtimes, rollout pending, and 28 rejected mutations with canonical signoff.
No-change closeout `.10.9.2.4` is complete from clean `28f84826`; focused and canonical unchanged-owner
recomposition are green, parent `.10.9.2` is closed, and Rust `.10.9.3` follows after the clean commit. Behavior-
free Rust audit `.10.9.3.0` and ADR `0058` now freeze shared verified-bundle/Rust binding generation,
`linkedspec-runtime` registry/decoded dispatch, strict stdio, exact admission, and no-change closeout under `.1-.4`;
the audit is complete with canonical signoff. Generated binding/decoded server `.10.9.3.1` and strict borrowed-
stream stdio `.10.9.3.2` are implemented. Exact twelve-role admission `.10.9.3.3` advances only Rust to 2/5
implementations + 2/6 runtimes, preserves pending shared rollout, and rejects 39 mutations. No-change closeout
`.10.9.3.4` passes unchanged focused/canonical recomposition and closes parent `.10.9.3`. Behavior-free Dart audit
`.10.9.4.0` and ADR `0059` freeze generated private-part data/runtime, the native secure decoded server, strict
duplicate-safe/canonical stdio, exact admission, and no-change closeout under `.1-.4`; `.10.9.4.1-.3` implement
and admit Dart at 3/5 implementations + 3/6 runtimes with 58 mutations, and no-change `.10.9.4.4` closes its
parent. Behavior-free Julia `.10.9.5.0` and ADR `0060` freeze a generated Base64 contract module, private frozen
runtime, synchronous native server, strict number-preserving stdio, OS-random/monotonic/digest security, exact
admission, and no-change closeout under `.1-.4`. Generated binding/runtime and decoded server `.10.9.5.1` now
implement the 119,538-byte binding, public opaque secure registry/dispatch API, 187 focused assertions, and
canonical generator/source/test ordering. Strict stdio `.10.9.5.2` now adds the bounded duplicate-safe numeric-
kind-preserving wire, canonical LF, cancellation through flush, fixed optional diagnostics, and EOF/I/O release
over caller-owned streams; combined proof is 48 + 139 + 170 assertions and 68 governance mutations. The ledger
remained 3/5 + 3/6 pending until exact admission `.3`. Julia admission `.10.9.5.3` and no-change closeout `.4`
then advance Julia alone to 4/5 implementations + 4/6 runtimes at 79 mutations and close its parent. Shared Lua
`.10.9.6.0-.4` and ADR `0061` plan, implement, admit, recompose, and parent-close one Lua-5.1-compatible source
unchanged on PUC Lua and LuaJIT. The ledger reaches 5/5 implementations + 6/6 runtimes. Behavior-free recurring
audit `.10.9.7.0` and ADR `0062` now identify, freeze, and complete signoff on the exact final evidence seam: all six native semantic
consumers prove twenty responses, whereas each MCP consumer currently compares capabilities plus one
representative query. Real Perl probe `.10.9.7.1.0` proves 17 total identities and exposes three shared blockers:
missing MCP output fact keys, constant input-contract validation, and default-policy preemption of a native ceiling
diagnostic. Exploratory code is removed and rollout remains pending. On 2026-07-30 the director authorized the
exact all-twenty path. Plan `.10.9.7.1.1.0` freezes atomic neutral-contract/binding/five-server repair `.1`, six-
runtime all-twenty consumers `.2`, routed omission-governed promotion `.3`, and unchanged closeout `.4`; preserving
current bytes and weakening the claim to 17 identities plus three boundary outcomes is not selected. Repair `.1`
and all-twenty consumers `.2` are complete. Routed `.3` now adds rooted `tools/check_mcp_six_runtime.sh`, exact
neutral/bindings/six-consumer/ledger/primary order, same-volume scratch, canonical
`LINKEDSPEC_RUN_MCP_MATRIX=1`, and matching cross-ledger `.10.9.7.1` promotion. Focused proof passes; current
state at that boundary is semantic 6/20/110 at eight-of-nine rollout + admission 6/6 and MCP 5/5 + 6/6
complete with 141 mutations.
No-change `.4` repeats that chain plus canonical Phase 0 1,031/1,031 in 655 seconds and closes `.1.1` plus `.1`
without behavior or authority movement. Final MCP-parent leaf `.10.9.7.2` now independently passes the exact
focused chain plus canonical MCP opt-in, closes `.10.9.7` and `.10.9`, preserves the then-current semantic
eight-of-nine boundary and MCP complete/141, and hands the clean boundary to public semantic/MCP no-drift `.10.10`.
That public leaf is now complete: semantic governance is six fixture groups / 20 responses / 128 mutations,
rollout 9/9, and native admission 6/6, with no production behavior change.
The public semantic/MCP no-drift `.10.10` is complete and closes parent `.10`.

| Area | Status | What it covers | Remaining focus |
| --- | --- | --- | --- |
| Overall roadmap | `done` | Whole-project delivery across parser core, semantics, runtime, docs, self-hosting, multi-backend handoff, and Rust implementation. | All phases 0–9 done. Phase 9 Rust variant operational: .spec parser, compiler, runtime engine, helpers, integration tests. Cargo workspace at rust/. mdBook reframed variant-agnostic across all chapters (`.spec` = universal contract; Perl = reference backend) — `MDBOOK-VARIANT-AGNOSTIC` tree complete (7 leaves). Deferred future parity work is now owned by `FUTURE-PARITY-BACKLOG`. |
| Rendered mdBook readability | `proposed; non-blocking` | Evidence-first rendered-HTML audit and bounded repair of dense paragraph blobs. | Intake `.0` preserves the director observation. `.1` inventories exact source/route/section/viewport evidence before edits; `.2` repairs only confirmed cases without content loss and adds a guard only if a low-noise signal exists. No book theme change; current `.14.1.2` teaching renders as separate headings, lists, code blocks, and paragraphs, while the comprehensive audit remains queued. |
| mdBook destination-root safety | `done; closed` | Make custom mdBook output validation and execution use one repository-derived resolution base. | `MDBOOK-DESTINATION-ROOT-ALIGNMENT.1` runs mdBook from the book root and proves split/equals/compact relative, environment, absolute, default, hostile, outside-CWD, and exact real-build behavior. Canonical CLI 66x2, RAM 46%, and Phase 0 1,031/1,031 in 659 seconds pass. Typed-source Perl resumes next; the nonurgent readability audit remains separate. |
| Future parity backlog | `in progress` | Deferred/future lanes after the closed language-reference, terse-format, and five-backend implementation trees: staged parsing, function extensions, helper caveats, plugin fate, richer oracle candidates, spec-derived parser/stimuli validation, AND/OR edge-default design, deep semantic introspection with MCP projection, generic first-class codeblocks, compatibility retirement, toolbox reliability, structural/progressive/staged authoring closure, the Unicode structured-text program, and explicit Rust mutation campaigns. | Five-backend capability parity is 80/0/0. Semantic introspection remains exact at six fixture groups / 20 responses / 128 mutations, rollout 9/9, and native admission 6/6; MCP is complete/141. Typed-source internal value/helper parent `.14.2` is composition-closed at 8 complete / 6 pending / 53 mutations across all six runtimes. Transaction audit `.14.3.0` proves the current cursor-only stack/rule-label-mark boundary, and `.14.3.1.0` ratifies the four exact future `recognition_*` forms, falsey-safe match/payload split, linear token, closed 9/11 effects, invocation marks, and cursor-only progress. Executable neutral `.14.3.1.1` now locks 128 current + 4 future node rows, 246 call rows, token 8/17, effect graphs 6, marks 6, progress 8, diagnostics 15, and 40 mutations at rollout 1/9. It changes no grammar/runtime/backend/current public behavior; the forms remain unavailable until independent Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT, recurring, and public admission. Reversed-span remains `.14.2`-owned and `.14.8` retains final public no-drift. The stale active-tree prose frontier is repaired and prevention is owned by `TASK-TREE-METADATA-HYGIENE.5`. The nonurgent rendered-readability tree stays queued; `.22`, `.23`, format/inter-match work, manual mutation execution, inspector `.13.1`, and `.15` remain separately owned. |
| Expressive `.spec` self-containment | `direction ratified; implementation unscheduled` | Problem-domain language closure plus an optional EBNF-like authoring frontend over one canonical semantic core. | ADR `0064` and `SPEC-LANGUAGE-SELF-CONTAINMENT.0` accept no-host-escape expressive objectives, one AST/HandlerIR/runtime, honest EBNF semantic differences/extensions, lossless source maps, realistic proof, and five-backend rollout. `.1-.6` remain pending behind current callable parity; no syntax or behavior is current. |
| Inter-match gap capture | `direction ratified; awaiting explicit activation` | Historical “super split” means automatic source-gap access between repeated OR/default action-edge matches. The target rule owns the selected regex slot and its lifecycle; the enclosing rule owns repeated selection/gap orchestration. It is unrelated to blind calls or regex/edge adjacency. | ADR `0045` and `INTER-MATCH-GAP-CAPTURE.0` align history, guides, and book without behavior change, including the actual legacy matrix: Perl anonymous scope is rule-level, Lua is preceding-slot-local, and Rust/Dart/Julia do not execute marker members natively. Cursor rollout dependency is satisfied at 8/0. Accepted future `@capture_gaps` and spacing-insensitive `name=/regex/` → `Rule[name]` named slots remain `.1-.7` pending explicit activation. |
| Dart backend parity | `done` (foundation and rule-local cursor admitted) | First future full-parity backend lane after Perl5 and Rust. | The original parity tree closed at 190 tests, 61/61 default/POSIX, and 105/105 corpus. Rule-local cursor `.9.1.5` closes normalization, live/loaded/reconstructed execution, descriptor v1, generated-source v2, public/CLI override removal, and one exact 15-role admission. Its admission boundary was package 271, primary 65x2, corpus 105/105, and neutral 67 files / 4 complete / 4 pending / 39 mutations; Julia has since advanced the shared ledger to 5/3/44. |
| Julia backend parity | `complete` (semantic introspection admitted) | Second future full-parity backend lane after Dart under ADR `0021`; native in-memory Julia library first under ADR `0022`. | Standalone corpus is 105/105. Root/cursor/repeated-action exact admissions and their recurring/public proof remain closed. Unicode-17 labels, opaque strict source/compiled outcome, five exact static targets, calls/staging/generated 22/25, immutable query, typed observation, emitted propagation, and the ordered twelve-role admission are complete through `.10.6.7`. All 20 typed/raw-neutral hashes and all 26 malformed boundaries match; semantic governance is rollout 5/9 and native admission 4/6. |
| Non-current helper code purge | `done` | Remove retired helper spellings from Perl/Rust code surfaces, active tests/tools/spec fixtures, and durable docs so deleted names are not preserved as name-specific recognition or diagnostics. | Task tree `docs/tasks/NONCURRENT-HELPER-CODE-PURGE.md` complete through `.5`: Perl source cleanup, Rust source cleanup, active fixture/spec migration, and final no-drift closeout are done. Active retired-helper call-shape, label/tag, and `?concat:` scans are clean; generic unknown-helper tests use invented helper names. |
| Phase 0 | `done` | Regression safety net, baseline compilation coverage, and corpus-level guardrails. | Keep the regression baseline green; all shipped `specs/*.spec` files now participate in the baseline compile pass, and the current gate reaches `PASS 1..1031` with `PERL5LIB=` cleared. |
| Phase 1 | `done` | Parser-core isolation and dependency-surface reduction for the active compile/runtime path. | Task tree `docs/tasks/PHASE1-PARSER-CORE-ISOLATION.md` completed 2026-05-18 (3 leaves: inventory, ActionRewriter.pm removal, rewrite_action_code_for_compat evaluation). ActionRewriter.pm deleted (118 lines, 59 forwarders). rewrite_action_code_for_compat fallback evaluated and documented. |
| Phase 1A | `done` | Thin-façade modularization of `LinkedSpec.pm` into focused owner modules with stable public APIs. | Task tree `docs/tasks/PHASE1A-CLOSE-OUT.md` completed 2026-05-16. Finish shrinking `LinkedSpec.pm` and the remaining thin compatibility wrappers down to stable owner paths; public façade option normalization is now aligned across both `Get(...)` and `get_parser(...)`, the repeated lazy owner-dispatch / callback-value lookup / `$@` preservation plumbing is now also shared across `LinkedSpec.pm`, `LinkedSpec::Trace`, `Runtime.pm`, `ParserFactory.pm`, `BootstrapSpec.pm`, `BootstrapSpec::Core`, `Compiler.pm`, `SpecEntry.pm`, `RuleIR.pm`, `RuleIR::EmitContext.pm`, `Resolver.pm`, and `Validation.pm` through `LinkedSpec::OwnerDispatch` (the then-present thin shim `ActionRewriter.pm` was later deleted in Phase 1), with `Runtime`, `Compiler`, `BootstrapSpec`, `SpecEntry`, `RuleIR::EmitContext`, `ActionIR::Scanner`, and the remaining compile/support-owner package and callback loaders now spending that seam directly instead of local pass-through wrappers; `RuleIR::EmitContext` now also spends `OwnerDispatch::require_pkg(...)` directly inside `_actionir_owner_package(...)` instead of bouncing through a generic local package-loader wrapper, `ActionIR::StatementSplit::Core` now also spends `OwnerDispatch::require_pkg(...)` directly inside `_require_statement_split_mode_pkg(...)` and `_require_method_expr_pkg(...)` instead of bouncing through a generic local package-loader wrapper, `BootstrapSpec::Core` now also spends `OwnerDispatch::require_pkg(...)` and `OwnerDispatch::call_preserving_err(...)` directly inside `_linkedre_or(...)` and `_linkedre_ored_re(...)` instead of bouncing through separate local LinkedRE-loader or `$@` wrappers, `PluginBridge` now also spends `OwnerDispatch::call_preserving_err(...)` directly inside `_exec_legacy_plugin(...)`, `_get_legacy_plugin(...)`, `_lookup_plugin_name(...)`, and `_dispatch_plugin_name(...)` instead of bouncing through a local `$@` wrapper while `_lookup_plugin_name(...)` and `_dispatch_plugin_name(...)` now also serve as the direct dependency-validation seams instead of a second top-level `_require_dep(...)` wrapper, `Compiler` now also treats `_require_runtime_ctx(...)` and `run_get_pipeline(...)` as its direct dependency-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them, `ParserFactory` now also treats `run_get_parser(...)` as the direct setup dependency-validation seam instead of keeping a second top-level `_require_dep(...)` wrapper above it, `BootstrapSpec` now also spends `OwnerDispatch::require_pkg_cb(...)` directly inside `build_bootstrap_spec(...)` instead of bouncing through a local bootstrap-core loader wrapper, `Compiler` now also spends `OwnerDispatch::require_pkg(...)` directly inside `_dump_value(...)` for `Data::Dumper` and `_ored_re(...)` for LinkedRE, and spends `OwnerDispatch::call_preserving_err(...)` directly inside `_dump_value(...)`, `_ored_re(...)`, `_trace_log_output(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_apply_trace_options(...)`, and `_trace_level_name_for_current_verbosity(...)` instead of bouncing through local Data::Dumper-loader, LinkedRE-loader, or `$@` wrappers, `SpecEntry` now also spends `OwnerDispatch::require_pkg(...)` directly inside `_dump_value(...)` for `Data::Dumper` and spends `OwnerDispatch::call_preserving_err(...)` directly inside `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_dump_value(...)`, and `_trace_runtime_mark_event(...)` instead of bouncing through local Data::Dumper-loader or `$@` wrappers, `RuleIR` now also spends `OwnerDispatch::require_pkg(...)` directly inside `_dump_value(...)` for `Data::Dumper` and spends `OwnerDispatch::call_preserving_err(...)` directly inside `_trace_should_dump(...)`, `_trace_log_output(...)`, `_trace_decision(...)`, `_trace_rule_ir_decision(...)`, and `_dump_value(...)` instead of bouncing through local Data::Dumper-loader or `$@` wrappers, and `RuleIR::EmitContext` now also spends `OwnerDispatch::call_preserving_err(...)` directly inside `_actionir_owner_default_deps(...)`, `_call_actionir_owner(...)`, `_call_actionir_owner_with_deps(...)`, `_accumulate_action_rewrite_diagnostics(...)`, and `rewrite_action_code_for_compat(...)` instead of bouncing through a local `$@` wrapper; the then-present `ActionRewriter` shim also routed its shared `EmitContext` compatibility delegation through `OwnerDispatch::dispatch_owner_call(...)` before being deleted in Phase 1, while Backbone Item 3 now also spends that seam inside `LinkedSpec::ActionIR::RewritePipeline`, `LinkedSpec::ActionIR::Scanner`, `LinkedSpec::ActionIR::ScannerCore`, `LinkedSpec::ActionIR::StatementSplit`, `LinkedSpec::ActionIR::StatementSplit::Core`, `LinkedSpec::ActionIR::CanonicalEvents`, `LinkedSpec::ActionIR::Diagnostics`, `LinkedSpec::ActionIR::ValueExpr`, `LinkedSpec::ActionIR::FlowExpr`, `LinkedSpec::ActionIR::ArrayPipeline`, `LinkedSpec::ActionIR::ControlFlow`, `LinkedSpec::ActionIR::Contracts`, and `LinkedSpec::ActionIR::MethodLowering`, with `ActionIR::ScannerCore` now also keeping `_scanner_rule_dep_bindings(...)` as its sole local scanner-callback validation seam instead of a second top-level `_require_dep(...)` validator wrapper, `ActionIR::StatementSplit` now also keeping `_split_action_ir_statements(...)` as its sole local statement-splitting seam instead of a second top-level `_require_dep(...)` validator wrapper and now lazy-loading `StatementSplit::Core` directly inside that seam instead of a single-use core-loader wrapper, `ActionIR::CanonicalEvents` now also keeping `_build_canonical_action_ir_events(...)` as its sole local canonical-event dependency seam instead of a second top-level `_require_dep(...)` validator wrapper and now lazy-loading `CanonicalEvents::Core` directly inside `_canonicalize_helper_action_ir_event(...)` instead of a single-use core-loader wrapper, `ActionIR::Diagnostics` now also keeping `_find_unresolved_action_helpers(...)` and `_collect_action_helper_ir_nodes(...)` as its local diagnostics seams instead of a second top-level `_require_dep(...)` validator wrapper, `ActionIR::RewritePipeline` now also keeping `_build_action_rewrite_rules(...)` and `_rewrite_action_code_with_diagnostics(...)` as its local rewrite seams instead of a second top-level `_require_dep(...)` validator wrapper, `ActionIR::ArrayPipeline` now also keeping `_normalize_split_delimiter_expr(...)` and `_build_array_pipeline_plan_from_expr(...)` as its local array-pipeline seams instead of a second top-level `_require_dep(...)` validator wrapper, `ActionIR::Contracts` now also keeping `_require_lowering_deps(...)` as its sole local lowering-dependency seam instead of a second top-level `_require_dep(...)` validator wrapper, `ActionIR::ControlFlow` now also keeping its control-flow lowering helpers as the direct callback-validation seams instead of a second top-level `_require_dep(...)` validator wrapper, `ActionIR::MethodLowering` now also keeping its method/value/assignment/return lowering helpers as the direct callback-validation seams instead of a second top-level `_require_dep(...)` validator wrapper, and `LinkedSpec::ActionIR::DeclareMethod` also spending that seam directly; `RuleIR::EmitContext` now also centralizes its own internal ActionIR owner-package registry and owner default-dependency lookup, default callback-map assembly is now broadly centralized across both the core and secondary ActionIR owners through one shared `OwnerDispatch::build_dep_map(...)` helper, `ParserFactory.pm` now also assembles its mixed trace/resolve/compile callback plus trace dump-level value bundle through one shared `OwnerDispatch::build_dep_bundle(...)` helper, `OwnerDispatch::dispatch_owner_call(...)` now also resolves delegated callbacks through the same `require_pkg_cb(...)` loader route, lazy owner loads are now also `chdir(...)`-safe because `OwnerDispatch` seeds an absolute repo `perl` root into `@INC`, the dead façade/parser-factory, dep-map-only ActionIR, runtime/bootstrap/scanner/emit-context, single-use helper-owner, one-shot orchestration-wrapper, Resolver trace-wrapper, Scanner owner-wrapper, and compile/support-owner package/callback-loader `OwnerDispatch` wrappers are now gone, and the façade no longer carries the stale monolith-era `use re 'eval'` pragma. |
| Phase 2 | `done` | DSL frontend hardening, stricter validation, and clearer token/error handling. | Task tree `docs/tasks/PHASE2-DSL-FRONTEND.md` completed 2026-05-16 (6 leaves). Continue expanding syntax-aware validation from the current rule-paragraph regex checks into broader token/error hardening and clearer diagnostics; grouped shared-code action-edge targets like `-> RuleA | RuleB { ... }` are now part of the explicit supported frontend surface, and stray unmatched top-level closing delimiters inside rule paragraphs are now rejected early too. |
| Phase 3 | `done` | Formal parse-mode semantics, especially `seek` versus `consume` behavior. | Task tree `docs/tasks/PHASE3-EXECUTION-SEMANTICS.md` completed 2026-05-17 (4 leaves: inventory, BACKTRACK local-rewind contract, non-backtracking forward-moving model statement, BACKTRACK+parse_mode interaction verification). |
| Phase 4 | `done` | Capture/mark API formalization and clearer staged-extraction authoring primitives. | Task tree `docs/tasks/PHASE4-CAPTURE-MARK-API.md` completed 2026-05-17 (4 leaves: inventory, compat alias doc verification, mark-helper reference verification, finalize). |
| Phase 5 | `done` | Runtime modernization, diagnostics consistency, and reduced dynamic-eval fragility. | Task tree `docs/tasks/PHASE5-RUNTIME-DIAGNOSTICS.md` completed 2026-05-17 (2 leaves: inventory, stderr leak fix). |
| Phase 6 | `done` | User/developer documentation, architecture rationale, and live project-state upkeep. | Task tree `docs/tasks/PHASE6-DOCUMENTATION.md` completed 2026-05-17 (8 leaves: inventory, LinkedRE, Validation, public API, cross-linking, overviews, ActionIR lowering, per-spec walkthroughs). All documentation gaps closed. |
| Phase 7 | `done` | Self-hosted `spec.spec` grammar and `.spec` evolution through the DSL itself. | Task tree `docs/tasks/PHASE7-SELF-HOSTED-SPEC.md` completed 2026-05-17 (5 leaves: language surface inventory, structural rules, DSL rules, regression coverage, extension-surface policy). |
| Phase 8 | `done` | Multi-backend specification and handoff surface | Task tree `docs/tasks/PHASE8-MULTI-BACKEND-HANDOFF.md` completed 2026-06-14 (8 leaves). Specification-only — zero code changes. |
| Phase 9 | `done` | Rust variant implementation — LinkedSpec runtime in Rust. | Task tree `docs/tasks/PHASE9-RUST-VARIANT.md` completed 2026-06-14 (17 leaves). Cargo workspace at rust/: linkedspec-core + linkedspec-runtime. Interpreted mode. 28 unit tests. v0.1 operational. |
| Backbone refactor track | `done` | Cross-cutting structural cleanup needed to make LinkedSpec robust, modular, and extensible. | All items complete. |
| Backbone Item 1 | `done` | Declarative bootstrap grammar registry replacing positional bootstrap coupling. | Declarative bootstrap registry landed. |
| Backbone Item 2 | `done` | Staged `spec_entry()` compiler pipeline around RuleIR and explicit planning/validation phases. | Staged `spec_entry()` RuleIR pipeline landed. |
| Backbone Item 3 | `done` | Structured ActionIR/rewrite/lowering pipeline replacing ad hoc helper regex-chain rewriting. | Task tree `docs/tasks/BACKBONE-ACTION-IR-LOWERING.md` completed 2026-05-17 (1 leaf: owner-contract audit verified all 12 ActionIR owners clean). Finish the remaining ActionIR/EmitContext owner-contract cleanup and compatibility-surface reduction; `LinkedSpec::ActionIR::ScannerCore` now also centralizes both the scanner-rule family registry and the scanner dependency contract, with scanner-rule rebinding symbols derived straight from that dep-spec table instead of living in a second hardwired registry and `_scanner_rule_dep_bindings(...)` now serving as the sole local scanner-callback validation seam, `LinkedSpec::ActionIR::StatementSplit` now keeps `_split_action_ir_statements(...)` as its sole local statement-splitting seam instead of a second top-level validator wrapper and now lazy-loads `StatementSplit::Core` directly inside that seam instead of a single-use core-loader wrapper, `LinkedSpec::ActionIR::CanonicalEvents` now keeps `_build_canonical_action_ir_events(...)` as its sole local canonical-event dependency seam instead of a second top-level validator wrapper and now lazy-loads `CanonicalEvents::Core` directly inside `_canonicalize_helper_action_ir_event(...)` instead of a single-use core-loader wrapper, `LinkedSpec::ActionIR::Diagnostics` now keeps `_find_unresolved_action_helpers(...)` and `_collect_action_helper_ir_nodes(...)` as its local diagnostics seams instead of a second top-level validator wrapper, `LinkedSpec::ActionIR::RewritePipeline` now keeps `_build_action_rewrite_rules(...)` and `_rewrite_action_code_with_diagnostics(...)` as its local rewrite seams instead of a second top-level validator wrapper, `LinkedSpec::ActionIR::ArrayPipeline` now keeps `_normalize_split_delimiter_expr(...)` and `_build_array_pipeline_plan_from_expr(...)` as its local array-pipeline seams instead of a second top-level validator wrapper, `LinkedSpec::ActionIR::Contracts` now keeps `_require_lowering_deps(...)` as its sole local lowering-dependency seam instead of a second top-level validator wrapper, `LinkedSpec::ActionIR::DeclareMethod` now keeps its declare/assign lowering helpers as the direct callback-validation seams instead of a second top-level validator wrapper, `LinkedSpec::ActionIR::ValueExpr` now keeps its value-expression lowering helpers as the direct callback-validation seams instead of a second top-level validator wrapper, `LinkedSpec::ActionIR::FlowExpr` now keeps its flow-expression lowering helpers as the direct callback-validation seams instead of a second top-level validator wrapper, `LinkedSpec::ActionIR::ControlFlow` now keeps its control-flow lowering helpers as the direct callback-validation seams instead of a second top-level validator wrapper, `LinkedSpec::ActionIR::MethodLowering` now keeps its method/value/assignment/return lowering helpers as the direct callback-validation seams instead of a second top-level validator wrapper, and `RuleIR::EmitContext` now treats its owner-key registry plus shared dispatcher as the sole package/callback-loading seam on that bridge. |
| Method-like DSL migration track | `done` | Backend-neutral method-style `.spec` action syntax with equivalent fluent-chain and structured-block surfaces for the helper families locked by that track; newer fluent block-control and deeper composability surfaces landed under `SPEC-FORMAT-TERSE.2.3`, with the historical `RUST-PARITY.7.5.3` action-edge fluent frontier reconciled done. | Task tree `docs/tasks/METHOD-LIKE-DSL-MIGRATION.md` completed 2026-05-17 (5 leaves). The terse follow-on has landed the Round 1/2 terse helper, mutation, block, control-flow, receiver-chain, and numeric-alias surfaces on Perl/Rust and is now closed through `SPEC-FORMAT-TERSE.13.5`. `SPEC-FORMAT-TERSE.4` owns user-defined pure functions. The blocking `PERL-ACTIONIR-AST-MIGRATION` is complete: values, helper calls, receiver chains, return payloads, assignment/mutation statements, helper-call statements/returns, block-value statements, and structured control-flow now consume typed AST nodes; `.5.2` lowers supported standalone value statements as discarded `VALUE_DROP` nodes; `.5.3.1` retired `s(...)`/`a(...)`/`h(...)`; `.5.3.2` diagnoses return/value-position unknown typed calls; and `.5.4` locks permanent `fn` grammar ownership to `specs/spec.spec` while proving bootstrap has no current first-class `fn` support. `SPEC-FORMAT-TERSE.3.3.4` closed assignment-expression docs/compatibility after `.3.3.3`; public examples now prefer `set(...)`/operators, `assign(...)` remains a legacy alias, phase0 was 1015 green at that closure, and no concrete `SPEC-FORMAT-TERSE` PNT-eligible leaf remained at that time. `RUST-PARITY.7.5.2` closed the Lispish recursive shipped-spec blocker temporarily, bringing the oracle corpus to 63 fixtures; `SCALAREF-RETIREMENT.3/.4/.5` then migrated the fixture to direct access, removed `scalaref(...)` implementation support, swept final drift, and closed the retirement tree. `RUST-PARITY.7.2` then fixed Rust captures-only helper indexing, added two `hlink_substitution` raw-string oracle fixtures, and brought the corpus to 65 fixtures; `.7.3.3.2` added the JSON-safe `{abc}` curly fixture and brought the corpus to 66 fixtures; `.7.3.3.3` deferred bracket/mixed hlink scalar-ref fixtures behind `.7.3.3.4`; `.7.3.4` reproduced `portmap`/`lib_reader`/`ebnf` structural mismatches; `.7.3.4.1` fixed the Rust parser/compiler header-rest action-edge drop; `.7.3.4.4` added statement-form helper mutation parity plus two `lib_reader` oracle fixtures; `.7.3.4.2` added `portmap` scalar helper/list-context/regex-dispatch parity plus four `portmap` oracle fixtures; later terse leaves lifted the corpus to 74 fixtures; `.7.3.4.3` added action-edge child/target aggregation parity plus `portmap_concatenation`, `ebnf_expression_rules`, and `ebnf_logging_annotation`, bringing the Rust oracle corpus to **77 fixtures**; `.7.3.5` added four `spec.spec` smokes after null-output triage; `.7.3.6` added seven RTL/plugin/legacy safety smokes; `.7.4` finalized the manifest-backed oracle corpus guard; TOP-RULE-AS-NORMAL.3.2 added three recursive top-rule value fixtures; later terse leaves and SPEC-SOURCE-TERSE-CLOSEOUT.1 lifted the current Rust oracle corpus to **99 fixtures** with drift detection. |
| Terse declaration retirement | `done` | Overall roadmap — `.spec` language evolution (terse format) | `SPEC-FORMAT-TERSE.6.4` closed shipped-spec declaration migration, and `SPEC-FORMAT-TERSE.8.3`/`.8.4` have now hard-retired the remaining Perl/Rust legacy helper execution paths. Shipped specs, current-facing mdBook examples, root checked-in corpus specs, and generated oracle inputs use auto-existing variables, assignments, direct shape literals, `push(...)`, explicit `is_nonempty(...)` guards, `copy(...)`, `cat(...)`, `array(...)`, `hash(...)`, and receiver `.copy()`. Retired `declare(...)`, old copy/concat/append helper spellings, and wrapper aliases are diagnostic or historical only. |
| Terse type-method surface | `done` | Overall roadmap — `.spec` language evolution (terse format) | `SPEC-FORMAT-TERSE.7.1` completed the pre-code inventory. `SPEC-FORMAT-TERSE.7.2` verified the string/scalar family with no implementation change: `substr()` and the other useful pure string links are already receiver methods on Perl/Rust, and docs/tests demonstrate helper/method equivalence. `SPEC-FORMAT-TERSE.7.3` added terminal array/list numeric reducer receiver methods (`sum`, `avg`, `median`, `range`, `min`, `max`) on Perl/Rust, kept hash/number mutation or ambiguous helpers explicit, and lifted phase0 to **1021 green** plus the Rust oracle corpus to **74 fixtures**. `SPEC-FORMAT-TERSE.7.4` closed the no-drift sweep by reconciling current roadmap/task-tree/mdBook/KM receiver-family summaries. The type-method lane is closed; later `SPEC-FORMAT-TERSE.15` colon scalar-slot retirement is closed through `.15.5`. User directive 2026-07-08 reactivated `SPEC-FORMAT-TERSE.12`; `.12.2` landed the Perl reference hash-tree attached-block traversal, `.12.3` landed Rust parity plus the 96th oracle fixture, and `.12.4` closed docs/KM/no-drift closeout. User directive 2026-07-08 then reactivated `.13`; `.13.3` landed Rust/oracle parity for array-tree traversal as the 97th fixture, `.13.4` closed final no-drift alignment, and `.13.5` reconciled the parent `SPEC-FORMAT-TERSE` task tree closed. |
| RUST-PARITY structural mismatch triage | `done` | Phase 9 — Rust variant (parity follow-on) | `RUST-PARITY` closed on 2026-07-04. The Rust oracle corpus is green over **91 fixtures** plus manifest missing/stale drift tests, including three recursive top-rule value fixtures; richer legacy/plugin mismatches remain recorded follow-up blockers rather than unsafe fixture promotions. The generated-source emitter lane is also closed: `.8.1` split the code-generation boundary, `.8.2` added the minimal generated-source scaffold/compile-run harness, `.8.3.*` closed non-REP generated-family plan/direct execution/matrix coverage, `.8.4` added direct generated execution for REP acode, REP bcode, REP-AND acode, and REP-AND bcode with bounds/termination coverage, `.8.5` connected generated-source validation to a manifest-backed 8-case oracle corpus subset, and `.9` finalized roadmap/live-doc/book/architecture alignment. Limitation: generated-source corpus proof is curated; the full 91-fixture gate remains the interpreter oracle until a later generated-source corpus-expansion leaf exists. `TOP-RULE-AS-NORMAL.3.2`, `TRACE-OBSERVABILITY.1`, and `TRACE-OBSERVABILITY.2` have since closed; `.3` has split, `.3.1` added the generated-handler helper seam, `.3.2` added non-repetition generated dispatch tracing, `.3.3` added repetition generated path tracing, `.3.4` split compile/ActionIR trace coverage, `.3.4.1` added RuleIR planning trace decisions, `.3.4.2` added EmitContext owner-bridge trace decisions, `.3.4.3` added scanner/canonical/diagnostic/rewrite-pipeline trace decisions, `.3.4.4` added compact lowerer trace decisions, `.3.4.5` added MethodLowering trace decisions, `.3.4.6` closed compile/ActionIR trace coverage, `.3.5` closed trace contract no-drift and split backend parity, `.4.2` added Rust trace controls/sinks, `.4.3` added Rust compile/spec-parser/staged-dispatch trace events, `.4.4` added Rust interpreted-runtime and generated-plan runtime trace events, and `.4.5` has since closed the trace parity proof, so no `TRACE-OBSERVABILITY` frontier remains. |
| Trace observability | `done` | Overall roadmap — engine observability / developer experience | Perl reference trace coverage now has discoverable CLI control plus debug-level generated-handler, RuleIR, EmitContext, ActionIR pipeline, compact lowerer, and MethodLowering decision coverage. `TRACE-OBSERVABILITY.3.5` closed the neutral mdBook trace contract/no-drift leaf and split required backend parity. `TRACE-OBSERVABILITY.4.1` mapped the documented trace contract onto Rust entrypoints and owner boundaries before code. `TRACE-OBSERVABILITY.4.2` added core-visible Rust trace controls, levels, sinks, event primitives, and opt-in traced entrypoints while preserving default quiet behavior. `TRACE-OBSERVABILITY.4.3` added Rust compile/spec-parser/staged-dispatch trace events for core parse/validation/compile, full-spec user-function parsing, and staged parse-job normalize/resolve/load/compile/execute phases. `TRACE-OBSERVABILITY.4.4` added Rust interpreted-runtime and generated-plan runtime branch/lifecycle/mark-capture events, and `.4.5` closed cross-variant trace parity proof plus the future-variant checklist. The trace tree is closed; Rust can claim parity for the documented external trace capability contract. |
| Staged linked parsing track | `in progress` (first prototype complete) | Language-neutral parser composition: stage-N specs parse anchored outer structure, emit source-provenance text islands, and route those payloads to one or more later `.spec` parsers through deterministic parse jobs. | `.1` adopts the doctrine; `.2` specifies future spec import/composition; `.3` specifies future `parse_job(text_expr, options)` annotations; `.4` specifies deterministic registry/dispatch queue semantics, cache keys, capability/version boundaries, and cycle diagnostics before implementation; `.5.1` selects user-function body text as the first prototype payload family and makes 100% implementation-language neutrality a hard gate; `.5.2` defines the wrapper-top small-spec harness, named-capture requirement, current zero-arg/regex-brace gaps, neutral returned `function_definition` AST shape, and variation matrix before code; `.5.3.1` adds `specs/user_function_definition.spec` as the executable grammar owner for user-function definition AST shape and makes the Perl registry consume that returned AST instead of raw-scanning definitions; `.5.3.2` makes Rust consume the same spec-returned AST contract and removes the remaining raw Rust definition parser bridge; `.5.4` adds the neutral `body_parse_job` sidecar with deterministic job id, parser identity, top rule, result/failure policies, exact text, and source span; `.5.5` adds the minimal registry/dispatch path that resolves `actionir-body.spec`, compiles `action_block`, executes function-body parse jobs in stable order, and stitches `body_ast`; `.5.6` proves the staged function-body prototype end to end on Perl/Rust with descriptor/parsed/compiled AST-shape assertions, runtime stability, source-provenance diagnostics, and public docs. General public `parse_job(...)` authoring, provider/import search roots, multiple payload parser families, recursive staged queues, and cycle diagnostics remain future work needing new leaves. Current staged frontier is empty; the trace tree has since closed, so PNT returns to the active task-tree index unless a new staged linked parsing leaf is split or another active tree is reprioritized. |
| Plugin/resource-resolution modernization track | `done` | Keep deterministic spec/resource lookup, while retiring dynamic `.plg`/plugin execution support. | Task tree `docs/tasks/PLUGIN-MODERNIZATION.md` completed 2026-05-17 (5 leaves). Facade deprecated, FSMGen de-scoped, 2 dead .plg files removed, retirement path documented. 36 .plg files (~1,200+ actions) remain — follow-on `PLUGIN-ACTION-MIGRATION` tree was retired (all 5 leaves done; 17 dead files deleted; 19 kept as legacy corpus). | Named spec resolution remains a real framework responsibility, but dynamic plugin loading is now treated as legacy behavior to remove rather than preserve. Existing `run_plugin(...)`, `get_plugin(...)`, registry, and package-backed extraction work should be understood as transitional removal machinery that helps unwind `.plg`/`PPlugin` usage safely while keeping `get_parser('name')`-style spec lookup intact. Extracted helper owners now live outside `LinkedSpec::*` under clearer non-plugin/domain owners such as `HTTP::FileAccess`, `HTML::PathLinks`, `InteractivePrompt`, `Text::VariableSubstitution`, `VHDL::ConstantEval`, `MSOffice::Excel`, `QC::Flow`, `QC::Summary`, `QC::TclInterconn`, `RTLUtils`, `FSMGen`, `Timing::SetupHold`, `Timing::StanBackend`, `Timing::StanOmap2430cBackend`, and `Table::GenericFilter`; the HTTP file-access owner now also owns the host-setting helpers plus former `http` / `lighttpd` / `httpd` actions; `Table::GenericFilter` now owns the generic table grouping actions; `QC::Summary` now owns the former private `qc_summary_merge` row-merging helper; `QC::Flow` now owns the former private `qc_pushonce` qclog insertion helper plus QC budget-check, filter-expression, clock CTS summary, qclog workbook/link, and qclog table-preparation helpers; `QC::TclInterconn` now owns the former `tcl4interconn`, `tcl4fanx`, and `get_fanxinfo` helper bodies for repo-owned QC flow calls, and the obsolete standalone `plugin/tcl4interconn.plg` wrapper is gone; `RTLUtils` now owns the former private `get_log2` address-width helper as `ceil_log2(...)` plus the VHDL header/context-clause helper formerly reached through `add_header_n_context_clause`, and the obsolete `plugin/fsmgen.plg::add_header_n_context_clause` wrapper is gone too; `FSMGen` now owns dynamic `+type=plugin#args...` plugin-list parsing as `getop_plugin_list(...)`, and the obsolete `plugin/fsmgen.plg::getop_plugin_list` wrapper is gone too; `Timing::SetupHold` now owns setup/hold timing formulas plus the visible `tssio` action body that used to live in `.plg`; `Timing::StanBackend` now owns the former private `stan_backend_start` setup helper and `minmax_clockmx_cellcode` clock-matrix cell formatter; `Timing::StanOmap2430cBackend` now owns the former private STAN OMAP STA-frequency callback, frequency-detail helper family, report writers, TCK-delay DM-measures writer, no-path checker, and port-timing traversal callback; direct table parsing helpers use `Table::list2table(...)` instead of the removed `table.plg` wrapper; and direct Perl callers have started moving to those package owners instead of routing through LinkedSpec plugin dispatch. **Update (2026-06-22):** those extracted package owners and the `.plg` corpus have since left the active core — the Perl-only VHDL/RTL/FSM-generation subsystem (`RTLUtils` / `FSMGen` / `VHDL::ConstantEval` + 6 dependent `.plg`) was deleted (`LEGACY-VHDL-RETIRE`) and every remaining domain owner plus the 13 surviving `.plg` relocated to `noncore/` (`NONCORE-QUARANTINE`), so `perl/` is now core-only and `t/phase0_regression.t` is green (960/960) without any of them. |

Owner-dispatch cleanup note:
- `Runtime::run_get(...)` now calls the shared runtime-context top-rule handler label helper directly for runtime-owner fallback diagnostics, so the one-shot `_runtime_owner_handler_source_label(...)` wrapper is gone too.
- `ParserFactory::run_get_parser(...)` now calls the shared runtime-context top-rule handler label helper directly for parser-factory fallback diagnostics, so the one-shot `_parser_factory_handler_source_label(...)` wrapper is gone too.
- Compiler top-rule-only fallback diagnostics now call the shared runtime-context top-rule handler label helper directly, so the one-shot `_compiler_top_rule_handler_source_label(...)` wrapper is gone too.
- Rule-attributed compiler diagnostics now call the shared runtime-context rule-or-top handler label helper directly, so the one-shot `_compiler_rule_or_top_handler_source_label(...)` wrapper is gone too.
- Compiler final parser-source output now calls the shared runtime-context flush helper directly, so the one-shot `_flush_runtime_ctx_parser_source(...)` wrapper is gone too.
- Parser invocation now calls the shared runtime-context last-error read helpers directly when preserving deeper runtime-handler context, so the one-shot `_has_runtime_ctx_last_error_type(...)` and `_get_runtime_ctx_last_error_detail(...)` wrappers are gone too.
- Compiler selected-top-rule writes now call the shared runtime-context setter directly, so the one-shot `_set_runtime_ctx_top_rule(...)` wrapper is gone too.
- Compiler selected-top-rule reads now call the shared runtime-context getter directly, so the one-shot `_get_runtime_ctx_top_rule(...)` wrapper is gone too.
- Compiler stale-error cleanup now calls the shared runtime-context clearer directly, so the one-shot `_clear_runtime_ctx_last_error(...)` wrapper is gone too.
- Compiler parser-source emission now calls the shared runtime-context emitter directly, so the pass-through `_emit_runtime_ctx_parser_source_line(...)` wrapper is gone too.
- Low-level rule-table setup now inlines `top_rule` selection before calling the shared runtime-context preparation helper directly, so the one-shot `_prepare_runtime_ctx_for_build_compiled_rule_table(...)` wrapper is gone too.
- `Compiler::run_get_pipeline(...)` now checks validation callback availability directly through `OwnerDispatch`, so the one-shot `_require_validation_pkg(...)` wrapper is gone too.
- Compiler trace helpers now load `LinkedSpec::Trace` directly through `OwnerDispatch`, so the `_require_trace_pkg(...)` loader wrapper is gone too.
- Compiler-pipeline error boundaries now call the shared last-error helper directly, so the pass-through `_set_runtime_ctx_last_error(...)` wrapper is gone too.
- Final-descriptor failure attribution now reads the active dependency-regex label directly, so the one-shot `_get_active_dependency_regex_rule_label(...)` wrapper is gone too.
- Dependency-regex boundaries now reset the transient active label directly, so the one-shot `_clear_active_dependency_regex_rule_label(...)` wrapper is gone too.
- Validation and bootstrap-parse boundaries now reset scalar input position directly, so the small `_reset_spec_content_pos(...)` wrapper is gone too.
- Rule-table preparation and final top-rule selection now derive the first parsed rule label directly, so the small `_first_parsed_rule_label(...)` wrapper is gone too.
- Final-descriptor failures now trim trapped error detail directly at the last-error write, so the one-shot `_normalize_error_detail(...)` wrapper is gone too.
- Top-level parser invocation now builds invalid input-ref diagnostics directly at the runtime-parser last-error write, so the one-shot `_describe_parser_input_ref(...)` wrapper is gone too.
- Invalid bootstrap-parse result diagnostics now build their detail directly at the last-error write, so the one-shot `_bootstrap_parse_result_detail(...)` wrapper is gone too.
- The pipeline fallback now reads retained rule-table failure detail directly, so the one-shot `_get_last_build_compiled_rule_table_failure_detail(...)` wrapper is gone too.
- Rule-table and pipeline boundaries now reset retained failure detail directly, so the one-shot `_clear_last_build_compiled_rule_table_failure_detail(...)` wrapper is gone too.
- Rule-table failure sites now write retained failure detail directly, so the one-shot `_set_last_build_compiled_rule_table_failure_detail(...)` wrapper is gone too.
- Invalid parsed-entry-list diagnostics are now built directly at the rule-table boundary, so the one-shot `_describe_build_compiled_rule_table_entries_result(...)` wrapper is gone too.
- Invalid per-entry diagnostics are now built directly at the rule-table boundary, so the one-shot `_describe_build_compiled_rule_table_entry_result(...)` wrapper is gone too.
- Invalid compile-spec-entry tuple diagnostics are now built directly at the rule-table boundary, so the one-shot `_describe_compile_spec_entry_result(...)` wrapper is gone too.
- Invalid descriptor-state diagnostics are now built directly at the final descriptor boundary, so the one-shot `_describe_final_descriptor_state_result(...)` wrapper is gone too.
- Invalid compiled dependency-regex normalization diagnostics are now built directly inside the `CompilerState` callback, so the one-shot `_describe_final_descriptor_dependency_regex_result(...)` wrapper is gone too.
- Invalid compiled-spec input diagnostics are now built directly inside the `CompilerState` callback, so the one-shot `_describe_build_dependency_regex_map_spec_result(...)` wrapper is gone too.
- Invalid rule-info diagnostics are now built directly at the dependency-regex map validation boundary, so the one-shot `_describe_build_dependency_regex_map_rule_info_result(...)` wrapper is gone too.
- Invalid dependency-list diagnostics are now built directly at the dependency-regex map validation boundary, so the one-shot `_describe_build_dependency_regex_map_rule_dependency_refs_result(...)` wrapper is gone too.
- Invalid dependency-ref diagnostics are now built directly at the dependency-regex map validation boundary, so the one-shot `_describe_build_dependency_regex_map_dependency_ref_result(...)` wrapper is gone too.
- Invalid dependency-label diagnostics are now built directly at the dependency-regex map validation boundary, so the one-shot `_describe_build_dependency_regex_map_dependency_label_result(...)` wrapper is gone too.
- Invalid dependency-index diagnostics are now built directly at the dependency-regex map validation boundary, so the one-shot `_describe_build_dependency_regex_map_dependency_index_result(...)` wrapper is gone too.
- Missing dependency-rule diagnostics are now built directly at the dependency-regex map validation boundary, so the one-shot `_describe_build_dependency_regex_map_dependency_rule_missing(...)` wrapper is gone too.
- Invalid referenced dependency-rule info diagnostics are now built directly at the dependency-regex map validation boundary, so the one-shot `_describe_build_dependency_regex_map_dependency_rule_info_result(...)` wrapper is gone too.
- Invalid referenced regex-list diagnostics are now built directly at the dependency-regex map validation boundary, so the one-shot `_describe_build_dependency_regex_map_dependency_re_result(...)` wrapper is gone too.
- Rule-table build now asks `CompilerState` for new compiled-spec state directly through the shared owner seam, so the pass-through `_new_compiled_spec_state(...)` wrapper is gone too.
- Compiler-pipeline validation now asks `CompilerState` directly through the shared owner seam, so the pass-through `_is_compiled_spec_state(...)` wrapper is gone too.
- Trace and parser-generation rule-count reads now ask `CompilerState` directly through the shared owner seam, so the pass-through `_compiled_spec_state_rule_count(...)` wrapper is gone too.
- The unused compiled-spec rules-by-label mirror is gone too; `CompilerState` remains the only owner for rules-by-label map access instead of `Compiler.pm` carrying a local pass-through.
- Dependency-regex referenced-rule existence checks now ask `CompilerState` directly, so the pass-through `_compiled_spec_state_has_rule(...)` wrapper is gone too.
- Dependency-regex referenced-rule metadata lookup now asks `CompilerState` directly, so the pass-through `_compiled_spec_state_rule_info(...)` wrapper is gone too.
- The unused compiled-rule-order mirror is gone too; `CompilerState` remains the only owner for compiled rule ordering instead of `Compiler.pm` carrying a local pass-through.
- Dependency-regex map iteration now asks `CompilerState` directly for compiled rule rows, so the pass-through `_compiled_spec_state_rule_rows(...)` wrapper is gone too.
- Compiled-state trace output now asks `CompilerState` directly for definition order, so the pass-through `_compiled_spec_state_definition_order(...)` wrapper is gone too.
- Compiled-state trace reporting now asks `CompilerState` directly for redefined rule labels, so the pass-through `_compiled_spec_state_redefined_rule_labels(...)` wrapper is gone too.
- Compiled-spec metadata ownership remains solely with `CompilerState`, so the unused pass-through `_compiled_spec_state_meta(...)` wrapper is gone too.
- Compiled dependency-regex state shape checks remain solely with `CompilerState`, so the unused pass-through `_is_compiled_dependency_regex_state(...)` wrapper is gone too.
- Compiled dependency-regex by-label access remains solely with `CompilerState`, so the unused pass-through `_compiled_dependency_regex_state_regex_by_label(...)` wrapper is gone too.
- Compiled dependency-regex legacy-map projection remains solely with `CompilerState`, so the unused pass-through `_compiled_dependency_regex_state_to_dependency_regex_map(...)` wrapper is gone too.
- Compiled descriptor spec-state access remains solely with `CompilerState`, so the unused pass-through `_compiled_descriptor_state_spec_state(...)` wrapper is gone too.
- Compiled descriptor dependency-regex-state access remains solely with `CompilerState`, so the unused pass-through `_compiled_descriptor_state_dependency_regex_state(...)` wrapper is gone too.
- Compiled descriptor dependency-regex by-label access remains solely with `CompilerState`, so the unused pass-through `_compiled_descriptor_state_dependency_regex_by_label(...)` wrapper is gone too.
- Compiled descriptor rules-by-label access remains solely with `CompilerState`, so the unused pass-through `_compiled_descriptor_state_rules_by_label(...)` wrapper is gone too.
- `SpecEntry` discovered top-rule writes now call the shared runtime-context setter directly, so the one-shot `_set_runtime_ctx_top_rule(...)` wrapper is gone too.
- `SpecEntry` generated-handler parser-source emission now calls the shared runtime-context emitter directly, so the pass-through `_emit_runtime_ctx_parser_source_line(...)` wrapper is gone too.
- `SpecEntry` rule-handler compile/eval errors now call the shared runtime-handler last-error helper directly, so the pass-through `_set_runtime_ctx_last_error(...)` wrapper is gone too.
- `SpecEntry::compile_spec_entry(...)` now reads the optional runtime context dependency inline, so the one-shot `_runtime_ctx_from_deps(...)` wrapper is gone too.
- `SpecEntry::compile_spec_entry(...)` now checks RuleIR callback availability directly through `OwnerDispatch`, so the one-shot `_require_rule_ir_pkg(...)` wrapper is gone too.
- `SpecEntry::compile_spec_entry(...)` now checks emit-context callback availability directly through `OwnerDispatch`, so the one-shot `_require_emit_context_pkg(...)` wrapper is gone too.
- `SpecEntry` trace wrappers now load `LinkedSpec::Trace` directly through `OwnerDispatch`, so the `_require_trace_pkg(...)` loader wrapper is gone too.
- `ParserFactory::run_get_parser(...)` now calls the shared runtime-context preparation helper directly, so the one-shot `_prepare_runtime_ctx_for_get_parser(...)` wrapper is gone too.
- `ParserFactory::run_get_parser(...)` now calls the shared runtime-context spec-path setter directly, so the one-shot `_set_runtime_ctx_spec_path(...)` wrapper is gone too.
- `ParserFactory::run_get_parser(...)` now calls the shared preserve-existing last-error helper directly, so the pass-through `_set_runtime_ctx_last_error_unless_present(...)` wrapper is gone too.
- `ParserFactory::run_get_parser(...)` now calls the shared parser-factory last-error writer directly, so the pass-through `_set_runtime_ctx_last_error(...)` wrapper is gone too.
- `Runtime::run_get(...)` now calls the shared runtime-context preparation helper directly, so the one-shot `_build_runtime_context(...)` wrapper is gone too.
- `Runtime` no longer carries an unused direct last-error setter wrapper; its live fallback writes stay on the preserve-existing last-error path.
- `Runtime::run_get(...)` now calls the shared preserve-existing last-error helper directly, so the pass-through `_set_runtime_ctx_last_error_unless_present(...)` wrapper is gone too.
- `Runtime::run_get(...)` now resolves the compiler pipeline callback directly through `OwnerDispatch`, so the one-shot `_run_get_pipeline_cb(...)` wrapper is gone too.
- `ParserFactory::run_get_parser(...)` now validates required trace-level values inline beside its callback dependency checks, so the one-shot `_require_value_dep(...)` wrapper is gone too.

Plugin modernization note:
- `LinkedSpec::PluginBridge` still exists as transition machinery, but its default dependency callback map now builds through `LinkedSpec::OwnerDispatch::build_dep_map(...)`, and its registered-plugin lookup plus legacy `PPlugin` runtime loading spend the shared owner-dispatch seam instead of carrying local eval-require / `$@` preservation branches or a single-use generic package-loader wrapper.
- `PPlugin` still exists as the legacy `.plg` adapter, but its default `pplugin` parser callback now also loads through `LinkedSpec::OwnerDispatch` instead of a local `eval { require LinkedSpec }` branch; the callback remains lazy and only fires when the legacy registry loader actually needs to parse `.plg` files.
- `PPlugin` now also treats `_load_legacy_registry(...)` as its direct parser/discovery/registry dependency-validation seam instead of keeping a second top-level `_require_dep(...)` wrapper above it.
- `PPlugin` registry construction now reads plugin files through an explicit helper instead of localized diamond-reader state, reports unreadable/malformed files as skipped entries, and preserves caller `$@` after successful partial registry builds.
- The shipped `.plg` plugin corpus and the legacy domain-utility owners these notes describe are **no longer in the active `perl/` tree**: the Perl-only VHDL/RTL/FSM-generation subsystem (`RTLUtils`, `FSMGen`, `VHDL::ConstantEval` + their six exclusively-dependent `.plg`) was **deleted** (`LEGACY-VHDL-RETIRE`), and every remaining non-core domain owner (`HTTP::FileAccess`, `HTML::PathLinks`, `InteractivePrompt`, `Text::VariableSubstitution`, `MSOffice::Excel`, `QC::Flow`, `QC::Summary`, `QC::TclInterconn`, `Table::GenericFilter`, `Timing::SetupHold`, `Timing::StanBackend`, `Timing::StanOmap2430cBackend`, plus the flat domain `.pm`) and the 13 surviving `.plg` were **relocated to `noncore/`** (`NONCORE-QUARANTINE`). The root `plugin/` directory no longer exists; `perl/` is core-only and `t/phase0_regression.t` is green (960/960) without any of them. The earlier `generic_fake_memory_module.plg` / `wrapgen.plg` / `ceil_log2` references were doubly stale (those `.plg` had already been deleted) and are gone. `git log` (`LEGACY-VHDL-RETIRE`, `NONCORE-QUARANTINE`) holds the per-helper migration detail; `LinkedSpec::get_parser(...)` / `get_plugin(...)` remain the live deterministic lookup APIs on the core facade.

DSL helper surface consistency note:
- **Historical auto-existence milestone (terse format, ADR `0007`; `SPEC-FORMAT-TERSE.1.1.1` Perl reference + `.1.1.2` Rust lockstep parity, 2026-06-24).** At that milestone a working variable referenced through a typed wrapper — `scalar(NAME)`/`array(NAME)`/`hash(NAME)` or the `s()`/`a()`/`h()` aliases — no longer needed a prior `declare(...)`. **Perl reference (`.1.1.1`):** the engine auto-supplied one preamble `my $NAME`/`@NAME`/`%NAME` so it was a per-invocation lexical, not a leaky package global (generated handlers run non-strict). All 20 then-shipped specs already declared their working vars, so they generated byte-identical source (only the previously-undeclared `tkgui::subgui_name` gained a `my`, behavior-preserved); phase0 was 968 green. **Rust lockstep parity (`.1.1.2`): achieved with NO engine change** — the Rust variant is an interpreter, so working vars live in per-parse `RuntimeContext` maps that auto-vivify and are fresh per `execute`. `FUTURE-PARITY-BACKLOG.12.1` later superseded and removed the exact aggregate-selector forms; current authoring uses bare typed bindings, assignments, and direct shape literals.
- **Terse helper renames are recognized on both variants and the old helper names are now retired (`SPEC-FORMAT-TERSE.1.4.1` / `.1.4.2`, then hard-retired by `.8.3` / `.8.4`).** Current canonical spellings are `set(...)` instead of `assign`, `cat(...)` instead of `concat`, and unified `copy(...)` instead of the former shape-specific copy names. The deprecated-alias period from ADR `0007` is historical: current Perl/Rust behavior diagnoses those old spellings instead of executing them successfully.
- **The terse mutation surface is split by mechanism (`SPEC-FORMAT-TERSE.1.3`, 2026-06-29; `.1.3.2` array function spelling, `.1.3.3` hash mutation, `.1.3.4.1` scalar assignment operator, `.1.3.4.2` array append operator, and `.1.3.4.3` hash-index assignment landed 2026-06-29).** Scalar function-form mutation is already satisfied by the landed `set(...)` alias, and top-level scalar operator `name = value` now lowers/runs identically to `set(name,value)` / `assign(name,value)` on both Perl and Rust. Array explicit append accepts both `push(target,value)` and `items += value` and keeps all-bare `push(A,B)` as the existing child-call convention (`A` rule into `B` accumulator). Hash mutation accepts both top-level `set_key(name,key,value)` and `name[key] = value` as named-hash mutation on both Perl and Rust, while value-form `set_key(hash_expr,key,value)` stays pure/copy-valued. Channel 2 scalar bare reads have since landed on both variants, so `items += value`, `set_key(meta,key,value)`, and `meta[key] = value` now read bare key/RHS identifiers as scalar working variables. Later `.3.3` leaves made `name = value`, `items += value`, and `meta[key] = value` expression-valued; append/hash-index expression use yields updated aggregate snapshots. `.1.3` / `.1.3.4` are closed.
- **Round 1 array end-mutation methods landed (`SPEC-FORMAT-TERSE.1.6`, 2026-06-29), closing Round 1.** Perl and Rust recognized statement-level receiver-dot mutations on named working arrays: `items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`, and `items.pop_front()`. At that historical milestone bare receivers and the now-removed `array(items)` / `a(items)` receiver forms named the same working array. `FUTURE-PARITY-BACKLOG.12.1` later retired the selector forms; current receiver authoring is bare. Pop methods discard the removed value, while push values use mutation-slot value semantics.
- **Round 2 expression-valued blocks are landed across Perl and Rust (`SPEC-FORMAT-TERSE.2.1.1` through `.2.1.4`, 2026-06-29/30), and control-flow keywords are split (`.2.2.1`, 2026-06-30).** Ground truth keeps `{}` and top-level hash-pair brace payloads as hash shape literals. Current source/docs/corpus examples now use `{ key : value }`; Perl and Rust reject old `{ key => value }` as retired current ActionIR hash-literal syntax and point authors to `{ key : value }`. Perl and Rust now treat non-empty brace payloads without a top-level hash pair separator as value blocks in value-consuming sites: the block yields its final expression unless execution reaches `return(expr)` first. That block-local `return(expr)` yields the payload, skips later statements inside the block, and does not leak into the surrounding rule return channel.
  Current portable cross-backend control-flow support is attached-block `if(cond) { ... } elseif(cond2) { ... } else { ... }`, attached-block `when(cond) { ... } otherwise { ... }` as aliases over `if/else`, attached-block `switch(expr) { case(v) { ... } default { ... } }` with first-match/default semantics, attached-block `while(cond) { ... }` with deterministic 10000-iteration safety, statement-marker `if(cond); ... else(); ... endif()`, and inline-composite lazy `if(...)` / `switch(...)` value helpers in supported value positions (`return(...)`, assignment RHS, and fluent `.return(...)`). Rust `.2.2.6.2` now parses and executes attached while bodies with the accepted Perl loop/safety contract and the documented numeric comparison helper family; the oracle corpus is **39 fixtures**.
  `.2.3` is split/owned before code into Perl fluent block-chain locking, lifecycle value/drop semantics, Rust fluent-block/action-edge parity, full composability audit, and return-type method chaining design. Perl fluent `.when(cond) { ... }.otherwise { ... }` and no-dot `otherwise` fallback continuations landed in `.2.3.1`; lifecycle blocks were locked as statement blocks in `.2.3.2` (final ordinary statement values discarded, top-level `return(expr)` uses the surrounding return channel, expression-valued block return stays local). Rust action-edge no-arg fluent `.push`, `.return(expr)`, and `.return_undef` landed in `.2.3.3.1`; Rust action-edge/lifecycle attached fluent `.when(cond) { ... }` block payloads with dotted and no-dot fallback tails landed in `.2.3.3.2`; Rust compact lifecycle/body receiver chains such as `I.return(...)` and `I.declare(...).return(...)` landed in `.2.3.3.3.1`; Rust action-edge explicit/flow fluent chains such as `.push(child,target)` and `.if(...).push(...).else().return_undef().endif()` landed in `.2.3.3.3.2`.
  `SPEC-FORMAT-TERSE.2.3.3.3.3.1` then landed Rust default-mode recursive repetition parity, restored the
  two minimal `tclite` fixtures, and brought the Rust oracle corpus to **41 fixtures**.
  `RUST-PARITY.7.5.3` has since been reconciled done from that action-edge fluent plus `tclite` corpus evidence,
  and `RUST-PARITY.7.5.2` temporarily landed Lispish `scalaref(retv, {content})` parity. `SCALAREF-RETIREMENT.3`
  migrated the active `lispish_x_y` fixture to direct access, and `SCALAREF-RETIREMENT.4` removed implementation
  support for the old helper. `RUST-PARITY.7.2` then fixed captures-only helper indexing and added two
  `hlink_substitution` raw-string fixtures, and `RUST-PARITY.7.3.3.2` added the JSON-safe `{abc}` curly fixture;
  `RUST-PARITY.7.3.4.4` added the `lib_reader_sattribute` and `lib_reader_cattribute` fixtures after Rust
  statement-form helper mutation parity landed, and `RUST-PARITY.7.3.4.2` added the four scalar `portmap`
  fixtures after boolean/list-context/regex-dispatch parity landed, `SPEC-FORMAT-TERSE.7.3` added the array
  numeric reducer receiver fixture, `RUST-PARITY.7.3.4.3` added `portmap_concatenation`,
  `ebnf_expression_rules`, and `ebnf_logging_annotation`, `RUST-PARITY.7.3.5` added the four `spec_spec_*`
  smoke fixtures, and `RUST-PARITY.7.3.6` added seven RTL/plugin/legacy safety smokes. Later terse leaves,
  TOP-RULE-AS-NORMAL.3.2, and `SPEC-SOURCE-TERSE-CLOSEOUT.1` have raised the current Rust oracle corpus to
  **99 fixtures**. The old bracket/mixed hlink scalar-ref deferral from `RUST-PARITY.7.3.3.3` is resolved by
  the hlink source migration to neutral string payloads.
  `SPEC-FORMAT-TERSE.2.3.4` audited full nested composability, added a green deep pure-helper oracle fixture
  (corpus **42 fixtures**), and split Rust helper-context aggregate bare reads plus Perl inline value-control
  lowering into `.2.3.4.1`/`.2.3.4.2`; `.2.3.4.1` landed Rust bare aggregate helper arguments for hash- and
  array-consuming helper slots (corpus **44 fixtures**), and `.2.3.4.2` landed Perl inline value-control
  lowering plus two oracle fixtures (corpus **46 fixtures**). `SPEC-FORMAT-TERSE.2.3.5` specified return-type
  method chaining before code and split implementation by receiver return family plus a block-valued receiver
  audit. `SPEC-FORMAT-TERSE.2.3.5.1` landed array receiver-dot value chains on Perl and Rust, bringing phase0
  to 996 green and the oracle corpus to 47 fixtures. `SPEC-FORMAT-TERSE.2.3.5.2` landed hash receiver-dot value
  chains, fixed Rust `merge_hash` later-argument override parity, and brought phase0 to 997 green plus the
  oracle corpus to 48 fixtures. `SPEC-FORMAT-TERSE.2.3.5.3` landed string receiver-dot value chains, including
  the explicit `split` bridge into array chains and Rust string-literal receiver parsing, bringing phase0 to
  998 green plus the oracle corpus to 49 fixtures. `SPEC-FORMAT-TERSE.2.3.5.4` landed number receiver-dot value
  chains, including numeric literal receivers, terminal comparisons, Perl value-form numeric comparisons, and
  Rust multi-operand `num_add`/`num_mul`, bringing phase0 to 999 green plus the oracle corpus to 50 fixtures.
  `SPEC-FORMAT-TERSE.2.3.5.6` historically locked the aggregate wrapper quoted-name boundary: the removed
  selectors `array(foo)` / `hash(bar)` read typed working variables, while quoted arguments remained constructor
  payloads. `FUTURE-PARITY-BACKLOG.12.1` later superseded those selectors; current reads are bare and direct
  `[...]` / `{...}` shapes are the preferred terse constructors. At that milestone phase0 was 1000 green and the oracle corpus
  has 51 fixtures. `SPEC-FORMAT-TERSE.2.3.5.5` landed block-valued receiver chaining by yielded runtime type,
  bringing phase0 to 1001 green and the oracle corpus to 52 fixtures. `SPEC-FORMAT-TERSE.5.0` then owned
  future variant parity before any non-Rust variant code. ADR `0021` later schedules future parity rollout as
  Dart first, Julia second, and Lua third under `FUTURE-PARITY-BACKLOG`. `SPEC-FORMAT-TERSE.3.1` then
  locked the existing edge syntax contract with no behavior change: `->` remains action edges, `=>` remains
  blind-call edges, grouped action targets require a shared block, and block-less grouping stays invalid.
  `SPEC-FORMAT-TERSE.3.2` split the arithmetic/comparison call surface before code because word aliases,
  symbol callees, and comparison-name policy are separate mechanisms. `SPEC-FORMAT-TERSE.3.2.1` then landed
  non-comparison numeric word aliases on Perl/Rust; `.3.2.3.2` added explicit `str_*` lexical string helpers,
  and `.3.2.3.3` flipped bare comparison word calls to numeric aliases.
  `SPEC-FORMAT-TERSE.4` now owns user-defined pure functions: calls are ordinary value expressions, may feed
  receiver-dot chains, and silently drop their value when used as standalone statements. `.4.1` locked the MVP
  contract before code: top-level `fn name(args) { ... }`, exact arity, eager argument evaluation, fresh
  function-local scope, pure value/block bodies, final-expression or `return(expr)` result, collision rejection,
  and no capture/recursion/closures/lambdas/currying/host-code escape. Function syntax must ultimately be
  represented in `specs/spec.spec`; bootstrap-parser `fn` support, if any, is temporary migration debt to remove
  after text-to-AST handoff. `.4.1` split implementation into Perl grammar/registry, Perl value-call execution,
  Perl discard/purity hardening, Rust registry, and Rust runtime/oracle parity leaves.
  `PERL-ACTIONIR-AST-MIGRATION.1` has now inventoried the Perl text-to-text lowering boundaries and locked the
  AST node set/replacement order. `PERL-ACTIONIR-AST-MIGRATION.2` added an additive
  `LinkedSpec::ActionIR::AST` parser seam behind existing behavior. `.3` is complete after focused value/receiver
  migration children. `.3.1` moved non-call value nodes onto AST lowering; `.3.2` split helper calls by
  argument-slot risk; `.3.2.1` moved value-only helper-call composition onto AST call nodes; `.3.2.2` moved
  deprecated wrappers plus aggregate/collection/reducer/hash helper calls onto slot-aware AST call lowering;
  `.3.2.3` now reports unsupported covered-helper calls as unresolved-helper diagnostics instead of generated
  host calls, `.3.3` now lowers receiver-dot `fluent_chain` value chains from typed AST receiver/call nodes,
  and `.3.4` now lowers typed return payloads from AST before raw fallback. `.4` is now split into focused
  statement/control children, `.4.1` now lowers assignment/mutation operator statements from AST fields,
  `.4.2` now lowers helper-call statements and returns from AST call/fluent-chain fields, `.4.3` now lowers
  block-value side effects and block-local returns from AST block/statement fields, `.4.4` split structured
  control-flow lowering by parser nodes and control family, `.4.4.1` parsed attached and marker control forms
  into typed AST nodes, `.4.4.2` lowers if/when/otherwise forms from typed condition/body nodes, `.4.4.3`
  lowers switch/case/default forms from typed source/match/body/default nodes, and `.4.4.4` lowers attached
  while forms from typed condition/body nodes. `.5.1` audited the fallback boundary before code, `.5.2` now
  lowers supported standalone value statements as discarded `VALUE_DROP` nodes. `.5.3.1` retired `s(...)`,
  `a(...)`, and `h(...)` as wrapper aliases; `.5.3.2` now diagnoses return/value-position unknown typed calls
  instead of leaking generated host calls, while standalone unknown calls remain raw until the function registry
  owns discard semantics. `.5.4` locked permanent `fn` grammar ownership to `specs/spec.spec` and proved the
  bootstrap parser has no current first-class `fn` support. `SPEC-FORMAT-TERSE.4.1` then locked the function
  contract/inventory and split implementation. `.4.2.1` landed the Perl function-definition
  grammar/registry descriptor seam while leaving call execution unresolved by design. `.4.2.2`, `.4.2.3`,
  `.4.3.1`, `.4.3.2`, `.4.4`, `.3.2.2`, and `.3.2.3` have since landed or split/owned; `.3.2.3.3` flipped
  ordinary comparison word calls to numeric aliases after `.3.2.3.2` shipped the explicit `str_*`
  string-comparison helpers, `.3.2.3.4` landed comparison symbol callees, `.3.3` split expression-valued
  assignment, `.3.3.1` landed scalar assignment expression values, `.3.3.2` landed aggregate assignment
  expression values under the then-current target-kind inference contract later superseded by duck-typed value
  binding, and `.3.3.3` landed array append and hash-index mutation
  expression values as updated aggregate snapshots. `.3.3.4` then closed the parent assignment-expression
  docs/compatibility contract: public examples prefer `set(...)` and operator assignment, `assign(...)` remained
  a legacy alias at that time, and phase0 then stood at 1015 tests. The later `.6` terse migration lane is closed:
  `.6.2.1` removed shipped-spec `declare(...)`, `.6.2.2` migrated old helper spellings, `.6.2.3.1` added
  `:name` as the terse scalar-slot spelling, `.6.2.3.2` retired active authored-spec `scalar(...)` /
  `assign(...)` while adding remembered bare identifier kinds, `.6.2.4` verified shipped-spec no-drift, `.6.3`
  swept current-facing docs plus checked-in corpus examples, and `.6.4` kept declaration helpers as legacy
  compatibility while excluding them from new authoring. `.15.1` has since split removal of `:name` scalar-slot
  punctuation from the duck-typed surface; `.15.2.1`/`.15.2.2`/`.15.2.3` have completed engine-first bare-read
  parity on Perl and Rust, including literal `case(foo)` labels for attached and inline switch. `.15.2.4` has since
  migrated current specs/corpus/docs/KM to bare value reads with no expected-output drift, `.15.3` has
  hard-retired Perl parser/lowering support for `:name`, `.15.4` has hard-retired Rust `Expr::ScalarSlot`, and
  `.15.5` has closed the final no-drift sweep by correcting stale Knowledge fact-card examples and reconfirming
  current specs/corpus/mdBook/tests/KM do not depend on successful `:name`. `.8.1` has now split legacy
  helper-removal before behavior changes: successful remaining compatibility paths are classified. `.8.2.1` has
  migrated live EBNF `push_nonempty(...)` use to explicit `is_nonempty(...)`-guarded `push(...)` with no oracle
  expected-output drift. `.8.2.2.1` has migrated the Rust source-emitter smoke specs away from incidental legacy
  helper spellings while preserving named-aggregate storage through explicit `set(array(...), [])`; `.8.2.2.2.1`
  has migrated the non-compatibility Rust integration smoke fixtures with full `integration_test` passing;
  `.8.2.2.2.2` has migrated TOP-RULE-AS-NORMAL recursive append/snapshot helper spellings while retaining
  `declare(...)` as a Rust scoped-declaration compatibility lock that `.8.4` must resolve before hard retirement;
  `.8.2.2.2.3` has migrated current-side helper spellings and labelled retained old-helper sides in explicit
  Rust legacy-helper compatibility/equivalence tests; `.8.2.2.2.4` has migrated later current-feature Rust
  integration fixture setup/snapshot strings to current helper spellings where supported; `.8.2.2.2.5` has closed
  final Rust integration-test residue classification; `.8.2.2.3` has migrated/classified generated oracle corpus
  fixture inputs with no expected-output drift; `.8.2.2.4` has migrated/classified Perl phase0 helper strings with
  phase0 1022 PASS; `.8.2.2.5` has closed the active-test/corpus residue scans, including wrapper-alias
  classification for Rust integration tests; `.8.2.3` has migrated current-facing mdBook/KM helper references
  to current terse spellings; and `.8.2.4` has closed the final `.8.2` no-drift scan/gate closeout before hard
  retirement. `.8.3` now owns Perl reference hard retirement of still-successful legacy helper spellings.
  `.9` is closed for hash-literal `:` association syntax: `.9.1` split the migration, `.9.2` added Perl
  reference colon support during the migration window, `.9.3` added Rust parser/runtime parity, `.9.4`
  migrated current source/docs/KM/corpus to colon syntax, `.9.5` hard-retired old hash-literal `=>` with
  colon-migration diagnostics, and `.9.6` closed final no-drift scans across current specs/corpora/docs/tests/KM
  and implementation support sites. The user explicitly reactivated `SPEC-FORMAT-TERSE.14` on 2026-07-07; `.14.1`
  split trailing block arguments before code, selected `with(value) { ... }` as the first helper-function MVP, and
  `.14.2` landed Perl reference parsing/lowering/runtime support for `with(value) { ... }` / `with() { ... }`;
  `.14.3` landed Rust helper-function form parity and added the `terse_14_3_with_helper_trailing_block` oracle fixture;
  `.14.4` landed receiver `.with() { ... }` on Perl/Rust and added
  `terse_14_4_receiver_with_trailing_block`; and `.14.5` closed the trailing block-argument docs/KM/oracle
  no-drift sweep. Director clarification on 2026-07-10 supersedes that MVP's abstraction without changing current
  behavior: codeblock is the fourth value kind beside scalar, array, and harray; a block-taking callable must treat
  `call(args) { block }` and `call(args, { block })` as equivalent final-argument spellings across helpers,
  user functions, receiver methods, and every backend. ADR 0031 and `FUTURE-PARITY-BACKLOG.11.1` select
  `{|args| ...}`, dynamic caller context without lexical capture, and retained `with`; neutral contract `.11.2` is
  adopted; Perl typed construction `.11.3.1`, dynamic invocation `.11.3.2`, ADR 0032 declaration `.11.3.3.1`, and
  metadata-governed generic final blocks `.11.3.3.2` and Perl closeout `.11.3.4` are complete. Active `.12.1`
  removes spec-facing aggregate selectors before cross-backend rollout; Perl `.12.1.2` now executes the neutral
  bare typed-binding contract; Rust `.12.1.3`, Dart `.12.1.4`, Julia `.12.1.5`, and Lua `.12.1.6` now match it;
  source migration `.12.1.7.1-.3` removed all 600 file-backed forms and all 1,356 positive embedded-source
  occurrences; Perl hard rejection `.12.1.8.1`, Rust `.12.1.8.2`, Dart `.12.1.8.3`, Julia `.12.1.8.4`, and Lua
  `.12.1.8.5` are complete; no-drift `.12.1.8.6` is next. `SPEC-FORMAT-TERSE.10` is closed by `.10.1`, which ratified dynamic/computed hash-literal keys
  without parser/runtime changes. The user explicitly reactivated `.13`; `.13.1` split the array-tree traversal
  work before code, `.13.2` landed Perl reference support for array-valued `walk_leaves`, `map_leaves`, and
  `reduce_leaves(initial)` receiver blocks, `.13.3` landed Rust/oracle parity with
  `terse_13_3_array_tree_traversal_receiver_blocks`, and `.13.4` closed docs/KM/no-drift alignment.
  `.12` is closed through `.12.4` after docs/KM/no-drift closeout. `SPEC-SOURCE-TERSE-CLOSEOUT.1`
  later promoted neutral hlink bracket/mixed delimiter cases, so the Rust oracle corpus is now
  99 fixtures; it had reached 97 fixtures after `.13.3` added the array-tree traversal fixture,
  96 fixtures after `.12.3` added
  `terse_12_3_hash_tree_traversal_receiver_blocks`, 95 fixtures after `.14.4`, and
  93 fixtures after `.15.2.3` added
  `terse_15_2_3_bare_value_reads_and_case_labels`, and 92 fixtures after
  `SPEC-FORMAT-TERSE.11.4` added `terse_11_4_nested_mixed_value_path_assignment`, the Lispish fixture was
  re-enabled, migrated to direct access under `SCALAREF-RETIREMENT`, the first `RUST-PARITY.7.2` shipped-spec
  batch added two `hlink_substitution` raw-string cases, `RUST-PARITY.7.3.3.2` added the JSON-safe `{abc}` curly
  case, `RUST-PARITY.7.3.4.4` added the two `lib_reader` attribute cases, `RUST-PARITY.7.3.4.2` added the four
  scalar `portmap` cases, `SPEC-FORMAT-TERSE.6.2.3.1` added the scalar-slot shorthand fixture now renamed
  `terse_15_4_bare_scalar_payload_readback`,
  `SPEC-FORMAT-TERSE.7.3` added `terse_7_3_array_numeric_reducer_receiver_methods`, `RUST-PARITY.7.3.4.3`
  added `portmap_concatenation`, `ebnf_expression_rules`, and `ebnf_logging_annotation`, `RUST-PARITY.7.3.5`
  added the four `spec_spec_*` smokes after null-output triage, `RUST-PARITY.7.3.6` added the seven
  RTL/plugin/legacy safety smokes, and `TOP-RULE-AS-NORMAL.3.2` added `top_rule_body_recursion_sexpr`,
  `top_rule_lx_recursion_nested`, and `top_rule_lx_recursion_sequence`; the bracket/mixed hlink
  scalar-ref deferral from `RUST-PARITY.7.3.3.3` is resolved by `SPEC-SOURCE-TERSE-CLOSEOUT.1`
  after `hlink_substitution` switched bracket payloads to neutral strings.
- **The `.1.5` literal/nested-access/call/semicolon surface is split; primitive literal parity, call-spacing locks,
  statement separators, and explicit direct nested access are landed (`SPEC-FORMAT-TERSE.1.5` / `.1.5.2` /
  `.1.5.3` / `.1.5.4` / `.1.5.5.1`, 2026-06-29); Channel 2 value-read semantics are now landed on both variants
  (`SPEC-FORMAT-TERSE.1.2.3.1` through `.1.2.3.4`, 2026-06-29), shape-literal values landed through
  `.1.2.3.5.4`, and the historical RHS target-kind inference branch is superseded by duck-typed value binding in
  `.11.2` through `.11.4`.** Primitive literals are typed value expressions on Perl and Rust: quoted strings stay
  strings, numbers stay numeric, `undef` becomes null, and `true`/`false` are JSON booleans rather than strings.
  Exact matching keeps `trueword`/`undefine` outside the literal path; in supported scalar read slots those
  identifiers are working-variable reads. `push(items,false)` is an explicit append while all-bare non-literal
  `push(A,B)` remains the child-call convention. Rust now gates statement-form `if(false); ... else(); ... endif()`
  blocks; the value-form lazy `if(cond,then,else)` helper is unchanged. Helper calls keep the `callee(args)` shape:
  optional whitespace before `(` is accepted at supported call sites, but no-parenthesis helpers remain out of
  scope. Statement separators are newline-or-semicolon: newlines separate top-level canonical DSL statements,
  multiple same-line statements require semicolons, and nested semicolons stay protected. Direct nested access now
  works for mixed path segments such as `foo["a"][9]["b"][z]`: quoted string segments are hash keys, numeric/helper
  segments are array indexes, and non-reserved bare path atoms are scalar array-index reads equivalent to `[:z]`.
  The legacy `scalaref(base,path)` compatibility form has been retired under `SCALAREF-RETIREMENT`: active shipped
  specs/docs migrated away from it in `.3`, and `.4` removed implementation support. Aggregate bare reads work on
  Perl/Rust for `copy(NAME)` after the identifier's kind is known, with explicit aggregate receivers still available
  where needed. Scalar bare reads work on Perl/Rust for source slots (`return(NAME)`, `set(out, NAME)`, and
  `out = NAME`), mutation key/RHS slots (`items += VALUE`, `set_key(meta, KEY, VALUE)`, `meta[KEY] = VALUE`), direct
  path atoms (`foo["a"][z]`), while explicit scalar-slot shorthand (`:name`) is superseded by the active `.15`
  removal lane and should not be taught as future current syntax. Direct shape-literal values such as
  `[]`, `[value, true]`, and `{ key : value, "fixed" : [value] }` now work as value expressions on Perl and Rust;
  old `{ key => value }` is retired as current ActionIR hash-literal syntax and diagnoses with the colon
  replacement. Bare shape keys/elements/values
  read scalar working variables and fixed hash field names must be quoted.
  Direct shape literals in assignment bind typed values instead of declaring aggregate storage: `items = [value]`
  stores an array value in `items`, `meta = { key : value }` stores a hash value in `meta`, and explicit
  bare target names are the typed mutation boundary.
- Child-rule append authoring is now standardized on `push(...)`: `push(Rule)`, `push(Rule, index)`, `push(Rule, target)`, and `push(Rule, target, index)`. The duplicate public `push_call(...)` helper is retired, and raw Perl wrapper metadata now uses `push_child_call_*_builtin` contract IDs instead of names that look like public helper calls.
- Fatal parser-flow authoring now uses explicit `exit_now(status)` when DSL code must stop immediately after a diagnostic; bare host `exit` remains compatibility syntax, while `exit_now(...)` contributes canonical `EXIT` metadata and keeps migrated specs out of the compatibility-surface bucket. `tablegrep::{grep,group}` now use this helper plus helper-form child captures and declarations, so `tablegrep` reports zero compatibility-surface rules.
- Rule-flow skip authoring uses `next()` when an edge should consume or recognize input without appending a value;
  Perl now also accepts the punctuation-light standalone alias `next`, and both contribute canonical `NEXT`
  metadata. `next()` remains the cross-backend spelling until `FUTURE-PARITY-BACKLOG.16` closes.
  `tkgui::{sub_gui_list,curlyb}` use the parenthesized form plus helper-form returns, so `tkgui` reports zero
  compatibility-surface rules.
- Helper-form delimiter cleanup now covers `hlink_substitution::{substitute_top,substitute_statement2,curlyb}` as well: fatal bracket/brace paths use `exit_now(...)`, the bracket payload uses neutral `capture_slice()`, and the wrapped brace payload uses `return(cat(...))`, so `hlink_substitution` reports zero compatibility-surface rules and its bracket/mixed delimiter outputs are JSON-safe oracle values.
- Helper-form legacy plugin parsing now covers `pplugin::{pplugin_top,subdef,curlyb}` too: top-level state, flow, aggregation, hash return, subdef array return, and curly-brace undef return all use canonical helpers, so `pplugin` reports zero compatibility-surface rules. The parser returns plugin body text; legacy coderef wrapping lives in the Perl `PPlugin` runtime adapter.
- Helper-form register-definition parsing now covers `regdef::{regdef_top,reg_def,reg_fld,ob_cb}` too: top/reg/field array payloads use helper-form returns with accumulator snapshots, and `ob_cb` uses `return(1)`, so `regdef` reports zero compatibility-surface rules while preserving the nested register/field AST.
- Helper-form EBNF parsing now covers `ebnf::{grammar_file,include_dir,include_file,semantic_annotation,logging_annotation}` too: child-call assignment, include argument cleanup, semantic capture cleanup, logging capture-boundary movement, and returns all use canonical helpers, so `ebnf` reports zero compatibility-surface rules while preserving include and annotation AST behavior.
- Helper-form if/else debugging now covers `ifelse::{if,then,elsif,else,while,while_then}` too: flow-stop edges use canonical `return_undef()` instead of bare `return`, so `ifelse` reports zero compatibility-surface rules while preserving the debug parser trace behavior.
- Helper-form VHDL parsing now covers `vhdl::{vhdl_file,architecture_statement_part,signal_decl_range,constant_declaration,variable_declaration,file_declaration,signal_declaration,configuration_specification}` too: accumulator snapshots use `copy(...)`, list-context range returns use `flat_array(...)`, and comma-list tagged rows use `split_tagged_records(...)`, so `vhdl` reports zero compatibility-surface rules while preserving the VHDL smoke parser shape.
- Helper-form simenv parsing now covers `simenv::{top,begin_end_blocks,value readers,substitution readers,delimiter helpers}` too: working-state declarations, child-call assignment, appends, returns, fatal exits, source-position reads, `input_slice(...)`, and the new `print_each(...)` iterable debug-output helper all use canonical helpers, so `simenv` reports zero compatibility-surface rules while preserving the begin/end AST smoke.
- Live specs and current examples use `copy(...)` for snapshot arrays/hashes; `array_copy(...)` and `array_values(...)` are retired helper spellings. Generic list-context splicing uses `flat(...)`; `flatten(...)` is retired. Array-edge drops use `drop_front(...)` / `drop_back(...)`; `tail(...)` / `drop_last(...)` are retired. The live VHDL grammar, ordinary root-guide examples, and public mdBook blind-call examples use explicit `return(array(...))` constructor payloads, `flat_array(entry_groups())` for capture-group splices, and `copy(rule)` for accumulator snapshots. Exact aggregate selectors were later removed by `FUTURE-PARITY-BACKLOG.12.1`.

Runtime/diagnostic continuity note:
- `LinkedSpec::RuntimeContext` preparation now reseeds an explicit requested `top_rule` during both inline `run_get(...)` and file-oriented `get_parser(...)` setup, so earlier compiler/parser-factory failures still report the caller’s intended parser entrypoint instead of an empty or stale `top_rule`.
- Stale file identity reset for `spec_name` / `spec_path` now also has one shared `RuntimeContext` helper, deliberately separate from `top_rule` so selected-entrypoint continuity remains explicit.
- `runtime_ctx_ref => \$ctx` scalar slots are now explicitly reusable after first population: `RuntimeContext` treats Perl's later `REF` shape as the same populated scalar-slot contract, reuses the existing context hashref, and rejects slots already holding non-hash references.
- The reusable populated scalar-slot contract is now locked through the public `LinkedSpec::Get(...)` and `LinkedSpec::get_parser(...)` entrypoints too, so public callers can reuse the same context hashref across later calls while caller-owned fields survive and LinkedSpec-owned identity/error fields refresh for the current run.
- Parser-source capture reset now also has one shared `RuntimeContext` helper for paths that must clear stale chunks and remove stale emit callbacks, while `run_get_pipeline(...)` keeps the narrower chunk-only reset needed to preserve active compiler emission.
- `run_get(...)` and `get_parser(...)` runtime-context preparation now clear stale `last_error` at the boundary too, matching the low-level rule-table path so reused contexts start each new operation with a failure-only diagnostics channel.
- Top-rule generated-handler source labels now also build through `RuntimeContext`, so runtime-owner, parser-factory, and compiler diagnostics use one selected-`top_rule` attribution helper, with parser-invocation handler variants passed through the same helper when known.
- Compiler rule-or-top generated-handler source-label fallback now also lives in `RuntimeContext`, so concrete rule labels still win while generic compiler failures share the selected-`top_rule` fallback.
- Rule-metadata generated-handler source labels now also build through `RuntimeContext`, so `SpecEntry` runtime-handler source labels share the same selected-handler-variant extraction and label formatting.
- `SpecEntry` no longer keeps a one-shot generated-handler label wrapper above that shared rule-metadata helper.
- Low-level `build_compiled_rule_table(...)` runtime-context preparation now also lives in `LinkedSpec::RuntimeContext`, so compiler rule-table diagnostics reuse the same shared hook normalization, stale `last_error` clearing, stale file-identity clearing, parser-source capture cleanup, and selected-`top_rule` seeding path as the higher-level runtime/parser-factory entrypoints.
- compiler-attributed `runtime_ctx->{last_error}` payloads at `compiler_pipeline:build_compiled_rule_table`, `compiler_pipeline:build_final_descriptor`, and attributed `compiler_pipeline:validate_dependency_regex_references` now also preserve a synthetic `handler_source_label` like `LinkedSpec::generated_handler:<rule_label>` whenever the failing rule is already known even before an exact handler variant has been selected, and top-level `runtime_parser` failures now keep that same label whenever the parser boundary still knows at least the selected top-rule label.
- compiler `prepare_pipeline` and `bootstrap_parse` failures now also preserve the label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>` whenever the selected top rule is already known at those early seams.
- compiler `validate_spec_content` and unattributed `validate_dsl_syntax` failures now also preserve that same label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>` whenever the selected top rule is already known before rule attribution starts.
- unattributed `compiler_pipeline:build_compiled_rule_table`, `compiler_pipeline:build_final_descriptor`, and `compiler_pipeline:validate_dependency_regex_references` failures now also preserve that same label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>` whenever the selected top rule is already known but no more specific rule attribution exists yet.
- that same late generic compiler-failure handler attribution is now also regression-locked through the file-oriented `get_parser(...)` continuity path, so resolved-spec failures keep `spec_path`, selected `top_rule`, and `LinkedSpec::generated_handler:<top_rule>` together after file load too.
- file-oriented `runtime_parser` failures are now also regression-locked through `get_parser(...)`, so later top-level parser invocation failures keep resolved `spec_path`, selected `top_rule`, and generated-handler identity together in shared `runtime_ctx->{last_error}` too.
- returned parser coderefs now also reject malformed non-`SCALAR`-reference input explicitly at `runtime_parser:validate_input_ref`, so top-level parser misuse preserves targeted structured detail and the same `top_rule` / handler-identity continuity instead of falling through to lower-level Perl dereference failures; that same file-oriented continuity is now regression-locked through `get_parser(...)` too.
- the low-level `build_compiled_rule_table(...)` surface now also accepts `runtime_ctx_ref => \$ctx`, and thrown `compile_spec_entry(...)` failures, malformed non-throwing descriptor tuples, invalid non-CODE callback contracts, malformed non-ARRAY parsed-entry containers, plus malformed individual parsed entries there now normalize into `compiler_pipeline:build_compiled_rule_table` payloads with `top_rule` / `rule_label` / `handler_source_label` continuity instead of leaving low-level callers with only a raw die or local undef path.
- the default `build_dependency_regex_map(...)` seam now also validates malformed descriptor shape explicitly, so `compiler_pipeline:build_final_descriptor` can preserve targeted detail like `build_dependency_regex_map expects rule 'Top' dependency_refs to be ARRAY ref; got SCALAR` with active `rule_label` / `handler_source_label` continuity instead of leaking incidental Perl reference failures from deep inside dependency-regex-map assembly.
- `Compiler.pm` now also has one explicit internal compiled-spec state model: `build_compiled_rule_table(...)` first builds `kind/version/definition_order/compiled_rule_order/rules_by_label/redefined_rule_labels` state, default `build_dependency_regex_map(...)` now enriches that state directly, final descriptor assembly projects outward `spec` / `dependency_regex_map` hashes while exposing `meta.descriptor_model`, `meta.compiled_rule_order`, and `meta.redefined_rule_labels`, and low-level callers can request the same state directly with `build_compiled_rule_table(..., { return_state => 1 })`.
- descriptor-level `action_rewriter_migration` summary generation now also stays on that same state-first path: `Compiler.pm` now derives it directly from compiled-spec state instead of projecting through the legacy `spec` hash first, so non-priority summary rule lists now follow source rule order while the explicit `*_by_priority` views keep their separate triage ordering.
- final descriptor assembly now also has one explicit internal `compiled_descriptor_state` seam above compiled-spec state and the compiled dependency-regex map, `return_descriptor` metadata now exposes `definition_order` alongside `compiled_rule_order`, and malformed compiled dependency-regex-map callback output is rejected directly at that final descriptor boundary instead of drifting into later validation.
- the active public descriptor-introspection option is now `return_descriptor => 1` with no `return_descr` compatibility alias preserved, so runtime, parser-factory, compiler, the active regression locks, and the current docs all use one explicit descriptor-return term.
- generated-descriptor validation now also consumes that same `compiled_descriptor_state` directly on the active path instead of flattening back to parallel `spec` / `dependency_regex_map` hashes first, so the compiler now stays on the explicit state model through validation and only projects the outward descriptor after that seam.
- that generated-descriptor validation seam is now also state-first internally instead of bouncing back through the historical legacy `validate_dependency_regex_references(...)` entrypoint, so legacy descriptor projection is fully deferred until descriptor-state validation succeeds.
- derived dependency regexes now also have one explicit internal state seam: `build_dependency_regex_map(...)` can now return `compiled_dependency_regex_state`, and final descriptor assembly now composes compiled-spec state plus compiled dependency-regex state instead of carrying raw dependency-regex-map hashes as the last anonymous compiler-owned structure.
- that same derived compiler payload now also uses the explicit dependency-regex name throughout the active state model instead of keeping `compiled_gdata_state` / `gdata_by_label` / `gdata_rows` compatibility aliases inside `CompilerState`.
- the compiled state model now also has its own owner module: `LinkedSpec::CompilerState` now owns compiled-spec / compiled dependency-regex / compiled-descriptor state construction, shape checks, and legacy projection, so `Compiler.pm` and `Validation.pm` no longer duplicate that local state-model logic.
- the last legacy compatibility-shape normalization rules for compiled spec and compiled dependency-regex maps now also route through `LinkedSpec::CompilerState`, so `Compiler.pm` no longer carries a second local “accept legacy hash or compiled-state record” conversion seam beside the state owner.
- read-side compiled-state access now also routes through `LinkedSpec::CompilerState`, so compiler trace/logging reads and descriptor-validation rule-map reads no longer reach into raw compiled-state fields directly.
- ordered compiled-rule iteration now also routes through `LinkedSpec::CompilerState`, so compiler consumers no longer rebuild the active rule stream ad hoc from `compiled_rule_order + rules_by_label`.
- compiled-spec dependency lookup in `build_dependency_regex_map(...)` now also routes through `LinkedSpec::CompilerState`, so compiler consumers no longer probe the compiled rule map directly just to test dependency presence or fetch one dependent rule record.
- compiled-descriptor metadata assembly now also routes through `LinkedSpec::CompilerState`, so `Compiler.pm` no longer shapes descriptor metadata by mutating owner-provided compiled-spec metadata locally.
- descriptor migration-summary shaping now also routes through `LinkedSpec::CompilerState`, so `Compiler.pm` no longer computes the large `action_rewriter_migration` reduction locally over compiled rules.
- descriptor-state validation now also walks owner-provided descriptor-state rule rows, dependency-regex rows, and by-label lookup through `LinkedSpec::CompilerState`, so `Validation.pm` no longer flattens descriptor state back into raw rule/dependency-regex maps on the active state-first path.
- descriptor-state validation now also consumes one owner-provided validation view from `LinkedSpec::CompilerState`, so `Validation.pm` no longer performs repeated owner dispatch from inside its validation loops once it is already on the descriptor-state path.
- `Validation.pm` now also uses one shared validation-view engine for both legacy `validate_dependency_regex_references(...)` inputs and owner-provided descriptor-state validation views, so the project no longer carries two separate copies of the same dependency-regex/rule consistency checks.
- `LinkedSpec::BootstrapSpec` and `BootstrapSpec::Core` now use `rule_descriptors` / `dispatch_state` naming for the bootstrap parser tuple and dispatch metadata instead of the remaining active `spec_descr` / `gdata` vocabulary, keeping bootstrap internals aligned with the compiler-state terminology cleanup without changing parse behavior.
- rule-attributed `compiler_pipeline:validate_dsl_syntax` false-return failures now also preserve the validator’s specific `summary` and formatted DSL-error `detail`, plus that same synthetic `handler_source_label`, whenever the offending rule paragraph is already known.
- `compiler_pipeline:validate_spec_content` false-return failures now also preserve the validator’s specific `summary` and formatted DSL-error `detail`, and malformed-first-rule failures now also preserve that same synthetic `handler_source_label` whenever the early rule label is already known.
- parser-factory `validate_spec_name` false-return failures now also preserve the validator’s specific `summary` and `detail` instead of collapsing to a generic “validate_spec_name rejected the requested parser name” wrapper.
- parser-factory `resolve_spec_path` false-return failures from the real resolver now also preserve the resolver’s specific `summary` and `detail` instead of collapsing to a generic “Spec resolution failed” wrapper.
- parser-factory `load_spec_content` false-return failures from the real resolver now also preserve the resolver’s specific `summary` and `detail` instead of collapsing to a generic “Spec file load failed” wrapper.
- parser-factory pre-compile failure seams (`prepare_parser_factory`, `validate_spec_name`, `resolve_spec_path`, and `load_spec_content`) now also preserve the label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>` whenever the selected top rule is already known there.
- parser-factory `compile_spec` malformed defined return shapes now also preserve specific parser-result detail instead of accepting arbitrary defined values as successful parser results or collapsing to a generic compile wrapper, and when the selected top rule is already known at that seam the same fallback payload now also preserves the label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>`.
- runtime and parser-factory mode-only compile paths now also preserve explicit malformed-result detail instead of accepting defined values as successful `parse_only` / `generate_only` runs.
- runtime-owner fallback `runtime_owner:run_get_pipeline` payloads now also preserve the same label-only generated-handler identity whenever the selected top rule is already known at that seam.
- compiler `bootstrap_parse` malformed non-throwing return shapes now also preserve specific result-shape detail instead of collapsing to one generic invalid-intermediate-representation detail string.
- malformed non-throwing `compile_spec_entry(...)` return shapes at `compiler_pipeline:build_compiled_rule_table` now also preserve specific tuple-shape detail instead of collapsing to the old generic descriptor-build wrapper string.
- the remaining `runtime_parser:resolve_top_rule_handler` missing-descriptor-entry seam now follows that same rule too, so callers still get `LinkedSpec::generated_handler:<top_rule>` even when the selected top-rule label is known but no compiled descriptor entry exists yet.

## Near-Term Execution Priorities
1. Lifecycle-family follow-through for semicolon-light structured authoring: **verified complete** (LIFECYCLE-FAMILY-AUDIT, 2026-06-14).
   - generic helper-only regression coverage spans all 7 markers (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`),
   - marker-style semicolon-light control-flow coverage spans the full lifecycle family,
   - 73+ fluent_and_structured helper-family subtests use LX as primary proof point; full_lifecycle data-driven subtests cover all 7 markers for control-flow,
   - no lifecycle-specific semantic gaps found; all markers treated as equivalent.
2. Continue the method-like DSL migration track:
   - priority shift is now active: continue missing user-facing DSL features first, and return to deeper marker `if(...)` / marker `switch(...)` cross-nesting parity expansion only when a concrete feature or bug requires it,
   - design direction is now explicit: scalar and aggregate helper growth should follow a disciplined functional-expression style with unlimited composition, clear helper signatures, and parser-oriented semantics, while explicitly avoiding scope creep into lambdas, closures, currying, or a general-purpose FP sublanguage,
   - landed punctuation-reduction follow-up: structured marker-style zero-arg terminators now accept bare keyword form (`else`, `endif`, `default`, `endcase`, `endswitch`) in addition to the older `...()` spellings; attached branch blocks are explicitly owned by `SPEC-FORMAT-TERSE.2.2`, with attached `if`, `when`/`otherwise`, and `switch/case/default` now portable after their leaves closed,
   - landed documentation follow-up: a dedicated scalar-and-aggregate composition guide now teaches string, integer, float-like, array, and hash helper usage with many worked examples and explicit no-fixed-depth composition guidance instead of scattering that story only across module-owner references,
   - landed helper-contract follow-up: parser-oriented `coalesce(...)` fallback chains are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and comparison inputs,
   - landed helper-contract follow-up: parser-oriented `is_defined(...)` / `is_undefined(...)` flow helpers are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, so `.spec` rules can distinguish “missing” from “empty” without dropping back to ad hoc truthiness,
   - landed helper-contract follow-up: parser-oriented scalar normalization helpers `trim(...)`, `lowercase(...)`, and `uppercase(...)` are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and comparison inputs,
   - landed helper-contract follow-up: parser-oriented scalar `length(...)` reducer is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs while preserving `undef` for missing scalar expressions unless the caller explicitly `coalesce(...)`s to a default,
   - landed helper-contract follow-up: parser-oriented scalar fallback helper `coalesce_nonempty(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and comparison inputs while skipping only `undef` and `""` and still preserving `0` and other defined nonempty scalar values,
   - landed helper-contract follow-up: parser-oriented `scalar(container, key_or_index)` entry reads are now explicitly regression-locked for composed aggregate expressions too, so array-valued helpers like `sorted_keys(...)` and hash-valued helpers like `merge_hash(...)` can feed one-step scalar reads directly on both action-edge and lifecycle surfaces without forcing temporary working variables first,
   - landed helper-contract follow-up: parser-oriented array-size reducer `count(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs,
   - landed helper-contract follow-up: parser-oriented array boundary reducers `first(...)` / `last(...)` are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and comparison inputs over direct arrays plus projected array expressions,
   - landed helper-contract follow-up: parser-oriented front-drop helper `drop_front(...)` is now the canonical array rest-view spelling and is explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering array assignment sources, direct `return(payload)` expressions, and reducer composition such as `count(drop_front(sorted_keys(...)))`; `tail(...)` was a compatibility alias, since **retired** (`COMPAT-ALIAS-RETIREMENT.1`),
   - landed helper-contract follow-up: parser-oriented front-drop helper now also accepts one optional explicit drop-count argument, so `drop_front(array_expr)` drops `1` entry while `drop_front(array_expr, n)` is explicitly regression-locked across direct arrays, projected arrays, array assignment sources, direct `return(payload)` expressions, and reducer composition; `tail(array_expr, n)` was a compatibility alias, since **retired** (`COMPAT-ALIAS-RETIREMENT.1`),
   - landed helper-contract follow-up: parser-oriented array prefix helper `take(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, so `take(array_expr)` remains the shorthand for keeping the first `1` entry while `take(array_expr, n)` is explicitly regression-locked across direct arrays, projected arrays, array assignment sources, direct `return(payload)` expressions, reducer composition, and nested scalar(container, index) reads,
   - landed helper-contract follow-up: parser-oriented middle-window helper `slice(array_expr, start)` / `slice(array_expr, start, n)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, so direct arrays and composed array-valued expressions can expose one bounded middle subarray without temporary staging while still composing into reducers like `count(slice(...))` and nested reads like `scalar(slice(...), 0)`,
   - landed helper-contract follow-up: parser-oriented trailing-drop helper `drop_back(...)` is now the canonical trailing suffix-removal spelling and is explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, so `drop_back(array_expr)` drops the last `1` entry while `drop_back(array_expr, n)` is explicitly regression-locked across direct arrays, projected arrays, array assignment sources, direct `return(payload)` expressions, reducer composition, and nested scalar(container, index) reads; `drop_last(...)` was a compatibility alias, since **retired** (`COMPAT-ALIAS-RETIREMENT.1`),
   - landed helper-contract follow-up: parser-oriented trailing-suffix helper `take_last(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, so `take_last(array_expr)` remains the shorthand for keeping the last `1` entry while `take_last(array_expr, n)` is explicitly regression-locked across direct arrays, projected arrays, array assignment sources, direct `return(payload)` expressions, reducer composition, and nested scalar(container, index) reads,
   - landed helper-contract follow-up (since superseded by retirement): `tail(...)` and `drop_last(...)` were compatibility aliases of canonical `drop_front(...)` and `drop_back(...)`, **retired** in `COMPAT-ALIAS-RETIREMENT.1` — the Perl reference no longer recognizes them, no shipped spec uses them, and `t/` has zero locks,
   - landed helper-contract follow-up: parser-oriented pure array-layering helper `concat_arrays(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering declarations, array assignment sources, direct `return(payload)` expressions, and reducer composition over direct arrays, projected arrays, array constructors, and array-valued `coalesce(...)` chains,
   - landed helper-contract follow-up: parser-oriented arithmetic helpers `num_add(...)` and `num_sub(...)` are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs while preserving `undef` for missing or non-numeric-looking operands unless the caller explicitly `coalesce(...)`s to a default,
   - landed helper-contract follow-up: parser-oriented arithmetic helpers `num_mul(...)` and `num_div(...)` are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs while preserving `undef` for missing/non-numeric-looking operands and for divide-by-zero unless the caller explicitly `coalesce(...)`s to a default,
   - landed helper-contract follow-up: parser-oriented arithmetic reducer `num_sum(array_expr)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs over direct arrays and composed array-valued expressions while returning `0` for empty arrays and `undef` for non-array or non-numeric item sources unless the caller explicitly `coalesce(...)`s to a default,
   - landed helper-contract follow-up: parser-oriented arithmetic reducer `num_avg(array_expr)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs over direct arrays and composed array-valued expressions while returning `undef` for empty arrays, non-array sources, or non-numeric item sources unless the caller explicitly `coalesce(...)`s to a default,
   - landed helper-contract follow-up: parser-oriented arithmetic reducer `num_median(array_expr)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs over direct arrays and composed array-valued expressions while returning `undef` for empty arrays, non-array sources, or non-numeric item sources unless the caller explicitly `coalesce(...)`s to a default, with even-length arrays yielding the average of the two middle items after numeric ordering,
   - landed helper-contract follow-up: parser-oriented arithmetic reducer `num_range(array_expr)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs over direct arrays and composed array-valued expressions while returning `undef` for empty arrays, non-array sources, or non-numeric item sources unless the caller explicitly `coalesce(...)`s to a default, with nonempty valid arrays yielding the numeric maximum minus the numeric minimum,
   - landed helper-contract follow-up: parser-oriented arithmetic helpers `num_min(...)` and `num_max(...)` are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs while preserving `undef` for missing or non-numeric-looking operands unless the caller explicitly `coalesce(...)`s to a default,
   - landed helper-contract follow-up: those same parser-oriented arithmetic helpers `num_min(...)` and `num_max(...)` now also accept one array-valued source as a reducer on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs over direct arrays and composed array-valued expressions while returning `undef` for empty arrays, non-array sources, or non-numeric item sources unless the caller explicitly `coalesce(...)`s to a default,
   - landed helper-contract follow-up: parser-oriented arithmetic helper `num_abs(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs while preserving `undef` for missing or non-numeric-looking operands unless the caller explicitly `coalesce(...)`s to a default,
   - landed helper-contract follow-up: parser-oriented arithmetic helpers `num_floor(...)`, `num_ceil(...)`, and `num_round(...)` are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs while preserving `undef` for missing or non-numeric-looking operands unless the caller explicitly `coalesce(...)`s to a default,
   - landed helper-contract follow-up: parser-oriented arithmetic helper `num_mod(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs while preserving `undef` for missing, non-integer-looking, or divide-by-zero operands unless the caller explicitly `coalesce(...)`s to a default,
   - landed helper-contract follow-up: parser-oriented arithmetic helper `num_clamp(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs while preserving `undef` for missing, non-numeric-looking, or inverted-bound operands unless the caller explicitly `coalesce(...)`s to a default,
   - landed helper-contract follow-up: parser-oriented scalar boundary predicates `starts_with(...)` and `ends_with(...)` are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, so normalized prefix/suffix checks can stay inside assignments, direct `return(payload)` expressions, and flow conditions,
   - landed helper-contract follow-up: parser-oriented scalar substring predicate `contains_substr(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, so normalized substring-membership checks can stay inside assignments, direct `return(payload)` expressions, and flow conditions without dropping into ad hoc host-language `index(...) >= 0` code,
   - landed helper-contract follow-up: parser-oriented literal string rewrite helper `replace_substr(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, so separator cleanup and canonical name normalization can stay inside assignments, direct `return(payload)` expressions, and flow comparisons without dropping into mutation-oriented `regex_subst(...)` code,
   - landed helper-contract follow-up: parser-oriented scalar boundary transforms `rm_prefix(...)` and `rm_suffix(...)` are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, so one literal leading/trailing marker cleanup step can stay inside assignments, direct `return(payload)` expressions, and comparison inputs while preserving `undef` for missing operands and otherwise returning the original value unchanged when the boundary is absent,
   - landed helper-contract follow-up: parser-oriented scalar assembly helper `cat(...)` is explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces; the former `concat` spelling is retired,
   - landed helper-contract follow-up: parser-oriented scalar regex predicate helper `matches(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, so regex-membership flags can stay inside assignments, direct `return(payload)` expressions, and flow conditions without dropping into ad hoc host-language `=~` code,
   - landed helper-contract follow-up: parser-oriented array membership helper `contains(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and flow conditions over working arrays plus projected array expressions like `sorted_keys(...)` and `sorted_values(...)`,
   - landed helper-contract follow-up: parser-oriented first-match index helper `index_of(array_expr, needle_expr)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric/definedness flow comparisons over direct arrays plus projected array expressions like `sorted_keys(...)` and `sorted_values(...)`, while returning `undef` for missing/non-array/no-match cases and returning `0` when the first match is already at index `0`,
   - landed helper-contract follow-up: parser-oriented hash/object-size reducer `count_keys(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs,
   - landed helper-contract follow-up: parser-oriented hash/object key-presence helper `has_key(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and flow conditions,
   - landed helper-contract follow-up: parser-oriented pure hash/object layering helper `merge_hash(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and flow-helper composition without mutating source hashes,
   - landed helper-contract follow-up: parser-oriented pure hash/object snapshot helper `hash_copy(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, nested scalar/hash composition, and return payloads without mutating source hashes,
   - landed helper-contract follow-up: parser-oriented pure hash/object single-field update helper `set_key(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, nested scalar reads, and flow-helper composition without mutating source hashes,
   - landed helper-contract follow-up: parser-oriented pure hash/object single-field rename helper `rename_key(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, nested scalar reads, and flow-helper composition without mutating source hashes,
   - landed helper-contract follow-up: parser-oriented pure hash/object cleanup helper `drop_keys(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and flow-helper composition without mutating source hashes,
   - landed helper-contract follow-up: parser-oriented pure hash/object projection helper `pick_keys(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and flow-helper composition without mutating source hashes,
   - landed helper-contract follow-up: parser-oriented stable hash/object-to-array projection helper `sorted_keys(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering array assignment sources, return payloads, and array-reducer composition without relying on host-language hash iteration order,
   - landed helper-contract follow-up: parser-oriented stable hash/object-to-array projection helper `sorted_values(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering array assignment sources, return payloads, and array-reducer composition without relying on host-language hash iteration order,
   - landed helper-contract follow-up: parser-oriented deterministic array-ordering helper `sorted(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering array assignment sources, return payloads, and array-reducer composition over direct arrays and composed array-valued helper expressions such as `concat_arrays(...)`, `take(...)`, and `sorted_keys(...)`,
   - landed helper-contract follow-up: parser-oriented array order-inversion helper `reversed(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering array assignment sources, return payloads, and array-reducer composition over direct arrays and composed array-valued helper expressions such as `concat_arrays(...)`, `take(...)`, and `sorted_keys(...)`,
   - landed helper-contract follow-up: parser-oriented aggregate emptiness helpers `is_empty(...)` / `is_nonempty(...)` now treat composed array-valued and hash-valued helper expressions as real aggregates instead of Perl reference truthiness, so projections like `sorted_values(...)`, `pick_keys(...)`, `drop_keys(...)`, and aggregate `coalesce(...)` chains can drive flow conditions directly on both action-edge and lifecycle surfaces,
   - landed helper-contract follow-up: that same parser-oriented aggregate-emptiness family now also has explicit value-layer lowering, so `is_empty(...)` / `is_nonempty(...)` can be assigned into scalar flags and returned inside general `return(payload)` expressions on both action-edge and lifecycle surfaces instead of staying flow-condition-only,
   - landed helper-contract follow-up: parser-oriented string reducer `join_values(delimiter, array_expr)` now accepts composed array-valued helper expressions like `sorted_keys(...)`, `sorted_values(...)`, projected-object helpers, and array-valued `coalesce(...)` chains in addition to direct working arrays, and that broader source-side contract is explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces,
   - landed helper-contract follow-up: parser-oriented list-context insertion helpers `flat_array(...)` and `flat_hash(...)` now also accept composed aggregate helper expressions such as `sorted_keys(...)`, `sorted_values(...)`, `pick_keys(...)`, and `hash_copy(...)` in addition to direct working arrays/hashes, with exact lowering plus fluent-versus-structured parity locked on both action-edge and lifecycle surfaces,
   - landed helper-contract follow-up: representative array-normalization pipelines using `split(...)`, `split_each(...)`, `trim_each(...)`, `filter_nonempty(...)`, and `return(array_copy(...))` are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces,
   - landed helper-contract follow-up: representative case-normalization/filter pipelines using `assign(array(...), filter_match(uniq(uppercase_each(array(...))), /.../))`, `lowercase_each(...)`, and `return(array_copy(...))` are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces,
   - `.2.2.1` corrected the control-flow roadmap status: attached-block `if`, `when`/`otherwise`,
     statement-level switch blocks, and `while` needed split implementation leaves instead of being treated as
     landed portable contracts,
   - `.2.2.2` landed Perl attached-block `if/elseif/else`: compact same-line `} elseif/else {` chains now split
     and lower through ActionIR without raw fallback,
   - `.2.2.3` landed Rust attached-if parity by normalizing attached branch bodies into the existing
     `handle_statement_if_control` marker branch-gating model,
   - current portable branch-control support is attached-block `if(cond) { ... } elseif(cond2) { ... } else {
     ... }`, attached-block `when(cond) { ... } otherwise { ... }`, attached-block `switch(expr) { case(v) {
     ... } default { ... } }`, attached-block `while(cond) { ... }`, statement-marker `if(cond); ...
     elseif(cond); else(); ... endif()`, and inline-composite lazy `if(...)` / `switch(...)` value helpers in
     `return(...)`, assignment RHS, and fluent `.return(...)` value positions,
   - `.2.2.4` landed `when/otherwise` as attached `if/else` aliases over the existing branch model; `.2.2.5.1`
     landed the Perl attached switch/default separator/source lock; `.2.2.5.2` landed Rust parser/runtime
     parity; `.2.2.6` split `while(cond) { ... }`, `.2.2.6.1` landed the Perl reference loop/safety
     contract, and `.2.2.6.2` landed Rust parser/runtime/oracle parity with 39 corpus fixtures,
   - `.2.3` is now split/owned before code: `.2.3.1` landed the Perl reference exact fluent
     `.when(cond) { ... }.otherwise { ... }` block-chain fallback contract, `.2.3.2` locked lifecycle
     value/drop and return-channel semantics, `.2.3.3.1` landed Rust action-edge no-arg fluent continuations,
     `.2.3.3.2` landed Rust action-edge/lifecycle attached fluent block payloads, `.2.3.3.3` split remaining
     Rust fluent continuations into compact lifecycle/body receiver chains, action-edge explicit/flow chains,
     and `tclite` re-enable/default-mode repetition audit, `.2.3.3.3.1` landed compact lifecycle/body
     receiver chains as executable lifecycle `CodeBlock` statements, `.2.3.3.3.2` landed action-edge
     explicit/flow fluent chains, and `.2.3.3.3.3` retried `tclite` after fluent parity but still saw Rust
     `[]` for the `[]`/`""` Perl-oracle cases; `.2.3.3.3.3.1` then landed default-mode recursive
     repetition parity and restored the two `tclite` fixtures (corpus 41), then `.2.3.4` audited full nested
     composability, added a deep pure-helper oracle fixture (corpus 42), and split Rust helper-context
     aggregate bare reads plus Perl inline value-control lowering into `.2.3.4.1`/`.2.3.4.2`; `.2.3.4.1`
     landed Rust bare aggregate helper arguments and brought the corpus to 44, and `.2.3.4.2` landed Perl
     inline `if`/`switch` value-control lowering with two payload-value oracle fixtures, bringing the corpus
     to 46. `.2.3.5` specified return-type method chaining and split implementation into
     array/hash/string/number receiver-family leaves plus a block-valued receiver audit; `.2.3.5.1` landed
     array receiver-dot value chains with phase0 996 and corpus 47; `.2.3.5.2` landed hash receiver-dot value
     chains with phase0 997 and corpus 48; `.2.3.5.3` landed string receiver-dot value chains with phase0 998
     and corpus 49; `.2.3.5.4` landed number receiver-dot value chains with phase0 999 and corpus 50;
     `.2.3.5.6` locked aggregate wrapper quoted-name boundaries plus direct-shape constructor preference with
     phase0 1000 and corpus 51; `.2.3.5.5` landed block-valued receiver chaining by yielded type with phase0
     1001 and corpus 52; `.5.0` then owned future variant parity before any non-Rust variant code; `.3.1`
     locked the existing edge syntax contract with no behavior change; `.3.2` split arithmetic/comparison
    calls into word aliases, symbol callees, and comparison policy before code; `.3.2.1` landed the numeric
  word aliases with phase0 1002 and corpus 53. `.4` now owns user-defined pure functions, and
  `PERL-ACTIONIR-AST-MIGRATION.0` adopts the text-to-AST doctrine before that implementation proceeds.
  Function syntax must ultimately be represented in `specs/spec.spec`; bootstrap-parser `fn` support, if any,
  is temporary migration debt to remove after text-to-AST handoff.
  `PERL-ACTIONIR-AST-MIGRATION.1` then locked the Perl lowering inventory and AST node set, and `.2`
    introduced the additive Perl `ActionIR::AST` parser seam. `.3` is complete after focused value/receiver
    migration children; `.3.1` moved non-call value nodes onto AST lowering, `.3.2` split helper calls by
    argument-slot risk, `.3.2.1` moved value-only helper-call composition onto AST call nodes, `.3.2.2` moved
    deprecated wrappers plus aggregate/collection/reducer/hash helper calls onto slot-aware AST call lowering,
    `.3.2.3` replaced unsupported covered-helper host-call leakage with unresolved-helper diagnostics, `.3.3`
    moved receiver-dot `fluent_chain` value chains onto AST receiver/call traversal, `.3.4` moved typed
    return payloads onto AST traversal, `.4` split statement/control lowering by behavior family, `.4.1`
    moved assignment/mutation operator statements onto AST fields, `.4.2` moved helper-call statements
    and returns onto AST call/fluent-chain fields, `.4.3` moved block-value side effects/block-local
    returns onto AST block/statement fields, `.4.4` split structured control-flow lowering into focused
    children, `.4.4.1` added typed control-flow AST parser nodes, `.4.4.2` moved if-family control
    lowering onto typed condition/body fields, `.4.4.3` moved switch-family controls onto typed
    source/match/body/default fields, and `.4.4.4` moved attached while controls onto typed condition/body
    fields. `.5.1` then audited the fallback boundary, `.5.2` lowered supported standalone value statements
    as discarded `VALUE_DROP` nodes, `.5.3.1` retired `s(...)`/`a(...)`/`h(...)`, and `.5.3.2` now diagnoses
    return/value-position unknown typed calls instead of leaking generated host calls, and `.5.4` locked
    permanent `fn` grammar ownership to `specs/spec.spec` while proving bootstrap has no current first-class
    `fn` support. `SPEC-FORMAT-TERSE.4.1` then locked the function MVP contract/inventory and split the
    implementation leaves; `.4.2.1` landed the Perl grammar/registry descriptor seam. `.3.3.4` closed the assignment-expression documentation/compatibility contract after `.4.2.2`, `.4.2.3`, `.4.3.1`, `.4.3.2`, `.4.4`, `.3.2.2`, `.3.2.3`, `.3.2.3.1`, `.3.2.3.2`, `.3.2.3.3`, `.3.2.3.4`, `.3.3`, `.3.3.1`, `.3.3.2`, and `.3.3.3` landed or split/owned; later `.6` shipped-spec migration and `.7` type-method audit/backfill both closed, `SPEC-FORMAT-TERSE.15` colon scalar-slot retirement later closed, `.12.2` landed Perl hash-tree traversal, `.12.3` landed Rust hash-tree traversal parity, `.12.4` closed docs/KM/no-drift alignment, `.13.4` closed array-tree traversal no-drift alignment, and `.13.5` closed the parent terse-format task tree; no active terse frontier remains.
   - keep existing marker/composite flow behavior stable while each attached-block leaf lands,
   - keep zero-arg fluent control-flow markers punctuation-light too, so `.else`, `.endif`, `.default`, `.endcase`, and `.endswitch` stay aligned with the older parenthesized fluent forms,
   - keep those inline composite control-flow surfaces lifecycle-wide across `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`, not only on the earlier `LX` proof point,
   - treat marker-style `if(...) ... endif()` and future statement-level `switch(...) ... endswitch()` as
     structured-block-context syntax rather than as a free-standing fluent surface,
   - keep pure value-helper nested composition canonical and backend-neutral; hash-consuming and array-consuming
     helper slots now accept bare working variables on Perl/Rust after `.2.3.4.1`, while other aggregate slots
     still need their helper-specific contract before dropping explicit wrappers,
   - keep raw-Perl-free `.spec` authoring as the target.
3. Finish the remaining Backbone Item 3 cleanup:
   - reduce leftover compatibility seams,
   - `specs/ds_vhistory.spec::vhistory` now has zero compatibility-surface statements after migrating `$cur_object = call(object)` and the remaining `push @capt, call(...)` child-capture wrappers onto `assign(...)` / `push_value(...)`,
   - `specs/ds_vhistory.spec` now reports zero compatibility-surface rules after migrating the final `manifest` raw arrayref return block to `I.return(a("?manifest:"))`,
   - `specs/BNF.spec` now reports zero compatibility-surface rules after migrating the final `group` bare `return 1` statement to helper-form `return(1)`,
   - `specs/DT.spec` now reports zero compatibility-surface rules after migrating the final `testcontrol`, `group`, and `inline_dt_definition` bare `return 1` statements to helper-form `return(1)`,
   - `specs/operators_try.spec` now reports zero compatibility-surface rules after migrating the final `group`, `function_call`, and `string` bare `return 1` statements to helper-form `return(1)`,
   - `specs/tablegrep.spec` now reports zero compatibility-surface rules after migrating its child-call captures, loop `retv` declarations, aggregate lifecycle return flow, and fatal exits onto helper DSL,
   - `specs/Lispish.spec` now reports zero compatibility-surface rules after migrating top-level `return call(parenthesis)` to `return(call(parenthesis))` and bare `exit 1` to `exit_now(1)`,
   - `specs/lib_reader.spec` now reports zero compatibility-surface rules after migrating its top accumulator return to `return(array_copy(a(lib_file)))` and its group syntax-error path to `exit_now(1)`,
   - `specs/portmap.spec` now reports zero compatibility-surface rules after migrating its top aggregate return to structured helper flow and its concatenation return to `return(a("?concat:", array_copy(a(concatenation))))`,
   - `specs/tkgui.spec` now reports zero compatibility-surface rules after migrating bare `next`, bare `return`, and bare accumulator hash construction to `next()`, `return_undef()`, and `return(hash(flat_array(a(sub_gui_list))))`,
   - `specs/hlink_substitution.spec` now reports zero compatibility-surface rules after migrating dangling/unmatched delimiter exits to `exit_now(...)`, the bracket payload to neutral `return(capture_slice())`, and the wrapped brace return to `return(cat(...))`,
   - `specs/pplugin.spec` now reports zero compatibility-surface rules after migrating top-level parser state/flow/aggregation and subdef/curlyb returns to helper-form DSL; the spec returns plugin body text and the Perl `PPlugin` adapter preserves legacy plugin-body coderef execution,
   - `specs/regdef.spec` now reports zero compatibility-surface rules after migrating top/reg/field array payload returns and `ob_cb` completion to helper-form DSL while preserving the nested register/field AST,
   - `specs/ebnf.spec` now reports zero compatibility-surface rules after migrating top-rule assignment, include readers, semantic annotation cleanup, and logging annotation capture flow to helper-form DSL while preserving include and annotation AST behavior,
   - `specs/ifelse.spec` now reports zero compatibility-surface rules after migrating bare flow-stop returns to `return_undef()` while preserving the debug parser trace behavior,
   - `specs/vhdl.spec` now reports zero compatibility-surface rules after migrating remaining accumulator/list returns and comma-list tagged-row returns to helper-form DSL while preserving the VHDL smoke parser shape,
   - keep `LinkedSpec::OwnerDispatch` as the preferred seam for any remaining thin-wrapper lazy owner loading / `$@` preservation cleanup instead of reintroducing local copies,
   - keep the new `EmitContext` ActionIR owner/dependency registry as the single source of truth for that bridge instead of reintroducing per-wrapper package/dependency duplication,
   - keep the new shared ActionIR dep-map builder as the preferred way to assemble owner callback maps instead of letting `default_deps_for_package(...)` drift back into repeated inline callback registries or dead local callback-loader wrappers,
   - keep `EmitContext` and extracted ActionIR owners as the stable lowering surface.
4. Keep documentation synchronized with every meaningful slice:
   - roadmap,
   - execution notes,
   - user guide,
   - session memory.

## Deferred Architectural Risk Notes
- Keep feature addition ahead of broad refactors unless a concrete bug forces reprioritization.
- Still track these seams explicitly:
  - `perl/LinkedSpec/BootstrapSpec/Core.pm` remains the main bootstrap/frontend syntax hotspot.
  - `perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`, `perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm`, `perl/LinkedSpec/ActionIR/ControlFlow.pm`, and `perl/LinkedSpec/ActionIR/RewritePipeline.pm` form one correctness-critical semicolon-light/attached-block flow seam.
  - `perl/LinkedSpec/SpecEntry.pm` plus `perl/LinkedSpec/Compiler.pm` still define the main backend-portability ceiling because runtime handlers are emitted as Perl source strings and evaled.
  - `perl/LinkedSpec/Validation.pm` still trails parts of the supported DSL surface and remains a Phase 2 hardening target, even though current rule-label syntax, malformed extra-colon rule starts, malformed glued worded rule-mode suffixes, malformed glued edge-target suffixes, malformed action-edge fluent starts, malformed blind-call fluent starts, stray preamble before the first rule paragraph, unsupported top-level garbage inside a rule paragraph, unsupported same-line rule-header filler after a rule start or leading regex cluster, malformed `@...` split-marker spellings, top-level-only rule-start detection inside open blocks, unclosed open blocks at EOF, rule-paragraph regex validation, earlier mixed-edge rejection, malformed top-level edge-target indexing, and missing top-level edge targets are now aligned there more closely, while blind-call fluent post-call continuations are now part of the explicit supported surface too.
  - blind-call should remain mode-driven by the rule label: `=> child` must not silently make bare `rule:` mean ordered sequence just because the body is parser-step oriented.

## Deferred Future Note
- Current baseline rule-mode contract is now explicit:
  - `:&`, `:|`, `:+`, `:*`, and `:?` are the current supported rule-label suffixes,
  - `.spec` files remain paragraph-based too: after the leading `rule:` / `rule::` token, regexes, lifecycles, and edges belong to the same rule paragraph and can be interleaved without changing their structural meaning, and that paragraph-member flexibility is now regression-locked for representative action and blind-call rules,
  - that same paragraph contract now explicitly includes same-line rule bodies too, with representative action and blind-call rules regression-locked for multiline-versus-same-line equivalence rather than only freer multiline ordering,
  - action-edge target indexing is explicit current contract too: `-> rule` means `-> rule[0]`, while `-> rule[N]` selects the later regex slot and is mainly used for same-rule recursive entry selection, with representative four-slot rules now regression-locked so the regex-slot model does not silently cap out at three entries,
  - explicit ordered-sequence label `AND` is now supported on top of the current ordered-sequence rule model,
  - explicit repeated-sequence label `AND+` is now supported on top of the current ordered-sequence repetition model,
  - explicit repeated-choice label `OR` is now supported on top of the current repeated-alternative rule model,
  - explicit repeated-choice shorthand `OR+` is now supported on top of the current repeated-alternative rule model,
  - bounded repeated-choice labels `OR{N,M}`, `OR{N}`, `OR{N,}`, and `OR{,M}` are now supported on top of the current repeated-alternative rule model,
  - bounded repeated-sequence labels `AND{N,M}`, `AND{N}`, `AND{N,}`, and `AND{,M}` are now supported on top of the current ordered-sequence model,
  - blind-call `=> child_rule` is now treated as a documented advanced rule-body surface, with ordered-sequence wrappers and single-choice wrappers as the clearest current forms,
  - blind-call behavior still follows the rule label rather than the edge kind alone, so explicit `:AND` remains the preferred sequential spelling instead of making blind-call sequence the silent default,
  - repeated-choice blind-call use on `rule:`, `:OR`, `:OR+`, `:+`, and `:OR{...}` is now locked to the same label-driven repeated-choice family too, including the historical bare `rule:` shorthand,
  - repeated blind-call loops now guard against zero-progress child success so lower-bound-zero child rules do not send repeated parents into infinite loops,
  - `@capture_slice` is now the preferred anonymous split-boundary cursor feature for staged capture flows,
  - named `@mark(name)` is now the first explicit checkpoint surface for later `capture_from(name)`, `capture_len_from(name)`, `capture_until_cursor_from(name)`, `capture_until_cursor_len_from(name)`, `capture_take_until_cursor_from(name)`, `capture_take_until_cursor_len_from(name)`, `capture_take_len_from(name)`, `capture_rest_from(name)`, `capture_rest_len_from(name)`, `capture_take_rest_from(name)`, `capture_take_rest_len_from(name)`, `capture_between(...)`, `capture_len_between(...)`, and `mark_copy(...)` use, while `mark_input_start(name)` / `mark_input_end(name)` now cover the separate absolute current-input boundary write cases and now lower as safe standalone writer statements even when the stored absolute boundary is `0`, `capture_slice()` / `capture_slice_len()` / `capture_slice_until_cursor()` / `capture_slice_until_cursor_len()` / `capture_take_until_cursor()` / `capture_take_until_cursor_len()` / `capture_take_len()` / `capture_take_rest()` / `capture_take_rest_len()` / `capture_slice_line()` now cover the separate anonymous capture-boundary read and diagnostics cases, `start_capture_slice()` now covers the explicit anonymous capture-boundary move case inside lifecycle/action code (`capture_slice_here()` remains a compatibility alias), `capture_rest()` / `capture_rest_len()` now cover the anonymous capture-boundary tail-through-end-of-input cases (`capture_slice_length()` / `capture_rest_length()` plus older `capture_from_rule_start()` / `capture_len_from_rule_start()` remain compatibility aliases), `input_text()` / `input_slice(start, width)` / `input_len()` now cover the separate “read the whole current input directly” cases without first storing absolute marks, `input_end_line()` / `input_end_col()` now cover the separate “read the whole-input right-edge location directly” cases without first storing an explicit absolute input-end mark, `entry_text()` / `entry_group(index)` / `entry_groups()` / `entry_named(name)` / `entry_has(name)` / `entry_map()` (compatibility alias `entry_named_map()`) / `entry_len()` / `entry_start_pos()` / `entry_end_pos()` / `entry_end_line()` / `entry_end_col()` now cover the separate “read the current immediate match directly” cases and `match_text()` / `match_group(index)` / `match_groups()` / `match_named(name)` / `match_has(name)` / `match_map()` (compatibility alias `match_named_map()`) / `match_len()` / `match_start_pos()` / `match_end_pos()` / `match_end_line()` / `match_end_col()` now cover the separate “read the current local match directly” cases, and live delimiter-reader bands in `specs/tkgui.spec`, `specs/hlink_substitution.spec`, and `specs/simenv.spec` now also spend `capture_slice()` instead of raw anonymous-boundary `substr(...)` reads,
  - fluent direct anonymous capture-reader returns now preserve canonical general-return payload semantics too: `.return(capture_slice_len())` matches block-form `return(capture_slice_len())`, and `specs/sdce.spec::oc_brace` now spends that helper instead of raw `$LSPOS - $IPOS - 1`,
  - `input_slice(start, width)` now covers explicit whole-input substring reads from already-known absolute source boundaries, and `specs/sdce.spec::get_pinport` now spends `input_slice(match_end_pos(), call(oc_brace))` instead of raw `$LSPOS` `substr(...)`,
  - and `@capture_from_here` plus `@move_pos` remain compatibility aliases for the anonymous lowering.
  - runtime-owner compile fallback is now explicitly failure-only too: `runtime_owner:run_get_pipeline` should be written for delegated die or failure-shaped silent `undef` without deeper payload, while successful `parse_only` / `generate_only` modes still return `undef` with clear `last_error`.
- A possible later enhancement is explicit rule-grouping beyond today’s default repeated-alternative rule model:
  - related grouped rule strategies.
- This is intentionally deferred until the current default rule semantics are considered solid.

## Relationship to ROADMAP.md
- `ROADMAP.md` remains the primary long-form roadmap and historical planning document.
- `ROADMAP_V2.md` is the shorter execution-focused companion.
- If the two ever drift, update both in the same slice.
