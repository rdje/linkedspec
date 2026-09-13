---
id: current-supporting-grammar-dependencies
title: Current supporting reading retains three grammar dependencies and preserves historical application fixtures
answers:
  - which shipped specs are current compiler or runtime grammar dependencies
  - should startup reading continue through historical application specs and noncore modules
  - how did the historical spec configuration and Perl application flow work
  - do historical EBNF corpus files implement the future EBNF frontend
  - why is pplugin spec still included in supporting reading
  - did the noncore quarantine lose a module since its initial relocation
  - where is the current three grammar supporting reading scope verified
date: 2026-09-13
status: current dependency disposition; all three required grammar groups physically read, independent closeout pending
tags: [startup, reading, grammar, legacy, dependencies, continuity]
evidence: "SUPPORTING-SOURCE-READING.4; activation 5faaf61b9a5c56f18a01dde2c655f176b2828d19; current loader inspection and descriptor-only probe; NONCORE-QUARANTINE and initial relocation 2baddbd56."
reverify: "Run the original inventory/plan/tree recipes in supporting-source-reading-coverage.md, then CURRENT_SUPPORTING_SCOPE and CURRENT_GRAMMAR_DESCRIPTORS below. Inspect the named loader sites if source identities change; these checks grant no physical reading or full runtime signoff."
---

# Director scope and current grammar roles

The director explains that the historical application flow used a `.spec`, an
optional Lispish `.conf`, and a separate Perl script to run the grammar, load its
configuration and walk or execute the returned AST. Conf/Tk/TableScript files were
Lispish input for old work activities. `tclite.spec` modeled basic Tcl constructs;
a separate, now-absent Perl script supplied interpretation. The director explicitly
asks that work focus on today's backend-neutral, multi-backend LinkedSpec path.

Historical provenance alone does not retire a present implementation dependency.
Canonical grammar/transition owners and current source references give this scope:

| Retained grammar | Evidence and boundary |
| --- | --- |
| `specs/spec.spec` | ADR0012 and [[spec-spec-self-hosted-grammar]] retain it as the self-hosted language owner. `perl/LinkedSpec/BootstrapSpec.pm` lines19–83 derives and compiles its repository-relative source for the secondary/bootstrap comparison path. Canonical corpus mirrors are separately maintained. |
| `specs/user_function_definition.spec` | `perl/LinkedSpec/UserFunctionRegistry.pm` lines135–200 builds the function-definition parser from this file through `LinkedSpec::Get` with its selected top rule. Other backends have corresponding parser implementations; their references do not imply each host loads this file at runtime. |
| `specs/pplugin.spec` | `perl/PPlugin.pm` lines182–196 lazily requests `get_parser('pplugin')`. It is a callable compatibility dependency of transition machinery, not the target architecture or a portable `.plg` execution contract. |

The current shipped-spec reference census and inspected loader/test contexts
distinguish example use from implementation input. In particular,
`rust/linkedspec-core/src/parser.rs` line1920 loads `operators_try.spec` inside a
test; `rust/linkedspec-runtime/src/engine.rs` line8194 mentions `tablegrep.spec`
in a comment explaining a helper. The oracle generator uses Lispish and EBNF as
corpus cases. The other eighteen shipped specs remain historical application,
example or regression material and receive no further manual reading here.

The seven `ebnf/*.ebnf` files are retained grammar/corpus data. Current references
show no runtime file loader for these annotation/grammar files. Existing corpus
smoke remains; it does not make these files current language implementation
owners. The accepted future EBNF-like frontend in
[[spec-language-self-containment-and-ebnf-profile]] is a separate direction and
remains unimplemented. This scope decision neither cancels nor implements it.

# Quarantined application code remains preserved

`docs/tasks/NONCORE-QUARANTINE.md` records closure of static and dynamic
core-to-domain dependencies. The current package-name census inspects all 35
quarantined module names across maintained source/tool/test roots; the 26 candidate
contexts are Lispish grammar/rule/CLI names, not module loads. This reconciles the
existing dependency closure rather than granting exhaustive physical reading of
old applications. External callers are outside this repository census.

Initial relocation `2baddbd56` and the current tree have exactly the same 49 paths:
35 `.pm` modules, 13 `.plg` files and `noncore/README.md`. The historical statement
of 36 modules is an overcount already present at relocation, not evidence of a
lost module. Preserve the historical record and the corrected dated measurement.
Plugin policy remains in [[pplugin-pluginbridge-transition-machinery]]: the adapter
does not automatically load `noncore/plugin/`, and deferred removal policy remains
deferred. No quarantined source or fixture is deleted or executed by this audit.

# Exact current reading and verification limits

All 158 original sources and all 174 original Scope/digest ranges remain exact.
Completed historical `.1.1` retains its 1,500 fragments/61,165 bytes and 29-window
evidence. `.0` supersedes `.1.2-.1.7`; `.4` additionally supersedes `.1.8-.1.16`
and `.1.20-.1.21`. The mixed spec groups retain original inventory but add exact
Required reading scope overlays. Other intervals in those groups are omitted
without reading credit. The three required files total 629 fragments/96,781 bytes:

| Leaf | Required inclusive ranges | Fragments | Bytes |
| --- | --- | ---: | ---: |
| `.1.17` | pplugin.spec1–33; spec.spec1–146 | 179 | 26,444 |
| `.1.18` | spec.spec147–226; user_function_definition.spec1–115 | 195 | 62,203 |
| `.1.19` | user_function_definition.spec116–370 | 255 | 8,134 |

These three physical reading groups were pending at the .4 scope checkpoint.
Subsequent `.1.17-.1.19` complete all five required ranges; independent `.3`
reconciliation remains pending.
Current physical coverage and exact window replay live in
[[supporting-source-reading-coverage]].
Descriptor compilation passes for all three named grammars: readiness1.0000,
zero blocked rules and zero compatibility-surface rules; `PPlugin.pm` remains
unloaded. This is compilation/descriptor evidence, not full parsing, plugin
execution, cross-backend parity or canonical CI. The earlier six-assertion corpus
result stays dated in [[legacy-configuration-source-contracts]]. No dependency
build or runtime/test/gate change occurs; all defect owners and later startup
reading, formal book, policy and verification requirements remain.

# Reproduce scope and descriptor evidence

Run the original supporting inventory/plan/tree recipes first. Scratch is derived
from the current repository root; the scope audit below accepts later genuine
completion of the three required groups without crediting omitted ranges.

```bash
bash tools/project_data_run.sh python3 - <<'CURRENT_SUPPORTING_SCOPE'
from pathlib import Path
import collections, hashlib, json, re, subprocess

scratch = Path('.linkedspec-data/scratch/support4')
scratch.mkdir(parents=True, exist_ok=True)
baseline = 'baeb984e36a94a15951cd23d4c52def5064cdaca'
checkpoint = '5faaf61b9a5c56f18a01dde2c655f176b2828d19'
selected = {'specs/pplugin.spec', 'specs/spec.spec', 'specs/user_function_definition.spec'}
plan = json.loads(Path('.linkedspec-data/scratch/support370/plan.json').read_text())
tree = Path('docs/tasks/SUPPORTING-SOURCE-READING.md').read_text()
nodes = dict(re.findall(r'^- ID: `([^`]+)`\n(.*?)(?=^- ID: |^## |\Z)', tree, re.M | re.S))
required, coverage, statuses = [], {}, collections.Counter()
for number, group in enumerate(plan, 1):
    node = nodes[group['id']]
    original = '; '.join(f"`{r['path']}` lines {r['start']}-{r['end']}" for r in group['ranges'])
    assert re.search(r'^  Scope: (.+)$', node, re.M)[1] == original
    assert group['range_sha256'] in node
    status = re.search(r'^  Status: `([^`]+)`$', node, re.M)[1]
    statuses[status] += 1
    if number == 1:
        assert status == 'done'
    elif number not in [17, 18, 19]:
        assert status == 'superseded'
        owner = 'SUPPORTING-SOURCE-READING.' + ('0' if number <= 7 else '4')
        assert f'Superseded by: `{owner}`' in node
    else:
        assert status in ['pending', 'active', 'done']
        ranges = [r for r in group['ranges'] if r['path'] in selected]
        scope = '; '.join(f"`{r['path']}` lines {r['start']}-{r['end']}" for r in ranges)
        assert re.search(r'^  Required reading scope: (.+)$', node, re.M)[1] == scope
        for r in ranges:
            raw = Path(r['path']).read_bytes()
            assert raw == subprocess.check_output(['git', 'show', baseline + ':' + r['path']])
            chunk = b''.join(raw.splitlines(keepends=True)[r['start']-1:r['end']])
            assert len(chunk) == r['bytes'] and hashlib.sha256(chunk).hexdigest() == r['sha256']
            coverage.setdefault(r['path'], []).append((r['start'], r['end']))
        digest = hashlib.sha256(json.dumps(ranges, separators=(',', ':')).encode()).hexdigest()
        assert digest in node
        required.append({'id': group['id'], 'ranges': ranges,
                         'fragments': sum(r['end']-r['start']+1 for r in ranges),
                         'bytes': sum(r['bytes'] for r in ranges), 'range_sha256': digest})
assert set(coverage) == selected and len(required) == 3
for path, intervals in coverage.items():
    cursor = 1
    for start, end in sorted(intervals):
        assert start == cursor
        cursor = end + 1
    assert cursor == len(Path(path).read_bytes().splitlines(keepends=True)) + 1
assert sum(len(g['ranges']) for g in required) == 5
assert sum(g['fragments'] for g in required) == 629
assert sum(g['bytes'] for g in required) == 96781
assert statuses['superseded'] == 17
initial = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', '2baddbd56', '--', 'noncore/'], text=True).splitlines()
current = subprocess.check_output(['git', 'ls-files', 'noncore/'], text=True).splitlines()
assert initial == current and len(current) == 49
assert collections.Counter(Path(p).suffix for p in current) == {'.pm': 35, '.plg': 13, '.md': 1}
for prefix in ['conf/', 'tablescript/', 'noncore/', 'specs/', 'ebnf/']:
    entries = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', checkpoint, '--', prefix], text=True).splitlines()
    assert entries == subprocess.check_output(['git', 'ls-files', prefix], text=True).splitlines()
    for path in entries:
        assert Path(path).read_bytes() == subprocess.check_output(['git', 'show', checkpoint + ':' + path])
report = {'checkpoint': checkpoint, 'required': required, 'statuses': dict(statuses),
          'quarantine_files': 49, 'quarantine_modules': 35, 'quarantine_plugins': 13,
          'preserved_supporting_files': 158, 'required_files': 3, 'required_ranges': 5,
          'required_fragments': 629, 'required_bytes': 96781}
(scratch / 'audit.json').write_text(json.dumps(report, indent=2) + '\n')
print('PASS original scope/digests and 158 sources preserved; 17 omitted groups; three current grammars/5 ranges/629 fragments/96781 bytes; quarantine membership unchanged since initial relocation (35 modules/13 plugins/ledger).')
CURRENT_SUPPORTING_SCOPE
```

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'CURRENT_GRAMMAR_DESCRIPTORS'
use strict;
use warnings;
my @rows;
for my $name ('spec', 'user_function_definition', 'pplugin') {
    my $descriptor = LinkedSpec::get_parser($name, return_descriptor => 1);
    die "missing descriptor $name\n" unless ref($descriptor) eq 'HASH';
    my $m = $descriptor->{meta}{action_rewriter_migration} || {};
    die "descriptor not ready $name\n" unless ($m->{language_agnostic_ready_ratio} // 0) == 1;
    die "blocked descriptor $name\n" if ($m->{language_agnostic_blocked_rule_count} // 0) != 0;
    die "compatibility rules $name\n" if ($m->{compatibility_surface_rule_count} // 0) != 0;
    push @rows, { name => $name, ready => $m->{language_agnostic_ready_ratio},
                 blocked => 0 + ($m->{language_agnostic_blocked_rule_count} // 0),
                 compatibility => 0 + ($m->{compatibility_surface_rule_count} // 0) };
}
die "legacy adapter unexpectedly loaded\n" if exists $INC{'PPlugin.pm'};
print JSON::PP->new->canonical->encode({ descriptors => \@rows,
                                      legacy_adapter_loaded => JSON::PP::false }), "\n";
CURRENT_GRAMMAR_DESCRIPTORS
```

Related facts: [[supporting-source-reading-coverage]],
[[legacy-configuration-source-contracts]], [[spec-spec-self-hosted-grammar]],
[[pplugin-descriptor-ready-legacy-runtime-boundary]],
[[pplugin-pluginbridge-transition-machinery]],
[[spec-language-self-containment-and-ebnf-profile]].
