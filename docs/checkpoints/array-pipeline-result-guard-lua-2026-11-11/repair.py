"""Asserted own-Lua pipeline-role writer; --check rehearses without mutation."""
import gzip
from pathlib import Path
import sys

BASE = Path(__file__).resolve().parent
OWNER = Path('lua/src/linkedspec/interpreter.lua')
RUNNER = Path('lua/test/run.lua')
original = gzip.decompress((BASE / 'owner-before.lua.gz').read_bytes()).decode()
assert OWNER.read_text() == original
text = original


def replace_once(old, new):
    global text
    assert text.count(old) == 1, old[:100]
    text = text.replace(old, new)


helpers = '''-- Canonical pure Array pipelines retain actual-kind guards after their
-- producer. Reuse the existing namespace to preserve the chunk-local budget.
function typed_source.receiver_mutation.is_ordinary_array_pipeline_operand(expr)
  return typed_source.receiver_mutation.is_ordinary_array_transform_operand(expr) and
    not (expr.kind == "call" and (expr.name == "flat" or expr.name == "flat_array" or expr.name == "flat_hash"))
end

function typed_source.receiver_mutation.is_canonical_array_pipeline_arity(name, count)
  if name == "split_each" or name == "filter_match" then return count == 2 end
  return count == 1 and (name == "trim_each" or name == "filter_nonempty" or
    name == "lowercase_each" or name == "uppercase_each" or name == "uniq")
end

function typed_source.receiver_mutation.is_ordinary_array_pipeline_arguments(name, args, receiver)
  for index, argument in ipairs(args or {}) do
    if argument.argument_kind ~= "positional" then return false end
    local expr = argument_expr(argument)
    local pattern = expr and expr.kind == "regex" and (name == "split_each" or name == "filter_match") and
      #(args or {}) == (receiver and 1 or 2) and index == #(args or {})
    if not pattern and not typed_source.receiver_mutation.is_ordinary_array_pipeline_operand(expr) then
      return false
    end
  end
  return true
end

function typed_source.receiver_mutation.is_ordinary_array_pipeline_receiver_call(call)
  return call ~= nil and (call.source_method or call.method) == call.method and
    not call.trailing_block_arg and not call.receiver_trailing_block_arg and
    typed_source.receiver_mutation.is_canonical_array_pipeline_arity(call.method, #(call.args or {}) + 1) and
    typed_source.receiver_mutation.is_ordinary_array_pipeline_arguments(call.method, call.args, true)
end

function typed_source.receiver_mutation.is_ordinary_array_pipeline_result_chain(engine, expr, calls)
  for _, call in ipairs(calls or {}) do
    local method = action_contracts.canonical_action_helper_name(call.method)
    if method == "walk_leaves" or method == "map_leaves" or method == "reduce_leaves" or
      ((call.trailing_block_arg or call.receiver_trailing_block_arg) and method ~= "with") or
      not typed_source.receiver_mutation.is_ordinary_array_pipeline_arguments(method, call.args, true) or
      not (is_pure_string_helper(method) or PURE_ARRAY_HELPERS[method] or PURE_HASH_HELPERS[method] or
        LOGICAL_HELPERS[method] or scalar_numeric.supports(method) or scalar_numeric.supports_reducer(method) or
        method == "copy" or method == "with" or method == "coalesce" or method == "coalesce_nonempty") then
      return false
    end
  end
  if expr ~= nil and expr.kind == "call" then
    if engine.compiled_spec.function_registry:has_name(expr.name) then return false end
    if (expr.source_method or expr.name) == expr.name and not expr.trailing_block_arg and
      typed_source.receiver_mutation.is_canonical_array_pipeline_arity(expr.name, #(expr.args or {})) and
      typed_source.receiver_mutation.is_ordinary_array_pipeline_arguments(expr.name, expr.args, false) then
      return true
    end
  end
  return typed_source.receiver_mutation.is_ordinary_array_pipeline_operand(expr) and #(calls or {}) > 1 and
    typed_source.receiver_mutation.is_ordinary_array_pipeline_receiver_call(calls[1])
end

'''
replace_once('-- Canonical pure Hash helpers own later actual-kind guards.', helpers + '-- Canonical pure Hash helpers own later actual-kind guards.')
needle = '  local array_transform_chain = typed_source.receiver_mutation.is_ordinary_array_transform_result_chain(engine, target_receiver, calls)'
replace_once(needle, '''  local array_pipeline_chain = typed_source.receiver_mutation.is_ordinary_array_pipeline_result_chain(engine, target_receiver, calls)
  local preserve_initial_array_pipeline_source = array_pipeline_chain and not kind_guarded_result and
    not typed_source.receiver_mutation.is_ordinary_count_result_chain(target_receiver, {}) and
    not typed_source.receiver_mutation.is_ordinary_key_count_result_chain(target_receiver, {}) and
    not typed_source.receiver_mutation.is_ordinary_hash_view_result_chain(engine, target_receiver, {}) and
    not typed_source.receiver_mutation.is_ordinary_hash_value_result_chain(engine, target_receiver, {}) and
    not typed_source.receiver_mutation.is_ordinary_array_transform_result_chain(engine, target_receiver, {}) and
    not typed_source.receiver_mutation.is_ordinary_array_pipeline_result_chain(engine, target_receiver, {}) and
    typed_source.receiver_mutation.is_ordinary_array_pipeline_receiver_call(calls[1])
  -- Initial producer fallback survives; earlier guards and later Array results
  -- keep their own rejection before any incompatible consumer operands run.
  kind_guarded_result = kind_guarded_result or array_pipeline_chain
''' + needle)
replace_once('      not (preserve_initial_array_transform_source and index == 1) then',
             '      not (preserve_initial_array_transform_source and index == 1) and\n      not (preserve_initial_array_pipeline_source and index == 1) then')
runner = RUNNER.read_text()
anchor = '''test("Ordinary Array-transform result guards", function()
  dofile("lua/test/array_transform_result_guard_composition_test.lua")
end)'''
addition = '''
test("Ordinary Array-pipeline result guards", function()
  dofile("lua/test/array_pipeline_result_guard_composition_test.lua")
end)'''
assert runner.count(anchor) == 1 and 'dofile("lua/test/array_pipeline_result_guard_composition_test.lua")' not in runner
if sys.argv[1:] == ['--check']:
    print('Asserted Lua writer rehearsal PASS; no source writes')
else:
    assert sys.argv[1:] == []
    OWNER.write_text(text)
    RUNNER.write_text(runner.replace(anchor, anchor + addition))
    print('Installed-Lua canonical pipeline roles/initial permission and one normal group written')
