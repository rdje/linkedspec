---
id: julia-runtime-matching-state
title: Julia runtime matching uses native PCRE with stable alternatives and entry/local registers
answers:
  - where is the Julia runtime matching code
  - does Julia support seek and consume regex matching
  - how does Julia track entry and local match state
  - does Julia expose character offsets for match positions
  - how does Julia detect zero-progress matches
  - does Julia need regex dialect normalization
  - does Julia Regex support Python named captures POSIX flags possessive and recursion
date: 2026-07-10
status: current
tags: [julia, runtime, regex, match-state, PCRE, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.1 adds julia/src/runtime/Matching.jl and exports LinkedSpecParseMode, RuntimeRegexAlternative, RuntimeRegexAlternation, RuntimeRegexMatch, RuntimeMatchRegisters, RuntimeLineColumn, match/offset/register helpers, and JSON projection. julia/test/runtests.jl verifies seek/consume behavior, stable alternative identity, compiled-rule patterns, full/compact/named captures, multibyte character offsets, line/column positions, entry/local register separation, cursor and capture anchors, zero-width/progress detection, immutable updates, and boundary/input guards. Direct Julia 1.12 native Regex probes accept (?P<name>), (?<name>), POSIX classes, inline/scoped flags, possessive quantifiers, and (?R) recursion without a dialect rewrite."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

## Fact

Julia runtime matching lives in `julia/src/runtime/Matching.jl`.

`RuntimeRegexAlternation` compiles ordered patterns, including `CompiledRule.regex_patterns`, into native Julia
`Regex` values. `seek_match(...)` selects the earliest candidate and breaks same-position ties by lower source
alternative; `consume_match(...)` accepts only a match that starts at the code-unit cursor. Alternative indexes are
stable zero-based values and do not depend on a combined-regex branch side channel.

`RuntimeRegexMatch` records the full group-slot vector, compact participating captures, named captures, zero-based
Julia code-unit spans, public character offsets, line/column positions, and zero-width/progress state.
`RuntimeMatchRegisters` keeps entry and local matches separate across child dispatch, tracks cursor and capture-start
anchors, and returns updated immutable records.

Julia 1.12's native PCRE integration directly accepts the currently required Python/angle named captures, POSIX
classes, inline/scoped flags, possessive quantifiers, and recursive `(?R)`. Unlike Dart, this boundary does not need
a regex dialect-normalization or bounded structural-regex adapter.

Related facts: [[julia-runtime-rule-interpreter]], [[julia-compiled-spec-state]], [[dart-runtime-matching-state]],
[[rust-entry-match-separation]], [[rust-char-based-offsets]], [[julia-backend-interpreter-first-plan]].
