Lispish::
 -> parenthesis     {return(call(parenthesis))}
 -> parenthesis[1]  {say("(Lispish) -E- Syntax Error"); exit_now(1)}
 -> comments

parenthesis: /\(/ /\)/
I {declare(array, word, tail); declare(scalar, retv, head, has_head)}

 -> parenthesis       {
   if(is_nonempty(array(word)));
    if(is_empty(:has_head));
     head = join_values("", array(word));
     has_head = 1;
    else();
     push_value(array(tail), join_values("", array(word)));
    endif();
    word = [];
   endif();
   retv = call(parenthesis);
   if(is_empty(:has_head));
    head = :retv;
    has_head = 1;
   else();
    push_value(array(tail), :retv);
   endif()
}

 -> spaces            {
   call(spaces);
   if(is_nonempty(array(word)));
    if(is_empty(:has_head));
     head = join_values("", array(word));
     has_head = 1;
    else();
     push_value(array(tail), join_values("", array(word)));
    endif();
    word = [];
   endif()
}
 -> dquotes           {retv = call(dquotes); push_value(array(word), retv["content"])}
 -> sbrackets         {retv = call(sbrackets); push_value(array(word), retv["content"])}
 -> curlyb            {retv = call(curlyb); push_value(array(word), retv["content"])}
 -> others            {retv = call(others); push_value(array(word), retv["content"])}
 -> comments          {call(comments)}

 -> parenthesis[1]    {
   if(is_nonempty(array(word)));
    if(is_empty(:has_head));
     head = join_values("", array(word));
     has_head = 1;
    else();
     push_value(array(tail), join_values("", array(word)));
    endif();
   endif();

   if(:has_head);
    if(is_nonempty(array(tail)));
     return(array(:head, array_copy(array(tail))));
    else();
     return(array(:head, undef));
    endif();
   else();
    return(array(undef));
   endif()
}

sbrackets: /(\[(?:[^\[\]]++|(?R))+\])/     I.return(hash("type", "SBRACKETS", "content", entry_text()))

dquotes: /"(.*?)(?<!\\)"/     I.return(hash("type", "DQUOTES", "content", entry_group(0)))

squotes: /'(.*?)(?<!\\)'/     I.return(hash("type", "SQUOTES", "content", entry_group(0)))

curlyb: /(?<!\\)\{/ /(?<!\\)\}/ I {declare(scalar, content)}
 -> curlyb
 -> dquotes
 -> squotes
 -> curlyb[1]                 {
 content = CAPTURE;
 return(hash("type", "CBRACE", "content", :content))
}

spaces: /\s+/               I.return(hash("type", "SPACE", "content", entry_text()))

others: /[^\s\"\{\}\(\)\[\];]+/  I.return(hash("type", "OTHERS", "content", entry_text()))
			      
comments: /;.*\n/           I.return(hash("type", "COMMENTS", "content", entry_text()))
