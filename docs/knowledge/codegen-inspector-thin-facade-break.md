---
id: codegen-inspector-thin-facade-break
title: "The codegen inspector still calls private methods through the thin facade and falls into plugin AUTOLOAD"
answers:
  - "why does tools inspect spec codegen report unknown plugin rewrite action code with diagnostics"
  - "why does tools inspect spec codegen report unknown plugin render method call chain"
  - "when did the codegen inspector break after thin facade extraction"
  - "which task repairs the codegen inspector"
date: 2026-07-12
status: current
tags: [toolbox, codegen, facade, owner-dispatch, regression, FUTURE-PARITY-BACKLOG]
evidence: "During FUTURE-PARITY-BACKLOG.12.1.7.3, documented raw and lifecycle inspector probes failed through PPlugin::exec_plugin_name with unknown names _rewrite_action_code_with_diagnostics and _render_method_call_chain. Source audit locates the implementations in LinkedSpec::RuleIR::EmitContext and LinkedSpec::BootstrapSpec::Core while tools/inspect_spec_codegen.pl still calls LinkedSpec::_... through the thin facade. Git history shows the inspector arrived in 2984fb50 and Phase 1A facade removal e964d9a4 did not rewire the tool. FUTURE-PARITY-BACKLOG.13.1 owns repair after selector retirement."
reverify: "perl tools/inspect_spec_codegen.pl --label Top --snippet 'return(copy(items))'"
---

# Codegen inspector thin-facade regression

`tools/inspect_spec_codegen.pl` is currently not an executable ground-truth probe. Its raw-expression path calls
`LinkedSpec::_rewrite_action_code_with_diagnostics(...)`, and its lifecycle/action-chain paths also call
`LinkedSpec::_render_method_call_chain(...)`. Those private facade methods were removed during Phase 1A owner
extraction. The implementations now belong to `LinkedSpec::RuleIR::EmitContext` and
`LinkedSpec::BootstrapSpec::Core` respectively.

Because `LinkedSpec` retains plugin AUTOLOAD behavior, an absent private method does not produce a direct missing-
method diagnostic. It is normalized as a plugin name and reaches `PPlugin::exec_plugin_name`, producing a fishy
`Unknown plugin` error. This is a toolbox routing defect, not an ActionIR or selector-lowering failure.

`FUTURE-PARITY-BACKLOG.13.1` must route the tool through explicit current owners (or a deliberate supported probe
API), exercise raw/lifecycle/action-edge forms, and add a recurring smoke lock. It is dependency-ordered after the
active selector-retirement arc so it cannot interrupt the current clean-pivot doctrine.
