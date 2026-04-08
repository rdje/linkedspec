# Perl API Reference

This chapter lists the most important active functions in `perl/FSMGen.pm`.

## Main entrypoints

### `start_from_file($fsm_file_list, %opt)`

Purpose:

- load FSM source from files,
- merge configuration,
- initialize FSMGen state,
- and execute generation for discovered top paragraphs.

### `top_from_tree($atree, %opt)`

Purpose:

- accept a prebuilt tree/ATree input,
- merge configuration,
- initialize state,
- and execute generation.

### `top_from_string($string, %opt)`

Purpose:

- accept a string input,
- parse it through Lispish,
- merge configuration,
- initialize state,
- and execute generation.

## Input and initialization helpers

### `fsm_file_load(@files)`

Current role:

- turns file input into the tree form consumed by later FSMGen stages.

### `fsm_initialize($conf, @fsm_atrees)`

Current role:

- normalizes config,
- resolves key defaults such as `_top` and `_dp`,
- extracts `define`, `fsm`, and `top` paragraphs into the global structure.

## Analysis and generation helpers

Not every helper here is equally public, but these are important reference anchors:

- `fsm_handler(...)`
- `fsm_analyze(...)`
- `fsm_analyze_jo(...)`
- `fsm_top_gen(...)`
- `fsm_walk(...)`
- `create_data_path(...)`
- `create_top(...)`
- `drive_modules(...)`
- `top_exec(...)`

## Utility/API-adjacent helpers

These are also worth documenting because advanced callers or maintainers may need them:

- `define(...)`
- `expand(...)`
- `size(...)`

## Note on publicness

FSMGen has a large Perl surface. In practice, the most stable user-facing entrypoints are still:

- `start_from_file(...)`
- `top_from_tree(...)`
- `top_from_string(...)`

The rest of this module should be treated as documented internal-generation surface unless we explicitly promote more of it as stable API.
