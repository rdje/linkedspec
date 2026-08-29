---
id: codegen-inspector-thin-facade-break
title: "The codegen inspector calls its current owners directly and never falls into plugin AUTOLOAD"
answers:
  - "why does tools inspect spec codegen report unknown plugin rewrite action code with diagnostics"
  - "why does tools inspect spec codegen report unknown plugin render method call chain"
  - "when did the codegen inspector break after thin facade extraction"
  - "which task repairs the codegen inspector"
date: 2026-08-29
status: current
tags: [toolbox, codegen, facade, owner-dispatch, regression, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.13.1 reproduces the exact pre-repair PPlugin::exec_plugin_name failures for raw/lifecycle/action forms, confirms Phase 1A e964d9a4 removed the stale facade methods, and routes tools/inspect_spec_codegen.pl directly through LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics and LinkedSpec::BootstrapSpec::Core::_render_method_call_chain. t/inspect_spec_codegen.t locks both owner calls and five successful raw/lifecycle-block/lifecycle-chain/action-edge-block/action-edge-chain cases with generated Perl plus canonical diagnostics."
reverify: "perl tools/inspect_spec_codegen.pl --label Top --snippet 'return(copy(items))'"
---

# Codegen inspector thin-facade regression

Before `.13.1`, `tools/inspect_spec_codegen.pl` was not an executable ground-truth probe. Its raw-expression path
called `LinkedSpec::_rewrite_action_code_with_diagnostics(...)`, and its lifecycle/action-chain paths called
`LinkedSpec::_render_method_call_chain(...)`. Those private facade methods were removed during Phase 1A owner
extraction. The implementations belong to `LinkedSpec::RuleIR::EmitContext` and
`LinkedSpec::BootstrapSpec::Core` respectively.

Because `LinkedSpec` retains plugin AUTOLOAD behavior, an absent private method does not produce a direct missing-
method diagnostic. It is normalized as a plugin name and reaches `PPlugin::exec_plugin_name`, producing a fishy
`Unknown plugin` error. This is a toolbox routing defect, not an ActionIR or selector-lowering failure.

`FUTURE-PARITY-BACKLOG.13.1` now loads and calls those two owners explicitly. No unrelated public facade method or
second lowering seam was added. The recurring smoke statically forbids both stale `LinkedSpec::_...` calls and
executes raw helper, lifecycle block, lifecycle chain, action-edge block, and action-edge chain forms together.
Every case prints generated Perl and canonical IR diagnostics without plugin dispatch, raw fallback, or unresolved
helpers.
