"""Preserve complete current claim context before any bound metadata write."""
import json
import re
import subprocess
from pathlib import Path
import common as c

assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=c.ROOT, text=True).strip() == c.BASE
mechanical = {'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
              't/knowledge_map_header_lists.t', 'KNOWLEDGE_MAP.md',
              'knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md', 'knowledge-map/templates/FACT_TEMPLATE.md',
              'docs/linkedspec-book/src/development/documentation-workflow.md'}
old_raw = (c.ROOT / c.OLD_CLAIM).read_bytes()
old = json.loads(old_raw)
bindings = old['claims'][0]['durability']['inputs']
facts = {item['path'] for item in bindings if item['path'].startswith('docs/knowledge/')}
assert len(facts) == 15
planned = mechanical | facts
census, selected = [], []
for source in sorted((c.ROOT / 'docs/claims').glob('*.json')):
    record = json.loads(source.read_bytes())
    live = []
    for claim in record.get('claims', []):
        durability = claim.get('durability', {})
        if durability.get('status') == 'checked' and durability.get('mode') == 'live':
            names = {item['path'] for item in durability.get('inputs', [])}
            actual = sorted(names & planned)
            live.append(dict(name=claim['name'], input_count=len(names), intersections=actual,
                             potential_fact_intersections=sorted(path for path in names if path.startswith('docs/knowledge/'))))
            if actual:
                selected.append(source.relative_to(c.ROOT).as_posix())
    census.append(dict(path=source.relative_to(c.ROOT).as_posix(), sha256=c.sha(source.read_bytes()), live=live))
assert selected == [c.OLD_CLAIM], ('exact planned-surface live intersections', selected)
assert len(bindings) == 711 and len(old_raw) == 120239
inputs = {}
for item in bindings:
    value = c.read(item['path'])
    assert value['sha256'] == item['sha256']
    git = subprocess.check_output(['git', 'show', c.BASE + ':' + item['path']], cwd=c.ROOT)
    assert c.decode(value['base64']) == git, ('actual committed before image', item['path'])
    inputs[item['path']] = dict(sha256=value['sha256'], mode=value['mode'])
preflight = c.read('docs/checkpoints/pipeline-scope/publication-preflight.json')
assert c.decode(json.loads(c.decode(preflight['base64']))['draft_base64']) == old_raw
command = ['python3', 'docs/checkpoints/pipeline-scope/publish.py']
baseline = c.run(command)
assert baseline['returncode'] == 0 and not c.decode(baseline['stderr_base64']), baseline
assert c.decode(baseline['stdout_base64']) == b'Current pipeline publication PASS: 711 live inputs; 120239 bytes; original625+161 supplied\n'
assert c.unchanged(inputs) and (c.ROOT / c.OLD_CLAIM).read_bytes() == old_raw
assert not (c.ROOT / 'docs/checkpoints/pipeline-scope/preserved.json.gz').exists()
matches = list(re.finditer(rb'(?m)^( +)"mode": "live",$', old_raw))
assert len(matches) == 1
match = matches[0]
replacement = match[1] + b'"mode": "historical",\n' + match[1] + b'"revision": "' + c.BASE.encode() + b'",'
after = old_raw[:match.start()] + replacement + old_raw[match.end():]
expected = json.loads(old_raw)
expected['claims'][0]['durability'].update(mode='historical', revision=c.BASE)
assert json.loads(after) == expected and len(after) <= 131072
report = dict(version=1, result='PASS', base=c.BASE, planned_paths=sorted(planned),
              complete_claim_census=census, selected_claims=selected,
              original=dict(path=c.OLD_CLAIM, **c.read(c.OLD_CLAIM)), original_preflight=preflight,
              original_inputs=inputs, baseline=baseline, inputs_unchanged=True,
              after_sha256=c.sha(after), producer_base64=c.encode(Path(__file__).read_bytes()),
              common=c.read(c.HOME + 'common.py'),
              scope='Complete claim census examines every checked live claim against the exact '
                    'planned mechanical surfaces and fifteen already-pipeline-bound current facts. '
                    'The other live private-capacity claim binds a separate unchanged fact and has '
                    'zero actual planned intersections. Every711 original input byte equals real '
                    'activation Git, with actual filesystem permissions independently captured. '
                    'The actual readonly baseline precedes the sole mode/revision freeze. Whole '
                    'claim and preflight are retained; no native or retired capture writer runs.')
c.write_new(c.HOME + 'preservation.json', report)
assert (c.ROOT / c.OLD_CLAIM).read_bytes() == old_raw and c.unchanged(inputs)
(c.ROOT / c.OLD_CLAIM).write_bytes(after)
assert c.sha((c.ROOT / c.OLD_CLAIM).read_bytes()) == report['after_sha256']
print('Metadata preservation PASS:711 committed inputs;whole120239;actual baseline;mode/revision only')
