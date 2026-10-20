"""Exercise actual scanner classification with independent exact-byte/path controls."""
import gzip
import json
import os
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-selector/'
proposal = json.loads(gzip.decompress((ROOT / (P + 'proposals.json.gz')).read_bytes()))
scanner = 'tools/check_executable_aggregate_selector_sources.py'
variant = sys.argv[1] if len(sys.argv) == 2 else 'healthy'
assert variant in ('healthy', 'drop-current', 'drop-prior', 'drop-owner')
source = c.decode(proposal['after'][scanner]['base64'])
needles = {
    'drop-current': b'                and evolved[2] == digest)',
    'drop-prior': b'                and evolved[1] == historical_digest\n',
    'drop-owner': b"                and evolved[0] == 'TYPE-REFERENCE-BOOK.1.2.3'\n",
}
if variant != 'healthy':
    needle = needles[variant]
    assert source.count(needle) == 1
    source = source.replace(needle, b'                )' if variant == 'drop-current' else b'', 1)
rows = []
with tempfile.TemporaryDirectory(prefix='selector-admissions-', dir=os.environ['TMPDIR']) as directory:
    root = Path(directory)
    assert root.stat().st_dev == ROOT.stat().st_dev
    target = root / scanner
    target.parent.mkdir(parents=True)
    target.write_bytes(source)
    namespace = dict(__file__=str(target), __name__='selector_admission_probe')
    exec(compile(source, scanner, 'exec'), namespace)
    original_registry = dict(namespace['HISTORICAL_DIAGNOSTIC_INPUTS'])
    reviewed = dict(namespace['REVIEWED_DIAGNOSTIC_EVOLUTIONS'])
    for path, fixture in proposal['fixtures'].items():
        original = c.decode(fixture['original']['stdout_base64'])
        current = c.decode(fixture['current']['base64'])
        item = root / path
        item.parent.mkdir(parents=True, exist_ok=True)
        for case in ('original', 'current', 'comment-edit', 'appended-selector', 'copied-path',
                     'missing-reviewed', 'wrong-owner', 'wrong-prior', 'wrong-current',
                     'missing-historical', 'wrong-historical'):
            namespace['HISTORICAL_DIAGNOSTIC_INPUTS'] = dict(original_registry)
            namespace['REVIEWED_DIAGNOSTIC_EVOLUTIONS'] = dict(reviewed)
            selected = path
            data = original if case == 'original' else current
            if case == 'comment-edit':
                data += b'\n# an unrelated edit must not inherit admission\n'
            if case == 'appended-selector':
                data += b'\n' + b'array' + b'(new_public_input)' + b';\n'
            if case == 'copied-path':
                selected = 't/copied_diagnostic.t'
            if case == 'missing-reviewed':
                del namespace['REVIEWED_DIAGNOSTIC_EVOLUTIONS'][path]
            if case.startswith('wrong-') and case.removeprefix('wrong-') in ('owner', 'prior', 'current'):
                values = list(reviewed[path])
                index = ('owner', 'prior', 'current').index(case.removeprefix('wrong-'))
                values[index] = 'FOREIGN.1' if index == 0 else '0' * 64
                namespace['REVIEWED_DIAGNOSTIC_EVOLUTIONS'][path] = tuple(values)
            if case == 'missing-historical':
                del namespace['HISTORICAL_DIAGNOSTIC_INPUTS'][path]
            if case == 'wrong-historical':
                namespace['HISTORICAL_DIAGNOSTIC_INPUTS'][path] = '0' * 64
            selected_path = root / selected
            selected_path.write_bytes(data)
            selected_path.chmod(fixture['current']['mode'])
            positive, classified = namespace['scan_files']([selected])
            expected_rejection = case not in ('original', 'current')
            rows.append(dict(path=path, case=case, rejected=bool(positive),
                             expected_rejection=expected_rejection, classified=classified))
    ordinary = 'ordinary_public.py'
    (root / ordinary).write_bytes(b'array' + b'(items)' + b'\n')
    positive, classified = namespace['scan_files']([ordinary])
    rows.append(dict(path=ordinary, case='ordinary-positive', rejected=bool(positive),
                     expected_rejection=True, classified=classified))
unexpected = [dict(path=row['path'], case=row['case']) for row in rows
              if row['rejected'] != row['expected_rejection']]
print(json.dumps(dict(variant=variant, source_sha256=c.sha(source), rows=rows,
    unexpected=unexpected, healthy_controls=sum(not row['expected_rejection'] for row in rows),
    rejection_controls=sum(row['expected_rejection'] for row in rows)), sort_keys=True))
sys.exit(bool(unexpected))
