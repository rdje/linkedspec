use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use File::Path qw(make_path);
use Scalar::Util qw(blessed reftype);

sub plain {
    my ($value) = @_;
    return $value unless ref($value);
    my $type = reftype($value) // '';
    my $fields = $type eq 'HASH' ? {map { $_ => plain($value->{$_}) } keys %$value}
        : $type eq 'ARRAY' ? [map { plain($_) } @$value] : "$value";
    return blessed($value) ? {class => ref($value), fields => $fields} : $fields;
}

my $out = '.linkedspec-data/scratch/selfcontain133040';
make_path($out);
my $original_path = 'tests/language-readiness/composed/normalization.spec';
open my $source_fh, '<', $original_path or die $!;
my $original = do { local $/; <$source_fh> };
close $source_fh or die $!;
my $helper_source = $original;
my $replaced = $helper_source =~ s/while\(i < count\(pieces\)\) \{ visited = visited \+ 1; i = i \+ 1 \}/while(num_lt(i,count(pieces))) { visited = num_add(visited,1); i = num_add(i,1) }/g;
die "expected exactly one original loop" unless $replaced == 1;
my @cases = (
    ['original', undef],
    ['original-helpers', undef],
    ['count-direct', 'pieces=["a","b"]; return(count(pieces))'],
    ['loop-infix', 'pieces=["a","b"]; i=0; while(i < count(pieces)) { i=i+1 }; return(i)'],
    ['loop-helpers', 'pieces=["a","b"]; i=0; while(num_lt(i,count(pieces))) { i=num_add(i,1) }; return(i)'],
    ['loop-words', 'pieces=["a","b"]; i=0; while(lt(i,count(pieces))) { i=add(i,1) }; return(i)'],
    ['loop-symbols', 'pieces=["a","b"]; i=0; while(<(i,count(pieces))) { i=+(i,1) }; return(i)'],
    ['increment-infix', 'i=2; i=i+1; return(i)'],
    ['increment-helper', 'i=2; i=num_add(i,1); return(i)'],
    ['condition-infix', 'i=2; if(i < 1) { return("yes") }; return("no")'],
    ['condition-helper', 'i=2; if(num_lt(i,1)) { return("yes") }; return("no")'],
);
my @rows;
for my $case (@cases) {
    my ($id, $action) = @$case;
    print STDERR "capturing $id\n";
    my $source = defined($action) ? "Top:: I { $action }"
        : $id eq 'original-helpers' ? $helper_source : $original;
    my $input_text = $id =~ /^original/ ? 'ab-cd' : 'x';
    my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
    my ($dump, %ctx);
    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx,
        dump_parser_source => 1, parser_source_ref => \$dump);
    my ($value, $exception, $stdout, $stderr) = (undef, undef, '', '');
    {
        open my $capture_out, '>', \$stdout or die $!;
        open my $capture_err, '>', \$stderr or die $!;
        local *STDOUT = $capture_out;
        local *STDERR = $capture_err;
        my $input = $input_text;
        my $ran = eval { $value = $parser->(\$input); 1 };
        $exception = plain($@) unless $ran;
    }
    my $emitted = LinkedSpec::emit_generated_source(\$source,
        source_identity => "normalization-$id.spec");
    open my $fh, '>', "$out/$id.pl" or die $!;
    print {$fh} $emitted;
    close $fh or die $!;
    push @rows, {id => $id, source => $source, source_sha256 => sha256_hex($source),
        input => $input_text, action => $action,
        ast => defined($action) ? LinkedSpec::ActionIR::AST::parse_action_block($action) : undef,
        metadata => $descriptor->{spec}{Top}{meta}{action_rewriter},
        substitution => defined($action) ? LinkedSpec::call_spec_handler_subst('Top', $action) : undef,
        native => {value => $value, error => $ctx{last_error}, exception => $exception,
            stdout => $stdout, stderr => $stderr},
        dump => $dump, dump_sha256 => sha256_hex($dump // ''),
        emitted => $emitted, emitted_sha256 => sha256_hex($emitted)};
}
open my $fh, '>', "$out/native.json" or die $!;
print {$fh} JSON::PP->new->canonical->pretty->encode(plain(\@rows));
close $fh or die $!;
system($^X, '-Iperl', 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0-fresh.pl');
die "fresh child failed: $?" if $?;
print "eleven public normalization controls captured\n";
