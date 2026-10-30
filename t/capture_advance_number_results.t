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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'capture-advance-number.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::CaptureAdvanceNumber'.++$sequence;
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
        diag('CAPTURE_ADVANCE_NUMBER_ACTUAL '.$name.' '.$json->encode($actual));
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

# TYPE-REFERENCE-BOOK.1.2.23.3.52.1 — existing advancing Number results.
my $input = "\x{03b1}\x{03b2}:catTAIL";
my @sources = (
    ['capture_take_len', 1, 6],
    ['capture_take_until_cursor_len', 4, 6],
    ['capture_take_rest_len', 8, 10],
);
check_source('frozen advancing capture Number target',
    read_file('tests/fixtures/capture_advance_number_values.spec'), $input,
    $json->decode(read_file('tests/fixtures/capture_advance_number_values.json')), 6, 'Value');
for my $case (@sources) {
    my ($helper, $width, $origin) = @$case;
    check_source("$helper direct continuation", capture_source('return(['.$helper.'().coalesce(99).add(1).cat("!"),capture_slice_pos(),cursor_pos()])'),
        $input, [[($width+1).'!', $origin, 6]], 6, 'Value');
    check_source("$helper bound continuation retains native effects", capture_source('part='.$helper.'();return([part.coalesce(99).add(1).cat("!"),capture_slice_pos(),cursor_pos()])'),
        $input, [[($width+1).'!', $origin, 6]], 6, 'Value');
}
check_source('unavailable local match keeps the origin',
    q{Top:: I {return([capture_take_len().coalesce(99).cat("!"),capture_slice_pos(),cursor_pos()])}},
    'x', ['99!',0,0], 0, 'Top');
check_source('zero and reversed reads retain distinct fallback behavior', capture_source(q{
 first=capture_take_until_cursor_len();order="";
 zero=capture_take_until_cursor_len().coalesce({order=cat(order,"F");99}).add(1);
 missing=capture_take_len().coalesce(99).cat("!");
 return([first,zero,missing,capture_slice_pos(),cursor_pos(),order]);
}), $input, [[4,1,'99!',6,6,'']], 6, 'Value');
check_source('Number snapshot precedes a later boundary reset', capture_source(q{
 width=capture_take_rest_len().coalesce(0);
 snapshot=width.cat({start_capture_slice();"!"});
 return([width,snapshot,capture_slice_pos(),cursor_pos()]);
}), $input, [[8,'8!',6,6]], 6, 'Value');
check_source('named width source retains separate mark effects', capture_source(q{
 mark_capture_slice(begin);
 out=capture_take_len_from(begin).coalesce(99).add(1).cat("!");
 return([out,mark_pos(begin),capture_slice_pos(),cursor_pos()]);
}), $input, [['2!',6,2,6]], 6, 'Value');
my @readers = map { $_->[0] } @sources;
check_source('all advancing Number sources keep pure-function fences',
    'fn forbidden(){return(['.join(',', map { $_.'()' } @readers).'])} Top:: I {return(forbidden())}',
    'x', [(undef)x@readers], 0, 'Top', \@readers);
check_source('direct Number fallback retains the specific function fence',
    q{fn forbidden(){return(capture_take_len().coalesce(99).cat("!"))} Top:: I {return(forbidden())}},
    'x', '99!', 0, 'Top', ['capture_take_len']);
done_testing;
