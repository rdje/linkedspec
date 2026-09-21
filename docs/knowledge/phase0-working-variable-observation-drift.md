---
id: phase0-working-variable-observation-drift
title: Phase0 working-variable checks retain obsolete wrapper and declaration-deferral claims
answers:
  - does fluent push items still defer its Perl lexical declaration
  - which Phase0 working-variable test misses a removed scalar declaration
  - why do working-variable dedup tests still describe wrapped targets
  - which task owns Phase0 working-variable observation drift
date: 2026-09-21
status: confirmed test observation and description drift; .2.14 repair retains required reading prerequisites
tags: [perl, phase0, working-variables, tests, uniform-binding, observation-gap]
evidence: "CONFORMANCE-SOURCE-READING.1.78 at 2defd6def6f2fab08ac62e5b2f119186dc26cb9a. The exact fluent fixture captures 12,795 bytes with one my $items and no my @items. Its six authored assertions pass pristine and after deleting that scalar declaration from the observed source. A positive scalar-declaration control distinguishes the two. Adjacent dedup fixtures now use bare targets/reads despite wrapped-target descriptions."
reverify: "Run WORKING_VARIABLE_OBSERVATION below through the repository-local wrapper. It probes current public generated source and test sensitivity without changing production or executing target parser branches."
---

## Mechanism and repair ownership

`spec_format_terse_1_2_1_bare_arg_position_auto_exists` generates this fixture:

```text
top:: -> w.push(items)
 LX { return(count) }

w : /(\w+)/  I.return(match_group(0))
```

Public `Get` with `generate_only`, `dump_parser_source` and `parser_source_ref`
captures one `my $items;` and zero `my @items` declarations. Its 12,795-byte size
is a dated observation, not an output-size contract. The test's sixth assertion
only denies `my @items` and says the child-append target is deferred and not
auto-declared. That description no longer matches the current scalar-held binding.

Deleting only `my $items;` from the observed fluent source leaves all six
authored assertions passing. A scratch seventh assertion positively observes
the scalar declaration: pristine passes and the deletion fails that assertion.
Compiler calls and other generated fixtures remain unchanged. No production
leak or parser-runtime failure is established by this observation mutation.

The adjacent `spec_format_terse_1_2_1_dedup_with_wrapped_and_setup_single_my`
test still describes wrapped targets and reads, although its current source uses
bare `set(count, ...)`, `return(count)` and `copy(items)`. Its first two scalar
fixture expressions are identical. Their declaration-count assertions remain
meaningful, but they no longer distinguish a bare case from a wrapped case.
Historical channel comments and sigil claims throughout this family need an
explicit current-contract audit, including the unread continuation in group 79.

`CONFORMANCE-SOURCE-READING.2.14` owns that bounded repair after required
source/book/policy reading. It must observe actual nonempty scalar-held binding
declarations, reject declaration removal/duplication, preserve distinct setup,
per-invocation and recursion controls, correct descriptions and maintained
guidance, and avoid restoring retired wrapper syntax merely to fit old tests.
The historical channel chronology in [[terse-bare-working-vars-engine-gaps]]
does not override the current [[perl-uniform-binding-runtime]] contract.

## Reproduction

```bash
bash tools/project_data_run.sh python3 - <<'WORKING_VARIABLE_OBSERVATION'
from pathlib import Path
import os, re, subprocess

work = Path('.linkedspec-data/scratch/working-variable-observation-reverify')
work.mkdir(parents=True, exist_ok=True)
source = Path('t/phase0_regression.t').read_text()
name = 'spec_format_terse_1_2_1_bare_arg_position_auto_exists'
matches = re.findall(r"^subtest '" + name + r"' => sub \{\n.*?(?=^subtest |\Z)",
                     source, re.M | re.S)
assert len(matches) == 1
block = matches[0]
line = next(x for x in block.splitlines()
            if x.strip().startswith('my $fluent_src = $gen->('))
assert block.count(line) == 1 and block.count('plan tests => 6;') == 1
observe = r'''    diag('real fluent scalar declarations=' . scalar(() = $fluent_src =~ /my \$items\b/g));
    $fluent_src =~ s/^my \$items;\n//m if $ENV{PROBE_DROP_DECL};
'''
block = block.replace(line, line + '\n' + observe)
guarded = block.replace('plan tests => 6;', 'plan tests => 7;')
end = guarded.rindex('};')
positive = r'''    like($fluent_src, qr/my \$items\b/, 'positive control observes current fluent typed binding declaration');
'''
guarded = guarded[:end] + positive + guarded[end:]
for filename, text in [('original.t', block), ('guarded.t', guarded)]:
    (work / filename).write_text('use strict; use warnings; use Test::More; use LinkedSpec;\n'
                                + text + '\ndone_testing();\n')
for label, filename, drop, expected in [
    ('original-pristine', 'original.t', False, 0),
    ('original-dropped', 'original.t', True, 0),
    ('guarded-pristine', 'guarded.t', False, 0),
    ('guarded-dropped', 'guarded.t', True, 1),
]:
    env = dict(os.environ, PERL5LIB='')
    env.pop('PROBE_DROP_DECL', None)
    if drop:
        env['PROBE_DROP_DECL'] = '1'
    result = subprocess.run(['prove', '-v', '-Iperl', str(work / filename)],
                            env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    (work / (label + '.log')).write_text(result.stdout)
    assert result.returncode == expected, (label, result.returncode, result.stdout)
    assert 'real fluent scalar declarations=1' in result.stdout, label
    failures = re.findall(r'^    not ok (\d+) - (.+)$', result.stdout, re.M)
    assert failures == ([('7', 'positive control observes current fluent typed binding declaration')]
                        if expected else []), (label, failures)
    plan = 7 if filename == 'guarded.t' else 6
    assert f'    1..{plan}' in result.stdout, label
    assert '    ok 6 - fluent .push(items) child-append target is deferred' in result.stdout, label
    print(label, 'PASS: expected observation sensitivity', flush=True)
WORKING_VARIABLE_OBSERVATION
```

After repair, the historical six-assertion reproduction may require its activation
commit. The defective description and assertion are not preservation requirements.

Related: [[phase0-cursor-source-observation-gap]],
[[phase0-array-assignment-description-drift]], [[conformance-perl-consumer-reading]].
