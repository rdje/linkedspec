# Hierarchy And Tops

One of the most important FSMGen behaviors is how it turns multiple FSM/module fragments into a generated top-level view.

## The `_top` and `_dp` convention

The code uses both:

- `_top`
- `_dp`

These names are configuration-backed and are central to how FSMGen separates:

- the top-level wrapper view,
- from the data-path-related module view.

## `create_top(...)`

`create_top(...)` is the clearest current expression of top-level assembly rules.

It does all of the following:

- inspects module ports,
- derives top inputs,
- derives top outputs,
- infers internal signals,
- groups system/control/data ports,
- builds a same-name wiring netlist,
- and records output exceptions.

## Important default heuristics

The current code documents some strong default assumptions:

- top inputs are inferred from module inputs that are not already satisfied by matching data-path outputs,
- outputs of `_dp` that feed FSM logic are usually not exposed as top outputs by default,
- same-name ports across modules are treated as implicitly connected,
- and explicit exceptions can override those defaults.

This is a big part of FSMGen’s value, but it is also one of the areas users most need documented clearly because the generated top interface is not only a direct echo of the input source.

## Signals and exceptions

The top-building path maintains explicit exception state such as output exceptions and uses that to decide whether a name becomes:

- a top-level port,
- an internal signal,
- or a renamed/intermediate signal used to support explicit output behavior.

## Practical consequence

If a generated top-level interface looks surprising, the most likely explanation is in the hierarchy rules, not in the final text emission.
