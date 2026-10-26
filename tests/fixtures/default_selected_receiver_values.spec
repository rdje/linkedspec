Top:: I {
 fallback=["a","b"]; meta={"b":"y","a":"x"}; empty_meta={};
 direct="".coalesce_nonempty(fallback).join_values("-").uppercase();
 joined=[].join_values(",").coalesce_nonempty(fallback).join_values("-").uppercase();
 nested=uppercase(join_values("-",coalesce_nonempty("",fallback)));
 hash=[].join_values(",").coalesce_nonempty(meta).sorted_values().join_values(":").uppercase();
 retained=["kept"].join_values(",").coalesce_nonempty(fallback).uppercase();
 wrong_array=["kept"].join_values(",").coalesce_nonempty(fallback).sorted();
 wrong_hash=["kept"].join_values(",").coalesce_nonempty(meta).sorted_values();
 after_trim=[].join_values(",").coalesce_nonempty("kept").trim().sorted();
 selected=[].first().coalesce_nonempty(fallback).join_values("-").uppercase();
 exhausted=[].join_values(",").coalesce_nonempty(undef,"").uppercase();
 empty_array=[].join_values(",").coalesce_nonempty([],fallback).count().add(1);
 empty_hash=[].join_values(",").coalesce_nonempty(empty_meta,meta).count_keys().add(1);
 zero=[].join_values(",").coalesce_nonempty(0).add(3);
 false_value=[].join_values(",").coalesce_nonempty(false).cat("!");
 order=""; items=["a","b"];
 snapshot=[].join_values({order=cat(order,"S");","}).coalesce_nonempty({order=cat(order,"D");items},{order=cat(order,"L");["late"]}).join_values({order=cat(order,"J");items+="c";"-"}).uppercase();
 lazy_order="";lazy=["kept"].join_values(",").coalesce_nonempty({lazy_order=cat(lazy_order,"L");fallback}).uppercase();
 direct_hash="".coalesce_nonempty(meta).sorted_values().join_values(":").uppercase();
 return([direct,joined,nested,hash,retained,wrong_array,wrong_hash,after_trim,selected,exhausted,empty_array,empty_hash,zero,false_value,snapshot,order,items,lazy,lazy_order,fallback,meta,direct_hash]);
}
