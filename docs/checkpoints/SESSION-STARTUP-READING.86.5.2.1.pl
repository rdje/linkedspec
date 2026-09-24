#!/usr/bin/env perl
# Run from the repository root through tools/project_data_run.sh.
use strict;
use warnings;
use LinkedSpec ();
use JSON::PP ();
use File::Path qw(make_path);
my $output_dir = '.linkedspec-data/scratch/slash-members86-5-2';
make_path($output_dir);
my $json = JSON::PP->new->canonical;
for my $case (
 ['old_e', "Top::\n I { out=div(14,2) }\n /x/ E { return(42) }\n"],
 ['edge', "Top::\n I { out=/(14,2) }\n -> Done { return(add(out,1)) }\nDone:\n /x/\n"],
 ['same_line_named', "Top::\n I { out=div(14,2) } -> Done { return(add(out,1)) }\nDone:\n /x/\n"],
) {
 my ($id, $source) = @$case;
 my %context;
 my $generated = '';
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context,
  dump_parser_source => 1, parser_source_ref => \$generated);
 my @values;
 for my $text ('x', 'y') {
  my $input = $text;
  my $value = $parser ? $parser->(\$input) : undef;
  push @values, { input => $text, value => $value, error => $context{last_error} };
 }
 my $path = "$output_dir/$id-generated.pl";
 open my $fh, '>', $path or die "cannot write $path: $!";
 print {$fh} $generated;
 close $fh or die "cannot close $path: $!";
 print $json->encode({ id => $id, source => $source, values => \@values,
  generated_path => $path, generated_length => length($generated) }), "\n";
}
