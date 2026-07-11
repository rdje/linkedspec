# Shipped Specs and Corpora

The repository ships real specs and real corpora, not only toy examples.

This matters for two reasons:

- users can learn from realistic `.spec` files,
- maintainers can refactor LinkedSpec against material that exercises the system outside tiny examples.

The current repository does not have one single `corpus/` directory. Instead, the shipped material is spread across:

- `specs/`
- `noncore/plugin/` (relocated legacy `.plg` corpus)
- `conf/`
- `tablescript/`
- `ebnf/`
- `t/phase0_regression.t`

That spread reflects the project history. Some artifacts are current core examples. Some are legacy transition material. Some are fixture-like real-world inputs. The book should be transparent about those roles rather than pretending all files have the same status.

## Why that matters

This gives LinkedSpec a stronger quality loop:

- compile real shipped specs
- run regression checks across representative inputs
- keep behavior grounded in actual usage

It also prevents a common parser-project failure mode: a parser can look clean against handpicked toy grammars while quietly breaking on recursive delimiters, nested language fragments, escaped strings, real config files, and legacy data formats.

## Important repository areas

- `specs/`
- `t/phase0_regression.t`
- `noncore/plugin/` (relocated legacy `.plg` corpus)
- `conf/`
- `tablescript/`
- `ebnf/`

## `specs/`

`specs/` is the main shipped `.spec` directory.

At the time of this book slice, it contains these public examples and regression inputs:

| File | Main entry rule | What it demonstrates |
| --- | --- | --- |
| `BNF.spec` | `description` | BNF-style token and grouping experiments, with visible debug output. |
| `DT.spec` | `dtree` | Decision-tree-like syntax, recursive groups, and debug-print token readers. |
| `Lispish.spec` | `Lispish` | Nested parenthesized AST parsing, recursive structures, strings, comments, and typed payload construction. |
| `ds_vhistory.spec` | `vhistory` | Parsing verbose version-history output with object/branch/version aggregation. |
| `ebnf.spec` | `grammar_file` | Parsing EBNF-style grammar definitions, includes, annotations, operators, regexes, and rule references. |
| `hlink_substitution.spec` | `substitute_top` | Substitution syntax, bracket/brace nesting, and word-item accumulation. |
| `ifelse.spec` | `program` | Small control-flow grammar experiment for `if`, `elsif`, `else`, and `while` blocks. |
| `lib_reader.spec` | `lib_file` | Library-style grouped attributes, nested groups, scalar attributes, and comma-list attributes. |
| `operators_try.spec` | `top_expression` | Operator tokenization and grouping experiments. |
| `portmap.spec` | `portmap` | Hardware-oriented port-map fragments, concatenations, bit/slice classification, and constants. |
| `pplugin.spec` | `pplugin_top` | Legacy `.plg` subdefinition parsing and plugin-body capture. |
| `regdef.spec` | `regdef_top` | Register-definition and field-definition extraction. |
| `sdce.spec` | `sdc_esplit` | SDC-style split flows around `get_port` / `get_pin` forms and brace-aware capture. |
| `simenv.spec` | `top` | Simulation-environment config blocks, multiline values, substitutions, comments, nested delimiters, and helper-form iterable debug output. |
| `tablegrep.spec` | `grep` | Boolean expression parsing for table filtering, including `AND`, `OR`, grouping, and regex terms. |
| `tclite.spec` | `tcl_script` | Tcl-like syntax experiment with commands, quotes, comments, substitutions, and braces. |
| `tkgui.spec` | `sub_gui_list` | Small GUI-subdefinition parser with captured inner bodies. |
| `verilog.spec` | `verilog_file` | Minimal placeholder surface, not a mature shipped parser today. |
| `vhdl.spec` | `vhdl_file` | The largest shipped `.spec`: VHDL-oriented library/use/entity/architecture/package/configuration/declaration parsing. |
| `spec.spec` | `spec_file` | Self-hosted grammar: LinkedSpec parsing its own `.spec` language through the DSL itself. Compiles at `language_agnostic_ready_ratio == 1.0000`. |

The important point is not that every file has equal maturity. It does not.

The important point is that these files collectively exercise the system:

- top-level rule paragraphs,
- regex-only token rules,
- recursive delimiter rules,
- lifecycle blocks,
- action helper DSL,
- raw-host-language compatibility seams (a Perl reference-backend concern),
- generated descriptor metadata,
- dependency-regex dispatch,
- runtime parser invocation,
- real nested return payloads.

The manifest-backed 105-fixture Rust oracle corpus tracks this maturity incrementally, including six exhaustive
current-surface capability sources shared unchanged by every implemented backend.
Its exact case list lives in `rust/linkedspec-runtime/tests/corpus/manifest.json`.
Representative cases include `lib_reader_sattribute` and `lib_reader_cattribute`;
`portmap_bare`, `portmap_bit`, `portmap_slice`, `portmap_constant`, and
`portmap_concatenation`; `ebnf_expression_rules` and `ebnf_logging_annotation`;
`hlink_raw_string`, `hlink_raw_escaped_brackets`, `hlink_curly_brace`,
`hlink_bracket_body`, and `hlink_mixed_bracket_brace`;
terse-language fixtures such as `terse_11_4_nested_mixed_value_path_assignment` and
`terse_15_2_3_bare_value_reads_and_case_labels`, plus
`terse_12_3_hash_tree_traversal_receiver_blocks` and
`terse_13_3_array_tree_traversal_receiver_blocks`; and four `spec.spec` smokes:
`spec_spec_minimal_rule`, `spec_spec_action_edge`, `spec_spec_user_function_definition`,
and `spec_spec_comment_skip`; plus the narrow legacy safety smokes
`regdef_nested_register_fields`, `tablegrep_simple_term`, `simenv_multiline_value`,
`vhdl_library_use`, `ds_vhistory_version_entry`, `pplugin_empty`, and `tkgui_empty`;
plus the recursive top-rule/body value fixtures `top_rule_body_recursion_sexpr`,
`top_rule_lx_recursion_nested`, and `top_rule_lx_recursion_sequence`.
Those fixtures verify grouped attributes, port-map scalar classification and
concatenation, EBNF payload extraction, self-hosted `.spec` grammar AST shape, and
minimal RTL/plugin/legacy parser reachability, hlink delimiter/link payload parity, regdef accumulator shape, and
recursive top-rule value parity against the Perl reference output. `BNF.spec`,
`DT.spec`, `ifelse.spec`, and `operators_try.spec` remain useful diagnostic/debug-print
examples, but their probed inputs currently return Perl `null`, so they are not promoted
as semantic output fixtures. Richer `pplugin`, `tkgui`, `sdce`, recursive `tablegrep`,
single-line `simenv`, VHDL port-clause, `ds_vhistory` branch, and placeholder `verilog`
candidates remain explicit Rust parity follow-up blockers.

## Current maturity reading

The mature center of gravity is currently:

- `Lispish.spec`
- `ebnf.spec`
- `vhdl.spec`
- `ds_vhistory.spec`
- `tablegrep.spec`
- `simenv.spec`
- `portmap.spec`
- `pplugin.spec`
- `tclite.spec`
- `tkgui.spec`
- `hlink_substitution.spec`
- `lib_reader.spec`
- `sdce.spec`
- `regdef.spec`

These are actively referenced by the large phase0 regression suite for helper-flow migration, descriptor metadata, parser smoke checks, or corpus checks.

Smaller experimental or historical specs still matter, but they should be read with more caution:

- `BNF.spec`
- `DT.spec`
- `ifelse.spec`
- `operators_try.spec`
- `verilog.spec`

That does not mean they are useless. It means a reader should not infer the same product-level completeness from every shipped `.spec`.

The long-term direction is to keep promoting shipped specs from historical/experimental material into well-documented, helper-DSL-first examples.

## Examples of using shipped specs

These `.spec` files are the backend-neutral contract; any LinkedSpec backend can run
them. The runnable examples below show the **Perl reference backend's** surface
(`use LinkedSpec; LinkedSpec::get_parser(...)`).

Load the Lispish parser:

```perl
use LinkedSpec;

my $parser = LinkedSpec::get_parser('Lispish');

my $input = '(a (b c) d)';
my $ast = $parser->(\$input);
```

For the detailed rule-by-rule explanation, read [`Lispish.spec` Walkthrough](lispish-spec-walkthrough.md).

Load the VHDL parser:

```perl
use LinkedSpec;

my $parser = LinkedSpec::get_parser(
  'vhdl',
  top_rule => 'vhdl_file',
);
```

Ask for descriptor introspection instead of a parser:

```perl
my $descr = LinkedSpec::get_parser(
  'ebnf',
  return_descriptor => 1,
);

my $summary = $descr->{meta}{action_rewriter_migration};
```

That descriptor mode is heavily used by regression tests because it exposes rule metadata, dependency refs, compiled order, and ActionIR migration status.

`simenv.spec` is now regression-locked as compatibility-surface clean: block aggregation, variable/value readers, delimiter readers, substitution readers, fatal exits, and debug iteration all use helper-form ActionIR paths while preserving the shipped begin/end AST smoke behavior.

For the detailed rule-by-rule explanation of the shipped grammar-file parser, read [`ebnf.spec` Walkthrough](ebnf-spec-walkthrough.md).

## `noncore/plugin/` (relocated legacy `.plg` corpus)

The repository used to ship a top-level `plugin/` directory of legacy `.plg` files. As of the `NONCORE-QUARANTINE` and `LEGACY-VHDL-RETIRE` work it is **no longer part of the active product tree**: the root `plugin/` directory is gone, the 13 surviving `.plg` files live under `noncore/plugin/`, and the current core `t/phase0_regression.t` gate is green (`1..1028`) without the root plugin corpus.

> **Perl reference implementation.** The `.plg` plugin system, the `PPlugin` runtime,
> and the package-owner migration it once drove are part of the **Perl reference
> backend's** legacy transition. They are **not** part of the backend-neutral `.spec`
> contract — a new backend (Rust, Dart, Julia, Lua, ...) implements none of it. The detail
> is kept only as a faithful record of the reference implementation's plugin retirement.

Two passes resolved the legacy island:

- **Deleted** (`LEGACY-VHDL-RETIRE`): the Perl-only, non-portable VHDL/RTL/FSM-generation subsystem — `RTLUtils`, `FSMGen`, `VHDL::ConstantEval`, and the six `.plg` files that depended exclusively on them — had no cross-variant counterpart, so it was removed rather than ported.
- **Relocated to `noncore/`** (`NONCORE-QUARANTINE`): everything proven unreachable from the `.spec` engine — the remaining domain-utility owners (`HTTP::FileAccess`, `HTML::PathLinks`, `InteractivePrompt`, `Text::VariableSubstitution`, `MSOffice::Excel`, `QC::Flow`, `QC::Summary`, `QC::TclInterconn`, `Table::GenericFilter`, `Timing::SetupHold`, `Timing::StanBackend`, `Timing::StanOmap2430cBackend`, plus the flat domain `.pm`) and the 13 surviving `.plg` — was `git mv`'d into `noncore/`, layout preserved. `noncore/README.md` is the parked-fate ledger (refactor / port / publish / delete each later).

What remains relevant to LinkedSpec proper:

- `specs/pplugin.spec` still parses `.plg` *syntax* — it is a shipped `.spec` example of recursive bracket-matching, independent of whether any `.plg` files ship,
- the public facade still exposes the **deprecated** plugin entrypoints (`run_plugin`, `get_plugin`, `register_plugin`, ...) as transition machinery,
- the `.spec` parser, runtime, ActionIR helper semantics, and diagnostics — the actual product — have **zero** functional dependency on any of the relocated or deleted code.

Do not read the former `plugin/` corpus as a recommendation to build new LinkedSpec functionality around dynamic `.plg` loading. The architectural direction is to keep LinkedSpec focused on `.spec` parsing, runtime execution, ActionIR helper semantics, and diagnostics.

## `conf/`

`conf/` contains real configuration-like inputs.

The regression suite currently treats those files as corpus material through the Lispish-oriented runtime path.

That is useful because config files tend to contain varied strings, nesting, punctuation, and ad hoc syntax. They are good at exposing parser assumptions that do not show up in tiny examples.

## `tablescript/`

`tablescript/` contains `.ts` table-script material.

The regression suite also treats this as corpus material through the Lispish-oriented runtime path.

This directory is valuable because it gives LinkedSpec a second set of non-`.spec` real-world-ish inputs to parse during broad regression checks.

## `ebnf/`

`ebnf/` contains `.ebnf` files such as:

- `ebnf.ebnf`
- `regex.ebnf`
- `json.ebnf`
- semantic/return annotation grammars

The regression suite parses this directory with `ebnf.spec` and expects array-shaped AST output.

That makes `ebnf/` a good paired corpus:

```text
specs/ebnf.spec parses ebnf/*.ebnf
```

This pairing is important because it tests both the shipped EBNF parser and realistic EBNF-like grammar inputs.

## `t/phase0_regression.t`

`t/phase0_regression.t` is the main behavioral lock.

It is large because it locks many different project promises:

- public facade and lazy-owner behavior,
- parser factory behavior,
- compile/runtime diagnostics,
- DSL helper lowering,
- descriptor metadata,
- shipped spec helper migration,
- smoke tests for selected parsers,
- corpus parsing over `conf/`, `tablescript/`, and `ebnf/` (the legacy `.plg` corpus was relocated to `noncore/` and no longer participates in the core gate),
- trace behavior and runtime-context behavior.

Examples of shipped-material checks include:

- Lispish nested AST smoke checks,
- VHDL invariant smoke checks,
- EBNF rule-name smoke checks,
- portmap classification checks,
- pplugin and tkgui parser smoke checks,
- helper-flow migration checks across many shipped specs,
- corpus regression over `.conf`, `.ts`, and `.ebnf` files (the `.plg` corpus moved to `noncore/`).

## Local CI relationship

The local CI script is:

```sh
tools/run_ci_local.sh
```

It treats the following directories as tracked CI inputs:

- `.github/workflows`
- `tools`
- `specs`
- `conf`
- `tablescript`
- `ebnf`
- `perl`
- `t`

It also checks for untracked files in those CI input areas, runs syntax checks, and runs:

```sh
prove -v -Iperl t/phase0_regression.t
```

That means shipped material is not just documentation decoration. It is part of the quality gate.

## How to read the shipped material

Use this reading order:

1. Start with [`Lispish.spec` Walkthrough](lispish-spec-walkthrough.md) for a compact recursive AST parser.
2. Read [`ebnf.spec` Walkthrough](ebnf-spec-walkthrough.md) to see grammar parsing, annotations, return payloads, and the `ebnf/*.ebnf` corpus path.
3. Read [`tablegrep.spec` Walkthrough](tablegrep-spec-walkthrough.md) for a boolean expression parser with recursive grouping and operator detection.
4. Read [`portmap.spec` Walkthrough](portmap-spec-walkthrough.md) for a VHDL/Verilog port-map parser with single-regex multi-classification.
5. Read [`pplugin.spec` Walkthrough](pplugin-spec-walkthrough.md) for recursive bracket-matching with string-literal awareness (note: `.plg` is legacy transition material).
6. Read `vhdl.spec` to see a larger real-domain grammar with many nested rule families.
7. Read `t/phase0_regression.t` when you want to understand what behavior is locked.

## Documentation obligation

The book should eventually give each important shipped spec its own walkthrough.

For each major shipped spec, the public docs should explain:

- what input language or format it targets,
- what top-level rule to use,
- what output shape to expect,
- which helper DSL families it demonstrates,
- which parts are mature and which are historical,
- what regression tests currently lock.

That work is not complete yet. This chapter is the public map and maturity guide; deeper per-spec walkthroughs should follow as the book continues to grow.
