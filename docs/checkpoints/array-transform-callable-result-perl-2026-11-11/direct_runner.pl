use strict;
use warnings;
use LinkedSpec ();
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use IO::Compress::Gzip qw(gzip $GzipError);

my ($test) = @ARGV;
die 'one selected direct normal required' unless @ARGV == 1
 && ($test eq 't/array_transform_result_guard_composition.t' || $test eq 't/array_pipeline_callable_result_guard_composition.t');
my $output = $ENV{LINKEDSPEC_CALLABLE_TRANSFORM_DIRECT_CAPTURE} // '';
die 'owned direct output required' unless $output =~ m{\Adocs/checkpoints/array-transform-callable-result-perl-2026-11-11/direct\z}
 && -d $output && !-l $output;
my $serial = 0;
sub retain {
 my ($kind, $body) = @_;
 return unless defined $body;
 my $path = $output . '/api_' . $$ . '_' . ++$serial . '.' . $kind . '.gz';
 die 'one-shot direct artifact exists' if -e $path;
 gzip \$body => $path or die $GzipError;
 print STDERR 'CALLABLE_ARRAY_TRANSFORM_DIRECT_ARTIFACT ' . JSON::PP->new->canonical->ascii->encode({
  path => $path, kind => $kind, bytes => length($body), sha256 => sha256_hex($body),
 }) . "\n";
}
my $get = \&LinkedSpec::Get;
my $emit = \&LinkedSpec::emit_generated_source;
{
 no warnings 'redefine';
 *LinkedSpec::Get = sub {
  my ($source, @options) = @_;
  retain('spec', $$source) if ref($source) eq 'SCALAR';
  die 'direct Get option pairs required' if @options % 2;
  my %options = @options;
  my $handler;
  my $pointer = $options{parser_source_ref};
  unless ($options{return_descriptor} || $pointer) {
   $pointer = \$handler;
   push @options, dump_parser_source => 1, parser_source_ref => $pointer;
  }
  my $answer = $get->($source, @options);
  retain('handler', $$pointer) if ref($pointer) eq 'SCALAR';
  return $answer;
 };
 *LinkedSpec::emit_generated_source = sub {
  my ($source, @options) = @_;
  retain('spec', $$source) if ref($source) eq 'SCALAR';
  my $answer = $emit->($source, @options);
  retain('pm', $answer);
  return $answer;
 };
}
# A do-loaded test must retain its normal t/ FindBin context.
require FindBin;
require Cwd;
no warnings 'once';
local $FindBin::Bin = Cwd::abs_path('t');
do "./$test";
die $@ if $@;
require Test::More;
Test::More::done_testing() unless Test::More->builder->has_plan;
