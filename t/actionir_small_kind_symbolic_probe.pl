package SmallKindSymbolicProbe;
use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();
{
 package SmallKindSymbolicProbe::Map;
 sub TIEHASH { bless {storage => $_[1], selected => $_[2], fetches => $_[3], reads => 0}, $_[0] }
 sub FETCH {
  my ($self, $name) = @_;
  push @{$self->{fetches}}, $name;
  return ++$self->{reads} == 1 ? $self->{storage}{first} : $self->{selected} if $name eq 'bare_symbol_kind';
  return $self->{storage}{$name};
 }
}
my @rows;
for my $owner (qw(infer target candidate)) {
 for my $variant (qw(qualified unqualified glob blessed-code undefined array hash)) {
  for my $known (0, 1) {
   LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
    my $event = {raw => 'same'};
    LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
     {event => $event, source => 'same', source_span => {start => 0, end => 4}});
    my (@fetches, @trace, @eligible, $write_error, $written);
    my $input = $owner eq 'infer' ? 'copy(item)' : $owner eq 'target' ? 'array(item)' : 'item';
    my $actual = sub {
     push @trace, {args => [@_], context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
      incoming_error => $@, readonly => Internals::SvREADONLY($_[0]) ? 1 : 0,
      caller_slot => refaddr(\$_[0]) == refaddr(\$input) ? 1 : 0};
     push @eligible, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
     eval { $_[0] .= '!'; $written = $_[0]; 1 } or $write_error = $@;
     my $text = $owner eq 'infer' ? 'array' : $owner eq 'target' ? $_[0] : '1';
     my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
     LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, $text);
     LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
     $@ = 'successful symbolic kind';
     return $owner eq 'infer' ? 'array' : 'scalar';
    };
    no warnings 'redefine';
    local *LinkedSpec::ActionIR::MethodLowering::small_kind_named = $actual;
    local *LinkedSpec::ActionIR::MethodLowering::_infer_direct_shape_literal_kind = sub { return undef };
    my $selected = $variant eq 'qualified' ? 'LinkedSpec::ActionIR::MethodLowering::small_kind_named'
     : $variant eq 'unqualified' ? 'small_kind_named'
     : $variant eq 'glob' ? \*LinkedSpec::ActionIR::MethodLowering::small_kind_named
     : $variant eq 'blessed-code' ? bless(sub { return $actual->(@_) }, 'SmallKindSymbolicProbe::BlessedCode')
     : $variant eq 'array' ? [] : $variant eq 'hash' ? {} : undef;
    my $first_calls = 0;
    my %storage = (first => sub { ++$first_calls; return 'WRONG' },
     trim_action_ir_value => sub { return $_[0] },
     parse_method_function_expr => sub { return {method => 'copy', args => ['item']} },
     normalize_method_args_with_optional_scope => sub { return $_[0] });
    my %deps;
    tie %deps, 'SmallKindSymbolicProbe::Map', \%storage, $selected, \@fetches;
    my $outer = sub {
     return LinkedSpec::ActionIR::MethodLowering::_infer_assignment_source_container_kind($input, \%deps)
      if $owner eq 'infer';
     return LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol($input, 'array', \%deps)
      if $owner eq 'target';
     return LinkedSpec::ActionIR::MethodLowering::_codeblock_variable_call_candidate(\%deps, $input);
    };
    LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer, $actual] : [$outer], sub {
     my ($capture, $error, $success_error);
     eval { $@ = 'incoming symbolic kind'; $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
      $success_error = $@; 1 } or $error = $@;
     push @rows, {owner => $owner, variant => $variant, known => $known,
      value => $capture ? $capture->{value} : undef, error => $error, success_error => $success_error,
      trace => \@trace, eligible => \@eligible, fetches => \@fetches,
      selected_shape => ref($selected) || (defined($selected) ? 'scalar' : 'undefined'),
      first_calls => $first_calls, caller_after => $input, write_error => $write_error, written => $written,
      parent_packet => $capture && LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $outer, $event) ? 1 : 0};
    });
   });
  }
 }
}
print JSON::PP->new->canonical->encode({rows => \@rows}), "\n";
