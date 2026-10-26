Top:: I {
 order="";
 first=coalesce({order=cat(order,"A"); ""},{order=cat(order,"X"); "late"});
 fallback=coalesce({order=cat(order,"B"); undef},{order=cat(order,"C"); "chosen"},{order=cat(order,"X"); "late"});
 nested=coalesce(undef,coalesce(undef,"nested",{order=cat(order,"X"); "late"}));
 zero=coalesce(0,{order=cat(order,"X"); "late"});
 falsy=coalesce(false,{order=cat(order,"X"); "late"});
 selected=coalesce([].first(),"selected");
 absent=coalesce(undef,missing);
 return([first,fallback,nested,zero,falsy,selected,absent,order,coalesce([],"late"),coalesce({},"late")]);
}
