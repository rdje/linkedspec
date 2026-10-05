use strict;
use warnings;
use Test::More;
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::RuleIR::EmitContext ();

my $deps=LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my $source='switch(kind, case("x", case("nested")))';

sub scan_pair {
    my ($contract,$source,$custom)=@_;
    my $ordinary=LinkedSpec::ActionIR::Scanner::scan_contract_ir_events({id=>$contract},$source,$custom);
    my $private=LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance({id=>$contract},$source,$custom);
    is_deeply($private->{events},$ordinary,'ordinary custom event values/order remain exact');
    return $private;
}

subtest 'changed original switch argument denies only that inline subtree' => sub {
    my %custom=%$deps;
    $custom{parse_method_function_expr}=sub {
        my $call=$deps->{parse_method_function_expr}->(@_);
        $call->{args}[1]='case("changed", case("nested"))' if $call && $call->{method} eq 'switch';
        return $call;
    };
    my $private=scan_pair('case_flow',$source,\%custom);
    is_deeply($private->{events},[
        {raw=>'case("changed", case("nested"))',args=>{value=>'"changed"'}},
        {raw=>'case("nested")',args=>{value=>'"nested"'}},
    ],'changed original callbacks keep their syntactic result');
    is_deeply($private->{source_origins},[],'changed parent argument cannot lend original subtree coordinates');
};

subtest 'opaque canonical argument array retains original rejection' => sub {
    my %custom=%$deps;
    $custom{parse_method_function_expr}=sub {
        my $call=$deps->{parse_method_function_expr}->(@_);$call->{args}={} if $call;return $call;
    };
    my $private=scan_pair('case_flow',$source,\%custom);
    is_deeply($private,{events=>[],source_origins=>[]},'opaque arguments keep rejection without frames');
};

subtest 'transformed branch trim cannot invent a raw interval' => sub {
    my %custom=%$deps;
    $custom{trim_action_ir_value}=sub {
        my $value=$deps->{trim_action_ir_value}->(@_);
        return defined($value) && $value eq 'case("x", case("nested"))' ? 'transformed' : $value;
    };
    my $private=scan_pair('case_flow',$source,\%custom);
    is_deeply($private->{events},[
        {raw=>'transformed',args=>{value=>'"x"'}},
        {raw=>'case("nested")',args=>{value=>'"nested"'}},
    ],'transformed raw remains original callback event');
    is_deeply($private->{source_origins},[
        {event=>{raw=>'case("nested")',args=>{value=>'"nested"'}},source=>$source,
         source_span=>{start=>23,end=>37}},
    ],'unchanged nested original argument retains exact source authority');
};

done_testing;
