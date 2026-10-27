Top:: I {
 source="a,b";
 literal="a,b".split_tagged_records(",","row").last().last().uppercase();
 named=source.split_tagged_records(",","row").first().first().cat("!");
 derived=" a,b ".trim().split_tagged_records(",","row").count().add(1);
 carried="a,b".split_tagged_records(",","row",["x","y"]).last().last().last().uppercase();
 number="a,b".split_tagged_records(",","row",7).last().last().add(1);
 boolean="a,b".split_tagged_records(",","row",false).last().last().coalesce("wrong");
 null_value="a,b".split_tagged_records(",","row",null).last().last().coalesce("fallback").uppercase();
 hash_value="a,b".split_tagged_records(",","row",{"key":"v"}).last().last().sorted_values().first().uppercase();
 record_count="a,b".split_tagged_records(",","row",7).last().count().add(1);
 regex="aXbx".split_tagged_records(/x/i,"row").last().last().cat("end");
 order="";source="a,b";delimiter=",";tag="row";counter=0;
 effect={order=cat(order,"S");source}.split_tagged_records({order=cat(order,"D");source="changed";delimiter},{order=cat(order,"T");delimiter="wrong";tag},{order=cat(order,"F");tag="changed";counter=num_add(counter,1);counter}).take({order=cat(order,"C");1}).first().first().cat({order=cat(order,"E");"!"});
 effects=[effect,order,source,tag,counter];
 index="a,b".split_tagged_records(",","row",0).last().last();slots=["one","two"];slot=slots[index];
 values=[literal,named,derived,carried,number,boolean,null_value,hash_value,record_count,regex,effects,slot];
 return(values);
}
