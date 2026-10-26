fn contains_items() { return(["a","b"]) }
Top:: I {
 items=["a","b"];meta={"a":"a","b":"b"};
 positive=items.contains("a").cat("!");negative=items.contains("z").cat("!");nested=cat(contains(items,"a"),"!");
 raw=[contains(["a","b"],"a"),contains(["a","b"],"z"),contains([],"a"),contains([undef],undef),contains([undef],""),contains([""],undef),contains([""],""),contains([0],"0"),contains([false],0)];
 boundaries=[[].contains("a").cat("!"),[].first().contains("a").cat("!"),[undef].contains(undef).cat("!"),[undef].contains("").cat("!"),[""].contains(undef).cat("!"),[""].contains("").cat("!"),[0].contains("0").cat("!")];
 literal=["a","b"].contains("a").cat("!");selected=[["a","b"]].first().contains("a").cat("!");
 split="a:b".split(":").contains("b").cat("!");concat=["a"].concat_arrays(["b"]).contains("b").cat("!");
 from_hash=meta.sorted_values().contains("b").cat("!");from_function=contains_items().contains("a").cat("!");from_default="".coalesce_nonempty(items).contains("a").cat("!");copied=items.copy().contains("a").cat("!");
 retained=items.contains("z").coalesce_nonempty("late").cat("!");generic=items.contains("a").is_defined().cat("!");false_data=items.contains("z").is_empty().cat("!");
 bridged=items.contains("a").cat(",x").split(",").last().uppercase();incompatible=items.contains("a").sorted();after_text=items.contains("a").cat("!").sorted_values();
 source=["a"];order="";source_calls=0;needle_calls=0;
 effected={source_calls=num_add(source_calls,1);order=cat(order,"S");source}.contains({needle_calls=num_add(needle_calls,1);order=cat(order,"O");source=["z"];"a"}).cat({order=cat(order,"C");source=[].first();"!"});
 invalid_effects=0;bad=[{invalid_effects=num_add(invalid_effects,1);items}.contains,{invalid_effects=num_add(invalid_effects,1);items}.contains(),{invalid_effects=num_add(invalid_effects,1);items}.contains({invalid_effects=num_add(invalid_effects,1);"a"},{invalid_effects=num_add(invalid_effects,1);"extra"})];
 missing_twins=[items.contains,items.contains()];
 return({"positive":positive,"negative":negative,"nested":nested,"raw":raw,"boundaries":boundaries,"literal":literal,"selected":selected,"split":split,"concat":concat,"hash":from_hash,"function":from_function,"default":from_default,"copied":copied,"retained":retained,"generic":generic,"false_data":false_data,"bridged":bridged,"incompatible":incompatible,"after_text":after_text,"effected":effected,"order":order,"source_calls":source_calls,"needle_calls":needle_calls,"source":source,"bad":bad,"invalid_effects":invalid_effects,"missing_twins":missing_twins,"items":items,"meta":meta});
}
