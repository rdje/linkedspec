grep::
 -> re_term	{set(scalar(retv), call(re_term))}
 -> or_op	{set(scalar(retv), call(or_op))}
 -> and_op	{set(scalar(retv), call(and_op))}
 -> group	{set(scalar(retv), call(group))}

I {
 internal = [];
 prev_node_type = undef
}

LX {
 if(is_empty(array(internal)));
  return_undef();
 endif();
 return(copy(array(internal)))
}
LS {retv = undef}
LE {
 if(not(scalar(retv)));
  return_undef();
 endif();
 
 if(and(and(scalar(prev_node_type), matches(scalar(prev_node_type), /_OP/o)), matches(retv["type"], /_OP/o)));
  print("ERROR: Two operators w/o neither a RE_TERM nor a GROUP in between\n");
  exit_now(1);
 endif();
 
 push(array(internal), scalar(retv));
 set(scalar(prev_node_type), retv["type"])
}
#======== End Of grep ========


group:	/\(/ /\)/
 -> group		{set(scalar(retv), call(group))}
 -> re_term		{set(scalar(retv), call(re_term))}
 -> or_op		{set(scalar(retv), call(or_op))}
 -> and_op		{set(scalar(retv), call(and_op))}
 -> group[1]		{
  if(is_empty(array(internal)));
   print("\\nERROR: ** Empty **  GROUP\\n");
   exit_now(2);
  endif();
  return({type=>'GROUP', group=>array(internal)})
 }

I {
 internal = [];
 prev_node_type = undef
}

LS {retv = undef}
LE {
 if(not(scalar(retv)));
  return_undef();
 endif();
 
 if(and(and(scalar(prev_node_type), matches(scalar(prev_node_type), /_OP/o)), matches(retv["type"], /_OP/o)));
  print("\nERROR: Two operators w/o neither a RE_TERM nor a GROUP in between\n");
  exit_now(1);
 endif();

 push(array(internal), scalar(retv));
 set(scalar(prev_node_type), retv["type"])
}
#==========


re_term: /((?:\w+|\[\d+\]))\s*([!=])~\s*\/(.+?)(?<!\\)\//
I {
 field = entry_group(0);
 sens = entry_group(1);
 re = entry_group(2);
 if(matches(scalar(field), /^\[\d+\]$/o));
  subscript = scalar(field);
  substr(scalar(subscript), /^\[(\d+)\]$/, "$1", o);
  return(hash("type", "STERM", "field", scalar(subscript), "sens", scalar(sens), "re", scalar(re)));
 else();
  return(hash("type", "TERM", "field", scalar(field), "sens", scalar(sens), "re", scalar(re)));
 endif()
}

or_op: /\|\|/		I.return(hash("type", "OR_OP"))

and_op: /\&\&/		I.return(hash("type", "AND_OP"))
