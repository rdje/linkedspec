# Dated safe cleanup — REPO-HYGIENE.23

Run only the read-only reviewer:

```bash
bash tools/run_python_project_data.sh docs/checkpoints/REPO-HYGIENE.23/review.py
```

All capture, archive, control, intake, aftermath and cleanup writers in this directory
are retired after this dated observation. Do not rerun them or overwrite their output.
The next lifecycle repair has its own owner, REPO-HYGIENE.24.

The Rust target was quarantined on the repository volume. A fresh locked/offline primary
build and four typed public examples passed before native Cargo clean removed the old
quarantine. Allocated target bytes fell from 114,886,914,048 to 1,917,575,168: a reduction
of 112,969,338,880 bytes. The actual new executable is retained whole in gzip part(s).
Cargo's printed 363.1 GiB is logical deletion, not the allocated-space reduction.
The package store and already-prepared published RGX dependency outputs were retained
prerequisites. No cold dependency bootstrap, dependency implementation audit or future
toolchain reproducibility is claimed.

The history scratch held 1,702,740 entries: 1,533,599 regular files, 163,401 directories
and 5,740 symlinks, occupying 119,213,043,712 allocated bytes. The archive retains every
regular-file byte by content digest, with complete per-path metadata, symlink targets
and hardlink relations. Its three bounded parts total 55,259,061 bytes. Every payload
and metadata entry was verified from retained parts before deletion, and both public
archive readers ran on a restored complete sample with byte-identical original output.
Partial-sample hardlinks pointing outside that sample are copied; full relationships
remain in the manifest. Ownership, topology, whole source metadata and permitted empty
open-file inspections were checked again before descriptor-based removal. The closed
leases and exact result packets are retained. Redundant ignored archive staging files
were removed only after comparison to the retained copies and completed-use evidence.

The global metadata scans exclude root Git metadata, all Gitlinks/nested repositories,
this proof directory and verification/hygiene23. The original before-record phrase
"active measurement scratch" means that fixed verification exclusion; it does **not**
exclude every managed wrapper record. Both scans include existing managed-run metadata,
including observer overhead. These are non-atomic scoped working-tree observations,
not a complete repository total or independent per-file global custody. Volume free
space is separate and includes other projects' concurrent activity; its delta cannot
be attributed to this cleanup. Per-target native du agrees with the retained source
metadata totals. APFS allocation is not a guarantee of an identical physical free delta.

The large LS004 scratch ancestor contains a protected nested repository and remains
untouched. Other unresolved/unique experiment evidence, caches, Git objects/reflogs,
all earlier sealed proofs, other repositories and submodules remain retained. Ignore
status never establishes disposability. No managed recovery/purge or Git pruning ran.

Actual independent archive decoding, public-reader restoration and typed Rust outputs
are checked by review.py. Six actual reviewer controls reject bad part bytes/mode,
missing parts, wrong population totals, wrong Rust results and denied liveness evidence;
healthy and restored commands pass. Their full channels are retained. The initial
reviewer shape error is retained separately and receives no product-RED credit.
All live claims were checked before editing shared documentation; both intersections
were empty. Complete supplied book inputs and actual rendered outputs are retained.
The claim binds the closed evidence population. Current-state cleanup is never replayed
by the default reviewer, and future fixtures are not covered by this dated disposition.
