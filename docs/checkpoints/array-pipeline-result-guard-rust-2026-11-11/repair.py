"""Line-anchored, asserted Rust pipeline-role repair; --check never writes."""
import gzip
from pathlib import Path
import re
import sys

BASE = Path(__file__).resolve().parent
OWNER = Path('rust/linkedspec-runtime/src/engine.rs')
original = gzip.decompress((BASE / 'owner-before.rs.gz').read_bytes()).decode()
assert OWNER.read_text() == original
text = original
for indent, guarded in ((16, 'kind_guarded_source'), (8, 'kind_guarded_value')):
    pad = ' ' * indent
    anchor = pad + 'let array_transform_chain ='
    matches = list(re.finditer('^' + re.escape(anchor), text, re.M))
    assert len(matches) == 1
    block = f'''{pad}let array_pipeline_chain =
{pad}    self.is_ordinary_array_pipeline_result_chain(receiver, calls);
{pad}let array_pipeline_source_prefix = array_pipeline_chain
{pad}    && !{guarded}
{pad}    && !Self::is_ordinary_count_result_chain(receiver, &[])
{pad}    && !Self::is_ordinary_key_count_result_chain(receiver, &[])
{pad}    && !self.is_ordinary_hash_view_result_chain(receiver, &[])
{pad}    && !self.is_ordinary_hash_value_result_chain(receiver, &[])
{pad}    && !self.is_ordinary_array_transform_result_chain(receiver, &[])
{pad}    && !self.is_ordinary_array_pipeline_result_chain(receiver, &[])
{pad}    && calls.first().is_some_and(|first| {{
{pad}        Self::is_ordinary_array_pipeline_result_call(&first.method, &first.args, true)
{pad}    }});
{pad}// Keep the first pipeline's source fallback; its Array owns later guards.
{pad}{guarded} |= array_pipeline_chain;
'''
    position = matches[0].start()
    text = text[:position] + block + text[position:]
text, count = re.subn(r'(?m)^(\s*)if array_transform_source_prefix$',
                      r'\1if array_pipeline_source_prefix\n\1    || array_transform_source_prefix', text)
assert count == 1
text, count = re.subn(r'(?m)^(\s*)\|\| array_transform_source_prefix\)\)$',
                      r'\1|| array_transform_source_prefix\n\1|| array_pipeline_source_prefix))', text)
assert count == 1
anchor = '    fn is_ordinary_array_transform_result_call('
assert text.count(anchor) == 1
helpers = '''    fn is_ordinary_array_pipeline_result_call(
        name: &str,
        args: &[linkedspec_core::expr::Arg],
        receiver: bool,
    ) -> bool {
        use linkedspec_core::expr::Arg;

        let count = args.len() + usize::from(receiver);
        let canonical_arity = match name {
            "split_each" | "filter_match" => count == 2,
            "trim_each" | "filter_nonempty" | "lowercase_each" | "uppercase_each" | "uniq" => {
                count == 1
            }
            _ => false,
        };
        canonical_arity
            && args.iter().enumerate().all(|(index, arg)| {
                matches!(arg, Arg::Positional(value)
                    if (Self::is_ordinary_hash_value_operand(value)
                        || (matches!(name, "split_each" | "filter_match")
                            && index + 1 == args.len()
                            && matches!(value, Expr::RegexLiteral { .. })))
                        && !matches!(value, Expr::Call { name, .. }
                            if matches!(name.as_str(), "flat" | "flat_array" | "flat_hash")))
            })
    }

    // Pure eager pipelines keep their existing source and regex policies. Only
    // canonical positional values/prefixes gain persistent actual-kind guards.
    fn is_ordinary_array_pipeline_result_chain(
        &self,
        receiver: &Expr,
        calls: &[linkedspec_core::expr::FluentCall],
    ) -> bool {
        use linkedspec_core::expr::Arg;

        if calls.iter().any(|call| {
            Self::is_tree_traversal_receiver_method(&call.method)
                || call.args.iter().any(|arg| match arg {
                    Arg::Keyword { .. } => true,
                    Arg::Positional(value) => {
                        call.method != "with"
                            && !Self::is_ordinary_hash_value_operand(value)
                            && !(matches!(value, Expr::RegexLiteral { .. })
                                && Self::is_ordinary_array_pipeline_result_call(
                                    &call.method,
                                    &call.args,
                                    true,
                                ))
                    }
                })
                || !(Self::is_generic_receiver_value_method(&call.method)
                    || Self::is_array_receiver_value_chain_method(&call.method)
                    || Self::is_hash_receiver_value_chain_method(&call.method)
                    || Self::is_string_receiver_value_chain_method(&call.method)
                    || Self::is_number_receiver_value_chain_method(&call.method)
                    || Self::is_receiver_with_trailing_block_call(call))
        }) {
            return false;
        }
        if let Expr::Call { name, args } = receiver {
            if self.spec.find_function(name).is_some() {
                return false;
            }
            if Self::is_ordinary_array_pipeline_result_call(name, args, false) {
                return true;
            }
        }
        Self::is_ordinary_hash_value_operand(receiver)
            && calls.len() > 1
            && calls.first().is_some_and(|first| {
                Self::is_ordinary_array_pipeline_result_call(&first.method, &first.args, true)
            })
    }

'''
text = text.replace(anchor, helpers + anchor)
assert text != original
if sys.argv[1:] == ['--check']:
    print('Read/construct-only repair rehearsal: two anchored roles and two guards')
else:
    assert not sys.argv[1:]
    OWNER.write_text(text)
    print('Installed two ordinary pipeline roles; producer bodies/formats unchanged')
