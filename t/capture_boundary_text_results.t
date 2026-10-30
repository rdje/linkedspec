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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'capture-boundary-text.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::CaptureBoundaryText'.++$sequence;
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
        diag('CAPTURE_TEXT_ACTUAL '.$name.' '.$json->encode($actual));
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

my $input = "\x{03b1}\x{03b2}:cat";
my @readers = qw(capture_slice capture_slice_until_cursor capture_rest capture_from_rule_start);
check_source('frozen readonly capture String target', read_file('tests/fixtures/capture_boundary_text_values.spec'), $input,
    $json->decode(read_file('tests/fixtures/capture_boundary_text_values.json')), 6, 'Value');

for my $helper (@readers) {
    my $text = $helper eq 'capture_slice' || $helper eq 'capture_from_rule_start' ? ':' : ':cat';
    check_source("$helper direct defined default", capture_source('return('.$helper.'().coalesce("fallback").cat("!"))'),
        $input, [$text.'!'], 6, 'Value');
}

check_source('primitive and bound controls remain intact', capture_source(q{
 original=[capture_slice(),capture_slice_until_cursor(),capture_rest(),capture_from_rule_start()];
 tail=capture_rest();return([original,tail.split(":")[-1].uppercase()]);
}), $input, [[[':',':cat',':cat',':'],'CAT']], 6, 'Value');
check_source('initial absence and defined empty retain their distinct policies', q{
Top:: I {return([capture_slice().coalesce("missing").cat("!"),capture_from_rule_start().coalesce("alias").uppercase(),capture_rest().coalesce("bad").cat("!"),capture_slice_until_cursor().coalesce("bad").cat("!")])}
}, 'x', ['missing!','ALIAS','x!','!'], 0, 'Top');
check_source('reversed span uses existing missing fallback', capture_source(q{
 start_capture_slice();return([capture_slice().coalesce("reversed").cat("!"),capture_slice_pos()]);
}), $input, [['reversed!',6]], 6, 'Value');
check_source('String zero survives split selection and default', capture_source(q{
 return(capture_rest().coalesce("bad").split(":")[-1].coalesce("bad"));
}, '0'), "\x{03b1}\x{03b2}:0", ['0'], 4, 'Value');
check_source('legacy first consumer and with returned kind stay intact', capture_source(q{
 order="";a=capture_rest().take({order=cat(order,"BAD");1});
 b=capture_rest().with() {return(["ok"])}.first().uppercase();return([a,b,order]);
}), $input, [[[],'OK','']], 6, 'Value');
check_source('readonly sources keep pure-function fences',
    'fn forbidden(){return(['.join(',',map { $_.'()' } @readers).'])} Top:: I {return(forbidden())}',
    'x', [(undef)x@readers], 0, 'Top', \@readers);
check_source('direct defaults retain specific pure-function fence',
    'fn forbidden(){return(capture_rest().coalesce("M").cat("!"))} Top:: I {return(forbidden())}',
    'x', 'M!', 0, 'Top', ['capture_rest']);

done_testing;
