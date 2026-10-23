use strict;
use warnings;
use JSON::PP;
use LinkedSpec;
my $lowered = LinkedSpec::call_spec_handler_subst('Top', 'item = 1');
my ($item, @warnings);
local $SIG{__WARN__}=sub {push @warnings,@_};
my $ok=eval "$lowered; 1";
print JSON::PP->new->canonical->encode({completed=>$ok?1:0,error=>"$@",value=>$item,warnings=>\@warnings}),"\n";
