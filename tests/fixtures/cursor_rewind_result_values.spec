Top::
 -> Value[entry] {return(call(Value))}
Value:
 entry=/ab/
 colon=/:/
 -> Value[colon] {save_cursor();order="";
entry=rewind_entry_start().coalesce({order=cat(order,"F");99}).add(1).cat("!");
local_value=rewind_match_start().coalesce({order=cat(order,"F");99}).add(1);
invalid_entry=rewind_entry_start().take({order=cat(order,"BAD");1});
invalid_local=rewind_match_start().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
snapshot=rewind_entry_start().add({order=cat(order,"C");call(Advance)});
snapshot_end=cursor_pos();
bridge=rewind_entry_start().with(){return([value,"tail"])}[-1].uppercase();
recovered=rewind_match_start()[0].coalesce(["a","tail"])[-1].uppercase();
return([entry,local_value,invalid_entry,invalid_local,snapshot,snapshot_end,bridge,recovered,order,cursor_pos(),restore_cursor(),cursor_pos()]);}
Advance:
 /cd/
 -> Advance[0] {return(cursor_pos())}
