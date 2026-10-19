"""Bounded metadata claim; default freshly reviews complete supplied evidence."""
import copy
import gzip
import json
import subprocess
import sys
from pathlib import Path
import common as c

assert sys.argv[1:] in ([], ['--preflight'], ['--capture'])
sys.path.insert(0, str(c.ROOT / 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12-portability'))
import review_final as portability_review
portability = c.run(['python3', portability_review.HOME + 'review_final.py'])
assert portability['returncode'] == 0 and not c.decode(portability['stderr_base64']), portability
repair = json.loads((c.ROOT / (portability_review.HOME + 'review-repair.json')).read_bytes())
assert repair['original_reader'] == c.read(portability_review.HOME + 'review.py')
assert repair['corrected_reader'] == c.read(portability_review.HOME + 'review_final.py')
assert c.sha(c.decode(repair['failure_log']['base64'])) == repair['failure_log']['sha256']
assert b"'.linkedspec-data/tmp/xcrun_db'" in c.decode(repair['failure_log']['base64'])
replay = json.loads((c.ROOT / (portability_review.HOME + 'replay.json')).read_bytes())
for path, item in replay['runtime_temporary_files'].items():
    assert path.startswith('.linkedspec-data/tmp/') and c.sha(c.decode(item['base64'])) == item['sha256']
transport_controls = c.run(['python3', portability_review.HOME + 'controls.py'])
assert transport_controls['returncode'] == 0 and not c.decode(transport_controls['stderr_base64']), transport_controls
for script in ('review-current.py', 'faults.py', 'artifacts.py'):
    run = c.run(['python3', c.HOME + script])
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64']), (script, run)
render = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'render-final.json.gz')).read_bytes()))
render_inputs = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'render-inputs.json.gz')).read_bytes()))
assert render['result'] == 'PASS' and render['source_inputs_unchanged']
assert render['producer_sha256'] == c.sha((c.ROOT / (c.HOME + 'render-final.py')).read_bytes())
assert c.decode(render_inputs['producer_base64']) == (c.ROOT / (c.HOME + 'render-final.py')).read_bytes()
assert render['version']['returncode'] == render['command']['returncode'] == 0
assert render['tool']['sha256'] == render_inputs['tool_sha256']
mains = {}
for name, item in render['pages'].items():
    value = c.decode(item['base64'])
    assert c.sha(value) == item['sha256']
    mains[name] = value.split(b'<main>', 1)[1].rsplit(b'</main>', 1)[0]
assert mains['original'] == mains['compact'] and mains['changed'] != mains['compact']
assert b'Changed visible heading' in mains['changed']
first = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'render-recovery.json.gz')).read_bytes()))
fresh = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'render-outputs.json.gz')).read_bytes()))
assert set(first['files']) == set(fresh['files']) and len(first['files']) == 39
for path, item in first['files'].items():
    assert c.decode(item['base64']) == c.decode(fresh['files'][path]['base64'])
    assert c.sha(c.decode(item['base64'])) == item['sha256'] == fresh['files'][path]['sha256']
    assert item['mode'] == fresh['files'][path]['mode']
cleanup = json.loads((c.ROOT / (c.HOME + 'output-cleanup.json')).read_bytes())
cleanup_inputs = json.loads((c.ROOT / (c.HOME + 'output-cleanup-preparation.json')).read_bytes())
assert cleanup['result'] == 'PASS' and (cleanup['removed_files'], cleanup['removed_bytes']) == (39, 98579726)
assert set(cleanup['removed_paths']) == set(first['files'])
assert cleanup['residue'] == dict(path='output', exists=False, symlink=False)
assert cleanup_inputs['files'] == {path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in first['files'].items()}
assert cleanup_inputs['original_archive_sha256'] == c.sha((c.ROOT / (c.HOME + 'render-recovery.json.gz')).read_bytes())
pressure = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'pressure-red.json.gz')).read_bytes()))
assert pressure['command']['returncode'] != 0 and pressure['candidate_lines'] == 22596
assert b'22596/22500' in c.decode(pressure['command']['stderr_base64']) + c.decode(pressure['command']['stdout_base64'])
current = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'current.json.gz')).read_bytes()))
book = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'book-inputs.json.gz')).read_bytes()))
paths = {path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / c.HOME).iterdir()
         if path.is_file() and path.name not in ('publication-preflight.json', 'continuity.json')}
paths.update(portability_review.current_inputs())
paths.update(book['inputs'])
paths.update(current['changed_facts'])
paths.update(['knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
    't/knowledge_map_header_lists.t', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-headers-census.json',
    'knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md', 'knowledge-map/templates/FACT_TEMPLATE.md',
    '.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf', 'KNOWLEDGE_MAP.md',
    'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
    'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.6.json', 'scripts/check_readme_stability.sh',
    'scripts/check_readme_routing_pressure.pl', 'doctrine/readme_stability/routes.jsonl',
    'README.md', 'README_POLICY.md'])
bindings, modes = [], {}
for path in sorted(paths):
    item = c.read(path)
    bindings.append(dict(path=path, sha256=item['sha256'], role='producer' if Path(path).suffix in ('.py', '.sh', '.pl', '.t') else 'input'))
    modes[path] = item['mode']
claim = dict(name='complete-supported-knowledge-metadata-projection',
    statement='Knowledge generation preserves nonempty evidence/reverify block and inline lists in '
        'authored order and multiplicity, including quoted commas/escapes, Unicode and literal '
        'backticks. Scalars keep their existing presentation; questions point to complete reverify '
        'lists, and metadata is never executed. The original complete1487-source/1349-fact '
        'population loses897 entries across248 accepted fields; independent current source/code-span '
        'review restores every entry and all10455 question rows. Original80 assertions remain exact; '
        'corrected176 plan has38 projection REDs/138 controls then176 GREEN. Ten exact syntax-valid '
        'source faults retain all120 native controls and fail18/20/10/9/3/1/3/2/6/2, with exact '
        'restorations. Three coherent artifact forgeries reject and restore. Current fifteen routes, '
        'whole supplied map and89-input book/four controls pass. Knowledge8386908 bytes and map21249 '
        'lines fit unchanged limits. Actual22596/22500 denial precedes blank-separator containment; '
        'actual mdBook main content remains identical while changed-heading output differs. '
        'Standard JSON solidus transport preserves the actual render command and exact inverse bytes; '
        'original196-input/full35922 uncommitted draft and actual readonly replay remain recoverable.',
    scope='Original native/source/data epochs and every failed instrument remain immutable. '
        'Complete711-input/full120239 pipeline claim and actual readonly baseline precede its sole '
        'mode/revision freeze at real f7e8b292f. The current complete graph uses captured originals '
        'plus exact fifteen-card projections; full bytes/modes precede producers. A fixed historical '
        'census omitted by the first control declaration is supplied before a distinct exact80 '
        'recurrence. The first assertion grouping error retains40 actual/32 named failures; corrected '
        'recorder enumerates all failures. First correct format22596 and compact21247 epochs retain '
        'their exact source/data/reviews. Current two added questions yield21249 lines. The first '
        'render reader used the wrong destination; its actual39 files/98579726 bytes and outer '
        'failure remain recoverable, while unsaved build/version channels are explicitly unavailable. '
        'Corrected actual render retains complete input/channel/output custody. Its original plain JSON '
        'transport fails the unchanged path gate in the actual first canonical run (nine other '
        'doctrines pass). The complete failed108-file staged candidate, whole original196/full35922 '
        'draft and preflight, original bound source/record bytes and actual readonly baseline are '
        'preserved before transport. A supplied196-input original-reader replay restores exact '
        'baseline channels and guards all supplied bytes/modes. Current default checks that retained '
        'replay and every original source hash; it freshly regenerates the current metadata graph. '
        'Three separate transport/draft counterfactuals reject and restore in supplied fixtures. '
        'No original native writer or observation is refreshed. Fresh whole-output '
        'names/bytes/modes match before exact archived cleanup; dated residue proof is not a '
        'permanent absence or lifecycle guarantee. Current book has57 sources/32 recursive includes '
        'and four actual controls. The existing checker retains presence/list-association limits; '
        'no full YAML/type-validator, backend/DSL change, new allocator/selector, budget change, '
        'kernel/process-group/recovery/purge or private/parent admission is inferred.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + c.HOME + 'publish.py',
        granularity='Every actual source header/list item/order/multiplicity, scalar field and question '
            'row in the full supplied1487-source current graph; fresh actual generator/checker; '
            'original80/corrected176/30 native cases, complete source/control ledgers and full89-input '
            'book/four controls; actual format-render equivalence and complete output recovery.',
        result='All scoped focused behavior, independent source/code-span/current-book review, '
            'ten source faults and three semantic artifact denials PASS. Exact staged canonical '
            'receipt and normal doctrine/hook workflow are required before landing.'),
    falsify=dict(status='checked',
        hypothesis='Accepted lists could remain omitted, reorder/drop/merge entries, split quoted '
            'commas, misrender data, change scalar presentation or point questions to incomplete '
            'metadata while aggregate map counts/synchronization still pass.',
        oracle='Complete raw source graph plus independently decoded actual CommonMark spans and '
            'every expected question row; original80 controls and current public metadata cases; '
            'exact source recipes/same176 plan; coherent map/report/capsule forgeries; actual '
            'unchanged pressure gate and actual mdBook main-content/changed-heading comparison.',
        red_control='Original unchanged full generator/checker accept248 fields but omit897 entries; '
            'five separate public list reproductions and corrected38 projection assertion REDs. '
            'Ten semantic source faults and three coherently updated artifact denials reject for '
            'distinguishing reasons and restore exact healthy state. Actual22596/22500 pressure '
            'RED and visible changed-heading render RED remain retained.'),
    durability=dict(status='checked', mode='live', inputs=bindings))
record = dict(version=1, owner=c.OWNER, claims=[claim])
presentation = copy.deepcopy(record)
token = '__ALL_METADATA_BINDINGS__'
presentation['claims'][0]['durability']['inputs'] = token
value = json.dumps(presentation, indent=1)
assert value.count(json.dumps(token)) == 1
value = value.replace(json.dumps(token), '[\n' + ',\n'.join('     ' + json.dumps(item, separators=(',', ':')) for item in bindings) + '\n    ]')
value = (value + '\n').encode()
assert json.loads(value) == record and len(value) <= 131072
if sys.argv[1:] == ['--preflight']:
    print(json.dumps(dict(result='PASS', bytes=len(value), input_count=len(bindings), draft_sha256=c.sha(value),
        draft_base64=c.encode(value), input_modes=modes, producer_sha256=c.sha(Path(__file__).read_bytes())), indent=1))
elif sys.argv[1:] == ['--capture']:
    with (c.ROOT / c.CLAIM).open('xb') as output:
        output.write(value)
    print('Metadata publication captured:', len(bindings), 'inputs;', len(value), 'bytes')
else:
    assert (c.ROOT / c.CLAIM).read_bytes() == value
    print('Metadata publication PASS:', len(bindings), 'inputs;', len(value), 'bytes;1487/1349/10455;897/248')
