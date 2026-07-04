lib_file::  -> group    .push
LX          {return(copy(array(lib_file)))}

group: /\b(\w+)\s*\(\s*((?s:.*?))\s*\)\s*\{/ /\}/  I {grouptype = entry_group(0); groupname = entry_group(1); substr(:groupname, "\"", "", go)}

-> group                 .push
-> cattribute            .push
-> sattribute            .push
-> group[1]              .return(array("GROUP", :grouptype, :groupname, copy(array(group))))

LX {say("GROUP <", :grouptype, ">(", :groupname, ") Has a syntax error."); exit_now(1)}

sattribute: /\b(\w+)\s*:\s*(.*?)\s*;/    I {attribute_name = entry_group(0); value = entry_group(1); substr(:value, "\"", "", go); return(array("SATTRIBUTE", :attribute_name, :value))}

cattribute: /\b(\w+)\b\s*\(((?s:.)*?)\)\s*;/ I {attribute_name = entry_group(0); value = entry_group(1); value_items = []; substr(:value, "\"|\\\\|\\s", "", go); split(array(value_items), :value, /,/); return(array("CATTRIBUTE", :attribute_name, copy(array(value_items))))}
