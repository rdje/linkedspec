#!/usr/bin/env perl
# Fixed compatibility intake; run from the repository root through project_data_run.sh.
use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use JSON::PP ();
my $json = JSON::PP->new->canonical;
for my $case (
 ['host_cos_rhs', q{return(array(/(14,2), 14/cos))}],
 ['quoted_next_argument', q{return(array(/(14,2), "a/)"))}],
 ['host_quote_next_argument', q{return(array(/(14,2), q/)/))}],
 ['receiver_continuation', q{return(array(/(14,2).floor(), 1))}],
 ['receiver_and_quoted_argument', q{return(array(/(14,2).floor().add(1), "a/)"))}],
 ['comment_after_argument', "value = add(/(14,2),1)\n# pattern/)\nreturn(value)"],
 ['comment_inside_arguments', "return(array(/(14,2),\n# pattern/)\n1))"],
 ['bare_infix_rhs', q{i = 2; return(array(/(14,2), 14/i))}],
 ['wrong_arity_quoted_follower', q{return(array(/(14), "a/)"))}],
 ['grouped_comma_flags', q{return(matches("x,y", /(x),y/i))}],
 ['numeric_group_dot', q{return(matches("14,2zz", /(14,2).*z/))}],
 ['quoted_pattern_payload', q{return(matches('x,"', /(x),"/))}],
) {
 my ($id, $action) = @$case;
 my $source = "Top::\n -> Done { $action }\nDone:\n /x/\n";
 my $lowered = LinkedSpec::call_spec_handler_subst('Top', $action);
 my $ast = LinkedSpec::ActionIR::AST::parse_action_block($action);
 my %context;
 my $parser = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
 my $build_error = "$@";
 my $input = 'x';
 my $value = $parser ? eval { $parser->(\$input) } : undef;
 my $error = "$@";
 print $json->encode({id => $id, action => $action, lowered => $lowered,
  ast => $ast, value => $value, build_error => $build_error, error => $error,
  last_error => $context{last_error}}), "\n";
}
