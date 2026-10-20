use strict;
use warnings;
use JSON::PP;
use Scalar::Util qw(blessed);
use LinkedSpec;

sub data {
 my ($value) = @_;
 return $value unless ref($value);
 return {map { $_ => data($value->{$_}) } keys %$value} if ref($value) eq 'HASH';
 return [map { data($_) } @$value] if ref($value) eq 'ARRAY';
 return $value if blessed($value) && ($value->isa('JSON::PP::Boolean') || $value->isa('JSON::XS::Boolean'));
 return {reference_kind => ref($value), rendered => "$value"};
}

local $/;
my $cases = decode_json(<STDIN>);
my @rows;
for my $case (@$cases) {
 my %row = (id => $case->{id});
 my @warnings;
 my %warning_routes;
 my $active_route;
 local $SIG{__WARN__} = sub { push @warnings, @_; push @{$warning_routes{$active_route}}, @_ };
 for my $route (qw(descriptor live generated generated_fatal)) {
  $active_route = $route;
  my ($value, %context);
  my $ok = eval {
   my $source = $case->{spec};
   if ($route eq 'descriptor') {
    my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1, runtime_ctx_ref => \%context);
    die "descriptor build returned no descriptor\n" unless ref($descriptor) eq 'HASH';
    my $meta = $descriptor->{spec}{Top}{meta}{action_rewriter};
    $value = {map { $_ => $meta->{$_} } qw(canonical_action_ir_nodes canonical_action_ir_hits canonical_action_ir_fallback_count)};
   } elsif ($route eq 'live') {
    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
    die "build returned no parser\n" unless ref($parser) eq 'CODE';
    my $input = $case->{input};
    $value = $parser->(\$input);
   } else {
    my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'type-values-probe.spec');
    my $package = 'DropWarningProbe' . scalar(@rows) . $route;
    my $profile = $route eq 'generated_fatal' ? "use warnings FATAL => 'syntax'; " : '';
    eval "package $package; $profile $emitted; 1" or die $@;
    my $input = $case->{input};
    no strict 'refs';
    my $result = &{$package . '::Execute'}(\$input);
    $value = {source => $emitted, value => $result};
   }
   1;
  };
  $row{$route} = $ok ? {ok => JSON::PP::true, value => data($value)}
                     : {ok => JSON::PP::false, error => data($@), context => data($context{last_error})};
 }
 $row{warnings} = \@warnings;
 $row{warning_routes} = \%warning_routes;
 push @rows, \%row;
}
print "\nSOURCE_TYPE_MODEL_JSON ", JSON::PP->new->canonical->allow_nonref->encode({rows => \@rows, inc => \%INC, perl => "$^V"}), "\n";
