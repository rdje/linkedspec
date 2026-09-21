---
id: perl-progressive-parent-state-test-gap
title: Perl progressive authority parent-state checks compare a disconnected fixture
answers:
  - does the Perl progressive authority matrix observe actual parent state
  - can Perl progressive parent-state assertions detect changes outside their fixture
  - which task owns Perl progressive parent-state observation repair
date: 2026-09-21
status: confirmed observation gap; runtime parent-state corruption not reproduced
tags: [perl, progressive, tests, observation-gap, conformance]
evidence: "CONFORMANCE-SOURCE-READING.1.82 at dc88fc1397b01a6dadb7b2d8a8cbf91b2169e1e0. The execution matrix uses parent only to clone, serialize and compare its local fixture. Four independently changed states differ while all four old predicates still pass. Eight scope controls pass with the unchanged authority assertions; repair .2.15 retains startup prerequisites and carrier-suffix reading."
reverify: "Run PERL_PARENT_OBSERVATION below; it diagnoses the test's observation scope, not runtime corruption."
---

## Observation and repair

In `t/progressive_span_dispatch_perl_authority.t`, the four execution rows copy
`parent_before` into a local `parent`, save its serialization, and later compare
that same object with its saved value. Those are its only three source references.
Neither invocation configuration, dispatch arguments nor the child callback
receives the fixture object. The assertion therefore does not observe actual
parent parser registers.

The source-extracted scope control independently changes a second state object.
It differs from the saved state while each old comparison still passes. All
original authority checks and eight added controls pass: nine top-level results
with 272 nested assertions, versus 264 nested assertions in the unchanged suite.
This is an observation gap, not demonstrated runtime parent-state corruption.
The result-detachment, budget and diagnostic assertions remain meaningful.

`CONFORMANCE-SOURCE-READING.2.15` owns actual supported-carrier state observations
and a relevant mutation rejected by the same observation. The admitted carrier
suffix remains .1.83-owned and must be read before selecting those controls.
Private authority deliberately excludes parent registers; a repair must preserve
that boundary and distinguish it from integration regression coverage.
Startup `.37` separately owns resource-ceiling enforcement.

## Reproduction

```bash
bash tools/project_data_run.sh python3 - <<'PERL_PARENT_OBSERVATION'
from pathlib import Path
import re, subprocess

work = Path('.linkedspec-data/scratch/perl-parent-observation-reverify')
work.mkdir(parents=True, exist_ok=True)
source = Path('t/progressive_span_dispatch_perl_authority.t').read_text()
name = 'child execution is isolated, fail-only, falsey-safe, and deeply detached'
block = re.search(r"^subtest '" + re.escape(name) + r"' => sub \{\n.*?(?=^subtest |\Z)",
                  source, re.M | re.S)[0]
assert len(re.findall(r'\$parent\b', block)) == 3
needle = '  is($JSON->encode($parent), $parent_before, "$case->{id} cannot mutate parent parser state");'
assert source.count(needle) == 1
extra = '''  my $independent = clone_plain($case->{parent_before});
  $independent->{coverage_probe} = 'changed outside the observation';
  isnt($JSON->encode($independent), $parent_before,
       "$case->{id} independent changed state differs");
  is($JSON->encode($parent), $parent_before,
     "$case->{id} original predicate ignores independent changed state");
'''
source = source.replace(needle, needle + '\n' + extra)
source = source.replace('use FindBin qw($Bin);',
                        'use Cwd qw(abs_path);\nmy $Bin = abs_path("t");')
source = source.replace('use lib "$Bin/../perl";', "use lib 'perl';")
target = work / 'parent-observation.t'
target.write_text(source)
result = subprocess.run(['prove', '-v', '-Iperl', str(target)],
                        capture_output=True, text=True)
(work / 'probe.log').write_text(result.stdout + result.stderr)
assert result.returncode == 0, result.stdout + result.stderr
assert result.stdout.count('independent changed state differs') == 4
assert result.stdout.count('original predicate ignores independent changed state') == 4
print('PASS: four disconnected parent observations and eight scope controls; no runtime corruption asserted')
PERL_PARENT_OBSERVATION
```

Related: [[perl-progressive-span-dispatch-authority]],
[[julia-progressive-parent-state-test-gap]], [[conformance-perl-consumer-reading]].
