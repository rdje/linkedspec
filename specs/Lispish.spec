Lispish::
 -> parenthesis     {return(call(parenthesis))}
 -> parenthesis[1]  {say("(Lispish) -E- Syntax Error"); exit_now(1)}
 -> comments

parenthesis: /\(/ /\)/
I {word = []; tail = []; retv = undef; head = undef; has_head = undef}

 -> parenthesis       {
   if(is_nonempty(word));
    if(is_empty(has_head));
     head = join_values("", word);
     has_head = 1;
    else();
     push(tail, join_values("", word));
    endif();
    set(word, array());
   endif();
   retv = call(parenthesis);
   if(is_empty(has_head));
    head = retv;
    has_head = 1;
   else();
    push(tail, retv);
   endif()
}

 -> spaces            {
   call(spaces);
   if(is_nonempty(word));
    if(is_empty(has_head));
     head = join_values("", word);
     has_head = 1;
    else();
     push(tail, join_values("", word));
    endif();
    set(word, array());
   endif()
}
 -> dquotes           {retv = call(dquotes); push(word, retv["content"])}
 -> sbrackets         {retv = call(sbrackets); push(word, retv["content"])}
 -> curlyb            {retv = call(curlyb); push(word, retv["content"])}
 -> others            {retv = call(others); push(word, retv["content"])}
 -> comments          {call(comments)}

 -> parenthesis[1]    {
   if(is_nonempty(word));
    if(is_empty(has_head));
     head = join_values("", word);
     has_head = 1;
    else();
     push(tail, join_values("", word));
    endif();
   endif();

   if(has_head);
    if(is_nonempty(tail));
     return(array(head, copy(tail)));
    else();
     return(array(head, undef));
    endif();
   else();
    return([undef]);
   endif()
}

sbrackets: /(\[(?:[^\[\]]++|(?R))+\])/     I.return(hash("type", "SBRACKETS", "content", entry_text()))

dquotes: /"(.*?)(?<!\\)"/     I.return(hash("type", "DQUOTES", "content", entry_group(0)))

squotes: /'(.*?)(?<!\\)'/     I.return(hash("type", "SQUOTES", "content", entry_group(0)))

curlyb: /(?<!\\)\{/ /(?<!\\)\}/ I {content = undef}
 -> curlyb
 -> dquotes
 -> squotes
 -> curlyb[1]                 {
 content = capture_slice();
 return(hash("type", "CBRACE", "content", content))
}

spaces: /\s+/               I.return(hash("type", "SPACE", "content", entry_text()))

others: /[^\s\"\{\}\(\)\[\];]+/  I.return(hash("type", "OTHERS", "content", entry_text()))
			      
comments: /;.*\n/           I.return(hash("type", "COMMENTS", "content", entry_text()))
