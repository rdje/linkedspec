"""Publish the independently accepted composition at actual input boundaries."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
PREP = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.0-'
result = json.loads((ROOT / (PREFIX + 'verification.json')).read_bytes())
assert result['suites'] == 13 and result['top_level_tests'] == 1337
assert result['public_book']['rendered_examples'] == 2
assert all(row['rejected'] for row in result['controls'])
paths = [path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if path.is_file()]
paths += [PREP + name for name in ('plan.json', 'prepare.py', 'inputs.tar.gz', 'inputs.json', 'input-graph.json', 'review.py', 'run.py')]
paths += ['tools/run_python_project_data.sh', 'tools/project_data_run.sh', 'tools/project_data_env.sh', 'tools/run_mdbook_local.sh',
          'docs/linkedspec-book/src/development/documentation-workflow.md']
paths += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-' + name for name in ('consumers.py', 'consumers.json')]
inputs = [{'path': path, 'sha256': hashlib.sha256((ROOT / path).read_bytes()).hexdigest(),
           'role': 'producer' if path.endswith(('.py', '.sh')) else 'input'} for path in sorted(set(paths))]
statement = ('Thirteen unchanged selected suites complete1337 top-level groups at exact Git3fc589f8494fd55b4f0154d6c226797a4fa2f711 plus one retained book overlay. '
             'The first twelve pass1298 groups with738 fixed inputs; the last passes39 after exactly four immutable checkpoint inputs are added, producing a742-file capsule. '
             'Every common supplied input byte/mode is identical; each actual run keeps its own source/capsule/instrument identity and before/after contents/modes/population checks. '
             f"Independent Git/rg review verifies{result['source_related_sites']} source-related lexical sites and{result['named_input_edges']} named input edges, and{len(result['controls'])} reason-checked evidence corruptions reject. "
             'The initial actual missing-file RED is preserved; two original examples render both from fixed consumer inputs and from the separately retained final public-book inputs.')
command = 'bash tools/run_python_project_data.sh '
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'selected-consumer-composition-at-retained-input-boundaries', 'statement': statement,
    'scope': 'A source-bound12+1 composition from two recoverable conservative supplied-input supersets, not a single full successful run of the expanded capsule or a minimal runtime filesystem read set. Initial full run fails before the last suite emits TAP; that failure is not relabeled as success. Root continuity bytes are Git3fc and the sole development book overlay is exactly Git e853; these are retained historical consumer inputs; final publication has a separate complete book capsule. The original broader run remains recoverable with its disclosed gaps; this measurement supersedes active acceptance and does not recover its unretained original live-document reads. The private/compiler regex claim remains exact and unchanged. Wider prior-record audit remains SESSION-STARTUP-READING.5. Lexical sites include writes and quoted program text, and are not all actual reads or classified defects. This is no public DSL/runtime/backend admission, nor cross-host byte-identical transcript claim. All project payload bytes are parent-owned; submodules are excluded. Read-only PATH-resolved host Perl/prove/mdBook, OS and standard-library installations are necessary execution prerequisites; executable identities are retained. Scratch/output stays on the repository filesystem. Exact staged current-candidate canonical proof is separately receipt-bound before parent closeout landing.',
    'rederive': {'status': 'checked', 'command': 'From the retained738/742-file capsules (both book overlays exactly Git e853cd5a7537c0ad8452ffac57af18ef48215df1): ' + command + PREP + 'run.py --mode full --output ' + PREFIX + 'consumers.json; ' + command + PREFIX + 'run.py --mode remaining --output ' + PREFIX + 'consumers-repair.json; ' + command + PREFIX + 'review.py; ' + command + PREFIX + 'book.py; ' + command + PREFIX + 'review.py --public-book',
                 'granularity': 'Every actual per-run capsule member, content/mode and Git object identity; every unchanged named suite command/complete ordered positive TAP plan; actual failure channels and executing instrument identities; complete final public-book input population and actual original rendered examples.', 'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'A successful smoke run, matching aggregate count, omitted checkpoint dependency, altered/truncated TAP or relabeled capsule boundary could conceal incomplete or different-source execution.',
                'oracle': 'Independent immutable Git membership/object/content census; exact common original/expanded input bytes and modes; independent rg reader-site population; retained actual original suite plan population, ordered reach and failure/exit/prove markers; independently authored case source and actual rendered HTML.',
                'red_control': 'Actual initial codeblock_matches_perl.t missing-file failure occurs at line8 before any TAP; all12 earlier passing channels and its exit/stdout/stderr survive. Exactly four immutable dependency files repair it and the unchanged suite passes39 groups. Twenty-two reason-checked mutations reject missing suites, promoted incomplete/failing runs, relabeled capsules, ungated boundaries, forged instruments/commands, failed/nested/truncated TAP, changed streams, erased actual failure, failed render, changed examples, missing/changed transitive inputs and graph omissions. Fifteen independent expanded-capsule/TAP controls additionally reject. Original input-preparation actual post-run mutation control remains preserved at its own boundary.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}
}]}
target = ROOT / 'docs/claims' / (OWNER + '.json')
target.write_text(json.dumps(record, indent=2) + '\n')
assert target.stat().st_size <= 131072
print(f'Published complete bounded selected consumer proof with {len(inputs)} retained producer/input artifacts')
