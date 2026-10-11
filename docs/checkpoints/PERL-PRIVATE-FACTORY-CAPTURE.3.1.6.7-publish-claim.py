"""Finite change-history publication; default readonly, --capture is one-shot."""
import json
import sys
from pathlib import Path
import importlib.util

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
spec = importlib.util.spec_from_file_location('capacity', ROOT / (PREFIX + 'capacity.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
assert sys.argv[1:] in ([], ['--capture'])
target = ROOT / ('docs/claims/' + LEAF + '.json')
result = m.command(['python3', PREFIX + 'review.py'])
assert result['exit_code'] == 0 and result['stderr']['bytes'] == 0, result
if sys.argv[1:]:
    assert not target.exists() and not (ROOT / (PREFIX + 'final.json')).exists()
    m.save('final.json', result)
else:
    assert m.load('final.json') == result, 'actual complete readonly review'
plan = m.load('plan.json')
book = m.load('book-review.json')
assert len(plan['preserved']) == 226
assert plan['measured'] == {
    'change_history': {'files': 50, 'lines': 52037, 'bytes': 3993010},
    'decisions': {'files': 135, 'lines': 13250, 'bytes': 985463},
    'manifest': {'lines': 49, 'bytes': 27983}}
paths = set(plan['preserved']) | set(plan['resulting_inputs']) | set(book['source_inputs'])
paths.add('docs/knowledge/guarded-ast-change-history-capacity.md')
old_claim = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4.json'
old_publisher = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4-publish-claim.py'
paths.add(old_claim)
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
inputs = [{'path': p, 'sha256': m.sha(m.read(p)),
           'role': 'producer' if Path(p).suffix in ('.py', '.pl') else 'input'} for p in sorted(paths)]
statement = ('One finite change-history member and exact manifest/decision overhead are verified against clean6392b8a651. '
    'Segment4963 preserves the complete223-line/36819-byte suffix at source lines238–460. '
    'The resulting root is239 lines/20160 bytes. All226 prior history/decision files remain exact. '
    'Actual464-line pressure and old admission REDs,30 unchanged production threshold observations,23 accepted/indexed/'
    'exact-object authority denials, four current reviewer REDs and two preservation REDs each restore PASS. '
    'All329 original array-end bindings/full claim fields remain historical at the clean activation, with actual '
    'accepted publisher baseline retained. Complete book57 sources plus32 recursive includes and three actual '
    'render controls pass. Exact staged canonical CI/receipt separately governs capacity admission.')
scope = ('Exactly one archive member: files49→50; manifest48→49 lines and27407→27983 bytes; sole ADR0134/index '
    'overhead files134→135 and13215→13250 lines. Root/per-file/aggregate/unrelated limits, accepted immutable bytes '
    'and runtime/checker/dependency behavior remain exact; no future reserve. The original applied producer listed '
    'changes twice and omitted46 engineering-history inputs: its exact180-member plan/source/controls/reached '
    'observations remain retained, and a separate late extension verifies all46 unchanged accepted Git inputs. '
    'The first census correction equality correctly rejected a mutant before its expected later reason; the failed '
    'reached envelope remains exact. Current readonly reconstruction preserves the original plan and orders '
    'field-specific checks before correction equality; fresh evidence uses a distinct producer. The first book '
    'capture read the correct chapter but enumerated the old DSL basename; its independent reader rejected the '
    'actual wrong path census. Original producer/capture/reader and tool-return transcription remain exact; the '
    'corrected capture is distinct. Original supplied temporary outputs and outer transport envelopes are unavailable '
    'and explicitly disclosed; no original observation/hash is refreshed or incomplete draft accepted. Authority '
    'controls execute actual unchanged functions with in-memory ADR/index faults. No new runtime, benchmark, '
    'full-private or parent admission is claimed. Hash-index .3.1.6.5 resumes after canonical landing; fixture '
    'registration .7 precedes pipeline .6 and TYPE-REFERENCE-BOOK remains queued.')

primary = {'name': 'finite-change-history-member', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; separately review.py, '
            'capacity.py review, reviewer-repair.py, evidence.py, preservation-controls.py and book-review.py '
            'with that wrapper. Defaults readonly. Applied/draft/capture/freezer/correction producers and '
            '--capture/--apply writers are one-shot and are not resume entrypoints.',
        'granularity': 'Every226 prior file and entire clean-Git suffix/blob/range/digest; every original manifest '
            'row and exact new row/header; exact registry/sole indexed decision; all30 thresholds/23 authority '
            'cases, four named reviewer and two preservation mutant/restored populations/full channels;329 '
            'original Git bindings/full claim;89 book inputs/modes/recursive includes and three actual controls; '
            'complete original180-member draft and46-file extension, first failed reason envelope and original '
            'wrong book census with sole basename repair; existing card body/questions retained.', 'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Extra capacity could pass without exact accepted/indexed authority, excess usage could fit, '
            'or an omitted engineering-history member/forged identity could hide behind immediate metadata or a '
            'draft PASS label and wrong rendered chapter census.',
        'oracle': 'Independent accepted-Git reconstruction and exact field/byte equality; actual unchanged '
            'production threshold/authority functions; reason-sensitive subprocesses and exact restoration; '
            'complete original claim plus historical Git hashes; independent recursive book/input/path/marker '
            'reader and retained failed drafts.',
        'red_control': 'Actual next-record --check and old routing admission reject. Five production dimensions '
            'reject old-bound usage and new-limit-plus-one while exact new boundaries pass;23 authority denials '
            'reject missing/unindexed/proposed/missing/duplicate/wrong-object/unreviewed increases. Four actual '
            'reviewer corruptions reject missing prior member, specifically missing engineering-history input, '
            'forged original and resulting SHA. Two beyond-immediate-SHA preservation corruptions reject '
            'original-binding and preserved-statement drift. Every current RED restores exactly. The first book '
            'reader actually rejects the wrong chapter census; corrected full rendering additionally rejects '
            'missing SUMMARY, loses changed prose and diagnoses missing include despite exit0. Original failed '
            'census reason assertion and its child RED remain retained without a full-PASS claim.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}

def historical(name, statement, source_inputs, command, red):
    return {'name': name, 'statement': statement,
        'scope': 'Exact original accepted Git inputs at6392b8a651; no original identity or observation refresh.',
        'rederive': {'status': 'checked', 'command': command,
            'granularity': 'Every original Git input/full original claim at the accepted revision.', 'result': statement},
        'falsify': {'status': 'checked', 'hypothesis': 'Updated immediate metadata could conceal original drift.',
            'oracle': 'Independent accepted Git bytes and exact full-record comparison.', 'red_control': red},
        'durability': {'status': 'checked', 'mode': 'historical', 'revision': m.BASE, 'inputs': source_inputs}}

original_inputs = [{'path': p, 'sha256': h,
                    'role': 'producer' if Path(p).suffix in ('.py', '.pl') else 'input'}
                   for p,h in sorted(plan['original_inputs'].items())]
original_publication = [{'path': p, 'sha256': m.sha(m.old(p)),
                         'role': 'producer' if p == old_publisher else 'input'} for p in (old_claim, old_publisher)]
data = {'version': 1, 'owner': LEAF, 'claims': [primary,
    historical('original-capacity-input-boundary', 'All nine original mutable/support inputs remain exact at '
        'clean6392b8a651; the complete clean-source suffix is independently reconstructed.', original_inputs,
        'bash tools/run_python_project_data.sh ' + PREFIX + 'capacity.py review',
        'Actual forged original SHA rejects; exact restoration passes with complete channels.'),
    historical('original-array-end-publication-boundary', 'All329 predecessor live bindings and full original '
        'claim fields remain exact; only its first live durability mode/revision becomes historical at6392b8a651. '
        'The actual accepted publisher baseline is retained; earlier historical hash preservation remains exact.',
        original_publication, 'bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-controls.py',
        'Two actual beyond-immediate-SHA REDs reject original binding and preserved statement drift; each restores.') ]}
raw = (json.dumps(data, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded claim', len(raw))
if sys.argv[1:]:
    target.write_bytes(raw)
else:
    assert target.read_bytes() == raw, 'publication or inputs drift'
print('Finite change-history publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes; readonly')
