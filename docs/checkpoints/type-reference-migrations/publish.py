"""Readonly current publication, with explicit one-shot capture for this leaf."""
import gzip
import json
import sys
from pathlib import Path
import common as c
import replay_prior
import review
import review_draft

assert sys.argv[1:] in ([], ['--capture-final'])
draft = review_draft.review()
current = review.review()
prior = replay_prior.replay()
assert current['result'] == prior['result'] == 'PASS'
paths = {path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / c.PREFIX).iterdir()
         if path.is_file() and path.name not in ('publication-final-preflight.json', 'continuity.json')}
for name in ('flat-ma-inputs.json.gz', 'book-inputs.json.gz'):
    paths.update(json.loads(gzip.decompress((c.ROOT / (c.PREFIX + name)).read_bytes()))['inputs'])
proposals = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'docs-proposals-final.json.gz')).read_bytes()))
paths.update(proposals['proposals'])
preservation = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes()))
for key, item in preservation['live'].items():
    if key != c.PRIOR_CLAIM + '#0':
        paths.add(key.rsplit('#', 1)[0])
        paths.update(item['inputs'])
paths.update([c.PRIOR_CLAIM, 'KNOWLEDGE_MAP.md', 'docs/checkpoints/knowledge-fields/metadata_oracle.py',
    '.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
    'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
    'README.md', 'README_POLICY.md', 'scripts/check_readme_stability.sh',
    'scripts/check_readme_routing_pressure.pl', 'doctrine/readme_stability/routes.jsonl'])
bindings, modes = [], {}
for path in sorted(paths):
    item = c.read(path)
    bindings.append(dict(path=path, sha256=item['sha256'], role='producer' if Path(path).suffix in ('.py', '.pl', '.sh') else 'input'))
    modes[path] = item['mode']
claim = dict(name='current-retired-return-migration-guidance',
    statement='Current guidance replaces removed aggregate selectors and retired return helpers '
        'with explicitly verified payloads. Exact pre-retirement a/m/ma callbacks splice m/ma capture '
        'groups and retain a live accumulator reference; current flat_array(entry_groups()) keeps '
        'the historical flat group shape while copy supplies a snapshot with an explicit identity '
        'limit. Optional old return_array scope is distinguished from its retained tag. Current '
        'named recipes pass17 fixed parser/generated payload oracles and RETURN/zero-fallback checks; '
        'five actual alternate native shapes reject and restore. Two Toolbox return examples work. '
        'Complete current Knowledge1487/1349/10455 and all897 list items/248 fields remain exact; '
        'knowledge8386601 bytes and map21249 lines fit unchanged limits. Complete89-input book '
        'renders, affected pages/links and worked native example agree, and changed heading is RED. '
        'Whole accepted208-input/full39111 prior metadata publication and original channels remain '
        'recoverable with exact supplied readonly replay. The complete first uncommitted355/full60395 '
        'candidate and original readonly baseline are preserved; a distinct module-key predicate '
        'adapter replays that whole original record with unchanged on-disk inputs and exact channels. '
        'Four unsafe/missing/mismatched module controls reject and restore; retired diagnostic '
        'producer sources are exactly recoverable data with guarded retirement stubs.',
    scope='Bounded six-helper migration guidance, two current cards, fifteen current reverify routes, '
        'Toolbox sections1.1/1.3 and affected canonical book sections. Original26 root,31 matched-entry '
        'and3 additional current observations remain distinct; root initialization without incoming '
        'captures is not substituted for matched-entry evidence. Full source/spec/contract input '
        'supersets precede each producer, and every loaded owned Perl module is covered. Historical '
        'execution is limited to exact pure a/m/ma replacement callbacks and emitted local-array '
        'snippets, without a retired compiler. Original dated cards/source/claims/channels and all '
        'failed instruments remain immutable; separate corrections handle EOF, removed callbacks, '
        'diagnostic stdout, front-matter-only routing and HTML entity presentation. Separate original '
        'first-history inner channels were unavailable and are explicitly disclosed, with a complete '
        'supplied recurrence retained. Prior208/full39111 is frozen by mode/revision only at real '
        'accepted1a8b20201; other two live guards stay unchanged. The original publisher freshly '
        'replays in its full208-input/whole-live-target context, never by rewriting old observations. '
        'Current graph and book are freshly supplied/read-only; external read-only OS Perl/mdBook '
        'prerequisites retain observed identities. No runtime/contract, budget, deep-copy, full old '
        'alias equivalence, corpus absence, exhaustive type inventory, cross-backend or private/parent '
        'admission. The separately owned Toolbox2.2 capture family remains pending. '
        'The first source-bound current publication355/full60395 passes its actual main-context '
        'readonly baseline but its exact isolated reader fails on captured absolute INC roots. '
        'A first adapted fixture then omits materialized graph files that were already present in '
        'its bound capsule. Both actual failures and sources remain retained; the complete supplied '
        'fixture plus only the normalized module predicate passes the whole original publication. '
        'The original two redundant grammar references fail public42/40; current prose restores '
        'the unchanged40 reference contract. Original negative diagnostic Python producers are '
        'retained losslessly as data and replaced by explicit stubs; every runtime input remains '
        'unchanged and every original producer byte/mode is independently recoverable.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish.py',
        granularity='Each actual named lowerer/descriptor/parser/generated payload, exact pure historical '
            'replacement string and post-return mutation, every current source/header/question row, '
            'complete book/include population and affected rendered pages; original whole208/full39111 replay.',
        result='Scoped native/history/current-source/rendered review and exact prior publisher replay PASS. '
            'Focused doctrine/history/memory checks and normal hooks govern this ordinary documentation leaf.'),
    falsify=dict(status='checked', hypothesis='A synchronized current document could retain a removed selector, '
        'nest originally spliced groups, confuse whole text with one group, drop the optional value/tag, '
        'claim full snapshot alias equivalence, or pass a heading/link check without rendered target content.',
        oracle='Exact retired LinkedSpec-owned callback source and isolated emitted snippet values; '
            'independent fixed payload expectations across actual public/parser/generated observations; '
            'current recipe-to-executed-source equality, independent full Knowledge header/code-span reader '
            'and actual decoded rendered HTML/anchor/native-example equality.',
        red_control='Actual old selector probes reject aggregate_selector_removed; retired calls remain '
            'RAW_PERL. Five actual alternate native shapes fail the independent intended payload oracle '
            'and each original passes restoration. Historical live accumulator changes after mutation '
            'while the current demonstrated snapshot does not; m/ma nesting counterexamples differ. '
            'Actual changed-heading render omits the target anchor despite exit0; healthy render restores it.'),
    durability=dict(status='checked', mode='live', inputs=bindings))
record = dict(version=1, owner=c.OWNER, claims=[claim])
display = dict(record)
display['claims'] = [dict(claim)]
display['claims'][0]['durability'] = dict(claim['durability'], inputs='__BINDINGS__')
raw = json.dumps(display, indent=1).replace('"__BINDINGS__"', '[\n' + ',\n'.join('     ' + json.dumps(item, separators=(',', ':')) for item in bindings) + '\n    ]')
raw = (raw + '\n').encode()
assert json.loads(raw) == record and len(raw) <= 131072
if sys.argv[1:]:
    first = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'first-draft.json.gz')).read_bytes()))
    assert (c.ROOT / c.CLAIM).read_bytes() == c.decode(first['original']['base64']), 'whole original draft preserved before replacement'
    (c.ROOT / c.CLAIM).write_bytes(raw)
    c.write_new(c.PREFIX + 'publication-final-preflight.json', dict(result='PASS', bytes=len(raw), input_count=len(bindings),
        draft_base64=c.encode(raw), draft_sha256=c.sha(raw), input_modes=modes,
        current=current, first_draft=draft, prior_summary=dict(result=prior['result'], supplied_inputs=208, original_claim_bytes=39111)))
else:
    assert (c.ROOT / c.CLAIM).read_bytes() == raw
print('Current migration publication PASS:', len(bindings), 'inputs;', len(raw), 'bytes;17 payloads;five controls;prior208/full39111')
