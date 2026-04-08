# Plugin API Reference

FSMGen also exposes a meaningful plugin-layer surface in `plugin/fsmgen.plg`.

## Thin bridge entrypoints

These are the clearest plugin-facing entrypoints:

- `fsmgen_from_string`
- `fsmgen_from_tree`

They delegate directly to the main Perl module entrypoints and are the best starting point when FSMGen is invoked from the plugin environment rather than directly from Perl code.

## Interface and mapping helpers

Important helpers in the plugin layer include:

- `interface_object(...)`
- `interface_objects(...)`
- `override_interface_objects(...)`
- `map_objects(...)`
- `generic_objects(...)`
- `portinfo_2interface_object(...)`
- `signalist_2hash(...)`
- `portlist_2hash(...)`
- `portlist_2force(...)`

These are important because they define much of the practical user-facing syntax and conversion behavior for interfaces and mappings.

## Naming and generation helpers

Additional helpers include:

- `mapspec_atree_2signame(...)`
- `decimal_constant_string(...)`
- `helper_find_signalport_size(...)`
- `add_header_n_context_clause(...)`
- `get_entity_file_name(...)`
- `get_architecture_file_name(...)`
- `get_entity_file_description(...)`
- `get_architecture_file_description(...)`

## Top-level plugin hooks

The plugin file also contains top/hierarchy-oriented helpers such as:

- `specific_context_clause(...)`
- `move_port_2signal(...)`
- `decl_signal_from_port(...)`
- `assign_add(...)`

These are worth calling out because they represent customization seams that can materially change output structure.

## Documentation rule for this chapter

When this book is expanded further, each of the plugin helpers above should eventually gain:

- accepted input shape,
- produced output shape,
- example usage,
- and failure/edge-case notes.
