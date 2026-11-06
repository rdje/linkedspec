"""Prepare localized numeric-source host probes before any producer change."""
import json
from pathlib import Path

BASE = Path('docs/checkpoints/hash-view-receiver-policy-perl-2026-11-06')
assert not (BASE / 'seed_observer.pl').exists(), 'one-shot source seed preparation'
rows = []
for identifier, body in (
    ('receiver_number', 'return(3.sorted_keys())'),
    ('free_number', 'return(sorted_keys(3))'),
    ('computed_number', 'return(sorted_keys(length("abc")))'),
    ('valid_named_hash', 'set_key(meta,"b",2);set_key(meta,"a",1);return(sorted_keys(meta))'),
):
    rows.append(dict(id=identifier, body=body, source='Value:: I {' + body + '}\n', rule='Value', input='x'))
(BASE / 'seed-cases.json').write_text(json.dumps(rows, indent=2) + '\n')
source = (BASE / 'observer.pl').read_text()
start = source.index(' if ($row{native_callable}) {')
source = source[:start] + ''' my $package='LinkedSpec::HashViewReceiverSeedProbe::'.$id;
 my $loaded=defined($emitted) && eval "package $package; $emitted; 1";
 $row{loaded}=$loaded?1:0;$row{load_error}=error_value($@);
 for my $state (qw(empty outer main)) {
  no strict 'refs';
  local %{'main::3'}=$state eq 'main' ? (host_main=>'MAIN') : ();
  local %{$package.'::3'}=$state eq 'outer' ? (host_outer=>'OUTER') : ();
  my %observed=(host_before=>{main=>{%{'main::3'}},outer=>{%{$package.'::3'}}});
  if ($row{native_callable}) {
   my $text=$case->{input};$observed{native}=eval{$native->(\\$text)};
   $observed{native_error}=error_value($@ || $ctx{last_error});$observed{native_cursor}=pos($text);
  }
  if ($loaded) {
   my $text=$case->{input};$observed{fresh}=eval{$package->can('Execute')->(\\$text)};
   $observed{fresh_error}=error_value($@);$observed{fresh_cursor}=pos($text);
  }
  $observed{host_after}={main=>{%{'main::3'}},outer=>{%{$package.'::3'}}};
  $row{runs}{$state}=\\%observed;
 }
 $row{warnings}=\\@warnings;
 print 'HASH_VIEW_SOURCE_SEED '.$id.' '.$json->encode(\\%row),"\\n";
}
'''
(BASE / 'seed_observer.pl').write_text(source)
source = (BASE / 'capture.py').read_text()
source = source.replace("'owner.pm'", "'seed-owner.pm'")
source = source.replace("'capture.py', 'prepare.py', 'observer.pl', 'cases.json'",
                        "'capture_seed.py', 'prepare_seed.py', 'seed_observer.pl', 'seed-cases.json'")
source = source.replace("str(BASE / 'observer.pl')", "str(BASE / 'seed_observer.pl')")
source = source.replace("str(BASE / 'cases.json')", "str(BASE / 'seed-cases.json')")
source = source.replace('output = BASE / phase', "output = BASE / 'seed' / phase")
source = source.replace('output.mkdir()', 'output.mkdir(parents=True)')
source = source.replace('actual13 public policy', 'actual4 localized source-seed')
(BASE / 'capture_seed.py').write_text(source)
print('Four localized source programs/three host states prepared; no source change')
