"""Actual pre-edit claim/source admission and non-writing Dart gate baseline."""
import gzip
import json
import subprocess
import common as c


def main():
    selected=['dart/lib/src/runtime/interpreter.dart',
        'dart/test/write_vivification_contract_test.dart',
        'docs/knowledge/write-vivification-dart-runtime.md',
        'docs/knowledge/dart-component-gate-sdk-compatibility.md',
        'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md',
        'docs/linkedspec-book/src/development/local-ci-and-regression.md',
        'tests/language-readiness/verify_objectives.py',
        'docs/language-readiness/objective-reconciliation.md','KNOWLEDGE_MAP.md']
    records={};hits=[]
    for path in subprocess.check_output(['git','ls-files','docs/claims'],cwd=c.ROOT,text=True).splitlines():
        packet=c.read(path);records[path]=packet
        for claim in json.loads(c.decode(packet['base64']))['claims']:
            durable=claim['durability']
            if durable.get('mode')=='live':
                overlap=sorted(set(selected)&{row['path'] for row in durable.get('inputs',[])})
                if overlap:hits.append(dict(record=path,claim=claim['name'],paths=overlap))
    assert not hits,hits
    historical='docs/checkpoints/rust-numeric-boundaries/history-final-result.json.gz'
    old=c.read(historical)
    report=json.loads(gzip.decompress(c.decode(old['base64'])))['audit_report']
    source='dart/lib/src/runtime/interpreter.dart'
    bound=report['latest_source_inputs'][source]
    assert c.identity(source)['sha256']==bound['sha256']
    extras=selected+[historical,'tools/check_signed_array_selector_contract.py',
        'tools/check_write_vivification_contract.py']
    supplied=c.context(extras)
    baseline=c.load('before-result.json.gz')
    c.save('audit-before.json.gz',dict(context=supplied,claims=records,
        live_intersections=hits,historical_report=old,historical_dart_boundary=bound,
        public_before=dict(programs=len(baseline['parsed']),observations=len(baseline['observed']),
            targeted=baseline['targeted'],mismatches=baseline['mismatches'],controls=baseline['controls']),
        producer=c.read(c.PREFIX+'audit.py'),
        scope='Complete actual pre-edit claim namespace has no live intersection '
            'with selected mutable producers/docs. Exact Dart source equals the '
            'accepted historical image; its reviewed evolution needs separate admission. '
            'No old claim/checkpoint/source hash is refreshed. Public baseline '
            'epochs keep their original complete producer bytes.'))
    runs=[]
    for command,cwd in [
        (['bash','tools/run_dart_project_data.sh','format','--output=none',
          '--set-exit-if-changed','--language-version=3.9','dart'],c.ROOT),
        (['bash','../tools/run_dart_project_data.sh','analyze','--fatal-infos',
          '--fatal-warnings'],c.ROOT/'dart'),
    ]:
        result=c.run(command,cwd=cwd);runs.append(result)
        print('Component baseline',command[2],result['returncode'],flush=True)
    stable=c.unchanged(supplied['inputs'])
    c.save('component-before.json.gz',dict(runs=runs,inputs_unchanged=stable,
        input_reference=c.PREFIX+'audit-before.json.gz',
        scope='Actual whole-package non-writing formatter and strict analyzer '
            'observations before runtime edits. Existing2.24/2.25 failures remain '
            'separately owned; never claim complete component-gate success.'))
    assert stable
    print('Pre-edit admission/claims and unchanged non-writing component baseline retained.')


if __name__=='__main__':main()
