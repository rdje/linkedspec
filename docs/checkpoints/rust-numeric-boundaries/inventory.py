"""Retain the textual conversion census; it is not a semantic coverage claim."""
import subprocess
import common as c


def main():
    paths = [path for path in subprocess.check_output(
        ['git', 'ls-files', 'rust'], cwd=c.ROOT, text=True).splitlines() if path.endswith('.rs')]
    supplied = c.context()
    c.save('conversion-census-inputs.json.gz', dict(context=supplied, rust_files=paths,
        scope='Whole current tracked first-party Rust population and actual search producer before numeric edits. Textual matches guide the manual consumer audit; a match alone is not a reachable defect, complete type-resolved call graph or execution proof.'))
    queries = {
        'integer-casts': r'\bas (i64|u64|usize|isize|i128|u128)\b',
        'numeric-projections': r'\.to_json\(|\.to_str\(|\.to_scalar_text\(|runtime_value_from_json|RuntimeValue::Number',
        'serde-and-length': r'serde_json::(to_|from_)|\.len\(\)',
        'strict-fields': r'fn usize_field|usize_field\(|literal_usize_arg|classify_write_path_segments|parse_staged_direct_text_plan',
    }
    runs = {}
    for name, pattern in queries.items():
        result = c.run(['rg', '-n', '--', pattern, *paths])
        assert result['returncode'] == 0
        runs[name] = result
    stable = c.unchanged(supplied['inputs'])
    c.save('conversion-census.json.gz', dict(queries=queries, runs=runs, inputs_unchanged=stable))
    assert stable
    print('Conversion census retained:', len(paths), 'first-party Rust files; four textual query populations, no new execution-failure inference.')


if __name__ == '__main__':
    main()
