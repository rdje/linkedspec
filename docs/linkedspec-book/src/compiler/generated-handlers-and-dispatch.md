# Generated Handlers and Dispatch

LinkedSpec generates rule handlers dynamically, but the project has been moving away from opaque, repeatedly-evaled behavior toward a cleaner and more attributable runtime model.

## Important themes

- generated handlers are attributed to rule labels and variants
- top-level parser invocation keeps structured entrypoint identity
- dispatch uses compiled dependency regexes explicitly
- runtime failures are normalized into structured error channels

## Why this matters

Dynamic generation is powerful, but without structure it becomes hard to trust.

LinkedSpec’s current direction is to keep the flexibility of generated handlers while making them:

- more inspectable
- more attributable
- more deterministic
- and less fragile

## What a generated handler is

A generated handler is the runtime implementation of one compiled rule.

At compile time, LinkedSpec takes the parsed rule paragraph and lowers it into runtime behavior:

```text
rule paragraph
  -> RuleIR
  -> emit context
  -> generated handler
  -> parser invocation path
```

The handler is where regex dispatch, child-rule calls, action code, lifecycle code, and returned payloads come together.

## Dispatch through dependency regexes

When a rule references child rules, LinkedSpec builds derived dependency-regex dispatch data.

The public descriptor name for that derived map is:

```text
dependency_regex_map
```

Generated handlers use it to dispatch efficiently:

```perl
LinkedRE::or($STRING, $$descr{dependency_regex_map}{Top}, $info)
```

In `consume` parse mode, the generated dispatch is contiguous:

```perl
LinkedRE::or($STRING, $$descr{dependency_regex_map}{Top}, 'consume', $info)
```

This is why dependency-regex state is part of the compiled descriptor model rather than a random sidecar.

## Handler identity

Generated handlers are attributed using stable labels.

The structured identity can include:

- rule label
- handler variant
- handler source label

The label-only form looks like:

```text
LinkedSpec::generated_handler:<rule_label>
```

When the exact variant is known, the label can become more specific:

```text
LinkedSpec::generated_handler:<rule_label>:<handler_variant>
```

This identity is valuable because dynamic code needs attribution. If a generated handler fails, the user should not have to reverse-engineer the rule from a Perl stack string.

## RuleIR and emit context

Rule compilation passes through RuleIR and an emit context.

The emit context carries the normalized action/lifecycle material consumed by `SpecEntry`.

Important active fields include:

- `ACODEs`
- `BCODEs`
- `BCALLs`
- `DEPENDENCY_REFS`
- lifecycle chunks such as `icode`, `ecode`, `lxcode`, `lscode`, `lecode`
- action-rewriter metadata

The important naming point is `DEPENDENCY_REFS`. It describes rule dependency references carried from action-code edges into compiled rule info, where the outward rule field becomes `dependency_refs`.

## Why generated handlers still matter

LinkedSpec remains a dynamic parser system. Generated handlers keep it flexible and fast for the current Perl backend.

The modernization goal is not to pretend generation does not exist. The goal is to make generation:

- compiled once where possible
- structured around explicit state
- attributed in diagnostics
- backed by regression tests
- and less dependent on opaque runtime eval behavior
