"""Add canonical pipeline result roles while preserving original producers."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
OWNER = Path('perl/LinkedSpec/ActionIR/MethodLowering.pm')
old = OWNER.read_bytes()
record = json.loads((BASE / 'before/input-identities.json').read_bytes())[str(OWNER)]
assert hashlib.sha256(old).hexdigest() == record['sha256']
text = old.decode()


def replace(needle, replacement, count=1):
    global text
    assert text.count(needle) == count, needle
    text = text.replace(needle, replacement)


helper = r'''# Pure pipeline results are Arrays at their canonical ordinary arities.
# Regex operands belong only to the split/filter pattern position.
sub _ordinary_array_pipeline_result_call {
 my ($call, $is_receiver) = @_;
 return 0 unless ref($call) eq 'HASH'
  && ($is_receiver || ($call->{kind} // '') eq 'call');
 my $method = $is_receiver ? ($call->{method} // '') : ($call->{name} // '');
 return 0 unless $method =~ /\A(?:split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match)\z/o
  && ($call->{source_method} // $method) eq $method
  && !$call->{trailing_block_arg} && !$call->{receiver_trailing_block_arg}
  && ($is_receiver || (defined($call->{source}) && length($call->{source})))
  && ref($call->{args}) eq 'ARRAY';
 my $pattern_method = $method eq 'split_each' || $method eq 'filter_match';
 my $count = @{$call->{args}} + ($is_receiver ? 1 : 0);
 return 0 unless $count == ($pattern_method ? 2 : 1);
 foreach my $index (0 .. $#{$call->{args}}) {
  my $value = $call->{args}[$index];
  return 0 unless ref($value) eq 'HASH';
  my $kind = $value->{kind} // '';
  if ($kind eq 'regex') {
   return 0 unless $pattern_method && $index == $#{$call->{args}};
   next;
  }
  return 0 unless $kind =~ /\A(?:variable|string|number|boolean|undef|array_literal|hash_literal|block_value|call|fluent_chain|receiver_mutation_chain|indexed_var|nested_access|value_access|assign_scalar|assign_array_append|assign_hash_index|assign_nested_access|codeblock_literal)\z/o;
  return 0 if $kind eq 'call' && ($value->{name} // '') =~ /\A(?:flat|flat_array|flat_hash)\z/o;
 }
 return 1
}

'''
replace('# Count keeps its numeric result and existing non-array zero source policy.',
        helper + '# Count keeps its numeric result and existing non-array zero source policy.')
chain = r'''  my $ordinary_array_pipeline_result_chain = (_ordinary_array_pipeline_result_call($receiver, 0)
    || (@$calls > 1 && ($receiver->{kind} // '') ne 'raw_perl'
     && !(($receiver->{kind} // '') eq 'call'
       && _user_function_definition_for_name($deps, $receiver->{name}))
     && _ordinary_array_pipeline_result_call($calls->[0], 1)))
   && !defined(_actionir_ast_first_unknown_value_call_name($node, $deps))
   && !(grep { _is_tree_traversal_receiver_method($_->{method} // '')
     || (($_->{trailing_block_arg} || $_->{receiver_trailing_block_arg}) && ($_->{method} // '') ne 'with') } @$calls);
'''
replace('  # Copy and collection results stay together;', chain + '  # Copy and collection results stay together;')
replace(' || $ordinary_array_transform_result_chain',
        ' || $ordinary_array_transform_result_chain || $ordinary_array_pipeline_result_chain', 5)
replace('&& !$ordinary_array_transform_result_chain',
        '&& !$ordinary_array_transform_result_chain && !$ordinary_array_pipeline_result_chain', 2)
replace('   && _ordinary_array_transform_result_call($calls->[0], 1);',
        '   && !$ordinary_array_pipeline_result_chain\n   && _ordinary_array_transform_result_call($calls->[0], 1);')
initial = r'''  my $initial_array_pipeline_prefix = $ordinary_array_pipeline_result_chain
   && !_ordinary_array_pipeline_result_call($receiver, 0)
   && !$retained_result_source && !$logical_receiver
   && !$ordinary_hash_view_result_chain && !$ordinary_hash_value_result_chain && !$ordinary_array_transform_result_chain
   && !$ordinary_count_result_chain && !$ordinary_key_count_result_chain
   && _ordinary_array_pipeline_result_call($calls->[0], 1);
'''
replace('  my $initial_collection_prefix =', initial + '  my $initial_collection_prefix =')
replace('   || $initial_array_transform_prefix;', '   || $initial_array_transform_prefix || $initial_array_pipeline_prefix;')
assert text != old.decode()
OWNER.write_text(text)
assert OWNER.stat().st_mode & 0o777 == record['mode']
print('Added only canonical pipeline result classification and existing retained/initial-producer routes')
