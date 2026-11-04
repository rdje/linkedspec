# Backlog publication custody

Owner: `TYPE-REFERENCE-BOOK.1.2.23.4.7`. The accepted publication root is
`d3a26a94f5c2efba736806ac13911155e3739995`; the initial measurement root is
`cd3b6adc3e58fb64283ae4ae4a5a37823eabd891`, against remote base
`2ac834913d85c32f532be9b0aab63644838a577a`.

```bash
bash tools/run_python_project_data.sh docs/checkpoints/publication-custody-2026-11-04/source_capture.py
bash tools/run_python_project_data.sh docs/checkpoints/publication-custody-2026-11-04/review.py
```

These commands review retained dated observations and current Git identities.
`review.py --verify-objects` additionally retrieves and hashes every retained
logical object body again. Neither review runs any recorded push or planner.
`source_capture.py --acquire`, `capture_runtime.py`, `preserve_failure.py` and
`diagnose_overlap.py` are completed one-shot acquisition instruments. Do not
repeat the archived original planner or the historical `publish.py` operator.

`original-source-records.json.gz` contains only selected actual application
call/output records, byte offsets and selection/readback evidence. It retains
the original raw counters, flat/thin measurement calls and inline planner.
The two `original-planner.*.txt` files are byte-exact extracted source, not a
reconstruction. Acquisition used one necessary, explicitly owned read-only
external application source; ordinary review depends only on repository data.
No application data was written or deleted.

`publication.json.gz` retains both raw plans, actual per-command events and full
logs, session and canonical receipt, historical direct producer/input bodies,
the fresh main/temporary-ref observation and the new acquisition/review source
bodies. Each object stream is retained exactly with its command and SHA-256.
The manifest identifies every object reachable from the published root,
including common remote objects and possible thin bases, by Git SHA-1, kind,
byte length and independently recomputed body SHA-256. Capture retrieved every
opaque body and recomputed its Git content address. The retained Git root is
the lossless body store; this capsule does not duplicate gigabytes of payload.

A full Git clone containing the published root supplies these objects through
the public Git interface. For an individual manifest row, `git cat-file -t OID`,
`git cat-file -s OID` and `git cat-file TYPE OID` retrieve its kind, length and
opaque body. Shallow or filtered clones need the complete published history
before full-body review. No submodule implementation is part of this object
walk: Git links are identities, and no recursion is performed.

Three observed boundary corrections remain explicit:

- The original planner accepts equality at its budget. The actual operator and
  current validator require strictly smaller estimates. The isolated original
  split function accepts a controlled equal-budget value; the current predicate
  rejects it. All actual retained batches were strictly below budget.
- The historical final-plan writer changed the last target and byte estimate
  while retaining the initial head anchor and original group count. Raw fields
  remain untouched. The normalized report derives the runtime head and counts
  from the actual session and immutable Git first-parent sequence; an independent
  Git count rejects treating original grouping metadata as runtime metadata.
- The first review incorrectly required disjoint batch object lists. Its exact
  source and actual traceback survive in `capture-failure-01.json.gz`.
  `object-overlap-diagnosis.json.gz` independently retains the actual range lists
  and metadata: one historical blob appears twice, is reachable through the
  later negative base history and is absent from that base's tip tree. The
  corrected reviewer checks required new-object coverage within the full target
  closure and allows repeated/common inputs. A disjoint-list model is an
  observed RED, not a property assumed of Git.

Pack byte observations remain dated to their original encoding epoch. Physical
pack layout, Git/SSH/CI/OS/toolchain implementation closure, exact wire bytes,
server disk usage and future or concurrent remote state are unassessed. No
oversized upload was attempted. This evidence does not imply full language
feature or portable backend admission.

The first normal commit attempt recorded a task-collection cap rejection and
was stopped after that rejection; its remaining checks earn no passing credit.
`narrative-before.json.gz` preserves the complete rejected collection, registry,
producer and actual log. Only this new leaf's narrative is shortened; its full
earlier wording remains recoverable. `narrative-after.json.gz` retains the
repaired collection. `narrative_boundary.py` replays both dated populations and
checks unchanged authority and per-file node Status/Goal/Acceptance/Dependencies
fields, with missing-input and lost-acceptance denials. Its node projection
includes historical members in the counted collection; it is not the unique
current-ID census. A helper allowlist setup failure preceded acquisition; its
source and limited diagnostic metadata remain separate from completed captures.
Existing task-budget20.2 activates next under its already declared cap trigger,
before Rust Count work; no ceiling or immutable archive is changed here.

```bash
bash tools/run_python_project_data.sh docs/checkpoints/publication-custody-2026-11-04/narrative_boundary.py
```

Primary contracts:
[GitHub smaller pushes](https://docs.github.com/en/get-started/using-git/troubleshooting-the-2-gb-push-limit),
[Git pack objects](https://git-scm.com/docs/git-pack-objects),
[Git object walks](https://git-scm.com/docs/git-rev-list), and
[Git push](https://git-scm.com/docs/git-push).
