# Quick Start

This chapter gives the shortest honest path into FSMGen.

## 1. Call the Perl API with a string

```perl
use FSMGen;

my $fsm_source = <<'FSM';
# Replace this illustrative body with your actual FSM source.
FSM

FSMGen::top_from_string(
  $fsm_source,
  _top => 'demo_top',
  output_directory => 'out/fsmgen',
);
```

`top_from_string(...)` is the simplest API when your source already exists in memory.

## 2. Call the Perl API with files

```perl
use FSMGen;

FSMGen::start_from_file(
  ['control_a.fsm', 'control_b.fsm'],
  conf => {
    output_directory => 'out/fsmgen',
  },
);
```

`start_from_file(...)` is the simplest entrypoint when your source is already organized as `.fsm` files.

## 3. Understand what the entrypoint does

All three main entrypoints eventually follow the same broad path:

- load or accept parsed FSM input,
- merge config,
- initialize global state,
- analyze FSM/top content,
- generate output files.

## 4. Expect generated files, not just in-memory results

FSMGen is generation-oriented. The normal successful outcome is not only an in-memory structure, but emitted module/entity/architecture files under the configured output directory.

## 5. Know the first files to read next

After your first successful run, the next chapters to read are:

- [Configuration Surfaces](./configuration.md)
- [Inputs And Entrypoints](./inputs-and-entrypoints.md)
- [Generated Output](./generated-output.md)
