fn duplicate(value) { scratch="inner";counter=1;return(value.copy().copy()) }
Top:: I {
 functions=[copy(true),copy(false),copy(0),copy(7),copy(-2.5),copy("0"),copy(""),copy("🙂"),copy(undef),copy(missing)];
 literals=[true.copy(),false.copy(),0.copy(),"0".copy(),"".copy(),"🙂".copy(),undef.copy(),missing.copy()];
 f=false;n=0;s="0";u=undef;
 named=[f.copy().copy(),n.copy().copy(),s.copy().copy(),u.copy().copy()];
 results=[and(false).copy(),num_add(1,2).copy().add(1)," a ".trim().copy().uppercase(),false.copy().coalesce("late").cat("!"),[].first().copy().coalesce([7]).first(),"x".with() {return(false)}.not().copy()];
 order="";
 wrong_array={order=cat(order,"S");false}.copy().trim().take({order=cat(order,"A");1});
 wrong_hash={order=cat(order,"R");0}.copy().set_key({order=cat(order,"K");"a"},{order=cat(order,"V");1});
 guards=[wrong_array,wrong_hash,order];
 source=0;counter=0;
 snapshot={counter=num_add(counter,1);source}.copy().cat({source=7;counter=num_add(counter,1);"!"});
 saved=[snapshot,source,counter];
 scratch="outer";counter=9;scoped=[duplicate(false),scratch,counter];
 a=[[2,1]];h={"a":[1]};containers=[a,copy(a),a.copy().copy(),h,copy(h),h.copy().copy(),copy([]),copy({})];
 items=["zero"];items[copy(0)]="changed";
 return([functions,literals,named,results,guards,saved,scoped,containers,items]);
}
