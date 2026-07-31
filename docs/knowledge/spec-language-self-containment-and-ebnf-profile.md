---
id: spec-language-self-containment-and-ebnf-profile
title: Self-contained `.spec` objectives and EBNF-like authoring share one semantic core
answers:
  - "what does self contained mean for a LinkedSpec spec file"
  - "does LinkedSpec aim to be Turing complete"
  - "can a spec file access the filesystem network process or environment"
  - "are host language callbacks part of the expressive language goal"
  - "is an EBNF like syntax planned for LinkedSpec"
  - "will the EBNF like syntax have a separate runtime"
  - "how does an EBNF profile retain cursor and capture semantics"
  - "will ordinary spec syntax and an EBNF profile share one AST or HandlerIR"
  - "how will diagnostics map from canonical IR to EBNF authored source"
  - "does every backend implement the same authoring profile semantics"
  - "when will the self containment and EBNF direction be implemented"
date: 2026-07-30
status: current
tags: [architecture, dsl, self-containment, ebnf, frontend, source-map, actionir, handlerir, parity]
evidence: "ADR 0064 and SPEC-LANGUAGE-SELF-CONTAINMENT.0 accept problem-domain expressive closure without ambient effects, plus an optional honest EBNF-like frontend that lowers losslessly into one canonical semantic model across five backends; no syntax or behavior is implemented by the direction leaf."
reverify: "bash scripts/check_memory_architecture.sh && bash knowledge-map/scripts/check_knowledge_map.sh && bash scripts/check_doctrines.sh"
---

# `.spec` Self-Containment and EBNF-Like Authoring

LinkedSpec targets expressive self-containment for its own problem domain. After caller-authorized source enters
the engine, normal grammar, recursion, cursor/source-location control, capture, scoped typed state, callable
composition, branching, iteration, transformation, and result construction should be expressible without routine
backend-host escape hatches. This is not an unrestricted-computation claim and does not grant filesystem, process,
network, environment, clock, randomness, package-loading, or host-FFI authority.

ADR `0064` accepts an optional EBNF-like authoring profile in principle. It is a frontend, not a second language
runtime: ordinary syntax and the profile must lower to one versioned canonical AST/HandlerIR and reuse identical
validation, compilation, execution, generated state, semantic introspection, MCP projection, diagnostics, and
resource policy. Perl, Rust, Dart, Julia, and Lua implement the same neutral contract.

The profile may resemble EBNF only where semantics agree. A formal difference table must keep LinkedSpec ordered
matching, seek/consume, cursor movement, capture/state/actions, progress, failure, and result construction visible
through explicit extensions. Lowering preserves profile identity, original source, Unicode-scalar spans, canonical
node correspondence, and diagnostic remapping, so users debug the source they authored.

No new syntax or behavior is current yet. `docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md` first inventories portable
capabilities and real gaps, defines mutation-sensitive neutral objectives, closes missing core semantics, proves the
profile on realistic recursive/progressive formats, then implements five-backend frontend parity and no-drift.

Related facts: [[language-agnostic-backend-vision]], [[typed-source-location-cursor-algebra-direction]],
[[spec-format-brainstorm-rounds-1-3]], [[post-parity-structured-text-program]].
