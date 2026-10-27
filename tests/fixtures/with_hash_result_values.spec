Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>name)/
 /=/
 /(?<value>Alpha)/
 -> Value[2] {
  value="outer";order="";text="source";
  literal="literal".with(){order=cat(order,"A");return({"n":[false]})}.sorted_values().first().first();
  bound=text.with({order=cat(order,"B");return({"b":"b","a":"a"})}).sorted_values().join_values("-");
  capture=entry_text().with(){order=cat(order,"C");return({"z":["x","y"]})}.sorted_values().first()[-1].uppercase();
  helper=with("x"){order=cat(order,"D");return({"z":1,"a":2})}.sorted_keys().join_values(",");
  prefixed=" a ".trim().with(){order=cat(order,"E");return({"k":1})}.count_keys().add(1);
  return([literal,bound,capture,helper,prefixed,order,value]);
 }
