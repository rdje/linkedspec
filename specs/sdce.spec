sdc_esplit:: I {pieces = []; retv = undef; start_capture_slice()}
-> get_pinport  {retv = call(get_pinport); push(array(pieces), retv)}
LS   {retv = capture_slice(); push(array(pieces), retv)}
LE   {start_capture_slice()}
LX   {retv = capture_rest(); push(array(pieces), retv); return(copy(array(pieces)))}


get_pinport: /\[\s*((?:get_port|get_pin)\w?\s+)/ /\]/ I {pieces = []}
-> oc_brace        {segment = undef; segment_parts = []; segment = input_slice(match_end_pos(), call(oc_brace)); split(array(segment_parts), segment, /\s+/); filter_nonempty(array(segment_parts)); set(array(pieces), array(flat_array(pieces), flat_array(segment_parts)))}
-> get_pinport[1]  {return(array(flat_array(entry_groups()), copy(array(pieces))))}

LS   {segment = undef; segment_parts = []; segment = capture_slice(); split(array(segment_parts), segment, /(\s+)/); filter_nonempty(array(segment_parts)); set(array(pieces), array(flat_array(pieces), flat_array(segment_parts)))}
LE   {start_capture_slice()}

oc_brace: /\{/ /\}/ -> oc_brace  -> oc_brace[1]  {return(capture_slice_len())}
