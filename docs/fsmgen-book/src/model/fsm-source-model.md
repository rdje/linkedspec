# FSM Source Model

FSMGen does not consume free-form text directly. Its working input model is a Lispish/ATree structure whose nodes are dispatched by head token.

That matters because the source model is not "whatever looks reasonable." The active code in [perl/FSMGen.pm](/Users/richarddje/Documents/github/linkedspec/perl/FSMGen.pm) recognizes a specific set of paragraph kinds, decision-tree nodes, and hierarchy nodes.

This chapter documents those active shapes from the implementation that currently drives:

- `fsm_initialize(...)`
- `fsm_walk(...)`
- `dtree_walk(...)`
- `top_exec(...)`
- helper parsing in [plugin/fsmgen.plg](/Users/richarddje/Documents/github/linkedspec/plugin/fsmgen.plg)

## Reading the examples

Examples below use a Lispish-style notation because that is the closest readable form to what FSMGen walks internally.

Conceptually, a node looks like:

```lisp
(HEAD CHILDREN...)
```

So a top-level source may contain paragraphs such as:

```lisp
(?define:macro_name ...)
(?fsm:uart_ctrl ...)
(?top:system_top ...)
```

The examples in this chapter are intentionally structural. They show the shapes FSMGen expects and dispatches on, not the exact final emitted RTL.

## Top-level paragraphs

`fsm_initialize(...)` scans the loaded ATree for exactly three core paragraph families:

- `?define:<name>`
- `?fsm:<name>`
- `?top:<name>`

### `?define:<name>`

This stores a named macro-like source fragment under `global->{define}{name}`.

Example shape:

```lisp
(?define:shared_ports
  (...macro body...))
```

These definitions are later consumed from hierarchy trees through macro-call nodes of the form:

```lisp
(?&shared_ports key=value other=value)
```

The active `define(...)` and `expand(...)` code tells us two important things:

- the macro body is recursively cloned and expanded before use,
- bracketed expressions like `[ ... ]` are treated as expansion/evaluation regions.

So `?define` is not just a named comment block. It is an actual reusable source template mechanism.

### `?fsm:<name>`

This is the paragraph that describes one FSM decision-tree block.

Example shape:

```lisp
(?fsm:uart_ctrl
  (IDLE ...)
  (RUN ...)
  (:= ...)
  (:< ...)
  (...shared-info entries...))
```

`fsm_analyze(...)` finds these paragraphs, and `fsm_walk(...)` is the main dispatcher for their bodies.

### `?top:<name>`

This is the paragraph that describes hierarchy/top construction.

Example shape:

```lisp
(?top:system_top
  (?fsmc:ctrl ...)
  (?rtl:uart ...)
  (?ports:user_if ...)
  (?toplink:subtop ...)
  (?&shared_ports ...))
```

`top_exec(...)` is the active consumer for these trees.

## FSM paragraph body

Inside a `?fsm:<name>` paragraph, `fsm_walk(...)` currently recognizes these entry families by the first atom of each child node.

### State decision tree: bare word

A bare word such as `IDLE` or `RUN` is treated as a state decision tree and routed to `st_decision_tree(...)`.

Example:

```lisp
(?fsm:uart_ctrl
  (IDLE
    (...decision tree...))
  (RUN
    (...decision tree...)))
```

Important active behavior:

- the first encountered state becomes `initial_state` unless already set,
- every state label is collected into the FSM state enum type,
- the state decision tree pushes a condition equivalent to `state_variable == current_state`.

So a bare-word entry is not just a label. It creates a state-scoped decision-tree context.

### Stand-alone decision tree: `-name`

An entry whose head begins with `-` is routed to `sa_decision_tree(...)`.

Example:

```lisp
(?fsm:uart_ctrl
  (-comb_logic
    (...decision tree...)))
```

This is used for stand-alone or combinational decision-tree logic that is not tied to a named FSM state.

### Asynchronous reset: `:=`

An entry headed by `:=` is routed to `asyncreset(...)`.

Example:

```lisp
(?fsm:uart_ctrl
  (:= rst_n=0 state=IDLE counter=0))
```

The current implementation accepts simple `key=value` atoms here and stores them under the shared async-reset structure.

### Synchronous reset: `:<`

An entry headed by `:<` is routed to `syncreset(...)`.

Example:

```lisp
(?fsm:uart_ctrl
  (:< state=IDLE))
```

The active dispatcher recognizes the node kind even though the implementation is still much thinner than the asynchronous reset path.

### Shared-info entries

Any entry whose head matches `conf->{sharedinfo}` is routed to `sharedinfo(...)`.

That means shared-info is configuration-driven rather than hard-coded to one token family. When documenting or extending a specific FSMGen setup, the configured `sharedinfo` regex is part of the user-facing source model.

## Decision-tree nodes inside a state or stand-alone tree

Once FSMGen is inside a state or stand-alone decision tree, `dtree_walk(...)` and `dtree_node_iterate(...)` take over.

The active node families are richer than just assignment and transition.

### Assignment nodes

Assignment heads are matched by:

```text
name
name'
name[bit]
name[msb:lsb]
name>
```

Conceptually:

```lisp
(data_valid> ...)
(counter ...)
(bus[7:0] ...)
```

The implementation supports:

- output-marked names with `>`,
- inline size hints with `'N`,
- bit and slice left-hand sides like `sig[3]` or `sig[7:0]`.

The detailed assignment semantics are handled later by `assignode(...)`, which further fans out into sequential/combinational assignment variants.

### Transition node: `->`

State transitions are explicit decision-tree nodes headed by `->`.

Example:

```lisp
(IDLE
  (-> RUN))
```

This is the active state-change primitive in the decision-tree language.

### Auto increment/decrement nodes

The dispatcher also recognizes:

- `++`
- `--`
- `+=N`
- `-=N`

Those are routed to arithmetic update helpers rather than being treated as generic assignments.

### Test nodes

The active test syntax includes several families:

- `?signal`
- `?`
- `<signal`
- `<!signal`
- `<signal=value`
- `<!signal=value`
- `<`
- `<!`

Examples:

```lisp
(?ready
  (=1 (...))
  (=0 (...)))

(<enable
  (...))

(<!error
  (...))

(?
  (& ready valid)
  (...cases...))
```

From the implementation, the important distinction is:

- `?signal` introduces a normal test/case-style node,
- `<signal` and `<!signal` are shortcut test variants,
- `<signal=value` variants fold comparison directly into the head token,
- `?` / `<` / `<!` allow boolean-expression nodes rather than only plain signal names.

### Repeat node

The dispatcher also accepts:

```lisp
(?repeat:COUNT
  (...template node...))
```

This is handled by `repeatnode(...)`, which clones the child shape multiple times while substituting loop context values.

## Boolean-expression nodes

Inside test contexts, FSMGen actively supports logical-expression nodes with these heads:

- `&`
- `|`
- `!&`
- `!|`
- `!`
- `^`
- `!^`

Example:

```lisp
(& ready valid)
(! error)
(| rx_done timeout)
```

The implementation routes them through `logical_dispatch(...)`, `logicalnode(...)`, and the related NAND/NOR/XNOR helpers.

Logical leaves can compare against:

- binary constants,
- sized decimal constants,
- hexadecimal constants,
- another signal,
- another signal bit,
- another signal slice.

So the active decision-tree language is already a real small boolean DSL, not only a flat IF/ELSE tree.

## Hierarchy/top nodes

Inside a `?top:<name>` paragraph, `top_exec(...)` recursively walks nodes whose heads match:

- `?&macro_name`
- `?fsmc[:name]`
- `?rtl:<name>`
- `?ports:<name>`
- `?toplink:<name>`
- `?top:<name>`

### Macro call: `?&name`

This expands a previously defined `?define:name` body in hierarchy context.

Example:

```lisp
(?&shared_ports width=8 domain=sys)
```

The current code builds a key/value context from atoms like `key=value`, clones the stored definition, expands it, and then routes the resulting content back through `fsm_handler(...)`.

### FSM compile node: `?fsmc[:name]`

This is the hierarchy node that embeds one or more FSM paragraphs into an intermediate module/top.

Example:

```lisp
(?fsmc:ctrl
  uart_ctrl
  rx_path
  /rx_/rx_i/
  --WIDTH=8)
```

From the current implementation:

- bare non-option atoms are resolved as FSM sources,
- ref/hash-like children flatten into local options,
- an explicit node name seeds `_top` / `_dp`,
- the result is compiled through `fsm_analyze(...)` plus `fsm_top_gen(...)`,
- the node returns a `{ module => ..., portmap => ... }` structure to hierarchy assembly.

### RTL instance node: `?rtl:<name>`

This loads an existing RTL entity/module interface and instantiates it in the current top.

Example:

```lisp
(?rtl:uart_core
  /tx/tx_o/
  /rx/rx_i/
  --WIDTH=8
  :u_uart)
```

The active path:

- loads entity information through `entity_loader(...)`,
- parses generics,
- parses override-interface specs,
- builds a port map,
- optionally applies a user instance name.

### Explicit port bundle node: `?ports:<name>`

This is similar to `?rtl:<name>`, but the interface is built from inline interface objects instead of an external entity load.

Example:

```lisp
(?ports:user_if
  ready>1
  valid<1
  data<8
  /data/data_bus/)
```

### Top link node: `?toplink:<name>`

This links to another named top that FSMGen already knows how to build or has built earlier.

Example:

```lisp
(?toplink:subsystem
  /clk/sys_clk/
  /rst/sys_rst/)
```

### Nested top node: `?top:<name>`

Nested `?top` nodes are the main hierarchy-building structure. They are where submodules are collected, port directions are reconciled, internal signals are inferred, and final top-level port/signal tables are created.

Conceptually:

```lisp
(?top:system_top
  (?rtl:uart_core ...)
  (?fsmc:ctrl ...)
  (?top:subsystem ...))
```

## Inline mini-languages used inside hierarchy nodes

`plugin/fsmgen.plg` is important because several user-facing atoms inside top/hierarchy nodes are parsed there.

### Interface-object atoms

`interface_object(...)` currently accepts:

```text
name
name<
name>
name<8
name>8=0b1010
name<16:UNSIGNED
```

Semantics:

- `<` means `IN`
- `>` means `OUT`
- a trailing size like `8` creates a vector
- `=...` captures an output force/default value
- `:TYPE` overrides the default VHDL type

Examples:

```text
ready<
valid>
data<8
mask<16:UNSIGNED
done>1=0b0
```

### Mapping atoms

`map_objects(...)` parses slash-delimited mapping specs:

```text
/search/replace/
```

Example:

```text
/tx/tx_o/
/rx/rx_i/
```

Those feed `portlist_2hash(...)`, which applies the first matching search/replace mapping to each formal port.

### Generic atoms

`generic_objects(...)` accepts `-name=value` and `--name=value` style generic assignments.

Examples:

```text
-WIDTH=8
--DEPTH=16
```

### Instance-name atoms

`get_instance_name(...)` treats a leading-colon atom as an explicit instance name.

Example:

```text
:u_uart
```

### Plugin option atoms

`getop_plugin_list(...)` accepts `+type=plugin#arg#arg` style plugin attachment specs.

Examples:

```text
+declarch=my_plugin
+beginarch=my_plugin#foo#bar
```

That is part of the active source model too, because those atoms change how top generation is extended.

## Practical mental model

The safest way to think about FSMGen source is:

1. top-level paragraphs declare reusable macros, FSM blocks, and tops,
2. FSM paragraphs contain decision-tree programs,
3. top paragraphs contain hierarchy assembly programs,
4. hierarchy atoms reuse several plugin-defined mini-languages for ports, mapping, generics, instance names, and plugin hooks.

That model matches the current code much better than treating FSMGen input as one flat “FSM text format.”

## What to read next

After this chapter, the most useful follow-ups are:

- [Hierarchy And Tops](hierarchy-and-tops.md)
- [Signals, Ports, And Maps](signals-ports-and-maps.md)
- [Inputs And Entrypoints](../using/inputs-and-entrypoints.md)
- [Plugin API](../reference/plugin-api.md)
