"""Readonly corrected publication; --capture replaces only the preserved draft."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
OBJECT='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/'
TARGET=ROOT/'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.7.json'
sha=lambda v:hashlib.sha256(v).hexdigest()
assert sys.argv[1:] in ([],['--capture'])
for name in ('review.py','evidence.py'):
    result=subprocess.run(['python3',PREFIX+name],cwd=ROOT,capture_output=True)
    assert result.returncode==0 and not result.stderr,(name,result.stderr)
review=json.loads((ROOT/(PREFIX+'review.json')).read_bytes())
evidence=json.loads((ROOT/(PREFIX+'evidence.json')).read_bytes())
assert review['result']==evidence['result']=='PASS' and len(evidence['controls'])==10
pop=review['population']
assert pop['mixed_assertions']==445 and pop['mixed_red']==53 and pop['mixed_faults']==18
assert pop['object_assertions']==444 and pop['object_red']==100 and pop['object_faults']==10
assert pop['consumer_suites']==91 and pop['consumer_inputs']==363 and pop['consumer_assertions']==30394
assert pop['diagnostic_inputs']==358 and pop['diagnostic_assertions']==16
assert pop['knowledge_bytes']==8388255 and pop['book_sources']==89 and pop['book_controls']==4
compat=json.loads((ROOT/(PREFIX+'compat.json')).read_bytes())
assert compat['result']=='PASS' and len(compat['rows'])==8 and all(v['returncode']==0 for v in compat['rows'])
assert b'Files=1, Tests=1035' in base64.b64decode(compat['rows'][-1]['stdout_base64'],validate=True)
paths=set(review['inputs'])|{PREFIX+n for n in ('review.json','evidence.py','evidence.json',
    'evidence-originals.json.gz','evidence-reached.json','publish.py',
    'publish-over-budget.py','publish-preflight.py','publish-preflight.json',
    'publish-size-review.py','publish-size-review.json')}
preflight=json.loads((ROOT/(PREFIX+'publish-preflight.json')).read_bytes())
assert preflight['result']=='PASS' and preflight['returncode']!=0
assert preflight['failed_source_sha256']==sha((ROOT/(PREFIX+'publish-over-budget.py')).read_bytes())
assert preflight['producer_sha256']==sha((ROOT/(PREFIX+'publish-preflight.py')).read_bytes())
assert b'(131264, 560)' in base64.b64decode(preflight['stderr_base64'],validate=True)
second=json.loads((ROOT/(PREFIX+'publish-size-review.json')).read_bytes())
assert second['result']=='PASS' and second['returncode']!=0
assert second['producer_sha256']==sha((ROOT/(PREFIX+'publish-size-review.py')).read_bytes())
assert second['failed_source_sha256']==sha(base64.b64decode(second['failed_source_base64'],validate=True))
assert b'(131243, 563)' in base64.b64decode(second['stderr_base64'],validate=True)
bindings=[]
for path in sorted(paths):
    source=ROOT/path
    assert source.is_file() and not source.is_symlink()
    bindings.append(dict(path=path,sha256=sha(source.read_bytes()),
        role='producer' if source.suffix in ('.py','.pl','.pm','.t','.sh') else 'input'))
statement=(
    'Mixed native defaults preserve public maps, contexts and package-object effects. '
    'Identical445/53 and444/100 RED/GREEN pairs,28 effective source variants, exact mixed26/26 '
    'and object108/108 native ledgers,91 supplied suites/363 inputs/30394 assertions, '
    '358-input/16-assertion diagnostics, eight standard commands/public1035, ten artifact '
    'denials, complete Knowledge8388255 and book89/four controls pass. Whole initial546-input/'
    '127929-byte uncommitted draft and actual2020-file original-publisher replay stay preserved.')
record=dict(version=1,owner='PERL-PRIVATE-FACTORY-CAPTURE.5.7',claims=[dict(
    name='corrected-mixed-default-selection-and-native-package-targets',statement=statement,
    scope='Five production files change: ControlFlow factory/definition selection and the two '
        'definition owners, plus one noncoercing package-reference guard in FlowExpr and '
        'MethodLowering. Native existing source locations and SourceEmissions stay exact. '
        'MethodLowering retains scalar construction under every owner context; the other two '
        'forward native context. Object proof uses a published-builder pre-selection oracle, '
        'not a fabricated complete historical-factory replay. Original narrow candidate source, '
        'data and producers stay immutable in a full byte/mode archive; its known object gap is '
        'not final admission. The normal commit was deliberately stopped before it landed. '
        'Original namespace/syntax/builder failures and later before-write budget/chronology '
        'corrections retain distinct source identities and actual channels. Four fact bodies '
        'change; nine route-only bodies stay exact. Complete older prose is recoverable from '
        'Git and the logical archive. Original raw wrapper failure channels are not reconstructed; '
        'actual predicate/rerun controls have their stated scopes. Native attempts are observed '
        'inside the warm probe hook, not a complete outside-attempt census. Module definitions '
        'remain retained; registry release does not imply native-reference release. No ordered '
        'hash-iteration, immutable host-toolchain, complete private/parent/canonical, fixture '
        'registration or pipeline admission is inferred. Standard/public guards are supplemental '
        'without full transitive capsules. Startup.7 owns wrapper/kernel gaps and recovery/purge restrictions.',
    rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+PREFIX+
        'publish.py (readonly default). Current review/evidence, object review, consumer review, '
        'book review and public-validation defaults are readonly. All capture/preparation/replay '
        'writers are retired one-shot instruments. Initial .5.7/publish.py requires its saved '
        'logical inputs and must not run against corrected live sources.',
        granularity='Every mixed26/26 and object108/108 row and recurrence; complete445/53 and '
            '444/100 TAP; each18+10 complete-source variants;91 supplied suites/363 inputs/'
            '30394 assertions; separate358-input diagnostics; complete initial546 bindings/'
            '127929 bytes and actual2020-file replay; full Knowledge/book populations; ten artifact denials.',
        result=statement),
    falsify=dict(status='checked',hypothesis='Name equality or inherited package-object methods '
        'could authorize facade callbacks or add overload effects/fatal exits. Catalogue union, '
        'dynamic lookup, wrong fixed-provider guards, forced contexts, map copies, duplicate '
        'calls or eager loading could alter native behavior. Coherently rehashed evidence '
        'could hide ordinary effects, opaque grants, missing observations/consumers, changed '
        'whole draft claims, object equality/facade changes or forged rendered table values.',
        oracle='Original native ledgers, actual native-builder specifications/contexts, exact '
            'callback references and fresh/carryover scope controls, identical paired fixtures, '
            'exact source inverses, fixed accepted/preserved consumer populations, independently '
            'derived rendered tables and complete original/current source custody.',
        red_control='Original53/445 and100/444 failures become zero with392/344 controls intact. '
            'Mixed source variants fail53,31,14,1,17,35,5,14,2,153,67,21,45,4,44,6,1,55 assertions; '
            'object variants fail100,30,28,42,86,42,12,26,26,39, all with complete plans. Exact '
            'inverses recover every original number/name. Ten actual semantic artifact controls '
            'reject forgeries of native/object effects, authority, observation completeness, '
            'whole draft, consumer selection and both rendered tables, then restore exact PASS. '
            'Four actual book source controls and retained namespace/preservation controls '
            'remain independently scoped.'),
    durability=dict(status='checked',mode='live',inputs=bindings))])
value=(json.dumps(record,indent=2)+'\n').encode()
assert len(value)<=131072,(len(value),len(bindings))
if sys.argv[1:]:
    assert TARGET.read_bytes()==(ROOT/(OBJECT+'initial-claim.json')).read_bytes(), 'replace only the fully preserved logical draft'
    TARGET.write_bytes(value)
else:assert TARGET.read_bytes()==value
print('Corrected default publication PASS:',len(bindings),'live inputs;',len(value),'bytes')
