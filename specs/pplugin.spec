pplugin_top::   I {my @defs; my $retv}
 -> comment       {next}
 -> subdef        {$retv = call(subdef)}

LE {return undef unless defined $retv; assign(a(defs), a(flat_array(defs), scalaref(retv, [0]), scalaref(retv, [1])))}
LX {return {@defs}}


subdef: /(?<subname>\w\S*)\s*(?<!\\)\{/ /(?<!\\)\}/
# -> comment
 -> curlyb
 -> dquotes
 -> squotes
 -> subdef[1]	{return [entry_named(subname), sub {eval substr($$STRING, $IPOS, $LSPOS - $IPOS -1)}]}


curlyb: /(?<!\\)\{/ /(?<!\\)\}/
# -> comment
 -> curlyb
 -> dquotes
 -> squotes
 -> curlyb[1]	{return}


comment: /#.*/
dquotes: /(?<!\\)".*?(?<!\\)"/
squotes: /(?<!\\)'.*?(?<!\\)'/
