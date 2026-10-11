use strict;
use warnings;
use Test::More;
use JSON::PP ();

do './t/actionir_receiver_scalar_copy_probe.pl' or die $@ || $!;
my $observed = ReceiverScalarCopyProbe::observations();
diag('RECEIVER_COPY_OBSERVATIONS '.JSON::PP->new->canonical->encode($observed));
my @names = qw(original-hash receiver-hash function-hash original-array receiver-array
 function-array original-empty-hash receiver-empty-hash original-empty-array
 receiver-empty-array multi-step-hash-count multi-step-array-count text-copy zero-copy);
my $hash = {k => 'v', nested => [1, 2]};
my @expected = ($hash, $hash, $hash, [1, 2], [1, 2], [1, 2], {}, {}, [], [], 2, 2, [], []);
for my $route (qw(live standalone)) {
 is(ref($observed->{$route}), 'ARRAY', "$route result is an array");
 is(scalar(@{$observed->{$route}}), scalar(@names), "$route complete case population");
 for my $idx (0 .. $#names) {
  is_deeply($observed->{$route}[$idx], $expected[$idx], "$route $names[$idx]");
 }
 for my $fact (qw(hash_distinct hash_nested_shared function_hash_distinct
    function_hash_nested_shared array_distinct function_array_distinct)) {
  is($observed->{$route.'_identity'}{$fact}, 1, "$route $fact");
 }
}
ok(!defined($observed->{live_error}), 'live structured runtime error remains clear');
is_deeply($observed->{typed_value}, {k => 'v'}, 'typed AST receiver preserves hash value');
ok($observed->{typed_calls} > 0, 'typed AST override was actually used');
unlike($observed->{typed_source}, qr/__poison_/, 'typed AST ignores all poisoned source fields');
is($observed->{legacy_source}, 'return [@Top]', 'legacy rule aggregate array snapshot remains exact');
like($observed->{wrong_arity_source}, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:copy/,
 'receiver copy still rejects an extra argument');
my $legacy_loaded=do './t/actionir_legacy_hash_kind_probe.pl';
die $@ || $! unless defined $legacy_loaded;
my $legacy_native_path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-native.json';
open my $legacy_fh,'<',$legacy_native_path or die "$legacy_native_path: $!";
my $legacy_capture=JSON::PP->new->decode(do {local $/;<$legacy_fh>});
close $legacy_fh or die "$legacy_native_path: $!";
my $legacy_native=JSON::PP->new->decode(MIME::Base64::decode_base64($legacy_capture->{stdout_base64}));
is($legacy_capture->{returncode},0,'legacy first native probe completed');
my $legacy_cases=LegacyHashKindProbe::cases();
is(scalar(@{$legacy_native->{cases}}),scalar(@$legacy_cases),'legacy complete native case population');
my $legacy_current=LegacyHashKindProbe::observations();
for my $index (0..$#$legacy_cases) {
 my $case=$legacy_cases->[$index];
 my $row=$legacy_current->{cases}[$index];
 my $label='legacy '.$case->{name};
 is_deeply($row,$legacy_native->{cases}[$index],"$label complete native observation") unless $case->{repair};
 is($row->{value},$case->{value},"$label result");
 is($row->{error_kind},$case->{error},"$label exact error selection");
 is(scalar(@{$row->{trace}}),$case->{calls},"$label selected callback count");
 ok($row->{public_map_preserved},"$label actual caller map survives");
 is($row->{caller_after},exists($case->{expr}) ? $case->{expr} : 'meta.copy()',"$label caller scalar survives");
 for my $call (@{$row->{trace}}) {
  is($call->{origin},'map',"$label actual injected callback selected");
  is($call->{context},'scalar',"$label callback scalar context");
  is_deeply($call->{args},['meta'],"$label actual match value");
  is_deeply($call->{readonly},[0],"$label native match flag remains clear");
  is($call->{caller_slot},0,"$label match argument is separate from caller scalar");
  is($call->{incoming_error},'incoming legacy kind error',"$label incoming error effect survives");
 }
 if (($case->{error} // '') eq 'map-fatal') {
  is_deeply($row->{error},{type=>'LegacyHashKindMapFatal',kind=>'map-fatal'},"$label actual fatal identity");
 } elsif (($case->{error} // '') eq 'readonly') {
  like($row->{error},qr/Modification of a read-only value attempted/,"$label actual write rejection");
 }
}
my $legacy_writability=LegacyHashKindProbe::invoke({name=>'native-hash',kind=>'hash',outcome=>'readonly'});
is($legacy_writability->{error_kind},'readonly','legacy native-hash actual readonly match alias');
is($legacy_writability->{caller_after},'meta.copy()','legacy rejected match write leaves caller intact');
for my $known (0,1) {
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same',sub {
  my $event={raw=>'same'};
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
   {event=>$event,source=>'same',source_span=>{start=>0,end=>4}});
  my ($deps,$state,$package_cb)=LegacyHashKindProbe::setup({name=>'authority',kind=>'hash'});
  $state->{event}=$event;
  my $outer=sub {LegacyHashKindProbe::invoke_owner($deps,$state,$package_cb)};
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer,$deps->{bare_symbol_kind}] : [$outer],sub {
   my $result=LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
   is($result->{value},'copy(meta)',"legacy authority/$known ordinary value");
   ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result,$outer,$event),"legacy authority/$known separate publication");
   is_deeply($state->{eligible},[$known],"legacy authority/$known actual callback identity");
   is(scalar(@{$state->{trace}}),1,"legacy authority/$known once-only effect");
   ok(LegacyHashKindProbe::same($deps->{bare_symbol_kind},$state->{actual}),"legacy authority/$known public callback unchanged");
   is_deeply($state->{trace}[0]{args},['meta'],"legacy authority/$known actual match value");
  });
 });
}
my $legacy_cold=$legacy_current->{cold};
is($legacy_cold->{returncode},0,'legacy cold probe completed');
is($legacy_cold->{value}{loaded_before},0,'legacy cold owner starts without emission channel');
is($legacy_cold->{value}{loaded_after},0,'legacy cold binding keeps channel lazy');
is_deeply($legacy_cold->{value}{rows}[0],$legacy_native->{cold}{value}{rows}[0],'legacy cold injected callback stays native');
is($legacy_cold->{value}{rows}[0]{value},'copy(meta)','legacy cold injected result');
is($legacy_cold->{value}{rows}[1]{value},undef,'legacy cold missing callback defaults to unknown');
is($legacy_cold->{value}{rows}[1]{error},undef,'legacy cold default avoids undefined package callback');
ok($legacy_cold->{value}{rows}[1]{map_preserved},'legacy cold default preserves absent map field');
done_testing();
