use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::ActionIR::StatementSplit ();
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

my $phase = shift // die "phase required";
die "invalid phase" unless $phase =~ /\A(?:red|green|restored-red|reapplied-green)\z/;
my $out = '.linkedspec-data/scratch/selfcontain13302131/' . $phase;
make_path($out);
my @cases;
for my $name (qw(y tr s q qq qx qr m)) {
    push @cases, ["fixed-$name", "{|x,$name| return(x) }"];
    push @cases, ["rest-$name", "{|x,...$name| return(x) }"];
}
push @cases,
    ['zero', '{|| return("ok") }'],
    ['nested', '{|x,y| nested={|s,q| return(s) }; return(nested(x,y)) }'],
    ['quoted', '{|x,y| text="{|s,q|"; return(x) }'],
    ['body-regex', '{|x,y| if(matches(x, /ok/)) { return(x) }; return("miss") }'];
my @rows;
for my $case (@cases) {
    my ($id, $literal) = @$case;
    my $call = $id eq 'zero' ? 'cb()' : 'cb("ok","unused")';
    my $action = "cb=$literal; return($call)";
    my $source = "Top:: I { $action }";
    my $parts = LinkedSpec::ActionIR::StatementSplit::_split_action_ir_statements(
        $action, { trim_action_ir_value => sub { my $s = shift; $s =~ s/^\s+|\s+$//g; $s } });
    my $ast = LinkedSpec::ActionIR::AST::parse_action_expr($literal);
    my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
    my ($dump, %ctx);
    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx,
        dump_parser_source => 1, parser_source_ref => \$dump);
    my ($value, $exception);
    my $input = 'x';
    my $ran = eval { $value = $parser->(\$input); 1 };
    $exception = "$@" unless $ran;
    my $emitted = LinkedSpec::emit_generated_source(\$source,
        source_identity => "signature-$id.spec");
    open my $fh, '>', "$out/$id.pl" or die $!;
    print {$fh} $emitted;
    close $fh or die $!;
    push @rows, {id => $id, source => $source, literal => $literal, ast => $ast,
        source_sha256 => sha256_hex($source), statement_split => $parts,
        metadata => $descriptor->{spec}{Top}{meta}{action_rewriter},
        substitution => LinkedSpec::call_spec_handler_subst('Top', $action),
        native => {value => $value, error => $ctx{last_error}, exception => $exception},
        dump => $dump, dump_sha256 => sha256_hex($dump // ''),
        emitted => $emitted, emitted_sha256 => sha256_hex($emitted)};
}
open my $fh, '>', "$out/native.json" or die $!;
print {$fh} JSON::PP->new->canonical->pretty->encode(plain(\@rows));
close $fh or die $!;
system($^X, '-Iperl',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1-fresh.pl', $phase);
die "fresh child failed: $?" if $?;
print "twenty public signature controls captured: $phase\n";
