Top:: I {
 order="";
 first=coalesce_nonempty({order=cat(order,"A"); "first"},{order=cat(order,"X"); "late"});
 fallback=coalesce_nonempty({order=cat(order,"B"); ""},{order=cat(order,"C"); undef},{order=cat(order,"D"); "chosen"},{order=cat(order,"X"); "late"});
 zero=coalesce_nonempty(0,{order=cat(order,"X"); "late"});
 falsy=coalesce_nonempty(false,{order=cat(order,"X"); "late"});
 nested=coalesce_nonempty("",coalesce_nonempty(undef,"nested",{order=cat(order,"X"); "late"}));
 selected=coalesce_nonempty([""].first(),"selected");
 absent=coalesce_nonempty(undef,"",missing);
 return([first,fallback,zero,falsy,nested,selected,absent,order,coalesce_nonempty([],"late"),coalesce_nonempty({},"late")]);
}
