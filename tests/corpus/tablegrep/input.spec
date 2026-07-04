grep::
 -> re_term	{retv = call(re_term)}
 -> or_op	{retv = call(or_op)}
 -> and_op	{retv = call(and_op)}
 -> group	{retv = call(group)}

I {
 declare(array, internal);
 declare(scalar, prev_node_type)
}

LX {
 if(is_empty(array(internal)));
  return_undef();
 endif();
 return(array_copy(array(internal)))
}
LS {declare(scalar, retv)}
LE {
 if(not(:retv));
  return_undef();
 endif();
 
 if(and(and(:prev_node_type, matches(:prev_node_type, /_OP/o)), matches(retv["type"], /_OP/o)));
  print("ERROR: Two operators w/o neither a RE_TERM nor a GROUP in between\n");
  exit_now(1);
 endif();
 
 push_value(array(internal), :retv);
 prev_node_type = retv["type"]
}
#======== End Of grep ========


group:	/\(/ /\)/
 -> group		{retv = call(group)}
 -> re_term		{retv = call(re_term)}
 -> or_op		{retv = call(or_op)}
 -> and_op		{retv = call(and_op)}
 -> group[1]		{
  if(is_empty(array(internal)));
   print("\\nERROR: ** Empty **  GROUP\\n");
   exit_now(2);
  endif();
  return({type=>'GROUP', group=>array(internal)})
 }

I {
 declare(array, internal);
 declare(scalar, prev_node_type)
}

LS {declare(scalar, retv)}
LE {
 if(not(:retv));
  return_undef();
 endif();
 
 if(and(and(:prev_node_type, matches(:prev_node_type, /_OP/o)), matches(retv["type"], /_OP/o)));
  print("\nERROR: Two operators w/o neither a RE_TERM nor a GROUP in between\n");
  exit_now(1);
 endif();

 push_value(array(internal), :retv);
 prev_node_type = retv["type"]
}
#==========


re_term: /((?:\w+|\[\d+\]))\s*([!=])~\s*\/(.+?)(?<!\\)\//
I {
 declare(scalar, field=entry_group(0), sens=entry_group(1), re=entry_group(2));
 if(matches(:field, /^\[\d+\]$/o));
  declare(scalar, subscript=:field);
  substr(:subscript, /^\[(\d+)\]$/, "$1", o);
  return(hash("type", "STERM", "field", :subscript, "sens", :sens, "re", :re));
 else();
  return(hash("type", "TERM", "field", :field, "sens", :sens, "re", :re));
 endif()
}

or_op: /\|\|/		I.return(hash("type", "OR_OP"))

and_op: /\&\&/		I.return(hash("type", "AND_OP"))
