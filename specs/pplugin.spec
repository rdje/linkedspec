pplugin_top::   I {declare(array, defs); declare(scalar, retv)}
 -> comment       {next()}
 -> subdef        {assign(scalar(retv), call(subdef))}

LE {
    if(is_defined(scalar(retv)));
      assign(array(defs), array(flat_array(defs), retv[0], retv[1]));
    else();
      return_undef();
    endif()
}
LX {return(hash(flat_array(array(defs))))}


subdef: /(?<subname>\w\S*)\s*(?<!\\)\{/ /(?<!\\)\}/
# -> comment
 -> curlyb
 -> dquotes
 -> squotes
 -> subdef[1]	{return(array(entry_named(subname), sub {eval substr($$STRING, $IPOS, $LSPOS - $IPOS -1)}))}


curlyb: /(?<!\\)\{/ /(?<!\\)\}/
# -> comment
 -> curlyb
 -> dquotes
 -> squotes
 -> curlyb[1]	{return_undef()}


comment: /#.*/
dquotes: /(?<!\\)".*?(?<!\\)"/
squotes: /(?<!\\)'.*?(?<!\\)'/
