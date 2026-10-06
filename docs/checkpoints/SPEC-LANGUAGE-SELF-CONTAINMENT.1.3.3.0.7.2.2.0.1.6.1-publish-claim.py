"""Bind the complete retained composition producers, inputs and publication."""
from pathlib import Path
import hashlib
import importlib.util
import json
import types

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
BASE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.'


def read(path):
    return json.loads((ROOT / path).read_bytes())


def main():
    evidence = read(PREFIX + 'verification.json')
    book = read(PREFIX + 'book-verification.json')
    supplement = read(PREFIX + 'supplement-verification.json')
    assert evidence['complete'] and book['complete'] and supplement['complete']
    assert len(evidence['controls']) == 320 and len(book['controls']) == 63 and len(supplement['controls']) == 5
    paths = {path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if path.is_file()}
    seen = set()
    def walk(module):
        if id(module) in seen: return
        seen.add(id(module))
        source = getattr(module, '__file__', None)
        if source is None: return
        try: relative = Path(source).resolve().relative_to(ROOT)
        except ValueError: return
        paths.add(relative.as_posix())
        for value in vars(module).values():
            if isinstance(value, types.ModuleType): walk(value)
    spec = importlib.util.spec_from_file_location('composition_claim_inputs', ROOT / (PREFIX + 'review.py'))
    review = importlib.util.module_from_spec(spec); spec.loader.exec_module(review); walk(review)
    for suffix, files in {
        '1.2.0': ['cases.json', 'probe.pl'], '1.2.1': ['observations.json'],
        '2.0': ['cases.json'], '2.2': ['probe.pl', 'identity-probe.pl'], '2.3': ['observations.json'],
        '3.0': ['cases.json', 'oracle.py', 'review-cases.json', 'original-oracle-control.py', 'original-oracle-control.json'],
        '3.2.1': ['probe.pl'], '3.2.0.1': ['frames-probe.pl'], '3.3': ['observations.json'],
        '4.0': ['cases.json', 'inventory.json'], '4.6': ['cases.json', 'probe.pl'], '4.7': ['observations.json'],
        '5.0': ['cases.json', 'inventory.json', 'probe.pl'], '5.3': ['after-observations.json'],
        '5.4': ['observations.json'], '1.1.0': ['capture.py'], '1.1.2': ['guard-probe.pl'],
        '6.0': ['cases.json', 'retry-probe.pl', 'observations.json', 'retry-observations.json', 'verification.json'],
    }.items():
        paths.update(BASE + suffix + '-' + name for name in files)
    paths.update(entry['path'] for entry in read(PREFIX + 'book-inputs.json')['entries'])
    paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/knowledge').glob('*.md')
                 if path.name in {
        'perl-all-producer-source-composition.md', 'perl-all-producer-source-acceptance.md', 'perl-basic-family-mixed-source-provenance.md',
        'perl-pipeline-statement-source-provenance.md', 'perl-pipeline-regex-source-provenance.md',
        'perl-flow-recursive-source-provenance.md', 'perl-legacy-family-source-acceptance.md',
        'perl-dedicated-family-source-acceptance.md', 'perl-helper-source-provenance-channel.md',
        'scanner-rule-family-architecture.md'})
    paths.update(['tools/project_data_run.sh', 'tools/run_python_project_data.sh',
                  'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.0.json'])
    bindings = []
    for path in sorted(paths):
        source = ROOT / path
        assert source.is_file() and not source.is_symlink(), path
        bindings.append({'path': path, 'sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
                         'role': 'producer' if source.suffix in ('.py', '.pl', '.sh') else 'input'})
    statement = 'Fresh immutable56c8f38 supplies4745 regular committed inputs/no overlays and26 guarded commands. All174 disjoint selected contract IDs retain436 events/origins and46 MethodExpr/CSV frames per seed with exact complete previous compiler/callback/origin channels under seeds0/1/42. Seven representatives retain49 ordered nested pairs/42 off-diagonal pairs/seven fatal routes per seed. All29 unchanged suites pass1440 ordered groups;320 effective exact-reason evidence RED. Original151 hashes freeze mode/revision only with five supplemental RED; book58/32/four chapters/63 RED. Exact staged canonical receipt/normal hooks independently gate private .1.6/.0.1 closeout.'
    scope = 'Fresh complete regular immutable Git superset at56c8f38d12a799e4f4fb8c5b0cfe27690d27f1fc without overlays, production/spec/test replacements or owner deltas. Original independently authored Basic20/pipeline19/Flow16/Legacy112/dedicated7 selected ID partitions are disjoint across five corpora and retain49/69/49/227/42 events and origins per seed. Full earlier compiler/callback/origin channels and separate46 MethodExpr/CSV frames recur byte-for-byte; physical statement frames count authored sources separately. Actual returned/construction/event/argument identities and scalar intervals preserve occurrence and family order without raw-search pairing or global sorting. Real nesting covers seven representatives/49 ordered pairs/seven caught fatal routes per seed, not all174 IDs or arbitrary callbacks. The original rejected fatal visitor/display/mutation/routing instruments and historical Flow/pipeline adjudications remain unchanged. Original151 hashes verify before changing only prior durability mode/revision; current Knowledge routing uses fresh recurrence. Runtime inputs recover from all4745 regular Git blobs through retained object/content/mode/member/hash manifests, guarded before/after every actual command. This conservative supplied superset is not minimal observed IO. Transitive independent reviewer/oracle producers, earlier full channels and complete book publication inputs/capsules remain byte-bound. Compiler channels include parser construction without implying additional parser execution; rendered32 teaching examples are not additional runtime execution. Three controlled seeds do not establish other hosts. Required Phase0 and broad closeout are independently required in exact staged canonical CI before private parent landing; this record publishes no canonical CI measurement. Executable quoted/comment membership .0.2, selected replacement .0.3, recurring executable repair .0.4 and separately owned token/order/effects/restoration/boolean/cursor/resource/marker/mark-copy/wrapper defects remain open; recovery/purge prohibited. No helper/public-event/static-policy/admission/backend/CI/storage/dependency/global-audit/other-repository expansion. Necessary OS/Perl/Python/mdBook/toolchain prerequisites read-only; all project data repository-local on same volume. Gitlink/nonregular payloads excluded; RGX/PGEN remain public-integration black boxes and other repositories read-only.'
    record = {'version': 1, 'owner': OWNER, 'claims': [{
        'name': 'immutable-original-all-producer-and-representative-acceptance',
        'statement': statement, 'scope': scope,
        'rederive': {'status': 'checked',
            'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + name for name in
                ('capture.py', 'review.py', 'freeze.py', 'supplement-review.py', 'book.py --review')),
            'granularity': '4745 immutable regular inputs/zero overlays/26 commands;174 disjoint selected IDs/436 events and origins/46 MethodExpr and CSV frames per seed;seven representatives/49 ordered nested pairs/42 off-diagonal pairs/seven fatal routes per seed;29 suites/1440 groups/320 evidence RED;151 original hashes/five supplemental RED;58 book inputs/32 rendered examples/four chapters/63 book RED.',
            'result': statement},
        'falsify': {'status': 'checked',
            'hypothesis': 'Equal raw text, cloned references, cross-family recorder/callback/order/error leakage, changed full compiler channels, wrong aggregation grain or truncated input/TAP evidence could falsely accept producer composition; historical refresh or vacuous rendered controls could hide failed evidence.',
            'oracle': 'Unchanged original independently authored scalar/event/argument populations, separately adjudicated Flow literal expectation, actual returned/construction references, complete earlier channels and registry/dependency order; seven representative source literals, real nested/fatal scans, strict full TAP/input/channel guards. Original first-defined order oracle actually rejects all three contaminated fatal probe channels before instrument-only repair.',
            'red_control': '320 effective exact-reason controls corrupt all49 nested pairs in five ways, all seven fatal routes/repeated origins/references/arrays/order/callbacks, opaque/empty/recorder behavior, complete producer/channel/command/input/mode/TAP/original compiler evidence and repository-local input-tree identity. Five supplemental controls reject rewritten original statements/bindings, lost population or forged freeze producer/channels. All63 book controls effectively lose examples/teaching/scopes/current acceptance command/canonical boundary or forge/omit render channels/guards.'},
        'durability': {'status': 'checked', 'mode': 'live', 'inputs': bindings}}]}
    output = ROOT / ('docs/claims/' + OWNER + '.json')
    raw = (json.dumps(record, indent=2) + '\n').encode()
    assert len(raw) <= 131072, 'bounded claim record'
    output.write_bytes(raw)
    print(str(len(bindings)) + ' exact retained producer/input/publication bindings; ' + str(len(raw)) + ' claim bytes')


if __name__ == '__main__': main()
