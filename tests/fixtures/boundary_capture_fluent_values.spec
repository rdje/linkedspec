Top::
 I {order="";
a=capture_until_boundary(End).coalesce("M").cat({order=cat(order,"A");start_capture_slice();"!"});apos=cursor_pos();
b=capture_until_boundary(End).coalesce({order=cat(order,"F");"fallback"}).cat("!");
missing=capture_until_boundary(Missing).coalesce("missing").cat("!");
number=capture_until_boundary(Far).coalesce("").length().add(1);
selected=number.cat(":tail").split(":")[-1].uppercase();
invalid=capture_until_boundary(End).coalesce("").take({order=cat(order,"BAD");1});
last=capture_until_boundary(End).coalesce({order=cat(order,"F");"fallback"}).cat("!");
return([a,b,missing,number,selected,invalid,last,apos,cursor_pos(),capture_slice_pos(),order]);}
End:OR{1,1}
 /END/
Far:OR{1,1}
 /TAIL/
