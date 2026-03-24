sdc_esplit:: I.declare(array, pieces).declare(scalar, retv).assign(s(IPOS), 0)
-> get_pinport  {assign(s(retv), call(get_pinport)); push_value(a(pieces), s(retv))}
LS   {assign(s(retv), substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH)); push_value(a(pieces), s(retv))}
LE   {assign(s(IPOS), pos $$STRING)}
LX   {assign(s(retv), substr($$STRING, $IPOS, length($$STRING) - $IPOS)); push_value(a(pieces), s(retv)); return(array_values(a(pieces)))}


get_pinport: /\[\s*((?:get_port|get_pin)\w?\s+)/ /\]/ I.declare(array, pieces)
-> oc_brace        {declare(scalar, segment); declare(array, segment_parts); assign(s(segment), substr($$STRING, $LSPOS, call(oc_brace))); split(a(segment_parts), s(segment), /\s+/); filter_nonempty(a(segment_parts)); assign(a(pieces), a(flat_array(pieces), flat_array(segment_parts)))}
-> get_pinport[1]  {return(a(flat_array(IMATCH_LIST), array_values(a(pieces))))}

LS   {declare(scalar, segment); declare(array, segment_parts); assign(s(segment), substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH)); split(a(segment_parts), s(segment), /(\s+)/); filter_nonempty(a(segment_parts)); assign(a(pieces), a(flat_array(pieces), flat_array(segment_parts)))}
LE   {assign(s(IPOS), pos $$STRING)}

oc_brace: /\{/ /\}/ -> oc_brace  -> oc_brace[1]  {return  $LSPOS - $IPOS - 1}
