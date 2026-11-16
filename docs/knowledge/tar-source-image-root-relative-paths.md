---
id: tar-source-image-root-relative-paths
title: Planning source-image qualification removes a checkout-prefixed member name
answers:
  - "why did the planning archive retain the checkout volume prefix"
  - "where is portable recovery for the November16 planning source archive"
  - "how do source archives keep member names relative to the repository"
date: 2026-11-16
status: one observed archive qualified; original producer and bytes retained
tags: [archives, paths, portability, provenance, recovery]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.1.1.0: the old publisher used absolute Path(__file__) as arcname. A separate qualified archive corrects that one source member and independently recovers all226 original member bodies/modes via native tar. Original namespace RED and five path/body/mode controls pass; original archive/Git blob remains exact."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/canonical-discovery-inventory-2026-11-16/review_portable.py"
---

The original planning producer is retained at
`docs/checkpoints/canonical-discovery-plan-2026-11-16/publish.py`. Its source
image member carries the checkout prefix because the archive name came from
the absolute `__file__` value. The native archive enumeration establishes the
actual defect; it is not a claim about every archive or platform.

Portable recovery uses
`docs/checkpoints/canonical-discovery-inventory-2026-11-16/plan-archive/before-qualified.tar.gz`.
The original archive remains historical evidence. The independent reader checks
all original/qualified bodies/modes and actual native recovery without filesystem
extraction. New source archivers derive root-relative names before adding files
and verify their exact expected member namespace.

Qualification supplies no retroactive original first-use or complete native/OS
custody credit. Wider archive/input/source-origin auditing stays with4.2/SESSION5.

Five selector-command records also held runtime-derived absolute operands.
Their exact actual records remain raw historical images; labeled relative replay
metadata preserves the observed cwd/other operands and script bytes. The combined
reader verifies this equivalence and five counterexamples without selector replay.
