---
id: phase0-cursor-source-observation-gap
title: Phase0 cursor generated-source denial passes even when captured source is empty
answers:
  - does the Phase0 cursor source assertion detect empty generated output
  - which task fixes the negative-only cursor source observation
  - does a passing consume-override denial prove seek source was captured
  - how can the cursor source test reject missing or unrelated output
date: 2026-09-21
status: confirmed observation gap; repair .2.13 pending required reading prerequisites
tags: [perl, phase0, tests, cursor, generated-source, observation-gap]
evidence: "CONFORMANCE-SOURCE-READING.1.77 at c57bd928ef7fe1bd385b80a1e029ca3960ae3532. Public dump_parser_source captures 11,417 bytes with the current Top three-argument LinkedRE::or call. The exact twelve authored assertions pass pristine and after emptying the subprocess output observation. A scratch positive source check passes with real capture and rejects empty and unrelated nonempty output at its added assertion 12; the original denial still passes."
reverify: "Run CURSOR_SOURCE_OBSERVATION below through the repository-local wrapper. This reproduces test sensitivity and preserves production source; it does not close the repair or prove standalone generated execution."
---

## Mechanism and owner

`return_descriptor_and_generated_source_share_rule_local_cursor_contract` in
`t/phase0_regression.t` checks ten descriptor properties, then a source-capture
subprocess exit code and one negative source pattern. The final assertion says
default-family generated source keeps seek dispatch, but only rejects one
four-argument call spelling containing `'consume'`. It never requires source
output to be nonempty or positively observes the current dispatch call.

The public capture works at this activation: the exact authored snippet returns
11,417 bytes and contains
`LinkedRE::or($STRING, $$descr{dependency_regex_map}{Top}, $info)`.
The byte count is dated evidence, not a required output size. No dependency
implementation is inspected; this is LinkedSpec-generated caller source.

Replacing only the observed subprocess stdout with an empty string leaves all
twelve authored assertions passing. Descriptor checks remain meaningful, but
the negative source assertion is vacuous for absent output. The separate
default/AND subprocess tests do observe seek/consume runtime outcomes; this
finding does not establish a compiler or cursor-execution defect.

A scratch copy adds a positive rule-specific source pattern and increases the
plan to thirteen. It passes pristine and fails exactly the new assertion with
empty output or unrelated nonempty text. The old negative assertion passes in
both mutations. The subprocess still executes and produces real source before
the harness changes its observation; compiler/bootstrap calls are untouched.

`CONFORMANCE-SOURCE-READING.2.13` owns the tracked correction after required
source/book/policy reading. It must require nonempty captured source and a
positive current dispatch observation, retain descriptor/runtime checks and
the consume-override denial, and reject missing and wrong-dispatch observations.
The positive scratch pattern is diagnostic evidence, not a newly frozen public
source format. No production change is justified by this test-only gap.

## Exact reproduction

```bash
bash tools/project_data_run.sh python3 - <<'CURSOR_SOURCE_OBSERVATION'
from pathlib import Path
import os, re, subprocess

work = Path('.linkedspec-data/scratch/cursor-source-observation-reverify')
work.mkdir(parents=True, exist_ok=True)
source = Path('t/phase0_regression.t').read_text()
name = 'return_descriptor_and_generated_source_share_rule_local_cursor_contract'
matches = re.findall(r"^subtest '" + name + r"' => sub \{\n.*?(?=^subtest |\Z)",
                     source, re.M | re.S)
assert len(matches) == 1
block = matches[0]
assert block.count('run_perl_snippet_in_subprocess($snippet)') == 1
block = block.replace('run_perl_snippet_in_subprocess($snippet)', 'probe_capture($snippet)')
prelude = r'''use strict; use warnings; use Test::More; use LinkedSpec;
use IPC::Open3; use Symbol qw(gensym);
sub normalize_error { return $_[0] }
sub probe_capture {
 my ($snippet) = @_;
 my ($in, $out, $err) = (undef, undef, gensym());
 my $pid = open3($in, $out, $err, $^X, '-Iperl', '-e', $snippet);
 close $in;
 local $/; my $stdout = <$out> // ''; my $stderr = <$err> // '';
 waitpid($pid, 0); my $status = $? >> 8;
 diag('actual captured bytes=' . length($stdout));
 $stdout = '' if $ENV{PROBE_EMPTY};
 $stdout = 'nonempty unrelated source' if $ENV{PROBE_WRONG};
 return ($status, $stdout, $stderr);
}
'''
assert block.count('plan tests => 12;') == 1
needle = '    unlike(\n        $source_out,'
assert block.count(needle) == 1
positive = r'''    like($source_out, qr/LinkedRE::or\(\$STRING, \$\$descr\{dependency_regex_map\}\{Top\}, \$info\)/,
        'positive control observes current default-family dispatch in captured source');
'''
guarded = block.replace('plan tests => 12;', 'plan tests => 13;').replace(needle, positive + needle)
for filename, text in [('original.t', block), ('guarded.t', guarded)]:
    (work / filename).write_text(prelude + text + '\ndone_testing();\n')
for label, filename, mutation, expected in [
    ('original-pristine', 'original.t', None, 0),
    ('original-empty', 'original.t', 'PROBE_EMPTY', 0),
    ('guarded-pristine', 'guarded.t', None, 0),
    ('guarded-empty', 'guarded.t', 'PROBE_EMPTY', 1),
    ('guarded-wrong', 'guarded.t', 'PROBE_WRONG', 1),
]:
    env = dict(os.environ, PERL5LIB='')
    env.pop('PROBE_EMPTY', None)
    env.pop('PROBE_WRONG', None)
    if mutation:
        env[mutation] = '1'
    result = subprocess.run(['prove', '-v', '-Iperl', str(work / filename)],
                            env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    (work / (label + '.log')).write_text(result.stdout)
    assert result.returncode == expected, (label, result.returncode, result.stdout)
    assert re.search(r'actual captured bytes=[1-9]\d*', result.stdout), label
    failures = re.findall(r'^    not ok (\d+) - (.+)$', result.stdout, re.M)
    assert failures == ([('12', 'positive control observes current default-family dispatch in captured source')]
                        if expected else []), (label, failures)
    plan = 13 if filename == 'guarded.t' else 12
    assert f'    1..{plan}' in result.stdout, label
    assert f'    ok {plan} - default-family generated source keeps seek dispatch without a global override' in result.stdout, label
    print(label, 'PASS: expected observation sensitivity', flush=True)
CURSOR_SOURCE_OBSERVATION
```

After the tracked test is repaired, the old twelve-assertion reproduction may
need to be read from its activation commit. Retaining the defective assertion
is not an acceptance requirement.

Related: [[phase0-code-slot-equivalence-observation-gap]],
[[perl-rule-local-cursor-rollout-boundaries]], [[conformance-perl-consumer-reading]].
