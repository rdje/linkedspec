fn default_missing() { return(undef) }
Top:: I {
 raw=[coalesce(undef,"fallback"),coalesce("","late"),coalesce(0,7),coalesce(false,true),coalesce(undef,undef),coalesce(undef,[2,3]),coalesce(undef,{"b":"b","a":"a"})];
 text=[undef.coalesce(" chosen ").trim().uppercase(),"".coalesce("late").cat("!"),0.coalesce(7).add(1),false.coalesce(true).cat("!"),undef.coalesce(undef," chosen ").trim().uppercase()];
 nested=[uppercase(trim(coalesce(undef," chosen "))),cat(coalesce("","late"),"!"),num_add(coalesce(0,7),1),cat(coalesce(false,true),"!"),uppercase(trim(coalesce(undef,undef," chosen ")))];
 containers=[undef.coalesce(["a","b"]).last().uppercase(),undef.coalesce({"b":"b","a":"a"}).sorted_values().first().uppercase()];
 retained=[[].coalesce(["late"]).count(),{}.coalesce({"late":1}).count_keys(),["a","b"].coalesce(["late"]).last().uppercase(),{"b":"b","a":"a"}.coalesce({"late":1}).sorted_values().first().uppercase()];
 score=undef;meta={"n":undef};
 sources=[score.coalesce("x").uppercase(),[].first().coalesce("x").uppercase(),meta["n"].coalesce("x").uppercase(),{undef}.coalesce("x").uppercase(),default_missing().coalesce("x").uppercase(),2.div(0).coalesce(7).add(1),"".trim().coalesce("late").cat("!"),and(false).coalesce(true).cat("!")];
 bridge=undef.coalesce("a,b").split(",").last().uppercase();
 recovered=false.coalesce(true).add(1).coalesce(["a","b"]).last().uppercase();
 exhausted=[undef.coalesce(undef),undef.coalesce(undef,undef),undef.coalesce(undef).is_undefined().cat("!")];
 defaults=["".coalesce("late").coalesce_nonempty("chosen").uppercase(),undef.coalesce(undef).coalesce(["a","b"]).last().uppercase()];
 calls=0;order="";source=undef;fallback=["a","b"];
 snapshot={order=cat(order,"S");calls=num_add(calls,1);source}.coalesce({order=cat(order,"D");source=1;fallback},{order=cat(order,"L");["late"]}).join_values({order=cat(order,"C");fallback=["z"];":"}).uppercase();
 kept_order="";kept_source=["a","b"];
 kept_snapshot={kept_order=cat(kept_order,"S");kept_source}.coalesce({kept_order=cat(kept_order,"L");["late"]}).join_values({kept_order=cat(kept_order,"C");kept_source=["z"];":"}).uppercase();
 hash_order="";hash_source={"b":"b","a":"a"};
 hash_snapshot=undef.coalesce(hash_source).pick_keys({hash_order=cat(hash_order,"C");hash_source["a"]="z";"a"}).sorted_values().first().uppercase();
 hits=0;
 lazy=["".coalesce({hits=num_add(hits,1);"late"}),false.coalesce({hits=num_add(hits,1);true}),0.coalesce({hits=num_add(hits,1);7}),"safe".coalesce({target=1;target[0]=2;"bad"})];
 items=["a","b"];copy_meta={"a":"a","b":"b"};
 chosen_items=undef.coalesce(items);chosen_meta=undef.coalesce(copy_meta);
 items[0]="z";copy_meta["a"]="z";
 values=["zero","one"];values[undef.coalesce(1)]="updated";
 reject_order="";rejected={reject_order=cat(reject_order,"S");"kept"}.coalesce({reject_order=cat(reject_order,"L");["late"]}).take({reject_order=cat(reject_order,"A");1});
 prefix_order="";after_text={prefix_order=cat(prefix_order,"S");undef}.coalesce("kept").cat({prefix_order=cat(prefix_order,"C");"!"}).sorted_values();
 malformed_order="";malformed={malformed_order=cat(malformed_order,"S");undef}.coalesce().cat({malformed_order=cat(malformed_order,"C");"!"});
 return({"raw":raw,"text":text,"nested":nested,"containers":containers,"retained":retained,"sources":sources,"bridge":bridge,"recovered":recovered,"exhausted":exhausted,"defaults":defaults,"snapshot":snapshot,"order":order,"calls":calls,"source":source,"fallback":fallback,"kept_snapshot":kept_snapshot,"kept_order":kept_order,"kept_source":kept_source,"hash_snapshot":hash_snapshot,"hash_order":hash_order,"hash_source":hash_source,"lazy":lazy,"hits":hits,"chosen_items":chosen_items,"chosen_meta":chosen_meta,"items":items,"copy_meta":copy_meta,"values":values,"rejected":rejected,"reject_order":reject_order,"after_text":after_text,"prefix_order":prefix_order,"malformed":malformed,"malformed_order":malformed_order});
}
