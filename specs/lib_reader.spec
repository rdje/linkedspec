lib_file::  -> group    .push
LX          {return \@lib_file}

group: /\b(\w+)\s*\(\s*((?s:.*?))\s*\)\s*\{/ /\}/  I.declare(scalar, grouptype=entry_group(0), groupname=entry_group(1)).substr(s(groupname), "\"", "", go)

-> group                 .push
-> cattribute            .push
-> sattribute            .push
-> group[1]              .return(a("GROUP", s(grouptype), s(groupname), array_values(a(group))))

LX {say("GROUP <", s(grouptype), ">(", s(groupname), ") Has a syntax error."); exit 1}

sattribute: /\b(\w+)\s*:\s*(.*?)\s*;/    I.declare(scalar, attribute_name=entry_group(0), value=entry_group(1)).substr(s(value), "\"", "", go).return(a("SATTRIBUTE", s(attribute_name), s(value)))

cattribute: /\b(\w+)\b\s*\(((?s:.)*?)\)\s*;/ I.declare(scalar, attribute_name=entry_group(0), value=entry_group(1)).declare(array, value_items).substr(s(value), "\"|\\\\|\\s", "", go).split(a(value_items), s(value), /,/).return(a("CATTRIBUTE", s(attribute_name), array_values(a(value_items))))
