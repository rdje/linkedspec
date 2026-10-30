
List::
 @capture_gaps
 I {rows=[];order=""}
 -> Item[word] {punct=gap_text().coalesce({order=cat(order,"F");"bad"}).cat("!");
kind_upper=gap_kind().coalesce({order=cat(order,"F");"bad"}).uppercase();
invalid_text=gap_text().take({order=cat(order,"A");1});
invalid_kind=gap_kind().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
bridge=gap_text()[0].coalesce(["a","tail"])[-1].uppercase();
flow=gap_kind().with(){return([value,"tail"])}[-1].uppercase();
push(rows,[punct,kind_upper,invalid_text,invalid_kind,bridge,flow,call(Item)]);}
 LX {return([rows,gap_text().coalesce("BAD").cat("!"),gap_kind().uppercase(),order,cursor_pos()]);}
Item:
 word=/[^,;]+/
 I {return(entry_text())}
