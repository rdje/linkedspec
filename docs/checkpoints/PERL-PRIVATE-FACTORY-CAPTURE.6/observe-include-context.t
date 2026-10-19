use strict;
use warnings;
use Test::More;
use JSON::PP ();

note(JSON::PP->new->canonical->encode({before_linkedspec => [@INC],
 module_preloaded => exists $INC{'LinkedSpec/ActionIR/RewritePipeline.pm'} ? 1 : 0}));
require LinkedSpec::ActionIR::RewritePipeline;
note(JSON::PP->new->canonical->encode({loaded_module => $INC{'LinkedSpec/ActionIR/RewritePipeline.pm'}}));
pass('retained include observation');
done_testing;
