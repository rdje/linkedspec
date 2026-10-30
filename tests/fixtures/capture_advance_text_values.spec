Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_capture_slice(origin);order="";
a=capture_take().coalesce("missing").cat({order=cat(order,"A");"!"});apos=capture_slice_pos();
start_capture_slice_from(origin);
b=capture_take_until_cursor().coalesce("").split(":")[-1].uppercase();bpos=capture_slice_pos();
start_capture_slice_from(origin);
c=capture_take_rest().coalesce("").split(":")[-1].uppercase();cpos=capture_slice_pos();
start_capture_slice_from(origin);
invalid=capture_take_until_cursor().coalesce("").take({order=cat(order,"BAD");1});
empty=capture_take_until_cursor().coalesce({order=cat(order,"F");"fallback"}).cat("!");
missing=capture_take().coalesce("missing").cat("!");
return([a,b,c,[apos,bpos,cpos],invalid,empty,missing,cursor_pos(),order]);}
