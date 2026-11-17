# Documentation Workflow

LinkedSpec needs both public documentation and internal continuity documentation.

Those two documentation families are intentionally separate.

The repository landing page is a third, deliberately smaller surface. Root `README.md` is for stable purpose,
one first-use path, top-level architecture, canonical navigation, contribution/support entry points, and accurate
notices. It is not another public manual, roadmap, status ledger, file inventory, or gate catalog. Route detail to
the book or continuity owner first, then link from README only when that destination is part of stable navigation.

ADR `0063` and `README_POLICY.md` govern that boundary. The adopted budget is at most 128 lines and 6,144 bytes,
derived from a reviewed 105-line / 5,072-byte lossless prototype. The registered `README-STABILITY` doctrine
enforces both limits; raising either requires a new accepted, indexed decision record rather than an ordinary
feature edit. Policy/checker admission was implemented by `README-STABILITY-POLICY.1`, recomposed unchanged and
closed by `.2`, and is checked with:

```bash
bash scripts/check_readme_stability.sh
```

Routing-pressure revision `.4.0` audited the next boundary before changing that checker. Implementation `.4.1`
introduced `doctrine/readme_stability/routes.jsonl` and an unconditional core-Perl resulting-tree check. The current routing checker also invokes project-managed Python standard-library scope admission under ADR `0139`. It classifies
reader navigation separately from author-overflow destinations, follows routes transitively, assigns
lifecycle-specific controls, and records legacy high-water marks as debt rather than healthy targets. Every focused run now
proves 62 exact routes over 20 surfaces and all 40 mutation classes before the README doctrine can pass.

The audit also found and traced a stale root `test_input/` layout entry introduced during the original README
trim. LinkedSpec's current fixture roots are `t/` and `tests/`; `.4.1` removes the false route and checks every local
target for existence and symlinks. Four already-large neighboring families—live status, task evidence, changes, and engineering
notes—have a separate `LIVE-DOCUMENT-PRESSURE-CONTAINMENT` owner so the README revision does not silently bless
their present size or mix semantic migration into doctrine admission.

The implementation's definitive local gate passes all seven doctrines, repository containment and moved-root
proof, primary CLI 66/66 in both option environments, and Phase 0 1,031/1,031 in 694 seconds. This closes
implementation signoff without changing parser, runtime, backend, fixture, MCP, or CLI behavior.

Closeout `.4.2` then byte-compares the seven admitted policy/README/registry/checker/doctrine/gate owners with
commit `5c570719` and reruns the full proof without a replacement implementation. The independent gate passes
primary CLI 66/66 twice and Phase 0 1,031/1,031 in 673 seconds, closing routing-pressure revision `.4` unchanged.
`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.0-.4` then preserve exact live/change/note history, partition future task
evidence by stable ID, install bounded current views and complete-record rollover, and independently recompose
the four current routes unchanged. That documentation-sustainability program is composition-closed. Historical admission counts and lifetime limits in the dated examples below remain provenance, not current growth allowances.

Accepted ADR `0139` adopts exact query archives for the two author histories and task-owned maintained scope for decisions, Knowledge cards and public references. It retains all canonical browsing paths and original per-file/hot-root/segment limits. Catalog pages and source-bound closed narratives preserve exact retrieval; current task collection ceilings stay unchanged. TYPE now joins FUTURE and STARTUP as a partitioned tree. Update a changed maintained reference's ledger before staging with `bash tools/run_python_project_data.sh tools/update_reference_scope.py --owner <leaf-id>`; the routing doctrine rejects stale, unknown, symbolic or unowned members. The integrated restoration requires normal hooks and an exact staged canonical receipt; no temporary waiver or cap refresh is used.

The public book explains LinkedSpec to the outside world. The continuity docs help the project survive crashes, handoffs, and long refactoring sessions.

## Accepted decision authority

An authority record must contain exactly one canonical `- Status:` field whose first state word is `accepted`.
Both of these forms are accepted:

```text
- Status: accepted
- Status: accepted; qualified engineering decision
```

These are alternatives, not two fields to put in one record. A proposed or missing status, two Status fields
(even two accepted fields), and a word such as `acceptedish` reject admission. The same rule governs new routed
limit or lifecycle changes, new README-cap increases, and the initial ADR `0063` authority paths. Accepted status
does not replace the indexed filename, newly added staged record where required, or exact previous/new markers.
For example, a proposed record with otherwise correct old/new cap values still fails the README doctrine.
The wrapper's recurring tests exercise both actual cap-authority helpers; the routing oracle exercises all three
actual routing-authority branches. Pressure, generated-owner freshness, and staged/worktree agreement remain
separate checks.

A new archive slot admits only one measured rollover.
Keep root, per-file and aggregate limits unchanged unless their own accepted authority changes.
Add decision-index rows inside the existing table, before its authoring instructions.
When repairing placement, retain accepted row text and decision files exactly.

A complete record can trigger rollover through line count even when bytes remain
below the byte boundary. For example, adding four lines to a root with460 lines
crosses the mandatory461-line boundary. Retain the actual `--check` failure before
running `--apply`; inspect the clean-Git suffix, source blob, line range and digest.
If the collection has no archive slot, own a separate finite admission before
continuing feature work. Its exact manifest growth and sole decision/index overhead
need accepted authority; an earlier finite allowance supplies no future reserve.

Rollover generation and capacity admission are separate steps. After the roller
creates an exact archive, the existing routing gate can reject the additional
member and manifest growth. Retain that rejection before adding the finite
accepted decision and exact limits; then stage the whole proposal and run
canonical CI. A successful generation alone grants no capacity.

### Finite continuity example

ADR0136 combines one measured change-history member with one finite engineering-note
envelope. The roller preserves a complete 257-line suffix from the accepted source;
the unchanged checker rejects the added member, manifest growth and exhausted note
aggregate before any allowance changes.

| Surface | Previous allowance | Finite allowance |
| --- | --- | --- |
| Change-history files | 50 | 51 |
| Change-history manifest lines | 49 | 50 |
| Change-history manifest bytes | 27983 | 28559 |
| Engineering-note aggregate lines | 29512 | 30024 |
| Decision files | 136 | 137 |
| Decision aggregate lines | 13285 | 13326 |

The 512-line note envelope covers the declared maintenance, due artifact review,
fixture admission, pipeline and metadata continuation, including bounded child splits.
The sole decision adds 40 physical lines and one index row. Root, byte, per-file and
engineering membership/manifest limits stay fixed; this grants no future archive slot.

Check the control instrument's actual population independently. In this example,
the first instrument's arithmetic checks passed while it read the wrong history
manifest. A separate census rejected both affected populations. The exact two-line
correction then passed the real census, inclusive boundary observations and authority
denials. Preserve that rejected source and output alongside the corrected producer.

### Dated retention and reported-output example

The current dated review retained 16443 parent artifact rows and 483 Rust incremental rows, with zero removals. Independent live
census and per-file metadata checks ran before publication. Keep the dated snapshot,
complete command channels and reusable caches; a retention review supplies no
content-ownership, disposability or liveness permission.

| Public compiler summary | Occurrences in captured log | Reported count per summary |
| --- | --- | --- |
| pgen | 12 | 7093 |
| rgx-core | 12 | 26 |

Each row records compiler reports from the warranted canonical run. Distinct
diagnostics, defects, comparable configurations and internal causes remain unassessed.
The earlier dated 1870/26 account stays preserved. The upstream-owned warning census
and reporting tasks remain open; this observation introduces no new dependency build,
implementation inspection, pin change or warning suppression.

### Explicit fixture selection

The canonical runner selects an explicit supplied population. Adding a file alone
does not add its test execution. The retained original direct-command inventory is:

| Population | Paths | Original presence | Original syntax | Original direct prove |
| --- | --- | --- | --- | --- |
| Supplied suites | 91 | 4 | 5 | 5 |
| Supplied test helpers | 46 | 1 | 1 | — |

These counts describe literal tracked-file, syntax and prove commands; indirect
coverage was not inventoried. The admitted block lists all 91 suites and 46 test
helpers, checks each of the 137 paths through Git presence and Perl syntax, then
runs all 91 suites. One suite is a historical checkpoint fixture. All 363 supplied
input bytes and modes stay unchanged. The .7 canonical admission at `64b66167c` passes 30,394 assertions; the later focused pipeline extension is described below.

| Actual selected-block experiment | Syntax paths | Suites | Shell exit | Population oracle |
| --- | --- | --- | --- | --- |
| Complete block | 137 | 91 | 0 | PASS |
| Suite omitted | 136 | 90 | 0 | RED |
| Helper omitted | 136 | 91 | 0 | RED |
| Suite duplicated | 138 | 91 | 0 | RED |
| Execution disabled | 137 | — | 0 | RED |

Each row retains the actual Bash script and full command channels. A successful
shell exit alone permits missing or extra work; independent ordered syntax and
test-path populations plus the harness summary distinguish it. The recurring
historical auditor removes only the exact 150-line insertion before its older
inverses and still requires every original runner byte. Its per-path mutations
operate within that block, because six names also occur in older commands.

The current source preparation retains 952 candidate consumer files and 221 classifier proposals; 131 proposed Perl paths have no direct unconditional selector. Actual Bash argument extraction uses stubs, with five missing/duplicate/disabled-command controls and five independent evidence controls. These are preparation results. Target ownership, actual loaders, automatic backend discovery, SDK tests and canonical inclusion still need their own proof.

A bounded Dart loader review covers six named consumers: ten fixture inputs, six grammar dependencies, one support import and one optional capture readback. The `with` fixture expands its extension to separate spec and JSON inputs. Four normals read grammar explicitly; constructor/`with` rely on the cached default parser, which searches upward from the current directory before the script directory. The callable-transform capture writes serialized input before reading it back when its capture environment variable is set. Source interpretation and the earlier fixture ledger agree, with eight omission/role/path controls. These facts describe source routes; actual runtime lookup, cache state, package resolution, complete loader coverage and canonical execution remain separately verified work.

Source discovery also distinguishes a Perl test selected directly by `prove` from a test included inside another selected suite. For example, the callable suite loads the pipeline-value contract in a subtest; its `done_testing() unless caller` supports that include route. The bounded role review retains feature, compatibility and maintenance candidates separately. The default-literal contract has no direct or named-callable selection in that review and is owned for registration repair. Source routes and retained omission controls do not establish executed tests, complete dynamic loader coverage or canonical admission.

Native source routes also require distinct evidence. A Rust package test command and a Dart package test command can select files by documented conventions; Julia package tests enter `test/runtests.jl` and its named includes; Lua local tests use explicit operands or named `dofile` calls. A convention-compatible filename alone establishes no execution. Inert shell recorders can verify optional flag selection, including missing, duplicated and disabled commands, while leaving SDK discovery and test results unclaimed. Remaining transitive routes and direct artifact loaders must be resolved before freezing canonical registration input.

Lua direct input review separates immutable fixtures from generated capture outputs. A suite may iterate literal fixture paths, obtain a cached module-relative function grammar, or explicitly supply that grammar. A `dofile` returning observation functions is a support input. Optional capture helpers may write parsed JSON or emitted source before reading those bytes back; those paths are outputs with readback dependencies. Retain the source expressions and conditions, then compare earlier input ledgers without assigning new execution or canonical-selection credit.

Dart guard normals can read cases, domain profiles and an explicitly supplied grammar from a declared package cwd. Optional one-shot captures have a different role: they require an allowed phase and an absent target, write parsed JSON, then read and check it before target compilation and restoration. Parsing precedes that write. Preserve those conditions and the original source epoch when qualifying the loader graph; matching historical file identities does not renew an earlier execution or custody claim.

A constructed fixture path needs its caller vocabulary as well as its read expression. For example, a `fixture(extension)` helper called with `spec` and `json` reads two files; a stem helper or literal loop may expand one read site into several targets. Keep inline observations and AST/domain snapshots in their actual roles. Registering a suite that skips named runtime cases or preserves a backend-specific expected value does not close those independently owned qualifications. An older broad root snapshot can corroborate file identities without proving that every captured test ran.

Lua `assert(loadfile(path))` compiles a chunk and returns it; calling that chunk requires a separate invocation. A syntax check of the shared runner therefore supplies no test-selection evidence. Keep an input-root-prefixed fixture or syntax path separate from `require("linkedspec")`, whose actual package/cache resolution needs its own origin proof. Likewise, distinguish write-only captures from bytes that are read back and then supplied to restoration or emitted-code loading, and record which earlier SDK operations already happened. An optional environment condition may accept an empty string in Lua; preserve the actual branch condition.

A Julia generated parser included with `Base.include_string(Module(...), emitted)` gets a new module in the same process. Keep that role separate from file reads and fresh-process execution. Also distinguish restoring parsed JSON into an AST from compiling that restored AST: an optional write after AST restoration can still precede the restored compilation. Capture timing must name the exact operation. For evidence controls, verify which semantic row was removed; deleting the first row can reject a ledger while testing a different qualification from the label.

Rust `include_str!` supplies compile-time source dependencies; verifying the current file is separate from proving bytes embedded in an older binary. An optional readback can check equality without replacing the object passed to compilation. Follow the actual next argument: restoring from `retained` and calling a plan with `serialized` have distinct provenance even when their values agree. Keep observation-only exports and emitted source strings in their actual roles. Historical packet selection must use that producer’s documented schema, such as an exact archive locator.

A generated-source classifier has both a parent program and programs assembled as strings. The Rust full-manifest source has three parent tests; its two child-test templates are written into generated modules. Its manifest names105 cases, each with `input.spec`, `input.txt` and `expected.json`: these315 paths are potential preparation inputs. Only successfully prepared cases reach generated module writing. Extra manifest provenance metadata is not another file dependency.

| Rust parent route | Source inputs and generated artifacts | Child-process check |
| --- | --- | --- |
| Full manifest | Runtime manifest/corpus, embedded function grammar, generated crate/modules/index | Compile status required; run markers counted while run status is diagnostic. Known repair: `SESSION-STARTUP-READING.77`. |
| Focused emitted Count | Two embedded fixtures containing16+1 rows, generated crate/modules/index | Separate `cargo test --lib` requires successful exit. |
| Native Count trace | Two named rows from the16-row fixture; Engine writes then reads trace files | No Cargo launch in this parent. |

The source-level Cargo helper requests offline/quiet execution, a generated-project cwd and its own target directory. Actual Cargo identity, dependency resolution, effective temporary root, embedded bytes and successful test execution require separate runtime evidence. A current source/fixture identity match with an older ledger supplies none of those execution results.

Named test selection needs more than a file census. For Lua, `assert(loadfile(path))` returns a compiled chunk; the caller must invoke that chunk to run its body. Keep the syntax loop separate from explicit test operands and the shared runner's `dofile` calls. The current isolated primary and secondary command blocks each select44 operands, while the shared source contains83 literal `dofile` calls. Inert Bash recording can expose a missing or duplicated runner even when the shell exits0; it establishes operand selection, not successful Lua execution or host availability. A literal-reference census also leaves computed names and callers outside its declared source roots unresolved.

Freeze each evidence instrument before using it. Adding readonly recovery support creates a new instrument epoch. If a probe already imported a changed reader, retain the actual body and compare the helpers it called with the frozen original. Later recovery can qualify the saved observations while honestly retaining the missing before-use capture; it cannot recreate that earlier custody event.

Perl source inventory also needs token context. The same text `open` can appear in a builtin-like word, a method name, a hash key, a declaration or an expected-code string. A static PPI census round-trips145 retained sources and freezes overlapping follow-up groups:122 files with IO/readline candidates,143 with eval/process candidates,84 with named helper candidates,127 with non-Word/heredoc contexts and three with non-block `do` sites. These counts describe source candidates, not reached operations or resolved input files. The vocabulary is bounded; retain the full145-source population when resolving custom helper and library loaders.

Preserve heredocs through document serialization: token or statement `content` alone omits their payload. Quoted and interpolated payloads can also carry later execution and need separate analysis. Controlled examples can distinguish static inspection from compiling a `BEGIN` block without running the LinkedSpec tests. Resolve each candidate's exact caller, target, mode and phase before treating it as a fixture dependency or a selected suite.

Named Perl includes need caller roles as well as paths. The fourteen inspected `do` sites name twelve suite files and two package probe libraries. Each suite imports `Test::More` and ends with `done_testing() unless caller;`: including it suppresses its final plan while leaving assertions in the source. The AST and callable parents wrap their suite includes in subtests. The two libraries guard standalone `observe` output with `unless (caller)` and expose observation functions to the parent. One declares a cold Perl subprocess; retain that child separately as context. Source-derived paths, guards and selection multiplicity establish neither actual execution nor native input custody.

Literal file opens need mode and token context. In the inspected Perl population, a deliberately bounded grammar accepts34 of191 `open` Word sites:32 literal input reads and two declared output writes. All157 unmatched sites remain in the follow-up inventory. For example, `open my $fh, '<:raw', 'tests/fixtures/example.json' or die $!;` declares an input, while a `'>'` mode declares output. A scalar reference such as `\$buffer` names an in-memory capture; a variable or concatenated path needs separate binding analysis. Quoted expected code, method names and heredoc payloads do not automatically qualify as literal opens. Retaining source-declared paths proves neither actual reachability nor complete file origins.

Variable-bound paths need a narrower source claim. Across159 retained original and named-support files, a bounded adjacent lexical-initializer grammar qualifies one read among192 open sites. It requires a simple quoted ASCII path, matching source symbol and the same PPI parent, while preserving191 unmatched sites for other analyses. The read supplies a historical JSON comparison baseline; a stored successful result is not a new execution verdict. PPI quote strings strip delimiters and do not generally evaluate Perl escapes or interpolation. Controlled source changes can test adjacency without running the application.

IO syntax also needs operand roles. A subsequent159-source inventory retains322 sites, including the same34 direct literal sites,35 scalar-output declarations and one process-pipe declaration. It leaves122 variable or constructed file operands and130 non-open sites explicit:121 readline forms plus nine glob, directory, pipe or sysread Words. Scalar-backed output captures supply no input file; a handle read needs its handle origin resolved before it can identify an input. A source-shape role alone establishes neither the selected callee nor runtime reachability. Controlled scalar-reference removal distinguishes a capture declaration from a variable file operand without running the application.

Resolve an unresolved input cohort in bounded stages: fixed variable declarations, helper formal/caller bindings, then library, process and handle origins. Each stage preserves the complete source population and its unresolved sites; a successful lexical stage does not close independent semantic or native-input verification.

A closed-tree epoch can renew current text capacity while preserving its full source. One Perl AST migration tree keeps all28 IDs and CORE fields, five complete unselected bodies and its52263-byte frontier/tail;23 closed commentary pointers reduce current text from88302 to75228 bytes. Whole-source and every ID query recover original bytes. That13074-byte reduction is text capacity under existing limits, with original SDK observations still historical.

The closed staged-parsing tree uses the same source-retaining interface:15 ordered IDs and all CORE fields, two full unselected bodies and the19108-byte frontier/tail remain current. Thirteen commentary pointers renew11972 text bytes. The whole-source query and every node query reproduce the original bytes. For this dated source, run `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree STAGED-LINKED-PARSING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.36 --all`. This changes task text capacity, with original runtime observations still historical.

Closed-task commentary can use the existing explicit epoch interface while every current contract, unselected body and complete frontier stays in place. The helper-purge epoch retains its original source and every stable-ID query; it changes no helper behavior or old delivery date. Historical pressure recovery similarly reads the archived task view, while the original strict current-view reader remains dated. Neither form supplies fresh SDK or canonical-admission credit. For the complete helper-purge source, run `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree NONCURRENT-HELPER-CODE-PURGE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.34 --all`.

Archive member names must be derived relative to the repository before adding source images. The planning capture used an absolute self-source name and retained the checkout prefix in that one archive member. A separate qualified archive restores the canonical namespace while retaining all226 member bodies/modes; native tar independently recovers every body/mode. The original capture stays historical, with no new original first-use or native-custody credit. Recovery: `bash tools/run_python_project_data.sh docs/checkpoints/canonical-discovery-inventory-2026-11-16/review_portable.py`.

Accumulated feature regressions enter canonical CI in two steps: first freeze the current consumer/helper/fixture inventory and distinguish direct, automatic and optional backend selection; then repair the proven omissions with an exact historical CI inverse and current-source admission. Source inventory supplies no runtime or canonical-execution credit. The registration slice requires an exact staged receipt and actual required backend routes; declared-host and native-custody gaps retain their separate owners.

Keep future tests task-owned and explicitly registered. Exact staged canonical
CI and normal hooks govern admission. Pipeline scope and broader private/mapped
execution retain their separate owners.

Preserve any live evidence that binds the root or book before changing them.
Keep its original hashes at the accepted Git revision, then separately verify the
new rollover against that revision. A healthy render also checks recursive local
includes: mdBook can report an include error while returning exit0.

A historical review command requires its original logical inputs.
Use the current Knowledge card's readonly entrypoint when documents have changed;
it should preserve and check the accepted publication separately. Updating a
command must not refresh an earlier observation or silently change its boundary.

Recurring CI can also check current runtime compatibility against unchanged
semantic expectations, as the native and fresh factory probes do. Keep historical
byte-preservation and source-calibration checks tied to their frozen epochs.
Current compatibility must still reject changed values, kinds and effects;
it does not require later feature implementations to reproduce old source bytes.

The historical objective audit separately admits exact committed source images.
Keep the original image table and earlier inverse checks; a successor record names
the accepted commit, path and SHA-256 of later source while retaining its old
predecessor oracle. A first-image record retains the exact historical predecessor,
as for the Dart emitter test changed by Count73.3. Unknown historical members,
noncommit revisions, symbolic file modes and unreviewed current bytes reject.
Fixture calibration keeps its own boundary. Source identity admission does not
advance the original runtime observations; feature tests own current behavior.

### Pipeline scope proof

The pipeline extension uses the already selected factory-capture suite, so the
canonical selector remains 91 suites and 46 test helpers. Its focused proof keeps
the earlier canonical admission's original inputs/results at `64b66167c` and
preserves the complete publication (603 inputs, 115,985 bytes) before changing shared files.

| Current focused observation | Retained population |
| --- | --- |
| Native context, aliases, ordering, values and errors | 96 original rows |
| Callable, tied lookup and release behavior | 9 rows in distinct original/load-context epochs |
| Positive pipeline fixture | 2,065 assertions |
| Exact syntax-valid semantic source inverses | 13, each with the same plan of 2,065 assertions |
| Complete supplied runtime inputs | 426 files with saved bytes and permissions |
| All previously selected direct suites | 91 suites, 32,235 assertions |

The source controls remove either scope, move it outside the original-source
invocation, remove each actual callback boundary, duplicate an apply lookup,
retain opaque callbacks, register supplied callbacks, move native non-CODE
diagnostics or coerce body context. Same-source opaque publication, actual
identities, independently authored Unicode argument intervals and complete
native ledgers distinguish these faults. The public lowering facade selects an
actual native callback with its source origin and matching invocation registries.

Retain failed instruments too. The initial fixture require lacked a runtime root
anchor; an initial assertion plan depended on observed captures. Separate native
diagnostic epochs exposed the actual `prove` include conversion before imports,
and a later oracle reader added its own line context until explicitly closed.
Whole used sources, inputs, raw channels and exact repairs remain distinct.
Portable comparison projects only the expected historical owned-module filename
to the current verified module; actual errors and native lines remain exact.

This is focused invocation/callback integration. Native output composition,
mapping, the quoted-first replacement fix and complete private/parent admission
keep their separate owners. No selector, public language or budget change follows.

### Pipeline observation transport

The native load-context record retains the actual include argument used by Perl.
Its standard JSON transport escapes solidus characters without changing any
decoded value. Exact original bytes, arguments and channels remain recoverable;
the unchanged original readers verify a restored copy on repository storage.

That restoration exposed an input declaration gap. The original draft declared
625 bindings in 123,401 bytes, but its reader also inspected a fixed Git claim
namespace. The current proof supplies all 161 missing claim inputs, including the
actual prior-claim freeze, and retains the first failed replay. It gives no Git
revision to the original uncommitted draft. Original runtime measurements keep
their original sources and dates; the current factory suite also checks the
decoded transport. Production code, the path gate and native observations stay
unchanged by this representation repair.

### Checkpoint artifact parts

The original packed preservation has 127,191,037 bytes. GitHub's
[ordinary Git file limit](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github)
is 100 MiB, so this checkpoint stores four exact parts, each at most 32 MiB. A manifest
retains aggregate identity, permissions, the complete original 669-input claim and
the before source images needed to recover its supplied context.

The unchanged original reader executes against bytes recovered from those parts;
every supplied input and the whole claim retain their bytes and permissions.
Current verification assembles a compatibility copy during the command and
removes that known copy afterward. The tracked parts retain every durable byte.
No native observation, gate or repository history is rewritten, and no oversized
push is attempted. Corrupted, missing or reordered parts must be rejected.

### Historical claim populations

Current Knowledge cards keep their factual explanation and one current verification
route. Repeated historical route headers belong in the owning checkpoint archive,
with exact original bytes and a readonly replay route. This keeps the bounded live-card
collection useful without discarding earlier evidence or raising its size limits.
A first uncommitted candidate is recovered from its supplied bytes; it must never
be assigned an invented accepted Git revision.

A review of an accepted claim population must enumerate files from that same Git
boundary. Listing today's claim files and then reading each from an older commit
fails as soon as an unrelated newer claim is added. Keep the historical population
fixed; verify newer files separately. For example, adding a daily maintenance claim
must leave an accepted callback review usable without substituting its old inputs.

An accepted publication replay can also require published historical inputs beyond
its immediate live bindings. Supply those inputs from their recorded revisions,
verify their original hashes, and retain any incomplete replay and its failure.
Keep complete diagnostic channels byte-exact and portable, including tracebacks.
Encode raw diagnostic bytes when they contain checkout identity, and decode them
for review. Changing that representation must retain the original publication
and prove that altered diagnostic bytes are rejected.

A corrected reader has its own executed source and identity. A historical report
continues to identify the producer that originally captured it; changing the reader
must never relabel or refresh that observation.

The current verification entrypoint checks this explicit supplied fixture selection
and preserves the complete 175-input retained-review publication and its actual successful
baseline at `858eba97c`. That review retains the complete 550-input finite-capacity
publication at `e953f69a9`. The complete 565-input mixed-default/package-object
publication remains at `54bb5eb65`, retaining native observations, exact definition-owned
selection, full-source faults, supplied consumers and the public Perl diagnostic contract.
Administrative maintenance refreshes none of those observations.
The complete initial546-input logical draft is preserved with every input byte/mode.
Its actual original publisher replays from2020 supplied files; this is an uncommitted
logical draft, not a historical Git revision or admission for object targets.
The last committed predecessor is the complete525-input direct/rule publication at
`ce9eaf32e`. The complete506-input optional-kind publication remains at `2b35b77ea`. The earlier output-helper publication at `dadce45ac8` retains its
495-input compiler claim and separately scoped historical wrapper sample. The
complete480-input switch publication remains at `4a8e92aef`, and the complete463-input
if/while publication remains at `09000223f`,
the earlier155-input artifact publication at `a60764c11`, and the finite
engineering-history publication at `e2ec1e96b`. No historical observation is
refreshed. The finite example above changes only its listed allowances; this dated
fixture admission changes no budget or DSL semantics:

```bash
bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/publish.py
```

Its default is readonly. The earlier fixed-population reader under `.3.2.1.10`
requires its accepted `de02b83a1` logical inputs when rechecking that historical
publication; it must not substitute later runtime or documentation bytes.
Capture, preservation, supplied-replay and source-fault writers are one-shot
evidence producers, not resume commands. Each accepted record retains its own
scope, source identity and historical boundary.

When a diagnostic input proves unstable, retain its first producer and actual
observations. For example, the optional AST probe's ordinary tied-hash iterator
changed only clone FETCH order across unchanged-source runs. Its distinct sorted
iterator input was observed twice before regression expectations or production
edits. The reader checks complete native rows and byte-identical recurrence;
it does not normalize or replace the original unordered observations.

### Knowledge header lists

Fact cards use a small documented YAML subset. A block list starts after a key
whose value is empty; a scalar or inline list completes that key. For example:

```yaml
answers:
  - where is capture authority checked
tags: [parser, capture]
reverify: printf ok
```

Adding an indented list item after that `reverify` scalar is malformed:

```yaml
reverify: printf ok
  - another command
```

The Knowledge checker rejects the orphan item and names its line number. It also
rejects a scalar `answers` field followed by detached questions, keeping that
mistake visible to validation. Ordinary documents without a fact list remain
outside the Knowledge Map.

Run the gate and its public-interface regression fixture with:

```bash
bash knowledge-map/scripts/check_knowledge_map.sh
bash tools/project_data_run.sh prove t/knowledge_map_header_lists.t
```

Canonical CI runs the fixture. Regenerating the derived index and validating its
source headers serve separate purposes; both are required. The checker covers
required fields, list association, unique IDs and map synchronization. The
constrained format and its limits are documented in
`knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md`.

### Scoped question aliases

Precise question aliases lead to the existing canonical fact and its recorded
evidence boundary. Search the problem words, then read that card before choosing
a verification command. For example:

```bash
rg -n '128KiB|twenty assertion inverse' KNOWLEDGE_MAP.md
```

Adding aliases updates the derived question-total header while preserving the
existing routes and fact entries. Historical commands use their declared Git
capture or supplied logical artifact epoch. A frozen input bundle retains that
named epoch; its replay and the current implementation's verification have their
own scope. The alias examples point to already recorded bounded proof.


### Evidence and verification lists

The map displays scalar and list values for `evidence` and `reverify`. Lists keep
their authored order and repeated entries. For example:

```yaml
evidence: ["source, notes.md", tests/evidence.t]
reverify:
  - bash scripts/check_memory_architecture.sh
  - bash knowledge-map/scripts/check_knowledge_map.sh
```

The fact entry shows each value in its own code span:

```markdown
- **evidence:** `source, notes.md` · `tests/evidence.t`
- **reverify:** `bash scripts/check_memory_architecture.sh` · `bash knowledge-map/scripts/check_knowledge_map.sh`
```

Question rows link to the complete fact list with an `N entries` label. A scalar
command keeps its existing inline presentation. Generation and validation display
these commands without running or combining them; follow the context written in
the fact when choosing a check. Code-span delimiters preserve backticks inside
list values. Double-quoted evidence/reverify inline items can protect commas and
escaped quotes; block lists keep complex commands readable. Questions containing
commas continue to use the existing block-list form.

## Later task-narrative epochs

Closed task evidence can grow after an earlier archive snapshot. Keep every
current ID, contract field and open task body visible, then name a new extraction
epoch explicitly. Existing queries without an epoch keep their original source.

For example, this reads the complete accepted historical body of one closed node:

```bash
bash tools/run_python_project_data.sh tools/read_task_narrative.py \
  --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 \
  --id PERL-PRIVATE-FACTORY-CAPTURE.1
```

Replace `--id ...` with `--all` to read that epoch's whole source file. The current
graph remains in `docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md`; the query returns the
explicit historical snapshot, including its original dates and statuses.

The bounded immutable manifest under `docs/history/task-narrative-epochs/` names
the accepted commit, source path, Git blob, SHA-256 and selected IDs. Git retains
the complete body through that ancestor commit. A full-history clone supplies
the source; the reader verifies its identity and ancestry before returning it.
The task metadata gate rejects lost contracts, wrong or missing pointers,
corrupted source identities and changed committed manifests. Open bodies stay
complete. The one-shot migration requires its own task owner and explicit source
commit. It checks repository/volume boundaries and retained ancestry before writing,
rejects symlink and nonregular targets, and refuses repeated original migration
before creating a candidate. Existing data extractions use their declared focused preservation checks and
normal hooks. Reader, migrator or doctrine infrastructure changes require canonical
acceptance under the commit workflow.

The later Dart milestone epoch preserves all 68 IDs, 58 closed contracts and ten
unchanged short bodies. Its entire current frontier and trailing sections remain
unchanged at 54,718 bytes. The source shrinks from 171,451 to 106,515 bytes under
unchanged limits. Read the
original closed commentary with:

```bash
bash tools/run_python_project_data.sh tools/read_task_narrative.py \
  --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --all
```

All 69 public source and node queries match exact original bytes; an independent
readonly recovery rejects ten deliberate preservation faults. Tools, registries,
limits and runtime behavior are unchanged. Original SDK observations and milestone
dates remain historical, and this data migration supplies no fresh Dart parity or
whole-project reading credit. The separate lowercase frontier/query repair remains
owned; this source has the exact uppercase boundary.

This renews the bounded current document collection. The full Git history remains
retained, and the text reduction supplies no disk-reclamation or upload-size claim.

The hygiene epoch uses the same unchanged data interface:

```bash
bash tools/run_python_project_data.sh tools/read_task_narrative.py \
  --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --all
```

All 25 IDs/contracts, three complete unselected bodies and the full 22339-byte
frontier/trailing section stay exact; 22 closed narratives gain source pointers.
All 26 public queries and independent recovery with ten corruption controls pass.
Current text changes from 110217 to 61280 bytes, renewing 48937 under unchanged
limits. The epoch interface requires an unpartitioned tree. Original cleanup dates,
totals and frontier words remain historical; current work resumes from MEMORY.md.
This preserves task data, with no new cleanup, runtime or parity claim.

The storage-locality epoch preserves all22 IDs/CORE fields, five complete unselected
bodies and the full35225-byte frontier/trailing section.17 closed narratives gain
source pointers; current text changes from98757 to58170 bytes, renewing40587 under
unchanged limits. Recover the exact original source with:

```bash
bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --all
```

All23 source/node queries and independent recovery with ten corruption controls
pass. The first terse attempt is retained as a guarded refusal: its189 records
already had original archive pointers, so it supplied no new capacity. Readiness
checks must exclude both original and epoch pointers and confirm a shorter
eligible body. Original source/producer/command/mode evidence remains exact.
This data epoch preserves dated storage evidence; current deletion, SDK and parity authority stays with its existing owners.


## Public book

This book is for:

- users
- adopters
- contributors
- evaluators
- future readers outside the immediate implementation loop

It should explain the project clearly and transparently.

The public book lives at:

```text
docs/linkedspec-book/
```

Its job is to answer questions like:

- What is LinkedSpec?
- How do I write and read `.spec` files?
- How do I call `Get(...)` and `get_parser(...)`?
- What does descriptor introspection expose?
- What helper DSL methods exist and why?
- How does compilation work internally?
- How does runtime context and tracing work?
- What shipped material exists?
- What are the real architectural boundaries?

If the outside world needs to understand it, it belongs in the book.

## Internal continuity docs

The repo continuity docs are for:

- crash recovery
- session handoff
- implementation continuity
- commit hygiene

Examples:

- `CHANGES.md`
- `DEVELOPMENT_NOTES.md`
- `MEMORY.md`
- `COMMIT.md`

The latest artifact-maintenance date and disposition live in `docs/ARTIFACT_CLEANUP.md`. Each cleanup has a task-tree owner, exact targets, retained evidence and permitted
process/open-file checks. Ignored status, age and size alone never authorize removal. Preserve reusable dependency caches and every unresolved experiment. Never follow
symlinks or traverse another Git repository; an inaccessible liveness check means retain. For rebuildable Rust output, quarantine only the parent target on the same filesystem,
build a fresh locked/offline primary executable, and run public examples before using native Cargo clean on the old quarantine. Preserve the new usable target and package store.
For repeated fixture trees, copy all unique file bytes and per-path metadata first;
verify every payload, restore a sample and run its actual public readers before deletion.
The October25 cleanup removed 112,969,338,880 allocated bytes of old Rust output and
119,213,043,712 allocated bytes of history fixtures, retaining a 55,259,061-byte archive.
Those are dated per-target measurements. Cargo's larger logical deletion summary and
the volume's free-space movement are different quantities; other projects may use that volume.
The remaining large scratch area containing a nested repository stays protected.
The successful history regression's recurring fixture accumulation has a separately
owned repair, `REPO-HYGIENE.24`; the cleanup itself does not prevent future growth.
Review the retained cleanup without rerunning any capture or removal command:

```bash
bash tools/run_python_project_data.sh docs/checkpoints/REPO-HYGIENE.23/review.py
```

All other Git repositories and submodules are excluded before traversal. A project task or
notification does not authorize modifying them; their owners apply any upstream repair.
Retained verification logs and canonical receipts are evidence, so their size or age
alone does not authorize deletion. A handoff finishes the current slice, clears
`git_message_brief.txt`, and verifies clean Git state and no required background job
before leaving the next task in `MEMORY.md`.
An explicit pause also records that work must wait for a resume instruction.
If a host rejects publication, retain the actual error and remote boundary,
schedule publication recovery before feature work, and distinguish the verified
commit from later documentation commits that require their own exact-HEAD proof.
On resume, recheck the host and independent Git/API refs before changing
authentication or retrying publication. Commit the recovered-access checkpoint,
then obtain canonical proof for that exact clean HEAD and retain the actual push
and read-back afterward. A later outcome record needs fresh proof at its own
publication boundary.

The November5 recovery record at `docs/checkpoints/publication-recovery-2026-11-05/`
retains the successful default canonical gate, exact committed receipt, normal
push and independent ref/workflow responses. The later focused event record
separately resumes feature work; publication proof stays bound to the actual
published commit. Quiet test output alone establishes neither success nor a hang.

The November12 review retains all1316 matching metadata rows in eight named
scopes. Separately, three completed own normal-commit logs preserve133480
content bytes/full modes in compressed evidence before independent recovery and
removal of only their plain copies. Postdelete recovery and16 metadata/
log/channel/task-link corruption controls pass. Caches, native products and other
proof remain retained; no physical reclamation claim follows. The latest-only
record is `docs/ARTIFACT_CLEANUP.md`. Review without rerunning capture/retirement:

```sh
bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/artifact-review-2026-11-12/review.py
```

The November16 retention review compares 1316 dated path/suffix/byte rows in the same eight scopes with independent scandir/lstat, rejects five altered-evidence controls, and removes nothing. Source images precede helper import and scanning; the complete native/OS custody leg remains open. Its readonly recovery is `bash tools/run_python_project_data.sh docs/checkpoints/artifact-review-2026-11-16/review.py`.

A daily review can retain every candidate. The November10 bounded review compares 1,181 rows in eight named artifact scopes with an independent metadata walk, verifies the configured Rust target is covered, and removes nothing: cache usefulness and unresolved proof obligations take precedence over filename, age or size. Its dated snapshot, complete command channels and readonly reader live under `docs/checkpoints/artifact-review-2026-11-10/`; earlier observations remain unchanged, and the latest-only record remains `docs/ARTIFACT_CLEANUP.md`. Project census producer bodies are retained before helper import and checked unchanged afterward. Five metadata and four channel counterexamples reject. Before editing this shared chapter, the eight checked claims of the accepted prior checkpoint are preserved at their actual Git capture; their original logical epochs, results and input hashes remain unchanged. The complete native/OS input-custody leg is separately owned and is not supplied by source or channel retention. The new declaration is authored directly, with its script-composition templates explicit. The November7 review retains its original draft and qualified prior-template disclosure. The earlier November4 review preserves its original publication messages; the separate `docs/checkpoints/publication-custody-2026-11-04/` record retains the original planner, actual ref-update logs and complete logical Git-object identities. Its readonly review distinguishes raw object bytes from packed estimates, original grouping fields from runtime counts, and repeated batch inputs from required-object coverage. Exact wire size and transitive toolchain closure remain unassessed. A rejected new task narrative can be shortened while retaining its full prior wording and unchanged acceptance fields; this preserves the fixed collection cap while its scheduled headroom task renews capacity. The accepted large-file warning has a dated assessment under `docs/checkpoints/artifact-growth-2026-11-05/`; prospective input reuse remains scheduled after feature coverage. Historical evidence stays retained.

Continuity docs answer different questions:

- What changed in this slice?
- Why was the implementation shaped this way?
- What should a future session remember after interruption?
- What validation was run before the commit?
- What workflow rules should be followed when committing?

They are optimized for execution continuity, not public onboarding.

## History rollover and byte reconstruction

Rollover removes terminal LF separators from the mutable hot root, leaving one
final LF. Immutable archive bytes remain exact clean-source slices. The manifest's
source commit and blob preserve the original prefix, including its separator;
use those identities when reconstructing historical bytes rather than assuming
that the current hot root concatenated with its archive equals an older source.
`--all` returns archive bytes only, without the current hot root.

Both history formats exercise actual rollover, ordinary Git whitespace checks,
exact source reconstruction, orphan and pending recovery, and rejection before
publication. A pending segment ID remains a four-character JSON string after its
numeric eligibility check. Otherwise its comparison with the published row would
fail and a rerun could archive the same suffix twice. Contradictory same-HEAD
pending metadata is rejected before any new publication.

Check both current author surfaces before committing:

```sh
perl tools/roll_document_history.pl --surface change_history --check
perl tools/roll_document_history.pl --surface engineering_notes --check
```

For exact historical reconstruction, verify the newest archive against its bound
Git source. This example includes the original separator without changing any
archive or normalizing historical bytes:

```sh
bash tools/project_data_run.sh python3 - <<'HISTORY_SOURCE'
from pathlib import Path
import json, subprocess
rows = json.loads(subprocess.check_output([
    'perl', 'tools/read_document_history.pl', '--surface', 'change_history', '--catalog-json'
]))
row = rows[1]
source = subprocess.check_output(['git', 'show', row['source_commit'] + ':' + row['source_path']])
archive = Path(row['target_path']).read_bytes()
assert source.endswith(archive)
original_prefix = source[:-len(archive)]
assert original_prefix + archive == source
print(row['source_commit'])
HISTORY_SOURCE
```

### Replaying historical evidence after a repair

Historical recovery keeps the original hashes. A later accepted repair can evolve
an executable input only through an explicit source-bound compatibility check.
The quoted-boundary decoder import and loop replacement recover the original
`Contracts.pm` bytes when reversed. Removing the exact committed nested-boundary
subtest recovers the earlier Phase0 source before its existing compatibility checks.
Missing, duplicated or changed additions and unrelated edits fail the audit.

Current source-image admission is separate from historical execution. The closed table at
`tests/language-readiness/current-source-images.json.gz` binds 18 exact committed images at `0db5e9e87` to
owner `TYPE-REFERENCE-BOOK.1.2.20.1.11`. Each entry preserves the historical boundary and last admitted predecessor. Git path, regular-file
mode, commit and bytes are checked; any later byte change rejects until a new reviewed owner admits it.
The report's `source_image_evolutions` names actual current images. Older inverse/falsifier rows explicitly
name their preserved predecessor `source_stage`; those original controls and all original results remain.

For example, the historical ZIP can still recover every selected input while a later Compiler edit causes
`unreviewed current source image: perl/LinkedSpec/Compiler.pm`. Restoring the admitted current image passes;
refreshing an old historical hash is never the repair. The new path-wise current-image mutations exercise that
rejection, while original-log reads and tracked writes remain denied. Source identity admission does not
re-execute old runtime producers or promote feature/objective compatibility; that verification remains deferred
under its existing owners.


Run the isolated recovery proof to check the archived inputs and current audit:

```sh
bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py
```

It does not re-execute historical runtime producers. Their runtime results remain
bound to the original checkpoints; fresh behavior checks belong to each repair.

## Commit identity and the resume pointer

A tracked file cannot contain the literal hash of the Git commit that contains it: changing that literal changes
the tree and therefore changes the content-addressed commit identity. Current commit identity belongs to Git and
is obtained with `git rev-parse HEAD` or `git log`, never copied back into the same commit.

ADR `0065` adopts a satisfiable boundary for `MEMORY.md`. The bounded pointer names the clean
`activation_commit` from which a leaf started. That value equals `HEAD` while the leaf is being prepared and
equals `HEAD^1` after its normal commit lands. The leaf ID in the commit subject is the durable join key from the
activation boundary to the landing commit. Before committing, the rest of `MEMORY.md` is written as the intended
clean post-landing handoff: the latest leaf has completed task-tree status; an idle pointer has no uncommitted work;
and a completed active leaf is not still described as staged/uncommitted or scheduled for another commit/push.

`MEMORY-COMMIT-POINTER-ENFORCEMENT.0` ratifies this contract, and `.1` implements it through one
read-only phase-aware checker. The pre-commit hook is a hard gate over staged `MEMORY.md` and current
`HEAD`. The post-commit hook is a non-mutating verification signal over committed `HEAD:MEMORY.md`
and `HEAD^1`. The canonical local gate uses an automatic mode that selects a worktree, staged, or clean
committed view and rejects ambiguous staged-plus-unstaged pointer edits. Hermetic tests cover the initial
`root` sentinel, ordinary success, malformed/duplicate fields, genuine drift, and phase ambiguity.
The composed memory doctrine also runs `tools/check_memory_handoff_state.py`: three active/clean/idle twins pass,
while six mutations reject task-status and post-landing contradictions that commit ancestry alone cannot detect.
Closeout `.2` independently recomposed the committed checker, both hook views, all eleven cases, and the current
and historical documentation owners without implementation change; it found no current contradiction and made
the only two unqualified historical task statements point explicitly to ADR `0065`.

## Outgoing publication byte budget

The director’s 1,500,000,000-byte early push trigger takes precedence over the batch
or PNT cadence. Measure after each committed leaf and before large growth:

```sh
bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/publication-size-monitor-2026-11-12/measure.py
```

The command prints the actual committed HEAD/cached origin refs, non-thin pack
estimate, byte margin and preparation state. It keeps raw diagnostics on the
repository volume outside Git, with one pack worker and a `64m` window-memory limit. All
uncommitted changes are excluded. Start canonical discovery/publication preparation
around 1,400,000,000 bytes or earlier if the next slice or CI receipts need more
margin; this 100 MB reserve is advisory. Publish around 1.5 GB even before the batch
ends. GitHub's [single-push limit](https://docs.github.com/en/get-started/using-git/troubleshooting-the-2-gb-push-limit)
is 2 GiB. Every push still requires current canonical test discovery, full CI and a
clean exact HEAD through normal hooks. Check fresh remote identity before transfer.

The estimate concerns a local serialized artifact; remote negotiation and wire
bytes can differ. Source/config/ref/object metadata and independent validation are
retained, while full native/physical/cache/toolchain custody remains separately
owned. The canonical record at `docs/knowledge/github-size-safe-publication.md`
links the scoped proof and preserved index-stem failure. The historical one-off
backlog publisher remains retired. The publication task owns the required checks and transfer.

## Publishing a measured result

A published measurement carries three different checks: re-derive it from the actual
source at the claim's granularity, falsify a competing hypothesis with a distinguishing
oracle and a control observed failing, then retain the producer and gate all artifact
inputs. A count of search hits is a population to classify; it is not automatically a
count of defects. Aggregate conservation cannot establish correct per-item assignment.

The local contract is `DOCTRINE_ENFORCEMENT.md` section 12, adopted under ADR0126.
`COMMIT.md` contains the review template. New task leaves declare a bounded record in
`docs/claims/`, or explain why no measured claim is published. Checked records name the
command/result, hypothesis/oracle/RED and tracked producer/input hashes. Missing legs
name a reason and an open repair task. The adoption record is a complete schema example.

For instance, an output-count assertion should identify the exact source population and
command, a deliberate dropped/wrong-row control, and the tracked observer that wrote the
result. If the observer exists only in ignored scratch, publish **durability gap** and its
repair owner until its source is retained. Repeating that observer does not cure the gap.
For stochastic performance use intervals and method; named cases and contract counts
require exact agreement. Explain differences from earlier adjudicated sibling cases.

```bash
bash scripts/check_claim_verification.sh
```

A claim’s repair task uses status `pending`, `active`, or `blocked`. Use `active`
while that repair work is in progress.

The registered checker validates disclosure and declared regular tracked byte identities;
it never executes commands from a record. `live` hashes watch index inputs; `historical`
hashes preserve an explicit existing Git capture rather than today's counter. Re-measure
or explicitly preserve/supersede a stale record; changing its hash alone is not verification.
The selected tests and canonical gate still establish actual behavior. The checker cannot
establish that a source list is complete, a RED happened, or an oracle is independent.

A test can read more than its own source file. Phase 0 discovers shipped specs,
corpora and book Markdown, reads JSON contracts and runs nested consumers. A
file hash for the named suite therefore does not identify every input. Retain
both the contents and directory membership of its input trees. A fixed input
capsule also lets continuity documents change after a run without changing the
bytes that the run actually examined. Gate the capsule against its declared Git
boundary and any explicit candidate overlays before and after execution; retain
complete output channels and reject missing inputs or incomplete TAP plans.
Passing older transcripts retain their original boundary until remeasurement
supersedes them. Preparation alone is not consumer acceptance.

Checkpoint JSON belongs to the measured input tree. A guard over Perl, specs and
tests can omit a case file opened under a checkpoint directory. Retain every
actual reader edge and exercise the selected tests in a supplied tree containing
those artifacts; removing a required case file must fail its unchanged reader.
Inspect earlier manifests individually: a wider producer may already include the
same artifact. Preserve an incomplete historical transcript as an observation,
qualify its missing evidence, and use a complete new recurrence for acceptance.
Current hashes cannot identify an earlier unrecorded read. Book rendering likewise
needs its complete configuration and source tree, including every chapter.

The selected thirteen-suite remeasurement preserves two actual input boundaries.
Twelve suites complete 1,298 groups using the original fixed capsule. The last
suite initially fails before its first assertion because its checkpoint case
file is absent. Its probe, fresh-process program and shared observer are also
required inputs. Adding those four exact files from the same Git revision lets
that suite complete its 39 groups. Every shared input byte and mode stays the
same; the earlier passing runs retain their original capsule identity. Independent
review checks complete plans, ordered results, exits, producer identities and
input membership, and rejects missing inputs and altered or incomplete evidence.
The combined result is 1,337 groups across thirteen unchanged suites. The failed
run remains available; the new result supersedes the older broader observation
without inventing its unretained document reads. The final public book has its
own complete input capsule and render, separate from historical test inputs.

This bounded working-rule/checker adoption does not finish the broader published-constant,
ignored-producer, control and alignment audit owned by startup task .5. Diagnostic path
repair .29 remains required before that audit closeout. Older checkpoints and their
historical results retain their original scope and bytes.


### Replayed diagnostic source

A logical compile filename supplies coordinates; it does not bind the source text
that Python displays in a traceback. If retained bytes contain
`raise RuntimeError("original")` but a newer file at that filename contains
`raise RuntimeError("newer")`, a replay can raise the original exception while
printing the newer line. That displayed line is another artifact input.

The retained reviewer replay supplies the exact original text to the traceback
formatter before execution and independently compares every displayed logical frame
with the executed source at its reported line number. Its source hashes, commands,
input guards, exit codes and both channels are retained. Two original diagnostics
with mismatched context remain explicitly limited historical evidence; fresh bound
replays reproduce their same failures with the correct original lines. Distinguishing
controls reject the old context, incomplete runs, changed producers, erased failures
and forged channels. A filename alone is never evidence of diagnostic source identity.

### Reference identity in provenance probes

An origin must reference the actual event returned by the scanner. Comparing
`origin.event` with a local variable assigned from that same field checks the object
against itself; it cannot establish the returned-event relationship. Compare against
`result.events[index]` instead. Equal JSON values do not establish reference identity.

The retained original pipeline diagnosis contains that limited self-comparison marker.
Its original bytes and adjudication remain available. A corrected probe compares the
actual returned array, and a distinguishing control copies that array while preserving
the origins: values remain equal, the old marker still passes, and the required reference
relationship fails. Dedicated constructor/argument identity tests retain their own scope.

## Definition of done

If a slice changes what the outside world needs to understand about LinkedSpec, the book should move too.

If a slice changes implementation continuity, rationale, or crash-recovery knowledge, the continuity docs should move too.

Those two obligations overlap sometimes, but they are not the same obligation.

Examples:

- Adding or renaming a public DSL helper should update the relevant public helper docs and continuity docs.
- Refactoring an internal owner boundary should update the architecture section if the public mental model changes, plus continuity docs.
- Tightening a diagnostics payload should update compiler/runtime docs if users can observe it, plus continuity docs.
- A purely internal cleanup with no public story may only need continuity docs and validation notes.
- A book-only documentation slice still needs continuity docs so future sessions know what public area was expanded.

## mdBook workflow

Build the book with:

```bash
bash tools/run_mdbook_local.sh
```

The wrapper derives the checkout at runtime, keeps default/generated output on the repository filesystem, and
rejects an external `MDBOOK_BUILD__BUILD_DIR` or `-d`/`--dest-dir` before mdBook starts.

The source files live under:

```text
docs/linkedspec-book/src/
```

The generated HTML output goes under:

```text
docs/linkedspec-book/book/
```

When adding a new chapter, update:

```text
docs/linkedspec-book/src/SUMMARY.md
```

When editing existing chapters, keep the chapter in the section where a reader would naturally look first. If a subject crosses boundaries, prefer a short cross-reference over duplicating a long explanation in several places.

## Documentation style

The public book should be:

- explicit about current behavior,
- transparent about historical or legacy surfaces,
- example-heavy for user-facing APIs and DSL methods,
- clear about maturity and caveats,
- honest about current backend limits such as generated Perl handlers,
- organized by reader need rather than implementation accident.

Avoid hiding transitional areas. If a surface is legacy, say so. If a spec is a placeholder, say so. If a chapter is only a map and deeper walkthroughs still need to be written, say so.

## DSL documentation bar

DSL methods need especially strong documentation.

For each public DSL method or method family, the public docs should eventually explain:

- rationale,
- semantics,
- when to use it,
- when not to use it,
- expected input/output shape,
- how it lowers conceptually,
- several worked `.spec` examples,
- interaction with related methods.

New methods are not fully landed until users can understand and adopt them from the docs. Older methods are held to the same bar as they are revisited.

## Continuity update pattern

For each committed slice, continuity docs usually need:

- a `CHANGES.md` entry with concrete changes and validation commands,
- a `DEVELOPMENT_NOTES.md` entry with rationale and future guidance,
- a `MEMORY.md` entry with interruption-safe resume context.

Keep these entries concise but specific. They should tell the next session what happened and what should be done next.

## Validation pattern

For documentation-only book work, run:

```bash
git diff --check
bash tools/run_mdbook_local.sh
```

For implementation work, run the relevant code/spec tests. The full shared gate is:

```bash
bash tools/run_ci_local.sh
```

If validation could not be run, say so in the final answer and record the limitation when appropriate.

The current main-method kind proof preserves the complete earlier `.3.2.1.9`
publication, all490 bindings and its actual readonly baseline before changing
bound inputs. Rechecking that historical publication requires its accepted
`61a73324` logical inputs. Its original producers and observations remain exact;
the current proof uses a separate corrected parent-packet oracle and reviewer.

The local CI runner selects the Knowledge header fixture and verifies that its source is tracked. Historical artifact audits admit that exact insertion by reversing it and comparing the complete original runner bytes. The managed-storage inventory also includes the fixture: its temporary files must use repository-derived scratch. Missing or duplicated registrations, changed commands, wrong allocator names and unrelated source edits fail the compatibility checks. The current review retains the first candidate and its observations, then checks the final source and documentation separately.

The ControlFlow foundation proof preserves the complete accepted FlowExpr default publication at `aa88233432976a019b41d05578f8e6a5f6e3c082`. Its first native instrument and ordinary observations precede behavioral assertions and production edits; the native switch tag list context is retained alongside the scalar callback controls. Later ControlFlow children and independent admissions remain separately owned.

### Type inventory and execution evidence

A shared call-name registry checks vocabulary presence in source, fixtures and prose.
It does not count all language operations, certify per-type documentation depth, or
execute every operation. Keep literals, operators, constructors, free helpers,
receiver methods and callable invocation distinct. Resolve surprising results with
public descriptor/emitted-source tools and distinguishing controls; give confirmed
defects repair owners before publishing a healthy taxonomy. Preserve complete prior
live claims before updating any of their bound documentation inputs.


### Test inputs and rejected oracles

An explicit suffix selection can be useful source custody while omitting `.t`
scripts or fixture data in another tree. Before running a supplied test context,
retain the actual selected scripts, their data dependencies and modes. A failed
file lookup is not a behavioral RED. Keep that incomplete reconstruction and use
a separate complete-input epoch.

Likewise, a baseline observation is not automatically the intended behavior.
Distinguish a late variable read from container mutation with a saved-binding
control and the existing mutation contract before choosing the expected value.
Retain rejected expectations and actual failures. When internal emitted text
changes, execute the relevant AST-derived values while preserving poisoned-source
denials and trace checks.
For a rule aggregate copy, compare snapshot values, distinct outer storage,
shared nested containers and the original array-read trace. These checks preserve
the contract when emitted temporaries change.

Historical audits keep the original executable source hashes when test
representations evolve. Give each reviewed delta an owning task and an exact
inverse that recovers the complete original file. Keep the existing denial
controls and add missing, duplicated, altered and unrelated-edit controls.
Retain the inverse table as an explicit input to the recurring proof, then
run that proof before retrying canonical CI. Preserve rejected instruments
and their channels separately from behavioral RED evidence.
For count/first, a separate table reverses ten generated guard expectations before
the older inverses run. Earlier falsifiers keep their original source stages;
the ten new hunks add omission, duplication and corruption controls. Table bytes
are explicit audit inputs, with actual inverse and hash-check faults retained.
Publish loader paths relative to the repository root. Preserve exact raw loader
observations separately before normalization, and run the production portability
check on the resulting summaries before canonical CI.

Private diagnostic tests retain their original native captures when unrelated
source insertions move a diagnostic. Translate only fresh error coordinates
through byte-identical statements in the same named routine at an explicit
Git anchor; preserve callback names, paths and all other row fields. Reject
unmatched statements. For source formatting changes, execute the expression
against an independent value expectation. A test invocation observer covers
its declared argument and binding ABI; it does not establish runtime dispatch.
For generated count guards, select only reviewed rows and execute both array
and nonarray operands; retain the original capture and every other row field.
Prove wrong callbacks, files and lines still differ, then bypass the actual
mapper and observe failing assertions before restoring it.

When maintained diagnostic tests change, retain their historical scanner registrations.
An exact reviewed admission must identify its owner, original digest and current digest.
Compare the old and new selector occurrences, then reject edited files, copies, extra
selectors and wrong or missing registrations. Removing each admission check must expose
false acceptances to the control probe.

Large immutable checkpoints can retain their exact bytes as bounded payload chunks.
Gate physical chunk hashes, decoded payload hashes, order, offsets, whole-stream hash,
byte count and original mode. Copy and verify first, use the retained reader in its
explicit original source context, then remove only the verified duplicate originals.
Keep rejected attempts distinct. Record the physical input migration while preserving
every original logical identity; an uncommitted draft has no historical Git revision.

An exact emitted-source snapshot can lag an accepted lowering implementation.
Before calibrating it, compare the exact committed activation module with the
candidate through the same public AST/lowering probes. Verify the module actually
loaded: facade initialization can prepend its own SDK root ahead of a private
overlay. A rejected image-identity check earns no baseline credit. Retain every
original fixture byte, change only the demonstrated stale source field, and keep
AST/errors/warnings, unresolved-helper ownership and non-ready metadata unchanged.
Equal legacy runtime values do not admit an unsupported expression. A diagnostic
collector must also preserve Trace prefixes separately from its complete JSON
frame; a framing failure is not a behavioral RED.

### Canonical execution prerequisites on macOS

Run canonical CI in approved host execution so its process-locality oracle can install its own kernel sandbox.
The read-only initialization control is:

```sh
/usr/bin/sandbox-exec -p '(version 1) (allow default)' /usr/bin/true
```

CI runs this control before doctrines. If initialization is denied, rerun the complete staged candidate
in approved host execution with `bash tools/run_ci_local.sh`. Preserve the oracle's containment profile and
negative checks. An early failure supplies no canonical receipt; a focused host pass does not replace the
complete run. The execution requirement is canonical in `docs/knowledge/project-data-process-locality-proof.md`.


### Host RAM admission and trend monitoring

RAM guard and canonical CI share tools/host_ram_usage.sh. On macOS, a denied or
invalid sysctl query falls back to actual capacity from memory_pressure -Q.
Page size and available free/inactive/speculative pages come from one vm_stat
response. Linux uses one /proc/meminfo response. Missing or invalid data refuses
admission rather than substituting an invented host size.

```sh
bash tools/host_ram_usage.sh
bash tools/ram_guard.sh --ceiling-mb 4096 --danger-pct 88 -- bash tools/run_python_project_data.sh tools/test_ram_guard.py
```

The first command prints the upward-rounded availability-based used percentage.
The wrapper's configured threshold defaults to88%; it exits77 without starting
the child when usage is unknown or reaches that threshold, otherwise preserves
the child's exit code. Its attempted virtual-memory ceiling is not an RSS bound.
Canonical CI runs the capacity/arithmetic/admission controls before its heavy
suite and uses the same producer with LINKEDSPEC_TEST_DANGER_PCT.

These are snapshot admission checks. Check headroom for the expected peak, use
conservative concurrency and run at most one intensive job of our own. Observe
host-wide trends while it runs. If usage exceeds90% and keeps increasing, tell
the director and reduce or stop our driving jobs; stable high80s alone do not
require intervention. After a pressure stop, aim for stable80% or less before
resuming with lower concurrency or smaller batches. Never stop another project's
jobs. If other projects keep usage above90%, defer our intensive work.

Request a confirmed quiet window only when required headroom is unavailable or
background activity could skew a measurement. State purpose, proposed start and
duration, and required free memory/background limit; verify readiness and announce
when the window ends. Keep all monitoring data in managed repository storage.
The current operating authority is docs/knowledge/shared-host-ram-budget.md.


### Later source images and exact CI inverses

Historical objective recovery checks source identities separately from fresh
runtime results. A later accepted runtime image needs a closed successor entry:
retain the original image and intermediate committed predecessor, then bind the
latest path, commit, regular mode and full digest. Keep the original Phase0
activation and calibration. Nested reports must identify the effective latest
image while exposing the intermediate lineage.

An owned CI change can instead have an exact source inverse. The RAM preflight
stage restores its two reviewed hunks to committed b370 bytes before exercising
every older CI falsifier. Current candidate bytes are distinct from a committed
historical image. Missing registration, unrelated edits and changed support
inputs reject; old tables, recovered logs and runtime observations stay intact.

```sh
bash tools/run_python_project_data.sh tools/test_historical_objective_images.py
bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py
```

The first command checks source-admission/inverse mechanics. The second performs
actual isolated historical recovery under original-log/tracked-write denial.
Neither reruns the historical runtime objectives or promotes feature coverage.
Source/data integrity, current runtime proof and the exact canonical receipt
remain separate. New CI stages must preserve the earlier inverses and controls.
