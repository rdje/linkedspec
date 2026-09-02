---
id: aggregate-selector-backend-readme-coverage
title: Backend READMEs are part of aggregate-selector public no-drift
answers:
  - "why did removed aggregate selectors remain in backend READMEs"
  - "which backend READMEs taught stale selector forms"
  - "how does the public selector checker discover component READMEs"
  - "how many public files does aggregate selector admission check"
date: 2026-07-12
status: current
tags: [language, bindings, retirement, documentation, readme, no-drift, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.10 found 14 current positive exact selector forms in rust/README.md, dart/README.md, julia/README.md, and lua/README.md after .12.1.9 had reported zero examples across a curated 47-file root/capability/mdBook list. The four READMEs now use bare typed bindings. tools/check_public_aggregate_selector_surface.py discovers every immediate component README, asserts 56 files and 31 classified removed/history references, requires four backend bare-binding anchors, and reports zero current examples."
evidence_update_2026_07_12_lua_array_closeout: "The 56-file inventory remains exact, but its classified count is now 27. Four former matches were `array (statement)` prose fragments inside a formal-grammar code block, not removed selector references; LUA-BACKEND-PARITY.4.3.4.6 replaced them with accurate updated-snapshot descriptions and corrected the expected count."
evidence_update_2026_07_15_structured_format_page: "FUTURE-PARITY-BACKLOG.18.0 added architecture/structured-format-program.md to the discovered mdBook surface. LUA-BACKEND-PARITY.4.3.7.4's first canonical gate measured the stale exact count; the checker now asserts 57 public files, 27 classified removed/history references, and zero current examples."
evidence_update_2026_07_15_native_loading_page: "LUA-BACKEND-PARITY.5.2.1 added public-api/native-spec-loading.md. The exact discovered inventory is now 58 files; classified/current selector counts remain 27/0."
evidence_update_2026_07_20_semantic_introspection_page: "FUTURE-PARITY-BACKLOG.10.2 added public-api/semantic-introspection.md. The public selector checker reviewed the new chapter, advances the exact inventory to 59 files, and keeps classified/current selector counts at 27/0."
evidence_update_2026_07_29_readme_routing: "README-STABILITY-POLICY.1 retains the bounded root README in the 59-file discovered scan but removes its two duplicate historical selector references. Classified/current counts are now 25/0; backend README coverage and bare-binding anchors are unchanged."
evidence_update_2026_08_25_staged_ast_enrichment_page: "FUTURE-PARITY-BACKLOG.14.7.2 adds compiler/staged-ast-enrichment.md. The discovered public inventory is now 60 files; classified/current selector counts remain 25/0."
evidence_update_2026_08_29_codegen_inspector_page: "FUTURE-PARITY-BACKLOG.13.1 adds development/codegen-inspector.md. The exact staged canonical gate discovers 61 public files; classified/current selector counts remain 25/0, and component README discovery plus all four backend bare-binding anchors are unchanged."
evidence_update_2026_09_02_macos_latency_page: "FUTURE-PARITY-BACKLOG.19.3.4.0 adds development/macos-rust-launch-latency.md. The .19.4.1 canonical boundary discovers that the public cardinality guard remained at 61; the corrected exact inventory is 62 files, with backend README discovery and all four bare-binding anchors unchanged."
reverify: "bash tools/run_python_project_data.sh tools/check_public_aggregate_selector_surface.py"
---

The `.12.1.9` public checker was correct for every file it enumerated, but its inventory was incomplete: it fixed
root project documents, capability documentation, and every mdBook source file without scanning backend entry
documents. That allowed runtime and executable-source retirement to be complete while four public backend READMEs
still described retired selector reads and mutations as current.

Follow-up `.12.1.10` migrates all 14 exact forms to bare typed reads, `set`, `copy`, `push`, `set_key`, and mutable
three-argument `split`. The checker now discovers `*/README.md` at the repository component level, deduplicates the
already-fixed capability README, and scans those files beside root documents and mdBook sources. Exact file and
classified-reference counts make inventory growth deliberate; backend-specific bare-binding anchors ensure the
entry documents teach the replacement, not merely avoid the removed spelling.

The current discovered inventory is 62 files; classified and current example counts are 25 and zero after root
README history was routed to canonical documentation.
