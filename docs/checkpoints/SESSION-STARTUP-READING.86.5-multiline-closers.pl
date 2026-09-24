#!/usr/bin/env perl
# Fixed compatibility controls for .86.5.1; run through tools/project_data_run.sh.
use strict;
use warnings;
use LinkedSpec ();
use JSON::PP ();
my $json = JSON::PP->new->canonical;
for my $case (
 ['assigned_close', "rx = /(14,2) }\ntext/; return(7)"],
 ['assigned_close_space', "rx = /(14,2) }  \ntext/; return(7)"],
 ['assigned_escaped_close', "rx = /(14,2) \\}\ntext/; return(7)"],
 ['helper_close', "return(matches(\"14,2 }\\ntext\", /(14,2) }\ntext/))"],
 ['host_close', "rx = qr/(14,2) }\ntext/; return(7)"],
) {
 my ($id, $action) = @$case;
 my $source = "Top::\n -> Done { $action }\nDone:\n /x/\n";
 my %context;
 my $parser = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
 my $build_error = "$@";
 my $input = 'x';
 my $value = $parser ? eval { $parser->(\$input) } : undef;
 my $runtime_error = "$@";
 print $json->encode({id=>$id, parser_ready=>$parser?1:0, value=>$value,
  source=>$source, build_error=>$build_error, runtime_error=>$runtime_error,
  last_error=>$context{last_error}}), "\n";
}
