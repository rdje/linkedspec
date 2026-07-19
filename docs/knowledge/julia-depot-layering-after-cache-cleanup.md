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
date: 2026-07-18
status: confirmed operational fact during Julia root-core verification
tags: [julia, depot, cache, artifact-cleanup, offline, verification, FUTURE-PARITY-BACKLOG]
evidence: "After artifact cleanup left `/private/tmp/linkedspec-julia-depot/compiled` but no package-source tree, `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot` and the same value with a trailing `:` both failed to load project dependency JSON3. `find` proved JSON3 source remained under `$HOME/.julia/packages/JSON3`, while Julia printed the trailing-colon expansion as the temporary depot plus Homebrew system depots only; it did not include `$HOME/.julia`. Explicit `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia` kept precompile writes in the temporary depot, resolved existing package source from the second entry, and passed the 79-assertion root-core suite, package progression, primary 32/65x2, and corpus 105. Compiled bytecode is regenerable but is not a substitute for package source."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot: /opt/homebrew/bin/julia --startup-file=no --history-file=no -e 'println.(DEPOT_PATH)' && test -d $HOME/.julia/packages/JSON3 && JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3; println(\"ok\")'"
---

# Julia depot layering after cache cleanup

Julia package resolution needs package source even when compiled cache files exist. A temporary depot that retains
only `compiled/` is useful as the first, writable cache layer, but it cannot satisfy a project dependency alone.
Layer an existing source-bearing depot explicitly as the second entry.

```bash
JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia \
  julia --project=julia -e 'using LinkedSpecJulia'
```

Do not rely on a trailing empty entry to add the user depot: in this Homebrew Julia 1.12.6 environment it expands
to system depots. Cleanup may remove regenerable `compiled/` directories only after checking no Julia process is
using them; preserve package sources, registries, environments, artifacts, manifests, and project source.

Related: [[julia-root-rule-selection-core]].
