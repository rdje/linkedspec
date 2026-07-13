sub_gui_list::
 -> sub_gui	{set(sub_gui_list, merge_hash(sub_gui_list, call(sub_gui)))}
 -> comment	{next()}

 I {set(sub_gui_list, {})}
 LX {return(copy(sub_gui_list))}

sub_gui: /(\S+)\s+\{/   /\}/ 	
I {
 subgui_name = entry_group(0);
 print("Found a SUB GUI entry point <", subgui_name, ">\n")
}

 -> curlyb
 -> sub_gui[1]	  {return({ subgui_name : cat("(", capture_slice(), ")") })}

curlyb: /\{/ /\}/
 -> curlyb
 -> comment	{next()}
 -> curlyb[1]   {return_undef()}

comment: /#.*\n/
