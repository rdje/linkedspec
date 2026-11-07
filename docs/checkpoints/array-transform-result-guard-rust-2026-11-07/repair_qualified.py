"""Add canonical Array result roles to the two persistent runtime guards."""
import difflib
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
OWNER = Path('rust/linkedspec-runtime/src/engine.rs')
before = OWNER.read_bytes()
assert not (BASE / 'owner-before.rs.gz').exists()
source = before.decode()
for guard, spaces in (('kind_guarded_source', 16), ('kind_guarded_value', 8)):
    indent = ' ' * spaces
    needle = indent + 'let hash_value_chain = self.is_ordinary_hash_value_result_chain(receiver, calls);'
    assert source.count('\n' + needle) == 1
    addition = '''let array_transform_chain = self.is_ordinary_array_transform_result_chain(receiver, calls);
let array_transform_source_prefix = array_transform_chain
    && !GUARD
    && !Self::is_ordinary_count_result_chain(receiver, &[])
    && !Self::is_ordinary_key_count_result_chain(receiver, &[])
    && !self.is_ordinary_hash_view_result_chain(receiver, &[])
    && !self.is_ordinary_hash_value_result_chain(receiver, &[])
    && !self.is_ordinary_array_transform_result_chain(receiver, &[])
    && calls.first().is_some_and(|first| {
        Self::is_ordinary_array_transform_result_call(&first.method, &first.args, true)
    });
// Preserve only the initial producer's source policy; its actual Array
// then owns consumers, before another helper can claim source permission.
GUARD |= array_transform_chain;
'''.replace('GUARD', guard)
    source = source.replace('\n' + needle, '\n' + ''.join(indent + line + '\n' for line in addition.splitlines()) + needle)
needle = '                    if hash_value_source_prefix\n'
assert source.count(needle) == 1
source = source.replace(needle, '                    if array_transform_source_prefix\n                        || hash_value_source_prefix\n')
needle = '                        || hash_value_source_prefix))'
assert source.count(needle) == 1
source = source.replace(needle, '                        || hash_value_source_prefix\n                        || array_transform_source_prefix))')
needle = '    fn is_ordinary_hash_value_result_call(\n'
assert source.count(needle) == 1
helper = '''    fn is_ordinary_array_transform_result_call(
        name: &str,
        args: &[linkedspec_core::expr::Arg],
        receiver: bool,
    ) -> bool {
        use linkedspec_core::expr::Arg;

        let count = args.len() + usize::from(receiver);
        let canonical_arity = match name {
            "take" | "take_last" | "drop_front" | "drop_back" => (1..=2).contains(&count),
            "slice" => (2..=3).contains(&count),
            "sorted" | "reversed" => count == 1,
            "concat_arrays" => count == 2,
            _ => false,
        };
        canonical_arity
            && args.iter().all(|arg| {
                matches!(arg, Arg::Positional(value)
                    if Self::is_ordinary_hash_value_operand(value)
                        && !matches!(value, Expr::Call { name, .. }
                            if matches!(name.as_str(), "flat" | "flat_array" | "flat_hash")))
            })
    }

    // Ordinary eager Array transforms share the existing typed value operand
    // boundary. Deferred/callback, traversal and unassessed function receivers
    // retain their original routes; variadic concat gains no new authority.
    fn is_ordinary_array_transform_result_chain(
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
                        call.method != "with" && !Self::is_ordinary_hash_value_operand(value)
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
            if Self::is_ordinary_array_transform_result_call(name, args, false) {
                return true;
            }
        }
        Self::is_ordinary_hash_value_operand(receiver)
            && calls.len() > 1
            && calls.first().is_some_and(|first| {
                Self::is_ordinary_array_transform_result_call(&first.method, &first.args, true)
            })
    }

'''
source = source.replace(needle, helper + needle)
(BASE / 'owner-before.rs.gz').write_bytes(gzip.compress(before, mtime=0))
OWNER.write_text(source)
(BASE / 'owner-unformatted.rs.gz').write_bytes(gzip.compress(OWNER.read_bytes(), mtime=0))
command = ['bash', 'tools/project_data_run.sh', 'rustfmt', '--edition', '2024', str(OWNER)]
(BASE / 'repair-format-command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('repair-format-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'repair-format-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0
patch = ''.join(difflib.unified_diff(before.decode().splitlines(True), OWNER.read_text().splitlines(True),
                                   fromfile=str(OWNER), tofile=str(OWNER)))
(BASE / 'source.patch.gz').write_bytes(gzip.compress(patch.encode(), mtime=0))
print('canonical Array result roles added; producer bodies and serialized format unchanged')
