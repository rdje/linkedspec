Top::
 -> Done {
   items = ["first", "second"];
   i = 1;
   first = items[0];
   selected = items[i];
   nested = [["saved"]];
   snapshot = nested[0];
   nested[0][0] = "changed";
   items = ["rebound"];
   return({"first":first, "selected":selected, "snapshot":snapshot,
           "current":items[0], "missing":items[9], items[0]:7})
 }
Done:
 /x/
