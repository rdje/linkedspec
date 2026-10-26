fn empty_items() { return([]) }
fn full_items() { return(["a"]) }
fn full_meta() { return({"a":1}) }
Top:: I {
 meta={"a":1};empty_meta={};parts=[];zero=0;
 bound_meta=full_meta(); copied_hash_binding=bound_meta.copy().is_empty().cat("!");
 bound_items=full_items(); copied_binding=bound_items.copy().is_empty().cat("!");
 direct=[].is_empty().cat("!"); nested=cat(is_empty([]),"!");
 nonempty=["a"].is_nonempty().cat("!"); false_result=["a"].is_empty().coalesce_nonempty("late").cat("!");
 hashes=[{}.is_empty().cat("!"),empty_meta.is_empty().cat("!"),meta.is_empty().cat("!")];
 scalar_sources=["".is_empty().cat("!"),"0".is_nonempty().cat("!"),zero.is_nonempty().cat("!"),[].first().is_empty().cat("!")];
 hash_pipeline=meta.copy().is_empty().cat("!");
 selected=[["a"]].first().is_nonempty().cat("!"); pipeline=["a"].drop_front().is_empty().cat("!");
 from_function=empty_items().is_empty().cat("!"); from_default="".coalesce_nonempty(parts).is_empty().cat("!");
 bridged=["a"].is_empty().cat(",x").split(",").last().uppercase();
 predicate_again=[].is_empty().is_nonempty().cat("!");
 incompatible=[].is_empty().sorted();after_text=[].is_empty().cat("!").sorted_values();
 order="";calls=0;source=[];
 effected={calls=num_add(calls,1);order=cat(order,"S");source}.is_empty().cat({order=cat(order,"A");source+="x";"!"});
 invalid_effects=0;
 bad_empty={invalid_effects=num_add(invalid_effects,1);parts}.is_empty({invalid_effects=num_add(invalid_effects,1);1}).cat("!");
 bad_nonempty={invalid_effects=num_add(invalid_effects,1);parts}.is_nonempty({invalid_effects=num_add(invalid_effects,1);1}).cat("!");
 return({"copied_hash_binding":copied_hash_binding,"copied_binding":copied_binding,"hash_pipeline":hash_pipeline,"direct":direct,"nested":nested,"nonempty":nonempty,"false_result":false_result,"hashes":hashes,"scalar_sources":scalar_sources,"selected":selected,"pipeline":pipeline,"function":from_function,"default":from_default,"bridged":bridged,"predicate_again":predicate_again,"incompatible":incompatible,"after_text":after_text,"effected":effected,"order":order,"calls":calls,"source":source,"bad_empty":bad_empty,"bad_nonempty":bad_nonempty,"invalid_effects":invalid_effects,"parts":parts,"meta":meta});
}
