use 5.010;
use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::SourceLocation ();
use lib '.';
use t::lib::TestHelpers qw(normalize_error);

open my $fixture, '<:raw', 't/phase0_regression.t' or die $!;
my $text; { local $/; $text = <$fixture>; } close $fixture or die $!;
my ($helper) = $text =~ /\n(sub evaluate_lowered_json \{.*?)(?=\nsub discover_specs)/s;
die 'missing real lowered evaluator' unless defined $helper;
eval $helper; die $@ if $@;
if (@ARGV == 1 && $ARGV[0] eq '--fault-controls') {
    require Test::More; Test::More->import;
    require IO::Uncompress::Gunzip;
    my $raw;
    IO::Uncompress::Gunzip::gunzip('tests/language-readiness/phase0-fixture-calibration.json.gz' => \$raw) or die 'fixture table decode';
    my $table=JSON::PP->new->decode($raw);
    my @faults;
    for my $hunk (@{$table->{hunks}}[0,1]) {
        my ($old)=$hunk->{before}=~/q#(.*?)#/s; die 'old capture body missing' unless defined $old;
        push @faults,$old;
    }
    push @faults, 'return 4.5', 'return 4', 'return 4', 'return 3';
    for my $index (0..5) {
        my $fault=$faults[$index];
        my $L=sub { $fault };
        no warnings 'redefine';
        local *LinkedSpec::call_spec_handler_subst=sub { $fault };
        eval $table->{hunks}[$index]{after}; die $@ if $@;
    }
    Test::More::done_testing(); exit;
}
if (@ARGV) {
    die 'only --focused is supported' unless @ARGV == 1 && $ARGV[0] eq '--focused';
    my $warm_source="Top:: I { return(1) }\n";
    LinkedSpec::Get(\$warm_source);
    require Test::More; Test::More->import;
    my @names = qw(bootstrap_named_mark_builds_named_mark_lecode method_chain_capture_slice_return_helper_lowers_without_raw_fallback spec_format_terse_2_3_5_4_number_receiver_value_chains spec_format_terse_2_3_5_5_block_valued_receiver_chains spec_format_terse_3_2_1_numeric_word_aliases spec_format_terse_3_3_3_mutation_assignment_expression_values);
    for my $name (@names) {
        my ($block) = $text =~ /^(subtest '\Q$name\E' => sub \{.*?^\};\n)/ms;
        die "missing exact subtest $name" unless defined $block;
        eval $block; die $@ if $@;
    }
    Test::More::done_testing(); exit;
}
my $json = JSON::PP->new->canonical->allow_nonref;
my %lowering = (
 named => LinkedSpec::call_spec_handler_subst('MoveTop','capture_from(body_start)'),
 width => LinkedSpec::call_spec_handler_subst('Top','return(capture_slice_len())'),
 decimal => LinkedSpec::call_spec_handler_subst('Top','return(3.5.floor().add(1))'),
 block => LinkedSpec::call_spec_handler_subst('Top','return({ 3.5 }.floor().add(2))'),
 mutation => LinkedSpec::call_spec_handler_subst('Top','return((items += value).count())'),
 order => LinkedSpec::call_spec_handler_subst('Top','return(3.5.floor().add(0.75))'),
);
my %evaluated;
for my $name (qw(decimal block order)) { $evaluated{$name}= $json->decode(evaluate_lowered_json($lowering{$name},'')); }
$evaluated{mutation}=$json->decode(evaluate_lowered_json('my $before=$items; my $result=(sub { '.$lowering{mutation}.' })->(); return [$result,$items,$before];',q{my $items=[1,2]; my $value=3;}));
my @endpoints;
for my $case (['available',0,5,'ef',1],['empty',3,5,'ef',3],['missing_start',undef,5,'ef',1],['missing_end',0,undef,'ef',1],['missing_match',0,5,undef,1],['reversed',4,5,'ef',4],['missing_mark',0,5,'ef',undef]) {
    my ($id,$start,$end,$match,$mark)=@$case;
    my $setup='my $text="abcdef"; my $STRING=\$text; my $info={}; my $IPOS='.$json->encode($start).'; my $LSPOS='.$json->encode($end).'; my $LMATCH='.$json->encode($match).';';
    $setup =~ s/\bnull\b/undef/g;
    $setup.=' LinkedSpec::SourceLocation::Runtime::mark_write_position($info,$STRING,"MoveTop","body_start",'.$mark.',"fixture");' if defined $mark;
    push @endpoints,{id=>$id,map {$_=>$json->decode(evaluate_lowered_json($lowering{$_},$setup))} qw(named width)};
}
my @public; my $serial=0;
for my $case (
 ['decimal',q{return([3.5.floor().add(1),3.5.floor().add(0.75)])}],
 ['block_once',q{trace=""; n={trace=cat(trace,"V"); return(3.5)}.floor().add(0.75); return([n,trace])}],
 ['append_once',q{items=[1,2]; before=items; trace=""; n=(items += {trace=cat(trace,"V"); return(3)}).count(); return([n,items,before,trace])}],
) {
    my $source="Top:: I { $case->[1] }\n"; my (%context,$output,$native,@warnings);
    local $SIG{__WARN__}=sub {push @warnings,@_};
    {open my $out,'>',\$output or die $!; local *STDOUT=$out;
     my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context); my $input='x'; $native=$parser->(\$input);}
    my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'phase0-calibration.spec');
    my $package='Phase0Calibration'.++$serial; my $loaded=eval "package $package; $emitted; 1"; my $error="$@"; my $fresh;
    if ($loaded) {eval {my $input='x'; $fresh=$package->can('Execute')->(\$input);1} or $error="$@";}
    push @public,{id=>$case->[0],source=>$source,emitted=>$emitted,native=>$native,fresh=>$fresh,error=>$error,native_error=>$context{last_error},warnings=>\@warnings,output=>$output,loaded=>$loaded?1:0};
}
print $json->encode({lowering=>\%lowering,evaluated=>\%evaluated,endpoints=>\@endpoints,public=>\@public}),"\n";
