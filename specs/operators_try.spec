
top_expression::   I {print("top_expression\n\n")}
-> group
-> auto_inc_op
-> auto_dec_op
-> div_op
-> mul_op
-> add_op
-> sub_op
-> string_concat
-> integer
-> function_call
-> variable


group: /\(/ /\)/       I {print("-> {start-group\n")}
-> group
-> auto_inc_op
-> auto_dec_op
-> div_op
-> mul_op
-> add_op
-> sub_op
-> string_concat
-> integer
-> function_call
-> variable
-> group[1]    {print("-> end-group}\n"); return 1}

function_call: /\w+\s*\(/ /\)/  I {print("-> (", scalar(IMATCH), ") {start-function_call\n")}
-> variable
-> integer
-> string
-> function_call[1]    {print("-> end-function_call}\n"); return 1}

string: /"/  /(?<!\\)"/      I {print("-> {start-string\n")}
-> string[1]                 {print("-> end-string}\n"); return 1}

auto_inc_op: /\+\+/          I {print("-> (", scalar(IMATCH), ") auto_inc_op\n")}
auto_dec_op: /\-\-/          I {print("-> (", scalar(IMATCH), ") auto_dec_op\n")}
div_op: /\//                 I {print("-> (", scalar(IMATCH), ") div_op\n")}
mul_op: /\*/                 I {print("-> (", scalar(IMATCH), ") mul_op\n")}
add_op: /\+/                 I {print("-> (", scalar(IMATCH), ") add_op\n")}
sub_op: /\-/                 I {print("-> (", scalar(IMATCH), ") sub_op\n")}
string_concat: /\./          I {print("-> (", scalar(IMATCH), ") string_concat\n")}
variable: /[a-zA-Z_]\w*/     I {print("-> (", scalar(IMATCH), ") variable\n")}
integer: /\d+/               I {print("-> (", scalar(IMATCH), ") integer\n")}

