sub_gui_list:: 
 -> sub_gui	{push(sub_gui)}
 -> comment	{next}

 LX {return {@sub_gui_list}}

sub_gui: /(\S+)\s+\{/   /\}/ 	
I {
 assign(scalar(subgui_name), entry_group(0));
 print("Found a SUB GUI entry point <", scalar($subgui_name), ">\n")
}

 -> curlyb
 -> sub_gui[1]	  {return ($subgui_name => '('.capture_slice().')')}

curlyb: /\{/ /\}/
 -> curlyb
 -> comment	{next}
 -> curlyb[1]   {return} 

comment: /#.*\n/
