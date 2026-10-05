---
id: historical-selector-diagnostic-classification
title: Historical rejected-source diagnostics require exact path and content classification
answers:
  - "why does canonical CI reject retained pipeline diagnosis selector artifacts"
  - "how does executable selector scanning classify historical rejected experiments"
  - "does the historical selector classification exempt edited or copied checkpoint source"
  - "where are the failed metadata canonical candidate and output preserved"
date: 2026-10-05
status: focused blocker repair verified; exact restaged canonical receipt required for landing
tags: [ci, historical-evidence, aggregate-selectors, provenance, claim-verification]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.1: actual original/current/composed exits1/0/0; complete4021 regular input identities; two original positive occurrences classified only at exact path/full SHA-256;18 distinguishing RED controls. Initial canonical exit1 and full merged output/exact staged diff remain archived."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.1-selector-review.py"
  - "bash tools/run_python_project_data.sh tools/check_public_aggregate_selector_surface.py"
---

Canonical metadata landing first stopped at the public aggregate-selector admission.
Executable candidate discovery includes checkpoint Python/Perl sources. The original
pipeline diagnosis deliberately retains a rejected experiment and prose describing
that rejection; the original compatibility classifier treats both as positive source.
The compiler's rejection is preserved, not an authoring compatibility form.

The gate now classifies exactly the immutable .1.2.0-claim.py and
.1.2.0-split-probe-initial.pl paths at their full SHA-256 identities. Both input files
remain byte-identical to Git95e6a02935155b9ab7b5c30f79a3275529b803da. An altered
file, extra positive source or copied artifact cannot borrow the classification.
No generic checkpoint or historical filename exclusion is introduced. Existing
untracked discovery and three-process serialized concurrency checks stay active.

Actual original/current/composed runs use one fixed candidate input snapshot;
only the executed classifier producer changes. Complete4021 regular members supply
a conservative input superset for executable/public/contract/capability guards.
Unchanged inputs are recoverable from immutable Git95; exact overlays are retained
in the capsule, with the original preliminary capsule separately hash-bound.
Nonregular/submodule metadata is excluded without payload inspection. Ten source
classification and eight producer/channel/guard/membership corruptions observe RED.
Public70/classified36/current0/migration5/mutations11 and composed runtime/capability
checks pass. The initial1321-scanner-input capture remains unchanged and explicitly
limited: it did not bind suffix-excluded composed inputs. The final capture repairs
that leg before composed acceptance is claimed.

The first canonical job's consumed exit1, complete merged stdout/stderr and exact
staged binary diff remain under the owning .1.2.1.1 canonical-first prefix. The archive
is an actual failed boundary, not a completed gate or reconstructed external-toolchain
IO graph. Exact restaged canonical CI must pass before public metadata/regex-parent
landing. All scratch and outputs remain on the repository volume; other repositories
are read-only and dependency submodules remain black boxes.
