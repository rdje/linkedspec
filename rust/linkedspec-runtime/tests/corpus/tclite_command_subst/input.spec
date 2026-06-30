tcl_script::
-? push
-> semi_colon      .push
-> newline         .push
-> double_quote    .push
-> space           .push
-> pound_sign      .push
-> command_subst   .push
-> oc_curly_brace  .push
LX                 .return(a("?tcl_script:", array_copy(a(tcl_script))))


semi_colon       : /;/        I.return ([])
space            : /[ \t]+/   I.return ([])
newline          : /\r\n?/    I.return ([])

double_quote     : /(?<!\\)"/
-? push
-> command_subst  .push
-> double_quote   .return(a("?double_quote:", array_copy(a(double_quote))))

pound_sign       : /#/        I.return ([])
command_subst    : /(?<!\\)\[/  /(?<!\\)\]/
-? push
-> command_subst     .push
-> semi_colon        .push
-> newline           .push
-> double_quote      .push
-> space             .push
-> pound_sign        .push
-> oc_curly_brace    .push
-> command_subst[1]  .return(a("?command_subst:", array_copy(a(command_subst))))

oc_curly_brace    : /(?<!\\){/  /(?<!\\)}/
variable_subst    : /\$[\w:]+/
