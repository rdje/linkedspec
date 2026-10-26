fn logical_flag() { return(or(false,true)) }
Top:: I {
 raw=[and(true),and(false),or(false,true),or(false,0),not(false),not(true)];
 text=[and(true).cat("!"),and(false).cat("!"),or(false,true).cat("!"),or(false,0).cat("!"),not(false).cat("!"),not(true).cat("!")];
 nested=[cat(and(true),"!"),cat(and(false),"!"),cat(or(false,true),"!"),cat(or(false,0),"!"),cat(not(false),"!"),cat(not(true),"!")];
 truthiness=[and("0").cat("!"),or("false").cat("!"),not([]).cat("!"),not({}).cat("!"),not([undef]).cat("!"),not({"a":undef}).cat("!")];
 flag=and(false);meta={"flag":or(false,true)};
 sources=[flag.cat("!"),[not(false)].first().cat("!"),meta["flag"].cat("!"),{and(false)}.cat("!"),logical_flag().cat("!"),true.cat("!"),false.cat("!")];
 bridge=and(true).cat(",x").split(",").last().uppercase();
 or_bridge=or(false).cat(",x").split(",").last().uppercase();
 not_bridge=not(false).cat(",x").split(",").last().uppercase();
 nested_bridge=uppercase(last(split(cat(and(true),",x"),",")));
 fallback_calls=0;
 retained=and(false).coalesce_nonempty({fallback_calls=num_add(fallback_calls,1);"late"}).cat("!");
 rejected_number=and(true).add(1);
 recovered=or(false).add(1).coalesce_nonempty(7).add(1);
 array_default=not(false).add(1).coalesce_nonempty(["a","b"]).last().uppercase();
 hash_default=and(false).add(1).coalesce_nonempty({"b":"b","a":"a"}).sorted_values().first().uppercase();
 defined=and(false).is_defined().cat("!");
 empty=or(false).is_empty().cat("!");
 incompatible=not(false).sorted();
 after_text=and(true).cat("x").sorted_values();
 source=true;order="";calls=0;
 effected=and({order=cat(order,"L");calls=num_add(calls,1);source},{order=cat(order,"R");calls=num_add(calls,1);source=false;false}).cat({order=cat(order,"C");source=undef;"!"});
 or_order="";or_effected=or({or_order=cat(or_order,"L");true},{or_order=cat(or_order,"R");false}).cat({or_order=cat(or_order,"C");"!"});
 not_order="";not_effected=not({not_order=cat(not_order,"S");false}).cat({not_order=cat(not_order,"C");"!"});
 return({"raw":raw,"text":text,"nested":nested,"truthiness":truthiness,"sources":sources,"bridge":bridge,"or_bridge":or_bridge,"not_bridge":not_bridge,"nested_bridge":nested_bridge,"retained":retained,"fallback_calls":fallback_calls,"rejected_number":rejected_number,"recovered":recovered,"array_default":array_default,"hash_default":hash_default,"defined":defined,"empty":empty,"incompatible":incompatible,"after_text":after_text,"effected":effected,"order":order,"calls":calls,"source":source,"or_effected":or_effected,"or_order":or_order,"not_effected":not_effected,"not_order":not_order,"flag":flag,"meta":meta});
}
