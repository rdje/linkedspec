"""Publish native-frame proof and the separately owned original empty-span cause."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0-'
review = json.loads((ROOT / (PREFIX + 'review.json')).read_text())
assert review['result'] == 'PASS'
sources = set()
for suffix in ('final', 'consumers', 'toolbox'):
    sources.update(json.loads((ROOT / (PREFIX + suffix + '.json')).read_text())['inputs'])
sources.update(json.loads((ROOT / (PREFIX + 'empty.json')).read_text())['routes'][0]['inputs'])
sources.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*'))
sources.update(['tools/run_python_project_data.sh', 'tools/project_data_env.sh', 'tools/project_data_run.sh',
                'docs/knowledge/perl-private-ast-input-frames.md', 'docs/knowledge/perl-empty-ast-trim-span.md',
                'docs/knowledge/perl-private-ast-constructions.md', 'docs/knowledge/perl-private-input-authority-selection.md',
                'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md', PREVIOUS + 'actual.json',
                'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.1.json'])
statement = ('Native parser-relative root/call/array frames pass63 supplied-tree assertions and11 effective semantic source inverses. '
             'Actual CSV-returned occurrence frames and explicit parent/payload rebasing ignore public base_start and wrong compatibility search offsets, preserve public AST/callback semantics, and decline copied/changed/foreign/scoped/unsupported descendants. '
             'Eleven guarded live suites (including constructor77), three actual Toolbox routes and eight reason-sensitive evidence RED controls pass. Only Parser changes production; all250 prior constructor inputs remain preserved historically at0d52 by mode/revision only. '
             'Separate original/live public AST probes observe three inverted whitespace-only intervals per route, six independent product RED rows; commands themselves succeed. Actual trim-helper returns and a narrow correction establish the pre-existing cause; P1 .2.1.2.4 repairs it immediately next. Native empty frames are independently ordered.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'native-ast-input-frames-and-owned-empty-span-cause', 'statement': statement,
    'scope': 'Native descriptive parser-input coordinates only for roots and ordinary call/array CSV descendants. Unsupported descendant paths conservatively decline. These are not compiler-event SourceOrigins, original-source copy/consumption, producer/factory integration, mapped repair or public runtime fix. Original interface RED proves availability; eleven source inverses prove semantics. Guarded live consumers/Toolbox reuse standard toolchain and published dependency outputs, not immutable complete Phase0/dependency reproduction. The original empty-span diagnosis covers exactly four authored inputs at base7 in original0d52/live source and the dynamic trim intervention; no broader runtime failure or repaired public behavior is claimed. Public invariant repair is explicitly owned next, then MethodExpr/event joining and later Phase0/canonical admission remain open.',
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'proof.py original; bash tools/run_python_project_data.sh ' + PREFIX + 'proof.py final; bash tools/run_python_project_data.sh ' + PREFIX + 'proof.py consumers; bash tools/run_python_project_data.sh ' + PREFIX + 'toolbox.py; bash tools/run_python_project_data.sh ' + PREFIX + 'empty-probe.py; bash tools/run_python_project_data.sh ' + PREFIX + 'review.py',
                 'granularity': 'Each authored original argument/trim interval and actual source/capture/callback/root/CSV identity; wrong-public-search intervention; exact source inverses and full channels; each original/live empty public interval and actual trim return/intervention; every original constructor binding.', 'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'Public base/search offsets, copied CSV arrays or foreign native roots may grant input frames; the new native extension may cause empty public inversion; failed/incomplete/forged actual evidence may hide these differences.',
                'oracle': 'Independent cumulative original Unicode/CRLF/repeated/empty-slot intervals and actual reference identities; wrong public-search intervention; immutable original source and independently authored ordered zero-width empty intervals, with exact trim-helper intervention.',
                'red_control': 'Eleven valid source inverses reach named semantic TAP assertion failures. Eight evidence corruptions reject failed final/consumer channels, forged inputs/inverse producers, missing inverses/consumers, forged Toolbox output and missing original empty route. The independent public ordered-span oracle observes six actual RED rows on original/live source, while the narrow trim intervention yields all expected ordered intervals; the new native empty frames pass independently.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': [
        {'path': p, 'sha256': hashlib.sha256((ROOT / p).read_bytes()).hexdigest(),
         'role': 'producer' if p.endswith(('.pm', '.pl', '.py', '.sh', '.t')) else 'input'} for p in sorted(sources)]}
}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print('Native-frame claim:', len(sources), 'exact retained inputs.')
