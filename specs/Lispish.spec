Lispish::
 -> parenthesis     {return call(parenthesis)}
 -> parenthesis[1]  {say("(Lispish) -E- Syntax Error"); exit 1}
 -> comments

parenthesis: /\(/ /\)/
I {
 #say "parenthesis OPENING (";
 my @submatchs; 
 my @word;
 my $retv
}

 -> parenthesis       {
 #say "Closing WORD --> submatchs (DUE to OPENING PARENTHESIS)" if @word;
 push @submatchs, join("", @word) if @word;
 @word = ();
 $retv = call(parenthesis)
}

 -> spaces            {$retv = call(spaces)}
 -> dquotes           {$retv = call(dquotes)}
 -> sbrackets         {$retv = call(sbrackets)}
 -> curlyb            {$retv = call(curlyb)}
 -> others            {$retv = call(others)}
 -> comments          {$retv = call(comments)}

 -> parenthesis[1]    {
 #say "parenthesis CLOSING )";
 #say "Closing WORD --> submatchs (DUE to CLOSING PARENTHESIS)" if @word;
 push @submatchs, join("", @word) if @word;
 return @submatchs >= 1 ? [$submatchs[0], @submatchs == 1 ? undef : [@submatchs[1 .. $#submatchs]]] : [undef]
}
 

 LE {
  my $is_ref = ref($retv);
  unless ($is_ref && $is_ref eq 'HASH') {
  # For Opening parenthesis
   push @submatchs, $retv;
  } elsif ($retv->{type} eq 'SPACE') {
    #say "Closing WORD --> submatchs (DUE to SPACE)";
    push @submatchs, join("", @word) if @word;
    @word = ()
  } elsif ($retv->{type} ne 'COMMENTS') {
    #say "Pushing '$retv' into WORD";
    # DQUOTES + CBRACE + OTHERS
    push @word, $retv->{content}
  } 
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
