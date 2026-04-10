# --------------------------------------------
#  Parses the output of 
#
#  dssc vhistory -all -report verbose
# --------------------------------------------

vhistory::  I {
declare(array, vhistory, capt, object_hier);
declare(scalar, cur_object, first_capt, entry_tag, current_object_name)
}
LX  {
 if(is_nonempty(a(capt)));
  assign(s(first_capt), scalar(a(capt), 0));
  if(eq(scalaref(first_capt, [0]), "?branch:"));
   assign(s(entry_tag), "?branch_entry:");
  else();
   assign(s(entry_tag), "?version_entry:");
  endif();
  push_value(a(object_hier), a(s(entry_tag), array_copy(a(capt))));
 endif();

 if(is_nonempty(a(object_hier)));
  assign(s(current_object_name), scalaref(cur_object, [1]));
  push_value(a(vhistory), a("?object:", s(current_object_name), array_copy(a(object_hier))));
 endif();

 return(a("?ds_vhistory:", array_copy(a(vhistory))))
} 

-> object             {
  if(is_nonempty(a(capt)));
   assign(s(first_capt), scalar(a(capt), 0));
   if(eq(scalaref(first_capt, [0]), "?branch:"));
    assign(s(entry_tag), "?branch_entry:");
   else();
    assign(s(entry_tag), "?version_entry:");
   endif();
   push_value(a(object_hier), a(s(entry_tag), array_copy(a(capt))));
   assign(a(capt), a());

  endif();

  if(is_nonempty(a(object_hier)));
   assign(s(current_object_name), scalaref(cur_object, [1]));
   push_value(a(vhistory), a("?object:", s(current_object_name), array_copy(a(object_hier))));
   assign(a(object_hier), a());
  endif();

  $cur_object  = call(object);
  print("\tObject   ", scalaref(cur_object, [1]), "\n")
}


-> separator          {
  if(is_nonempty(a(capt)));
   assign(s(first_capt), scalar(a(capt), 0));
   if(eq(scalaref(first_capt, [0]), "?branch:"));
    assign(s(entry_tag), "?branch_entry:");
   else();
    assign(s(entry_tag), "?version_entry:");
   endif();
   push_value(a(object_hier), a(s(entry_tag), array_copy(a(capt))));
   assign(a(capt), a());
  endif();
}


-> branch             {push @capt, call(branch)}
-> version            {push @capt, call(version)}
-> branch_tags        {push @capt, call(branch_tags)}
-> version_tags       {push @capt, call(version_tags)}
-> date               {push @capt, call(date)}
-> author             {push @capt, call(author)}
-> comment            {push @capt, call(comment)}
-> manifest           {push @capt, call(manifest)}
-> derived_from       {push @capt, call(derived_from)}



separator:    /-{20,}/
object:       /(?i)\nobject:\s+(\S+)/                                             I.return(a("?object:", flat_array(entry_groups())))
branch:       /(?i)\nbranch:\s+(\S+)/                                             I.return(a("?branch:", flat_array(entry_groups())))
branch_tags:  /(?is)\nbranch\s+tags:\s+(?:([^:]+?),\s*(.+?)\s*,\s*(\w+)|(\S+))/   I.return(a("?branch_tags:", flat_array(entry_groups())))
version_tags: /(?is)\nversion\s+tags:\s+(?:([^:]+?),\s*(.+?)\s*,\s*(\w+)|(\S+))/  I.return(a("?version_tags:", flat_array(entry_groups())))
version:      /(?i)\nversion:\s+(\S+)/                                            I.return(a("?version:", flat_array(entry_groups())))
date:         /(?i)\ndate:\s+(.+)/                                                I.return(a("?date:", flat_array(entry_groups())))
comment:      /(?i)\ncomment:\s+(.+)/                                             I.return(a("?comment:", flat_array(entry_groups())))
author:       /(?i)\nauthor:\s+(.+)/                                              I.return(a("?author:", flat_array(entry_groups())))
derived_from: /(?i)\nderived_from:\s+(\S+)/                                       I.return(a("?derived_from:", flat_array(entry_groups())))
manifest:     /(?is)\nmanifest:\s+.+?\n\n/                                        I {return  ['?manifest:']}
