use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use MIME::Base64 qw(decode_base64);

my $loaded = do './t/actionir_method_regex_undef_required_probe.pl';
die $@ || $! unless defined $loaded;
my $native_path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2-native.json';
open my $fh, '<', $native_path or die "$native_path: $!";
my $capture = JSON::PP->new->decode(do {local $/; <$fh>});
close $fh or die "$native_path: $!";
my $native = JSON::PP->new->decode(decode_base64($capture->{stdout_base64}));
is($capture->{returncode}, 0, 'retained first native probe completed');
is(scalar(@{$native->{callbacks}}), 24, 'native callback population');
is(scalar(@{$native->{branches}}), 32, 'native branch population');
is(scalar(@{$native->{public}}), 4, 'native public Toolbox population');

for my $original (@{$native->{callbacks}}) {
 my ($kind,$mode,$role,$outcome) = @{$original}{qw(kind mode role outcome)};
 my $row = MethodRegexUndefRequiredProbe::invoke($kind,$mode,$role,$outcome);
 my $label = "$kind/$mode/$role/$outcome";
 is_deeply($row, $original, "$label complete first-native observation survives");
 my $count = $role eq 'strip_literal_delimiters' && $outcome ne 'fatal' ? 2 : 1;
 is($row->{calls}, $count, "$label native invocation count");
 ok($row->{map_identity}, "$label actual public references survive");
 my @calls = grep {$_->{role} eq $role} @{$row->{trace}};
 for my $i (0..$#calls) {
  my $call = $calls[$i];
  is($call->{context}, 'scalar', "$label/$i native scalar context");
  is($call->{error}, $i ? 'successful regex-undef required callback' : 'incoming regex-undef required error', "$label/$i native incoming error");
  is_deeply($call->{caller_slots}, [0,0,0,0,0], "$label/$i arguments retain native local scalar copies");
  if ($role eq 'normalize_method_args_with_optional_scope') {
   is($call->{actual_call_args}, 1, "$label actual parser argument array");
   is_deeply($call->{args}, [[],0,0], "$label exact zero arity arguments");
   is_deeply($call->{readonly}, [0,1,1], "$label zero arity literals stay readonly");
  } else {
   is_deeply($call->{readonly}, [$role eq 'trim_action_ir_value' && $mode eq 'default' ? 1 : 0], "$label/$i actual writable versus default literal boundary");
  }
  if ($role eq 'strip_literal_delimiters') {
   is($call->{previous_strip_slot}, 0, "$label/$i pattern and replacement use distinct local slots");
  }
 }
 if ($outcome eq 'fatal') {
  is_deeply($row->{error}, {type => 'MethodRegexUndefRequiredFatal', same_fatal => 1}, "$label fatal object retains actual identity");
 } else {
  is($row->{error}, undef, "$label bounded native route completes");
  is($row->{success_error}, 'successful regex-undef required callback', "$label successful error effect survives");
  my $expected = $kind eq 'undef' ? 'return undef'
   : '$SCALAR_SLOT =~ s{PATTERN}{REPLACEMENT}'.($mode eq 'default' ? '' : 'g');
  if ($outcome eq 'undefined') {
   $expected = $kind eq 'regex' && $role eq 'trim_action_ir_value'
    ? '$SCALAR_SLOT =~ s{PATTERN}{REPLACEMENT}' : undef;
  }
  is($row->{value}, $expected, "$label native result and fallback");
 }
 is_deeply($row->{caller_after}{args}, $role eq 'normalize_method_args_with_optional_scope' ? ['effect'] : [],
  "$label actual parser array effects survive even undefined or fatal outcomes");
}
for my $path (MethodRegexUndefRequiredProbe::paths()) {
 my ($kind,$mode) = @$path;
 my $owner = MethodRegexUndefRequiredProbe::owner($kind);
 for my $role (@{MethodRegexUndefRequiredProbe::roles($kind)}) {
  my $baseline = MethodRegexUndefRequiredProbe::invoke($kind,$mode,$role,'string');
  for my $known (0,1) {
   LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same',sub {
    my $event = {raw => 'same'};
    LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,{event => $event,source => 'same',source_span => {start => 0,end => 4}});
    my ($deps,$state) = MethodRegexUndefRequiredProbe::setup($kind,$mode,$role,'string');
    $state->{event} = $event; $state->{publication} = $baseline->{value};
    my $outer = sub {return MethodRegexUndefRequiredProbe::invoke_owner($deps,$state)};
    LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer,$deps->{$role}] : [$outer],sub {
     my $result = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
     my $label = "$owner/$mode/$role/$known";
     is($result->{value},$baseline->{value},"$label ordinary value survives");
     ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result,$outer,$event),"$label required dependency cannot donate nested publication");
     is_deeply($state->{eligible},[($known) x $baseline->{calls}],"$label actual callback has its own identity boundary");
     is($state->{calls},$baseline->{calls},"$label actual effect count survives");
     is(refaddr($deps->{$role}),refaddr($state->{original}{$role}),"$label public callback stays actual");
    });
   });
  }
  for my $bad (undef,'not code') {
   my ($deps,$state) = MethodRegexUndefRequiredProbe::setup($kind,$mode,'none','string',
    {input => undef,target => undef,pattern => undef,replacement => undef,flags => undef,ast => 'FAST'});
   $deps->{$role} = $bad;
   my $error; eval {MethodRegexUndefRequiredProbe::invoke_owner($deps,$state);1} or $error=$@;
   like($error,qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$role\E'/,
    "$owner/$mode/$role required diagnostic retains native selection");
   is_deeply($state->{events},[],"$owner/$mode/$role eager validation precedes input guards or AST fast path");
  }
 }
}
my $current = MethodRegexUndefRequiredProbe::observations();
my $cases = MethodRegexUndefRequiredProbe::branch_cases();
for my $i (0..$#$cases) {
 my ($label,$kind,$mode,$options,$value,$events) = @{$cases->[$i]};
 my $row = $current->{branches}[$i];
 is_deeply($row,$native->{branches}[$i],"$label complete first-native branch survives");
 is_deeply($row->{value},$value,"$label independently specified guard result");
 is_deeply($row->{events},$events,"$label exact guard and fallback order");
 is($row->{error},undef,"$label bounded branch completes");
 ok($row->{map_identity},"$label actual public references survive");
 is($row->{reference_identity},$label eq 'undef-ast-reference' ? 1 : 0,"$label direct result keeps actual reference identity");
 for my $helper (@{$row->{helpers}}) {is($helper->{actual_map},1,"$label actual helper map")}
 if ($label eq 'undef-normalized-distinct') {
  is($row->{candidate_is_call_args},0,'distinct normalizer result retains actual separate identity');
  is_deeply($row->{caller_after}{args},[],'distinct normalizer result leaves parser array unchanged');
 }
 if ($label eq 'undef-args-undefined') {
  my ($normalizer) = grep {$_->{role} eq 'normalize_method_args_with_optional_scope'} @{$row->{trace}};
  is($normalizer->{actual_call_args},0,'undefined parser args use a new empty array');
  is_deeply($normalizer->{args},[[],0,0],'new empty array retains actual zero-arity literals');
 }
}
my @public_values = ('$text =~ s{A}{X}g','$text =~ s{A}{X}g','return undef','return undef');
for my $i (0..$#public_values) {
 my $row = $current->{public}[$i];
 is_deeply($row,$native->{public}[$i],"$row->{case} complete first-native public Toolbox row survives");
 is($row->{error},undef,"$row->{case} actual public Toolbox diagnostic");
 is($row->{value},$public_values[$i],"$row->{case} existing generated-source distinction");
}
done_testing;
