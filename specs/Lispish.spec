Lispish::
 -> parenthesis     {return(call(parenthesis))}
 -> parenthesis[1]  {say("(Lispish) -E- Syntax Error"); exit_now(1)}
 -> comments

parenthesis: /\(/ /\)/
I {word = []; tail = []; retv = undef; head = undef; has_head = undef}

 -> parenthesis       {
   if(is_nonempty(array(word)));
    if(is_empty(scalar(has_head)));
     set(scalar(head), join_values("", array(word)));
     set(scalar(has_head), 1);
    else();
     push(array(tail), join_values("", array(word)));
    endif();
    set(array(word), array());
   endif();
   set(scalar(retv), call(parenthesis));
   if(is_empty(scalar(has_head)));
    set(scalar(head), scalar(retv));
    set(scalar(has_head), 1);
   else();
    push(array(tail), scalar(retv));
   endif()
}

 -> spaces            {
   call(spaces);
   if(is_nonempty(array(word)));
    if(is_empty(scalar(has_head)));
     set(scalar(head), join_values("", array(word)));
     set(scalar(has_head), 1);
    else();
     push(array(tail), join_values("", array(word)));
    endif();
    set(array(word), array());
   endif()
}
 -> dquotes           {set(scalar(retv), call(dquotes)); push(array(word), retv["content"])}
 -> sbrackets         {set(scalar(retv), call(sbrackets)); push(array(word), retv["content"])}
 -> curlyb            {set(scalar(retv), call(curlyb)); push(array(word), retv["content"])}
 -> others            {set(scalar(retv), call(others)); push(array(word), retv["content"])}
 -> comments          {call(comments)}

 -> parenthesis[1]    {
   if(is_nonempty(array(word)));
    if(is_empty(scalar(has_head)));
     set(scalar(head), join_values("", array(word)));
     set(scalar(has_head), 1);
    else();
     push(array(tail), join_values("", array(word)));
    endif();
   endif();

   if(scalar(has_head));
    if(is_nonempty(array(tail)));
     return(array(scalar(head), copy(array(tail))));
    else();
     return(array(scalar(head), undef));
    endif();
   else();
    return(array(undef));
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
 set(scalar(content), CAPTURE);
 return(hash("type", "CBRACE", "content", scalar(content)))
}

spaces: /\s+/               I.return(hash("type", "SPACE", "content", entry_text()))

others: /[^\s\"\{\}\(\)\[\];]+/  I.return(hash("type", "OTHERS", "content", entry_text()))
			      
comments: /;.*\n/           I.return(hash("type", "COMMENTS", "content", entry_text()))
