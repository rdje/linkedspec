use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my $source = <<'SPEC';
Top:: I {
 values=[2,4,6];
 return([
 values.sum().add(1),num_add(num_sum(values),1),
 values.avg().add(1),num_add(num_avg(values),1),
 values.median().add(1),num_add(num_median(values),1),
 values.range().add(1),num_add(num_range(values),1),
 values.min().add(1),num_add(num_min(values),1),
 values.max().add(1),num_add(num_max(values),1)
 ]);
}
SPEC
my %ctx;
my $parser = LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);
my $input='x';
my $value=$parser->(\$input);
print JSON::PP->new->canonical->encode($value),"\n";
print "last_error=",defined($ctx{last_error}) ? $ctx{last_error} : "none","\n";
print LinkedSpec::call_spec_handler_subst("Top",q{return([2,4,6].sum().add(1))}),"\n";
