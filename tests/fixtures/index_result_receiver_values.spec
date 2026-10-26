fn search_words() { return(["a","b"]) }
Top:: I {
 parts=["a","b"]; meta={"a":"a","b":"b"};
 direct=parts.index_of("b").add(1); nested=num_add(index_of(parts,"b"),1);
 zero=parts.index_of("a").add(1); absent=parts.index_of("z").add(1);
 empty=[].index_of("a").add(1); null_source=[].first().index_of("a").add(1);
 selected=[["a","b"]].first().index_of("b").add(1);
 pipeline=["b","a"].sorted().index_of("b").add(1);
 from_hash=meta.sorted_values().index_of("b").add(1);
 from_string="a,b".split(",").index_of("b").add(1);
 from_function=search_words().index_of("b").add(1);
 from_default="".coalesce_nonempty(parts).index_of("b").add(1);
 text=parts.index_of("b").cat("!");
 bridged=parts.index_of("b").cat(",x").split(",").last().uppercase();
 fallback=parts.index_of("z").coalesce_nonempty(7).add(1);
 incompatible=parts.index_of("b").sorted();
 after_text=parts.index_of("b").cat("!").sorted(); bad_min=parts.index_of("b").min();
 items=["a","b"];order="";
 effected={order=cat(order,"S");items}.index_of({order=cat(order,"N");items+="c";"b"}).add({order=cat(order,"A");items+="d";1});
 named_parts=["a"];named_order="";
 named_snapshot=named_parts.index_of({named_order=cat(named_order,"N");named_parts+="b";"b"});
 computed_parts=["a"];computed_order="";
 computed_snapshot={computed_order=cat(computed_order,"S");computed_parts}.index_of({computed_order=cat(computed_order,"N");computed_parts+="b";"b"});
 zero_target=["old","old"];position=parts.index_of("a").add(0);zero_target[position]="zero";
 invalid_effects=0;
 missing={invalid_effects=num_add(invalid_effects,1);parts}.index_of().add(1);
 extra={invalid_effects=num_add(invalid_effects,1);parts}.index_of({invalid_effects=num_add(invalid_effects,1);"b"},{invalid_effects=num_add(invalid_effects,1);"late"}).add(1);
 return([direct,nested,zero,absent,empty,null_source,selected,pipeline,from_hash,from_string,from_function,from_default,text,bridged,fallback,incompatible,after_text,bad_min,effected,order,items,named_snapshot,named_order,named_parts,computed_snapshot,computed_order,computed_parts,zero_target,missing,extra,invalid_effects,parts,meta]);
}
