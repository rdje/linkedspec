"""Bind private membership measurement producers, closed inputs and teaching."""
from pathlib import Path
import hashlib
import importlib.util
import json
import types

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
read = lambda suffix: json.loads((ROOT / (PREFIX + suffix)).read_bytes())
evidence, supplement, book = [read(suffix) for suffix in
    ('verification.json', 'supplement-verification.json', 'book-verification.json')]
assert all(value['complete'] for value in (evidence, supplement, book))
assert supplement['initial_warning_retained'] and supplement['unchanged_host_remeasurement']
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


spec = importlib.util.spec_from_file_location('membership_claim_producer_closure', ROOT / (PREFIX + 'review.py'))
review = importlib.util.module_from_spec(spec); spec.loader.exec_module(review); walk(review)
paths.update(entry['path'] for entry in read('book-inputs.json')['entries'])
paths.update([
    review.OWNER, review.capture.FIXTURE, review.oracle.REPRESENTATIVES,
    'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
    'docs/knowledge/perl-executable-source-membership.md',
    'docs/knowledge/perl-all-producer-source-acceptance.md',
    'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.1.json',
])
bindings = []
for path in sorted(paths):
    source = ROOT / path; assert source.is_file() and not source.is_symlink(), path
    bindings.append({'path': path, 'sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
                     'role': 'producer' if source.suffix in ('.pm', '.py', '.pl', '.sh', '.t') else 'input'})
metrics = evidence['metrics']
statement = ('Private membership selects47 of68 original syntactic events per seed across36 authored sources. '
    'Original unfiltered baseline fails20 complete groups; selector passes41 groups under seeds0/1/42. '
    'Eight unchanged consumers pass321 ordered groups. Seventeen effective evidence RED, four actual distinguishing '
    'producer RED and five supplemental evidence RED; original141 hashes freeze mode/revision only with five RED. '
    'Book58 supplied inputs/35 rendered examples/four chapters/68 RED. Initial startup warning and actual rejection '
    'remain retained; unchanged host remeasurement is accepted. Compiler and public substitution remain unchanged.')
scope = ('Unused private SourceMembership only. Actual scanner events, arguments and origins retain their original references '
    'and precise original scalar intervals. Original source/scan, complete original producer/public intake channels, '
    'family order and unchanged result identity persist. Source authority requires exact source and actual event reference; '
    'foreign/missing/copied origins grant none. Matching-source malformed spans reject. Quote delimiters can begin genuine '
    'literal receiver events, and existing MethodExpr host quotes/helper pattern/numeric-slash contracts remain authoritative. '
    'Comments remain separately owned; ignoring comment quote delimiters here is compatibility, not comment membership. '
    'The36-source corpus and seven representative producer families do not establish all174 contracts or arbitrary callbacks. '
    'Indexed quote and numeric slash fixture sources are scanner controls, not new native grammar admission. '
    'No native/fresh parser execution, compiler collection repair, precise source replacement, diagnostic/comment parent '
    'closeout or backend/admission/CI/storage/dependency expansion follows. Supplied inputs reconstruct4764 regular committed '
    'Git blobs at5f700625ef4bce962285ece583b088c457f2dd63 plus six before/seven after new authored overlays, with '
    'object/content/mode/member hashes and complete guards before/after11 actual commands per phase. This conservative '
    'supplied superset is not minimal observed IO; Gitlink/nonregular payloads excluded. Mutants use only a declared '
    'new-owner replacement in independent project-local trees. All full stdout/stderr and actual exits are recoverable. '
    'Original warning/rejection and original pre-extra-guard fixture/root TAP remain historical preliminary evidence; '
    'current acceptance uses the unchanged final41-group producer/oracle and approved host. Known startup .7 remains '
    'open, recovery/purge prohibited. Prior141 input hashes/statements/artifacts stay frozen at5f700625 before book/card '
    'changes. Three controlled hash seeds do not establish other hosts. Teaching examples are rendered, not extra runtime '
    'measurements. Necessary OS/Perl/Python/mdBook prerequisites are read-only; all project data same-volume repository-local. '
    'RGX/PGEN remain published-integration black boxes and every other repository read-only.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'private-original-source-membership',
    'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
        'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + name for name in
            ('retry-capture.py before', 'retry-capture.py after', 'review.py', 'mutants.py',
             'freeze.py', 'supplement-review.py', 'book.py --review')),
        'granularity': json.dumps(metrics, sort_keys=True) + '; complete supplied regular Git inputs and declared new overlays; original/full selected channels per seed; complete TAP groups, source/reference guards and rendered teaching.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'An equal-raw association, lost original references, masked literal receiver opener, numeric slash misclassification, caller-error leakage or truncated/changed producer/input/channel evidence could falsely establish executable source membership.',
        'oracle': 'Independently authored scalar source pieces, arguments, interval order and exact event populations; actual original event/argument/origin references and malformed/missing/foreign/copied authority controls. Complete unchanged original/public channels and ordered direct-consumer TAP. The original quiet-channel oracle actually rejects the retained83-byte baseline setpgid warning despite exit0.',
        'red_control': 'Seventeen reason-specific effective evidence corruptions reject; four actual source variants lose literal receivers, treat numeric slash as pattern, pair equal raw events or leak caller error and reach complete41-group distinguishing RED. Five supplemental mutant-evidence corruptions reject. Five mode/revision-only historical freeze corruptions reject;68 effective rendered controls reject lost examples/scopes/authority/commands or forged channels/guards.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': bindings}}]}
raw = (json.dumps(record, indent=2) + '\n').encode()
assert len(raw) <= 131072
(ROOT / ('docs/claims/' + OWNER + '.json')).write_bytes(raw)
print(str(len(bindings)) + ' complete producer/input/publication bindings; ' + str(len(raw)) + ' claim bytes')
