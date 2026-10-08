# Recovered session handoff — 2026-10-09

The user requested machine-crash recovery and stopping at the ensuing handoff-ready
checkpoint. Recovery leaf `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0` closes only preservation
and continuity. Stop after its clean commit; implementation continuation requires
a new turn.

The interrupted session was implementing the private emission foundation under
`SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0`, from clean
`58a11ae80cc55f8d19a0a7a4f0203ae491d11383`. Its surviving state is retained in
`docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0-crash.json`: four tracked modifications recover by applying
`tracked_diff_base64` to that immutable Git index; four untracked files retain
their complete `content_base64`. Each original file has its byte count and SHA-256.
The interrupted task and memory pointer are recoverable too.

The unverified 205-line `SourceEmissions.pm` draft and six-line
`SourceOrigins.pm` invocation-token accessor are evidence only. Eight selected
production owners match the original Git bytes. No foundation tests, callback
acceptance, fragment proof or results were saved. Lost conversation, process
memory and unsaved buffers are outside this recovery.

Next activate `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1`
and declare its actual verification/claim ownership. Preserve this recovery claim
at that clean Git revision by mode/revision only before changing its bound owners.
Extract only the saved
`perl/LinkedSpec/ActionIR/SourceEmissions.pm` payload after checking its hash;
apply only the SourceOrigins hunk from the saved delta to its verified baseline.
Keep current continuity and the already preserved historical claim. Do not
blindly apply the entire old delta.

Before accepting that draft, follow the original selected plan:
`docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-plan.json`.
Author independent generated/copied/consumed character and occurrence oracles,
actual callback/invocation identity, literal/duplicate/foreign/opaque/nested/error/
Unicode/CRLF controls, original RED/corrected GREEN and effective source inverses.
Preserve callback arguments, scalar context, effects, public shapes and family
order. Inspect the draft on those terms; it has not been admitted by this checkpoint.
Commit the verified foundation before input/value/statement integration.
Complete guarded Phase0/direct consumers remain required at private acceptance
`.2.5`; mapped replacement `.1.1.2` and independent canonical `.0.3.2` remain open.

Reverify preservation with:

```sh
bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0-review.py
```

The isolated-index/object-store reviewer reconstructs all eight files, verifies
48 original historical-claim bindings, and observes six reason-sensitive RED
controls before GREEN. The initial index-only reviewer and its actual failure
channels remain retained as base64 with their original hashes; only the corrected
reviewer supplies acceptance. The path gate rejected the initial raw transcript;
encoding preserves its exact bytes without publishing machine-specific operands.
The existing public book limitation was reviewed and stays accurate. No public
behavior changed, and no full CI, runtime acceptance or push is claimed.
