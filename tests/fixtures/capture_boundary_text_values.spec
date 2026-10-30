Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";
a=capture_slice().coalesce("missing").cat("!");
b=capture_slice_until_cursor().coalesce("").split(":")[-1].uppercase();
c=capture_rest().coalesce("").length().add(1);
d=capture_from_rule_start().coalesce("").cat("!");
invalid=capture_rest().coalesce("").take({order=cat(order,"BAD");1});
snapshot=capture_rest().coalesce("").cat({order=cat(order,"S");start_capture_slice();"!"});
empty=capture_rest().coalesce({order=cat(order,"F");"fallback"}).cat("!");
return([a,b,c,d,invalid,snapshot,empty,capture_slice_pos(),order]);}
