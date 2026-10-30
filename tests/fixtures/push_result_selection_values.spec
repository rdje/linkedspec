Value::
 I {
  order="";
  words=[];
  bools=[];
  nums=[];
  nulls=[];
  hashes=[];
  nested_items=[];
  snap=[];
  miss=[];
  chain_items=[];
  text=push(words," a ")[-1].trim().uppercase();
  boolean=push(bools,false)[-1].not();
  number=push(nums,{0})[-1].add(1);
  recovered=push(nulls,undef)[-1].coalesce(["a","tail"])[-1].uppercase();
  hash=push(hashes,{"k":["head","tail"]})[-1]["k"][-1].uppercase();
  nested=push(nested_items,[["head","tail"]])[-1][-1][-1].uppercase();
  snapshot=push(snap,{order=cat(order,"V");"old"})[{snap=["new"];order=cat(order,"I");-1}].uppercase();
  missing=push(miss,"tail")[{order=cat(order,"J");9}][{order=cat(order,"K");0}].coalesce("M");
  chained=push(chain_items,"tail").last().uppercase();
  return([text,boolean,number,recovered,hash,nested,snapshot,snap,missing,order,chained,chain_items]);
 }
