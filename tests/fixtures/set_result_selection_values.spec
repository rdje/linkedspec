Value::
 I {
   order="";
   text=set(text_value," a ").trim().uppercase();
   boolean=set(bool_value,false).not();
   number=set(num_value,0).add(1);
   recovered=set(null_value,undef).coalesce(["a","tail"])[-1].uppercase();
   hash=set(meta,{"k":["head","tail"]})["k"][-1].uppercase();
   nested=set(items,[["head","tail"]])[-1][-1].uppercase();
   saved=set(memo,{order=cat(order,"S");["old","tail"]})[{memo=["new"];order=cat(order,"I");-1}].cat({order=cat(order,"C");"!"}).uppercase();
   missing=set(others,["tail"])[{order=cat(order,"J");9}][{order=cat(order,"K");0}].coalesce("M");
   source=["head","tail"];
   bare=set(bare_copy,source)[-1].uppercase();
   return([text,boolean,number,recovered,hash,nested,saved,memo,missing,order,bare,bare_copy]);
 }
