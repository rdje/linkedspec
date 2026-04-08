# What FSMGen Is

FSMGen is a generation-oriented subsystem that turns FSM descriptions and related hierarchy/interface declarations into structured RTL-oriented output.

At a high level, FSMGen does four kinds of work:

1. loads FSM descriptions from files, trees, or strings,
2. normalizes configuration and shared state,
3. analyzes FSM and hierarchy declarations into an internal model,
4. emits module/entity/architecture output into an output directory.

From the current code, the main public Perl entrypoints are:

- `FSMGen::start_from_file(...)`
- `FSMGen::top_from_tree(...)`
- `FSMGen::top_from_string(...)`

Those functions are the most important starting points for users because they correspond to the three main input shapes:

- a list of FSM files,
- a prebuilt Lispish/ATree structure,
- or an FSM description string.

FSMGen also exposes a plugin-facing surface in `plugin/fsmgen.plg`. That layer helps with:

- interface-object parsing,
- map and generic interpretation,
- signal/assignment helper generation,
- and adapter functions such as `fsmgen_from_string` and `fsmgen_from_tree`.

## What FSMGen is not

FSMGen is not just a text templating script.

The code makes it clear that it has real internal phases:

- initialization,
- FSM analysis,
- decision-tree walking,
- hierarchy assembly,
- data-path and top creation,
- and final file emission.

That means good FSMGen documentation needs to cover both:

- how to call it,
- and how the internal model is shaped while it runs.
