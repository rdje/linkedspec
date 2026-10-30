use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

my $json = JSON::PP->new->canonical->allow_nonref;
my $sequence = 0;

sub read_file {
    my ($path) = @_;
    open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
    local $/;
    my $text = <$fh>;
    close $fh or die $!;
    return $text;
}

sub error_value {
    my ($error) = @_;
    return undef unless defined($error) && (ref($error) || length($error));
    if ((reftype($error) // '') eq 'HASH') {
        my %result = map { $_ => ref($error->{$_}) ? error_value($error->{$_}) : $error->{$_} }
            grep { exists $error->{$_} } qw(type code stage detail summary helper_name name);
        $result{class} = ref($error) if ref($error) ne 'HASH';
        return \%result;
    }
    return "$error";
}

sub capture_source {
    my ($body, $tail) = @_;
    $tail //= 'cat';
    return "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>\x{03b1}\x{03b2})/\n /:/\n /$tail/\n -> Value[2] {$body}\n";
}

sub observe_source {
    my ($source, $input, $rule) = @_;
    my (%context, @warnings, %result);
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    my $native = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
    $result{build_error} = error_value($@);
    $result{native_callable} = ref($native) eq 'CODE' ? 1 : 0;
    if ($result{native_callable}) {
        my $text = $input;
        $result{native} = eval { $native->(\$text) };
        $result{native_error} = error_value($@ || $context{last_error});
        $result{native_cursor} = pos($text);
    }
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'boundary-capture-fluent.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::BoundaryCaptureFluent'.++$sequence;
    my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
    $result{loaded} = $loaded ? 1 : 0;
    $result{load_error} = error_value($@);
    if ($loaded) {
        my $text = $input;
        $result{fresh} = eval { $package->can('Execute')->(\$text) };
        $result{fresh_error} = error_value($@);
        $result{fresh_cursor} = pos($text);
    }
    my $descriptor = eval { LinkedSpec::Get(\$source, return_descriptor => 1) };
    $result{descriptor_error} = error_value($@);
    my $meta = $descriptor->{spec}{$rule}{meta}{action_rewriter};
    $result{metadata} = {map { $_ => $meta->{$_} } qw(canonical_action_ir_fallback_count raw_perl_dependency_count unresolved_helper_count unresolved_helpers language_agnostic_action_ir_ready)};
    $result{warnings} = \@warnings;
    return \%result;
}

sub check_source {
    my ($name, $source, $input, $expected, $cursor, $rule, $unsupported) = @_;
    return if @ARGV && !grep { $_ eq $name } @ARGV;
    $unsupported //= [];
    subtest $name => sub {
        my $actual = observe_source($source, $input, $rule);
        diag('BOUNDARY_CAPTURE_ACTUAL '.$name.' '.$json->encode($actual));
        ok($actual->{native_callable} && !$actual->{build_error} && !$actual->{native_error}, 'native executes without handler error');
        is($json->encode($actual->{native}), $json->encode($expected), 'native exact values and kinds');
        is($actual->{native_cursor}, $cursor, 'native cursor preserved');
        ok($actual->{loaded} && !$actual->{emission_error} && !$actual->{load_error}, 'fresh source loads');
        ok($actual->{loaded} && !$actual->{fresh_error}, 'fresh execution succeeds');
        is($json->encode($actual->{fresh}), $json->encode($expected), 'fresh exact values and kinds');
        is($actual->{fresh_cursor}, $cursor, 'fresh cursor preserved');
        ok(!$actual->{descriptor_error}, 'descriptor resolves');
        is_deeply($actual->{warnings}, [], 'build/load/run stay warning-free');
        my $meta = $actual->{metadata};
        is($meta->{raw_perl_dependency_count}, 0, 'no raw dependency');
        is($meta->{canonical_action_ir_fallback_count}, 0, 'no fallback executor');
        if (@$unsupported) {
            ok(!$meta->{language_agnostic_action_ir_ready}, 'pure-function state access remains unready');
            my %found = map { $_ => 1 } @{$meta->{unresolved_helpers} // []};
            ok($found{$_}, "specific forbidden helper $_ retained") for @$unsupported;
        } else {
            is($meta->{unresolved_helper_count}, 0, 'ordinary sources resolve');
            ok($meta->{language_agnostic_action_ir_ready}, 'readiness accompanies actual execution');
        }
    };
}

# TYPE-REFERENCE-BOOK.1.2.23.3.53.1 — existing structural-boundary String.
sub boundary_source {
    my ($body, $end) = @_;
    $end //= 'END';
    return "Top::\n I {$body}\nEnd:OR{1,1}\n /$end/\nFar:OR{1,1}\n /TAIL/\n";
}
my $input = "\x{03b1}\x{03b2}:ENDTAIL";
my $head = "\x{03b1}\x{03b2}:";
check_source('frozen structural boundary fluent target',
    read_file('tests/fixtures/boundary_capture_fluent_values.spec'), $input,
    $json->decode(read_file('tests/fixtures/boundary_capture_fluent_values.json')), 10, 'Top');
check_source('direct String continuation retains cursor effect',
    boundary_source(q{return([capture_until_boundary(End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])}),
    $input, [$head.'!',3,0], 3, 'Top');
check_source('bound String continuation preserves native capture',
    boundary_source(q{part=capture_until_boundary(End);return([part.coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])}),
    $input, [$head.'!',3,0], 3, 'Top');
check_source('direct Number continuation retains character width',
    boundary_source(q{return([capture_until_boundary(End).coalesce("").length().add(1),cursor_pos(),capture_slice_pos()])}),
    $input, [4,3,0], 3, 'Top');
check_source('repeated defined empty skips lazy fallback',
    boundary_source(q{first=capture_until_boundary(End);order="";empty=capture_until_boundary(End).coalesce({order=cat(order,"F");"fallback"}).cat("!");return([first,empty,cursor_pos(),capture_slice_pos(),order])}),
    $input, [$head,'!',3,0,''], 3, 'Top');
check_source('unresolved boundary stays null without cursor movement',
    boundary_source(q{return([capture_until_boundary(Missing).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])}),
    $input, ['M!',0,0], 0, 'Top');
check_source('usable boundary without later match captures through EOF',
    boundary_source(q{return([capture_until_boundary(End).coalesce("").length().add(1),cursor_pos(),capture_slice_pos()])}, 'ZZZ'),
    $input, [11,10,0], 10, 'Top');
check_source('quoted commas remain one boundary label',
    boundary_source(q{return([capture_until_boundary("a,b,c",End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])})."\nb:OR{1,1}\n /\x{03b1}\x{03b2}/\n",
    $input, [$head.'!',3,0], 3, 'Top');
check_source('multiple boundaries retain earliest rather than argument order',
    boundary_source(q{return([capture_until_boundary(Far,End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])}),
    $input, [$head.'!',3,0], 3, 'Top');
check_source('completed String precedes later capture reset',
    boundary_source(q{part=capture_until_boundary(End).coalesce("M");snapshot=part.cat({start_capture_slice();"!"});return([part,snapshot,cursor_pos(),capture_slice_pos()])}),
    $input, [$head,$head.'!',3,3], 3, 'Top');
check_source('boundary function fence retains specific metadata',
    q{fn forbidden(){return(capture_until_boundary(End).coalesce("M").cat("!"))} Top:: I {return(forbidden())} End:OR{1,1} /END/},
    $input, 'M!', 0, 'Top', ['capture_until_boundary']);
done_testing;
