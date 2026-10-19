use strict;
use warnings;
use JSON::PP;
use LinkedSpec;
local $/;
my $cases = decode_json(<STDIN>);
my @observations;
for my $case (@$cases) {
 my %observed = (id => $case->{id});
 my @warnings;
 local $SIG{__WARN__} = sub { push @warnings, @_ };
 for my $route (qw(lower descriptor execute generated)) {
  my $result;
  my $ok = eval {
   if ($route eq 'lower') {
    $result = LinkedSpec::call_spec_handler_subst('Top', $case->{body});
   } elsif ($route eq 'descriptor') {
    my $spec = $case->{spec};
    my $descriptor = LinkedSpec::Get(\$spec, return_descriptor => 1);
    my $meta = $descriptor->{spec}{Top}{meta}{action_rewriter};
    $result = {map { $_ => $meta->{$_} } qw(canonical_action_ir_nodes canonical_action_ir_hits canonical_action_ir_fallback_count)};
   } elsif ($route eq 'execute') {
    my $spec = $case->{spec};
    my $input = $case->{input};
    my $parser = LinkedSpec::Get(\$spec);
    $result = $parser->(\$input);
   } else {
    my $spec = $case->{spec};
    my $source = LinkedSpec::emit_generated_source(\$spec, source_identity => 'migration-probe.spec');
    my $package = 'MigrationProbe' . scalar(@observations);
    eval "package $package; $source; 1" or die $@;
    my $input = $case->{input};
    no strict 'refs';
    my $value = &{$package . '::Execute'}(\$input);
    $result = {source => $source, value => $value};
   }
   1;
  };
  $observed{$route} = $ok ? {ok => JSON::PP::true, value => $result} : {ok => JSON::PP::false, error => "$@"};
 }
 $observed{warnings} = \@warnings;
 push @observations, \%observed;
}
print JSON::PP->new->canonical->allow_nonref->encode({cases => \@observations, inc => \%INC, perl => "$^V"}), "\n";
