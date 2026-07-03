sdc_esplit:: I {pieces = []; retv = undef; start_capture_slice()}
-> get_pinport  {assign(scalar(retv), call(get_pinport)); push_value(array(pieces), scalar(retv))}
LS   {assign(scalar(retv), capture_slice()); push_value(array(pieces), scalar(retv))}
LE   {start_capture_slice()}
LX   {assign(scalar(retv), capture_rest()); push_value(array(pieces), scalar(retv)); return(array_copy(array(pieces)))}


get_pinport: /\[\s*((?:get_port|get_pin)\w?\s+)/ /\]/ I {pieces = []}
-> oc_brace        {segment = undef; segment_parts = []; assign(scalar(segment), input_slice(match_end_pos(), call(oc_brace))); split(array(segment_parts), scalar(segment), /\s+/); filter_nonempty(array(segment_parts)); assign(array(pieces), array(flat_array(pieces), flat_array(segment_parts)))}
-> get_pinport[1]  {return(array(flat_array(entry_groups()), array_copy(array(pieces))))}

LS   {segment = undef; segment_parts = []; assign(scalar(segment), capture_slice()); split(array(segment_parts), scalar(segment), /(\s+)/); filter_nonempty(array(segment_parts)); assign(array(pieces), array(flat_array(pieces), flat_array(segment_parts)))}
LE   {start_capture_slice()}

oc_brace: /\{/ /\}/ -> oc_brace  -> oc_brace[1]  {return(capture_slice_len())}
