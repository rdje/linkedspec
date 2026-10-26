Top:: I {
 free_source=undef;free_calls=0;free_result=has_key(free_source,{free_calls=num_add(free_calls,1);free_source={"a":1};"a"});
 literal_calls=0;literal_result=has_key(undef,{literal_calls=num_add(literal_calls,1);"a"});
 missing_calls=0;missing_result=has_key(missing_source,{missing_calls=num_add(missing_calls,1);missing_source={"a":1};"a"});
 source=undef;source_calls=0;key_calls=0;order="";
 receiver={source_calls=num_add(source_calls,1);order=cat(order,"S");source}.has_key({key_calls=num_add(key_calls,1);order=cat(order,"K");source={"a":1};"a"}).cat({order=cat(order,"C");"!"});
 valid_source={"a":1};valid_order="";valid=has_key({valid_order=cat(valid_order,"S");valid_source},{valid_order=cat(valid_order,"K");valid_source={"z":2};"a"});
 empty_source={};empty_calls=0;empty=has_key(empty_source,{empty_calls=num_add(empty_calls,1);empty_source={"a":1};"a"});
 invalid_effects=0;bad=[{invalid_effects=num_add(invalid_effects,1);undef}.has_key(),{invalid_effects=num_add(invalid_effects,1);undef}.has_key({invalid_effects=num_add(invalid_effects,1);"a"},{invalid_effects=num_add(invalid_effects,1);"extra"})];
 return({"free":[free_result,free_calls,free_source],"literal":[literal_result,literal_calls],"missing":[missing_result,missing_calls,missing_source],"receiver":[receiver,order,source_calls,key_calls,source],"valid":[valid,valid_order,valid_source],"empty":[empty,empty_calls,empty_source],"bad":bad,"invalid_effects":invalid_effects});
}
