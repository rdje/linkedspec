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
adds `doctrine/readme_stability/routes.jsonl` and an unconditional core-Perl resulting-tree check. It classifies
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
the four current routes unchanged. That documentation-sustainability program is composition-closed.

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

The latest artifact-maintenance date and disposition live in `docs/ARTIFACT_CLEANUP.md`.
An owned census may retain every artifact: reusable caches, dependency data and
verification evidence are preserved unless an exact deletion is proved safe.
The task tree records the census scope and exclusions; the date record is overwritten
after each cleanup rather than accumulating another history log.
A dated census records file metadata at that moment; it does not prove content ownership
or authorize deletion. Keep the retained snapshot immutable. A later live census is a new
observation, while a read-only reviewer can still check the old recorded totals and inputs.
For a retained daily snapshot, the review order is census completion, fresh scoped comparison,
and independent per-file metadata checks. Save the actual producers, exit statuses and both
output channels before advancing the latest date. A successful review may remove zero files.
For example, the retained daily snapshot can be checked without recapturing changing state:

```bash
bash tools/run_python_project_data.sh docs/checkpoints/REPO-HYGIENE.11-review.py
```

All other Git repositories and submodules are excluded before traversal. A project task or
notification does not authorize modifying them; their owners apply any upstream repair.
Retained verification logs and canonical receipts are evidence, so their size or age
alone does not authorize deletion. A handoff finishes the current slice, clears
`git_message_brief.txt`, and verifies clean Git state and no required background job
before leaving the next task in `MEMORY.md`.

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
rows = Path('docs/history/changes/manifest.jsonl').read_text().splitlines()
row = json.loads(rows[1])
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
