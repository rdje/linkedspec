# Historical objective audit artifact recovery

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2`. Census/plan `.4.2.0`
precedes archive/restoration `.4.2.1`; bridge reconciliation waits for recovery.

## Measured input boundary

The read-only census reconstructs the original nesting/context/lossless milestone
populations (48/39/47 entries) and compares their union with the committed `.4.1`
audit's exact path/hash map. All 134 regular, repository-volume inputs match their
old hashes and total 84,613,241 bytes. Independent zlib level9 compression totals
3,394,928 bytes with zlib1.2.12. This measures a format budget; it is not an archive.

The selected 24 checkpoints total 214,367 bytes. Neither their complete bytes nor
their decoded UTF-8 strings/joined string arrays match any complete input-log
identity. No `.gz`, `.zip`, `.zst`, `.tar`, `.xz` or `.bz2` tracked member exists in
the selected `docs/checkpoints`, `docs/history` and `tests/language-readiness`
surfaces. Other encodings, surfaces and possible archival sources are unassessed.
This bounded result does not classify all historical proof as unrecoverable.

Actual-byte corruption, removed population membership, changed identity and three
outside-path controls reject through the same validators used for healthy input.
The producer and exact capture are retained under `docs/checkpoints` with the
`.4.2.0` prefix. Its original claim disclosed an open byte-recovery `.4.2.1` leg, now
explicitly superseded by isolated archive recovery without refreshing this census. The earlier normalization claim is frozen at its actual `0f15e194f` capture;
none of its hashes, observations or dated results is refreshed by this census.

```sh
bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0-census.py
```

## Implemented recovery

`.4.2.1` owns these implemented paths:

- `tests/language-readiness/artifacts/objective-audit-inputs.zip`: one deterministic
  ZIP_DEFLATED archive, sorted ordinal member names, fixed metadata; log content
  remains opaque and byte-exact. Budget: 4MiB archive, 96MiB expanded population.
- `tests/language-readiness/artifacts/objective-audit-inputs.json`: versioned closed
  manifest binding archive SHA256/size, 134 relative old paths, member names,
  original hashes and exact uncompressed sizes to the independent census.
- `tests/language-readiness/recover_objective_audit_inputs.py`: bounded archive
  validator and explicit safe restore; validation alone writes no files. An
  explicit restore destination is newly created beneath repository-derived
  `.linkedspec-data/scratch`, on the same volume. Reject an existing destination,
  traversal, noncanonical paths, symlink ancestors, extra/duplicate/missing ZIP
  members, unsupported compression, size/hash drift and incomplete streams.
- `.4.2.1` capture/archive producer and recovery controls under `docs/checkpoints`:
  reproducible capture from the closed population, isolated restoration and
  independent exact-byte comparison; controls use actual altered archives,
  missing inputs and hostile destinations. Original artifacts are retained.
- A source-bound read-only audit replay instrument under `docs/checkpoints`:
  invoke `verify_objectives.py`'s actual `audit_evidence` and falsifiers with the
  injected reader mapping only declared log paths to restored files. Guard reads
  of original local logs and tracked writes. No historical snapshot writer runs.
- `tools/run_ci_local.sh` and the narrowly owned evolution/falsifiers in
  `tests/language-readiness/verify_objectives.py`: require both archive inputs and
  run recovery/audit proof once; reconstruct every prior historical CI byte.

Use ZIP metadata only as checked data; never call unrestricted archive extraction.
Derive output paths from the independently verified closed manifest. Observed
absolute paths inside log contents are opaque observations, never filesystem
locations. Validate the complete archive before writing. Restore with exclusive
file creation and verify every restored size/hash; there is no original-log
fallback. Preserve old milestone checkpoints, source identities and raw files.

## Signoff boundary

Compare manifest membership against the three milestones and `.4.2.0` capture,
not merely against archive metadata. Deny reads of the original inputs while the
complete historical integrity audit and distinguishing falsifiers run on restored
bytes. Confirm that historical sources/results remain exact except for explicitly
owned CI evolution. Actual runtime executions remain their original per-leaf proof.

After recovery passes, explicitly supersede only selected open durability legs,
retaining their original measurements and the recovery boundary. Do not simply
refresh old live hashes. Register recurring proof and retain exact source/control
inputs. Storage/CI infrastructure and `.4.2` parent signoff require an exact staged
canonical receipt. Broader source/claim auditing stays with startup5/29; complete
neutral D/P execution and other backend admission remain separate.


## Verified selected recovery

The archive is3,406,206 bytes (SHA256
`4f48d1dacd2de861a2b9ebdcb361b30a8d0084cc88700edf39801cee1df1a715`).
All134 restored byte counts/hashes match the original84,613,241 bytes. Regeneration
from the restored reader is byte-exact under the original-read/tracked-write guard.
22 actual recovery controls reject their intended reasons; the full audit preserves
24 checkpoints/257 references/149 current source inputs/134 logs and rejects four
input/two path/15 CI/six storage/three Phase0 controls plus summary inflation.
Healthy replay makes zero original-log and tracked-write attempts. Original input
files and prior captures remain retained. The full source-bound observation is
`docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-verification.json`.

```sh
bash tools/run_python_project_data.sh tests/language-readiness/recover_objective_audit_inputs.py
bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py
```

The first command is read-only. The second retains only new managed isolated proof
outputs. Deliberate guard probes are separated from healthy zero-attempt counts.
One recurring call/thirteen declared inputs and newest-first exact CI reversal
retain every prior byte, with three added reason-sensitive governance controls.
Original census coverage/compression and .4.1 governance counts remain historical
measurements. Selected durability supersession changes no rederive/falsify result.
Exact staged canonical proof governs this artifact/storage parent landing.
