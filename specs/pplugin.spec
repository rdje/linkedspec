pplugin_top::   I {declare(array, defs); declare(scalar, retv)}
 -> comment       {next()}
 -> subdef        {assign(s(retv), call(subdef))}

LE {
    if(is_defined(s(retv)));
      assign(a(defs), a(flat_array(defs), scalaref(retv, [0]), scalaref(retv, [1])));
    else();
      return_undef();
    endif()
}
LX {return(hash(flat_array(a(defs))))}


subdef: /(?<subname>\w\S*)\s*(?<!\\)\{/ /(?<!\\)\}/
# -> comment
 -> curlyb
 -> dquotes
 -> squotes
 -> subdef[1]	{return(a(entry_named(subname), sub {eval substr($$STRING, $IPOS, $LSPOS - $IPOS -1)}))}


curlyb: /(?<!\\)\{/ /(?<!\\)\}/
# -> comment
 -> curlyb
 -> dquotes
 -> squotes
 -> curlyb[1]	{return_undef()}


comment: /#.*/
dquotes: /(?<!\\)".*?(?<!\\)"/
squotes: /(?<!\\)'.*?(?<!\\)'/
