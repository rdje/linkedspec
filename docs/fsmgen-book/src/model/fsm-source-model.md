# FSM Source Model

The active code suggests that FSMGen consumes a Lispish/ATree-shaped representation of FSM content and then walks it according to a small set of recognized paragraph/node kinds.

## Top-level recognized paragraphs during initialization

`fsm_initialize(...)` explicitly looks for:

- `?define:<name>`
- `?fsm:<name>`
- `?top:<name>`

So those are core structural markers in the loaded source model.

## FSM-level constructs

Inside `fsm_walk(...)`, FSMGen currently distinguishes at least:

- state decision-tree entries with bare word names,
- stand-alone decision trees with `-name`,
- asynchronous reset entries marked by `:=`,
- synchronous reset entries marked by `:<`,
- shared-info entries matched through the configured `sharedinfo` regex.

This already tells us something important: FSMGen is not only reading one flat FSM list. It is dispatching into specialized handlers depending on source-node role.

## Hierarchy-level constructs

Inside `top_exec(...)`, FSMGen recognizes additional node kinds such as:

- macro calls,
- `fsmc`,
- `rtl`,
- `ports`,
- `toplink`,
- `top`

Those are the nodes that drive hierarchy assembly, submodule connection, and final top construction.

## Why this matters

To document FSMGen well, we need to distinguish two models:

1. the **source model** users write,
2. the **internal generation model** the code constructs.

This chapter is about the first one.

The later architecture chapters describe how the source model is turned into:

- shared module records,
- ports,
- signals,
- assignments,
- constants,
- instance graphs,
- and final generated files.
