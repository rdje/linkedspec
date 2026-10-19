"""Current bounded source/input publication; default recurs readonly supplied proof."""
import copy
import json
import subprocess
import sys
from pathlib import Path
from common_final import ROOT, PREFIX, CLAIM, load, load_namespace, sha, encode, decode

import importlib.util
_artifact_spec = importlib.util.spec_from_file_location(
    '_pipeline_artifacts', ROOT / 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-artifacts/artifact.py')
_artifacts = importlib.util.module_from_spec(_artifact_spec)
_artifact_spec.loader.exec_module(_artifacts)
_route_spec = importlib.util.spec_from_file_location('_knowledge_route', ROOT / 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-knowledge-route/route.py')
_route = importlib.util.module_from_spec(_route_spec)
_route_spec.loader.exec_module(_route)
with _artifacts.materialized_original():
    assert sys.argv[1:] in ([], ['--preflight'], ['--capture'])
    transport = subprocess.run(['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-knowledge-route/review.py'], cwd=ROOT, capture_output=True)
    assert transport.returncode == 0 and not transport.stderr, ('artifact/current supplied proof', transport.stdout, transport.stderr)
    original = load()
    namespace = load_namespace(original)
    assert (ROOT / 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.7.json').read_bytes() == decode(
        namespace['inputs']['docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.7.json']['base64'])
    review = json.loads((ROOT / (PREFIX + 'current-review.json')).read_bytes())
    controls = json.loads((ROOT / (PREFIX + 'controls.json')).read_bytes())
    complete = json.loads((ROOT / (PREFIX + 'complete-replay.json')).read_bytes())
    assert review['result'] == controls['result'] == 'PASS' and len(controls['controls']) == 3
    assert complete['guarded_overlay_count'] == 786 and complete['all_overlay_bytes_and_modes_unchanged']
    assert complete['whole_claim_and_mode_unchanged'] and complete['returncode'] == 0
    paths = set(original['inputs'])
    paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / PREFIX).iterdir()
                 if path.is_file() and path.name not in ('publication-preflight.json', 'continuity.json', 'preserved.json.gz'))
    paths.update(['docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-standard-verification.py',
                  'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-standard-verification.json.gz',
                  'scripts/check_repo_root_path_portability.sh',
                  'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.7.json',
                  'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-continuity-repair.py',
                  'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-continuity-repair.json.gz'])
    paths.update(_artifacts.current_inputs())
    paths.discard(_artifacts.CARD)
    paths.update(_route.current_inputs())
    source_suffixes = {'.py', '.pm', '.pl', '.t', '.sh'}
    bindings, modes = [], {}
    for path in sorted(paths):
        source = ROOT / path
        assert source.is_file() and not source.is_symlink(), path
        bindings.append(dict(path=path, sha256=sha(source.read_bytes()),
                             role='producer' if source.suffix in source_suffixes else 'input'))
        modes[path] = source.stat().st_mode & 0o7777
    claim = dict(
        name='pipeline-invocation-scopes-with-complete-supplied-evidence-context',
        statement='RewritePipeline opens fresh producer/input scopes inside the original-source invocation '
            'before factories, and separately captures four actual dependencies plus canonical apply. '
            'Original native96/distinct9-row epochs and the actual public native factory remain frozen. '
            'The original426-input runtime epoch retains2065 assertions,13 exact syntax-valid semantic '
            'inverses with the same complete plan and91 suites/32235 assertions. Current2065 assertions '
            'pass with426 guarded inputs and only one lossless JSON encoding change. Original declared625 '
            'bindings/full123401 and161 omitted fixed claim inputs are preserved; unchanged original '
            'readers pass with all786 supplied overlays and whole claim/mode guarded. Current complete '
            'Knowledge1487/1349 facts/10453 keys/fifteen prior routes/one retained prior body/artifact facts in the existing canonical card/8386222 bytes and '
            'book89/four controls pass with every original rendered table exact. Three actual transport/'
            'closure artifact denials restore exact healthy bytes/modes; the unchanged path gate passes.',
        scope='Production/test sources stay exact to the original supplied runtime epoch. The current '
            'native record is a standard solidus-escaped JSON view: decoded values/arguments/observations '
            'are identical and its exact raw original is retained. Actual diagnostics are never normalized; '
            'the original fixture projects only the expected owned-module filename. The old625 figure '
            'was a declared binding count, not complete actual IO: unchanged review-runtime-final.py '
            'reads a fixed claim namespace omitted by review-current.py. The actual before-write161-input '
            'supplement and distinct failed/corrected replays close that gap. No Git revision is invented '
            'for the uncommitted625 draft; activation64b66167c only supplies explicitly fixed historical '
            'Git contexts. Older native, failed-instrument, merged early-GREEN and final separated-channel '
            'boundaries stay distinct. Original8 artifact denials remain in their exact restored context; '
            'three new denials govern current transport/closure. Whole captured Knowledge plus current15 '
            'overlays/map/config is independently regenerated on repository storage; other captured facts '
            'remain historical at64b66167c. No retired native/capture/preparation writer is replayed. '
            'The earlier667 preparation draft and its before sources remain recoverable inside '
            'the exact restored669 context. Four bounded parts retain all127191037 packed bytes; '
            'actual original669-reader use guards every input and whole claim. Current compatibility '
            'assembly is temporary and removed after verified use. Three effective part controls '
            'reject corruption, omission and order changes. No oversized blob or push is admitted. '
            'Observed wrapper warnings remain disclosed under SESSION-STARTUP-READING.7; no minimal IO, '
            'arbitrary-shell/kernel/lifecycle/recovery/purge or complete private/parent admission follows. '
            'Replacement algorithm, public DSL/maps/references/family order, selector, gate and budgets '
            'stay unchanged; output construction/composition, mapping and quoted-first repair remain owned.',
        rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py (readonly).',
            granularity='Complete original625 draft plus161 actual fixed claim inputs,786 guarded overlays '
                'and original whole claim/mode; exact original native/runtime/13 source inverses/91 '
                'consumer ledgers through unchanged readers; current2065/426; whole supplied1487-source '
                'Knowledge regeneration/check, fifteen routes/one body, full89-source book and four '
                'controls; exact original tables; three actual whole-file artifact denials/restorations.',
            result='All scoped supplied/current checks PASS. Ordinary focused syntax, complete wrapped '
                'Phase01035/1035 at unchanged production, history/memory/Knowledge/public surface and '
                'all normal doctrine hooks govern landing; no selector or gate source changes.'),
        falsify=dict(status='checked',
            hypothesis='Equal text could donate authority, altered native data could be relabeled as '
                'transport, or625 declared bindings could hide an undeclared current claim namespace.',
            oracle='Actual callback/event/origin/registry identities and authored Unicode intervals; '
                'complete raw native ledgers and exact source inverses; original whole claim/preflight '
                'and independent pre-transport custody; decoded equality plus byte inverse; actual fixed '
                'Git claim namespace and selected mode/revision-only freeze; fresh supplied map and '
                'every original rendered table.',
            red_control='Original1988/1128 semantic RED,13 complete-plan syntax-valid source inverses '
                'and8 original artifact denials remain exact. First restored625 replay actually rejects '
                'the missing .7 freeze; supplied161 context restores PASS. Retained earlier forgeries '
                'change an observed argument, restore unescaped transport, or omit a coherently '
                'relabeled fixed-namespace claim: all3 reject with named reasons and exact restoration. '
                'Unchanged original path gate rejects the original raw record; the current view passes. '
                'Four current supplied book controls retain command/marker/include REDs.'),
        durability=dict(status='checked', mode='live', inputs=bindings))
    record = dict(version=1, owner='PERL-PRIVATE-FACTORY-CAPTURE.6', claims=[claim])
    # Keep all bindings while making each machine-oriented binding one readable line.
    presentation = copy.deepcopy(record)
    token = '__COMPLETE_PIPELINE_BINDINGS__'
    presentation['claims'][0]['durability']['inputs'] = token
    value = json.dumps(presentation, indent=1)
    assert value.count(json.dumps(token)) == 1
    value = value.replace(json.dumps(token), '[\n' + ',\n'.join(
        '     ' + json.dumps(item, separators=(',', ':')) for item in bindings) + '\n    ]')
    value = (value + '\n').encode()
    assert json.loads(value) == record
    if sys.argv[1:] == ['--preflight']:
        print(json.dumps(dict(result='PASS' if len(value) <= 131072 else 'OVER_CAP',
            bytes=len(value), input_count=len(bindings), draft_sha256=sha(value),
            draft_base64=encode(value), input_modes=modes,
            producer_sha256=sha(Path(__file__).read_bytes()),
            scope='Actual complete serialized current draft, before replacing the original preserved '
                  'uncommitted625 claim. No field/input is omitted and no budget/revision is invented.'), indent=1))
        raise SystemExit(0 if len(value) <= 131072 else 1)
    assert len(value) <= 131072, (len(value), len(bindings))
    target = ROOT / CLAIM
    if sys.argv[1:]:
        assert target.read_bytes() == decode(original['claim_base64'])
        target.write_bytes(value)
    else: assert target.read_bytes() == value
    print('Current pipeline publication PASS:', len(bindings), 'live inputs;', len(value), 'bytes; original625+161 supplied')
