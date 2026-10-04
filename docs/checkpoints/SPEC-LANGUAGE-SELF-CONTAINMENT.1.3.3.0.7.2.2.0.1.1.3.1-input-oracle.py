"""Independently gate capsule content, Git membership and complete TAP evidence."""
from pathlib import Path, PurePosixPath
import ast
import base64
import copy
import gzip
import hashlib
import io
import json
import re
import stat
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('input-oracle.py')
BASE = '3fc589f8494fd55b4f0154d6c226797a4fa2f711'
BOOK_OVERLAY = 'docs/linkedspec-book/src/development/documentation-workflow.md'


def check(condition, reason):
    if not condition:
        raise ValueError(reason)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def unpack(envelope):
    check(envelope['encoding'] == 'gzip-base64', 'stream encoding')
    data = gzip.decompress(base64.b64decode(envelope['data'], validate=True))
    check(len(data) == envelope['bytes'] and sha(data) == envelope['sha256'], 'stream byte identity')
    return data


def envelope(data):
    return {'encoding': 'gzip-base64', 'bytes': len(data), 'sha256': sha(data),
            'data': base64.b64encode(gzip.compress(data, mtime=0)).decode()}


def read_capsule(raw):
    files = {}
    with tarfile.open(fileobj=io.BytesIO(raw), mode='r:gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            check(member.isfile() and not path.is_absolute() and '..' not in path.parts
                  and str(path) == member.name, 'unsafe capsule entry')
            check(member.name not in files, 'duplicate capsule entry')
            files[member.name] = archive.extractfile(member).read()
    return files


def verify_capsule(plan, manifest, files):
    check(plan['revision'] == manifest['revision'] == BASE, 'immutable Git boundary')
    check(plan['overlays'] == [BOOK_OVERLAY], 'exact declared candidate overlay')
    required = {'perl', 'specs', 't', 'tests', 'examples', 'conf', 'tablescript', 'ebnf',
                'capability_conformance', 'tools', 'docs/linkedspec-book'}
    check(required.issubset(plan['roots']), 'required transitive input trees')
    check(set(['docs/checkpoints/SESSION-STARTUP-READING.87.2-cases.json', 'docs/checkpoints/SESSION-STARTUP-READING.87.2-probe.pl', 'docs/checkpoints/SESSION-STARTUP-READING.87.2-fresh.pl', 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm']).issubset(plan.get('checkpoint_paths', [])), 'required matches checkpoint input closure')
    # Independent census reads Git metadata, not the preparer's selected rows.
    git_rows = subprocess.check_output(['git', 'ls-tree', '-rz', BASE], cwd=ROOT)
    expected = {}
    for row in filter(None, git_rows.split(b'\0')):
        meta, path_bytes = row.split(b'\t', 1)
        mode, kind, oid = meta.decode().split()
        path = path_bytes.decode()
        boundary = '/' not in path or any(path == root or path.startswith(root + '/') for root in plan['roots'])
        checkpoint = path in plan.get('checkpoint_paths', []) or any(path.startswith(prefix) for prefix in plan['checkpoint_prefixes'])
        if kind == 'blob' and (boundary or checkpoint):
            check(mode in ('100644', '100755'), 'selected non-regular Git input')
            expected[path] = (mode, oid)
    check(set(files) == set(expected), 'capsule directory population')
    entries = manifest['entries']
    check(len(entries) == len(expected) and {entry['path'] for entry in entries} == set(expected), 'manifest directory population')
    for entry in entries:
        path = entry['path']
        data = files[path]
        mode, oid = expected[path]
        check(entry['mode'] == mode and entry['kind'] == 'blob', 'Git input type ' + path)
        check(entry['bytes'] == len(data) and entry['sha256'] == sha(data), 'input byte identity ' + path)
        content_oid = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
        check(entry['oid'] == content_oid, 'input Git object identity ' + path)
        if path in plan['overlays']:
            check(entry.get('base_oid') == oid, 'overlay original Git identity')
        else:
            check(entry['oid'] == oid and 'base_oid' not in entry, 'immutable source owner ' + path)
    # Derive the suite population from the retained actual original producer.
    producer = files['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-consumers.py']
    tree = ast.parse(producer)
    tests = next(ast.literal_eval(node.value) for node in tree.body if isinstance(node, ast.Assign)
                 and any(isinstance(target, ast.Name) and target.id == 'tests' for target in node.targets))
    check(plan['tests'] == tests, 'original selected consumer population')
    for path, literal, role in plan['graph_sentinels']:
        check(literal in files[path].decode(), 'source-backed input edge ' + role)
    return {'files': len(files), 'input_bytes': sum(map(len, files.values())), 'suites': len(tests)}


def verify_tree(tree, manifest):
    expected = {entry['path']: entry for entry in manifest['entries']}
    actual = set()
    for path in tree.rglob('*'):
        relative = path.relative_to(tree).as_posix()
        if relative == '.linkedspec-data' or relative.startswith('.linkedspec-data/') or relative.startswith('docs/linkedspec-book/book/'):
            continue
        check(not path.is_symlink(), 'input tree symlink ' + relative)
        if path.is_file():
            actual.add(relative)
    check(actual == set(expected), 'runtime input directory population')
    for path, entry in expected.items():
        data = (tree / path).read_bytes()
        check(len(data) == entry['bytes'] and sha(data) == entry['sha256'], 'runtime input byte identity ' + path)
        check(stat.S_IMODE((tree / path).stat().st_mode) == int(entry['mode'][-3:], 8), 'runtime input mode ' + path)
    return len(expected)


def verify_tap(row):
    text = unpack(row['stdout']).decode()
    unpack(row['stderr'])
    check(row['exit'] == 0, 'consumer successful exit ' + row['test'])
    check(not re.search(r'^\s*(?:not ok\b|Bail out!)', text, re.M), 'consumer failing TAP ' + row['test'])
    plans = re.findall(r'^1\.\.(\d+)\s*$', text, re.M)
    check(len(plans) == 1 and int(plans[0]) > 0, 'consumer complete positive plan ' + row['test'])
    count = int(plans[0])
    reached = [int(number) for number in re.findall(r'^ok (\d+)\b', text, re.M)]
    check(reached == list(range(1, count + 1)), 'consumer complete ordered reach ' + row['test'])
    check('All tests successful.' in text and 'Result: PASS' in text, 'prove final success marker ' + row['test'])
    return count


def main():
    plan = json.loads(Path(PREFIX + 'plan.json').read_bytes())
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    capsule = Path(PREFIX + 'inputs.tar.gz').read_bytes()
    check(sha(capsule) == manifest['capsule_sha256'], 'capsule byte identity')
    files = read_capsule(capsule)
    summary = verify_capsule(plan, manifest, files)
    check(files[BOOK_OVERLAY] == (ROOT / BOOK_OVERLAY).read_bytes(), 'actual declared candidate overlay bytes')
    graph = json.loads(Path(PREFIX + 'input-graph.json').read_bytes())
    check(graph['revision'] == BASE, 'input graph Git boundary')
    for site in graph['source_related_sites']:
        check(files[site['path']].decode().splitlines()[site['line'] - 1] == site['source'], 'retained exact reader site')
    check(len(graph['required_input_edges']) == len(plan['graph_sentinels']), 'all named source-backed input edges')
    original = json.loads((ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-consumers.json').read_bytes())
    check([row['test'] for row in original['rows']] == plan['tests'], 'original observed suite population')
    summary['original_observed_tests'] = sum(verify_tap(row) for row in original['rows'])
    summary['original_boundary_limit'] = 'Original passing channels only; this review does not recover their unretained transitive live input bytes. New full execution belongs to .3.1.'
    controls = []

    def reject(name, reason, mutation):
        altered_plan, altered_manifest, altered_files = copy.deepcopy((plan, manifest, files))
        mutation(altered_plan, altered_manifest, altered_files)
        try:
            verify_capsule(altered_plan, altered_manifest, altered_files)
        except ValueError as error:
            check(reason in str(error), 'control rejected for wrong reason ' + name)
            controls.append({'name': name, 'reason': str(error), 'rejected': True})
        else:
            raise ValueError('unrejected capsule control ' + name)

    reject('omit_transitive_contract_json', 'capsule directory population',
           lambda p, m, f: f.pop('tests/lispish/quoted-newlines.json'))
    corpus = next(path for path in files if path.startswith('conf/') and path.endswith('.conf'))
    reject('change_discovered_corpus_bytes', 'input byte identity', lambda p, m, f: f.update({corpus: f[corpus] + b'changed'}))
    reject('drop_discovered_corpus_member_and_manifest_row', 'capsule directory population',
           lambda p, m, f: (f.pop(corpus), m.update(entries=[entry for entry in m['entries'] if entry['path'] != corpus])))
    reject('change_nested_consumer', 'input byte identity',
           lambda p, m, f: f.update({'t/staged_ast_enrichment_perl_contract.t': b'changed'}))
    reject('change_frozen_continuity_document', 'input byte identity', lambda p, m, f: f.update({'MEMORY.md': b'changed'}))
    reject('add_unretained_input', 'capsule directory population', lambda p, m, f: f.update({'conf/unretained.conf': b'new'}))
    reject('drop_required_tree_selection', 'required transitive input trees', lambda p, m, f: p['roots'].remove('conf'))
    reject('relabel_live_Git_boundary', 'immutable Git boundary', lambda p, m, f: p.update(revision='HEAD'))
    reject('forge_bytes_and_hash_for_source_owner', 'immutable source owner',
           lambda p, m, f: forge_input(m, f, 'perl/LinkedSpec.pm'))
    bad = io.BytesIO()
    with tarfile.open(fileobj=bad, mode='w:gz') as archive:
        item = tarfile.TarInfo('../escape'); item.size = 1
        archive.addfile(item, io.BytesIO(b'x'))
    try:
        read_capsule(bad.getvalue())
    except ValueError as error:
        check(str(error) == 'unsafe capsule entry', 'unsafe archive rejection reason')
        controls.append({'name': 'unsafe_archive_path', 'reason': str(error), 'rejected': True})
    else:
        raise ValueError('unsafe archive accepted')
    first = original['rows'][0]
    raw = unpack(first['stdout'])
    tap_controls = [
        ('missing_final_plan', 'consumer complete positive plan', re.sub(rb'^1\.\.\d+\s*$', b'', raw, flags=re.M)),
        ('missing_planned_result', 'consumer complete ordered reach', re.sub(rb'^ok 2\b[^\n]*\n', b'', raw, count=1, flags=re.M)),
        ('failed_top_level_result', 'consumer failing TAP', re.sub(rb'^ok 1\b', b'not ok 1', raw, count=1, flags=re.M)),
        ('failed_nested_result', 'consumer failing TAP', re.sub(rb'^( +)ok 1\b', rb'\1not ok 1', raw, count=1, flags=re.M)),
        ('missing_prove_final_marker', 'prove final success marker', raw.replace(b'Result: PASS', b'Result: UNKNOWN')),
    ]
    for name, reason, changed in tap_controls:
        check(changed != raw, 'actual altered TAP ' + name)
        row = copy.deepcopy(first)
        row['stdout'] = envelope(changed)
        try:
            verify_tap(row)
        except ValueError as error:
            check(reason in str(error), 'TAP control rejected for wrong reason ' + name)
            controls.append({'name': name, 'reason': str(error), 'rejected': True})
        else:
            raise ValueError('unrejected TAP control ' + name)
    report = {'summary': summary, 'source_related_sites': len(graph['source_related_sites']),
              'named_input_edges': len(graph['required_input_edges']), 'controls': controls}
    Path(PREFIX + 'input-verification.json').write_text(json.dumps(report, indent=2) + '\n')
    print(f"PASS {summary['files']} exact frozen inputs, {len(controls)} reason-checked input controls; original TAP remains observations only")


def forge_input(manifest, files, path):
    files[path] += b'\n# forged owner\n'
    entry = next(entry for entry in manifest['entries'] if entry['path'] == path)
    entry.update(bytes=len(files[path]), sha256=sha(files[path]),
                 oid=hashlib.sha1(b'blob ' + str(len(files[path])).encode() + b'\0' + files[path]).hexdigest())


if __name__ == '__main__':
    main()
