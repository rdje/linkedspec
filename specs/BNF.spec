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
	$IMATCH =~ s/\s*->//;
	print("(construction_start)         -I- seen(", scalar(IMATCH), ")\n")
}

node: 			/[a-zA-Z_]\w*/		I {print("(node)         -I- <", scalar(IMATCH), ">\n")}
dquote_str:		/"[^"]+"/		I {
	$IMATCH =~ s/^"|"$//g;
	print("(dquote_str)         -I- seen(", scalar(IMATCH), ")\n")
}

squote_str:		/'[^']+?'/		I {
	$IMATCH =~ s/^'|'$//g;
	print("(squote_str)         -I- seen(", scalar(IMATCH), ")\n")
}

regex:			/\/.+\//		I {
	$IMATCH =~ s/\///g;
	print("(regex)         -I- seen#", scalar(IMATCH), "#\n")
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
	 return 1;
 }

g_repetition: 		/\{(?:\d+(?:,\d*)?|,\d+)\}/	I {print("(g_repetition) -I- <", scalar(IMATCH), ">\n")}
q_mark: 		/\?/			I {print("(q_mark)       -I- ?\n")}
plus: 			/\+/			I {print("(plus)         -I- +\n")}
star: 			/\*/			I {print("(start)        -I- *\n")}
pipe: 			/\|/			I {print("(pipe)         -I- |\n")} 
