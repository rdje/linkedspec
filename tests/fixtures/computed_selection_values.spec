fn entries() { return([" a "," b "," c "]); }
Top:: I {
  basics=[
    split(" a , b , c ",",")[-2].trim().uppercase(),
    " a , b , c ".split(",")[-2].trim().uppercase(),
    [" a "," b "][-1].trim().uppercase(),
    {"items":["a","b"]}["items"][-1].uppercase(),
    {["a","b"]}[-1].uppercase(),
    entries()[-2].trim().uppercase(),
    "a,b".split(",")[-1].cat(",c").split(",")[0].uppercase(),
    {"items":["a","b"]}.pick_keys("items")["items"][-1].uppercase()
  ];
  kinds=[
    [false][0], [0][0], ["0"][0], [undef][0], [["a"]][0], [{"key":"b"}][0]
  ];
  source=["old","tail"];order="";counter=0;
  selected={order=cat(order,"S");counter=num_add(counter,1);source}[
    {order=cat(order,"I");source=["new"];-1}
  ].uppercase().cat({order=cat(order,"C");"!"});
  snapshot=[selected,order,counter,source];
  order="";
  missing={"items":[]}["items"][{order=cat(order,"I");3}][{order=cat(order,"J");0}];
  absent=[missing,order];
  order="";
  rejected={order=cat(order,"S");[false]}[0].take({order=cat(order,"A");1});
  bridges=[
    [[3,1]][0].sorted().last().add(1),
    [{"b":2,"a":1}][0].sorted_keys().last().uppercase(),
    [undef][0].coalesce([7]).first().add(1),
    [false][0].not().cat("!")
  ];
  return([basics,kinds,snapshot,absent,[rejected,order],bridges]);
}
