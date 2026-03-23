# Grammar parser for := style rules
# This spec will parse EBNF-style grammar definitions

grammar_file:: I {
  declare(array, rules, rule, includes, semantic_annotations);
  declare(scalar, rule, on)
}

LX {
  if(scalar(rule));
    push_value(array(rules), array(scalar(rule), flat_array(rule)));
  endif();

  return(array(flat_array(includes), flat_array(rules)))
}

-> include_dir.push(includes)
-> include_file.push(includes)

-> grammar_rule   {
  if(scalar(rule));
    push_value(array(rules), array(scalar(rule), flat_array(rule)));
  endif();

  assign(array(rule), array(flat_array(semantic_annotations)));
  assign(array(semantic_annotations), array());

  $rule = call(grammar_rule);
  assign(scalar(on), 1)
}

-> rule_name
  .if(scalar(on))
    .push(rule_name, rule)
  .else()
    .say("Error: Rule name '$LMATCH' reference with no container rule context")
    .return_undef()
  .endif()

-> quoted_string
  .if(scalar(on))
    .push(quoted_string, rule)
  .else()
    .say("Error: Quoted string <$LMATCH> occurrence with no container rule context")
    .return_undef()
  .endif()

-> number
  .if(scalar(on))
    .push(number, rule)
  .else()
    .say("Error: Number '$LMATCH' occurrence with no container rule context")
    .return_undef()
  .endif()

-> quantifier
  .if(scalar(on))
    .push(quantifier, rule)
  .else()
    .say("Error: Quantifier occurrence with no container rule context")
    .return_undef()
  .endif()

-> plus_operator
  .if(scalar(on))
    .push(plus_operator, rule)
  .else()
    .say("Error: '+' operator occurrence with no container rule context")
    .return_undef()
  .endif()

-> return_scalar
  .if(scalar(on))
    .push(return_scalar, rule)
  .else()
    .say("Error: Scalar return annotation occurrence with no container rule context")
    .return_undef()
  .endif()

-> return_array
  .if(scalar(on))
    .push(return_array, rule)
  .else()
    .say("Error: Array return annotation occurrence with no container rule context")
    .return_undef()
  .endif()

-> return_object
  .if(scalar(on))
    .push(return_object, rule)
  .else()
    .say("Error: Object return annotation occurrence with no container rule context")
    .return_undef()
  .endif()

-> star_operator
  .if(scalar(on))
    .push(star_operator, rule)
  .else()
    .say("Error: '*' operator occurrence with no container rule context")
    .return_undef()
  .endif()

-> question_operator
  .if(scalar(on))
    .push(question_operator, rule)
  .else()
    .say("Error: '?' operator occurrence with no container rule context")
    .return_undef()
  .endif()

-> pipe_operator
  .if(scalar(on))
    .push(pipe_operator, rule)
  .else()
    .say("Error: '|' operator occurrence with no container rule context")
    .return_undef()
  .endif()

-> open_paren
  .if(scalar(on))
    .push(open_paren, rule)
  .else()
    .say("Error: '(' occurrence with no container rule context")
    .return_undef()
  .endif()

-> close_paren
  .if(scalar(on))
    .push(close_paren, rule)
  .else()
    .say("Error: ')' occurrence with no container rule context")
    .return_undef()
  .endif()

-> probability
  .if(scalar(on))
    .push(probability, rule)
  .else()
    .say("Error: Probability occurrence with no container rule context")
    .return_undef()
  .endif()

-> regex
  .if(scalar(on))
    .push(regex, rule)
  .else()
    .say("Error: Regex occurrence with no container rule context")
    .return_undef()
  .endif()

-> semantic_annotation.push(semantic_annotations)
-> logging_annotation
  .if(scalar(on))
    .push(logging_annotation, rule)
  .else()
    .say("Error: Logging annotation occurrence with no container rule context")
    .return_undef()
  .endif()

-> whitespace
-> comment

grammar_rule: /(?m)^\s*([[:alpha:]_]\w*)\s*:{,2}=/  I.return(array("rule", entry_group(0)))
rule_name: /\b[[:alpha:]_]\w*/                      I.return(array("rule_reference", entry_text()))

quoted_string: /"[^"]*"|'[^']*'/  I.declare(scalar, value=entry_text()).substr(scalar(value), "^(?:'|\")|(?:'|\")$", "", go).return(array("quoted_string", scalar(value)))
number: /\b\d+\b/                 I.return(array("number", entry_text()))
quantifier: /\{\s*(?:\d+(?:\s*,\s*\d*)?|,\s*\d+)\s*\}/  I.declare(scalar, value=entry_text()).substr(scalar(value), "\\{|\\}", "", go).return(array("quantifier", scalar(value)))
pipe_operator: /\|/               I.return(array("operator", entry_text()))
plus_operator: /\+/               I.return(array("operator", entry_text()))
star_operator: /\*/               I.return(array("operator", entry_text()))
question_operator: /\?/           I.return(array("operator", entry_text()))
return_scalar: /->\s*\K(?:\$\d+|"[^"]*"|'[^']*')/  I.return(array("return_scalar", entry_text()))
return_array: /->\s*\K(?&array_structure)(?(DEFINE)(?<array_structure>\[(?&content)\])(?<object_structure>\{(?&content)\})(?<content>(?:[^{}\[\]]*|(?&array_structure)|(?&object_structure))*))/   I.return(array("return_array", entry_text()))
return_object: /->\s*\K(?&object_structure)(?(DEFINE)(?<array_structure>\[(?&content)\])(?<object_structure>\{(?&content)\})(?<content>(?:[^{}\[\]]*|(?&array_structure)|(?&object_structure))*))/ I.return(array("return_object", entry_text()))
open_paren: /\(/                  I.return(array("group_open", entry_text()))
close_paren: /\)/                 I.return(array("group_close", entry_text()))
probability: /@\d+%?/             I.declare(scalar, value=entry_text()).substr(scalar(value), "@|%", "", go).return(array("probability", scalar(value)))
regex: /(?<!\\)\/.+?(?<!\\)\//    I.declare(scalar, value=entry_text()).substr(scalar(value), "^/|/$", "", go).return(array("regex", scalar(value)))
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

logging_annotation: /@((?:log|debug|trace|benchmark|profile|timing)_\w+)\s*\(\s*/ /\s*\)/ 	@capture_from_here
I {$IMATCH =~ s/@|\s*\(//go}

-> quoted_string {
  push @logging_annotation, call(quoted_string)->[1]
}
-> comma.capture_if
-> logging_annotation[1] {
  CAPTURE_IF();
  return ['logging_annotation', [$IMATCH, [@logging_annotation]]]
}

comma: /\s*,\s*/
