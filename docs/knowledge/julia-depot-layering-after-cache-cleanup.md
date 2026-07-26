---
id: julia-depot-layering-after-cache-cleanup
title: "A compiled-only Julia temp depot must be layered with a source-bearing package depot"
answers:
  - "why does Julia say JSON3 is not installed after cache cleanup"
  - "can Julia compiled cache resolve packages without package source"
  - "how do I run Julia after cleaning a temporary depot"
  - "how should JULIA_DEPOT_PATH layer a writable cache and installed packages"
  - "does a trailing separator in JULIA_DEPOT_PATH include the user depot"
  - "what must be preserved when cleaning Julia artifacts"
date: 2026-07-26
status: current; the repository depot is source-bearing and the developer-home depot is no longer consulted
tags: [julia, depot, cache, artifact-cleanup, offline, verification, FUTURE-PARITY-BACKLOG]
evidence: "After artifact cleanup left `/private/tmp/linkedspec-julia-depot/compiled` but no package-source tree, `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot` and the same value with a trailing `:` both failed to load project dependency JSON3. `find` proved JSON3 source remained under `$HOME/.julia/packages/JSON3`, while Julia printed the trailing-colon expansion as the temporary depot plus Homebrew system depots only; it did not include `$HOME/.julia`. Explicit `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia` kept precompile writes in the temporary depot, resolved existing package source from the second entry, and passed the 79-assertion root-core suite, package progression, primary 32/65x2, and corpus 105. Compiled bytecode is regenerable but is not a substitute for package source."
evidence_update_2026_07_20_cursor_recurring_gate: "After safe artifact cleanup removed the previously populated temporary depot, the cursor recurring driver passed Perl/Rust/Dart but failed Julia with JSON3 missing because its default `JULIA_DEPOT_PATH` contained only the writable temp path. The driver now preserves explicit overrides but otherwise queries Julia's actual `Base.DEPOT_PATH` and prepends the disposable writable depot. This makes cleanup and a fresh recurring run compatible without hard-coding a user path."
evidence_update_2026_07_26_ssd_storage: "PROJECT-DATA-SSD-ROOTING.2.4 replaces the temporary/developer-home composition with the repository-derived retained depot plus Julia-managed system depots. The canonical depot contains all five external Manifest package trees and the General registry, resolves JSON3 offline, and passes the complete package/primary/105-fixture gate without a developer-home depot entry."
reverify: "bash tools/test_julia_project_data_storage.sh && bash tools/run_julia_project_data.sh -e 'println.(DEPOT_PATH)' && bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, JSON3; println(\"ok\")'"
---

# Julia depot layering after cache cleanup

Julia package resolution needs package source even when compiled cache files exist. The historical failure used a
compiled-only temporary depot; compiled bytecode could not substitute for the missing JSON3 package source.

The supported boundary now uses a source-bearing repository depot and admits no developer-home fallback:

```console
$ bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, JSON3'
```

The trailing empty depot entry adds Julia-managed system depots, not the user depot. Those external system depots
are necessary read-only runtime inputs; package source, registry data, precompile writes, and project scratch stay
in repository storage. Cleanup may remove regenerable `compiled/` data only when no Julia process is using it;
preserve repository package sources and registries.

Related: [[julia-root-rule-selection-core]].
