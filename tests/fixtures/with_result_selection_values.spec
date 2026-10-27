Top:: I {
 value="outer";order="";
 a=with(" a,b "){order=cat(order,"A");return(split(value,","))}[-1].trim().uppercase();
 b=with("x",{order=cat(order,"B");return({"n":[false]})})["n"][0].copy();
 c=with(){order=cat(order,"C");return([if(is_undefined(value),"empty","bound")])}[0].copy();
 d="x".with(){order=cat(order,"D");return({"n":[2,["q"]]})}["n"][1][0].uppercase();
 e=with("x"){order=cat(order,"E");return({"k":[{"ok":"v"}]})}["k"][-1]["ok"].uppercase();
 f=with("x"){order=cat(order,"F");return([2])}[0].add(1);
 g=with("x"){order=cat(order,"G");return({"n":[["a","b"]]})}["n"][0].last().uppercase();
 h=with("x"){order=cat(order,"H");return(3)}[0].coalesce("missing");
 invalid=with("x"){order=cat(order,"I");return(["text"])}[0].take({order=cat(order,"bad");1});
 missing=with("x"){order=cat(order,"J");return({})}["absent"][{order=cat(order,"K");0}].coalesce(["fallback"])[0].uppercase();
 saved=["old"];
 snapshot=with("x"){order=cat(order,"L");return(saved)}[{saved=["new"];order=cat(order,"M");0}].uppercase();
 return([a,b,c,d,e,f,g,h,invalid,missing,snapshot,saved,value,order]);
}
