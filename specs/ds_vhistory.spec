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
 if(is_nonempty(array(capt)));
  assign(scalar(first_capt), scalar(array(capt), 0));
  if(str_eq(first_capt[0], "?branch:"));
   assign(scalar(entry_tag), "?branch_entry:");
  else();
   assign(scalar(entry_tag), "?version_entry:");
  endif();
  push_value(array(object_hier), array(scalar(entry_tag), array_copy(array(capt))));
 endif();

 if(is_nonempty(array(object_hier)));
  assign(scalar(current_object_name), cur_object[1]);
  push_value(array(vhistory), array("?object:", scalar(current_object_name), array_copy(array(object_hier))));
 endif();

 return(array("?ds_vhistory:", array_copy(array(vhistory))))
} 

-> object             {
  if(is_nonempty(array(capt)));
   assign(scalar(first_capt), scalar(array(capt), 0));
   if(str_eq(first_capt[0], "?branch:"));
    assign(scalar(entry_tag), "?branch_entry:");
   else();
    assign(scalar(entry_tag), "?version_entry:");
   endif();
   push_value(array(object_hier), array(scalar(entry_tag), array_copy(array(capt))));
   assign(array(capt), array());

  endif();

  if(is_nonempty(array(object_hier)));
   assign(scalar(current_object_name), cur_object[1]);
   push_value(array(vhistory), array("?object:", scalar(current_object_name), array_copy(array(object_hier))));
   assign(array(object_hier), array());
  endif();

  assign(scalar(cur_object), call(object));
  print("\tObject   ", cur_object[1], "\n")
}


-> separator          {
  if(is_nonempty(array(capt)));
   assign(scalar(first_capt), scalar(array(capt), 0));
   if(str_eq(first_capt[0], "?branch:"));
    assign(scalar(entry_tag), "?branch_entry:");
   else();
    assign(scalar(entry_tag), "?version_entry:");
   endif();
   push_value(array(object_hier), array(scalar(entry_tag), array_copy(array(capt))));
   assign(array(capt), array());
  endif();
}


-> branch             {push_value(array(capt), call(branch))}
-> version            {push_value(array(capt), call(version))}
-> branch_tags        {push_value(array(capt), call(branch_tags))}
-> version_tags       {push_value(array(capt), call(version_tags))}
-> date               {push_value(array(capt), call(date))}
-> author             {push_value(array(capt), call(author))}
-> comment            {push_value(array(capt), call(comment))}
-> manifest           {push_value(array(capt), call(manifest))}
-> derived_from       {push_value(array(capt), call(derived_from))}



separator:    /-{20,}/
object:       /(?i)\nobject:\s+(\S+)/                                             I.return(array("?object:", flat_array(entry_groups())))
branch:       /(?i)\nbranch:\s+(\S+)/                                             I.return(array("?branch:", flat_array(entry_groups())))
branch_tags:  /(?is)\nbranch\s+tags:\s+(?:([^:]+?),\s*(.+?)\s*,\s*(\w+)|(\S+))/   I.return(array("?branch_tags:", flat_array(entry_groups())))
version_tags: /(?is)\nversion\s+tags:\s+(?:([^:]+?),\s*(.+?)\s*,\s*(\w+)|(\S+))/  I.return(array("?version_tags:", flat_array(entry_groups())))
version:      /(?i)\nversion:\s+(\S+)/                                            I.return(array("?version:", flat_array(entry_groups())))
date:         /(?i)\ndate:\s+(.+)/                                                I.return(array("?date:", flat_array(entry_groups())))
comment:      /(?i)\ncomment:\s+(.+)/                                             I.return(array("?comment:", flat_array(entry_groups())))
author:       /(?i)\nauthor:\s+(.+)/                                              I.return(array("?author:", flat_array(entry_groups())))
derived_from: /(?i)\nderived_from:\s+(\S+)/                                       I.return(array("?derived_from:", flat_array(entry_groups())))
manifest:     /(?is)\nmanifest:\s+.+?\n\n/                                        I.return(array("?manifest:"))
