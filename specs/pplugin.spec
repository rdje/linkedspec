pplugin_top::   I {defs = []; retv = undef}
 -> comment       {next()}
 -> subdef        {retv = call(subdef)}

LE {
    if(is_defined(retv));
      set(array(defs), array(flat_array(defs), retv[0], retv[1]));
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
 -> subdef[1]	{return(array(entry_named(subname), capture_slice()))}


curlyb: /(?<!\\)\{/ /(?<!\\)\}/
# -> comment
 -> curlyb
 -> dquotes
 -> squotes
 -> curlyb[1]	{return_undef()}


comment: /#.*/
dquotes: /(?<!\\)".*?(?<!\\)"/
squotes: /(?<!\\)'.*?(?<!\\)'/
