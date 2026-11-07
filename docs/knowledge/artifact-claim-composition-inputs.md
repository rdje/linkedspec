---
id: artifact-claim-composition-inputs
title: Reused claim templates are actual inputs of the composition instrument
answers:
  - "which artifact-review claim input was omitted by the first November7 publisher"
  - "must a prior claim used as a template be declared as a producer input"
  - "why was artifact4.15 commit preparation stopped before landing"
  - "how does the qualified artifact claim preserve the original draft"
date: 2026-11-07
status: artifact4.15 template declaration qualified; interrupted preparation is not a hook result
tags: [claims, durability, inputs, artifacts, templates]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.15; original publish.py reads claims4.13 as a template, but claim-before-template-binding.json omits it. qualify_claim.py binds the actual unchanged Git template, retained draft, its own instrument/result and outer wrapper. Three distinguishing controls reject the original draft, removed binding and altered SHA; qualified write/readonly return0 with empty stderr."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/artifact-review-2026-11-07/qualify_claim.py"
---

The November7 artifact observer/replay has valid dated metadata, five effective
metadata controls and retained direct source/index/channel inputs. Its first
claim-composition instrument also reads the previous4.13 claim JSON to reuse
schema/narrative fields. That JSON is an actual composition input even though it
does not produce the observed row count. The first draft fails to declare it.

Before HEAD changes, stop only the verified own commit tree, preserve the actual
process snapshot and tool143 result, then qualify the input declaration. This is
a deliberate preparation correction, neither a hook failure nor an all-doctrine
pass. The observed1157 rows and original source/raw channels remain unchanged.

Keep original publish.py and claim draft byte-exact. qualify_claim.py adds the
prior template's actual SHA, verifies its unchanged activation-Git bytes, binds
the retained draft and qualification instrument/result, and distinguishes the
missing/removed/altered binding controls. The corrected claim still requires a
complete normal-hook run. A declaration repair gives no deletion, liveness,
reclamation or whole-project custody authority.

Related: [[repo-generated-artifact-cleanup-boundary]].
