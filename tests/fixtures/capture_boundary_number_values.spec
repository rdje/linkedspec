Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>..)/
 /:/
 /cat/
 -> Value[2] {
  order="";
  a=capture_slice_len().coalesce({order=cat(order,"bad");9}).add({order=cat(order,"A");1});
  b=capture_slice_pos().sub(2).coalesce({order=cat(order,"bad");9});
  c=capture_slice_line().add(1);
  d=capture_slice_col().coalesce(0).cat("!");
  e=capture_slice_until_cursor_len().add(1);
  f=capture_rest_len().coalesce(0).cat(":tail").split(":")[-1].uppercase();
  aliases=[capture_slice_length().add(1),capture_len_from_rule_start().cat("!"),capture_rest_length().sub(1)];
  invalid=capture_rest_len().coalesce(0).take({order=cat(order,"bad");1});
  snapshot=capture_rest_len().cat({order=cat(order,"S");"!"});
  start_capture_slice();
  after=capture_slice_pos();
  return([a,b,c,d,e,f,aliases,invalid,snapshot,after,order]);
 }
