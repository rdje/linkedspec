Top: /x/
 I { tree={"rows":[[1],[2,3]]}; edit={|| tree["rows"][-1][-2]=99; return(tree) }; return(edit()) }
