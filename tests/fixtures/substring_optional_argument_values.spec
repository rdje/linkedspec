Top:: I {
 omitted=[substr("abc",1),"abc".substr(1)];
 null_width=[substr("abc",1,undef),"abc".substr(1,undef)];
 boolean_starts=[substr("abc",true),substr("abc",false),"abc".substr(true),"abc".substr(false)];
 boolean_widths=[substr("abc",0,true),substr("abc",0,false),"abc".substr(0,true),"abc".substr(0,false)];
 integer_controls=[substr("abc",1.0),substr("abc","1"),substr("abc",-1),substr("abc",1.5),substr("abc",0,1.5)];
 null_controls=[substr(undef,0),substr("abc",undef),substr("abc",undef,1)];
 source="abc";order="";calls=0;
 present_null={order=cat(order,"S");calls=num_add(calls,1);source}.substr({order=cat(order,"I");source="zzz";true},{order=cat(order,"W");source=undef;undef}).cat({order=cat(order,"C");"!"});
 null_effects=[present_null,order,calls,source];
 source="abc";order="";calls=0;
 defined_width={order=cat(order,"S");calls=num_add(calls,1);source}.substr({order=cat(order,"I");source="zzz";true},{order=cat(order,"W");source=undef;true}).cat({order=cat(order,"C");"!"});
 defined_effects=[defined_width,order,calls,source];
 return({"omitted":omitted,"null_width":null_width,"boolean_starts":boolean_starts,"boolean_widths":boolean_widths,"integer_controls":integer_controls,"null_controls":null_controls,"null_effects":null_effects,"defined_effects":defined_effects});
}
