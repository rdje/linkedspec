---
id: legacy-configuration-source-contracts
title: Legacy configuration reading separates report data and templates from runtime proof
answers:
  - what do the first legacy configuration files configure
  - are conf files examples of current LinkedSpec function syntax
  - does reading lighttpd conf verify or launch a web server
  - how do timing report configurations differ from hardware templates
  - which legacy configuration ranges have been fully read
date: 2026-09-13
status: first configuration group read; director limits further historical reading to current spec/test dependencies
tags: [startup, reading, legacy, configuration]
evidence: "SUPPORTING-SOURCE-READING.1.1; activation d806aa674f8b0ae8202b78e3f8b40a1b898ede2a; exact Scope and baseline evidence in docs/tasks/SUPPORTING-SOURCE-READING.md."
reverify: "Run the three recipes in docs/knowledge/supporting-source-reading-coverage.md and bash scripts/check_repo_root_path_portability.sh; inspect the exact completed Scope ranges below for comprehension. These checks do not execute historical consumers or prove runtime compatibility."
---

# Configuration group 1 — 2026-09-13

The first group reads 24 ranges in 29 complete output windows: 1,500 physical-line
fragments /61,165 bytes, with 23 files through EOF and only lines 1–3 of
`conf/pt_cases_analysis.conf`. Its ordered range digest is
`7d85ddd590a20f2681eb68cadac6fad5e9e87b51949ec998a289ac60e799166c`.
The exact source baseline and all range identities remain in the coverage card
and owning tree. The partial case-analysis file only opens a `sections` form;
its body and closure belong to `.1.2`.

These files encode different historical applications. Most use parenthesized
records, semicolon comments, textual regular expressions, brace-delimited host
expressions/templates and occasional `seto://` references. The Lighttpd template
uses its own configuration syntax. Neither spelling is evidence that current
LinkedSpec function definitions or named arguments implement that syntax.

| Source under `conf/` | What the read source defines |
| --- | --- |
| `ambitiming.conf`, `encountiming.conf`, `magmatiming.conf` | Report-specific extraction patterns. AmbiTiming and Encounter each define timing-path/clock/point/slack/data/type fields; Encounter maps leading/trailing edges and Begin/End labels. Magma defines separator and path extraction only. |
| `dutycycled.conf` | Imported `stan_backend/by_pathtype` configuration and FSUSB0 receive/transmit classifications. Its comments distinguish reference-table algorithm 2 from algorithm 1 without such tables; transmit excludes rise and the configured maximum skew is 1000. This records configuration intent, not measured timing correctness. |
| `matrix.conf`, `peruser.conf` | Grouping sequences over report fields: matrix captures six filename components and assigns columns; per-user configuration extracts the suffix before `.rpt` and identifies candidate filenames. |
| `hold_scale_factors_to_qcmin.conf`, `n3g_scaling_factors.conf`, `lstype_long.conf` | Fourteen hold factors, eighteen corner factors and the twelve lowercase month-to-number mappings. Values are historical data, not newly validated engineering recommendations. |
| `fv_check.conf`, `network.conf` | Caller-selected design-root inputs. The former names relative verification reports and callback/field mappings; the latter selects `dc_load_netlist`, run directory `.`, input `design.ddc` and clock-gating options. |
| `nlc.conf` | Diagnostic-envelope regex; keyed capture patterns and replacement messages for netlist checks; the R2 special callback `nlc_r2_cb`. Absence of an R2 capture entry is not independently diagnosed as a defect because its special callback has separate ownership. |
| `postsyn.conf` | Report selection/splitting; section, diagnosis and library-add callback maps; capture and message tables; exclusions for informational diagnostics; TEST-283 list-to-table handling and default workbook `post_synthesis_check.xls`. |
| `fxstart.conf` | Plugin-name to configuration-name aliases, including many aliases to `stan_backend`; several old alternatives remain commented out. |
| `libview_table2ss.conf` | Eight spreadsheet format categories with foreground/background and alignment properties. |
| `easytk.conf` | Tk/Tix widget handler registry, widget categories, option/call preprocessing, command/variable patterns, skip maps, menu handling and environment search-path references. Comments identify unimplemented special handlers; consumer behavior is not inferred from spelling alone. |
| `cgi.conf`, `lispml.conf` | CGI key lists and file-to-enscript language mappings; separately, HTML entity/attribute groups and input/form aliases with `$ARGV` forwarding. The CGI file explicitly excludes its disabled `extension_action` block from HUtils configuration input. |
| `fsmgen.conf` | VHDL generation configuration: state/output naming, IEEE context, comparison/negation maps, input patterns, relative output and template names, entity/architecture filenames and an asynchronous active-low reset/rising-edge process template. |
| `fake_memmodule.conf` | Twelve buffer-allocation triples, a four-buffer-per-module limit and pin direction/size/multiplicity/type records. It is input data, not a generated hardware implementation. |
| `m2g.conf` | Thirteen generated-clock descriptors with source/port/frequency data and a separate master-clock path table. |
| `pcsally_mem.conf` | Active and commented memory-map variants, instance counts, wrapper-port mappings, technology/MBIST signals, relative output/input directories, VHDL context/header templates and clock-gate naming substitution. Commented variants and active rows remain distinct. |
| `lighttpd.conf` | A historical server template with `<server_port>`/`<server_name>` placeholders, relative document/log/alias paths, CGI interpreter mapping and digest-auth settings. Many optional modules and examples are comments; no listener, authentication workflow or server compatibility was exercised. |

# Director clarification during this reading — 2026-09-13

The director identifies these configuration files as historical material from
handwritten, Perl-only LinkedSpec, no longer applicable to FSMGEN. Further reading
should be limited to files required by current LinkedSpec tests/specifications.
`SUPPORTING-SOURCE-READING.0` owns the dependency audit and remaining-scope
disposition. The completed first group remains honestly recorded; the remaining
configuration ranges receive no reading credit and are not executed or removed.

# Interpretation and evidence boundary

The canonical path-portability fact already explains caller-selected design roots,
PATH-selected legacy tools, and the distinction between active project defaults,
caller input and operating-system examples. The fresh structural portability
check covers 14 classifier cases and five primary-command anchors; it is not a
functional test of these legacy applications. Commented optional examples do not
establish that their paths are used by a current project workflow.

All 158 supporting files still match their frozen baseline modes/blobs/current
bytes. Independent published-task reconstruction covers all 174 planned ranges;
only the first committed reading child earns physical comprehension credit.
No newly demonstrated defect arises from this group. Existing startup/backend
repair ownership remains intact. Legacy consumer execution, actual report
fixtures and modern runtime claims require their own precise scope and proof.
No RGX/PGEN compilation, server launch, hardware generation or external design
tool was required for this reading.

Related facts: [[supporting-source-reading-coverage]],
[[startup-codebase-reading-inventory]], [[repository-root-path-portability]].
