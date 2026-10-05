use strict;
use warnings;
use utf8;
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::RuleIR::EmitContext ();
use Scalar::Util qw(refaddr);
use JSON::PP ();
my $json=JSON::PP->new->canonical->utf8;
my $deps=LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my $source="push(items, '雪');";
my $result=LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance({id=>'push'},$source,$deps);
my $original=$result->{source_origins}[0]{event};
my $original_relation=refaddr($original)==refaddr($result->{events}[0]);
# Equal-valued copied returns preserve public values but break the relationship.
$result->{events}=$json->decode($json->encode($result->{events}));
my $event=$result->{source_origins}[0]{event};
print $json->encode({source=>$source,origin_event=>$event,returned_event=>$result->{events}[0],
 original_relation=>$original_relation?JSON::PP::true:JSON::PP::false,
 old_self_comparison=>refaddr($result->{source_origins}[0]{event})==refaddr($event)?JSON::PP::true:JSON::PP::false,
 required_return_relationship=>refaddr($result->{source_origins}[0]{event})==refaddr($result->{events}[0])?JSON::PP::true:JSON::PP::false}),"\n";
