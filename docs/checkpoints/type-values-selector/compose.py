"""Compose a separate selector/storage epoch while preserving every prior reader."""
import ast
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import partition_storage as storage

P, F = storage.P, c.PREFIX
saved = storage.load('preservation.json.gz')
assert c.read(c.CLAIM) == saved['original_claim']
assert storage.load('partition-removal.json')['result'] == 'PASS'
before = {F + name: c.read(F + name) for name in ('publish.py', 'README.md')}
assert all(item == saved['before'][path] for path, item in before.items())
records = (ROOT / (F + 'required_records.py')).read_text()
needle = "    current_sources.update(warning['after'])\n"
replacement = needle + '''    selected = selector_load('compose-proposals.json.gz')
    assert selected['producer'] == c.read(Q + 'compose.py')
    for path, item in selected['before'].items():
        assert current_sources[path] == item, path
    current_sources.update(selected['after'])
'''
assert records.count(needle) == 1
records = records.replace(needle, replacement, 1)
needle = '    assert c.unchanged(target)\n    return target\n'
replacement = '''    for name, producer in (('proposals.json.gz', 'apply.py'),
                           ('docs-proposals.json.gz', 'docs.py')):
        change = selector_load(name)
        assert change['producer'] == c.read(Q + producer)
        for path, item in change['before'].items():
            assert item == target.get(path, inputs.get(path, original_graph.get(path))), path
        target.update(change['after'])
    assert c.unchanged(target)
    return target
'''
assert records.count(needle) == 1
records = records.replace(needle, replacement, 1)
records += '''

Q = 'docs/checkpoints/type-values-selector/'
sys.path.insert(0, str(c.ROOT / Q))
import partition_storage as storage
storage.install_legacy(c, capsules)
selector_load = storage.load


def verify_selector(fresh):
    saved = selector_load('preservation.json.gz')
    baseline = selector_load('baseline.json')
    assert baseline['claim'] == saved['original_claim']
    assert baseline['run']['returncode'] == 0 and baseline['inputs_bytes_modes_unchanged']
    original = json.loads(c.decode(saved['original_claim']['base64']))
    assert len(original['claims'][0]['durability']['inputs']) == 837
    assert len(c.decode(saved['original_claim']['base64'])) == 130737
    proposal = selector_load('proposals.json.gz')
    assert c.unchanged(proposal['after'])
    grade = selector_load('scanner-review.json')
    observed = selector_load('scanner-run.json.gz')
    assert grade['result'] == 'PASS' and observed['inputs_bytes_modes_unchanged']
    assert observed['producer'] == c.read(Q + 'capture.py')
    for index in (0, 4):
        run = observed['runs'][index]['run']
        assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
        value = json.loads(c.decode(run['stdout_base64']))
        assert not value['unexpected'] and value['healthy_controls'] == 6 and value['rejection_controls'] == 28
    for row, expected in zip(observed['runs'][1:4], (9, 6, 3)):
        assert row['run']['returncode'] == 1 and not c.decode(row['run']['stderr_base64'])
        assert len(json.loads(c.decode(row['run']['stdout_base64']))['unexpected']) == expected
    assert all(run['returncode'] == 0 for run in observed['public'])
    copy = selector_load('partition-copy.json')
    removed = selector_load('partition-removal.json')
    context = selector_load('partition-context.json')
    controls = selector_load('partition-controls-review.json')
    assert copy['result'] == removed['result'] == controls['result'] == 'PASS'
    assert copy['parts'] == 31 and len(copy['originals']) == 2
    assert context['run']['returncode'] == 0 and context['restored']
    assert selector_load('partition-use-context.json')['result'] == 'PASS'
    assert controls['rejected_controls'] == 10 and controls['actual_whole_hash_fault'] == 2
    for row in copy['originals']:
        assert not (c.ROOT / row['path']).exists()
        raw, mode = storage.read_bytes(row['path'])
        assert c.sha(raw) == row['sha256'] and len(raw) == row['size'] and mode == row['mode']
    assert removed['residue_count'] == 0 and removed['removed_bytes'] == 500733803
    closure = selector_load('closure.json')
    for path, item in closure['inputs'].items():
        assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
    # The final closed source inventory precedes fresh global scans. Earlier finite
    # controls retain their original context; no initial global manifest is invented.
    namespace = dict(__file__=str(c.ROOT / 'tools/check_executable_aggregate_selector_sources.py'),
                     __name__='selector_inventory')
    exec(compile(c.decode(c.read('tools/check_executable_aggregate_selector_sources.py')['base64']),
                 'tools/check_executable_aggregate_selector_sources.py', 'exec'), namespace)
    eligible = sorted(path for path in namespace['candidate_files']()
                      if Path(path).suffix not in namespace['EXCLUDED_SUFFIXES']
                      and (c.ROOT / path).is_file())
    assert eligible == closure['scanner_candidates']
    if fresh:
        for command in closure['commands']:
            run = c.run(command)
            assert run['returncode'] == 0 and not c.decode(run['stderr_base64']), run
        for path, item in closure['inputs'].items():
            assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
    return dict(result='PASS', fixtures=3, denials=28, producer_faults=[9, 6, 3],
                original_readonly_inputs=837, original_readonly_bytes=130737,
                partitioned_streams=2, chunks=31, removed_duplicate_bytes=500733803,
                storage_denials=10, whole_hash_producer_red=2,
                scanner_candidates=len(eligible), closed_inputs=len(closure['inputs']),
                limits='Original837 logical inputs survive. One formerly direct physical '
                       'artifact is replaced by an index and gated chunks. Original '
                       'scanner bytes were explicitly supplied only for retained-use proof; '
                       'current scanner semantics have separate controls and fresh scans.')
'''
review = (ROOT / (F + 'review_required.py')).read_text()
assert review.count('import current\n') == 1
review = review.replace('import current\n', 'import current_selector as current\n', 1)
review = review.replace('import required_records as phase0_records', 'import selector_records as phase0_records')
review = review.replace('graph-required-', 'graph-selector-').replace('book-required-', 'book-selector-')
needle = '    required = phase0_records.verify_required(fresh)\n'
assert review.count(needle) == 1
review = review.replace(needle, needle + '''    selected = phase0_records.verify_selector(fresh)
    required = dict(required)
    required.pop('prior_direct_inputs', None)
    required['prior_logical_inputs'] = 823
    required['scope'] = 'Original4998 plus3 goldens; supplied mapper RED/restoration. One old physical artifact now has exact hash-checked partitions.'
''', 1)
review = review.replace('historical=historical, required=required,',
                        'historical=historical, required=required, selector=selected,', 1)
publisher = (ROOT / (F + 'publish_required.py')).read_text()
publisher = publisher.replace('review_required', 'review_selector').replace('required_records', 'selector_records')
publisher = publisher.replace('publish_required.py', 'publish_selector.py').replace(
    'publication-required-final', 'publication-selector')
publisher = publisher.replace('graph-required-', 'graph-selector-').replace('book-required-', 'book-selector-')
start, end = publisher.index('def input_paths():\n'), publisher.index('\ndef make_claim(')
publisher = publisher[:start] + '''def input_paths():
    original = json.loads(c.decode(records.selector_load('preservation.json.gz')['original_claim']['base64']))
    paths = {item['path'] for item in original['claims'][0]['durability']['inputs']}
    assert len(paths) == 837
    logical = 'docs/checkpoints/type-values-admission/canonical1-candidate.patch.gz'
    paths.remove(logical)
    paths.add(records.storage.INDEXES[logical])
    prepared = review.load('final-inputs.json.gz')['inputs']
    paths.update(records.current_proposals(prepared, review.load('docs-proposals.json.gz')))
    paths.update(c.PREFIX + name for name in (
        'selector_records.py', 'review_selector.py', 'publish_selector.py', 'current_selector.py',
        'graph-selector-inputs.json.gz', 'graph-selector-run.json.gz',
        'book-selector-inputs.json.gz', 'book-selector-run.json.gz'))
    paths.add('docs/checkpoints/type-values-selector/closure.json')
    return paths

''' + publisher[end:]
start, end = publisher.index('def make_claim(result, bindings):\n'), publisher.index('\ndef record_bytes(')
publisher = publisher[:start] + '''def make_claim(result, bindings):
    g, h, s = result['graph'], result['historical'], result['selector']
    return dict(name='perl-evaluated-list-values',
        statement='Finite Perl emitted list operands retain evaluated values across later effects, preserving flat splices and copy-on-write.',
        scope='Real c053 plus owned proposals; no exhaustive method, cross-backend or private/parent admission. '
              'Scoped-with4/numeric5/drop6 and startup32/35 remain owned. Focused52 has982 skips; ordinary1035 is separate. '
              'Original/rejected epochs retain their limits. All837 original logical inputs survive; one physical '
              'artifact becomes an index and exact chunks. No uncommitted draft is assigned a historical Git revision.',
        rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish.py',
            granularity='Each23 value/kind; seven suites/277 inputs; focused52; complete Knowledge/list/book; whole prior reader; historical recovery; recurring12 suites; selector and byte-partition controls.',
            result=f"23 GREEN/19 accepted RED; graph{g}; Knowledge{result['knowledge_bytes']}; book89/heading denial; "
                   f"prior388/full68814/2706 context; historical{h['fragments']} fragments/"
                   f"{h['original_denials']}+{h['added_denials']} denials/archive134/full84613241/22 recovery controls; "
                   'recurring12/5001 quiet; selector3/28 denials and9/6/3 producer RED; original837/full130737 readonly0; '
                   f"partitions2/{s['chunks']} chunks/500733803 duplicate bytes removed; exact bytes/modes/use; "
                   f"closed scanner candidates{s['scanner_candidates']}."),
        falsify=dict(status='checked',
            hypothesis='Late reads, erased splices, null/all-skip observers, permissive source admissions or damaged partitions could hide differences.',
            oracle='Fixed23 values/kinds, saved bindings, real c053 source,130 historical/manual goldens, original archive/native rows, independent emitted-value/ABI goldens and original byte hashes/modes.',
            red_control='Emitter faults19/14/2/1/1/1; observer129 plus one null; missing selector and heading loss; '
                        '368 original plus210 fragment denials/equal-JSON byte fault; mapper198/restoration; '
                        'wrong callback/file/line and value; selector28 denials, source faults9/6/3; '
                        'partition10 denials, actual whole-hash bypass2 and restoration. Generated-drop warning/FATAL remains owned by6.'),
        durability=dict(status='checked', mode='live', inputs=bindings))

''' + publisher[end:]
old = '''        preserved = json.loads(gzip.decompress(
            (c.ROOT / 'docs/checkpoints/type-values-required/preservation.json.gz').read_bytes()))
'''
new = "        preserved = records.selector_load('preservation.json.gz')\n"
assert publisher.count(old) == 1
publisher = publisher.replace(old, new, 1)
current = (ROOT / (F + 'current_required.py')).read_text().replace('current_required.py', 'current_selector.py')
current = current.replace('graph-required-', 'graph-selector-').replace('book-required-', 'book-selector-')
texts = {F + 'selector_records.py': records, F + 'review_selector.py': review,
         F + 'publish_selector.py': publisher, F + 'current_selector.py': current,
         F + 'publish.py': '"""Stable readonly publication entrypoint; capture is one-shot."""\nfrom publish_selector import main\n\nif __name__ == "__main__":\n    main()\n'}
readme = c.decode(before[F + 'README.md']['base64']).decode()
readme = readme.replace('publication-required-final.json is current.', 'publication-selector.json is current.', 1)
readme = readme.replace('The original823 direct bindings remain.',
                        'The required-consumer epoch retained its original823 direct bindings.', 1)
readme += (
    '\nThe selector/storage epoch retains whole837/full130737 and its actual default0\n'
    'before changes. Three diagnostic fixture revisions have separate owner/prior/current\n'
    'admissions; original registrations stay exact. Edited/copied/new-positive/wrong\n'
    'registrations reject, and actual check-removal faults admit9/6/3 before restoration.\n'
    'Two oversized raw gzip streams now have31 bounded payload chunks. Their exact bytes,\n'
    'whole hashes and original modes survive. The old reviewer uses its explicitly supplied\n'
    'original scanner context before duplicate removal; the repaired scanner is restored.\n'
    'The earlier context mismatch remains rejected preparation. One previous direct path\n'
    'becomes a physical index plus gated chunks; this is an explicit logical-input migration.\n'
    'A final complete scanner candidate closure precedes fresh composed scans. The first\n'
    'finite control epoch does not acquire a retroactive global input manifest.\n')
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
    scope='Separate selector/storage readers preserve every earlier actor. Exact scanner '
          'and fact/book deltas enter the current proposal chain. The original837 record '
          'and default0 stay intact; one physical artifact is replaced by lossless parts '
          'without pretending its old path remains a current direct binding.'), packed=True)
assert c.unchanged(before)
for path, item in after.items():
    (ROOT / path).write_bytes(c.decode(item['base64']))
    (ROOT / path).chmod(item['mode'])
print('Separate selector/storage publication composed; prior actors and logical inputs preserved')
