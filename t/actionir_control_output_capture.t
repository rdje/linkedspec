use strict;
use warnings;
use Test::More;
use JSON::PP ();
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use IPC::Open3 ();
use IO::Select ();
use Symbol qw(gensym);

my $baseline_path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.4/before-complete-native-data.json.gz';
my $raw;
gunzip $baseline_path => \$raw or BAIL_OUT("cannot read retained native observations: $GunzipError");
my $captured = JSON::PP->new->decode($raw);
my $instrument = 't/actionir_control_output_native_complete.pl';

sub run_native {
 my (@command) = @_;
 local $ENV{PERL5LIB} = '';
 local $ENV{PERL5OPT} = '';
 local $ENV{LINKEDSPEC_TRACE_LEVEL};
 delete $ENV{LINKEDSPEC_TRACE_LEVEL};
 my $error = gensym;
 my $pid = IPC::Open3::open3(my $input, my $output, $error, @command);
 close $input;
 my $out_number = fileno($output);
 my $err_number = fileno($error);
 my %bytes = ($out_number => '', $err_number => '');
 my $select = IO::Select->new($output, $error);
 while ($select->count) {
  for my $handle ($select->can_read) {
   my $length = sysread($handle, my $buffer, 65536);
   die "cannot read native diagnostic channel: $!" unless defined $length;
   if ($length) { $bytes{fileno($handle)} .= $buffer }
   else { $select->remove($handle); close $handle }
  }
 }
 waitpid($pid, 0);
 my $status = $?;
 return {returncode => ($status & 127) ? 128 + ($status & 127) : $status >> 8,
         stdout => $bytes{$out_number}, stderr => $bytes{$err_number}};
}

for my $selection ([warm => 1], [cold => 3]) {
 my ($mode, $index) = @$selection;
 my @command = ($^X, '-Iperl', $instrument, $mode eq 'cold' ? ('cold') : ());
 my $process = run_native(@command);
 is($process->{returncode}, 0, "$mode actual diagnostic completes");
 is($process->{stderr}, '', "$mode diagnostic keeps its complete quiet stderr channel");
 my $actual = eval {JSON::PP->new->decode($process->{stdout})};
 BAIL_OUT("$mode native diagnostic did not return complete JSON") unless ref($actual) eq 'HASH';
 my $original = $captured->[$index]{observation};
 is_deeply([map {$_->{label}} @{$actual->{rows}}],
  [map {$_->{label}} @{$original->{rows}}], "$mode complete original row order and population");
 my %original = map {$_->{label} => $_} @{$original->{rows}};
 is(scalar(keys %original), scalar(@{$original->{rows}}), "$mode original labels are unique");
 is($actual->{emission_loaded}, $mode eq 'cold' ? 0 : 1, "$mode keeps native emission-channel loading");
 is($actual->{trace_loaded}, 0, "$mode keeps Trace lazy");
 for my $row (@{$actual->{rows}}) {
  my $label = $row->{label};
  is_deeply($row->{native}, $original{$label}{native},
   "$mode/$label preserves complete native arguments/context/maps/values/effects/errors");
  next if $mode eq 'cold';
  my $options = $row->{options};
  my %native_context = map {($_->{key} . '/' . $_->{generation} . '/' . $_->{number}) => $_->{context}}
   @{$row->{native}{calls}};
  my @expected = map {
   my $scalar = $native_context{$_->{key} . '/' . $_->{generation} . '/' . $_->{number}} eq 'scalar';
   +{key => $_->{key}, generation => $_->{generation}, number => $_->{number}, actual_callback => $scalar ? 1 : 0,
     eligible => $scalar && $options->{known} && $_->{generation} == 0 && $_->{key} eq ($options->{key} // '') ? 1 : 0}
  } @{$row->{authority}{calls}};
  is_deeply($row->{authority}{calls}, \@expected,
   "$label uses actual scalar callback frames with own registration");
  is($row->{authority}{parent_packet}, 0,
   "$label cannot lend a dependency publication to its enclosing callback");
  my $matching = $options->{known} && $options->{authority} && grep {
   $_->{key} eq ($options->{key} // '') && $_->{generation} == 0 && $_->{number} == ($options->{number} // 1)
    && defined($_->{value}) && !ref($_->{value}) && $_->{value} eq 'outer'
  } @{$row->{native}{callback_returns}};
  is($row->{authority}{child_packets}, $matching ? 1 : 0,
   "$label retains only its own matching scalar packet");
 }
}
done_testing;
