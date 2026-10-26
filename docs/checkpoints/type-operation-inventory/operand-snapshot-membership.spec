Top:: I {
 membership=[contains([undef],undef),contains([undef],""),contains([""],undef),contains([""],""),contains([undef,""],""),contains(["",undef],undef),contains([],undef),contains([0],"0"),contains([false],0)];
 indexes=[index_of([undef],undef),index_of([undef],""),index_of([""],undef),index_of([""],""),index_of([undef,""],""),index_of(["",undef],undef),index_of([],undef),index_of([0],"0"),index_of([false],0)];
 array_source=["a"];array_order="";array_result=index_of(array_source,{array_order=cat(array_order,"O");array_source=["z"];"a"});
 hash_source={"a":1};hash_order="";hash_result=has_key(hash_source,{hash_order=cat(hash_order,"O");hash_source={"z":2};"a"});
 absent_array=undef;absent_array_result=index_of(absent_array,{absent_array=["a"];"a"});
 absent_hash=undef;absent_hash_result=has_key(absent_hash,{absent_hash={"a":1};"a"});
 appended=["a"];appended_result=index_of(appended,{appended+="b";"b"});
 concat_source=["a"];concatenated=concat_arrays(concat_source,{concat_source=["z"];["b"]});
 merge_source={"a":1};merged=merge_hash(merge_source,{merge_source={"z":2};{"b":3}});
 unique=uniq([undef,"",undef,"",0,"0",false]);
 return({"unique":unique,"membership":membership,"indexes":indexes,"array_snapshot":[array_result,array_order,array_source],"hash_snapshot":[hash_result,hash_order,hash_source],"absent_array":[absent_array_result,absent_array],"absent_hash":[absent_hash_result,absent_hash],"appended":[appended_result,appended],"concatenated":[concatenated,concat_source],"merged":[merged,merge_source],"absent_controls":[index_of(undef,"a"),has_key(undef,"a")]});
}
