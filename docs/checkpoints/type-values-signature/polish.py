"""Keep every direct input while stating each current measurement's three legs concisely."""
import ast
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-signature/'
paths = (c.PREFIX + 'signature_records.py', c.PREFIX + 'publish_signature.py')
finished = json.loads(gzip.decompress((ROOT / (P + 'finish-proposals.json.gz')).read_bytes()))
before = {path: c.read(path) for path in paths}
assert all(item == finished['after'][path] for path, item in before.items())
records = c.decode(before[paths[0]]['base64']).decode()
anchor = "    current_sources = dict(composed['after'], **finished['after'])\n"
replacement = anchor + '''    polished = signature_load('polish-proposals.json.gz')
    assert polished['producer'] == c.read(S + 'polish.py')
    for path, item in polished['before'].items():
        assert current_sources[path] == item, path
    current_sources.update(polished['after'])
'''
assert records.count(anchor) == 1
records = records.replace(anchor, replacement, 1)
publisher = c.decode(before[paths[1]]['base64']).decode()
start = publisher.index('def make_claim(result, bindings):\n')
end = publisher.index('\ndef record_bytes(record):\n', start)
function = '''def make_claim(result, bindings):
    g, h = result['graph'], result['historical']
    return dict(name='perl-evaluated-list-values',
        statement=(
            'Perl emitted array/harray members, constructor operands, dynamic keys and callable '
            'arguments retain evaluated values across later effects. Accepted runtime rejects19 '
            'of23 cases; four controls stay healthy and candidate Get/fresh generated match all23. '
            f"The historical auditor reverses{h['fragments']} reviewed Phase0 fragments: "
            f"{h['original_denials']} original and{h['added_denials']} added denials pass. "
            'Archive134/full84613241,22 recovery controls and both isolated source-audit sides '
            'retain their calibrated original-log/tracked-write denial boundary.'),
        scope=(
            'Finite Perl repair from real c053 plus explicit proposals. Flat splices and existing '
            'copy-on-write semantics remain; exhaustive methods, cross-backend and private/parent '
            'admissions remain separately owned. Scoped-with4, numeric5, generated-drop6, startup '
            'boolean35 and caller-shadowing32 stay open. The focused52 snapshot retains1651 inputs, '
            'its original auditor and982 explicit skips. Current auditor evolution has independent '
            '184-input recovery proof and a separate original-control baseline with initial '
            'restored modes. The earlier outer baseline uses original log locations; its missing '
            'initial mode/guard observations remain disclosed and supplemental. Historical runtime '
            'observations, hashes and logs are unchanged. Wrong push oracle/first candidate, '
            'no-write writers, incomplete syntax2/TAP2, dated metadata count, three fixture compile '
            'errors, static publisher failures and the first new-control KeyError/two-reference '
            'correction remain recoverable. Drafts568/full91709,573/full92573 and649/full106855 '
            'retain whole records, original inputs/modes, changed-before bytes and actual readonly '
            'baselines without fabricated historical commits. Ordinary all1035, canonical exact '
            'staged receipt and normal hooks separately govern landing.'),
        rederive=dict(status='checked',
            command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish.py',
            granularity='Each23 JSON value/kind;277 selected test/data/bin inputs and seven suites; '
                'focused52 original names/numbers;130 historical/manual value/diagnostic goldens; '
                'actual producer faults; complete graph/list rows and89 book inputs; whole prior '
                'publication; full historical source inverse and actual isolated recovery controls.',
            result=(
                'Accepted19 RED/four controls; candidate23 GREEN; seven suites0; focused52 PASS/982 '
                'skips; observer129 RED/one null/restoration and missing-selector RED. '
                f"Graph{g['markdown']}/{g['facts']}/{g['question_keys']}, lists{g['list_items']}/"
                f"{g['list_fields']}, Knowledge{result['knowledge_bytes']} bytes. Book89/heading "
                'denial and whole accepted388/full68814 reader in2706 supplied files pass. '
                f"Historical{h['fragments']} fragments: original{h['original_denials']} + "
                f"added{h['added_denials']} = {h['current_denials']} denials;134 restored inputs, "
                '22 recovery controls,184 explicit proof inputs and both isolated denial guards '
                'pass. Semantic-JSON-preserving table byte fault rejects; reader restores.')),
        falsify=dict(status='checked',
            hypothesis='Earlier lvalues could be read late, snapshots could erase splices, an '
                'observer could return null or skip all roots, or missing inputs could look like '
                'behavioral RED. A historical inverse could forgive foreign edits or ignore table bytes.',
            oracle='Independent fixed23 values/kinds, saved-binding/host controls, accepted c053 '
                'source,106 historical expectations plus24 manual cases, original root names/numbers, '
                'complete original historical Git bytes/hash, unchanged archive/census and original '
                'control population; rendered anchor presence is distinct from build success.',
            red_control='Six actual emitter faults reject19/14/2/1/1/1 and restore. Actual observer '
                'bypass rejects129 goldens with one genuine null; healthy source restores52. Missing '
                'selector exits nonzero despite SKIPs. Changed heading builds0 but loses anchor. '
                'Original auditor rejects the reviewed Phase0 delta; each70 fragment is removed, '
                'duplicated and altered for210 added denials. Existing foreign-edit controls remain. '
                'A whitespace-only table byte change preserves valid/equal JSON but rejects by '
                'identity; restored reader accepts. Generated scalar-drop advisory/FATAL loading '
                'RED is separately owned by6; no warning policy changes.'),
        durability=dict(status='checked', mode='live', inputs=bindings))

'''
publisher = publisher[:start] + function + publisher[end:]
texts = dict(zip(paths, (records, publisher)))
for path, source in texts.items():
    ast.parse(source, filename=path)
after = {path: dict(base64=c.encode(source.encode()), sha256=c.sha(source.encode()), mode=before[path]['mode'])
         for path, source in texts.items()}
c.write_new(P + 'polish-proposals.json.gz', dict(before=before, after=after,
    producer=c.read(P + 'polish.py'),
    scope='Claim prose names each measurement/three legs and its custody limits once. '
          'Every direct producer/input binding and the unchanged131072-byte cap remain. '
          'No observation, counter, historical hash or runtime code changes.'), packed=True)
assert c.unchanged(before)
for path, item in after.items():
    (ROOT / path).write_bytes(c.decode(item['base64']))
    (ROOT / path).chmod(item['mode'])
    assert c.read(path) == item
print('Claim wording shortened with explicit historical re-derive/falsification and unchanged complete input bindings')
