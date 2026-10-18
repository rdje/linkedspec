use strict;
use warnings;
use Test::More;
use JSON::PP ();
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use IPC::Open3 ();
use IO::Select ();
use Symbol qw(gensym);

my $prefix = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/';
my $raw;
gunzip($prefix.'before-data.json.gz' => \$raw) or BAIL_OUT($GunzipError);
my $before = JSON::PP->new->decode($raw);
sub run_native {
 my (@command) = @_;
 my $error = gensym;
 my $pid = IPC::Open3::open3(my $input, my $output, $error, @command);
 close $input;
 my ($out_number, $err_number) = (fileno($output), fileno($error));
 my %bytes = ($out_number => '', $err_number => '');
 my $select = IO::Select->new($output, $error);
 while ($select->count) {
  for my $handle ($select->can_read) {
   my $length = sysread($handle, my $buffer, 65536);
   die $! unless defined $length;
   if ($length) { $bytes{fileno($handle)} .= $buffer }
   else { $select->remove($handle); close $handle }
  }
 }
 waitpid($pid, 0);
 return {status => $?, stdout => $bytes{$out_number}, stderr => $bytes{$err_number}};
}
for my $mode ([warm => 1], [cold => 3]) {
 my ($label, $index) = @$mode;
 my $process = run_native($^X, '-Iperl', 't/actionir_default_object_native.pl', $label eq 'cold' ? ('cold') : ());
 is($process->{status}, 0, "$label complete object diagnostic exits");
 is($process->{stderr}, '', "$label complete diagnostic stderr stays quiet");
 my $current = eval {JSON::PP->new->decode($process->{stdout})};
 BAIL_OUT('invalid complete native JSON') unless ref($current) eq 'HASH';
 is(scalar @{$current->{rows}}, 108, "$label reaches all108 original rows");
 my %rows = map {join('/', @$_{qw(owner variant context stage)}) => $_} @{$current->{rows}};
 is(scalar keys %rows, 108, "$label original row labels stay unique");
 is($current->{source_emissions_loaded}, $label eq 'warm' ? 1 : 0, "$label preserves native emission-channel loading");
 is($current->{trace_loaded}, 0, "$label preserves lazy Trace");
 my %original = map {join('/', @$_{qw(owner variant context stage)}) => $_} @{$before->[$index]{observation}{rows}};
 for my $row (@{$current->{rows}}) {
  my $key = join('/', @$row{qw(owner variant context stage)});
  if ($row->{stage} eq 'native-builder') {
   is_deeply($row->{ordinary}, $original{$key}{ordinary}, "$label/$key keeps the complete original native-builder oracle");
  } else {
   my $native_key = join('/', @$row{qw(owner variant context)}, 'native-builder');
   is_deeply($row->{ordinary}, $rows{$native_key}{ordinary}, "$label/$key preserves native object overloads, returns, errors and build context");
  }
  my $native_key = join('/', @$row{qw(owner variant context)}, 'native-builder');
  my @expected = map {
   my $fixed = $label eq 'warm' && $row->{stage} eq 'current-factory'
    && $row->{owner} eq 'LinkedSpec::ActionIR::ControlFlow' && $row->{context} ne 'void'
    && $_->{key} eq 'extract_array_symbol_name';
   +{key => $_->{key}, selected => $fixed ? 1 : 0}
  } @{$original{$native_key}{authority}};
  is_deeply($row->{authority}, \@expected, "$label/$key grants only the actual fixed provider, never facade object aliases");
 }
}
done_testing;
