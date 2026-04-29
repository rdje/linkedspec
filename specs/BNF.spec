#
# BNF-style language
#

description::			I {print("HELLO\n")}
 -> construction_start
 -> node
 -> dquote_str
 -> squote_str
 -> regex
 -> group
 -> pipe
 -> star
 -> plus
 -> q_mark
 -> g_repetition
 
construction_start:	/[a-zA-Z_]\w*\s*->/	I {
	declare(scalar, text=entry_text());
	substr(scalar(text), "\\s*->$", "", o);
	print("(construction_start)         -I- seen(", scalar(text), ")\n")
}

node: 			/[a-zA-Z_]\w*/		I {print("(node)         -I- <", entry_text(), ">\n")}
dquote_str:		/"[^"]+"/		I {
	declare(scalar, text=entry_text());
	substr(scalar(text), "^(?:\")|(?:\")$", "", go);
	print("(dquote_str)         -I- seen(", scalar(text), ")\n")
}

squote_str:		/'[^']+?'/		I {
	declare(scalar, text=entry_text());
	substr(scalar(text), "^'|'$", "", go);
	print("(squote_str)         -I- seen(", scalar(text), ")\n")
}

regex:			/\/.+\//		I {
	declare(scalar, text=entry_text());
	substr(scalar(text), "^/|/$", "", go);
	print("(regex)         -I- seen#", scalar(text), "#\n")
}

group: 			/\(/ /\)/		I {print("(group)        -I-  ****************************************** Entering\n")}
LS {print("LOOP START Message\n")}
LE {print("LOOP END Message\n")}
 -> group
 -> node
 -> dquote_str
 -> squote_str
 -> pipe
 -> regex
 -> star
 -> plus
 -> q_mark
 -> g_repetition
 -> group[1]			  	  	  { 
	 print("(group)        -I-  ########################################## Leaving\n");
	 return(1);
 }

g_repetition: 		/\{(?:\d+(?:,\d*)?|,\d+)\}/	I {print("(g_repetition) -I- <", entry_text(), ">\n")}
q_mark: 		/\?/			I {print("(q_mark)       -I- ?\n")}
plus: 			/\+/			I {print("(plus)         -I- +\n")}
star: 			/\*/			I {print("(start)        -I- *\n")}
pipe: 			/\|/			I {print("(pipe)         -I- |\n")} 
