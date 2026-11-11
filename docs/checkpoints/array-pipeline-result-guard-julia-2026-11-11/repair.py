"""Asserted Julia pipeline-role writer; --check constructs without writes."""
import gzip
from pathlib import Path
import sys

BASE = Path(__file__).resolve().parent
OWNER = Path('julia/src/runtime/Interpreter.jl')
original = gzip.decompress((BASE / 'owner-before.jl.gz').read_bytes()).decode()
assert OWNER.read_text() == original
text = original


def replace_once(old, new):
    global text
    assert text.count(old) == 1, old[:100]
    text = text.replace(old, new)


replace_once('    array_transform_chain = _runtime_is_ordinary_array_transform_result_chain(engine, chain.receiver, chain.calls)', '''    array_pipeline_chain = _runtime_is_ordinary_array_pipeline_result_chain(engine, chain.receiver, chain.calls)
    preserve_initial_array_pipeline_source = array_pipeline_chain && !kind_guarded_result &&
        !_runtime_is_ordinary_count_result_chain(chain.receiver, ()) &&
        !_runtime_is_ordinary_key_count_result_chain(chain.receiver, ()) &&
        !_runtime_is_ordinary_hash_view_result_chain(engine, chain.receiver, ()) &&
        !_runtime_is_ordinary_hash_value_result_chain(engine, chain.receiver, ()) &&
        !_runtime_is_ordinary_array_transform_result_chain(engine, chain.receiver, ()) &&
        !_runtime_is_ordinary_array_pipeline_result_chain(engine, chain.receiver, ()) &&
        _runtime_is_ordinary_array_pipeline_receiver_call(first(chain.calls))
    # Keep the first pipeline's source fallback. Its Array owns later guards.
    kind_guarded_result = kind_guarded_result || array_pipeline_chain
    array_transform_chain = _runtime_is_ordinary_array_transform_result_chain(engine, chain.receiver, chain.calls)''')
replace_once('''        initial_array_transform_source = preserve_initial_array_transform_source && call_index == 1
''', '''        initial_array_transform_source = preserve_initial_array_transform_source && call_index == 1
        initial_array_pipeline_source = preserve_initial_array_pipeline_source && call_index == 1
''')
replace_once('''            !initial_array_transform_source &&
''', '''            !initial_array_transform_source && !initial_array_pipeline_source &&
''')
helpers = '''function _runtime_is_ordinary_array_pipeline_operand(expression)
    return _runtime_is_ordinary_array_transform_operand(expression) &&
        !(expression isa ActionCallExpr &&
            canonical_action_helper_name(expression.name) in ("flat", "flat_array", "flat_hash"))
end

function _runtime_is_canonical_array_pipeline_arity(helper, count)
    helper in ("split_each", "filter_match") && return count == 2
    return helper in ("trim_each", "filter_nonempty", "lowercase_each", "uppercase_each", "uniq") && count == 1
end

function _runtime_is_ordinary_array_pipeline_arguments(helper, args, receiver=false)
    _runtime_is_canonical_array_pipeline_arity(helper, length(args) + Int(receiver)) || return false
    for (index, arg) in enumerate(args)
        arg isa ActionPositionalArgument || return false
        (_runtime_is_ordinary_array_pipeline_operand(arg.value) ||
            (helper in ("split_each", "filter_match") && index == length(args) &&
                arg.value isa ActionRegexLiteralExpr)) || return false
    end
    return true
end

function _runtime_is_ordinary_array_pipeline_receiver_call(call)
    return something(call.source_method, call.method) == call.method &&
        !call.trailing_block_arg && !call.receiver_trailing_block_arg &&
        _runtime_is_ordinary_array_pipeline_arguments(call.method, call.args, true)
end

# Canonical eager pipelines keep their source and regex policies. The existing
# single contextual with operand remains distinct from deferred callbacks.
function _runtime_is_ordinary_array_pipeline_result_chain(engine, receiver, calls)
    any(calls) do call
        helper = canonical_action_helper_name(call.method)
        ordinary_args = all(arg -> arg isa ActionPositionalArgument &&
            _runtime_is_ordinary_array_pipeline_operand(arg.value), call.args)
        helper in _RUNTIME_TREE_TRAVERSAL_NAMES ||
            !(ordinary_args || _runtime_is_ordinary_array_pipeline_receiver_call(call) ||
                (helper == "with" && length(call.args) == 1 &&
                    first(call.args) isa ActionPositionalArgument &&
                    first(call.args).value isa ActionCodeblockArgumentExpr)) ||
            ((call.trailing_block_arg || call.receiver_trailing_block_arg) && helper != "with") ||
            !(helper in _RUNTIME_PURE_HELPER_NAMES || helper in _RUNTIME_ARRAY_HELPER_NAMES ||
                helper in _RUNTIME_HASH_HELPER_NAMES ||
                helper in ("copy", "with", "and", "or", "not", "coalesce", "coalesce_nonempty"))
    end && return false
    if receiver isa ActionCallExpr
        has_user_function_name(engine.compiled_spec.function_registry, receiver.name) && return false
        if something(receiver.source_method, receiver.name) == receiver.name &&
            !receiver.trailing_block_arg &&
            _runtime_is_ordinary_array_pipeline_arguments(receiver.name, receiver.args)
            return true
        end
    end
    return _runtime_is_ordinary_array_pipeline_operand(receiver) && length(calls) > 1 &&
        _runtime_is_ordinary_array_pipeline_receiver_call(first(calls))
end

'''
replace_once('function _runtime_is_ordinary_array_transform_operand(expression)', helpers + 'function _runtime_is_ordinary_array_transform_operand(expression)')
assert text != original
if sys.argv[1:] == ['--check']:
    print('Read/construct-only rehearsal: canonical role/initial permission/common guard; scalar_result and loop/index policy unchanged')
else:
    assert not sys.argv[1:]
    OWNER.write_text(text)
    print('Installed canonical pipeline result ownership; producer and independent scalar/index policies unchanged')
