lib_file::  -> group    .push
LX          {return \@lib_file}

group: /\b(\w+)\s*\(\s*((?s:.*?))\s*\)\s*\{/ /\}/  I.declare(scalar, grouptype=scalar(IMATCH_LIST, 0), groupname=scalar(IMATCH_LIST, 1)).substr(scalar(groupname), "\"", "", go)

-> group                 .push
-> cattribute            .push
-> sattribute            .push
-> group[1]              .return(array("GROUP", scalar(grouptype), scalar(groupname), array_values(array(group))))

LX {say("GROUP <", scalar(grouptype), ">(", scalar(groupname), ") Has a syntax error."); exit 1}

sattribute: /\b(\w+)\s*:\s*(.*?)\s*;/    I.declare(scalar, attribute_name=scalar(IMATCH_LIST, 0), value=scalar(IMATCH_LIST, 1)).substr(scalar(value), "\"", "", go).return(array("SATTRIBUTE", scalar(attribute_name), scalar(value)))

cattribute: /\b(\w+)\b\s*\(((?s:.)*?)\)\s*;/ I.declare(scalar, attribute_name=scalar(IMATCH_LIST, 0), value=scalar(IMATCH_LIST, 1)).declare(array, value_items).substr(scalar(value), "\"|\\\\|\\s", "", go).split(array(value_items), scalar(value), /,/).return(array("CATTRIBUTE", scalar(attribute_name), array_values(array(value_items))))
