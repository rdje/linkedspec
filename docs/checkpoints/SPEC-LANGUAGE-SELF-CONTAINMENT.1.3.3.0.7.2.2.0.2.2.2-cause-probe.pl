use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::ActionIR::SourceMembership ();
use LinkedSpec::ActionIR::MethodExpr ();
use JSON::PP ();
use Scalar::Util qw(blessed reftype refaddr);
use IPC::Open2 qw(open2);

sub project {
    my ($value) = @_;
    return [map { project($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return {map(($_ => project($value->{$_})), keys %$value),
        blessed($value) ? (observed_class => blessed($value)) : ()}
        if (reftype($value) // '') eq 'HASH';
    return "$value" if ref($value);
    return $value;
}

my $json = JSON::PP->new->canonical->utf8;
my @results;
for my $params ('x,y', 'x,z', 'x,...y') {
  for my $pattern ('/(set(counter,1)).*x/', '/(set(counter,1)),x/') {
    my $action = 'cb={|' . $params . '| return(matches("setcounter,1,x", ' . $pattern . ')) }; return(cb("ok","unused"))';
    my $source = 'Top:: I { ' . $action . ' }';
    my ($ast, $substitution, $descriptor, $dump, $emitted, $value, %ctx, %errors);
    my $stdout = '';
    my $stderr = '';
    my ($scan, $selected, $ranges);
    my @source_origins;
    {
        open my $out, '>', \$stdout or die $!;
        open my $err, '>', \$stderr or die $!;
        local *STDOUT = $out;
        local *STDERR = $err;
        $ast = LinkedSpec::ActionIR::AST::parse_action_block($action);
        $ranges = LinkedSpec::ActionIR::SourceMembership::_literal_source_ranges($action);
        {
            my $original = \&LinkedSpec::ActionIR::SourceMembership::_select_executable_source_events;
            no warnings 'redefine';
            local *LinkedSpec::ActionIR::SourceMembership::_select_executable_source_events = sub {
                my $result = $original->(@_);
                my $saved = $@;
                if ($_[0] eq $action) {
                    $scan = $_[1]; $selected = $result;
                    my %chosen = map { refaddr($_) => 1 } @{$result->{events}};
                    push @source_origins, map { {contract_id => $_->{event}{contract_id},
                        raw => $_->{event}{raw}, span => $_->{source_span},
                        selected => $chosen{refaddr($_->{event})} ? 1 : 0} }
                        @{$scan->{source_origins}};
                }
                $@ = $saved;
                return $result;
            };
            eval { $substitution = LinkedSpec::call_spec_handler_subst('Top', $action); 1 }
                or $errors{substitution} = project($@);
        }
        die 'actual compiler selection was not observed' unless $scan && $selected;
        eval { $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1); 1 }
            or $errors{descriptor} = project($@);
        eval {
            my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx,
                dump_parser_source => 1, parser_source_ref => \$dump);
            my $input = 'x';
            $value = $parser->(\$input);
            1;
        } or $errors{native} = project($@);
        eval { $emitted = LinkedSpec::emit_generated_source(\$source,
            source_identity => 'signature-' . $params . '.spec'); 1 }
            or $errors{emitted} = project($@);
    }
    my $fresh;
    if (defined $emitted) {
        my $pid = open2(my $child_out, my $child_in, $^X, '-Iperl',
            'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-fresh.pl');
        binmode $child_in, ':raw';
        binmode $child_out, ':raw';
        print {$child_in} $json->encode({emitted => $emitted, input => 'x'});
        close $child_in or die $!;
        my $reply = do { local $/; <$child_out> };
        close $child_out or die $!;
        waitpid($pid, 0);
        die 'fresh observer failed' if $?;
        $fresh = $json->decode($reply);
    }
    push @results, {
        params => $params, pattern => $pattern, action => $action, source => $source, expected => 1,
        ast => project($ast), substitution => $substitution, dump => $dump, emitted => $emitted,
        metadata => project($descriptor ? $descriptor->{spec}{Top}{meta}{action_rewriter} : undef),
        literal_ranges => [map { {start => $_->[0], end => $_->[1],
            text => substr($action, $_->[0], $_->[1] - $_->[0])} } @$ranges],
        source_origins => \@source_origins,
        helper_patterns => LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges($action),
        signature_closer => {start => index($action, '|', index($action, '|') + 1),
            host_quote_end => LinkedSpec::ActionIR::MethodExpr::_host_quote_end(
                $action, index($action, '|', index($action, '|') + 1))},
        pattern_start => index($action, '/'),
        numeric_slash_discriminator => LinkedSpec::ActionIR::MethodExpr::_looks_like_slash_symbol_call_at(
            $action, index($action, '/'), 1) ? 1 : 0,
        native => {value => project($value), context_error => project($ctx{last_error}),
            stdout => $stdout, stderr => $stderr}, fresh => $fresh, errors => \%errors,
    };
  }
}
print $json->pretty->encode(\@results);
