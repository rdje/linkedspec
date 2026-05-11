# Shipped Specs and Corpora

The repository ships real specs and real corpora, not only toy examples.

This matters for two reasons:

- users can learn from realistic `.spec` files,
- maintainers can refactor LinkedSpec against material that exercises the system outside tiny examples.

The current repository does not have one single `corpus/` directory. Instead, the shipped material is spread across:

- `specs/`
- `plugin/`
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
- `plugin/`
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

The important point is not that every file has equal maturity. It does not.

The important point is that these files collectively exercise the system:

- top-level rule paragraphs,
- regex-only token rules,
- recursive delimiter rules,
- lifecycle blocks,
- action helper DSL,
- raw-Perl compatibility seams,
- generated descriptor metadata,
- dependency-regex dispatch,
- runtime parser invocation,
- real nested return payloads.

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

## `plugin/`

`plugin/` contains legacy `.plg` files.

Architecturally, this is transition material, not the future identity of LinkedSpec.

It is still important because:

- `pplugin.spec` parses `.plg` files,
- plugin compatibility remains publicly visible in the current facade,
- regression checks still prove legacy plugin discovery and parsing behavior where needed,
- shipped `.plg` files now avoid direct `PPlugin->get(...)` and `LinkedSpec::get_plugin(...)` helper lookups; migrated helper reuse goes through explicit package owners, while package-level code can still inject or default dynamic resolution when it is truly needed,
- clearer non-plugin/domain owners such as `HTTP::FileAccess`, `InteractivePrompt`, `HTML::PathLinks`, `Text::VariableSubstitution`, `VHDL::ConstantEval`, `MSOffice::Excel`, `QC::Flow`, `QC::Summary`, `QC::TclInterconn`, `FSMGen`, `Timing::SetupHold`, `Timing::StanBackend`, `Timing::StanOmap2430cBackend`, and `Table::GenericFilter` now carry real behavior that used to live in `.plg` files,
- extracted wrappers are not permanent by default; `plugin/string.plg`, `plugin/cgi.plg`, `plugin/genericfilter.plg`, `plugin/msoffice.plg`, `plugin/vhdconst_eval.plg`, and `plugin/yesno.plg` have been removed now that their package owners handle all repo-owned usage directly,
- package-backed helper subdefs are removable even when their containing legacy action file remains, and real actions can move once a package owner can carry the behavior; `HTTP::FileAccess::print_file_links_for_conf(...)`, `HTTP::FileAccess::run_lighttpd_for_conf(...)`, and `HTTP::FileAccess::run_httpd_for_conf(...)` now own the former `http` / `lighttpd` / `httpd` actions, so `plugin/http.plg`, `plugin/lighttpd.plg`, and `plugin/httpd.plg` are gone,
- private helper subdefs inside still-shipped legacy action files can move too; `plugin/qc_summary.plg` still exposes `qc_summary`, but the former `qc_summary_merge` helper is now `QC::Summary::append_merged_rows(...)` rather than a dynamic plugin registration,
- larger mixed legacy action files can move one private helper cluster at a time; `plugin/qcflow.plg` still exposes `glc_xcel2hm`, but the former `qc_pushonce`, `qc_budget_check`, `qc_budget_check_01match_code`, `qcflow_filter_handler`, `qcflow_clock_ctsinfo`, `qcflow_links_n_qclog`, and `qcflow_qclogdata` helpers are now `QC::Flow::push_once(...)`, `QC::Flow::budget_check(...)`, `QC::Flow::budget_check_single_or_zero_match(...)`, `QC::Flow::filter_handler(...)`, `QC::Flow::clock_cts_info(...)`, `QC::Flow::write_qclog_links(...)`, and `QC::Flow::prepare_qclog_data(...)`, while the former `tcl4interconn`, `tcl4fanx`, and `get_fanxinfo` helper bodies are now `QC::TclInterconn::append_interconnect_tcl(...)`, `load_fanx(...)`, and `fanx_info(...)` for repo-owned QC flow calls rather than dynamic plugin lookups, and the old standalone `plugin/tcl4interconn.plg` wrapper is gone,
- helper families shared across legacy action files can move too; `plugin/setup_hold_tmax_tmin.plg` still exposes its visible action, the obsolete `plugin/tssio.plg` wrapper is gone, and their former timing helper subdefs plus the visible `tssio` report body now live in `Timing::SetupHold` rather than the dynamic plugin registry,
- setup and formatting helpers reused inside legacy action files can move too; `plugin/stan_backend.plg`, `plugin/skew.plg`, and `plugin/duty_cycle_degradation.plg` still expose visible actions, but the former `stan_backend_start` setup helper now lives in `Timing::StanBackend::start(...)`, and the former `minmax_clockmx_cellcode` clock-matrix formatter now lives in `Timing::StanBackend::clock_matrix_cell_code(...)` rather than the dynamic plugin registry,
- private helper families can also rename the callable package API while preserving historical file strings; `plugin/stan_omap2430c_backend.plg` still exposes its visible actions, but its former `stafrequency` callback, `freqency_detailed` helper family, `potential_fp` / `questionable_paths` / `freqency_summary` report writers, `drive_tckdelays` writer, `drive_nopath_check` / `nopath_check` pair, and `portiming` traversal callback now live in `Timing::StanOmap2430cBackend` under corrected names such as `collect_sta_frequency(...)`, `write_potential_fp(...)`, `write_questionable_paths(...)`, `write_frequency_summary(...)`, `write_tck_delays(...)`, `write_no_path_check(...)`, `record_no_path_check(...)`, and `filter_port_timing_paths(...)`,
- parser lookup is no longer treated as a plugin action inside the shipped project; repo-owned callers use `LinkedSpec::get_parser(...)` directly, and the old `plugin/spec.plg` `_get_parser` shim is gone,
- generic dynamic callback lookup is no longer hidden behind the old `plugin/plugin.plg` action either; `FSMGen::getop_plugin_list(...)` now owns that parser directly, the obsolete `plugin/fsmgen.plg::getop_plugin_list` helper wrapper is gone, and that owner preserves the default `LinkedSpec::get_plugin(...)` resolver plus no-op fallback,
- small utility wrappers are removed when a normal package owner is clearer; the old `plugin/table.plg` wrapper is gone, remaining callers use `Table::list2table(...)` directly, and the unused `table_2ss` action is not preserved as a legacy registration,
- small RTL utility helpers can move the same way; the old `get_log2` helper is gone from the `.plg` registry, and fake-memory / wrapper-generation callers use `RTLUtils::ceil_log2(...)` directly for address-width sizing. VHDL header/context-clause generation now follows that package-owner path too through `RTLUtils::add_header_n_context_clause(...)`, and the obsolete `add_header_n_context_clause` helper wrapper is gone from `fsmgen.plg` too,
- Office automation helpers follow the same rule; the old `plugin/msoffice.plg` wrapper is gone, and `spyglass_waive` calls `MSOffice::Excel::start()` directly,
- VHDL constant helpers follow the same rule; the old `plugin/vhdconst_eval.plg` wrapper is gone, and MBIST/register-test callers use `VHDL::ConstantEval` directly,
- interactive prompt helpers follow the same rule and have already graduated out of the temporary `Plugin::*` scaffold; the old `plugin/yesno.plg` wrapper is gone, and FX environment comparison code uses `InteractivePrompt::yes_no(...)` directly,
- the migration plan needs real legacy inputs so compatibility-removal decisions are grounded.

Do not read `plugin/` as a recommendation to build new LinkedSpec functionality around dynamic `.plg` loading. The current architectural direction is to keep LinkedSpec focused on `.spec` parsing, runtime execution, ActionIR helper semantics, and diagnostics.

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
- corpus parsing over `plugin/`, `conf/`, `tablescript/`, and `ebnf/`,
- trace behavior and runtime-context behavior.

Examples of shipped-material checks include:

- Lispish nested AST smoke checks,
- VHDL invariant smoke checks,
- EBNF rule-name smoke checks,
- portmap classification checks,
- pplugin and tkgui parser smoke checks,
- helper-flow migration checks across many shipped specs,
- corpus regression over `.plg`, `.conf`, `.ts`, and `.ebnf` files.

## Local CI relationship

The local CI script is:

```sh
tools/run_ci_local.sh
```

It treats the following directories as tracked CI inputs:

- `.github/workflows`
- `tools`
- `specs`
- `plugin`
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
3. Read `vhdl.spec` to see a larger real-domain grammar with many nested rule families.
4. Read `tablegrep.spec`, `portmap.spec`, and `sdce.spec` for focused domain-specific parsers.
5. Read `pplugin.spec` only with the architecture caveat that `.plg` is legacy transition material.
6. Read `t/phase0_regression.t` when you want to understand what behavior is locked.

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
