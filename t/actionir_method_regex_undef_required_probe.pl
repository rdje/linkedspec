package MethodRegexUndefRequiredProbe;
use strict;
use warnings;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

sub roles {
 return $_[0] eq 'regex' ? [qw(extract_scalar_symbol_name strip_literal_delimiters trim_action_ir_value)]
  : [qw(parse_method_function_expr normalize_method_args_with_optional_scope)];
}
sub owner {return $_[0] eq 'regex' ? '_lower_regex_subst_statement' : '_lower_return_undef_statement'}
sub same {ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0}
sub encoded {
 my ($value) = @_;
 return $value unless ref($value);
 return [map {encoded($_)} @$value] if ref($value) eq 'ARRAY';
 return {type => 'HASH', marker => $value->{marker}} if ref($value) eq 'HASH';
 return {type => ref($value)};
}
sub setup {
 my ($kind, $mode, $role, $outcome, $options) = @_;
 $options ||= {};
 my $state = {kind => $kind, mode => $mode, role => $role, outcome => $outcome, options => $options,
  input => exists($options->{input}) ? $options->{input} : 'return_undef()',
  target => exists($options->{target}) ? $options->{target} : 'target',
  pattern => exists($options->{pattern}) ? $options->{pattern} : '/pattern/',
  replacement => exists($options->{replacement}) ? $options->{replacement} : '"replacement"',
  flags => exists($options->{flags}) ? $options->{flags} : $mode eq 'default' ? undef : 'g',
  args => exists($options->{args}) ? $options->{args} : [],
  trace => [], helpers => [], events => [], eligible => [], calls => 0, strip_slots => [],
  reference => {marker => 'actual-result'}};
 $state->{call} = {method => $options->{method} // 'return_undef', args => $state->{args}};
 my $fatal = bless {}, 'MethodRegexUndefRequiredFatal';
 my %deps;
 for my $name (@{roles($kind)}) {
  $deps{$name} = sub {
   my @readonly = map {Internals::SvREADONLY($_) ? 1 : 0} @_;
   push @{$state->{events}}, $name;
   my $row = {role => $name, args => [map {encoded($_)} @_], readonly => \@readonly,
    context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', error => $@,
    caller_slots => [map {same(\$_[0], \$state->{$_})} qw(input target pattern replacement flags)],
    actual_call_args => same($_[0], $state->{call}{args}),
    previous_strip_slot => (grep {same(\$_[0], $_)} @{$state->{strip_slots}}) ? 1 : 0};
   push @{$state->{trace}}, $row;
   my $result;
   if ($name eq 'extract_scalar_symbol_name') {
    $result = exists($options->{symbol}) ? $options->{symbol} : 'SCALAR_SLOT';
   } elsif ($name eq 'strip_literal_delimiters') {
    my $ordinal = @{$state->{strip_slots}};
    push @{$state->{strip_slots}}, \$_[0];
    $result = ref($options->{stripped}) eq 'ARRAY' ? $options->{stripped}[$ordinal]
     : $ordinal ? 'REPLACEMENT' : 'PATTERN';
   } elsif ($name eq 'trim_action_ir_value') {
    $result = exists($options->{trimmed}) ? $options->{trimmed} : $_[0];
   } elsif ($name eq 'parse_method_function_expr') {
    $result = $options->{parse_undefined} ? undef : $state->{call};
   } else {
    $result = exists($options->{normalized}) ? $options->{normalized} : $_[0];
    $state->{normalizer_candidate} = $result;
   }
   if ($name eq $role) {
    ++$state->{calls};
    if (ref($_[0]) eq 'ARRAY') {push @{$_[0]}, 'effect'}
    elsif (defined($_[0]) && !ref($_[0]) && !$readonly[0]) {$_[0] .= '!'}
    $@ = 'successful regex-undef required callback';
    push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    die $fatal if $outcome eq 'fatal';
    return undef if $outcome eq 'undefined';
    if ($state->{event} && $state->{calls} == 1) {
     my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
     LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, $state->{publication});
     LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
    }
   }
   return $result;
  };
 }
 $state->{original} = {%deps};
 return (\%deps, $state, $fatal);
}
sub invoke_owner {
 my ($deps, $state) = @_;
 if ($state->{kind} eq 'regex') {
  return LinkedSpec::ActionIR::MethodLowering::_lower_regex_subst_statement(
   @{$state}{qw(target pattern replacement flags)}, $deps);
 }
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement = sub {
  push @{$state->{events}}, 'ast';
  push @{$state->{helpers}}, {name => 'ast', args => [map {encoded($_)} @_], actual_map => same($_[2], $deps)};
  return $state->{reference} if $state->{options}{ast_reference};
  return $state->{options}{ast};
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_return_undef_statement($state->{input}, $deps);
}
sub invoke {
 my ($kind, $mode, $role, $outcome, $options) = @_;
 my ($deps, $state, $fatal) = setup(@_);
 my ($value, $error, $success_error);
 eval {$@ = 'incoming regex-undef required error'; $value = invoke_owner($deps, $state); $success_error = $@; 1} or $error = $@;
 return {kind => $kind, mode => $mode, role => $role, outcome => $outcome, value => encoded($value), calls => $state->{calls},
  trace => $state->{trace}, helpers => $state->{helpers}, events => $state->{events},
  caller_after => {map {$_ => encoded($state->{$_})} qw(input target pattern replacement flags args)},
  normalizer_candidate_after => encoded($state->{normalizer_candidate}),
  candidate_is_call_args => same($state->{normalizer_candidate}, $state->{call}{args}),
  map_identity => (grep {!same($deps->{$_}, $state->{original}{$_})} @{roles($kind)}) ? 0 : 1,
  reference_identity => same($value, $state->{reference}), success_error => $success_error,
  error => ref($error) ? {type => ref($error), same_fatal => same($error, $fatal)} : $error};
}
sub paths {return (['regex','defined'], ['regex','default'], ['undef','plain'])}
sub branch_cases {
 my @cases;
 my @regex = qw(extract_scalar_symbol_name strip_literal_delimiters strip_literal_delimiters trim_action_ir_value);
 my @stripped = @regex[0..2];
 my @undef = qw(ast parse_method_function_expr normalize_method_args_with_optional_scope);
 my $plain = '$SCALAR_SLOT =~ s{PATTERN}{REPLACEMENT}g';
 for my $symbol (undef, '', '0') {
  push @cases, ['regex-symbol-'.($symbol // 'undefined'),'regex','defined',{symbol => $symbol},
   defined($symbol) ? '$'.$symbol.' =~ s{PATTERN}{REPLACEMENT}g' : undef,
   defined($symbol) ? \@regex : ['extract_scalar_symbol_name']];
 }
 for my $slot (0,1) {
  for my $value (undef, '', '0') {
   my @stripped_values = ('PATTERN','REPLACEMENT');$stripped_values[$slot] = $value;
   push @cases, ['regex-strip-'.$slot.'-'.($value // 'undefined'),'regex','defined',{stripped => \@stripped_values},
    defined($value) ? '$SCALAR_SLOT =~ s{'.$stripped_values[0].'}{'.$stripped_values[1].'}g' : undef,
    defined($value) ? \@regex : \@stripped];
  }
 }
 for my $value (undef, '', '0', 'g') {
  push @cases, ['regex-trim-'.($value // 'undefined'),'regex','defined',{trimmed => $value},
   '$SCALAR_SLOT =~ s{PATTERN}{REPLACEMENT}'.($value // ''),\@regex];
 }
 push @cases, ['regex-default-flags','regex','default',{},'$SCALAR_SLOT =~ s{PATTERN}{REPLACEMENT}',\@regex];
 for my $name (qw(target pattern replacement)) {
  push @cases, ['regex-undefined-'.$name,'regex','defined',{$name => undef},$plain,\@regex];
 }
 for my $ast ('FAST','0','') {
  push @cases, ['undef-ast-'.$ast,'undef','plain',{ast => $ast},length($ast) ? $ast : 'return undef',length($ast) ? ['ast'] : \@undef];
 }
 push @cases, ['undef-ast-reference','undef','plain',{ast_reference => 1},{type => 'HASH',marker => 'actual-result'},['ast']];
 for my $case (['undefined',{parse_undefined => 1}],['other-method',{method => 'other'}]) {
  push @cases, ['undef-parser-'.$case->[0],'undef','plain',$case->[1],undef,[qw(ast parse_method_function_expr)]];
 }
 for my $normalized (undef,'','0',[]) {
  my $label = ref($normalized) ? 'empty-array' : $normalized // 'undefined';
  push @cases, ['undef-normalized-'.$label,'undef','plain',{normalized => $normalized},ref($normalized) ? 'return undef' : undef,\@undef];
 }
 push @cases, ['undef-normalized-distinct','undef','plain',{normalized => ['other']},'return undef',\@undef];
 for my $case (['undefined',undef],['empty',[]],['unvalidated',['a','b']]) {
  push @cases, ['undef-args-'.$case->[0],'undef','plain',{args => $case->[1]},'return undef',\@undef];
 }
 push @cases, ['undef-undefined-input','undef','plain',{input => undef},'return undef',\@undef];
 return \@cases;
}
sub public_cases {
 return (['regex-bare','regex_subst(text, /A/, "X", g)'],['substr-bare','substr(text, /A/, "X", g)'],
  ['undef-plain','return_undef()'],['undef-scoped','return_undef(Top)']);
}
sub observations {
 my @callbacks;
 for my $path (paths()) {
  for my $role (@{roles($path->[0])}) {
   push @callbacks, map {invoke(@$path,$role,$_)} qw(string undefined fatal);
  }
 }
 my @public = map {my ($case,$source) = @$_;my ($value,$error);
  eval {$value = LinkedSpec::call_spec_handler_subst('Top',$source);1} or $error=$@;
  {case => $case,source => $source,value => $value,error => $error}} public_cases();
 return {callbacks => \@callbacks,
  branches => [map {{case => $_->[0],%{invoke($_->[1],$_->[2],'none','string',$_->[3])}}} @{branch_cases()}],public => \@public};
}
unless (caller) {
 die 'usage: probe.pl observe' unless @ARGV == 1 && $ARGV[0] eq 'observe';
 print JSON::PP->new->canonical->encode(observations()), "\n";
}
1;
