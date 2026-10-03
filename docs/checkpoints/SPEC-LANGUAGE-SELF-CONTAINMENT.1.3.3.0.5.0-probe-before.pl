use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use JSON::PP ();
use Scalar::Util qw(blessed reftype);
use Digest::SHA qw(sha256_hex);
use IPC::Open2 qw(open2);

my $json = JSON::PP->new->canonical;
sub project {
    my ($value) = @_;
    return [map { project($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return {map(($_ => project($value->{$_})), keys %$value),
        blessed($value) ? (observed_class => blessed($value)) : ()}
        if (reftype($value) // '') eq 'HASH';
    return $value;
}
my @cases = (
    ['deferred_original', 'Top:: I { cb={|x,y| if(matches(x, /ok/)) { return(x) }; return("miss") }; return(cb("ok","unused")) }'],
    ['deferred_false', 'Top:: I { cb={|x,y| if(matches(x, /ok/)) { return(x) }; return("miss") }; return(cb("no","unused")) }'],
    ['deferred_true', 'Top:: I { cb={|| if(true) { return("hit") }; return("miss") }; return(cb()) }'],
    ['deferred_else', 'Top:: I { cb={|| if(false) { return("bad") } else { return("hit") }; return("miss") }; return(cb()) }'],
    ['deferred_elseif', 'Top:: I { cb={|| if(false) { return("bad") } elseif(true) { return("hit") } else { return("bad") }; return("miss") }; return(cb()) }'],
    ['deferred_nested', 'Top:: I { cb={|| if(true) { if(true) { return("hit") }; return("bad") }; return("miss") }; return(cb()) }'],
    ['deferred_when', 'Top:: I { cb={|| when(true) { return("hit") } otherwise { return("miss") }; return(cb()) }'],
    ['deferred_marker', 'Top:: I { cb={|| if(true); return("hit"); else(); return("miss"); endif() }; return(cb()) }'],
    ['deferred_inline', 'Top:: I { cb={|| return(if(true,"hit",else("miss"))) }; return(cb()) }'],
    ['direct_attached', 'Top:: I { if(true) { return("hit") }; return("miss") }'],
    ['function_attached', 'fn choose(x) { if(matches(x, /ok/)) { return(x) }; return("miss") } Top:: I { return(choose("ok")) }'],
    ['function_false', 'fn choose(x) { if(matches(x, /ok/)) { return(x) }; return("miss") } Top:: I { return(choose("no")) }'],
    ['bridged_attached', 'fn choose(x) { if(matches(x, /ok/)) { return(x) }; return("miss") } Top:: I { cb={|| return(choose("ok")) }; return(cb()) }'],
    ['early_return_scope', 'Top:: I { x="outside"; cb={|x| return(x); return("bad") }; value=cb("inside"); return([value,x]) }'],
    ['implicit_result', 'Top:: I { cb={|| "hit" }; return(cb()) }'],
    ['deferred_effect', 'Top:: I { effects=[]; cb={|| push(effects,"before"); if(true) { push(effects,"branch"); return("hit") }; push(effects,"after"); return("miss") }; return(cb()) }'],
);
my @rows;
for my $case (@cases) {
    my ($id, $source) = @$case;
    my (%ctx, $dump, $value, $failure, $stdout, $stderr, $emitted, $descriptor);
    $stdout = $stderr = '';
    {
        open my $out, '>', \$stdout or die $!;
        open my $err, '>', \$stderr or die $!;
        local *STDOUT = $out;
        local *STDERR = $err;
        my $ok = eval {
            my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx,
                dump_parser_source => 1, parser_source_ref => \$dump);
            $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
            my $input = '';
            $value = $parser->(\$input);
            $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => "$id.spec");
            1;
        };
        $failure = $@ unless $ok;
    }
    my $fresh;
    if (defined $emitted) {
        my $pid = open2(my $child_out, my $child_in, $^X, '-Iperl',
            'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-fresh.pl');
        print {$child_in} $json->encode({emitted => $emitted});
        close $child_in or die $!;
        my $reply = do { local $/; <$child_out> };
        close $child_out or die $!;
        waitpid($pid, 0);
        die 'fresh observer failed' if $?;
        $fresh = $json->decode($reply);
    }
    my $meta = $descriptor ? $descriptor->{spec}{Top}{meta}{action_rewriter} : undef;
    push @rows, {id => $id, source => $source, source_sha256 => sha256_hex($source),
        dump => $dump, emitted => $emitted,
        emitted_sha256 => defined($emitted) ? sha256_hex($emitted) : undef,
        native => {value => project($value), exception => project($failure),
            context_error => project($ctx{last_error}), stdout => $stdout, stderr => $stderr},
        fresh => $fresh, metadata => project($meta)};
}
my @ast;
for my $source (
    '{|x,y| if(matches(x, /ok/)) { return(x) }; return("miss") }',
    '{|| if(false) { return("bad") } elseif(true) { return("hit") } else { return("miss") } }',
    '{|| when(true) { return("hit") } otherwise { return("miss") } }',
    '{|| if(true); return("hit"); else(); return("miss"); endif() }',
) {
    push @ast, {source => $source, node => project(LinkedSpec::ActionIR::AST::parse_action_expr($source))};
}
print $json->pretty->encode({cases => \@rows, literal_ast => \@ast});
