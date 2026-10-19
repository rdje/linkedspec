"""Current readonly authority/model publication; explicit one-shot initial capture."""
import json
import sys
from pathlib import Path
import common as c
import review
import vocabulary_controls

assert sys.argv[1:] in ([], ['--capture'])
result = review.review()
controls = vocabulary_controls.controls()
assert result['result'] == controls['result'] == 'PASS'
assert review.load('vocabulary-controls-inputs.json')['producer'] == c.read(c.PREFIX + 'vocabulary_controls.py')
assert review.load('vocabulary-controls.json') == controls
paths = {path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / c.PREFIX).iterdir()
         if path.is_file() and path.name != 'publication.json'}
source = review.load('source-inputs.json.gz')['inputs']
paths.update(path for path in source if path.startswith('perl/'))
paths.update(review.load('book-inputs.json.gz')['inputs'])
paths.update(review.load('docs-proposals.json.gz')['proposals'])
paths.update(['KNOWLEDGE_MAP.md', c.OLD_CLAIM,
    'docs/checkpoints/type-reference-migrations/normalize_inc.py',
    'docs/checkpoints/knowledge-fields/metadata_oracle.py',
    'tools/check_language_capability_coverage.pl',
    'dart/lib/src/action/action_contracts.dart', 'julia/src/action/ActionContracts.jl',
    'lua/src/linkedspec/action_call_names.lua', 'lua/src/linkedspec/action_contracts.lua',
    'rust/linkedspec-runtime/tests/corpus/manifest.json'])
manifest = json.loads((c.ROOT / 'rust/linkedspec-runtime/tests/corpus/manifest.json').read_bytes())
paths.update('rust/linkedspec-runtime/tests/corpus/' + name + '/input.spec' for name in manifest['cases'])
paths.update('capability_conformance/' + name + '_contract.json' for name in
    ('uniform_binding', 'scalar_text', 'scalar_numeric', 'logical_helper', 'callable_codeblock',
     'callable_signature', 'typed_source_location', 'complete_named_mark', 'inter_match_gap_capture'))
paths.update(path for path in review.load('graph-inputs.json.gz')['inputs']
             if not path.startswith(('docs/knowledge/', 'docs/decisions/')))
preserved = review.load('preservation.json.gz')
for key, item in preserved['live'].items():
    if key != c.OLD_CLAIM + '#0':
        paths.add(key.rsplit('#', 1)[0])
        paths.update(item['inputs'])
bindings, modes = [], {}
for path in sorted(paths):
    item = c.read(path)
    bindings.append(dict(path=path, sha256=item['sha256'],
        role='producer' if Path(path).suffix in ('.py', '.pl', '.sh') else 'input'))
    modes[path] = item['mode']
claim = dict(name='authority-population-and-value-model',
    statement='The bounded type-reference prerequisite retains1300 owned source/contract/test/book inputs '
        'before inventory commands. Four binding kinds are scalar, array, harray and codeblock; '
        'integer/real notation creates no separate binding namespace. Primitive string/number/boolean/null '
        'remain distinct. Fourteen named public descriptor/Get/fresh-generated cases include70 exact '
        'neutral scalar fields;11 independent distinguishing cases isolate two still-unfixed Perl '
        'defects with prioritized repair owners. Current250 shared call names and126 independently '
        'derived public generic Perl contracts pass presence checks; these are not complete operation '
        'counts or semantic parity. Actual private-name promotion passes report mode but rejects strict '
        'mode and restores exactly. Current Knowledge source/code-span review and complete book render '
        'pass with an actual changed-heading denial. Whole original396-input/full68960 migration '
        'publication replays with exact original channels and all supplied bytes/modes unchanged.',
    scope='Authority/model prerequisite only, at real cf4dceccd source boundary plus explicit current '
        'documentation proposals. Source population is a conservative custody superset, not a full-reading '
        'audit. Public execution is Perl only, including separately loaded generated source. Zero '
        'fallback metadata does not detect the scoped unsupported-call sentinel. Early scalar snapshot '
        'and scoped-with callable defects remain scheduled P1 .1.2.3/.1.2.4 before enumeration. Existing '
        'private receiver/boolean issues retain their owners. Source registry presence does not admit '
        'private helpers, all operations/spellings, book depth or cross-backend semantics. Prior migration '
        'claim frozen only by mode/revision at actual accepted cf4dceccd; all original results remain '
        'immutable and the whole original live target is supplied to its unchanged reader. The first '
        'documentation writer failed on an index lacking front matter before bound writes; exact original '
        'source, first combined log and distinct full-channel recurrence precede a separate corrected '
        'writer. No runtime, contract, gate, budget, exhaustive type reference or parent admission.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish.py',
        granularity='Every retained source identity; each named descriptor/live/generated value and primitive '
            'kind; each neutral scalar expected field; complete current Knowledge headers/questions and '
            'book/include population; whole original migration publication.',
        result='Independent value-kind/custody review, strict vocabulary/private controls, current graph, '
            'healthy/changed-heading book and exact supplied prior replay PASS; two runtime defects '
            'remain explicitly uncorrected and owned.'),
    falsify=dict(status='checked', hypothesis='Vocabulary presence or zero fallback could falsely imply '
        'healthy complete semantics; Python numeric equality could erase boolean kind; private vocabulary '
        'could be promoted or an authority omitted while counts and reports still look healthy.',
        oracle='Unchanged neutral scalar expectations with recursive primitive-kind checks; independent '
            'native named-function/rvalue/saved-binding/explicit-parameter controls and actual emitted '
            'source; unchanged strict vocabulary checker; accepted Git authorities and rendered anchors.',
        red_control='Captured callback cases reject early-value/callable expectations and have distinct '
            'healthy controls. False-vs0 and true-vs1 reject. Removing the callable authority rejects the '
            'independent required population. Actual dispatch_span promotion in all three registries '
            'has report exit0 but strict nonzero; exact restoration reproduces original channels. '
            'Actual changed-heading build exits0 but loses the required anchor; healthy render restores it.'),
    durability=dict(status='checked', mode='live', inputs=bindings))
record = dict(version=1, owner=c.OWNER, claims=[claim])
display = dict(record, claims=[dict(claim, durability=dict(claim['durability'], inputs='__INPUTS__'))])
raw = json.dumps(display, indent=1).replace('"__INPUTS__"', '[\n' + ',\n'.join(
    '     ' + json.dumps(item, separators=(',', ':')) for item in bindings) + '\n    ]')
raw = (raw + '\n').encode()
assert json.loads(raw) == record and len(raw) <= 131072, ('claim capacity', len(raw), len(bindings))
if sys.argv[1:]:
    assert not (c.ROOT / c.CLAIM).exists()
    with (c.ROOT / c.CLAIM).open('xb') as output:
        output.write(raw)
    c.write_new(c.PREFIX + 'publication.json', dict(result='PASS', record_base64=c.encode(raw),
        record_sha256=c.sha(raw), input_modes=modes, review=result,
        private_control='Actual report0, strict RED, exact source/channel restoration'))
else:
    assert (c.ROOT / c.CLAIM).read_bytes() == raw
print('Current type authority/model publication PASS:', len(bindings), 'inputs;', len(raw), 'bytes; runtime repairs3/4 pending')
