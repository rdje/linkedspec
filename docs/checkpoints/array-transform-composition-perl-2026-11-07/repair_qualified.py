"""Retain selected Array results without changing their first producer policies."""
import difflib
import gzip
from pathlib import Path
import re
import subprocess

BASE = Path(__file__).resolve().parent
OWNER = Path('perl/LinkedSpec/ActionIR/MethodLowering.pm')
roles = ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays')
red = {('target_' + name + '_' + route + '_hash_guard').encode() for name in roles for route in ('free', 'receiver')}
red |= {b'target_take_later_with', b'target_reverse_copy_later_with', b'target_sort_logical_later_with'}
stdout = gzip.decompress((BASE / 'before/stdout.log.gz').read_bytes())
assert set(re.findall(rb'^not ok \d+ - (\S+)', stdout, re.M)) == red
assert len(re.findall(rb'^(?:not )?ok \d+ - ', stdout, re.M)) == 212
original = OWNER.read_bytes()
assert original == subprocess.check_output(['git', 'show', '4bfe17f75c20851bc9a634c151071b6d196de57d:' + str(OWNER)])
text = original.decode()
marker = '# Count keeps its numeric result and existing non-array zero source policy.'
helper = r'''# Ordinary Array transforms retain their existing producers and optional arities.
# Only these canonical value forms gain result guards; list-splice roles stay out.
sub _ordinary_array_transform_result_call {
 my ($call, $is_receiver) = @_;
 return 0 unless ref($call) eq 'HASH'
  && ($is_receiver || ($call->{kind} // '') eq 'call');
 my $method = $is_receiver ? ($call->{method} // '') : ($call->{name} // '');
 return 0 unless $method =~ /\A(?:take|take_last|drop_front|drop_back|slice|sorted|reversed|concat_arrays)\z/o
  && ($call->{source_method} // $method) eq $method
  && !$call->{trailing_block_arg} && !$call->{receiver_trailing_block_arg}
  && ($is_receiver || (defined($call->{source}) && length($call->{source})))
  && ref($call->{args}) eq 'ARRAY';
 my $count = @{$call->{args}} + ($is_receiver ? 1 : 0);
 my $minimum = ($method eq 'slice' || $method eq 'concat_arrays') ? 2 : 1;
 my $maximum = $method eq 'slice' ? 3 : ($method eq 'sorted' || $method eq 'reversed') ? 1 : 2;
 return 0 if $count < $minimum || $count > $maximum;
 foreach my $value (@{$call->{args}}) {
  return 0 unless ref($value) eq 'HASH'
   && ($value->{kind} // '') =~ /\A(?:variable|string|number|boolean|undef|array_literal|hash_literal|block_value|call|fluent_chain|receiver_mutation_chain|indexed_var|nested_access|value_access|assign_scalar|assign_array_append|assign_hash_index|assign_nested_access|codeblock_literal)\z/o;
  return 0 if ($value->{kind} // '') eq 'call'
   && ($value->{name} // '') =~ /\A(?:flat|flat_array|flat_hash)\z/o;
 }
 return 1
}

'''
assert text.count(marker) == 1
text = text.replace(marker, helper + marker)
marker = '  # Copy and collection results stay together; other source roles retain copy'
flag = '''  my $ordinary_array_transform_result_chain = (_ordinary_array_transform_result_call($receiver, 0)
    || (@$calls > 1 && ($receiver->{kind} // '') ne 'raw_perl'
     && !(($receiver->{kind} // '') eq 'call'
       && _user_function_definition_for_name($deps, $receiver->{name}))
     && _ordinary_array_transform_result_call($calls->[0], 1)))
   && !defined(_actionir_ast_first_unknown_value_call_name($node, $deps))
   && !(grep { _is_tree_traversal_receiver_method($_->{method} // '')
     || (($_->{trailing_block_arg} || $_->{receiver_trailing_block_arg}) && ($_->{method} // '') ne 'with') } @$calls);
'''
assert text.count(marker) == 1
text = text.replace(marker, flag + marker)
assert text.count('|| $ordinary_hash_value_result_chain') == 5
text = text.replace('|| $ordinary_hash_value_result_chain', '|| $ordinary_hash_value_result_chain || $ordinary_array_transform_result_chain')
for old in ('&& !$retained_result_source && !$logical_receiver && !$ordinary_hash_view_result_chain',
            '&& !$retained_result_source && !$logical_receiver && !$ordinary_hash_value_result_chain'):
    assert text.count(old) == 1
    text = text.replace(old, old + ' && !$ordinary_array_transform_result_chain')
old = '  my $initial_hash_prefix = $initial_hash_view_prefix || $initial_hash_value_prefix;'
new = '''  my $initial_array_transform_prefix = $ordinary_array_transform_result_chain
   && !_ordinary_array_transform_result_call($receiver, 0)
   && !$retained_result_source && !$logical_receiver
   && !$ordinary_hash_view_result_chain && !$ordinary_hash_value_result_chain
   && !$ordinary_count_result_chain && !$ordinary_key_count_result_chain
   && _ordinary_array_transform_result_call($calls->[0], 1);
  my $initial_collection_prefix = $initial_hash_view_prefix || $initial_hash_value_prefix
   || $initial_array_transform_prefix;'''
assert text.count(old) == 1
text = text.replace(old, new)
assert text.count('$initial_hash_prefix') == 2
text = text.replace('$initial_hash_prefix', '$initial_collection_prefix')
text = text.replace('# An initial view owns its source fallback/errors before its Array result is\n  # guarded.', '# An initial collection helper owns its source fallback/errors before its result\n  # is guarded.')
assert text.count('&& !_method_value_is_numeric_literal($target_expr, $deps)') == original.decode().count('&& !_method_value_is_numeric_literal($target_expr, $deps)')
(BASE / 'owner-before.pm.gz').write_bytes(gzip.compress(original, mtime=0))
patch = ''.join(difflib.unified_diff(original.decode().splitlines(True), text.splitlines(True), fromfile=str(OWNER), tofile=str(OWNER))).encode()
(BASE / 'source.patch.gz').write_bytes(gzip.compress(patch, mtime=0))
OWNER.write_text(text)
print('Original212 baseline19RED; selected Array result roles and original first-producer permission retained')
