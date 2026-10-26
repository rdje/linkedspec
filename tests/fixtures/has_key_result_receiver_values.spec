fn make_meta() { return({"a":"x"}) }
Top:: I {
 meta={"a":"x","off":false,"nil":undef};key="a";
 direct=meta.has_key("a").cat("!");nested=cat(has_key(meta,"a"),"!");
 presence=[meta.has_key("missing").cat("!"),meta.has_key("off").cat("!"),meta.has_key("nil").cat("!")];
 selected=[meta].first().has_key("a").cat("!"); pipeline=meta.copy().has_key("a").cat("!");
 literal={"a":"x"}.has_key("a").cat("!"); from_function=make_meta().has_key("a").cat("!");
 from_default="".coalesce_nonempty(meta).has_key("a").cat("!");
 keys=[meta.has_key(key).cat("!"),meta.has_key(cat("a","")).cat("!"),meta.has_key({"a"}).cat("!")];
 retained=meta.has_key("missing").coalesce_nonempty("late").cat("!");
 bridged=meta.has_key("a").cat(",x").split(",").last().uppercase();
 incompatible=meta.has_key("a").sorted_values(); after_text=meta.has_key("a").cat("!").sorted();
 source={"a":"x"};order="";
 effected={order=cat(order,"S");source}.has_key({order=cat(order,"K");source["late"]="new";"a"}).cat({order=cat(order,"A");source["last"]="new";"!"});
 named={"a":"x"};named_order="";
 named_snapshot=named.has_key({named_order=cat(named_order,"K");named["late"]="new";"late"}).cat("!");
 computed={"a":"x"};computed_order="";
 computed_snapshot={computed_order=cat(computed_order,"S");computed}.has_key({computed_order=cat(computed_order,"K");computed["late"]="new";"late"}).cat("!");
 invalid_effects=0;
 missing={invalid_effects=num_add(invalid_effects,1);meta}.has_key().cat("!");
 extra={invalid_effects=num_add(invalid_effects,1);meta}.has_key({invalid_effects=num_add(invalid_effects,1);"a"},{invalid_effects=num_add(invalid_effects,1);"late"}).cat("!");
 return({"direct":direct,"nested":nested,"presence":presence,"selected":selected,"pipeline":pipeline,"literal":literal,"function":from_function,"default":from_default,"keys":keys,"retained":retained,"bridged":bridged,"incompatible":incompatible,"after_text":after_text,"effected":effected,"order":order,"source":source,"named_snapshot":named_snapshot,"named_order":named_order,"named":named,"computed_snapshot":computed_snapshot,"computed_order":computed_order,"computed":computed,"missing":missing,"extra":extra,"invalid_effects":invalid_effects,"meta":meta});
}
