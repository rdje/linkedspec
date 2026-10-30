List::
 @capture_gaps
 I {rows=[];order=""}
 -> Item[word] {start=gap_span()["start"].add(1);
ending=gap_span()["end"].coalesce({order=cat(order,"F");99}).cat("!");
source=gap_span()["source_id"].uppercase();
provenance=gap_span()["provenance"].cat("!");
missing=gap_span()["missing"].coalesce(["a","tail"])[-1].uppercase();
invalid=gap_span()["source_id"].take({order=cat(order,"BAD");1});
item=call(Item);push(rows,[start,ending,source,provenance,missing,invalid,item]);}
 LX {return([rows,order,cursor_pos()])}
Item:
 word=/[^,;]+/
 I {slot_order="";
entry_word=entry_slot()["slot_id"].uppercase();
entry_index=entry_slot()["regex_index"].coalesce({slot_order=cat(slot_order,"F");99}).add(1);
entry_target=entry_slot()["target_rule"].lowercase();
entry_missing=entry_slot()["missing"].coalesce("M");
entry_invalid=entry_slot()["target_rule"].take({slot_order=cat(slot_order,"BAD");1});
return([entry_word,entry_index,entry_target,entry_missing,entry_invalid,slot_order]);}
