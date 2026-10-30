Top::
 I {order="";
text=call(Child)[{order=cat(order,"I");start_capture_slice();0}].cat({order=cat(order,"C");"!"});
empty=call(Child)[0].coalesce({order=cat(order,"F");"fallback"}).cat("!");
number=call(Child)[1].add(1);
boolean=call(Child)[3].coalesce(true);
recovered=call(Child)[4].coalesce(["z","tail"])[-1].uppercase();
array_value=call(Child)[-2].sorted().last().uppercase();
hash_value=call(HashChild)["items"][-1].uppercase();
missing=call(Child)[99][{order=cat(order,"J");0}].coalesce("M");
invalid=call(Child)[2].take({order=cat(order,"BAD");1});
kept=call(Child)[2].cat("!");
return([text,empty,number,boolean,recovered,array_value,hash_value,missing,invalid,kept,cursor_pos(),capture_slice_pos(),order]);}

Child:
 I {chunk=capture_until_boundary(End);return([chunk,0,"0",false,undef,["b","a"],hash("name","tail")])}
HashChild:
 I {return(hash("items",["red","tail"]))}
End:OR{1,1}
 /END/
