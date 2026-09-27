---
id: lua-storage-census-failure-status
title: Lua storage verification can print PASS after its legacy-residue census fails
answers:
  - why can Lua storage verification pass after a find permission error
  - does the Lua storage oracle distinguish census failure from no residue
  - who owns the Lua legacy temporary census false PASS repair
date: 2026-09-27
status: confirmed; P1 immediate repair under SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.6
tags: [lua, verification, storage, census, defect]
evidence: "The .1.1.3.1.2.2.5 dual-ABI storage run exits0 and prints PASS19 after find emits Operation not permitted for an unrelated protected entry in the old OS temp root. tools/test_lua_project_data_storage.sh places find-to-rg in an if condition, so empty output with a failed census bypasses the failure body."
reverify: "bash tools/test_lua_project_data_storage.sh; inspect both exit status and stderr rather than trusting its PASS marker before repair"
---

The final legacy-residue check pipes find output into rg inside an if condition. With pipefail, a failed find
makes the condition false; shell errexit does not apply to this conditional pipeline. The residue failure body
therefore runs only for successful matching output, while failure with no matches is silently accepted. The run
log is `.linkedspec-data/scratch/nested-lua-storage.log`, hashed by the carrier leaf checkpoint.

The defect is verification integrity, not evidence of an actual leaked Lua directory. The preceding owner/module/
volume and owned-workspace checks completed; the external legacy census did not. Do not relabel it as successful.
P1 .1.1.3.1.2.2.6 runs immediately after the carrier commit and before canonical reconciliation: bounded relevant
entry enumeration, explicit failure propagation, empty/residue/error controls and canonical infrastructure proof.
No shared-data deletion or permission change is authorized or required.
