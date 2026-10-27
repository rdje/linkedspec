Top::
 -> Value .push
 LX {return(copy(Top))}

Value:
 /(?<head>name)/
 /\s*=\s*/
 /(?<value>[A-Za-z_]+)/
 -> Value[1] {separator=match_text()}
 -> Value[2] {
   basics=[entry_groups()[-1].uppercase(),entry_map()["head"].uppercase(),match_groups()[-1].uppercase(),match_map()["value"].uppercase()];
   aliases=[entry_named_map()["head"],match_named_map()["value"]];
   order="";
   missing=entry_map()["absent"][{order=cat(order,"I");0}][{order=cat(order,"J");0}];
   absent=[entry_groups()[99],entry_map()["absent"],match_groups()[99],match_map()["absent"],missing,order];
   order="";
   a=entry_groups()[0].take({order=cat(order,"A");1});
   b=entry_map()["head"].set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});
   bridges=[match_map()["absent"].coalesce(["fallback"])[0].uppercase(),entry_map()["head"].split(/a/)[-1].uppercase(),entry_map().pick_keys("head")["head"].uppercase()];
   return([basics,aliases,absent,[a,b,order],bridges,[entry_groups(),entry_map(),match_groups(),match_map()]]);
 }
