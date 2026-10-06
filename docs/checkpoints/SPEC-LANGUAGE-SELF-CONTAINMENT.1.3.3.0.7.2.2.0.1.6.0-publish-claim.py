"""Bind the complete retained composition producers, inputs and publication."""
from pathlib import Path
import hashlib
import importlib.util
import json
import types

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
BASE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.'


def read(path):
    return json.loads((ROOT / path).read_bytes())


def main():
    evidence = read(PREFIX + 'verification.json')
    book = read(PREFIX + 'book-verification.json')
    supplement = read(PREFIX + 'supplement-verification.json')
    assert evidence['complete'] and book['complete'] and supplement['complete']
    assert len(evidence['controls']) == 320 and len(book['controls']) == 61 and len(supplement['controls']) == 7
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
    }.items():
        paths.update(BASE + suffix + '-' + name for name in files)
    paths.update(entry['path'] for entry in read(PREFIX + 'book-inputs.json')['entries'])
    paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/knowledge').glob('*.md')
                 if path.name in {
        'perl-all-producer-source-composition.md', 'perl-basic-family-mixed-source-provenance.md',
        'perl-pipeline-statement-source-provenance.md', 'perl-pipeline-regex-source-provenance.md',
        'perl-flow-recursive-source-provenance.md', 'perl-legacy-family-source-acceptance.md',
        'perl-dedicated-family-source-acceptance.md', 'perl-helper-source-provenance-channel.md',
        'scanner-rule-family-architecture.md'})
    paths.update(['tools/project_data_run.sh', 'tools/run_python_project_data.sh',
                  'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.4.json'])
    bindings = []
    for path in sorted(paths):
        source = ROOT / path
        assert source.is_file() and not source.is_symlink(), path
        bindings.append({'path': path, 'sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
                         'role': 'producer' if source.suffix in ('.py', '.pl', '.sh') else 'input'})
    statement = 'Immutable37401 supplies4708 regular committed inputs plus exactly two authored observation inputs per tree;26 original-population commands and three corrected nested commands retain174 disjoint selected contract IDs/436 events and origins per seed,46 MethodExpr/CSV frames and complete prior compiler/callback/origin channels under seeds0/1/42. Seven representatives verify49 ordered nested pairs/42 off-diagonal pairs/seven fatal routes per seed;29 unchanged suites pass1440 ordered groups. Independent320 evidence RED, three actual rejected initial fatal visitor channels,111-hash mode/revision-only freeze, three stale-route guard rejections/seven supplemental RED and book58/31/four chapters/61 RED are retained.'
    scope = 'Original Basic20/pipeline19/Flow16/Legacy112/dedicated7 selected ID partitions are disjoint across five retained independent corpora. Full prior selected producer channels recur byte-for-byte; historical Flow expectation and pipeline reference adjudications remain unchanged. Runtime boundaries reconstruct all4708 regular immutable Git inputs; exactly two new observation files overlay each tree without replacing production/spec/fixtures. The conservative supplied Git superset is not minimal observed IO. Object/content/mode/member guards cover every runtime command. The original fatal visitor probe is explicitly rejected; its separate corrected instrument alone substantiates outer-only order. Nested composition covers seven representatives, not all174 IDs or arbitrary callbacks. References are observed at actual producer return; constructor/custom callback coverage elsewhere is recurring fixture observation. Physical statement frames count authored sources, distinct from selected events and MethodExpr/CSV frames. Complete compiler channels include parser construction without implying additional parser execution. Three controlled seeds do not establish other hosts. Rendered teaching is not additional runtime execution. Initial CRLF display normalization and ineffective rendered mutation are independently retained/rejected. Historical current-source guards remain exact; current Knowledge routing uses new composition. Required Phase0 belongs to fresh canonical .1.6.1; this record publishes no new canonical CI measurement or private parent closure. Executable quoted/comment membership, selected replacement and separately owned token/order/effects/restoration/boolean/cursor/resource/marker/mark-copy/wrapper defects remain open; recovery/purge prohibited. No new helper/public event/static policy/admission/backend/CI/storage/dependency/global-audit/other-repository change. Gitlink/nonregular payloads excluded; RGX/PGEN public integration black boxes; necessary OS/Perl/Python/mdBook/toolchain prerequisites read-only, all project data repository-local on same volume. Every supplied runtime input recovers through the tracked Git-object/hash manifest and declared overlays; transitive independent reviewer/oracle producers, full earlier channels, all publication inputs/capsules and rejected instruments remain byte-bound.'
    record = {'version': 1, 'owner': OWNER, 'claims': [{
        'name': 'original-all-producer-population-and-representative-composition',
        'statement': statement, 'scope': scope,
        'rederive': {'status': 'checked',
            'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + name for name in
                ('capture.py', 'retry-capture.py', 'review.py', 'historical-routing.py', 'supplement-review.py', 'book.py --review')),
            'granularity': '4708 immutable regular inputs/two authored overlays per tree/29 runtime commands;174 disjoint selected IDs/436 events and origins per seed/46 MethodExpr and CSV frames per seed;seven representatives/49 ordered nested pairs/42 off-diagonal pairs/seven fatal routes per seed;29 suites/1440 groups;320 runtime evidence RED;three actual initial probe and three historical-route rejections;111 prior hashes/seven supplemental RED;58 book inputs/31 rendered examples/four chapters/61 book RED.',
            'result': statement},
        'falsify': {'status': 'checked',
            'hypothesis': 'Equal raw text, cloned references, cross-family recorder/callback/order/error leakage, changed full compiler channels, wrong aggregation grain or truncated input/TAP evidence could falsely accept producer composition; historical refresh or vacuous rendered controls could hide failed evidence.',
            'oracle': 'Unchanged original independently authored scalar/event/argument populations, separately adjudicated Flow literal expectation, actual returned/construction references, complete earlier channels and registry/dependency order; seven representative source literals, real nested/fatal scans, strict full TAP/input/channel guards. Original first-defined order oracle actually rejects all three contaminated fatal probe channels before instrument-only repair.',
            'red_control': '320 effective exact-reason controls corrupt all49 nested pairs in five ways, all seven fatal routes/repeated origins/references/arrays/order/callbacks, opaque/empty/recorder behavior, complete producer/channel/command/input/mode/TAP and original compiler evidence. Seven supplemental controls reject historical statement/binding/freeze/producer and stale-route corruption. All61 book controls effectively lose examples/teaching/scope or forge/omit render channels/guards; original CRLF oracle and vacuous literal mutation are retained rejected evidence.'},
        'durability': {'status': 'checked', 'mode': 'live', 'inputs': bindings}}]}
    output = ROOT / ('docs/claims/' + OWNER + '.json')
    raw = (json.dumps(record, indent=2) + '\n').encode()
    assert len(raw) <= 131072, 'bounded claim record'
    output.write_bytes(raw)
    print(str(len(bindings)) + ' exact retained producer/input/publication bindings; ' + str(len(raw)) + ' claim bytes')


if __name__ == '__main__': main()
