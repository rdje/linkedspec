fn choose() { return(false) }
Top:: I {
 basics=[true.and(false),false.or(true),false.not(),true.and(true,false),false.or(false,true)];
 truth=["0".not(),0.not(),[].not(),[null].not(),{}.not(),{"key":null}.not(),undef.not()];
 selected=[false].last().or(true).not();meta={"ready":false};named=meta["ready"].or(true);fromfn=choose().not();
 text=false.or(true).not().coalesce("late").cat("!");
 bridge=[].not().cat(",x").split(",").last().uppercase();
 numeric=false.not().add(1).coalesce(["a","b"]).last().uppercase();
 order="";source=false;counter=0;
 result={order=cat(order,"S");counter=num_add(counter,1);source}.and({order=cat(order,"R");source=true;true},{order=cat(order,"T");false}).cat({order=cat(order,"C");"!"});
 eager_and=[result,order,counter,source];order="";
 result={order=cat(order,"S");true}.or({order=cat(order,"R");false},{order=cat(order,"T");false}).cat({order=cat(order,"C");"!"});eager_or=[result,order];
 source=0;snapshot=source.or({source="0";false});snapshots=[snapshot,source];
 items=[null];held=items.and({items=[];true});containers=[held,items,meta.not(),meta];
 values=[basics,truth,selected,named,fromfn,text,bridge,numeric,eager_and,eager_or,snapshots,containers];return(values);
}
