# Configuration Surfaces

FSMGen is strongly configuration-driven.

## Primary configuration source

The current repo-level environment/config file is:

- `perl/env.conf`

That file shows that `fsmgen` is a first-class configured program surface and that the repo preload path includes:

- `(conf fsmgen)`

So the active `fsmgen` profile matters at runtime.

## Config merge behavior

The main entrypoints merge caller-provided options with the configured `fsmgen` defaults:

- `start_from_file(...)` merges `Global->set('fsmgen')` with optional `conf => {...}`
- `top_from_tree(...)` merges `Global->set('fsmgen')` with direct `%opt`
- `top_from_string(...)` merges `Global->set('fsmgen')` with direct `%opt`

That means caller options are not the whole story. The environment/profile layer is part of the real contract.

## Config keys clearly visible in current code

The following config keys are directly visible in `perl/FSMGen.pm` and should be treated as active documented surface:

- `block_prefix`
- `_top`
- `_dp`
- `corporate_file_header`
- `default_clock_name`
- `default_async_reset_name`
- `output_directory`
- `architecture_name`
- `architecture_name_suffix`
- `instance_label_prefix`
- `state_variable`
- `sharedinfo`
- `non_standard_type_re`
- `_relationalop_re`
- `_testop`

Some of these are clearly end-user configuration points. Others are deeper internal-generation knobs. This book should continue clarifying that distinction chapter by chapter.

## Related config files

The repo also contains FSMGen-relevant configuration files such as:

- `conf/vhdl_template.conf`
- `conf/xif.conf`

Both reference `fsmgen` context-clause material, which is a strong hint that FSMGen output generation is meant to cooperate with the project’s VHDL-related templating and interface flows.

## Practical guidance

When documenting or using FSMGen, always ask:

1. what comes from the caller,
2. what comes from the `fsmgen` profile,
3. and what is synthesized internally.

That separation is essential for understanding why a given run produced a particular output.
