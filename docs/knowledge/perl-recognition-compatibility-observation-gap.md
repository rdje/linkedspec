---
id: perl-recognition-compatibility-observation-gap
title: Perl recognition compatibility isolation compares an unconnected local fixture
answers:
  - does the Perl recognition authority test observe compatibility cursor storage
  - can recognition compatibility assertions detect state interference
  - which repair owns the recognition compatibility observation gap
date: 2026-09-21
status: confirmed observation gap; runtime interference not reproduced
tags: [perl, recognition, compatibility, tests, observation-gap]
evidence: "CONFORMANCE-SOURCE-READING.1.83 at 1a18d19387ddb8cfc6c9717d93180711e10f6931 reads the complete authority test. The compatibility object has only declaration and comparison references. Independent cursor-stack and mark changes differ while the original comparison still passes. Eight top-level and 285 original nested results pass; the source-extracted scope probe adds four nested controls. Repair .2.17 owns actual supported-carrier observations after prerequisites."
reverify: "Run RECOGNITION_COMPATIBILITY_OBSERVATION below; it diagnoses observation scope, not runtime interference."
---

## Observation and repair

The final subtest in `t/recognition_transaction_perl_authority.t` declares a local
compatibility object with `cursor_stack` and rule-label `marks`, executes a private
recognition transaction, then compares that unchanged object with its literal.
The object is never passed to the authority or its invocation. This comparison
cannot observe changes to actual runtime compatibility storage.

The probe independently changes cursor-stack and mark state. Both changed objects
differ while the old fixture comparison passes: four added scope controls, with
all eight top-level and 285 original nested assertions passing. This establishes
an observation gap; it does not show runtime state corruption. Actual authority
frame snapshot, falsey payload and typed misuse assertions retain their meaning.

`CONFORMANCE-SOURCE-READING.2.17` owns a supported-carrier observation and a relevant
interference mutation rejected by that same observation. The private authority
intentionally excludes compatibility storage; preserve that design. The read
carrier prefix separately executes ordinary save/restore, but does not compose it
with a recognition transaction. Its recursive/generated suffix remains .1.84-owned.
Startup `.38` separately owns completed-token restoration of obsolete snapshots.

## Reproduction

```bash
bash tools/project_data_run.sh python3 - <<'RECOGNITION_COMPATIBILITY_OBSERVATION'
from pathlib import Path
import re, subprocess
w=Path('.linkedspec-data/scratch/recognition-compatibility-observation-reverify')
w.mkdir(parents=True,exist_ok=True)
def rooted(s):
 return s.replace('use FindBin qw($Bin);','use Cwd qw(abs_path);\nmy $Bin = abs_path("t");').replace('use lib "$Bin/../perl";',"use lib 'perl';")
s=Path('t/recognition_transaction_perl_authority.t').read_text();name='private state never aliases compatibility cursor-stack storage'
b=re.search(r"^subtest '"+re.escape(name)+r"' => sub \{\n.*?(?=^subtest |\Z)",s,re.M|re.S)[0];assert len(re.findall(r'\$compatibility\b',b))==2
needle=" is($authority->commit(token => $token, frame => $frame), 0, 'private commit preserves falsey payload');"
assert s.count(needle)==1
extra='''
 for my $field (qw(cursor_stack marks)) {
  my $independent = {cursor_stack => [3, 7], marks => {Top => {legacy => 9}}};
  if ($field eq 'cursor_stack') {push @{$independent->{cursor_stack}}, 99}
  else {$independent->{marks}{Top}{legacy} = 99}
  isnt(JSON::PP->new->canonical->encode($independent), JSON::PP->new->canonical->encode($compatibility), "$field independent changed state differs");
  is_deeply($compatibility, {cursor_stack => [3, 7], marks => {Top => {legacy => 9}}}, "$field original predicate ignores independent changed state");
 }
'''
s=s.replace(needle,needle+extra);(w/'recognition-compatibility-scope.t').write_text(rooted(s))
r=subprocess.run(['prove','-v','-Iperl',str(w/'recognition-compatibility-scope.t')],capture_output=True,text=True);(w/'recognition-compatibility-scope.log').write_text(r.stdout+r.stderr);assert r.returncode==0,r.stdout+r.stderr
assert r.stdout.count('independent changed state differs')==2 and r.stdout.count('original predicate ignores independent changed state')==2
print('PASS: two disconnected compatibility fields and four scope controls; no runtime corruption claimed')
RECOGNITION_COMPATIBILITY_OBSERVATION
```

Related: [[perl-recognition-transaction-private-authority]],
[[perl-recognition-invalidated-token-restoration]], [[conformance-perl-consumer-reading]].
