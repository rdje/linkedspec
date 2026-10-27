use strict;use warnings;use JSON::PP ();use LinkedSpec ();
my $action=q{meta={"old":1};key="before";result=set_key(meta,key,{key="after";2});return([result,key])};
my $source='Top:: I {'.$action.'}';my %context;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);my $input='x';my $value=eval{$parser->(\$input)};
print JSON::PP->new->canonical->encode({source=>$source,native=>$value,thrown=>"$@",context_error=>defined($context{last_error})?"$context{last_error}":undef,substitution=>LinkedSpec::call_spec_handler_subst('Top',$action)}),"\n";
