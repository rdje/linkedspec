use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::ControlFlow ();
use LinkedSpec::ActionIR::FlowExpr ();
use LinkedSpec::ActionIR::MethodLowering ();

my $cold = @ARGV && $ARGV[0] eq 'cold';
unless ($cold) {
 require LinkedSpec::ActionIR::SourceOrigins;
 require LinkedSpec::ActionIR::SourceEmissions;
}
{
 package DefaultPackageEqProbe;
 our @ISA = ('LinkedSpec::RuleIR::EmitContext');
 our ($strings, $equals, $fatal) = (0, 0, undef);
 use overload '""' => sub {++$strings; return __PACKAGE__},
  'eq' => sub {
   ++$equals;
   die $fatal if $_[0]{variant} eq 'eq-die';
   $@ = 'equality-effect' if $_[0]{variant} eq 'eq-effect';
   return $_[0]{variant} eq 'eq-true' ? 1 : 0;
  }, fallback => 1;
}
{
 package DefaultPackageStringProbe;
 our @ISA = ('LinkedSpec::RuleIR::EmitContext');
 our $strings = 0;
 use overload '""' => sub {
  ++$strings;
  return $_[0]{variant} eq 'string-builtin' ? 'LinkedSpec::RuleIR::EmitContext' : __PACKAGE__;
 }, fallback => 1;
}
my @owners = qw(LinkedSpec::ActionIR::ControlFlow LinkedSpec::ActionIR::FlowExpr LinkedSpec::ActionIR::MethodLowering);
my $build = \&LinkedSpec::OwnerDispatch::build_dep_map;
my (%factories, %specs, %native, %ids, @retained, @rows);
sub identity {
 my ($value) = @_;
 return undef unless ref $value;
 my $address = refaddr($value);
 unless (exists $ids{$address}) {
  $ids{$address} = scalar @retained;
  push @retained, $value;
 }
 return $ids{$address}
}
for my $owner (@owners) {
 $factories{$owner} = $owner->can('default_deps_for_package');
 my $proxy = sub { $specs{$owner} = $_[2]; return $build->(@_) };
 no warnings 'redefine';
 local *LinkedSpec::OwnerDispatch::build_dep_map = $proxy;
 $native{$owner} = $factories{$owner}->('LinkedSpec::RuleIR::EmitContext');
 identity($native{$owner}{$_}) for sort keys %{$native{$owner}};
}
sub selected {
 my ($callback) = @_;
 return 0 unless defined &LinkedSpec::ActionIR::SourceEmissions::_same_reference;
 my $state = $LinkedSpec::ActionIR::SourceEmissions::_producers;
 return 0 unless ref($state) eq 'HASH'
  && LinkedSpec::ActionIR::SourceEmissions::_same_reference(
   $state->{source_token}, LinkedSpec::ActionIR::SourceEmissions::_current_source_token());
 return LinkedSpec::ActionIR::SourceEmissions::_same_reference($state->{known}{refaddr($callback)}, $callback) ? 1 : 0;
}
sub context { return !defined($_[0]) ? 'void' : $_[0] ? 'list' : 'scalar' }
for my $owner (@owners) {
 for my $variant (qw(eq-false eq-true eq-die eq-effect string-name string-builtin)) {
  for my $want (qw(scalar list void)) {
   for my $stage (qw(native-builder current-factory)) {
    my $target = bless {variant => $variant}, $variant =~ /^string/ ? 'DefaultPackageStringProbe' : 'DefaultPackageEqProbe';
    my $marker = bless {}, 'DefaultPackageFatal';
    $DefaultPackageEqProbe::fatal = $marker;
    ($DefaultPackageEqProbe::strings, $DefaultPackageEqProbe::equals, $DefaultPackageStringProbe::strings) = (0, 0, 0);
    my (@calls, @values, $successful_error, $fatal, $returned, $warnings);
    my $work = sub {
     no warnings 'redefine';
     local *LinkedSpec::OwnerDispatch::build_dep_map = sub {
      my $context = wantarray;
      push @calls, {context => context($context), owner => $_[0], target_is_actual_object => refaddr($_[1]) == refaddr($target) ? 1 : 0};
      if (!defined $context) { $build->(@_); return }
      if ($context) { my @values = $build->(@_); $returned = $values[0]; return @values }
      $returned = $build->(@_); return $returned
     };
     my $factory = $factories{$owner};
     if ($stage eq 'native-builder') {
      # Mirror this owner's existing native construction context. MethodLowering
      # builds one scalar map even under list/void callers; the other two forward.
      $factory = $owner eq 'LinkedSpec::ActionIR::MethodLowering'
       ? sub { my $map = LinkedSpec::OwnerDispatch::build_dep_map($owner, $target, $specs{$owner}); return $map }
       : sub { return LinkedSpec::OwnerDispatch::build_dep_map($owner, $target, $specs{$owner}) };
     }
     local $SIG{__WARN__} = sub { $warnings .= $_[0] };
     my $ok = eval {
      $@ = 'incoming-error';
      if ($want eq 'void') { $factory->($target) }
      elsif ($want eq 'list') { @values = $factory->($target) }
      else { $values[0] = $factory->($target) }
      $successful_error = $@;
      1
     };
     $fatal = $@;
     my @ordinary_values = map {
      my $value = $_;
      !defined($value) ? {type => 'undefined'} : ref($value) eq 'HASH' ? {
       type => 'HASH', is_actual_builder_map => defined($returned) && refaddr($value) == refaddr($returned) ? 1 : 0,
       callbacks => [map {+{key => $_, type => ref($value->{$_}), id => identity($value->{$_}),
        native_reference => refaddr($value->{$_}) == refaddr($native{$owner}{$_}) ? 1 : 0}} sort keys %$value]
      } : {type => ref($value) || 'scalar'}
     } @values;
     push @rows, {owner => $owner, variant => $variant, context => $want, stage => $stage,
      ordinary => {success => $ok ? 1 : 0, values => [@ordinary_values], calls => [@calls],
       string_calls => $DefaultPackageEqProbe::strings + $DefaultPackageStringProbe::strings,
       equal_calls => $DefaultPackageEqProbe::equals, successful_error => $successful_error,
       fatal => ref($fatal) ? {type => ref($fatal), is_actual_marker => refaddr($fatal) == refaddr($marker) ? 1 : 0} : $fatal,
       warnings => $warnings // ''},
      authority => [map {+{key => $_, selected => selected($native{$owner}{$_})}} sort keys %{$native{$owner}}]};
    };
    if ($cold) { $work->() }
    else {
     LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
      LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([], $work)
     });
    }
   }
  }
 }
}
print JSON::PP->new->canonical->encode({mode => $cold ? 'cold' : 'warm', rows => \@rows,
 source_emissions_loaded => exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'} ? 1 : 0,
 trace_loaded => exists $INC{'LinkedSpec/Trace.pm'} ? 1 : 0,
 loaded_project_modules => [map {'perl/'.$_} sort grep {m{^LinkedSpec(?:/|\.pm)}} keys %INC]}), "\n";
