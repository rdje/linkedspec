# Retained-artifact growth assessment

Owner: `TYPE-REFERENCE-BOOK.1.2.23.4.8`; activation: `eda3c81fe6ca9264f0ba96f3f90525d96d79626c`.

At this fixed activation, `origin/main` is locally recorded at `4683555e` and
HEAD is15 commits ahead. The director reports an outgoing pack of about11.5MB;
this correction does not independently regenerate or measure that pack.
`review_outgoing.py` independently checks the range count and confirms that the
historically warned blob is already present at the base with the same object ID.
The whole local pack store below includes published history. It must not be
presented as the outgoing delta or evidence of a current oversized push.

The recommended next step is prospective reuse of exact Git-backed inputs and the
already admitted bounded archive profile. Keep all historical objects and accepted
claims. Treat repository growth separately from daily disposable-artifact cleanup.

## Evidence and limits

`review.py --capture` is a completed one-shot observation. Default replay streams
one opaque Git blob, compares its size metadata with the complete body count and
content address, checks the retained accepted-warning packet, and rejects five
altered records. It never executes a historical publisher or recurses into a
submodule. Retained observation and public-contract excerpts are adjacent.

- The named blob is `f2b0327502052d10766db016ea3425fbc80612de`, containing
  53,325,495 bytes. The actual batch10 warning labels it `50.86 MB`; historical
  acceptance remains established by the published4.7 custody claim.
- Local Git reported `size-pack: 10630033` KiB, or 10,885,153,792 bytes. This is a
  dated local pack field, about10.14GiB. It is neither the entire `.git` directory
  nor the pending outgoing pack nor GitHub server storage. A future repack may change it. Replay validates the
  retained packet and unit conversion; it does not reconstruct old physical packs.
- The earlier9.30GB thin-pack estimate, logical object totals, local packs,
  individual blob size and actual wire bytes answer different questions.
  Server disk usage and future host supportability remain unknown.

The chapter edit intersects one restoration claim in4.3, whose record is itself
an input of the dated publication claim in4.7. Both selected records are preserved
at clean `eda3c81` with only durability mode/revision changes; their original
40/20 per-claim input rows and all original fields remain exact. The two
`preserve_*claim.py` readers verify these transitions and reject altered original
statements, hashes, revisions, input populations and unselected claims. Current
bounded restoration/publication readers also pass. Historical `close_claim.py`
requires its accepted input state; it must not reinterpret a later preservation
as a change to the original closeout. No old measurement is refreshed here.

GitHub's [repository limits](https://docs.github.com/en/repositories/creating-and-managing-repositories/repository-limits)
describe10GB compressed repository storage as guidance, with distinct enforced
push/object restrictions. Its [large-file guide](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github)
warns above50MiB and blocks above100MiB; the named blob lies between those values.
The [push workaround](https://docs.github.com/en/get-started/using-git/troubleshooting-the-2-gb-push-limit)
uses smaller successive pushes below2GiB. Preserve each document's unit spelling;
the retained warning itself saysMB. No refusal or server-size measurement follows
from these observations. Source excerpts are dated November5,2026.

## Prevention choices

| Choice | Producer and reader implications | Claim and retention implications | Decision |
| --- | --- | --- | --- |
| Exact input manifest referencing retained Git objects | Before execution, compare each proposed reference with the actual consumed file bytes; use a retained ancestor only for an exact match. Reader resolves the commit/path/object and verifies type, size and digest. New dirty/generated/untracked bytes still need an actual retained payload. | Full history remains required. Bind the manifest, actual producer, opaque input bytes and reader; distinguish source capture from later regeneration. Fail on missing objects or changed bytes. | Preferred for already retained inputs; first adoption needs a bounded owned producer/reader proof. No current measurement claims a saving. |
| Existing content-addressed payload/archive chunks | Reuse the admitted REPO-HYGIENE.23 per-file digest manifest, hashed payload parts, modes and complete-stream identity when a new payload would be too large. Verify actual consumer recovery before changing physical bindings. | Complete bytes stay in tracked files on this volume. Chunking limits individual blobs; lifetime bytes can keep growing. Existing claims and originals remain untouched. | Preferred fallback for genuinely new captured bytes. No aggregate size-reduction claim. |
| LFS, release assets or external object storage | Requires a new fetch/authentication/offline-failure path and an explicitly approved retention owner. Current full-Git readers would need coordinated adoption. | Moves payload authority outside plain Git; requires a reviewed exception to current locality/durability contracts. Existing history would still remain large. | Outside this assessment's implementation authority; not selected. |

Deleting current files cannot remove their historical blobs. Rewriting accepted
history, replacing old blob identities, deleting proof/caches, moving data off
volume and writing another repository are excluded by the director's existing
instructions. No such change is needed for this bounded assessment.

## Owned follow-through

`TYPE-REFERENCE-BOOK.1.2.23.4.12` owns the first prospective input-reference
producer/reader admission, scheduled after current feature coverage and before
the next new large-payload publication. It must retain a real first-execution
capture, prove complete recovery, and reject a wrong revision, wrong body,
missing payload and changed byte. Reuse current archive semantics; any new
mechanical storage contract requires its own canonical boundary.

Until that admission, each selected feature leaf remains responsible for the
actual size of its new proof files and uses existing bounded chunks when needed.
The normal final publication check must inspect new outgoing blobs; transport
batching alone cannot solve a too-large individual object. Parent review4.8 can
close without claiming the future producer repair, full custody4.2, registration,
general isolation, declared-host admission or server-size knowledge.

```bash
bash tools/run_python_project_data.sh docs/checkpoints/artifact-growth-2026-11-05/review.py
bash tools/run_python_project_data.sh docs/checkpoints/artifact-growth-2026-11-05/review_outgoing.py
```
