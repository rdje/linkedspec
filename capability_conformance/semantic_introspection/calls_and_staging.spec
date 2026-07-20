fn normalize(value) { return(trim(value)) }

Top::
 /x/ -> Done {
   result = normalize(match_text())
   return(result)
 }

Done:
 /x/
