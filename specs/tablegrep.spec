grep::
 -> re_term	{$retv = call(re_term)}
 -> or_op	{$retv = call(or_op)}
 -> and_op	{$retv = call(and_op)}
 -> group	{$retv = call(group)}

I {
 declare(array, internal);
 declare(scalar, prev_node_type)
}

LX {return @internal ? \@internal : undef}
LS {my $retv}
LE {
 if(not(scalar(retv)));
  return_undef();
 endif();
 
 if(and(and(scalar(prev_node_type), matches(scalar(prev_node_type), /_OP/o)), matches(scalaref(retv, {type}), /_OP/o)));
  print("ERROR: Two operators w/o neither a RE_TERM nor a GROUP in between\n");
  exit 1;
 endif();
 
 push_value(array(internal), scalar(retv));
 assign(scalar(prev_node_type), scalaref(retv, {type}))
}
#======== End Of grep ========


group:	/\(/ /\)/
 -> group		{$retv = call(group)}
 -> re_term		{$retv = call(re_term)}
 -> or_op		{$retv = call(or_op)}
 -> and_op		{$retv = call(and_op)}
 -> group[1]		{
  if(is_empty(array(internal)));
   print("\\nERROR: ** Empty **  GROUP\\n");
   exit 2;
  endif();
  return({type=>'GROUP', group=>array(internal)})
 }

I {
 declare(array, internal);
 declare(scalar, prev_node_type)
}

LS {my $retv}
LE {
 if(not(scalar(retv)));
  return_undef();
 endif();
 
 if(and(and(scalar(prev_node_type), matches(scalar(prev_node_type), /_OP/o)), matches(scalaref(retv, {type}), /_OP/o)));
  print("\nERROR: Two operators w/o neither a RE_TERM nor a GROUP in between\n");
  exit 1;
 endif();

 push_value(array(internal), scalar(retv));
 assign(scalar(prev_node_type), scalaref(retv, {type}))
}
#==========


re_term: /((?:\w+|\[\d+\]))\s*([!=])~\s*\/(.+?)(?<!\\)\//
I {
 declare(scalar, field=scalar(IMATCH_LIST, 0), sens=scalar(IMATCH_LIST, 1), re=scalar(IMATCH_LIST, 2));
 if(matches(scalar(field), /^\[\d+\]$/o));
  declare(scalar, subscript=scalar(field));
  substr(scalar(subscript), /^\[(\d+)\]$/, "$1", o);
  return(hash("type", "STERM", "field", scalar(subscript), "sens", scalar(sens), "re", scalar(re)));
 else();
  return(hash("type", "TERM", "field", scalar(field), "sens", scalar(sens), "re", scalar(re)));
 endif()
}

or_op: /\|\|/		I.return(hash("type", "OR_OP"))

and_op: /\&\&/		I.return(hash("type", "AND_OP"))
