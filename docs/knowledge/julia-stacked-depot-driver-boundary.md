---
id: julia-stacked-depot-driver-boundary
title: "Julia drivers create only the first writable entry of a stacked depot path"
answers:
  - "how does the Julia local gate handle stacked JULIA_DEPOT_PATH"
  - "why was a directory named linkedspec-julia-depot colon Users created"
  - "which Julia scripts must mkdir only the first depot entry"
  - "how do I run the Julia gate offline with installed packages"
  - "which Julia depot entry owns generated cache writes"
date: 2026-07-26
status: current verified driver boundary
tags: [julia, gate, depot, offline, cache, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "During FUTURE-PARITY-BACKLOG.9.1.6.6 complete-driver proof, JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia exposed that tools/run_julia_local.sh and tools/check_julia_primary_cli.sh passed the entire POSIX path list to mkdir -p, creating one malformed colon-bearing directory rather than preparing the writable first depot. Both drivers now select the first entry (`:` on POSIX, `;` on MINGW/MSYS/CYGWIN), reject an empty first entry, and create only that directory. After removing the malformed regenerable directory, the stacked offline primary checker and complete driver pass and no colon-bearing directory reappears."
evidence_update_2026_07_26_ssd_storage: "PROJECT-DATA-SSD-ROOTING.2.4 makes the first entry the repository-derived retained depot and permits only Julia's trailing system-depot expansion after it. The storage oracle rejects any explicit second external entry, checks the writable depot's filesystem, locks all five package trees, and proves JSON3 resolves from the first entry."
reverify: "bash tools/check_julia_primary_cli.sh && bash tools/test_julia_project_data_storage.sh"
---

Julia treats `JULIA_DEPOT_PATH` as an ordered path list. For offline repository
verification, the first entry is LinkedSpec's writable, source-bearing retained depot. Julia's trailing empty
entry supplies its externally managed system depots; no developer-home depot supplies project package source.

Repository drivers must never pass the whole path list to `mkdir -p`.
`tools/run_julia_local.sh` and `tools/check_julia_primary_cli.sh` extract and
validate the first entry, using `:` on POSIX hosts and `;` on
MINGW/MSYS/CYGWIN, then create only that writable directory. A path-list string
used as one filesystem name produces a misleading colon-bearing artifact and
does not prepare the depot Julia will actually write.

Use the self-rooted wrapper for a targeted offline command:

```console
$ bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia'
```

Related: [[julia-rule-local-cursor-admission]] and
[[julia-primary-cli-process-conformance]].
