"""Freshly review scoped current recipes, graph and rendered public documentation."""
import gzip
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
import common as c
import review_native as native
import source_transport
import review_book
sys.path.insert(0, str(c.ROOT / 'docs/checkpoints/knowledge-fields'))
import metadata_oracle


def load(name):
    return json.loads(gzip.decompress((c.ROOT / (c.PREFIX + name)).read_bytes()))


def current_recipes(proposals):
    path = 'docs/knowledge/retired-return-helpers-canonical-rewrite.md'
    source = c.decode(proposals[path]['base64']).decode()
    actual = []
    for line in source.splitlines():
        if line.startswith('| `return_'):
            recipe = re.fullmatch(r'`([^`]+)`', line.split('|')[2].strip())
            assert recipe, 'explicit canonical recipe column'
            actual.append(recipe[1].replace('L', 'Top').replace('X', '"extra"').replace('payload', '"payload"'))
    cases = native.load('entry-inputs.json.gz')['cases'] + native.load('flat-ma-inputs.json.gz')['cases']
    by_id = {case['id']: case['body'] for case in cases}
    assert actual == [by_id[name] for name in ('a-snapshot', 'a-extra', 'm-flat', 'ma-flat', 'imatch', 'array-tag-payload')], 'current table equals actually executed canonical payload recipes'


def review(fresh=True):
    result = native.review()
    proposals = load('docs-proposals-final.json.gz')
    assert len(proposals['proposals']) == 21
    assert c.unchanged(proposals['proposals'])
    assert proposals['producer'] == source_transport.recover(c.PREFIX + 'finish-prose.py')
    for path, item in proposals['before'].items():
        original = subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
        assert c.decode(item['base64']) == original, ('actual accepted before-image', path)
    current_recipes(proposals['proposals'])
    graph = load('graph-inputs.json.gz')['inputs']
    observed = load('graph-run.json.gz')
    assert c.unchanged(graph) and observed['unchanged']
    assert len(observed['runs']) == 2 and all(run['returncode'] == 0 for run in observed['runs'])
    mapping = c.decode(observed['mapping']['base64'])
    assert c.read('KNOWLEDGE_MAP.md') == observed['mapping']
    for path, item in graph.items():
        if path in proposals['proposals']:
            assert item == proposals['proposals'][path]
        elif path.startswith(('docs/knowledge/', 'docs/decisions/')):
            assert c.decode(item['base64']) == subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT), ('unchanged accepted graph member', path)
    population = metadata_oracle.verify_graph(graph, mapping, c.decode)
    assert len(mapping.splitlines()) <= 22500
    knowledge_bytes = sum(len(c.decode(item['base64'])) for path, item in graph.items() if path.startswith('docs/knowledge/'))
    assert knowledge_bytes <= 8388608
    preserved = load('preservation.json.gz')
    frozen = json.loads(c.decode(preserved['original']['base64']))
    frozen['claims'][0]['durability'].update(mode='historical', revision=c.BASE)
    assert json.loads((c.ROOT / c.PRIOR_CLAIM).read_bytes()) == frozen
    for key, record in preserved['live'].items():
        if key != c.PRIOR_CLAIM + '#0':
            assert c.unchanged(record['inputs'])
            assert c.read(key.rsplit('#', 1)[0]) == record['original']
    if fresh:
        paths = {path for path in graph if path.startswith(('docs/knowledge/', 'docs/decisions/', 'knowledge-map/', 'tools/')) or path == '.knowledge_map.conf'}
        with tempfile.TemporaryDirectory(prefix='type-current-graph-', dir=os.environ['TMPDIR']) as directory:
            fixture = Path(directory)
            assert fixture.stat().st_dev == c.ROOT.stat().st_dev
            for path in paths:
                target = fixture / path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(c.decode(graph[path]['base64']))
                target.chmod(graph[path]['mode'])
            temporary = fixture / '.linkedspec-data/tmp'
            temporary.mkdir(parents=True)
            environment = dict(os.environ, GIT_DIR=subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=c.ROOT, text=True).strip(),
                GIT_WORK_TREE=str(fixture), GIT_OPTIONAL_LOCKS='0', TMPDIR=str(temporary),
                KM_SCAN_DIRS='docs/knowledge docs/decisions', KM_OUTPUT='generated-map.md')
            for command in (['bash', 'knowledge-map/scripts/gen_knowledge_map.sh'], ['bash', 'knowledge-map/scripts/check_knowledge_map.sh']):
                run = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
                assert run.returncode == 0, (command, run.stdout, run.stderr)
            assert (fixture / 'generated-map.md').read_bytes() == mapping
            assert all((fixture / path).read_bytes() == c.decode(graph[path]['base64']) and
                       (fixture / path).stat().st_mode & 0o7777 == graph[path]['mode'] for path in paths)
        cases = native.load('entry-inputs.json.gz')['cases'] + native.load('flat-ma-inputs.json.gz')['cases']
        selected = [case for case in cases if case['id'] in native.EXPECTED]
        assert len(selected) == len(native.EXPECTED)
        run = c.run(['perl', '-Iperl', c.PREFIX + 'native.pl'], input=json.dumps(selected).encode())
        current, prelude = native.observations(dict(run=run, unchanged=True))
        assert not prelude, 'current healthy cases produce no fallback diagnostics'
        for case in current['cases']:
            native.value_check(case, native.EXPECTED[case['id']])
        assert source_transport.unchanged(native.load('flat-ma-inputs.json.gz')['inputs'])
    book = review_book.review(fresh)
    return dict(result='PASS', native=result, graph=population, knowledge_bytes=knowledge_bytes,
                map_lines=len(mapping.splitlines()), book=book,
                scope='Exact current named recipe/value/descriptor/generated and complete supplied Knowledge graph; '
                      'preserved old source/claims/channels and actual counterexamples; complete book render and affected pages. '
                      'No runtime/contract change, alias equivalence, complete type inventory, or parent admission.')


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--semantic-only'])
    print(json.dumps(review(not sys.argv[1:]), sort_keys=True))
