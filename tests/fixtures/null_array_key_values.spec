Top:: I {
 membership=[contains([undef],undef),contains([undef],""),contains([""],undef),contains([""],""),contains([undef,""],""),contains(["",undef],undef),contains([],undef),contains([0],"0"),contains([false],0)];
 indexes=[index_of([undef],undef),index_of([undef],""),index_of([""],undef),index_of([""],""),index_of([undef,""],""),index_of(["",undef],undef),index_of([],undef),index_of([0],"0"),index_of([false],0)];
 items=[undef,"",undef,"",2,"2"];unique=uniq(items);receiver_unique=items.uniq();dropped=items.copy();uniq(dropped);
 false_text=[undef].contains("").coalesce_nonempty("late").cat("!");numeric=[undef].contains("").add(2);
 missing_index=[""].index_of(undef).coalesce_nonempty(7).add(1);found_index=["",undef].index_of(undef).add(1);
 unique_count=items.uniq().count().add(1);unique_last=items.uniq().last().mul(2);
 order="";needle_calls=0;effected=[undef,""].contains({needle_calls=num_add(needle_calls,1);order=cat(order,"N");undef}).cat({order=cat(order,"C");"!"});
 return({"membership":membership,"indexes":indexes,"unique":unique,"receiver_unique":receiver_unique,"dropped":dropped,"items":items,"false_text":false_text,"numeric":numeric,"missing_index":missing_index,"found_index":found_index,"unique_count":unique_count,"unique_last":unique_last,"effected":effected,"order":order,"needle_calls":needle_calls});
}
