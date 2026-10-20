"""Compose a separate current reader/publisher; retain every previous actor and proposal."""
import ast
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-signature/'
F = c.PREFIX
preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
assert c.read(c.CLAIM) == preserved['original_claim']
assert json.loads((ROOT / (P + 'historical-final-review.json')).read_bytes())['result'] == 'PASS'
docs = json.loads(gzip.decompress((ROOT / (P + 'docs-proposals.json.gz')).read_bytes()))
assert c.unchanged(docs['after'])
entrypoint, readme_path = F + 'publish.py', F + 'README.md'
before = {path: c.read(path) for path in (entrypoint, readme_path)}
assert all(item == preserved['before'][path] for path, item in before.items())

records = (ROOT / (F + 'phase0_records_portable.py')).read_text()
anchor = '    assert c.unchanged(target)\n'
overlay = '''    preserved = signature_load('preservation.json.gz')
    first = signature_load('proposals.json.gz')
    assert first['producer'] == c.read(S + 'apply.py')
    assert c.read('t/phase0_regression.t') == first['phase0_after']
    for path, item in first['before'].items():
        expected = target.get(path, inputs.get(path, preserved['before'].get(path)))
        assert item == expected, path
    target.update(first['after'])
    fixed = signature_load('control-fix.json.gz')
    assert fixed['producer'] == c.read(S + 'fix_control.py')
    for path, item in fixed['before'].items():
        assert target[path] == item, path
    target.update(fixed['after'])
    docs = signature_load('docs-proposals.json.gz')
    assert docs['producer'] == c.read(S + 'docs.py')
    for path, item in docs['before'].items():
        assert item == target.get(path, original_graph.get(path)), path
    target.update(docs['after'])
    composed = signature_load('compose-proposals.json.gz')
    assert composed['producer'] == c.read(S + 'compose.py')
    assert c.unchanged(composed['after'])
    path = c.PREFIX + 'README.md'
    assert target[path] == composed['before'][path]
    target[path] = composed['after'][path]
    assert c.unchanged(target)
'''
assert records.count(anchor) == 1
records = records.replace(anchor, overlay, 1)
anchor = '            assert c.read(path) == item, path\n'
replacement = '''            if path == 'tests/language-readiness/verify_objectives.py':
                # The focused snapshot retains its original auditor. Its later
                # owned source-integrity inverse has independent complete proof.
                assert item == signature_load('proposals.json.gz')['before'][path]
                assert c.read(path) == signature_load('control-fix.json.gz')['after'][path]
            else:
                assert c.read(path) == item, path
'''
assert records.count(anchor) == 1
records = records.replace(anchor, replacement, 1)
records += '''

S = 'docs/checkpoints/type-values-signature/'


def signature_load(name):
    raw = (c.ROOT / (S + name)).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def verify_signature_history(fresh):
    preserved = signature_load('preservation.json.gz')
    first = signature_load('proposals.json.gz')
    fixed = signature_load('control-fix.json.gz')
    assert fixed['before'] == {'tests/language-readiness/verify_objectives.py':
                              first['after']['tests/language-readiness/verify_objectives.py']}
    assert c.unchanged(fixed['after'])
    failed = signature_load('historical-run.json.gz')['run']
    assert failed['returncode'] == 1 and b"KeyError: 'historical'" in c.decode(failed['stderr_base64'])
    original_inputs = signature_load('historical-inputs.json')
    assert original_inputs['current_auditor'] == first['after']['tests/language-readiness/verify_objectives.py']
    assert original_inputs['instrument'] == c.read(S + 'capture.py')
    for path, item in original_inputs['inputs'].items():
        expected = first['after'][path] if path == 'tests/language-readiness/verify_objectives.py' else c.read(path)
        assert all(expected[key] == item[key] for key in ('sha256', 'mode')), path
    plan = signature_load('historical-final-inputs.json')
    observed = signature_load('historical-final-run.json.gz')
    grade = signature_load('historical-final-review.json')
    assert grade['result'] == 'PASS' and grade['input_bytes_modes_unchanged']
    assert observed['producer'] == c.read(S + 'capture_corrected.py')
    assert plan['instrument'] == c.read(S + 'capture_corrected.py')
    for path, item in plan['inputs'].items():
        assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
    run = observed['run']
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    actual = json.loads(c.decode(run['stdout_base64']))
    assert set(actual['tracked_inputs']) == set(plan['proof_inputs'])
    assert all(actual['tracked_inputs'][path] == plan['inputs'][path]['sha256'] for path in plan['proof_inputs'])
    assert actual['isolated_deterministic_capture']
    assert actual['healthy_audit_guard'] == dict(original_log_attempts=0, tracked_write_attempts=0)
    assert actual['restored_inputs'] == grade['restored_inputs'] == 134
    assert actual['restored_bytes'] == grade['restored_bytes'] == 84613241
    assert len(actual['controls']) == grade['recovery_controls'] == 22
    assert grade['original_verifier_red'] == first['original_verifier_red'] == 'unreviewed signature-regression drift: t/phase0_regression.t'
    addition = 3 * first['hunks']
    assert grade['fragments'] == first['hunks'] == 70
    assert grade['added_source_denials'] == addition
    assert grade['original_controls'] == observed['baseline_controls']
    assert grade['current_controls'] == actual['audit_controls']
    assert grade['current_controls']['governance_mutations_rejected'] == grade['original_controls']['governance_mutations_rejected'] + addition
    for path, count in grade['original_controls']['governance_mutations_by_source'].items():
        assert grade['current_controls']['governance_mutations_by_source'][path] == count + (addition if path == 't/phase0_regression.t' else 0)
    fault = signature_load('table-final-control.json')
    table = (c.ROOT / 'tests/language-readiness/evaluated-value-regression-evolution.json').read_bytes()
    changed = c.decode(fault['changed_base64'])
    assert changed == table[:-1] + b' ' and table.endswith(b'\\n')
    assert json.loads(changed) == json.loads(table) and changed != table
    assert fault['observed_red'] == grade['table_identity_red'] == 'evaluated-value inverse table identity mismatch: t/phase0_regression.t'
    assert fault['producer'] == c.read(S + 'capture_corrected.py')
    if fresh:
        repeated = c.run(['bash', 'tools/run_python_project_data.sh',
            'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'])
        assert repeated['returncode'] == 0 and not c.decode(repeated['stderr_base64'])
        assert json.loads(c.decode(repeated['stdout_base64'])) == actual
        for path, item in plan['inputs'].items():
            assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
    return dict(result='PASS', fragments=grade['fragments'], added_denials=addition,
        original_denials=grade['original_controls']['governance_mutations_rejected'],
        current_denials=grade['current_controls']['governance_mutations_rejected'],
        restored_inputs=134, restored_bytes=84613241, recovery_controls=22,
        explicit_proof_inputs=len(plan['proof_inputs']), table_identity_red=True,
        first_control_key_error_retained=True)
'''
review = (ROOT / (F + 'review_portable.py')).read_text()
assert review.count('import phase0_records_portable as phase0_records') == 1
review = review.replace('import phase0_records_portable as phase0_records', 'import signature_records as phase0_records', 1)
review = review.replace('graph-phase0-', 'graph-signature-').replace('book-phase0-', 'book-signature-')
anchor = '    prior = replay_inventory.replay() if fresh else load(\'prior-after-run.json\')'
assert review.count(anchor) == 1
review = review.replace(anchor, '    historical = phase0_records.verify_signature_history(fresh)\n' + anchor, 1)
anchor = '        phase0=supplement, value_helper_red=129, null_value_control=1,'
assert review.count(anchor) == 1
review = review.replace(anchor, '        phase0=supplement, historical=historical, value_helper_red=129, null_value_control=1,', 1)
publisher = (ROOT / (F + 'publish_portable.py')).read_text()
publisher = publisher.replace('review_portable', 'review_signature').replace('phase0_records_portable', 'signature_records')
publisher = publisher.replace('publish_portable.py', 'publish_signature.py').replace('publication-portable', 'publication-signature')
publisher = publisher.replace('graph-phase0-', 'graph-signature-').replace('book-phase0-', 'book-signature-')
anchor = "    paths.update(('KNOWLEDGE_MAP.md', c.OLD_CLAIM,"
replacement = '''    signature = c.ROOT / 'docs/checkpoints/type-values-signature'
    paths.update(path.relative_to(c.ROOT).as_posix() for path in signature.iterdir() if path.is_file())
    paths.update(records.signature_load('historical-final-inputs.json')['inputs'])
''' + anchor
assert publisher.count(anchor) == 1
publisher = publisher.replace(anchor, replacement, 1)
old_guard = "(c.ROOT / 'docs/checkpoints/type-values-admission/preservation.json.gz').read_bytes()"
new_guard = "(c.ROOT / 'docs/checkpoints/type-values-signature/preservation.json.gz').read_bytes()"
assert publisher.count(old_guard) == 1
publisher = publisher.replace(old_guard, new_guard, 1)
start = publisher.index('def record_bytes(record):\n')
end = publisher.index('\ndef main():\n', start)
publisher = publisher[:start] + '''def record_bytes(record):
    raw = (json.dumps(record, separators=(',', ':')) + '\\n').encode()
    assert json.loads(raw) == record and len(raw) <= 131072, (len(raw), len(record['claims'][0]['durability']['inputs']))
    return raw

''' + publisher[end:]
anchor = '    graph = result[\'graph\']\n'
assert publisher.count(anchor) == 1
publisher = publisher.replace(anchor, anchor + "    historical = result['historical']\n", 1)
anchor = "            'single-key drop warns and fatal caller loading rejects; .1.2.6 owns that separate defect.'),"
replacement = """            'single-key drop warns and fatal caller loading rejects; .1.2.6 owns that separate defect. '
            f"The historical auditor reverses {historical['fragments']} reviewed Phase0 fragments; "
            f"{historical['original_denials']} original plus {historical['added_denials']} added source denials pass. "
            'Archive134/full84613241 and22 recovery controls retain zero original-log/tracked-write attempts. '
            'A semantic-JSON-preserving table byte fault rejects and the reader restores.'),"""
assert publisher.count(anchor) == 1
publisher = publisher.replace(anchor, replacement, 1)
anchor = "            'Canonical exact-staged receipt, ordinary all1035 and normal hooks are separately required before landing.'),"
replacement = """            'The whole649/full106855 draft, actual default readonly baseline and exact failed source candidate remain '
            'recoverable with original binding modes and mutable before bytes. Separate actors retain the first '
            'new-control KeyError and exact two-reference correction. The frozen focused snapshot retains its '
            'original auditor; current historical-auditor evolution is independently measured from184 declared '
            'proof inputs. Historical runtime observations, hashes and logs are unchanged. '
            'Canonical exact-staged receipt, ordinary all1035 and normal hooks are separately required before landing.'),"""
assert publisher.count(anchor) == 1
publisher = publisher.replace(anchor, replacement, 1)
anchor = "                'snapshot bytes/modes; complete current graph/book; whole prior publication.',"
assert publisher.count(anchor) == 1
publisher = publisher.replace(anchor, "                'snapshot bytes/modes; complete current graph/book; whole prior publication; exact historical source inverse and recovery controls.',", 1)
anchor = '    assert sys.argv[1:] in ([], [\'--capture\'])\n    capture = bool(sys.argv[1:])'
assert publisher.count(anchor) == 1
publisher = publisher.replace(anchor, "    assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])\n    capture = sys.argv[1:] == ['--capture']", 1)
anchor = "    if capture:\n        c.write_new(manifest_path,"
preflight = '''    if sys.argv[1:] == ['--preflight']:
        result = review.review(fresh=False)
        bindings = [dict(path=path, sha256=item['sha256'],
            role='producer' if Path(path).suffix in ('.py', '.pl', '.sh', '.t', '.pm') else 'input')
            for path, item in identities.items()]
        bindings.append(dict(path=manifest_path, sha256='0' * 64, role='input'))
        bindings.sort(key=lambda item: item['path'])
        raw = record_bytes(dict(version=1, owner=c.OWNER, claims=[make_claim(result, bindings)]))
        print('Publication format/input preflight PASS:', len(bindings), 'bindings;', len(raw), 'bytes')
        return
''' + anchor
assert publisher.count(anchor) == 1
publisher = publisher.replace(anchor, preflight, 1)
current = (ROOT / (F + 'current_phase0.py')).read_text().replace('current_phase0.py', 'current_signature.py')
current = current.replace('graph-phase0-', 'graph-signature-').replace('book-phase0-', 'book-signature-')
texts = {F + 'signature_records.py': records, F + 'review_signature.py': review,
    F + 'publish_signature.py': publisher, F + 'current_signature.py': current,
    entrypoint: '"""Stable readonly publication entrypoint; --capture is one-shot."""\nfrom publish_signature import main\n\nif __name__ == "__main__":\n    main()\n'}
for path, source in texts.items():
    ast.parse(source, filename=path)
    if path != entrypoint:
        assert not (ROOT / path).exists(), path
readme = c.decode(before[readme_path]['base64']).decode()
old = 'publication-phase0.json retains the third draft; publication-portable.json\nis the current receipt.'
new = ('publication-phase0.json and publication-portable.json retain earlier drafts;\n'
       'publication-signature.json is the current receipt.')
assert readme.count(old) == 1
readme = readme.replace(old, new, 1)
readme += ('\nThe historical-auditor prerequisite retains the whole649/full106855 draft\n'
    'and actual default readonly baseline before bound writes. Its exact owned\n'
    '70-fragment inverse recovers the complete original Phase0 bytes and hash.\n'
    'All368 original and210 added source controls pass;134 archived inputs and22\n'
    'recovery controls retain their original read/write boundary. The first new\n'
    'control loop KeyError and two-reference correction remain separate. Current\n'
    'historical proof inputs are explicit, including the inverse table; a valid-JSON\n'
    'whitespace identity fault rejects. The focused snapshot keeps its original\n'
    'auditor and all52 selected tests; historical-auditor evolution has independent\n'
    'complete proof. No old runtime observation, hash or log is refreshed.\n')
texts[readme_path] = readme
after = {path: dict(base64=c.encode(source.encode()), sha256=c.sha(source.encode()),
    mode=before[path]['mode'] if path in before else 0o644) for path, source in texts.items()}
c.write_new(P + 'compose-proposals.json.gz', dict(before=before, after=after,
    producer=c.read(P + 'compose.py'),
    original_records=c.read(F + 'phase0_records_portable.py'),
    original_review=c.read(F + 'review_portable.py'), original_publisher=c.read(F + 'publish_portable.py'),
    original_current=c.read(F + 'current_phase0.py'),
    scope='Separate actors retain every former producer. Current proposal and frozen-snapshot '
          'checks admit only the independently verified historical-auditor delta. Every explicit '
          'historical proof input remains a direct claim binding. Compact JSON preserves the '
          'unchanged131072-byte record cap; preflight checks it before fresh measurements.'), packed=True)
assert c.unchanged(before)
for path, item in after.items():
    (ROOT / path).write_bytes(c.decode(item['base64']))
    (ROOT / path).chmod(item['mode'])
    assert c.read(path) == item
print('Separate signature reader/publisher composed; prior actors and complete proposal chain retained')
