"""Compose the recurring-consumer epoch without changing previous measured actors."""
import ast
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P, F = 'docs/checkpoints/type-values-required/', c.PREFIX
preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
assert c.read(c.CLAIM) == preserved['original_claim']
assert json.loads((ROOT / (P + 'controls-complete-review.json')).read_bytes())['result'] == 'PASS'
before = {F + name: c.read(F + name) for name in ('publish.py', 'README.md')}
assert all(item == preserved['before'][path] for path, item in before.items())
records = (ROOT / (F + 'signature_records.py')).read_text()
needle = '    assert c.unchanged(current_sources)\n'
replacement = '''    required_composed = required_load('compose-proposals.json.gz')
    assert required_composed['producer'] == c.read(R + 'compose.py')
    for path, item in required_composed['before'].items():
        assert current_sources[path] == item, path
    current_sources.update(required_composed['after'])
    assert c.unchanged(current_sources)
'''
assert records.count(needle) == 1
records = records.replace(needle, replacement, 1)
needle = '    assert c.unchanged(target)\n    return target\n'
replacement = '''    for name, producer in (('proposals.json.gz', 'apply.py'),
                           ('source-fix.json.gz', 'fix_source.py'),
                           ('docs-proposals.json.gz', 'docs.py')):
        change = required_load(name)
        assert change['producer'] == c.read(R + producer)
        for path, item in change['before'].items():
            assert item == target.get(path, inputs.get(path, original_graph.get(path))), path
        target.update(change['after'])
    assert c.unchanged(target)
    return target
'''
assert records.count(needle) == 1
records = records.replace(needle, replacement, 1)
needle = '            else:\n                assert c.read(path) == item, path\n'
replacement = '''            elif path in required_load('proposals.json.gz')['before']:
                first = required_load('proposals.json.gz')
                fixed = required_load('source-fix.json.gz')
                assert item == first['before'][path], path
                assert c.read(path) == fixed['after'].get(path, first['after'][path]), path
            else:
                assert c.read(path) == item, path
'''
assert records.count(needle) == 1
records = records.replace(needle, replacement, 1)
records += '''

R = 'docs/checkpoints/type-values-required/'
sys_path = str(c.ROOT / R)
import sys
sys.path.insert(0, sys_path)
import capsules
required_load = capsules.load


def verify_required(fresh):
    preserved = required_load('preservation.json.gz')
    baseline = required_load('baseline.json')
    assert baseline['returncode'] == 0 and baseline['claim'] == preserved['original_claim']
    original = json.loads(c.decode(preserved['original_claim']['base64']))
    assert len(original['claims'][0]['durability']['inputs']) == 823
    assert preserved['canonical']['returncode'] == 1
    first = required_load('proposals.json.gz')
    assert c.read('perl/LinkedSpec/ActionIR/MethodLowering.pm') == first['current_module']
    failed = required_load('focused-run.json.gz')
    assert failed['run']['returncode'] == 1
    assert len(re.findall(r'^not ok \\d+', c.decode(failed['run']['stdout_base64']).decode(), re.M)) == 3
    final = required_load('focused-final-run.json.gz')
    assert final['run']['returncode'] == 0 and final['inputs_bytes_modes_unchanged']
    assert 'Files=12, Tests=5001,' in c.decode(final['run']['stdout_base64']).decode()
    controls = required_load('controls-complete-run.json.gz')
    grade = required_load('controls-complete-review.json')
    plan = required_load('controls-complete-inputs.json.gz')
    assert grade['result'] == 'PASS' and grade['native_inputs'] == 15
    assert controls['producer'] == c.read(R + 'control_capture_complete.py')
    assert controls['main_inputs_bytes_modes_unchanged']
    assert controls['controls']['returncode'] == 0
    assert '1..14' in c.decode(controls['controls']['stdout_base64']).decode()
    assert [row['name'] for row in controls['runs']] == ['healthy', 'mapper-bypass', 'restored']
    assert [row['returncode'] for row in controls['runs']] == [0, 1, 0]
    for row in controls['runs']:
        assert row['supplied_bytes_modes_unchanged']
        text = c.decode(row['stdout_base64']).decode()
        assert 'Files=12, Tests=5001,' in text
        failures = len(re.findall(r'^not ok \\d+', text, re.M))
        assert failures == (198 if row['name'] == 'mapper-bypass' else 0)
    assert grade['mapper_bypass_failed_assertions'] == 198
    assert c.sha(c.decode(plan['fault']['base64'])) == plan['fault']['sha256']
    for path, item in plan['inputs'].items():
        assert c.sha(c.decode(item['base64'])) == item['sha256'], path
        assert capsules.read_version(path, item) == item, path
    recovery = required_load('capsule-recovery.json')
    assert recovery['result'] == 'PASS' and len(recovery['rows']) == 2
    for row in recovery['rows']:
        assert capsules.read_version(row['path'], row)['sha256'] == row['sha256']
    closure = required_load('closure.json')
    for path, item in closure['inputs'].items():
        assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
    if fresh:
        repeated = c.run(['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=',
                         'prove', '-v', '-Iperl'] + plan['selected'])
        assert repeated['returncode'] == 0
        assert 'Files=12, Tests=5001,' in c.decode(repeated['stdout_base64']).decode()
        native = c.run(['bash', 'tools/project_data_run.sh', 'perl', '-Iperl', R + 'controls_final.pl'])
        assert native['returncode'] == 0 and '1..14' in c.decode(native['stdout_base64']).decode()
    return dict(result='PASS', files=12, assertions=5001, native_controls=14,
                mapper_red=198, frozen_native_inputs=15, prior_direct_inputs=823,
                scope='Original4998 plus3 goldens; full supplied healthy/fault/restored '
                      'execution. First incomplete closure/control and census guard remain '
                      'rejected preparation. New support inputs have a closed hash manifest; '
                      'all823 previous direct bindings remain. No native capture refresh.')
'''
review = (ROOT / (F + 'review_signature.py')).read_text()
review = review.replace('import signature_records as phase0_records', 'import required_records as phase0_records')
review = review.replace('import current_signature as current', 'import current_required as current')
review = review.replace('graph-signature-', 'graph-required-').replace('book-signature-', 'book-required-')
needle = '    historical = phase0_records.verify_signature_history(fresh)\n'
assert review.count(needle) == 1
review = review.replace(needle, needle + '    required = phase0_records.verify_required(fresh)\n', 1)
review = review.replace('phase0=supplement, historical=historical,', 'phase0=supplement, historical=historical, required=required,', 1)
publisher = (ROOT / (F + 'publish_signature.py')).read_text()
publisher = publisher.replace('review_signature', 'review_required').replace('signature_records', 'required_records')
publisher = publisher.replace('publish_signature.py', 'publish_required.py').replace('publication-signature', 'publication-required')
publisher = publisher.replace('graph-signature-', 'graph-required-').replace('book-signature-', 'book-required-')
start, end = publisher.index('def input_paths():\n'), publisher.index('\ndef make_claim(', publisher.index('def input_paths():\n'))
publisher = publisher[:start] + '''def input_paths():
    original = json.loads(c.decode(records.required_load('preservation.json.gz')['original_claim']['base64']))
    paths = {item['path'] for item in original['claims'][0]['durability']['inputs']}
    assert len(paths) == 823
    prepared = review.load('final-inputs.json.gz')['inputs']
    paths.update(records.current_proposals(prepared, review.load('docs-proposals.json.gz')))
    paths.update(c.PREFIX + name for name in (
        'required_records.py', 'review_required.py', 'publish_required.py', 'current_required.py',
        'graph-required-inputs.json.gz', 'graph-required-run.json.gz',
        'book-required-inputs.json.gz', 'book-required-run.json.gz'))
    paths.update(('t/lib/method_locations.py', 't/lib/LinkedSpecTest/MethodLocations.pm',
                  't/lib/LinkedSpecTest/EmittedValues.pm',
                  'docs/checkpoints/type-values-required/capsules.py',
                  'docs/checkpoints/type-values-required/closure.json'))
    return paths

''' + publisher[end:]
start, end = publisher.index('def make_claim(result, bindings):\n'), publisher.index('\ndef record_bytes(', publisher.index('def make_claim(result, bindings):\n'))
publisher = publisher[:start] + '''def make_claim(result, bindings):
    g, h, r = result['graph'], result['historical'], result['required']
    return dict(name='perl-evaluated-list-values',
        statement='Finite Perl list operands retain evaluated values across later effects, preserving flat splices and copy-on-write.',
        scope='Real c053 plus retained proposals. No exhaustive methods, cross-backend or private/parent admission. '
              'Scoped-with4/numeric5/drop6 and startup32/35 remain owned. Focused52 retains1651 inputs/982 skips. '
              'Earlier incomplete closures, wrong oracle, compiler/preparation failures, baseline guard limits '
              'and uncommitted draft epochs remain disclosed in their preserved records. No historical observation is refreshed.',
        rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish.py',
            granularity='Each23 value/kind; seven suites/277 inputs; focused52; complete Knowledge/list/book; whole prior reader; '
                        'historical inverse/recovery; recurring12 suites and native15 captures.',
            result=f"23 GREEN/19 accepted RED; graph{g}; Knowledge{result['knowledge_bytes']}; book89/heading denial; "
                   f"prior388/full68814/2706 context; historical{h}; recurring{r}."),
        falsify=dict(status='checked',
            hypothesis='Late reads, erased splices, null/all-skip observers, permissive historical inverses or diagnostic projection could hide differences.',
            oracle='Fixed independent23 values/kinds, saved bindings, real c053 source,130 historical/manual goldens, '
                   'original archive/hash/census, frozen native rows and independent emitted-value/ABI goldens.',
            red_control='Emitter faults19/14/2/1/1/1; observer129 plus one null; missing selector; heading loss; '
                        '368 original plus210 fragment denials and equal-JSON byte fault; mapper198 failures and exact restoration; '
                        'wrong callback/file/line, unmatched statement, flattened return and wrong value. '
                        'All original823 direct inputs remain; new support inputs use a closed hash-checked manifest.'),
        durability=dict(status='checked', mode='live', inputs=bindings))

''' + publisher[end:]
publisher = publisher.replace("docs/checkpoints/type-values-signature/preservation.json.gz",
                              "docs/checkpoints/type-values-required/preservation.json.gz")
current = (ROOT / (F + 'current_signature.py')).read_text().replace('current_signature.py', 'current_required.py')
current = current.replace('graph-signature-', 'graph-required-').replace('book-signature-', 'book-required-')
texts = {F + 'required_records.py': records, F + 'review_required.py': review,
         F + 'publish_required.py': publisher, F + 'current_required.py': current,
         F + 'publish.py': '"""Stable readonly publication entrypoint; capture is one-shot."""\nfrom publish_required import main\n\nif __name__ == "__main__":\n    main()\n'}
readme = c.decode(before[F + 'README.md']['base64']).decode()
readme = readme.replace('publication-signature.json is the current receipt.',
                        'publication-signature.json retains its epoch; publication-required.json is current.', 1)
readme += ('\nRecurring-consumer evidence lives in docs/checkpoints/type-values-required/.\n'
           'The original823 direct bindings remain. A closed hash manifest gates new\n'
           'support sources, measured channels and all15 frozen native inputs. Two large\n'
           'duplicate measurement capsules recover their exact original gzip bytes through\n'
           'verified references. Original4998 assertions plus3 value goldens pass; mapper\n'
           'bypass fails198 and restores5001. Earlier incomplete controls and census guards\n'
           'remain rejected preparation, separate from behavioral RED. No capture refresh.\n')
texts[F + 'README.md'] = readme
for path, text in texts.items():
    if path.endswith('.py'):
        ast.parse(text, filename=path)
    if path not in before:
        assert not (ROOT / path).exists(), path
after = {path: dict(base64=c.encode(text.encode()), sha256=c.sha(text.encode()),
                   mode=before[path]['mode'] if path in before else 0o644)
         for path, text in texts.items()}
c.write_new(P + 'compose-proposals.json.gz', dict(before=before, after=after,
    producer=c.read(P + 'compose.py'),
    scope='Separate actors preserve every previous epoch. All823 prior direct bindings '
          'stay; bounded new support closure gates every source/artifact and native input '
          'without duplicating its path in the bounded claim. Exact frozen snapshot test '
          'deltas are separately proved, not relabeled historical observations.'), packed=True)
assert c.unchanged(before)
for path, item in after.items():
    (ROOT / path).write_bytes(c.decode(item['base64']))
    (ROOT / path).chmod(item['mode'])
print('Separate recurring-consumer publication actors composed')
