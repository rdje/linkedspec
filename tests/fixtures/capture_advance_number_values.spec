Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_capture_slice(origin);order="";
a=capture_take_len().coalesce(99).add({order=cat(order,"A");1}).cat("!");apos=capture_slice_pos();
start_capture_slice_from(origin);
b=capture_take_until_cursor_len().coalesce(0).cat(":tail").split(":")[-1].uppercase();bpos=capture_slice_pos();
start_capture_slice_from(origin);
c=capture_take_rest_len().coalesce(0).add(1);cpos=capture_slice_pos();
start_capture_slice_from(origin);
invalid=capture_take_until_cursor_len().coalesce(0).take({order=cat(order,"BAD");1});
zero=capture_take_until_cursor_len().coalesce({order=cat(order,"F");99}).add(1);
missing=capture_take_len().coalesce(99).cat("!");
start_capture_slice_from(origin);
snapshot=capture_take_rest_len().coalesce(0).cat({start_capture_slice();"!"});
return([a,b,c,[apos,bpos,cpos],invalid,zero,missing,snapshot,capture_slice_pos(),cursor_pos(),order]);}
