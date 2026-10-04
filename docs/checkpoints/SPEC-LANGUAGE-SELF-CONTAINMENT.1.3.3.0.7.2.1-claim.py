"""Publish identities only after the read-only behavioral review has passed."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
review = subprocess.run(['bash', 'tools/run_python_project_data.sh', PREFIX + 'review.py'], cwd=ROOT)
assert review.returncode == 0
verification = json.loads((ROOT / (PREFIX + 'verification.json')).read_bytes())
inputs = {}
for line in subprocess.check_output(['git', 'ls-files', '--stage', '-z', '--', 'perl', 'specs'], cwd=ROOT).split(b'\0'):
    if not line:
        continue
    metadata, name = line.split(b'\t', 1)
    mode, _, stage = metadata.split()
    if mode not in (b'100644', b'100755'):
        continue  # Git links/other repository boundaries are not implementation inputs.
    assert stage == b'0'
    path = name.decode()
    inputs[path] = 'input'
for path in ROOT.glob(PREFIX + '*'):
    assert path.is_file() and not path.is_symlink()
    inputs[str(path.relative_to(ROOT))] = 'producer' if path.suffix in ('.py', '.pl') else 'input'
for row in verification['suites']:
    inputs[row['path']] = 'producer'
for path, role in [
    ('docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm', 'producer'),
    ('docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md', 'input'),
    ('docs/knowledge/perl-quoted-primitive-rewrite-event-drift.md', 'input'),
    ('tools/run_python_project_data.sh', 'producer'), ('tools/project_data_run.sh', 'producer'),
    ('tools/project_data_env.sh', 'producer'),
    ('tools/run_mdbook_local.sh', 'producer'), ('docs/linkedspec-book/book.toml', 'input'),
]:
    inputs[path] = role
manifest = [{'path': path, 'sha256': hashlib.sha256((ROOT / path).read_bytes()).hexdigest(), 'role': role}
            for path, role in sorted(inputs.items())]
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'quoted-action-executable-and-diagnostic-source-ownership',
    'statement': f"{verification['sources']} exact authored sources produce {verification['native_fresh_pairs']} native/fresh Perl pairs over seeds0/1/2, {verification['trace_processes']} complete lowering traces, and {verification['tests']} passing top-level tests across ten unchanged suites. Desired literal/event oracles expose quoted primitive corruption, phantom IF/unresolved metadata, false authored diagnostic markers and two nested host-call failures per seed. {len(verification['rejected_evidence_controls'])} actual evidence corruptions reject. Four exact source examples render.",
    'scope': 'Current evidence-only diagnosis at production activation012038a637e727a57fe8ac387b27d7267f76f465. No repair, grammar/helper/event schema/backend admission, arbitrary lexical census or whole-project signoff. Native and independently loaded emitted routes are both Perl. Desired quote-data oracles remain RED; changing raw host results/warnings are retained, not portable positives. Three named seeds are exact observations, not a statistical interval. Full process/dump/emitted/trace/TAP/render streams are lossless envelopes, not projections. Unicode trace producer exit0 emits six actual Trace.pm:199 warnings; capture exit1 is owned by PERL-TRACE-UNICODE-SINK.1. Source comments remain .7.3. Older .18/.31 preserves a qualitative report, not complete raw baseline streams; no fabricated source-identical historical comparison or broad startup closure. Repo-owned Perl/spec inputs are hash-bound; host Perl/OS and published dependency installations remain the observed environment, not a universal dependency claim.',
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'capture.py; bash tools/run_python_project_data.sh ' + PREFIX + 'capture.py trace; bash tools/run_python_project_data.sh ' + PREFIX + 'tests.py; bash tools/run_python_project_data.sh ' + PREFIX + 'book.py; bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'claim.py',
        'granularity': 'One exact case per seeded public Perl process and independent fresh emitted child; one source-identical seed0 facade trace per case. Complete ordered helper/canonical/unresolved records, typed AST/source/spans, substitution, dump, generated input identity, actual values and original stdout/stderr/error channels retained. Independent manually authored value/call lists plus fixture-only lexical positions; full unchanged TAP plans and actual rendered chapter.',
        'result': 'PASS read-only diagnosis/reviewer/unchanged165 consumers/render; current desired quote value/events remain failing witnesses. Trace capture command returns1 solely for the retained Unicode sink warning; all22 trace children exit0. Exact input/producer count is generated in the durability manifest.'},
    'falsify': {'status': 'checked',
        'hypothesis': 'Healthy literal values prove correct helper ownership; all marker text is a real diagnostic; hiding all quoted strings preserves true unsupported-helper blockers; equal spelling identifies one executable occurrence.',
        'oracle': 'Independently authored literal values and executable helper occurrence lists distinguish quoted data, real repeated/mixed assignments, controls and raw operands. Actual trace reaches phantom if replacement then unbalanced-flow fallback, quoted set replacement, and identical text-only marker diagnosis for authored data and compiler sentinels. Unsupported substr/count/nested controls and source-span-bound i+1 remain blocked. Fresh child consumes the exact emitted UTF-8 digest.',
        'red_control': 'The actual current quote value/event/marker oracles fail; fourteen executed reviewer corruptions reject authored source, typed string ownership, fresh input identity, hidden false IF, hidden literal corruption, hidden authored marker, hidden real unsupported helper, raw span drift, lost mixed occurrence, hidden fresh interpolation warning, hidden native host-call failure, hidden Unicode warning, hidden reached replacement and hidden failed TAP. These mutate evidence, not production/runtime semantics. The initial blanket healthy-error reviewer and unsupported nested successful-value assumption remain frozen; correction preserves every executed input and actual capture byte.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': manifest}
}]}
target = ROOT / ('docs/claims/' + OWNER + '.json')
target.write_text(json.dumps(record, indent=2) + '\n')
print(f"claim inputs={len(manifest)} producers={sum(row['role']=='producer' for row in manifest)} bytes={target.stat().st_size}")
