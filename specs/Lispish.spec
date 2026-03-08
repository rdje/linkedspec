Lispish::
 -> parenthesis     {return call(parenthesis)}
 -> parenthesis[1]  {say("(Lispish) -E- Syntax Error"); exit 1}
 -> comments

parenthesis: /\(/ /\)/
I {declare(array, word, tail); declare(scalar, retv, head, has_head)}

 -> parenthesis       {
   if(is_nonempty(array(word)));
    if(is_empty(scalar(has_head)));
     assign(scalar(head), join_values("", array(word)));
     assign(scalar(has_head), 1);
    else();
     push_value(array(tail), join_values("", array(word)));
    endif();
    assign(array(word), array());
   endif();
   assign(scalar(retv), call(parenthesis));
   if(is_empty(scalar(has_head)));
    assign(scalar(head), scalar(retv));
    assign(scalar(has_head), 1);
   else();
    push_value(array(tail), scalar(retv));
   endif()
}

 -> spaces            {
   call(spaces);
   if(is_nonempty(array(word)));
    if(is_empty(scalar(has_head)));
     assign(scalar(head), join_values("", array(word)));
     assign(scalar(has_head), 1);
    else();
     push_value(array(tail), join_values("", array(word)));
    endif();
    assign(array(word), array());
   endif()
}
 -> dquotes           {assign(scalar(retv), call(dquotes)); push_value(array(word), scalaref(retv, {content}))}
 -> sbrackets         {assign(scalar(retv), call(sbrackets)); push_value(array(word), scalaref(retv, {content}))}
 -> curlyb            {assign(scalar(retv), call(curlyb)); push_value(array(word), scalaref(retv, {content}))}
 -> others            {assign(scalar(retv), call(others)); push_value(array(word), scalaref(retv, {content}))}
 -> comments          {call(comments)}

 -> parenthesis[1]    {
   if(is_nonempty(array(word)));
    if(is_empty(scalar(has_head)));
     assign(scalar(head), join_values("", array(word)));
     assign(scalar(has_head), 1);
    else();
     push_value(array(tail), join_values("", array(word)));
    endif();
   endif();

   if(scalar(has_head));
    if(is_nonempty(array(tail)));
     return(array(scalar(head), array_values(array(tail))));
    else();
     return(array(scalar(head), undef));
    endif();
   else();
    return(array(undef));
   endif()
}

sbrackets: /(\[(?:[^\[\]]++|(?R))+\])/     I.return(hash("type", "SBRACKETS", "content", scalar(IMATCH)))

dquotes: /"(.*?)(?<!\\)"/     I.return(hash("type", "DQUOTES", "content", scalar(IMATCH_LIST, 0)))

squotes: /'(.*?)(?<!\\)'/     I.return(hash("type", "SQUOTES", "content", scalar(IMATCH_LIST, 0)))

curlyb: /(?<!\\)\{/ /(?<!\\)\}/ I {declare(scalar, content)}
 -> curlyb
 -> dquotes
 -> squotes
 -> curlyb[1]                 {
 assign(scalar(content), CAPTURE);
 return(hash("type", "CBRACE", "content", scalar(content)))
}

spaces: /\s+/               I.return(hash("type", "SPACE", "content", scalar(IMATCH)))

others: /[^\s\"\{\}\(\)\[\];]+/  I.return(hash("type", "OTHERS", "content", scalar(IMATCH)))
			      
comments: /;.*\n/           I.return(hash("type", "COMMENTS", "content", scalar(IMATCH)))
