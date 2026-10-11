package LegacyHashKindProbe;
use strict;
use warnings;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use MIME::Base64 qw(encode_base64);
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

sub same {ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0}
sub cases {
 return [
  {name=>'native-hash', kind=>'hash', value=>'copy(meta)', calls=>1},
  {name=>'native-array', kind=>'array', calls=>1},
  {name=>'native-unknown', calls=>1},
  {name=>'native-scalar', kind=>'scalar', calls=>1},
  {name=>'native-empty-kind', kind=>'', calls=>1},
  {name=>'native-zero-kind', kind=>0, calls=>1},
  {name=>'native-reference-kind', kind=>{marker=>'kind-reference'}, calls=>1},
  {name=>'native-lookahead', expr=>'meta.copy().flat_hash()', value=>'copy(copy(meta))', calls=>1},
  {name=>'native-array-lookahead', expr=>'meta.copy().sorted()', calls=>1},
  {name=>'native-count-tail', expr=>'meta.copy().count_keys()', kind=>'hash', value=>'count_keys(copy(meta))', calls=>1},
  {name=>'native-wrong-arity', expr=>'meta.copy(one)', kind=>'hash', calls=>1},
  {name=>'native-explicit-hash', expr=>'hash({}).copy()', kind=>'array', value=>'copy(hash({}))', calls=>0},
  {name=>'native-explicit-array', expr=>'array([]).copy()', kind=>'hash', calls=>0},
  {name=>'native-other-method', expr=>'meta.count_keys()', value=>'count_keys(meta)', calls=>0},
  {name=>'native-terminal-tail', expr=>'meta.count_keys().copy()', calls=>0},
  {name=>'native-unknown-method', expr=>'meta.unknown()', calls=>0},
  {name=>'native-no-dot', expr=>'meta', calls=>0},
  {name=>'native-undefined-input', expr=>undef, calls=>0},
  {name=>'native-empty-input', expr=>'', calls=>0},
  {name=>'native-unparsed-call', expr=>'meta.copy', calls=>0},
  {name=>'native-fatal', kind=>'hash', outcome=>'fatal', error=>'map-fatal', calls=>1},
  {name=>'native-readonly', kind=>'hash', outcome=>'readonly', error=>'readonly', calls=>1},
  {name=>'native-map-replacement', kind=>'hash', replace_on_trim=>1, value=>'copy(meta)', calls=>1},
  {name=>'map-over-undefined-package', kind=>'hash', package=>'undefined', value=>'copy(meta)', calls=>1, repair=>1},
  {name=>'map-over-array-package', kind=>'hash', package=>'array', value=>'copy(meta)', calls=>1, repair=>1},
  {name=>'array-map-over-hash-package', kind=>'array', package=>'hash', calls=>1, repair=>1},
  {name=>'unknown-map-over-hash-package', package=>'hash', calls=>1, repair=>1},
  {name=>'missing-map-over-hash-package', missing=>1, package=>'hash', calls=>0, repair=>1},
  {name=>'noncode-map-over-hash-package', noncode=>1, package=>'hash', calls=>0, repair=>1},
  {name=>'missing-map-with-undefined-package', missing=>1, package=>'undefined', calls=>0, repair=>1},
  {name=>'noncode-map-with-undefined-package', noncode=>1, package=>'undefined', calls=>0, repair=>1},
  {name=>'missing-map-lookahead', missing=>1, package=>'undefined', expr=>'meta.copy().count_keys()', value=>'count_keys(copy(meta))', calls=>0, repair=>1},
  {name=>'map-over-fatal-package', kind=>'hash', package=>'fatal', value=>'copy(meta)', calls=>1, repair=>1},
  {name=>'fatal-map-over-array-package', kind=>'hash', outcome=>'fatal', package=>'array', error=>'map-fatal', calls=>1, repair=>1},
  {name=>'readonly-map-over-array-package', kind=>'hash', outcome=>'readonly', package=>'array', error=>'readonly', calls=>1, repair=>1},
 ];
}
sub setup {
 my ($case) = @_;
 my $state = {case=>$case, input=>exists($case->{expr}) ? $case->{expr} : 'meta.copy()',
  trace=>[], eligible=>[], trims=>0, events=>[], fatal=>bless({},'LegacyHashKindMapFatal'),
  package_fatal=>bless({},'LegacyHashKindPackageFatal')};
 my %deps;
 my $make_kind = sub {
  my ($origin,$kind,$outcome) = @_;
  return sub {
   push @{$state->{trace}}, {origin=>$origin, args=>[@_],
    readonly=>[map {Internals::SvREADONLY($_) ? 1 : 0} @_],
    context=>!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
    caller_slot=>same(\$_[0],\$state->{input}), incoming_error=>$@};
   push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
   $_[0] .= '!' if ($outcome // '') eq 'readonly';
   $@ = 'successful legacy kind callback';
   die $origin eq 'map' ? $state->{fatal} : $state->{package_fatal} if ($outcome // '') eq 'fatal';
   if ($state->{event}) {
    my $builder=LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
    LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder,'copy(meta)');
    LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
   }
   return $kind;
  };
 };
 $state->{actual}=$make_kind->('map',$case->{kind},$case->{outcome});
 $state->{replacement}=$make_kind->('replacement','array','');
 $deps{bare_symbol_kind}=$case->{noncode} ? 'not code' : $state->{actual} unless $case->{missing};
 $deps{trim_action_ir_value}=sub {
  ++$state->{trims};
  push @{$state->{events}},'trim';
  $deps{bare_symbol_kind}=$state->{replacement} if $case->{replace_on_trim} && $state->{trims}==1;
  return $_[0];
 };
 $deps{parse_method_function_expr}=sub {
  push @{$state->{events}},'parse';
  return undef unless defined($_[0]) && $_[0] =~ /^([a-z_]+)\((.*)\)$/s;
  return {method=>$1,args=>length($2) ? [$2] : []};
 };
 $state->{original}={%deps};
 my $package=$case->{package} // 'same';
 my $package_cb=$package eq 'same' ? $state->{actual} : $package eq 'undefined' ? undef
  : $make_kind->('package',$package,$package eq 'fatal' ? 'fatal' : '');
 return (\%deps,$state,$package_cb);
}
sub invoke_owner {
 my ($deps,$state,$package_cb)=@_;
 no warnings 'once';
 local $LinkedSpec::ActionIR::MethodLowering::bare_symbol_kind=$package_cb;
 return LinkedSpec::ActionIR::MethodLowering::_normalize_hash_receiver_value_chain_expr($state->{input},$deps);
}
sub invoke {
 my ($case)=@_;
 my ($deps,$state,$package_cb)=setup($case);
 my ($value,$error,$success_error);
 eval {$@='incoming legacy kind error'; $value=invoke_owner($deps,$state,$package_cb); $success_error=$@; 1} or $error=$@;
 my $error_kind=ref($error) ? same($error,$state->{fatal}) ? 'map-fatal'
  : same($error,$state->{package_fatal}) ? 'package-fatal' : 'foreign-fatal'
  : defined($error) && $error =~ /Modification of a read-only value/ ? 'readonly' : defined($error) ? 'text' : undef;
 my $expected_kind=$case->{replace_on_trim} ? $state->{replacement} : $state->{original}{bare_symbol_kind};
 my $kind_preserved=ref($expected_kind) ? same($deps->{bare_symbol_kind},$expected_kind)
  : (!defined($expected_kind) && !defined($deps->{bare_symbol_kind}))
   || (defined($expected_kind) && defined($deps->{bare_symbol_kind}) && $expected_kind eq $deps->{bare_symbol_kind});
 return {name=>$case->{name},value=>$value,error=>ref($error) ? {type=>ref($error),kind=>$error_kind} : $error,
  error_kind=>$error_kind,success_error=>$success_error,trace=>$state->{trace},eligible=>$state->{eligible},
  events=>$state->{events},caller_after=>$state->{input},
  public_map_preserved=>($kind_preserved && same($deps->{trim_action_ir_value},$state->{original}{trim_action_ir_value})
   && same($deps->{parse_method_function_expr},$state->{original}{parse_method_function_expr})
   && exists($deps->{bare_symbol_kind})==exists($state->{original}{bare_symbol_kind})) ? 1 : 0};
}
sub cold {
 my @command=('perl','-Iperl','t/actionir_legacy_hash_kind_cold_probe.pl');
 open my $pipe,'-|',@command or die "cold probe: $!";
 my $raw=do {local $/; <$pipe>};
 close $pipe;
 return {command=>\@command,returncode=>$? >> 8,stdout_base64=>encode_base64($raw,''),value=>JSON::PP->new->decode($raw)};
}
sub observations {return {cases=>[map {invoke($_)} @{cases()}],cold=>cold()}}
unless (caller) {
 die 'usage: legacy hash probe observe' unless @ARGV==1 && $ARGV[0] eq 'observe';
 print JSON::PP->new->canonical->encode(observations()),"\n";
}
1;
