---
id: pplugin-pluginbridge-transition-machinery
title: PPlugin and PluginBridge are transition/removal machinery, not the target architecture; dynamic plugin loading is legacy-removal territory
answers:
  - "are PPlugin and PluginBridge part of the target architecture"
  - "should new code use plugin dispatch"
  - "what is the plugin modernization status"
  - "is LinkedSpec still a plugin-hosting framework"
date: 2026-06-12
status: current
tags: [architecture, plugin, legacy, modernization]
evidence: "ARCHITECTURE_STATE.md §Current Strategic Judgments: 'LinkedSpec is no longer best understood as a plugin-hosting framework'; PLUGIN-MODERNIZATION tree completed (5 leaves, 2026-05-17)"
reverify: "grep -n 'transition.removal.machinery\|plugin-hosting framework' ARCHITECTURE_STATE.md"
---

The current architecture direction explicitly treats `PPlugin` and `PluginBridge` as
transition/removal machinery, not as the future identity of LinkedSpec. Key points:

- **`LinkedSpec.pm` still exposes** `run_plugin`, `get_plugin`, `dispatch_plugin_autoload_name`,
  and `AUTOLOAD` — all marked `DEPRECATED` with retirement tied to `PLUGIN-MODERNIZATION.5`.
- **`PluginBridge`** is a registry-first dispatch shim over the older `.plg` runtime; it
  assembles its default callback map through `OwnerDispatch::build_dep_map`.
- **`PPlugin`** owns legacy `.plg` discovery, reads files through explicit IO, parses via the
  `pplugin` spec, and lazy-loads its default parser callback through `OwnerDispatch`.
- **The lazy compatibility cycle**: `LinkedSpec -> PluginBridge -> PPlugin -> LinkedSpec::get_parser('pplugin')`.
- **17 dead `.plg` files** deleted (1,030 lines, 45 actions) in `PLUGIN-ACTION-MIGRATION`.
  **19 `.plg` files** remain as legacy corpus.
- **Extracted helper owners** (`HTTP::FileAccess`, `QC::Flow`, `Timing::SetupHold`, etc.) now
  live outside `LinkedSpec::*` under domain packages. Direct Perl callers use these owners
  instead of routing through `LinkedSpec::run_plugin(...)`.

The clearer core story: named `.spec` lookup, parser compilation, parser runtime, action
lowering, diagnostics. Dynamic plugin loading was historically useful but is not the
architectural center anymore.

Related: [[ownerdispatch-shared-seam]].
