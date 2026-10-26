Top:: I {
 parts=["a","b"];meta={"a":"a","b":"b"};order="";
 direct=parts.index_of("b").add(1);nested=num_add(index_of(parts,"b"),1);
 zero=parts.index_of("a").add(1);absent=parts.index_of("z").add(1);
 from_hash=meta.sorted_values().index_of("b").add(1);
 from_default="".coalesce_nonempty(parts).index_of("b").add(1);
 incompatible=parts.index_of("b").sorted();
 effected={order=cat(order,"S");parts}.index_of({order=cat(order,"N");parts+="c";"b"}).add({order=cat(order,"A");parts+="d";1});
 invalid_effects=0;
 missing={invalid_effects=num_add(invalid_effects,1);["a"]}.index_of().add(1);
 extra={invalid_effects=num_add(invalid_effects,1);["a"]}.index_of({invalid_effects=num_add(invalid_effects,1);"a"},{invalid_effects=num_add(invalid_effects,1);"late"}).add(1);
 return([direct,nested,zero,absent,from_hash,from_default,incompatible,effected,order,parts,missing,extra,invalid_effects]);
}