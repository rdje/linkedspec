use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::SourceLocation ();

my $json = JSON::PP->new->canonical->allow_nonref;
my $retained;
if (@ARGV) {
    die 'only --replay is supported' unless @ARGV == 1 && $ARGV[0] eq '--replay';
    local $/; $retained = $json->decode(<STDIN>);
}
my %lowering = $retained ? %{$retained->{lowering}} : (
    count => LinkedSpec::call_spec_handler_subst('Top', q{return((items += value).count())}),
    key => LinkedSpec::call_spec_handler_subst('Top', q{set_key(meta,key,value)}),
    capture => LinkedSpec::call_spec_handler_subst('Top', q{return(\(my $capt = capture_slice()))}),
);
my @counts;
for my $initial ([], ['seed']) {
    my $items = $json->decode($json->encode($initial));
    my $value = 'tail';
    my $execute = eval 'sub { ' . $lowering{count} . ' }';
    my $error = "$@";
    my $result = $execute ? eval {$execute->()} : undef;
    $error ||= "$@";
    push @counts, {initial => $initial, value => $result, binding => $items, error => $error};
}

my $materialized = 'do { my @__ls_evaluated_values = ($key); @__ls_evaluated_values }';
my @keys;
for my $fault (0, 1) {
    my $code = $lowering{key};
    my $materializers = () = $code =~ /\Q$materialized\E/g;
    die 'key materializer not uniquely found' unless $materializers == 1;
    $code =~ s/\Q$materialized\E/\$key/ if $fault;
    $code =~ s/\$value\b/do { \$key = "later"; \$value }/g;
    my $meta = {seed => 'kept'};
    my ($key, $value) = ('first', 'payload');
    my $execute = eval 'sub { ' . $code . '; return($meta) }';
    my $error = "$@";
    my $result = $execute ? eval {$execute->()} : undef;
    $error ||= "$@";
    push @keys, {fault => $fault, code => $code, result => $result, key => $key, error => $error};
}

my $unguarded = q{return \(my $capt = do { LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $IPOS, $LSPOS - length($LMATCH), "capture_slice") })};
my @captures;
for my $case (
    ['available', 0, 3, 'c', 'ab'], ['empty', 0, 0, '', ''],
    ['missing_boundary', undef, 3, 'c', undef], ['missing_position', 0, undef, 'c', undef],
    ['missing_match', 0, 3, undef, undef], ['reversed', 3, 2, 'x', undef],
) {
    for my $fault (0, 1) {
        my ($IPOS, $LSPOS, $LMATCH) = @$case[1 .. 3];
        my $text = 'abc'; my $STRING = \$text; my $info = {};
        my (@calls, @warnings, $result, $error);
        {
            no warnings 'redefine';
            local *LinkedSpec::SourceLocation::Runtime::span_text = sub {
                push @calls, {start => $_[2], end => $_[3], helper => $_[4]};
                return substr(${$_[1]}, $_[2], $_[3] - $_[2]);
            };
            local $SIG{__WARN__} = sub {push @warnings, @_};
            my $code = $fault ? $unguarded : $lowering{capture};
            my $execute = eval 'sub { ' . $code . ' }';
            $error = "$@";
            $result = $execute ? eval {$execute->()} : undef;
            $error ||= "$@";
        }
        push @captures, {id => $case->[0], expected => $case->[4], fault => $fault,
            kind => ref($result), value => ref($result) eq 'SCALAR' ? $$result : undef,
            calls => \@calls, warnings => \@warnings, error => $error};
    }
}

my @public;
my $serial = 0;
for my $case (
    ['count_once', q{items=[]; trace=""; n=(items += {trace=cat(trace,"V"); return("tail")}).count(); return([n,items,trace])}],
    ['key_snapshot', q{meta={}; key="first"; trace=""; set_key(meta,key,{trace=cat(trace,"V"); key="later"; return("payload")}); return([meta,key,trace])}],
) {
    my $source = "Top:: I { $case->[1] }\n";
    my (%context, $native, $output);
    {
        open my $capture, '>', \$output or die $!;
        local *STDOUT = $capture;
        my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
        my $input = 'x'; $native = $parser->(\$input);
    }
    die 'replay source mismatch' if $retained && $retained->{public}[$serial]{source} ne $source;
    my $emitted = $retained ? $retained->{public}[$serial]{emitted}
        : LinkedSpec::emit_generated_source(\$source, source_identity => 'ast-calibration.spec');
    my $package = 'ASTCalibration' . $serial++;
    my $loaded = eval "package $package; $emitted; 1";
    my $error = "$@";
    my $fresh;
    if ($loaded) {
        eval {no strict 'refs'; my $input = 'x'; $fresh = &{$package . '::Execute'}(\$input); 1}
            or $error = "$@";
    }
    push @public, {id => $case->[0], source => $source, emitted => $emitted, native => $native,
        native_error => $context{last_error}, output => $output, loaded => $loaded ? 1 : 0,
        fresh => $fresh, error => $error};
}
print $json->encode({lowering => \%lowering, counts => \@counts, keys => \@keys,
    captures => \@captures, public => \@public}), "\n";
