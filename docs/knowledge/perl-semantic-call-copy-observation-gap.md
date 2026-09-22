---
id: perl-semantic-call-copy-observation-gap
title: Perl semantic call copy test does not observe its mutated nested return shape
answers:
  - does the semantic call projection copy test check every mutated nested value
  - can the semantic projection copy test miss a shared nested return shape
  - which task repairs semantic call copy observation coverage
date: 2026-09-22
status: confirmed test observation gap; current production detachment passes; .2.18 repair retains prerequisites
tags: [perl, semantic-introspection, tests, copying, conformance]
evidence: "CONFORMANCE-SOURCE-READING.1.85 at 441be2af. Four source-extracted controls keep the original six assertions green with shared nested return shape. A seven-assertion guarded twin passes production and rejects only the injected sharing at its new assertion 1. No retained production state is changed."
reverify: "Run SEMANTIC_CALL_COPY_OBSERVATION below through the project-data wrapper; this verifies test sensitivity rather than a production copy defect."
---

The copy subtest in `t/semantic_index_perl_calls_projection.t` changes both the
first definition-order entry and a nested call return-shape kind in one returned
projection. It requests a second projection but checks only definition-order
isolation; its remaining assertions check JSON/privacy and public method presence.
The nested return-shape mutation has no corresponding observation.

The source-extracted original passes six assertions both unchanged and with a
scratch method wrapper sharing only the returned call shape across two copies.
The wrapper still delegates to the actual projection method and leaves the index's
retained state untouched. An added assertion checks that the second call shape
is still string. Its seven-assertion twin passes unmodified production and fails
precisely the new assertion when sharing is injected. This is a test gap; current
production copies satisfy the stronger observation.

`CONFORMANCE-SOURCE-READING.2.18` owns the tracked correction after required reading,
including the independent mutation rejection and existing privacy/oracle checks.

```bash
bash tools/project_data_run.sh env PERL5LIB= python3 - <<'SEMANTIC_CALL_COPY_OBSERVATION'
from pathlib import Path
import re, subprocess, json

work = Path('.linkedspec-data/scratch/semantic-call-copy-observation')
work.mkdir(parents=True, exist_ok=True)
source = Path('t/semantic_index_perl_calls_projection.t').read_text()
prefix = source[:source.index("subtest 'calls, bindings")]
prefix = prefix.replace('use FindBin qw($Bin);', 'use Cwd qw(getcwd); my $Bin = getcwd()."/t";')
name = 'projection copies remain private plain data without host IR or generated source'
block = re.search(r"^subtest '" + re.escape(name) + r"' => sub \{\n.*?(?=^subtest )", source, re.M | re.S)[0]
needle = ' my $second = $index->_static_projection;\n'
assert block.count(needle) == 1
guard = ''' my ($observed_call) = grep { $_->{kind} eq 'call' } @{$second->{records}};
 is($observed_call->{facts}{return_shape}{kind}, 'string', 'nested call return shape remains detached');
'''
mutation = r'''
my $projection_method = \&LinkedSpec::SemanticIndex::_static_projection;
my $shared_return_shape;
{
 no warnings 'redefine';
 *LinkedSpec::SemanticIndex::_static_projection = sub {
  my $copy = $projection_method->(@_);
  my ($call) = grep { $_->{kind} eq 'call' } @{$copy->{records}};
  $shared_return_shape //= $call->{facts}{return_shape};
  $call->{facts}{return_shape} = $shared_return_shape;
  return $copy;
 };
}
'''
reports=[]
for label, guarded, shared in [('original',False,False),('original_shared_shape',False,True),('guarded',True,False),('guarded_shared_shape',True,True)]:
    body=block.replace(needle,needle+guard) if guarded else block
    path=work/(label+'.t');path.write_text(prefix+(mutation if shared else '')+body+'done_testing;\n')
    result=subprocess.run(['perl','-Iperl',str(path)],capture_output=True,text=True,timeout=90)
    (work/(label+'.tap')).write_text(result.stdout+result.stderr)
    failures=re.findall(r'^    not ok (\d+) - (.*)$',result.stdout,re.M)
    expected=guarded and shared
    assert result.returncode==int(expected),(label,result.returncode,result.stdout,result.stderr)
    assert failures==([('1','nested call return shape remains detached')] if expected else []),(label,failures)
    assert ('    1..7' if guarded else '    1..6') in result.stdout,(label,result.stdout)
    reports.append(dict(case=label,exit=result.returncode,nested_plan=7 if guarded else 6,failures=failures))
    print(json.dumps(reports[-1]),flush=True)
(work/'proof.json').write_text(json.dumps(reports,indent=2)+'\n')
print('PASS: original assertions miss shared nested return shape; one added observation rejects it; production copies pass.')
SEMANTIC_CALL_COPY_OBSERVATION
```

Related: [[perl-semantic-call-staged-projection]], [[conformance-perl-consumer-reading]].
