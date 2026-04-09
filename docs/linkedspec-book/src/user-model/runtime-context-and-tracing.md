# Runtime Context and Tracing

LinkedSpec has a structured runtime-context story rather than only ad hoc dies and trace prints.

## Runtime context

The runtime context carries useful execution information such as:

- selected `top_rule`
- `spec_name`
- `spec_path`
- structured `last_error`
- parser-source capture state when requested

That makes failures easier to attribute and debug.

## Tracing

Tracing exists to make runtime and compile behavior inspectable without turning the system into an opaque dynamic-eval black box.

The trace surface is useful for:

- understanding parser entry and dispatch
- seeing rule-handler boundaries
- inspecting decision points
- debugging mark/capture behavior

## Why this exists

LinkedSpec wants to remain dynamic and flexible without becoming impossible to trust. Structured runtime context and trace scopes are part of that trust story.
