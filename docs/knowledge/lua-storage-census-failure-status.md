---
id: lua-storage-census-failure-status
title: Lua legacy-residue census now distinguishes empty results from scan failure
answers:
  - why can Lua storage verification pass after a find permission error
  - does the Lua storage oracle distinguish census failure from no residue
  - who owns the Lua legacy temporary census false PASS repair
date: 2026-09-27
status: repaired under SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.6; exact canonical receipt governs landing
tags: [lua, verification, storage, census, defect]
evidence: "The .1.1.3.1.2.2.5 dual-ABI storage run exits0 and prints PASS19 after find emits Operation not permitted for an unrelated protected entry in the old OS temp root. tools/test_lua_project_data_storage.sh places find-to-rg in an if condition, so empty output with a failed census bypasses the failure body."
reverify: "bash tools/project_data_run.sh prove -v t/lua_legacy_temp_residue.t && bash tools/test_lua_project_data_storage.sh"
---

The former legacy-residue check piped find output into rg inside an if condition. With pipefail, a failed find
makes the condition false; shell errexit does not apply to this conditional pipeline. The residue failure body
therefore runs only for successful matching output, while failure with no matches is silently accepted. The run
log is `.linkedspec-data/scratch/nested-lua-storage.log`, hashed by the carrier leaf checkpoint.

The defect is verification integrity, not evidence of an actual leaked Lua directory. The preceding owner/module/
volume and owned-workspace checks completed; the external legacy census did not. Do not relabel it as successful.
P1 .1.1.3.1.2.2.6 took ownership immediately after the carrier commit and before canonical reconciliation: bounded
relevant-entry enumeration, explicit failure propagation, empty/residue/error controls and canonical infrastructure proof.
No shared-data deletion or permission change is authorized or required.

The repair replaces that pipeline with tools/check_lua_legacy_temp_residue.pl. It checks opendir/readdir/closedir
and matching-entry lstat; filtering immediate names before metadata avoids unrelated protected children. It never
follows directory symlinks, preserving the prior -type d contract. Exit0 means clear,1 means directory residue,
and2 means census failure; the storage oracle requires0 and runs30 controlled assertions first. A nonexistent root
reproduces the old false success and now returns2. The real dual-ABI19-owner oracle passes without the permission
error. No data was deleted or permissions changed outside owned test fixtures. The adjacent Perl27-owner repair
and exact historical audit are recorded in [[perl-project-data-ssd-storage]].
