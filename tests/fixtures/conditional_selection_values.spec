Top:: I {
 basics=[if(true,["a","b"],["bad"])[-1].uppercase(),switch("k",case("k",{"value":["a","b"]}),default({}))["value"][-1].uppercase(),if(false,"bad"," a ").split(/ /)[1].uppercase()];
 kinds=[if(true,[false],[])[0],if(true,[0],[])[0],if(true,["0"],[])[0],if(true,[undef],[])[0],if(true,[[1]],[])[0],if(true,[{"a":1}],[])[0]];
 order="";
 selected=if({order=cat(order,"C");true},{order=cat(order,"T");[" a "," b "]},{order=cat(order,"F");["bad"]})[{order=cat(order,"I");-1}].trim().cat({order=cat(order,"M");"!"});
 trace=[selected,order];
 source=["old","tail"];
 snap=if(true,source,["bad"])[{source=["new"];-1}].uppercase();
 snapshot=[snap,source];
 order="";
 a=if(true,[false],[])[0].take({order=cat(order,"A");1});
 b=switch("k",case("k",[["a"]]))[0].set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});
 guards=[a,b,order];order="";
 missing=if(true,{"present":[]},{})["missing"][{order=cat(order,"I");0}][{order=cat(order,"J");0}];
 absent=[missing,order,if(false,[1])[0],switch("other",case("k",[1]))[0]];
 bridge=if(false,["bad"])[0].coalesce({"items":["tail"]})["items"][-1].uppercase();
 return([basics,kinds,trace,snapshot,guards,absent,bridge]);
}
