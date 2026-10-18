use strict;
use warnings;
use Test::More;
use JSON::PP ();
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use IPC::Open3 ();
use IO::Select ();
use Symbol qw(gensym);

my $baseline_path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.5/before-complete-native-data.json.gz';
my $raw;
gunzip $baseline_path => \$raw or BAIL_OUT("cannot read retained native observations: $GunzipError");
my $captured = JSON::PP->new->decode($raw);
my $instrument = 't/actionir_control_kind_native_complete.pl';

sub run_native {
 my (@command) = @_;
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
  my $display = $label;
  $display =~ s/([^\x00-\x7f])/sprintf('U+%04X', ord($1))/eg;
  is_deeply($row->{native}, $original{$label}{native},
   "$mode/$display preserves complete native arguments/context/maps/values/effects/errors");
  next if $mode eq 'cold';
  my $options = $row->{options};
  my $actual_code = !defined($options->{variant}) || $options->{variant} eq 'code';
  my @expected = map { +{
   actual_callback => $actual_code ? 1 : 0,
   eligible => $actual_code && $options->{known} ? 1 : 0,
  } } @{$row->{authority}{calls}};
  is_deeply($row->{authority}{calls}, \@expected,
   "$display captures each actual callback independently with only its own registration");
  is($row->{authority}{parent_packet}, 0,
   "$display cannot lend a dependency publication to its enclosing callback");
  is($row->{authority}{child_packets}, $label =~ m{^child/} && $options->{known} ? 1 : 0,
   "$display retains only an actually registered matching child's own packet");
 }
}
done_testing;
