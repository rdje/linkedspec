Top:: I {
 order="";
 first={order=cat(order,"A"); "first"}.coalesce_nonempty({order=cat(order,"X"); "late"});
 fallback={order=cat(order,"B"); ""}.coalesce_nonempty({order=cat(order,"C"); undef},{order=cat(order,"D"); "chosen"},{order=cat(order,"X"); "late"}).uppercase();
 selected=[""].first().coalesce_nonempty({order=cat(order,"E"); "selected"},{order=cat(order,"X"); "late"}).uppercase();
 absent=[].first().coalesce_nonempty({order=cat(order,"F"); "empty"},{order=cat(order,"X"); "late"});
 zero=0; zero_result=zero.coalesce_nonempty({order=cat(order,"X"); "late"});
 falsy=false; false_result=falsy.coalesce_nonempty({order=cat(order,"X"); "late"});
 all_empty="".coalesce_nonempty(undef,"");
 prior=" a ".trim().coalesce_nonempty({order=cat(order,"X"); "late"}).uppercase();
 return([first,fallback,selected,absent,zero_result,false_result,all_empty,prior,order]);
}
