Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /name/
 /=/
 /Alpha/
 -> Value[2] {
  order="";
  source=input_slice({order=cat(order,"S");5},{order=cat(order,"W");5}).cat({order=cat(order,"C");"!"});
  defaults=[input_text().coalesce({order=cat(order,"F");"late"}).split("=")[-1].uppercase(),cursor_rest().coalesce({order=cat(order,"F");"late"}).cat("!"),cursor_rest_len().coalesce({order=cat(order,"F");7}).add(1)];
  rejected=[input_text().take({order=cat(order,"A");1}),input_len().set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1})];
  return([
   [input_text().split("=")[-1].uppercase(),input_slice(5,5).uppercase()],
   [input_len().add(1),input_end_pos().add(1),input_end_line().add(1),input_end_col().add(1)],
   [cursor_pos().add(1),cursor_line().add(1),cursor_col().add(1),cursor_rest_len().add(1)],
   [source,defaults,rejected,order]
  ]);
 }
