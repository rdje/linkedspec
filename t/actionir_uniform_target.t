use strict;
use warnings;
use Test::More;
use JSON::PP ();
use IPC::Open3 qw(open3);
use Symbol qw(gensym);

my $json = JSON::PP->new->canonical;
sub probe {
 my ($mode, $first) = @_;
 my $err_handle = gensym;
 my $pid = open3(undef, my $out_handle, $err_handle,
  'perl', '-Iperl', './t/actionir_uniform_target_probe.pl', $mode, $first);
 my $out = do { local $/; <$out_handle> // '' };
 my $err = do { local $/; <$err_handle> // '' };
 waitpid($pid, 0);
 is($? >> 8, 0, "$mode $first fresh process completes");
 is($err, '', "$mode $first no diagnostics");
 return $json->decode($out);
}
my %called = map { $_ => 1 } qw(first other first-again other-again empty-literal literal-dot
 spaced kind-array kind-undefined kind-zero effect fatal trailing-newline);
my %value = map { $_ => 'item' } qw(first other first-again other-again empty-literal literal-dot
 bare spaced trailing-newline);
$value{effect} = 'item!';
my @names = qw(first other first-again other-again stale-wrong empty-wrong empty-literal
 literal-dot dot-lookalike bare undefined-target undefined-container spaced compound kind-array
 kind-undefined kind-zero effect fatal trailing-newline);
for my $first (qw(array hash)) {
 my $observed = probe('native', $first);
 is_deeply([map { $_->{id} } @{$observed->{rows}}], \@names, "$first exact ordered native population");
 for my $row (@{$observed->{rows}}) {
  my $id = $row->{id};
  my $label = "$first $id";
  is($row->{value}, $value{$id}, "$label current-container result");
  is(scalar(@{$row->{calls}}), $called{$id} // 0, "$label exact callback count");
  is($row->{caller_after}, $row->{input}, "$label caller input unchanged");
  is_deeply($row->{calls}, $called{$id}
   ? [{argument => 'item', context => 'scalar', incoming_error => 'target incoming'}] : [],
   "$label actual callback argument/context/error");
  is_deeply($row->{error}, $id eq 'fatal' ? {type => 'UniformTargetProbe::Fatal', actual => 1} : undef,
   "$label actual fatal identity");
  is($row->{success_error}, $id eq 'fatal' ? undef : $called{$id} ? 'target success' : 'target incoming',
   "$label successful error effect");
 }
}
open my $fh, '<', 'capability_conformance/uniform_binding_contract.json' or die $!;
my $contract = $json->decode(do { local $/; <$fh> });
close $fh or die $!;
my @public;
for my $first (qw(array hash)) {
 my $observed = probe('public', $first);
 is($observed->{warm}, 'item', "$first explicit private warm-up succeeds");
 is(scalar(@{$observed->{lowering}}), 4, "$first complete public lowering population");
 for my $index (0, 1) {
  my $surface = $index == 0 ? 'array' : 'hash';
  is($observed->{lowering}[$index]{value}, undef, "$first $surface selector not lowered");
  is($observed->{lowering}[$index]{error},
   "aggregate_selector_removed surface=$surface identifier=item replacement=item\n",
   "$first $surface exact public retirement diagnostic");
 }
 for my $index (2, 3) {
  is($observed->{lowering}[$index]{error}, undef, "$first bare lowering succeeds $index");
  ok(defined($observed->{lowering}[$index]{value}) && length($observed->{lowering}[$index]{value}),
   "$first bare lowering emits source $index");
 }
 is($observed->{parser_type}, 'CODE', "$first supported fixture compiles");
 is($observed->{error}, undef, "$first supported fixture no exception");
 is($observed->{last_error}, undef, "$first supported fixture no runtime error");
 is_deeply($observed->{value}, $contract->{fixture}{expected}, "$first supported fixture live result");
 ok(defined($observed->{generated}) && length($observed->{generated}), "$first standalone source retained");
 is($observed->{generated_error}, undef, "$first standalone source independently loads and executes");
 is_deeply($observed->{generated_value}, $contract->{fixture}{expected}, "$first standalone runtime result");
 delete $observed->{first};
 push @public, $observed;
}
is_deeply($public[0], $public[1], 'all public observations and full emitted bytes independent of first container');
done_testing;
