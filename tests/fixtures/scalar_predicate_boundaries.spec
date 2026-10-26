Top::
 I {
  absent=missing_value; order="";
  replaced=replace_substr({order=cat(order,"S"); "ab"},
   {order=cat(order,"N"); ""},{order=cat(order,"R"); "X"});
  return([
   [replace_substr("ab","","X"),starts_with(undef,""),ends_with(undef,""),contains_substr(undef,""),matches(undef,/^$/)],
   [absent.starts_with(""),absent.ends_with(""),absent.contains_substr(""),absent.matches(/^$/)],
   [starts_with("ab",undef),ends_with("ab",undef),contains_substr("ab",undef),
    replace_substr("ab",undef,"X"),replace_substr("ab","a",undef),rm_prefix("ab",undef),rm_suffix("ab",undef)],
   [starts_with("",""),ends_with("",""),contains_substr("",""),matches("",/^$/),matches("a",/^$/)],
   ["ab".replace_substr("","X"),rm_prefix("ab",""),rm_suffix("ab",""),replace_substr(0,"","X"),rm_prefix(0,""),rm_suffix(0,"")],
   [starts_with(0,"0"),ends_with(false,"0"),contains_substr("café","fé"),replace_substr("a.a",".","!"),rm_prefix("abc","a"),rm_suffix("abc","c")],
   [replaced,order],
   [rm_prefix(0,"x"),rm_suffix(0,"x")]
  ]);
 }
