Top::
 -> Done {
   tree = {"present":["kept"], "null":undef};
   missing = tree["missing"][0];
   null_child = tree["null"][0];
   wrong_kind = tree["present"]["field"];
   absent = document[0];
   document["created"] = "write";
   null_root = undef;
   null_read = null_root[0];
   return({"tree":tree, "missing":missing, "null_child":null_child,
           "wrong_kind":wrong_kind, "absent":absent, "document":document,
           "null_root":null_root, "null_read":null_read,
           "present":tree["present"][0]})
 }
Done:
 /x/
