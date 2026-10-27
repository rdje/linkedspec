Top:: I {
 numbers=[[1,[2,3]].reduce_leaves(0) {return(acc.add(value))}.add(1),{"b":2,"a":1}.reduce_leaves(0) {return(acc.add(value))}.add(1)];
 texts=["a",["b"]].reduce_leaves("") {return(cat(acc,value))}.uppercase().cat("!");
 arrays=[1,[2,3]].reduce_leaves([]) {return(concat_arrays(acc,[value]))}.last().add(1);
 hashes=[1].reduce_leaves({}) {return({"key":"B"})}.sorted_values().first().lowercase();
 traversals=[[1,[2]].reduce_leaves([]) {return(concat_arrays(acc,[value]))}.map_leaves() {return(value.add(1))}.last(),{"b":"b","a":"a"}.reduce_leaves([]) {return(concat_arrays(acc,[value]))}.map_leaves() {return(uppercase(value))}.last(),[1].reduce_leaves({}) {return({"key":"B"})}.map_leaves() {return(lowercase(value))}.sorted_values().first(),[1,2].reversed().reduce_leaves([]) {return(concat_arrays(acc,[value]))}.reduce_leaves(0) {return(acc.add(value))}.add(1),undef.coalesce([1,2]).reduce_leaves(0) {return(acc.add(value))}.add(1)];
 booleans=[ [].reduce_leaves(false) {return(true)}.coalesce_nonempty("late").cat("!"),[1].reduce_leaves(false) {return(true)}.cat("!"),[].reduce_leaves(false) {return(true)}.add(1) ];
 recovery=[1].reduce_leaves(0) {return(undef)}.coalesce(7).add(1);
 empty=[ [].reduce_leaves([]) {return(value)}.count().add(1),{}.reduce_leaves({}) {return(value)}.has_key("missing").cat("!") ];
 items=[1,2];named=items.reduce_leaves(0) {return(acc.add(value))}.cat("!");
 pipeline=[1,2].reversed().reduce_leaves(0) {return(acc.add(value))}.add(1);
 value="outer";acc="outer-acc";path=["outer"];depth=99;index=88;key="outer";
 items=[1,2];order="";calls=0;
 effect={order=cat(order,"S");calls=num_add(calls,1);items}.reduce_leaves({order=cat(order,"I");items=[9];0}) {order=cat(order,"L");return(acc.add(value))}.cat({order=cat(order,"C");items=undef;value});
 effects=[effect,order,calls,items];scope=[value,acc,path,depth,index,key];
 order="";invalid={order=cat(order,"S");"x"}.reduce_leaves({order=cat(order,"I");0}) {order=cat(order,"L");return(value)}.coalesce({order=cat(order,"C");"fallback"}).uppercase();invalid_effects=[invalid,order];
 order="";rejected={order=cat(order,"S");[1]}.reduce_leaves({order=cat(order,"I");0}) {order=cat(order,"L");return(acc.add(value))}.take({order=cat(order,"A");1});rejected_effects=[rejected,order];
 order="";prefix={order=cat(order,"S");[1]}.reduce_leaves({order=cat(order,"I");0}) {order=cat(order,"L");return(acc.add(value))}.cat({order=cat(order,"C");"!"}).take({order=cat(order,"A");1});prefix_effects=[prefix,order];
 initial=["a"];copied=[1].reduce_leaves(initial) {return(acc)}.copy();copied+="b";copies=[initial,copied];
 slots=["zero","one"];slots[[].reduce_leaves(0) {return(value)}]="updated";
 return({"traversals":traversals,"numbers":numbers,"texts":texts,"arrays":arrays,"hashes":hashes,"booleans":booleans,"recovery":recovery,"empty":empty,"named":named,"pipeline":pipeline,"effects":effects,"scope":scope,"invalid_effects":invalid_effects,"rejected_effects":rejected_effects,"prefix_effects":prefix_effects,"copies":copies,"slots":slots});
}
