# Multi branching IS NOT to be used when connecting INPUT Pins of component
# But ONLY for having the same output pin of a component instance driving
# more than one SINK, i.e, internal signal (OUT-pin -------< IN-pins) and OUT-port(s)
portmap::
-> bare_bit_slice .push
-> concatenation  .push

LX {return @portmap == 1 ? $portmap[0] : ['?multi:', [@portmap]]}


concatenation: /\{/ /\}/
-> concatenation  .push
-> bare_bit_slice .push
-> concatenation[1]    {return ['?concat:', [@concatenation]]} 
bare_bit_slice: /([[:alpha:]]\w*)(?:\[(?:(\d+)(?::(\d+))?|(\?[[:alpha:]]\w+))\])?|(?i)(0x[0-9a-f]+|0b[01]+|\d+\'\d+)/ I {
	declare(array, entry_parts);
	assign(a(entry_parts), entry_groups());
	if(matches(entry_text(), /:/));
		return(a("?slice:", a(flat_array(entry_parts))));
	elseif(or(eq(entry_group(1), "0"), is_nonempty(entry_group(1))));
		return(a("?bit:", a(flat_array(entry_parts))));
	elseif(matches(entry_group(0), /^\d/io));
		return(a("?constant:", a(flat_array(entry_parts))));
	else();
		return(a("?bare:", a(flat_array(entry_parts))));
	endif()
}
