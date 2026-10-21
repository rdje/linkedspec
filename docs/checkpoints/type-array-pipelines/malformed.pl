use strict;
use warnings;
use JSON::PP ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::CodeblockRuntime ();
my $json = JSON::PP->new->canonical;
my @rows;
for my $method (qw(sorted take sum)) {
    for my $kind (qw(null number string hash missing)) {
        my $record = LinkedSpec::ActionIR::AST::parse_action_expr("{|| return(items.$method()) }");
        my $call = $record->{body_ast}{statements}[0]{expr}{args}[0]{calls}[0];
        if ($kind eq 'missing') { delete $call->{args} }
        else { $call->{args} = $kind eq 'null' ? undef : $kind eq 'number' ? 1 : $kind eq 'string' ? 'bad' : {} }
        my $before = $json->encode($record);
        my $items = [3,1,8];
        my ($value,$error);
        my $ok = eval { $value = LinkedSpec::CodeblockRuntime::invoke($record,[],{items=>\$items},'malformed'); 1 };
        $error = $@ unless $ok;
        my $typed = ref($error) eq 'LinkedSpec::CodeblockRuntime::Error';
        push @rows, {method=>$method,kind=>$kind,completed=>$ok?1:0,
            error=>$typed?{class=>ref($error),fields=>{%$error}}:{class=>'',text=>defined($error)?"$error":''},
            value=>$value,record_unchanged=>$json->encode($record) eq $before?1:0,
            caller_unchanged=>$json->encode($items) eq '[3,1,8]'?1:0};
    }
}
print $json->encode({rows=>\@rows}),"\n";
