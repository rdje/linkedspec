Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>name)/
 /=/
 /(?<value>Alpha)/
 -> Value[2] {
 order="";
 numbers=[
  entry_len().coalesce({order=cat(order,"F");999}).add(0),
  entry_start_pos().coalesce({order=cat(order,"F");999}).add(0),
  entry_end_pos().coalesce({order=cat(order,"F");999}).add(0),
  entry_line().coalesce({order=cat(order,"F");999}).add(0),
  entry_start_line().coalesce({order=cat(order,"F");999}).add(0),
  entry_end_line().coalesce({order=cat(order,"F");999}).add(0),
  entry_col().coalesce({order=cat(order,"F");999}).add(0),
  entry_start_col().coalesce({order=cat(order,"F");999}).add(0),
  entry_end_col().coalesce({order=cat(order,"F");999}).add(0),
  match_len().coalesce({order=cat(order,"F");999}).add(0),
  match_start_pos().coalesce({order=cat(order,"F");999}).add(0),
  match_end_pos().coalesce({order=cat(order,"F");999}).add(0),
  match_line().coalesce({order=cat(order,"F");999}).add(0),
  match_start_line().coalesce({order=cat(order,"F");999}).add(0),
  match_end_line().coalesce({order=cat(order,"F");999}).add(0),
  match_col().coalesce({order=cat(order,"F");999}).add(0),
  match_start_col().coalesce({order=cat(order,"F");999}).add(0),
  match_end_col().coalesce({order=cat(order,"F");999}).add(0)
 ];
 text=[entry_text().coalesce("x").split(/a/)[-1].uppercase(),match_text().coalesce("x").split(/l/)[-1].uppercase(),entry_group(9).coalesce("missing").uppercase(),match_named("absent").coalesce("fallback").split(/a/)[-1].uppercase()];
 a=entry_start_pos().coalesce(0).add(0).take({order=cat(order,"A");1});
 b=match_end_pos().coalesce(0).add(0).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
 n=entry_len().coalesce(0).add({order=cat(order,"C");1});
 return([numbers,text,n,match_len().coalesce(0).cat("!"),match_end_col().coalesce(0).sub(1),[a,b],order]);
}
