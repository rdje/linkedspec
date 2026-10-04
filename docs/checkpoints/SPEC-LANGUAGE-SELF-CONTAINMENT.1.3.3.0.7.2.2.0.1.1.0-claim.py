"""Publish only the independently reviewed basic-regex provenance measurement."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
subprocess.run(['bash', 'tools/run_python_project_data.sh', PREFIX + 'review.py'], cwd=ROOT, check=True)
verified = json.loads((ROOT / (PREFIX + 'verification.json')).read_bytes())
inputs = {}
for line in subprocess.check_output(['git', 'ls-files', '--stage', '-z', '--', 'perl', 'specs'], cwd=ROOT).split(b'\0'):
    if line:
        metadata, name = line.split(b'\t', 1)
        mode, _, stage = metadata.split()
        if mode in (b'100644', b'100755'):
            assert stage == b'0'
            inputs[name.decode()] = 'input'
for path in ROOT.glob(PREFIX + '*'):
    assert path.is_file() and not path.is_symlink()
    inputs[str(path.relative_to(ROOT))] = 'producer' if path.suffix in ('.py', '.pl', '.pm') else 'input'
for row in verified['suites']:
    inputs[row['path']] = 'producer'
for path, role in [
    ('t/actionir_basic_regex_source_provenance.t', 'producer'),
    ('docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py', 'producer'),
    ('docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0-cases.json', 'input'),
    ('docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md', 'input'),
    ('docs/linkedspec-book/book.toml', 'input'),
    ('tools/run_python_project_data.sh', 'producer'), ('tools/project_data_run.sh', 'producer'),
    ('tools/project_data_env.sh', 'producer'), ('tools/run_mdbook_local.sh', 'producer'),
    ('tools/run_ci_local.sh', 'input'), ('tests/language-readiness/verify_objectives.py', 'input'),
]:
    inputs[path] = role
manifest = [{'path': path, 'sha256': hashlib.sha256((ROOT / path).read_bytes()).hexdigest(), 'role': role}
            for path, role in sorted(inputs.items())]
statement = (f"Nine PrimitiveBasicRules regex contracts retain original scalar match positions privately. "
             f"{verified['sources']} authored sources/{verified['before_after_pairs']} seed-bound before/after compiler pairs "
             f"preserve public event/raw/argument, substitution, diagnostic, dump and emission records. "
             f"{verified['private_origins']} origins satisfy independent positions. The same complete ten-group test "
             f"fails nine before and passes ten after; the empty-result guard passes both. "
             f"{len(verified['rejected_evidence_controls'])} evidence corruptions reject.")
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'basic-regex-private-source-provenance', 'statement': statement,
    'scope': 'Exactly the five call/dispatch regex contracts and four zero-argument gap contracts listed in the independent fixture. One production owner changes from clean80ecf47f258a7f23a59598a1c5500a34fe662a7c. Original quoted syntactic matches remain recorded; executable membership, replacement, statement/recursive frames, marker/comments, public event/schema, callback contract, backend admission and CI registration do not change. Probe routes compile/inspect but do not execute newly emitted sources; all original failure and internal channels are retained and compared. Nine source instances across three named fixed seeds are deterministic observations, not a stochastic interval. Additional consumer/render observations and their open legs are disclosed in the separate claim below; this checked claim establishes only the bounded private/compiler result. OS/tool/dependency installations are the observed environment. Prior three-contract proof is frozen historically, without refreshing its original source identities.',
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'tests.py before; bash tools/run_python_project_data.sh ' + PREFIX + 'capture.py before; bash tools/run_python_project_data.sh ' + PREFIX + 'tests.py after; bash tools/run_python_project_data.sh ' + PREFIX + 'capture.py after; bash tools/run_python_project_data.sh ' + PREFIX + 'review.py',
                 'granularity': 'Each independently authored original action, Unicode scalar match and event argument; each complete named source/seed frozen/current process; complete unchanged permanent private-provenance TAP plans. Broader consumer/render observations are separately disclosed below.',
                 'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'Missing origins, raw-key twin pairing, altered argument bytes, added public fields or changed compiler outputs could pass unnoticed.',
                'oracle': 'Independent authored source positions distinguish the quoted syntactic twin and both real repeated matches. Permanent assertions compare exact event object identities and source slices. Source-identical before/after public compiler records and unchanged test/source identities distinguish semantic drift.',
                'red_control': 'Actual frozen-owner test reaches all ten groups, fails exactly the nine producer groups and passes empty-result guard; unchanged test bytes pass all ten after. Twelve executed evidence controls reject wrong twin positions, lost repeated origin, public field/argument/substitution/diagnostic/emission/source-frame drift, missing seed, hidden RED, broken GREEN guard and book example drift.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': manifest}
}, {
    'name': 'broader-consumer-and-book-observation-with-disclosed-proof-gaps',
    'statement': f"Thirteen selected unchanged suites report{verified['consumer_tests']} top-level passes, including complete Phase0; the actual book command reports success and two examples are present in retained rendered HTML. The finite observations are preserved; broader falsification and complete transitive input closure remain open.",
    'scope': 'Actual observed command/TAP/rendered outputs only. Phase0 reads corpus/contract/nested test and root/book Markdown inputs omitted by the initial publisher; generated-source tests read examples. Root continuity documents changed after the run. The book reads sources beyond its chapter/toml. The initial claim/publisher are retained as superseded artifacts, not silently refreshed. Wider prior-record input-closure review remains owned by SESSION-STARTUP-READING.5. No whole-project proof/admission or reproducibility claim follows from these transcripts.',
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh '+PREFIX+'consumers.py; bash tools/run_python_project_data.sh '+PREFIX+'book.py; bash tools/run_python_project_data.sh '+PREFIX+'review.py',
                 'granularity': 'Thirteen named complete TAP plans and actual render command/chapter output at the observed worktree boundary; transitive input identities and their prior historical bytes are not fully established.',
                 'result': f"Actual exit0/full plans total{verified['consumer_tests']}; book exit0/two normalized rendered examples. Original streams are retained unchanged."},
    'falsify': {'status': 'gap', 'reason': 'The current twelve controls distinguish the private/compiler proof and rendered example drift, but do not execute broader missing/transitively changed input and truncated/failing consumer TAP controls. Those distinguishing controls are required before closing this broader claim.', 'repair_owner': 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3'},
    'durability': {'status': 'gap', 'reason': 'Selected suite/tool sources and transcripts are retained in the source-bound primary manifest, but the actual transitive corpus/contract/nested consumer/root-doc/book/example input closure is incomplete. Some root Markdown bytes changed after the run and were not frozen at read time; updating hashes alone would misidentify original inputs. Preserve this boundary and recover or re-measure in the owned repair.', 'repair_owner': 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3'}
}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print(f"claim inputs={len(manifest)} producers={sum(row['role'] == 'producer' for row in manifest)}")
