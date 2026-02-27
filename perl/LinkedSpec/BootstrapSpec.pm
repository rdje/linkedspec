package LinkedSpec::BootstrapSpec;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedRE ();

sub _build_bootstrap_registry_gdata {
 my ($spec_descr) = @_;

 my %bootstrap_rule_index = map {
  my $id = $spec_descr->[$_]{id};
  defined $id ? ($id => $_) : ()
 } 0 .. $#$spec_descr;

 for my $required_rule_id (qw/SPEC_ROOT CURLY_BRACE/) {
  die "(LinkedSpec.pm) -E- Missing required bootstrap rule id '$required_rule_id'"
   unless defined $bootstrap_rule_index{$required_rule_id};
 }

 my @bootstrap_start_res;
 my @bootstrap_start_dispatch;
 for my $idx (0 .. $#$spec_descr) {
  my $rule = $spec_descr->[$idx];
  next unless ref($rule) eq 'HASH';
  next unless exists $rule->{tags} && ref($rule->{tags}) eq 'HASH' && $rule->{tags}{start_token};
  next unless exists $rule->{re} && ref($rule->{re}) eq 'ARRAY' && @{$rule->{re}};
  push @bootstrap_start_res, $rule->{re}[0];
  push @bootstrap_start_dispatch, $idx;
 }

 die "(LinkedSpec.pm) -E- Bootstrap start-token registry is empty"
  unless @bootstrap_start_res && @bootstrap_start_dispatch;

 my @bootstrap_cbrace_res = ();
 if (defined $bootstrap_rule_index{CURLY_BRACE}
     && exists $spec_descr->[$bootstrap_rule_index{CURLY_BRACE}]{re}
     && ref($spec_descr->[$bootstrap_rule_index{CURLY_BRACE}]{re}) eq 'ARRAY') {
  @bootstrap_cbrace_res = @{$spec_descr->[$bootstrap_rule_index{CURLY_BRACE}]{re}};
 }

 my $gdata = {
  startREs       => LinkedRE::oredRE(@bootstrap_start_res),
  start_dispatch => \@bootstrap_start_dispatch,
  cbrace         => LinkedRE::oredRE(@bootstrap_cbrace_res)
 };

 return (\%bootstrap_rule_index, $gdata);
}

1;
