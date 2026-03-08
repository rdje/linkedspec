sdc_esplit:: I.declare(array, pieces).declare(scalar, retv).assign(scalar(IPOS), 0)
-> get_pinport  {assign(scalar(retv), call(get_pinport)); push_value(array(pieces), scalar(retv))}
LS   {assign(scalar(retv), substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH)); push_value(array(pieces), scalar(retv))}
LE   {assign(scalar(IPOS), pos $$STRING)}
LX   {assign(scalar(retv), substr($$STRING, $IPOS, length($$STRING) - $IPOS)); push_value(array(pieces), scalar(retv)); return(array_values(array(pieces)))}


get_pinport: /\[\s*((?:get_port|get_pin)\w?\s+)/ /\]/ I.declare(array, pieces)
-> oc_brace        {declare(scalar, segment); declare(array, segment_parts); assign(scalar(segment), substr($$STRING, $LSPOS, call(oc_brace))); split(array(segment_parts), scalar(segment), /\s+/); filter_nonempty(array(segment_parts)); assign(array(pieces), array(flat_array(pieces), flat_array(segment_parts)))}
-> get_pinport[1]  {return(array(flat_array(IMATCH_LIST), array_values(array(pieces))))}

LS   {declare(scalar, segment); declare(array, segment_parts); assign(scalar(segment), substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH)); split(array(segment_parts), scalar(segment), /(\s+)/); filter_nonempty(array(segment_parts)); assign(array(pieces), array(flat_array(pieces), flat_array(segment_parts)))}
LE   {assign(scalar(IPOS), pos $$STRING)}

oc_brace: /\{/ /\}/ -> oc_brace  -> oc_brace[1]  {return  $LSPOS - $IPOS - 1}
