Lispish::
 -> parenthesis     {return call(parenthesis)}
 -> parenthesis[1]  {say("(Lispish) -E- Syntax Error"); exit 1}
 -> comments

parenthesis: /\(/ /\)/
I {declare(array, word, tail); declare(scalar, retv, head, has_head)}

 -> parenthesis       {
   if(is_nonempty(a(word)));
    if(is_empty(s(has_head)));
     assign(s(head), join_values("", a(word)));
     assign(s(has_head), 1);
    else();
     push_value(a(tail), join_values("", a(word)));
    endif();
    assign(a(word), a());
   endif();
   assign(s(retv), call(parenthesis));
   if(is_empty(s(has_head)));
    assign(s(head), s(retv));
    assign(s(has_head), 1);
   else();
    push_value(a(tail), s(retv));
   endif()
}

 -> spaces            {
   call(spaces);
   if(is_nonempty(a(word)));
    if(is_empty(s(has_head)));
     assign(s(head), join_values("", a(word)));
     assign(s(has_head), 1);
    else();
     push_value(a(tail), join_values("", a(word)));
    endif();
    assign(a(word), a());
   endif()
}
 -> dquotes           {assign(s(retv), call(dquotes)); push_value(a(word), scalaref(retv, {content}))}
 -> sbrackets         {assign(s(retv), call(sbrackets)); push_value(a(word), scalaref(retv, {content}))}
 -> curlyb            {assign(s(retv), call(curlyb)); push_value(a(word), scalaref(retv, {content}))}
 -> others            {assign(s(retv), call(others)); push_value(a(word), scalaref(retv, {content}))}
 -> comments          {call(comments)}

 -> parenthesis[1]    {
   if(is_nonempty(a(word)));
    if(is_empty(s(has_head)));
     assign(s(head), join_values("", a(word)));
     assign(s(has_head), 1);
    else();
     push_value(a(tail), join_values("", a(word)));
    endif();
   endif();

   if(s(has_head));
    if(is_nonempty(a(tail)));
     return(a(s(head), array_values(a(tail))));
    else();
     return(a(s(head), undef));
    endif();
   else();
    return(a(undef));
   endif()
}

sbrackets: /(\[(?:[^\[\]]++|(?R))+\])/     I.return(h("type", "SBRACKETS", "content", entry_text()))

dquotes: /"(.*?)(?<!\\)"/     I.return(h("type", "DQUOTES", "content", entry_group(0)))

squotes: /'(.*?)(?<!\\)'/     I.return(h("type", "SQUOTES", "content", entry_group(0)))

curlyb: /(?<!\\)\{/ /(?<!\\)\}/ I {declare(scalar, content)}
 -> curlyb
 -> dquotes
 -> squotes
 -> curlyb[1]                 {
 assign(s(content), CAPTURE);
 return(h("type", "CBRACE", "content", s(content)))
}

spaces: /\s+/               I.return(h("type", "SPACE", "content", entry_text()))

others: /[^\s\"\{\}\(\)\[\];]+/  I.return(h("type", "OTHERS", "content", entry_text()))
			      
comments: /;.*\n/           I.return(h("type", "COMMENTS", "content", entry_text()))
