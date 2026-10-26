fn defined_word() { return("abc") }
fn defined_items() { return([1]) }
fn defined_meta() { return({"a":1}) }
Top:: I {
 word="abc"; items=[]; meta={}; missing=[].first();
 positive=[word.is_defined().cat("!"),missing.is_undefined().cat("!")];
 negative=[missing.is_defined().cat("!"),word.is_undefined().cat("!")];
 nested=[cat(is_defined(word),"!"),cat(is_undefined(missing),"!")];
 boundaries=["".is_defined().cat("!"),0.is_defined().cat("!"),false.is_defined().cat("!"),[].is_defined().cat("!"),{}.is_defined().cat("!"),missing.is_defined().cat("!"),missing.is_undefined().cat("!")];
 selected=["abc"].first().is_defined().cat("!"); pipeline=" abc ".trim().is_defined().cat("!"); numeric=1.add(1).is_defined().cat("!");
 named=[items.is_defined().cat("!"),meta.is_defined().cat("!")];
 copied=[items.copy().is_defined().cat("!"),meta.copy().is_defined().cat("!"),defined_items().copy().is_defined().cat("!"),defined_meta().copy().is_defined().cat("!")];
 from_function=defined_word().is_defined().cat("!"); from_default="".coalesce_nonempty("abc").is_defined().cat("!");
 retained=missing.is_defined().coalesce_nonempty("late").cat("!");
 bridged=word.is_defined().cat(",x").split(",").last().uppercase();
 predicate_again=missing.is_defined().is_defined().cat("!"); false_empty=missing.is_defined().is_empty().cat("!");
 incompatible=word.is_defined().sorted(); after_text=missing.is_undefined().cat("!").sorted_values();
 source="abc";order="";calls=0;
 effected={calls=num_add(calls,1);order=cat(order,"S");source}.is_defined().cat({order=cat(order,"C");source=[].first();"!"});
 invalid_effects=0;
 bad=[{invalid_effects=num_add(invalid_effects,1);word}.is_defined({invalid_effects=num_add(invalid_effects,1);"extra"}).cat("!"),{invalid_effects=num_add(invalid_effects,1);missing}.is_undefined({invalid_effects=num_add(invalid_effects,1);"extra"}).cat("!")];
 return({"positive":positive,"negative":negative,"nested":nested,"boundaries":boundaries,"selected":selected,"pipeline":pipeline,"numeric":numeric,"named":named,"copied":copied,"function":from_function,"default":from_default,"retained":retained,"bridged":bridged,"predicate_again":predicate_again,"false_empty":false_empty,"incompatible":incompatible,"after_text":after_text,"effected":effected,"order":order,"calls":calls,"source":source,"bad":bad,"invalid_effects":invalid_effects,"word":word,"items":items,"meta":meta});
}
