fn word_value() { return("abc") }
Top:: I {
 word="abc";meta={"a":"abc"};
 positive=[word.starts_with("a").cat("!"),word.ends_with("c").cat("!"),word.contains_substr("b").cat("!"),word.matches(/^a/).cat("!")];
 negative=[word.starts_with("z").cat("!"),word.ends_with("z").cat("!"),word.contains_substr("z").cat("!"),word.matches(/^z/).cat("!")];
 nested=[cat(starts_with(word,"a"),"!"),cat(ends_with(word,"c"),"!"),cat(contains_substr(word,"b"),"!"),cat(matches(word,/^a/),"!")];
 boundaries=[[].first().starts_with("").cat("!"),[].first().matches(/^$/).cat("!"),word.ends_with([].first()).cat("!"),word.contains_substr([].first()).cat("!"),"".starts_with("").cat("!"),"".ends_with("").cat("!"),"".contains_substr("").cat("!"),"".matches(/^$/).cat("!"),"ABC".matches(/^a/i).cat("!")];
 selected=["abc"].first().starts_with("a").cat("!");pipeline=" ABC ".trim().lowercase().ends_with("c").cat("!");
 from_hash=meta.sorted_values().first().contains_substr("b").cat("!");from_split="abc,x".split(",").first().matches(/^a/).cat("!");
 from_function=word_value().contains_substr("b").cat("!");from_default="".coalesce_nonempty("abc").matches(/^a/).cat("!");
 from_join=["a","b"].join_values("").starts_with("a").cat("!");
 retained=word.contains_substr("z").coalesce_nonempty("late").cat("!");
 bridged=word.matches(/^a/).cat(",x").split(",").last().uppercase();
 predicate_again=word.matches(/^a/).is_nonempty().cat("!");false_data=word.contains_substr("z").is_empty().cat("!");
 incompatible=word.starts_with("a").sorted();after_text=word.matches(/^a/).cat("!").sorted_values();
 source="abc";order="";source_calls=0;operand_calls=0;
 effected={source_calls=num_add(source_calls,1);order=cat(order,"S");source}.starts_with({operand_calls=num_add(operand_calls,1);order=cat(order,"O");source="zzz";"a"}).cat({order=cat(order,"C");source=cat(source,"tail");"!"});
 regex_source="abc";regex_order="";
 regex_effected={regex_order=cat(regex_order,"S");regex_source}.matches(/^a/).cat({regex_order=cat(regex_order,"C");regex_source="changed";"!"});
 invalid_effects=0;
 bad=[{invalid_effects=num_add(invalid_effects,1);word}.starts_with().cat("!"),{invalid_effects=num_add(invalid_effects,1);word}.ends_with().cat("!"),{invalid_effects=num_add(invalid_effects,1);word}.contains_substr().cat("!"),{invalid_effects=num_add(invalid_effects,1);word}.matches().cat("!"),{invalid_effects=num_add(invalid_effects,1);word}.starts_with({invalid_effects=num_add(invalid_effects,1);"a"},"x").cat("!"),{invalid_effects=num_add(invalid_effects,1);word}.ends_with({invalid_effects=num_add(invalid_effects,1);"c"},"x").cat("!"),{invalid_effects=num_add(invalid_effects,1);word}.contains_substr({invalid_effects=num_add(invalid_effects,1);"b"},"x").cat("!"),{invalid_effects=num_add(invalid_effects,1);word}.matches(/^a/,{invalid_effects=num_add(invalid_effects,1);"x"}).cat("!")];
 return({"positive":positive,"negative":negative,"nested":nested,"boundaries":boundaries,"selected":selected,"pipeline":pipeline,"hash":from_hash,"split":from_split,"function":from_function,"default":from_default,"join":from_join,"retained":retained,"bridged":bridged,"predicate_again":predicate_again,"false_data":false_data,"incompatible":incompatible,"after_text":after_text,"effected":effected,"order":order,"source_calls":source_calls,"operand_calls":operand_calls,"source":source,"regex_effected":regex_effected,"regex_order":regex_order,"regex_source":regex_source,"bad":bad,"invalid_effects":invalid_effects,"word":word,"meta":meta});
}
