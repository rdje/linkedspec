"""Derive finite compatibility goldens from real accepted historical test sources."""
import ast
import gzip
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'


def arguments(statement):
    """Split three Perl assertion arguments without parsing their expressions."""
    body = statement[statement.index('(') + 1:statement.rfind(')')]
    pieces, start, index, stack = [], 0, 0, []
    pairs = {'(': ')', '[': ']', '{': '}', '<': '>'}
    while index < len(body):
        char = body[index]
        quote = re.match(r'q(?:q|r)?([^\w\s])', body[index:]) if (
            index == 0 or not (body[index - 1].isalnum() or body[index - 1] == '_')) else None
        if char in ("'", '"') or quote:
            if quote:
                opening = quote[1]
                closing = pairs.get(opening, opening)
                index += len(quote[0])
            else:
                opening = closing = char
                index += 1
            depth = 1
            while depth:
                assert index < len(body), 'terminated quoted assertion argument'
                if body[index] == '\\':
                    index += 2
                    continue
                if opening != closing and body[index] == opening:
                    depth += 1
                elif body[index] == closing:
                    depth -= 1
                index += 1
            continue
        if char in '([{':
            stack.append(pairs[char])
        elif char in ')]}':
            assert stack and stack.pop() == char
        elif char == ',' and not stack:
            pieces.append(body[start:index].strip())
            start = index + 1
        index += 1
    pieces.append(body[start:].strip())
    if not pieces[-1]:
        pieces.pop()
    assert len(pieces) == 3, statement
    return pieces


STRUCTURAL = {
    'generated Perl host code still uses Perl fat-arrow syntax internally': r'\$meta\s*=\s*\{.*=>',
    'generated source assigns the lowered array shape into $items': r'\$items\s*=\s*\[',
    'generated source assigns the lowered hash shape into $meta': r'\$meta\s*=\s*\{',
    'explicit array target stores the lowered shape in the typed binding': r'\$items\s*=\s*\[',
    'explicit hash target stores the lowered shape in the typed binding': r'\$meta\s*=\s*\{',
    'generated source contains scalar-held typed values and receiver-chain lowering':
        r'\$items\s*=\s*\[.*\$meta\s*=\s*\{.*__ls_count',
    'generated source contains uniform typed values and mutation updates':
        r'(?=.*\$items\s*=\s*\[)(?=.*\$meta\s*=\s*\{)(?=.*\$items_mut\s*=\s*\[)'
        r'(?=.*BindingRuntime::push_value\(\$items_mut, "items_mut", "tail"\))'
        r'(?=.*\$meta_mut\s*=\s*\{)(?=.*\$__ls_path_value = \$other;.*BindingRuntime::nested_write\(\$meta_mut, .*"meta_mut")',
    'generated source stores shape payload in $payload': r'\$payload\s*=\s*\[',
    'generated source uses scalar-held values plus guarded array/hash views':
        r'\$items\s*=\s*\[.*\$meta\s*=\s*\{.*ref\(\$__ls_array_value\) eq \'ARRAY\'.*ref\(\$__ls_hash_value\) eq \'HASH\'',
}
IDENTITY = 'input_end_pos() lowers through the typed whole-input right-edge position projection'


def prepare():
    preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
    original_run = json.loads((ROOT / (P + 'original-run.json')).read_bytes())
    assert original_run['returncode'] == 1
    path = 't/phase0_regression.t'
    assert c.read(path) == preserved['before'][path]
    source = c.decode(preserved['before'][path]['base64']).decode()
    declarations = {}
    for node in ast.parse((ROOT / (P + 'align.py')).read_text()).body:
        if isinstance(node, ast.Assign) and isinstance(node.targets[0], ast.Name):
            if node.targets[0].id in ('pipeline', 'snapshot', 'projection', 'cases'):
                exec(compile(ast.Module(body=[node], type_ignores=[]), P + 'align.py', 'exec'), declarations)
    manual = {label: (setup, expected) for label, setup, expected in declarations['cases']}
    manual.update({
        'flat_hash(...) flattens a runtime-typed copied harray into surrounding hash constructors':
            ('my $meta = { kind => "token", source => "fixture" };', '{ kind => "node", source => "fixture" }'),
        'nested-write RHS accepts colon hash literals':
            ('my $meta = {}; my $key = "field"; my $value = "payload";', '{ field => { inner => "payload" } }'),
        'array append RHS accepts a shape literal value expression':
            ('my $items = []; my $value = "payload";', '[["payload"]]'),
        'nested-write assignment RHS accepts a hash shape literal':
            ('my $meta = {}; my $key = "field"; my $value = "payload";', '{ field => { field => "payload" } }'),
        'push(target, shape) is explicit append, not all-bare child-call routing':
            ('my $items = []; my $value = "payload";', '[["payload"]]'),
        'nested-write brackets stay statement syntax while RHS brackets are a value literal':
            ('my $meta = {}; my $key = "field"; my $value = "payload";', '{ field => ["payload"] }'),
        'array-shaped initialization makes later bare items read the scalar-held array value':
            ('my $items; my $value = "payload";', '["payload"]'),
        'hash-shaped initialization makes later bare meta read the scalar-held hash value':
            ('my $meta; my $key = "field"; my $value = "payload";', '{ field => "payload" }'),
    })
    for label, count in (
        ('double-quoted array wrapper argument remains a literal constructor payload', 1),
        ('single-quoted array wrapper argument remains a literal constructor payload', 1),
        ('multi-argument array(...) remains an array constructor', 2),
        ('double-quoted hash wrapper key remains a literal constructor payload', 1),
        ('single-quoted hash wrapper key remains a literal constructor payload', 1),
        ('multi-argument hash(...) remains a hash constructor', 1),
    ):
        manual[label] = ('', str(count))
    log = c.decode(original_run['combined_output_base64']).decode()
    assert 'Tests=1035' in log and 'Result: FAIL' in log
    failures = re.findall(r"^    #   Failed test '([^\n]*)'\n    #   at t/phase0_regression.t line (\d+)\.", log, re.M)
    cases, structural = [], []
    for label, line in failures:
        if label in ('isolated real-fallback suite passes', IDENTITY):
            continue
        marker = "'" + label + "'"
        assert source.count(marker) == 1, label
        end = source.index(marker)
        starts = list(re.finditer(r'^    (is|like)\(', source[:end], re.M))
        start, kind = starts[-1].start(), starts[-1][1]
        end = source.index(');', end) + 2
        old = source[start:end]
        actual, expected, message = arguments(old)
        row = dict(label=label, line=int(line), original_assertion=old, actual_expr=actual, message_expr=message)
        if label in STRUCTURAL:
            assert kind == 'like'
            row['pattern'] = STRUCTURAL[label]
            structural.append(row)
            continue
        if label in manual:
            row['setup'], row['manual_expected_perl'] = manual[label]
        if kind == 'is':
            assert re.match(r"""(?:q[^\w\s]|['"])""", expected), ('literal historical oracle', label, expected)
            row['historical_expected_expr'] = expected
        else:
            assert label in manual, ('independent manual oracle', label)
        cases.append(row)
    assert len(failures) == 141 and len(cases) == 130 and len(structural) == 9
    # A declared common fixture, augmented only with uninitialized target slots.
    definitions = {
        '%meta': '(kind => "token", source => "fixture")', '$meta': '{ %meta }',
        '%extra': '(source => "extra")', '$extra': '{ %extra }',
        '@parts': '(1, 3, 11)', '$parts': '[@parts]', '$items': '["alpha", "beta"]',
        '@IMATCH_LIST': '("alpha", "beta")', '@LMATCH_LIST': '("local", "groups")',
        '$retv': '{ content => undef, parts => undef, meta => undef }',
        '$raw_name': '" Node_fix.txt "', '$stage': '"parsed"', '$name': '"node"',
        '$key': '"kind"', '$value': '"payload"', '$text': '"entry"', '$STRING': r'\$text',
        '$info': '{}', '$IPOS': '0', '$LSPOS': '5', '$LMATCH': '""',
    }
    required = set()
    for row in cases:
        if 'setup' not in row:
            required.update(sigil + name for sigil, name in re.findall(r'([$@%])([A-Za-z_]\w*)', row['historical_expected_expr'])
                            if not name.startswith('__ls_') and name not in ('a', 'b', '_'))
    common = '\n'.join('my ' + slot + ' = ' + value + ';' for slot, value in definitions.items()) + '\n'
    common += '\n'.join('my ' + slot + ';' for slot in sorted(required - definitions.keys()))
    for row in cases:
        row.setdefault('setup', common)
    return dict(cases=cases, structural=structural, identity_label=IDENTITY,
                common_setup=common, original_source=preserved['before'][path])


if __name__ == '__main__':
    assert sys.argv[1:] == []
    plan = prepare()
    source = json.loads(gzip.decompress((ROOT / (c.PREFIX + 'final-inputs.json.gz')).read_bytes()))['inputs']
    runtime = {path: item for path, item in source.items() if path.startswith('perl/')}
    assert c.unchanged(runtime)
    plan.update(producer=c.read(P + 'oracle_final.py'), actor=c.read(P + 'oracle_final.pl'),
        declarative_draft=c.read(P + 'align.py'), original_run=c.read(P + 'original-run.json'),
        runtime_identities={path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in runtime.items()},
        scope='130 finite compatibility values derive from106 literal accepted historical test sources '
              'and24 manual regex-case expectations under explicit caller fixtures. Nine generated-source '
              'binding/API purposes and one public input-position identity stay separate. Candidate '
              'lowering is never used to derive goldens; no exhaustive behavior admission.')
    c.write_new(P + 'oracle-final-inputs.json.gz', plan, packed=True)
    run = c.run(['perl', '-Iperl', P + 'oracle_final.pl'], input=json.dumps(plan).encode())
    c.write_new(P + 'oracle-final-run.json.gz', dict(run=run, runtime_inputs_unchanged=c.unchanged(runtime)), packed=True)
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64']), ('oracle actor failed; see retained channels', run['returncode'])
    rows = json.loads(c.decode(run['stdout_base64']))['rows']
    assert len(rows) == 130 and all(row['error'] is None for row in rows)
    print('Historical/manual finite value oracles PASS:', len(rows))
