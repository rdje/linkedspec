fn summary(items) {
 return([sum(items), avg(items), median(items), range(items), min(items), max(items)])
}
Top::
 -> Done {
  document = {"items":[3,1,2]}
  selected = document["items"]
  return([summary(selected), summary([]), sum(document["items"]), document["items"].sum()])
 }
Done:
 /x/
