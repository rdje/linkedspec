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
  if(eq(scalaref(first_capt, [0]), "?branch:"));
   assign(scalar(entry_tag), "?branch_entry:");
  else();
   assign(scalar(entry_tag), "?version_entry:");
  endif();
  push_value(array(object_hier), array(scalar(entry_tag), array_values(array(capt))));
 endif();

 if(is_nonempty(array(object_hier)));
  assign(scalar(current_object_name), scalaref(cur_object, [1]));
  push_value(array(vhistory), array("?object:", scalar(current_object_name), array_values(array(object_hier))));
 endif();

 return(array("?ds_vhistory:", array_values(array(vhistory))))
} 

-> object             {
  if(is_nonempty(array(capt)));
   assign(scalar(first_capt), scalar(array(capt), 0));
   if(eq(scalaref(first_capt, [0]), "?branch:"));
    assign(scalar(entry_tag), "?branch_entry:");
   else();
    assign(scalar(entry_tag), "?version_entry:");
   endif();
   push_value(array(object_hier), array(scalar(entry_tag), array_values(array(capt))));
   assign(array(capt), array());

  endif();

  if(is_nonempty(array(object_hier)));
   assign(scalar(current_object_name), scalaref(cur_object, [1]));
   push_value(array(vhistory), array("?object:", scalar(current_object_name), array_values(array(object_hier))));
   assign(array(object_hier), array());
  endif();

  $cur_object  = call(object);
  print("\tObject   ", scalaref(cur_object, [1]), "\n")
}


-> separator          {
  if(is_nonempty(array(capt)));
   assign(scalar(first_capt), scalar(array(capt), 0));
   if(eq(scalaref(first_capt, [0]), "?branch:"));
    assign(scalar(entry_tag), "?branch_entry:");
   else();
    assign(scalar(entry_tag), "?version_entry:");
   endif();
   push_value(array(object_hier), array(scalar(entry_tag), array_values(array(capt))));
   assign(array(capt), array());
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
object:       /(?i)\nobject:\s+(\S+)/                                             I {return  ['?object:',       @IMATCH_LIST]}
branch:       /(?i)\nbranch:\s+(\S+)/                                             I {return  ['?branch:',       @IMATCH_LIST]}
branch_tags:  /(?is)\nbranch\s+tags:\s+(?:([^:]+?),\s*(.+?)\s*,\s*(\w+)|(\S+))/   I {return  ['?branch_tags:',  @IMATCH_LIST]}
version_tags: /(?is)\nversion\s+tags:\s+(?:([^:]+?),\s*(.+?)\s*,\s*(\w+)|(\S+))/  I {return  ['?version_tags:', @IMATCH_LIST]}
version:      /(?i)\nversion:\s+(\S+)/                                            I {return  ['?version:',      @IMATCH_LIST]}
date:         /(?i)\ndate:\s+(.+)/                                                I {return  ['?date:',         @IMATCH_LIST]}
comment:      /(?i)\ncomment:\s+(.+)/                                             I {return  ['?comment:',      @IMATCH_LIST]}
author:       /(?i)\nauthor:\s+(.+)/                                              I {return  ['?author:',       @IMATCH_LIST]}
derived_from: /(?i)\nderived_from:\s+(\S+)/                                       I {return  ['?derived_from:', @IMATCH_LIST]}
manifest:     /(?is)\nmanifest:\s+.+?\n\n/                                        I {return  ['?manifest:']}
