fn scalar_string_value() { return(" a ") }
Top:: I {
 raw=[trim(" a "),lowercase("AB"),uppercase("ab"),replace_substr("a-b","-","_"),rm_prefix("pre_a","pre_"),rm_suffix("a_end","_end"),substr("abc",1),cat("a","b")];
 text=[" a ".trim().cat("!"),"AB".lowercase().cat("!"),"ab".uppercase().cat("!"),"a-b".replace_substr("-","_").cat("!"),"pre_a".rm_prefix("pre_").cat("!"),"a_end".rm_suffix("_end").cat("!"),"abc".substr(1).cat("!"),"a".cat("b").cat("!")];
 nested=[cat(trim(" a "),"!"),cat(lowercase("AB"),"!"),cat(uppercase("ab"),"!"),cat(replace_substr("a-b","-","_"),"!"),cat(rm_prefix("pre_a","pre_"),"!"),cat(rm_suffix("a_end","_end"),"!"),cat(substr("abc",1),"!"),cat(cat("a","b"),"!")];
 bridges=[" a,b ".trim().split(",").last().uppercase(),"A,B".lowercase().split(",").last().uppercase(),"a,b".uppercase().split(",").last(),"a-b".replace_substr("-",",").split(",").last().uppercase(),"pre_a,b".rm_prefix("pre_").split(",").last().uppercase(),"a,b_end".rm_suffix("_end").split(",").last().uppercase(),"za,b".substr(1).split(",").last().uppercase(),"a".cat(",b").split(",").last().uppercase()];
 boundaries=[" a ".trim().sorted(),"A".lowercase().sorted_values(),"a".uppercase().sorted(),"a-b".replace_substr("-","_").sorted_values(),"pre_a".rm_prefix("pre_").sorted(),"a_end".rm_suffix("_end").sorted_values(),"abc".substr(1).sorted(),"a".cat("b").sorted_values()];
 empty=[" ".trim().cat("!"),"".lowercase().cat("!"),"".uppercase().cat("!"),"".replace_substr("a","b").cat("!"),"".rm_prefix("x").cat("!"),"".rm_suffix("x").cat("!"),"".substr(0).cat("!"),"".cat("").cat("!")];
 nulls=[undef.trim(),undef.lowercase(),undef.uppercase(),undef.replace_substr("a","b"),undef.rm_prefix("a"),undef.rm_suffix("a"),undef.substr(0),undef.cat("x")];
 unicode=["ΟΣ".lowercase(),"Straße ﬃ".uppercase(),"a🙂b".substr(1,1).cat("!")];
 text_source=" a ";meta={"name":" a "};
 sources=[text_source.trim().uppercase(),[" a "].first().trim().uppercase(),meta["name"].trim().uppercase(),{" a "}.trim().uppercase(),scalar_string_value().trim().uppercase(),trim(" a ").uppercase(),[" a "].join_values(",").trim().uppercase(),undef.coalesce(" a ").trim().uppercase()];
 numeric=[" 4 ".trim().add(1),"4".uppercase().add(1),0.rm_prefix("x").add(1),false.rm_suffix("x").add(1)];
 generic=[" ".trim().is_empty().cat("!"),"a".uppercase().is_defined().cat("!")];
 identity=[0.replace_substr("","X"),0.rm_prefix("x"),0.rm_suffix("x"),false.rm_prefix("x"),false.rm_suffix("x"),"0".rm_prefix("x"),0.rm_prefix("0"),0.rm_suffix("0")];
 prefix_items=["p"];prefix_items[0.rm_prefix("x")]="updated";
 suffix_items=["s"];suffix_items[rm_suffix(0,"x")]="updated";
 replacement_items=["r"];replacement_items[replace_substr(0,"","X")]="updated";
 key=rm_prefix(0,"x");named_items=["n"];named_items[key]="updated";
 keys={};keys["0".rm_prefix("x")]="string";keys[10.rm_suffix("0")]="matched";keys[0.rm_prefix("0")]="empty";
 source="a-b";order="";calls=0;
 effected={order=cat(order,"S");calls=num_add(calls,1);source}.replace_substr({order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"}).cat({order=cat(order,"C");source=undef;"!"});
 null_order="";null_effect={null_order=cat(null_order,"S");undef}.replace_substr({null_order=cat(null_order,"O");"a"},{null_order=cat(null_order,"N");"b"}).cat({null_order=cat(null_order,"C");"!"});
 cat_order="";null_cat={cat_order=cat(cat_order,"S");undef}.cat({cat_order=cat(cat_order,"C");"x"});
 reject_order="";rejected={reject_order=cat(reject_order,"S");" a "}.trim().cat({reject_order=cat(reject_order,"C");"!"}).take({reject_order=cat(reject_order,"A");1});
 selected_order="";selected_rejected=[{selected_order=cat(selected_order,"S");" a "}].first().trim().take({selected_order=cat(selected_order,"A");1});
 malformed_order="";
 malformed=[{malformed_order=cat(malformed_order,"S");"a"}.trim({malformed_order=cat(malformed_order,"A");1}),{malformed_order=cat(malformed_order,"S");"a"}.lowercase(1),{malformed_order=cat(malformed_order,"S");"a"}.uppercase(1),{malformed_order=cat(malformed_order,"S");"a"}.replace_substr({malformed_order=cat(malformed_order,"A");"x"}),{malformed_order=cat(malformed_order,"S");"a"}.replace_substr("x","y",1),{malformed_order=cat(malformed_order,"S");"a"}.rm_prefix(),{malformed_order=cat(malformed_order,"S");"a"}.rm_prefix("x",1),{malformed_order=cat(malformed_order,"S");"a"}.rm_suffix(),{malformed_order=cat(malformed_order,"S");"a"}.rm_suffix("x",1),{malformed_order=cat(malformed_order,"S");"a"}.substr(),{malformed_order=cat(malformed_order,"S");"a"}.substr(0,1,2),{malformed_order=cat(malformed_order,"S");"a"}.cat().cat({malformed_order=cat(malformed_order,"C");"!"})];
 return({"raw":raw,"text":text,"nested":nested,"bridges":bridges,"boundaries":boundaries,"empty":empty,"nulls":nulls,"unicode":unicode,"sources":sources,"numeric":numeric,"generic":generic,"identity":identity,"prefix_items":prefix_items,"suffix_items":suffix_items,"replacement_items":replacement_items,"named_items":named_items,"keys":keys,"effected":effected,"order":order,"calls":calls,"source":source,"null_effect":null_effect,"null_order":null_order,"null_cat":null_cat,"cat_order":cat_order,"rejected":rejected,"reject_order":reject_order,"selected_rejected":selected_rejected,"selected_order":selected_order,"malformed":malformed,"malformed_order":malformed_order});
}
