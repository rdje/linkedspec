# Inputs And Entrypoints

FSMGen currently exposes multiple entry surfaces because it accepts multiple input shapes.

## Perl-module entrypoints

The main Perl entrypoints in `perl/FSMGen.pm` are:

- `start_from_file($fsm_file_list, %opt)`
- `top_from_tree($atree, %opt)`
- `top_from_string($string, %opt)`

### `start_from_file(...)`

Use this when your FSM descriptions already exist as files.

Current behavior:

- loads files through `fsm_file_load(...)`,
- merges config,
- initializes global state,
- walks any discovered top paragraphs,
- executes generation.

### `top_from_tree(...)`

Use this when another tool has already parsed or constructed the FSM source into the expected tree/ATree shape.

### `top_from_string(...)`

Use this when you want to generate directly from an in-memory string.

This is often the easiest surface for tests, experiments, and tool-driven generation.

## Plugin entrypoints

The plugin-facing adapters in `plugin/fsmgen.plg` include:

- `fsmgen_from_string { FSMGen::top_from_string(@_) }`
- `fsmgen_from_tree   { FSMGen::top_from_tree(@_) }`

Those are thin bridges, but they matter because they are part of how FSMGen participates in the broader repo/plugin environment.

## Non-entrypoint helper layers

FSMGen also depends on several helper surfaces that are important to document even if they are not the first functions users call:

- `fsm_file_load(...)`
- `fsm_initialize(...)`
- `fsm_handler(...)`
- `top_exec(...)`
- plugin helpers such as `interface_object(...)`, `generic_objects(...)`, `portlist_2hash(...)`, and `portlist_2force(...)`

These are not all equally public, but they are user-relevant because they shape:

- accepted source forms,
- mapping syntax,
- interface behavior,
- and generated output.
