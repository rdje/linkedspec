# Generated Output

FSMGen is fundamentally an output generator.

## Output directory

The generated files are written under the configured:

- `output_directory`

`drive_modules(...)` creates that directory if needed and then writes per-module output beneath it.

## Per-module layout

For each module, FSMGen currently creates a directory named after the module and then writes generated files into that directory.

From the current code, output naming is influenced by helpers such as:

- `get_entity_file_name(...)`
- `get_architecture_file_name(...)`
- `get_entity_file_description(...)`
- `get_architecture_file_description(...)`

## Top vs non-top emission

FSMGen treats top-level modules differently from already assembled non-top modules.

Current high-level rule:

- non-top modules may reuse preassembled strings stored in the shared model,
- the top module is more explicitly driven through generation helpers such as `drive_architecture(...)` and the surrounding entity/component emission path.

## Supporting output features

The code also shows support for:

- corporate/file headers,
- context-clause insertion,
- architecture naming,
- instance-label prefixes,
- generated signal declarations,
- generated assignments,
- generated constants,
- and module instantiation blocks.

## Why this matters for users

When an FSMGen run looks wrong, the bug is often not in the final write call. It is usually upstream in one of these areas:

- interface inference,
- size propagation,
- map/override handling,
- top aggregation,
- or generated local-signal creation.

That is why the model chapters matter just as much as the output chapter.
