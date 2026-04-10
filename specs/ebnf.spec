# Grammar parser for := style rules
# This spec will parse EBNF-style grammar definitions

grammar_file:: I {
  declare(array, rules, rule, includes, semantic_annotations);
  declare(scalar, rule, on)
}

LX {
  if(s(rule));
    push_value(a(rules), a(s(rule), flat_array(rule)));
  endif();

  return(a(flat_array(includes), flat_array(rules)))
}

-> include_dir.push(includes)
-> include_file.push(includes)

-> grammar_rule   {
  if(s(rule));
    push_value(a(rules), a(s(rule), flat_array(rule)));
  endif();

  assign(a(rule), a(flat_array(semantic_annotations)));
  assign(a(semantic_annotations), a());

  $rule = call(grammar_rule);
  assign(s(on), 1)
}

-> rule_name
  .if(s(on))
    .push(rule_name, rule)
  .else()
    .say("Error: Rule name '$LMATCH' reference with no container rule context")
    .return_undef()
  .endif()

-> quoted_string
  .if(s(on))
    .push(quoted_string, rule)
  .else()
    .say("Error: Quoted string <$LMATCH> occurrence with no container rule context")
    .return_undef()
  .endif()

-> number
  .if(s(on))
    .push(number, rule)
  .else()
    .say("Error: Number '$LMATCH' occurrence with no container rule context")
    .return_undef()
  .endif()

-> quantifier
  .if(s(on))
    .push(quantifier, rule)
  .else()
    .say("Error: Quantifier occurrence with no container rule context")
    .return_undef()
  .endif()

-> plus_operator
  .if(s(on))
    .push(plus_operator, rule)
  .else()
    .say("Error: '+' operator occurrence with no container rule context")
    .return_undef()
  .endif()

-> return_scalar
  .if(s(on))
    .push(return_scalar, rule)
  .else()
    .say("Error: Scalar return annotation occurrence with no container rule context")
    .return_undef()
  .endif()

-> return_array
  .if(s(on))
    .push(return_array, rule)
  .else()
    .say("Error: Array return annotation occurrence with no container rule context")
    .return_undef()
  .endif()

-> return_object
  .if(s(on))
    .push(return_object, rule)
  .else()
    .say("Error: Object return annotation occurrence with no container rule context")
    .return_undef()
  .endif()

-> star_operator
  .if(s(on))
    .push(star_operator, rule)
  .else()
    .say("Error: '*' operator occurrence with no container rule context")
    .return_undef()
  .endif()

-> question_operator
  .if(s(on))
    .push(question_operator, rule)
  .else()
    .say("Error: '?' operator occurrence with no container rule context")
    .return_undef()
  .endif()

-> pipe_operator
  .if(s(on))
    .push(pipe_operator, rule)
  .else()
    .say("Error: '|' operator occurrence with no container rule context")
    .return_undef()
  .endif()

-> open_paren
  .if(s(on))
    .push(open_paren, rule)
  .else()
    .say("Error: '(' occurrence with no container rule context")
    .return_undef()
  .endif()

-> close_paren
  .if(s(on))
    .push(close_paren, rule)
  .else()
    .say("Error: ')' occurrence with no container rule context")
    .return_undef()
  .endif()

-> probability
  .if(s(on))
    .push(probability, rule)
  .else()
    .say("Error: Probability occurrence with no container rule context")
    .return_undef()
  .endif()

-> regex
  .if(s(on))
    .push(regex, rule)
  .else()
    .say("Error: Regex occurrence with no container rule context")
    .return_undef()
  .endif()

-> semantic_annotation.push(semantic_annotations)
-> logging_annotation
  .if(s(on))
    .push(logging_annotation, rule)
  .else()
    .say("Error: Logging annotation occurrence with no container rule context")
    .return_undef()
  .endif()

-> whitespace
-> comment

grammar_rule: /(?m)^\s*([[:alpha:]_]\w*)\s*:{,2}=/  I.return(a("rule", entry_group(0)))
rule_name: /\b[[:alpha:]_]\w*/                      I.return(a("rule_reference", entry_text()))

quoted_string: /"[^"]*"|'[^']*'/  I.declare(scalar, value=entry_text()).substr(s(value), "^(?:'|\")|(?:'|\")$", "", go).return(a("quoted_string", s(value)))
number: /\b\d+\b/                 I.return(a("number", entry_text()))
quantifier: /\{\s*(?:\d+(?:\s*,\s*\d*)?|,\s*\d+)\s*\}/  I.declare(scalar, value=entry_text()).substr(s(value), "\\{|\\}", "", go).return(a("quantifier", s(value)))
pipe_operator: /\|/               I.return(a("operator", entry_text()))
plus_operator: /\+/               I.return(a("operator", entry_text()))
star_operator: /\*/               I.return(a("operator", entry_text()))
question_operator: /\?/           I.return(a("operator", entry_text()))
return_scalar: /->\s*\K(?:\$\d+|"[^"]*"|'[^']*')/  I.return(a("return_scalar", entry_text()))
return_array: /->\s*\K(?&array_structure)(?(DEFINE)(?<array_structure>\[(?&content)\])(?<object_structure>\{(?&content)\})(?<content>(?:[^{}\[\]]*|(?&array_structure)|(?&object_structure))*))/   I.return(a("return_array", entry_text()))
return_object: /->\s*\K(?&object_structure)(?(DEFINE)(?<array_structure>\[(?&content)\])(?<object_structure>\{(?&content)\})(?<content>(?:[^{}\[\]]*|(?&array_structure)|(?&object_structure))*))/ I.return(a("return_object", entry_text()))
open_paren: /\(/                  I.return(a("group_open", entry_text()))
close_paren: /\)/                 I.return(a("group_close", entry_text()))
probability: /@\d+%?/             I.declare(scalar, value=entry_text()).substr(s(value), "@|%", "", go).return(a("probability", s(value)))
regex: /(?<!\\)\/.+?(?<!\\)\//    I.declare(scalar, value=entry_text()).substr(s(value), "^/|/$", "", go).return(a("regex", s(value)))
whitespace: /\s+/
comment: /#.*/
include_dir: /\b(?:include_)?dir\(\s*[^)]*?\s*\)/ I {
  my $args = $IMATCH;
  $args =~ s/^\s*(?:include_)?dir\(\s*//;
  $args =~ s/\s*\)\s*$//;
  my @parts = grep { length($_) } map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } split /\s*,\s*/, $args;
  return ["include_dir", \@parts]
}
include_file: /\b(?:include(?:_file)?|file)\(\s*[^)]*?\s*\)/ I {
  my $args = $IMATCH;
  $args =~ s/^\s*(?:include(?:_file)?|file)\(\s*//;
  $args =~ s/\s*\)\s*$//;
  my @parts = grep { length($_) } map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } split /\s*,\s*/, $args;
  return ["include_file", \@parts]
}

semantic_annotation: /@(\w+)\s*:\s*/
-> semantic_annotation | grammar_rule {BACKTRACK(); my $c = $CAPTURE; $c =~ s/\s*$//o; $c =~ s/^"|"$//go; return ['semantic_annotation', [$IMATCH_LIST[0], $c]]}

logging_annotation: /@((?:log|debug|trace|benchmark|profile|timing)_\w+)\s*\(\s*/ /\s*\)/ 	@capture_slice
I {$IMATCH =~ s/@|\s*\(//go}

-> quoted_string {
  push(quoted_string, 1)
}
-> comma {
  push_nonempty(a(logging_annotation), trim(capture_slice()))
}
-> logging_annotation[1] {
  push_nonempty(a(logging_annotation), trim(capture_slice()));
  return ['logging_annotation', [$IMATCH, [@logging_annotation]]]
}

comma: /\s*,\s*/
