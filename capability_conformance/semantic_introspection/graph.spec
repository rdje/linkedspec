Top::AND
 /a/ -> Child[0] { return("first") }
 /a/ -> Child[1] { return("second") }
 E { return(["done"]) }

Child:OR
 /a/
 /a/
