use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::StatementSplit::Core ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::RuleIR::EmitContext ();

my $json = JSON::PP->new->canonical->utf8;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-';
open my $file, '<:raw', $prefix.'verification.json' or die $!;
my $expected = $json->decode(do { local $/; <$file> })->{expected};
close $file or die $!;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my $split = $deps->{split_action_ir_statements};
my $trim = $deps->{trim_action_ir_value};

sub framed {
    my ($callback, @args) = @_;
    my $entry = LinkedSpec::ActionIR::StatementSplit::Core->can('_split_with_source_frames');
    return $entry->($callback,@args) if $entry;
    # The retained before implementation has no published private frames.
    # Its original callback/result are observed without inventing coordinates.
    return {statements => $callback->(@args), source_frames => []};
}

for my $case (@$expected) {
    subtest $case->{id} => sub {
        my ($calls,$returned) = (0,undef);
        my $result = framed(sub { ++$calls; $returned=$split->(@_); return $returned },$case->{action});
        is($calls,1,'same dependency callback called exactly once');
        is(refaddr($result->{statements}),refaddr($returned),'exact original returned array');
        is_deeply($result->{statements},[map {$_->{raw}} @{$case->{statements}}],'original split strings/order');
        my $frames = [map { +{source=>$case->{action},raw=>$_->{raw},source_span=>{start=>$_->{start},end=>$_->{end}}} } @{$case->{statements}}];
        is_deeply($result->{source_frames},$frames,'independent authored original scalar frames');
    };
}

subtest 'unknown and opaque callbacks keep their exact returns' => sub {
    for my $value (undef, 'opaque', {}, ['my $x']) {
        my $calls=0;
        my $result=framed(sub { ++$calls; return $value },'my $x');
        is($calls,1,'unknown callback once');
        if (ref $value) { is(refaddr($result->{statements}),refaddr($value),'opaque reference identity'); }
        else { is($result->{statements},$value,'opaque scalar identity'); }
        is_deeply($result->{source_frames},[],'no fabricated frames');
    }
    my $text='my $x';
    for my $source ({}, \$text) {
        my $public=$split->($source);
        my $private=framed($split,$source);
        is_deeply($private->{statements},$public,'non-scalar source keeps existing stringification');
        ok(!grep({ defined($_) } @{$private->{source_frames}}),'non-scalar source gains no invented scalar frame');
    }
};

subtest 'custom trim does not invent transformed source' => sub {
    my $result=framed(sub { LinkedSpec::ActionIR::StatementSplit::Core::split_action_ir_statements($_[0],sub { my $s=shift; $s =~ s/#.*//s; $s =~ s/\s+//g; return $s }) },"my #inside\n \$x;");
    is_deeply($result->{statements},['my','$x'],'existing custom transformation retained');
    is_deeply($result->{source_frames},[undef,{source=>"my #inside\n \$x;",raw=>'$x',source_span=>{start=>12,end=>14}}],'transformed entry has no invented span; exact unchanged entry retains its frame');
};

subtest 'copied or changed callback array does not borrow unrelated frames' => sub {
    my $copy=framed(sub { return [@{$split->($_[0])}] },'my $x;');
    is_deeply($copy->{statements},['my $x'],'copied values retained');
    is_deeply($copy->{source_frames},[],'copied array is not canonical producer identity');
    my $changed=framed(sub { my $a=$split->($_[0]);$a->[0]='my $y';return $a },'my $x;');
    is_deeply($changed->{statements},['my $y'],'changed values retained');
    is_deeply($changed->{source_frames},[undef],'changed array entry gets no borrowed origin');
};

subtest 'nested private calls restore the outer collector' => sub {
    my $inner;
    my $outer=framed(sub { $inner=framed($split,'return 7;');return $split->($_[0]) },'my $x;');
    is_deeply($inner->{source_frames},[{source=>'return 7;',raw=>'return 7',source_span=>{start=>0,end=>8}}],'inner exact frame');
    is_deeply($outer->{source_frames},[{source=>'my $x;',raw=>'my $x',source_span=>{start=>0,end=>5}}],'outer exact frame after nesting');
};

subtest 'arguments and callback errors retain existing behavior' => sub {
    my @seen;
    my $result=framed(sub { @seen=@_; return [] },'my $x;',42);
    is_deeply(\@seen,['my $x;',42],'callback signature/argument order preserved');
    is_deeply($result->{source_frames},[],'unknown empty callback has no invented frames');
    my $calls=0;
    my $ok=eval { framed(sub { ++$calls;die "controlled callback failure\n" },'my $x;');1 };
    ok(!$ok,'same callback failure propagates');
    is($@,"controlled callback failure\n",'exact callback error');
    is($calls,1,'throwing callback called once');
};

subtest 'empty canonical inputs remain empty' => sub {
    for my $input (undef,''," \t\r\n;;") {
        my $result=framed($split,$input);
        is_deeply($result,{statements=>[],source_frames=>[]},'empty original result and frames');
    }
};

done_testing;
