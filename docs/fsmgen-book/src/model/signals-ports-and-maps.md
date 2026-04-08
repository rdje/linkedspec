# Signals, Ports, Maps, And Overrides

FSMGen has a substantial amount of interface logic, and much of it currently lives in `plugin/fsmgen.plg`.

## Interface-object syntax

`interface_object(...)` parses a compact interface description shape that can include:

- a name,
- a direction marker (`<` or `>`),
- an optional size,
- an optional forced value,
- and an optional explicit type.

The current regex supports shapes along these lines:

- `sig`
- `sig<`
- `sig>8`
- `sig>8=0x00`
- `sig<16:UNSIGNED`

That helper is important because it turns compact textual declarations into structured interface rows.

## Port and signal hash conversion

Key helper functions include:

- `signalist_2hash(...)`
- `portlist_2hash(...)`
- `portlist_2force(...)`

These helpers normalize raw table/list forms into hash-based structures that later stages use for:

- actual/formal mapping,
- size propagation,
- force/default handling,
- and generated declaration creation.

## Maps and generics

The plugin layer also includes:

- `map_objects(...)`
- `generic_objects(...)`
- `override_interface_objects(...)`

Those helpers are how FSMGen currently interprets:

- search/replace style map specifications,
- generic assignments,
- and explicit interface overrides.

## Bit, slice, concat, and constant handling

`get_signal_n_assignment_objects(...)` shows that FSMGen actively synthesizes helper declarations and assignments for:

- bare references,
- bit selections,
- slices,
- concatenations,
- constants,
- and partially-finished multi-expression support.

That is a core part of the system because it explains why generated signal declarations often contain more than just the names explicitly written in the original source.

## Size inference

The current implementation also performs real size reasoning, including:

- vector-width derivation,
- decimal/hex/binary constant sizing,
- generic-based size expressions,
- and override-based rescue paths when generic substitution is incomplete.

That makes interface documentation especially important: mapping and width rules are not trivial in FSMGen.
