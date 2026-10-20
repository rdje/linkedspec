"""Keep the unchanged claim cap while retaining old bindings and the complete closed inputs."""
import ast
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import partition_storage as storage

P, F = storage.P, c.PREFIX
paths = (F + 'selector_records.py', F + 'publish_selector.py')
finished = storage.load('finish-proposals.json.gz')
before = {path: c.read(path) for path in paths}
assert all(before[path] == finished['after'][path] for path in paths)
closure = c.read(P + 'closure-final.json')
closed = json.loads(c.decode(closure['base64']))
original = json.loads(c.decode(storage.load('baseline.json')['claim']['base64']))
prior_paths = {item['path'] for item in original['claims'][0]['durability']['inputs']}
outputs = tuple(F + name for name in (
    'graph-selector-inputs.json.gz', 'graph-selector-run.json.gz',
    'book-selector-inputs.json.gz', 'book-selector-run.json.gz'))
assert not set(outputs) & prior_paths
assert all(path in closed['inputs'] for path in outputs)
records = c.decode(before[paths[0]]['base64']).decode()
needle = "    current_sources.update(finished_selector['after'])\n"
replacement = needle + '''    formatted_selector = selector_load('format-proposals.json.gz')
    assert formatted_selector['producer'] == c.read(Q + 'format.py')
    for path, item in formatted_selector['before'].items():
        assert current_sources[path] == item, path
    current_sources.update(formatted_selector['after'])
'''
assert records.count(needle) == 1
records = records.replace(needle, replacement, 1)
publisher = c.decode(before[paths[1]]['base64']).decode()
old = '''        'selector_records.py', 'review_selector.py', 'publish_selector.py', 'current_selector.py',
        'graph-selector-inputs.json.gz', 'graph-selector-run.json.gz',
        'book-selector-inputs.json.gz', 'book-selector-run.json.gz'))
'''
new = '''        'selector_records.py', 'review_selector.py', 'publish_selector.py', 'current_selector.py'))
'''
assert publisher.count(old) == 1
publisher = publisher.replace(old, new, 1)
start, end = publisher.index('def make_claim(result, bindings):\n'), publisher.index('\ndef record_bytes(')
publisher = publisher[:start] + '''def make_claim(result, bindings):
    g, h, s = result['graph'], result['historical'], result['selector']
    return dict(name='perl-evaluated-list-values',
        statement='Finite Perl list operands retain evaluated values across later effects, preserving flat splices and copy-on-write.',
        scope='c053 plus owned proposals; no exhaustive method/backend/private admission. Scoped4/numeric5/drop6/startup32/35 stay owned. '
              'Rejected/supplemental epochs retain their limits. Original837 logical inputs survive; one physical path becomes indexed chunks. No fake historical revision.',
        rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish.py',
            granularity='23 values/kinds; seven suites; complete graph/list/book and prior reader; historical audit;12 recurring suites;3 scanner fixtures;2 byte streams.',
            result=f"23 GREEN/19 RED; suites7/277; focused52/982 skips; ordinary1035; private5001; "
                   f"graph{g['markdown']}/{g['facts']}/{g['question_keys']},lists{g['list_items']}/{g['list_fields']},"
                   f"bytes{result['knowledge_bytes']}; book89; prior388/full68814; history{h['fragments']}/578; "
                   f"selector28/fault9,6,3; exact2 streams/31 chunks; scanner{s['scanner_candidates']}."),
        falsify=dict(status='checked', hypothesis='Late reads or permissive source/storage checks hide differences.',
            oracle='Fixed values, saved bindings, c053, frozen native rows, original byte hashes/modes and historical archive.',
            red_control='Emitter19/14/2/1/1/1; observer129/null; skip/heading; history368+210/equal-JSON; mapper198; '
                        'callback/file/line/value; scanner28/fault9,6,3; partition10/fault2; metadata4/fault1; exact restoration.'),
        durability=dict(status='checked', mode='live', inputs=bindings))

''' + publisher[end:]
texts = {paths[0]: records, paths[1]: publisher}
for path, text in texts.items():
    ast.parse(text, filename=path)
after = {path: dict(base64=c.encode(text.encode()), sha256=c.sha(text.encode()), mode=before[path]['mode'])
         for path, text in texts.items()}
c.write_new(P + 'format-proposals.json.gz', dict(before=before, after=after,
    original_closure=closure, producer=c.read(P + 'format.py'),
    rejected_output=c.read('.linkedspec-data/verification/type-values-selector-preflight-final.log'),
    indirectly_bound_new_outputs=list(outputs),
    scope='The retained preflight passes its evidence review but exceeds the unchanged '
          '131072-byte record cap at132188/849. Shorter three-leg prose and four NEW '
          'measurement outputs already covered by the complete hash manifest avoid '
          'duplicate direct entries. No original837 logical input is dropped. The '
          'unpublished old closure remains exact here before a fresh closure replaces it.'),
    packed=True)
assert c.unchanged(before) and c.read(P + 'closure-final.json') == closure
for path, item in after.items():
    (ROOT / path).write_bytes(c.decode(item['base64']))
    (ROOT / path).chmod(item['mode'])
(ROOT / (P + 'closure-final.json')).unlink()
print('Bounded claim format repaired; all prior logical inputs and new closed outputs retained')
