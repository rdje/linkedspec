"""Preserve the draft and correct only loader spelling and assertion-population dependence."""
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-'
TEST='t/actionir_receiver_scalar_copy.t'
PRODUCER=PREFIX+'capture.py'
COMPLETE=PREFIX+'complete-capture.py'
DRAFT=PREFIX+'fixture-draft.t'
TARGET=PREFIX+'fixture-correction.json'
digest=lambda raw:hashlib.sha256(raw).hexdigest()
assert not any((ROOT/path).exists() for path in (COMPLETE,DRAFT,TARGET)), 'one-shot correction already applied'
before_raw=(ROOT/(PREFIX+'before.json')).read_bytes()
before=json.loads(before_raw)
original=(ROOT/TEST).read_bytes()
producer=(ROOT/PRODUCER).read_bytes()
assert digest(original)==before['inputs'][TEST]
assert digest(producer)==before['producer_sha256']
old_compare=' is_deeply($row,$legacy_native->{cases}[$index],"$label complete native observation") unless $case->{repair};'
new_compare=r''' my $expected_native=$legacy_native->{cases}[$index];
 if ($case->{name} eq 'native-readonly') {
  $expected_native={%$expected_native};
  my $adjusted=$expected_native->{error}=~s{at t/actionir_legacy_hash_kind_probe\.pl line (?=\d+\.\n\z)}{at ./t/actionir_legacy_hash_kind_probe.pl line };
  is($adjusted,1,'legacy native readonly loader spelling is the sole path adjustment');
 }
 is_deeply($row,$expected_native,"$label complete native observation") unless $case->{repair};'''
old_loop=r''' for my $call (@{$row->{trace}}) {
  is($call->{origin},'map',"$label actual injected callback selected");
  is($call->{context},'scalar',"$label callback scalar context");
  is_deeply($call->{args},['meta'],"$label actual match value");
  is_deeply($call->{readonly},[0],"$label native match flag remains clear");
  is($call->{caller_slot},0,"$label match argument is separate from caller scalar");
  is($call->{incoming_error},'incoming legacy kind error',"$label incoming error effect survives");
 }'''
new_loop=r''' is_deeply([map {$_->{origin}} @{$row->{trace}}],[('map') x $case->{calls}],"$label actual injected callback selected");
 is_deeply([map {$_->{context}} @{$row->{trace}}],[('scalar') x $case->{calls}],"$label callback scalar context");
 is_deeply([map {$_->{args}} @{$row->{trace}}],[map {['meta']} 1..$case->{calls}],"$label actual match value");
 is_deeply([map {$_->{readonly}} @{$row->{trace}}],[map {[0]} 1..$case->{calls}],"$label native match flag remains clear");
 is_deeply([map {$_->{caller_slot}} @{$row->{trace}}],[(0) x $case->{calls}],"$label match argument is separate from caller scalar");
 is_deeply([map {$_->{incoming_error}} @{$row->{trace}}],[('incoming legacy kind error') x $case->{calls}],"$label incoming error effect survives");'''
text=original.decode()
assert text.count(old_compare)==1 and text.count(old_loop)==1
corrected=text.replace(old_compare,new_compare).replace(old_loop,new_loop).encode()
full=producer.decode()
changes=[
 ('"""One-shot native/paired/supplied legacy hash kind-callback proof and semantic faults."""',
  '"""Complete fixed-population fixture proof; original native and draft before remain immutable."""'),
 ("('native', 'current', 'before', 'fixture', 'consumers', 'inverses')",
  "('current', 'before', 'fixture', 'consumers', 'inverses')"),
 ('        retain(mode, row)',"        retain('before-complete' if mode == 'before' else mode, row)"),
 ("PREFIX + 'before.json'","PREFIX + 'before-complete.json'"),
]
for old,new in changes:
    assert full.count(old)==1
    full=full.replace(old,new)
(ROOT/DRAFT).write_bytes(original)
(ROOT/TEST).write_bytes(corrected)
(ROOT/COMPLETE).write_text(full)
(ROOT/TARGET).write_text(json.dumps({
 'producer_sha256':digest(Path(__file__).read_bytes()),'before':PREFIX+'before.json',
 'before_sha256':digest(before_raw),'draft':DRAFT,'draft_sha256':digest(original),
 'corrected_test':TEST,'corrected_test_sha256':digest(corrected),
 'original_capture':PRODUCER,'original_capture_sha256':digest(producer),
 'complete_capture':COMPLETE,'complete_capture_sha256':digest(full.encode()),
 'scope':'Draft408 assertions/33 failures retained verbatim. One native-control failure is only t/ versus ./t/ loader spelling in an otherwise equal readonly-write diagnostic. Compare a shallow expected-row copy after that exact path-prefix adjustment; raw observations remain unchanged. Replace trace-dependent assertion loops with six fixed whole-ledger assertions per authored case, so intended callback count changes cannot change the paired population. Original native/draft producers and results are not refreshed. Complete producer differs only by its disclosed docstring/native-mode prohibition/corrected-before output and reader selection.'
},indent=2)+'\n')
print('Fixture correction PASS: exact draft retained; bounded loader adjustment and fixed case-ledger assertions')
