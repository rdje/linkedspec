# Multi branching IS NOT to be used when connecting INPUT Pins of component
# But ONLY for having the same output pin of a component instance driving
# more than one SINK, i.e, internal signal (OUT-pin -------< IN-pins) and OUT-port(s)
portmap::
-> bare_bit_slice .push
-> concatenation  .push

LX {
	if(num_eq(count(array(portmap)), 1));
		return(scalar(array(portmap), 0));
	else();
		return(array("?multi:", array_copy(array(portmap))));
	endif()
}


concatenation: /\{/ /\}/
-> concatenation  .push
-> bare_bit_slice .push
-> concatenation[1]    {return(array("?concat:", array_copy(array(concatenation))))}
bare_bit_slice: /([[:alpha:]]\w*)(?:\[(?:(\d+)(?::(\d+))?|(\?[[:alpha:]]\w+))\])?|(?i)(0x[0-9a-f]+|0b[01]+|\d+\'\d+)/ I {
	declare(array, entry_parts);
	assign(array(entry_parts), entry_groups());
	if(matches(entry_text(), /:/));
		return(array("?slice:", array(flat_array(entry_parts))));
	elseif(or(eq(entry_group(1), "0"), is_nonempty(entry_group(1))));
		return(array("?bit:", array(flat_array(entry_parts))));
	elseif(matches(entry_group(0), /^\d/io));
		return(array("?constant:", array(flat_array(entry_parts))));
	else();
		return(array("?bare:", array(flat_array(entry_parts))));
	endif()
}
