---
id: legacy-configuration-source-contracts
title: Historical Lispish application data retains narrow corpus use without further manual reading
answers:
  - do current LinkedSpec tests still parse historical conf files
  - why is further conf and TableScript source reading retired
  - does the Lispish corpus test prove complete configuration parsing
  - what do the first legacy configuration files configure
  - are conf files examples of current LinkedSpec function syntax
  - does reading lighttpd conf verify or launch a web server
  - how do timing report configurations differ from hardware templates
  - which legacy configuration ranges have been fully read
date: 2026-09-13
status: further historical conf and TableScript reading retired; existing corpus inputs and tests retained
tags: [startup, reading, legacy, configuration]
evidence: "SUPPORTING-SOURCE-READING.0 dependency/scope audit at activation 0e3423a19addad30c8f932b1f23fb270e22f1677; SUPPORTING-SOURCE-READING.1.1; activation d806aa674f8b0ae8202b78e3f8b40a1b898ede2a; exact Scope and baseline evidence in docs/tasks/SUPPORTING-SOURCE-READING.md."
reverify: "Run the supporting-source coverage recipes, then CONF_DEPENDENCY_AUDIT and CONF_CORPUS_EXTRACT below, then the focused corpus invocation. The exact subtest checks 53 conf/23 TableScript/7 EBNF inputs; no legacy application or dependency build runs."
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

# Current corpus dependency and historical-data disposition — 2026-09-13

The director clarifies that `.conf`, `.tk` and `tablescript/*.ts` were Lispish
input for day-job applications created more than twenty years ago. Their returned
ASTs were processed by obsolete Perl scripts no longer in this repository.
This is provenance/background, not a request to restore those applications.
The director also explains that these data files have limited relevance to the
current backend-neutral, multi-backend LinkedSpec language. Extension does not
imply a different parser: TableScript `.ts` here is not TypeScript.

There is still a concrete current regression dependency:

- `t/phase0_regression.t` lines 43318–43373 defines `corpus_regression`. Its first
  two datasets discover every `conf/*.conf` and `tablescript/*.ts`, respectively,
  and pass each file to `parse_with_lispish_multi($file, 1)`: 53 conf and 23
  TableScript inputs. The five `.tk` files are outside those suffix selectors.
- The helper at lines 48488–48520 obtains `LinkedSpec::get_parser('Lispish')`,
  reads the input, collects advancing parse results and stops on undefined output
  or no progress. It requires a nonempty result list. It does not invoke an
  application AST consumer, compare expected AST contents or assert complete file
  consumption. A pass is this bounded parser smoke contract.
- `tools/run_ci_local.sh` invokes the Phase 0 suite. Toolbox §6.2 extraction of
  the exact 56-line subtest and six unchanged helpers passes all six assertions:
  discovery and parse checks for 53 conf, 23 TableScript and seven EBNF inputs.
  This is one focused subtest, not full CI or full configuration validation.

The tracked-reference census covers 1,015 non-Markdown/non-lock, nonsymlink text
files in the current source/test/tool roots listed in the recipe. Fourteen matching
lines belong to five files. No shipped `.spec` refers to a historical config input.
`PathSearch` defaults to `.conf`, but its actual resolver caller passes `'spec'`
explicitly. `perl/env.conf` contains historical references; current code has no
`env.conf`/`CONF_DIR`/`HUtils` loader reference. The two doctrine scripts use
synthetic path-classification examples. No generic Tk extension/loader spelling
or historical `.tk` filename occurs in that census. Directory/suffix discovery
explains why searching only individual config filenames misses live corpus use.

Based on the director's relevance clarification, `.0` ends further manual reading
of these historical application-data files while retaining every file and test.
The 81 files under `conf/` and `tablescript/` remain exactly 8,322 fragments /
290,357 bytes. `.1.1` preserves its already completed 1,500 fragments /61,165 bytes;
`.1.2-.1.7` are explicitly superseded, with no reading or application-verification
credit. No current parser fixture is deleted or its assertion weakened.

The original 158-file/174-range inventory remains historical evidence. Current
required supporting code is 77 files /88 ranges /17,291 fragments /673,899 bytes
in fourteen groups. Authored specs `.1.17-.1.19` and EBNF `.1.20-.1.21` are next,
followed by remaining legacy-code review `.1.8-.1.16`. The authoritative language
and runtime behavior belong to current specs and their backend implementations;
obsolete application settings are not features to maintain.

The earlier Lispish no-progress/inter-form observation remains a dated fact in
[[lispish-corpus-catastrophic-backtracking]]. This scope audit does not reclassify
it, claim full-input coverage, or repair it. Every prior defect owner and remaining
startup obligation stays intact. The reference census describes repository use,
not every possible external caller. The original inventory/plan recipes are
unchanged; the tree replay now accepts explicit superseded reading nodes and does
not count them as completed. The dependency replay below independently pins the
six exact omissions, preserved completed group and fourteen current code groups.

# Reproduce current dependency and reading disposition

First run the coverage recipes in
`docs/knowledge/supporting-source-reading-coverage.md` to recover the frozen plan.
These recipes write only repository-derived scratch. Their pinned identities
require a new audit when the relevant source/reference set changes.

```bash
bash tools/project_data_run.sh python3 - <<'CONF_DEPENDENCY_AUDIT'
from pathlib import Path
import collections, hashlib, json, re, subprocess
p = Path('.linkedspec-data/scratch/support0')
p.mkdir(exist_ok=True)
paths = subprocess.check_output(['git', 'ls-files', '-z'], text=True).rstrip('\0').split('\0')
conf = sorted(x for x in paths if x.startswith('conf/'))
assert collections.Counter(Path(x).suffix for x in conf) == {'.conf': 53, '.tk': 5}
roots = {'perl', 'rust', 'dart', 'julia', 'lua', 't', 'tools', 'scripts', 'bin', 'specs', 'ebnf', '.githooks'}
names = [Path(x).name.encode() for x in conf]
pat = re.compile(rb'(?<![A-Za-z0-9_])(?:conf/|CONF_DIR|env\.conf|' + b'|'.join(map(re.escape, names)) + rb')|[\x22\x27]conf[\x22\x27]|\.conf\b|\.tk\b|[\x22\x27]tk[\x22\x27]|TK_DIR|EasyTk|Tk::|HUtils')
records, scanned = [], []
for name in paths:
    path = Path(name)
    if name.split('/')[0] not in roots or path.suffix in ['.md', '.lock'] or path.is_symlink() or not path.is_file():
        continue
    data = path.read_bytes()
    if b'\0' in data:
        continue
    scanned.append(name)
    for no, line in enumerate(data.splitlines(), 1):
        tokens = sorted(set(m[0].decode() for m in pat.finditer(line)))
        if tokens:
            records.append({'path': name, 'line': no, 'tokens': tokens, 'line_sha256': hashlib.sha256(line).hexdigest()})
assert len(scanned) == 1015
assert hashlib.sha256('\n'.join(scanned).encode()).hexdigest() == '00db120d8ef3e9cb622b8ade04bd9b2bd2eac4de8d00bb1d072864d106df443f'
assert hashlib.sha256(json.dumps(records, separators=(',', ':')).encode()).hexdigest() == 'ba27ee5973570820dc9e8bc125f2f31d1c0ceb1848302ea2cd24fd34bf8b2e9c'
assert len(records) == 14 and len({r['path'] for r in records}) == 5
plan = json.loads(Path('.linkedspec-data/scratch/support370/plan.json').read_text())
tree = Path('docs/tasks/SUPPORTING-SOURCE-READING.md').read_text()
nodes = dict(re.findall(r'^- ID: `([^`]+)`\n(.*?)(?=^- ID: |^## |\Z)', tree, re.M | re.S))
historical, required = [], []
for index, g in enumerate(plan, 1):
    node = nodes[g['id']]
    scope = re.search(r'^  Scope: (.+)$', node, re.M)[1]
    assert scope == '; '.join(f"`{r['path']}` lines {r['start']}-{r['end']}" for r in g['ranges'])
    assert g['range_sha256'] in node
    status = re.search(r'^  Status: `([^`]+)`$', node, re.M)[1]
    if index == 1:
        assert status == 'done'
    elif index <= 7:
        assert status == 'superseded' and 'SUPPORTING-SOURCE-READING.0' in node
    else:
        assert status in ['pending', 'active', 'done']
    (historical if index <= 7 else required).append(g)
assert len(required) == 14
assert sum(len(g['ranges']) for g in required) == 88
assert len({r['path'] for g in required for r in g['ranges']}) == 77
assert sum(g['fragments'] for g in required) == 17291
assert sum(g['bytes'] for g in required) == 673899
assert sum(g['fragments'] for g in historical) == 8322
assert sum(g['bytes'] for g in historical) == 290357
report = {'scanned_files': len(scanned), 'reference_lines': records,
          'historical_files': sorted({r['path'] for g in historical for r in g['ranges']}),
          'superseded_reading_groups': [g['id'] for g in historical[1:]],
          'preserved_reading': {'groups': 1, 'fragments': 1500, 'bytes': 61165},
          'required_groups': [g['id'] for g in required], 'required_files': 77,
          'required_ranges': 88, 'required_fragments': 17291, 'required_bytes': 673899}
(p / 'audit.json').write_text(json.dumps(report, indent=2) + '\n')
print('PASS 1015-file reference census: 14 exact lines in five files; 53 conf and 23 TableScript corpus inputs retained; 81 historical data files excluded from further manual reading; 14 required groups/77 files/88 ranges/17291 fragments/673899 bytes.')
CONF_DEPENDENCY_AUDIT
```

```bash
bash tools/project_data_run.sh python3 - <<'CONF_CORPUS_EXTRACT'
from pathlib import Path
import hashlib, json, re
p = Path('.linkedspec-data/scratch/support0')
p.mkdir(exist_ok=True)
source = Path('t/phase0_regression.t').read_bytes()
assert hashlib.sha256(source).hexdigest() == '6b7fc16ee751ab02f2ae06109cfe4fb2516aa29b22c7a5ba3b2f77827a98a82a'
s = source.decode()
block = re.search(r"^subtest 'corpus_regression' => sub \{\n.*?^\};\n", s, re.M | re.S)[0]
helpers, rows = [], []
for name in ['slurp', 'normalize_error', 'discover_dir_files_by_suffix', 'parse_with_linkedspec', 'parse_with_lispish_multi', 'run_with_exit_trapped']:
    m = re.search(r'^sub ' + name + r' \{\n.*?^\}\n', s, re.M | re.S)
    assert m, name
    helpers.append(m[0])
    rows.append({'name': name, 'start': s[:m.start()].count('\n') + 1, 'lines': m[0].count('\n'), 'sha256': hashlib.sha256(m[0].encode()).hexdigest()})
header = "use 5.010;\nuse strict;\nuse warnings;\nno warnings 'once';\nuse Test::More;\nuse File::Spec;\nuse File::Basename qw(basename);\nuse Cwd qw(abs_path);\nuse LinkedSpec;\nmy $Bin = abs_path('t');\n"
(p / 'corpus.t').write_text(header + '\n'.join(helpers) + '\n' + block + '\ndone_testing();\n')
rows.append({'name': 'corpus_regression', 'start': s[:s.index(block)].count('\n') + 1, 'lines': block.count('\n'), 'sha256': hashlib.sha256(block.encode()).hexdigest()})
(p / 'extraction.json').write_text(json.dumps(rows, indent=2) + '\n')
print('PASS exact corpus subtest and six helpers extracted; runtime invocation is separate.')
CONF_CORPUS_EXTRACT
```

```bash
bash tools/project_data_run.sh perl -Iperl .linkedspec-data/scratch/support0/corpus.t > .linkedspec-data/scratch/support0/corpus.tap 2>&1
```

Inspect complete TAP: six inner `ok` assertions, `ok 1 - corpus_regression`,
`1..1`, and process exit 0. Do not interpret this focused result as canonical CI
or full-input/configuration-AST correctness proof.

Related facts: [[supporting-source-reading-coverage]],
[[startup-codebase-reading-inventory]], [[repository-root-path-portability]].
