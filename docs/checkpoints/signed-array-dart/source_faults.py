"""Physical Dart producer inverses, actual AOT observations, exact restoration."""
import json
import os
import common as c
import oracle
from carriers import build

SOURCE='dart/lib/src/runtime/interpreter.dart'
FIXTURE='tests/signed-array-dart/cases.json'


def replace(raw,before,after):
    assert raw.count(before)==1,before
    changed=raw.replace(before,after,1)
    assert changed!=raw
    return changed


def main():
    before=c.read(SOURCE);raw=c.decode(before['base64'])
    old=c.load('before-inputs.json.gz')['context']['sources'][SOURCE]
    assert c.sha(c.decode(old['base64']))=='0af1a72725fb2b3691ce57f97278439c63fbe23a153a490f0d51a3397f4a1e24'
    missing=replace(raw,b'if (selector.index case final index? when index < 0)',b'if (false)')
    path=replace(raw,b'Object get pathValue => key ?? index!;',
        b'Object get pathValue => key ?? (index! < 0 ? 0 : index!);')
    snapshot=b'  final rootStorage = _rootStorageForWrite(context, base);\n'
    early=replace(raw,snapshot,b'')
    early=replace(early,b'  final evaluatedSegments = _evaluateWriteSegments(\n',
        snapshot+b'  final evaluatedSegments = _evaluateWriteSegments(\n')
    guard=b'''      case ActionAssignNestedAccessExpr(
        :final base,
        :final segments,
        :final value,
      ):
        _assertReceiverMutationWritable(
          context,
          base,
          'nested_write',
          _bindingTargetSpan(expr.sourceSpan, base),
        );
'''
    unguarded=replace(raw,guard,guard[:guard.index(b'        _assertReceiverMutationWritable(')])
    variants={'legacy':c.decode(old['base64']),'missing-negative':missing,
        'authored-path':path,'early-snapshot':early,'guard':unguarded}
    c.save('source-fault-lease.json.gz',dict(source=SOURCE,before=before,
        producer=c.read(c.PREFIX+'source_faults.py'),variants={name:dict(base64=c.encode(value),
            sha256=c.sha(value),mode=before['mode']) for name,value in variants.items()},
        scope='Actual parent production source changes under one exact-restoration lease. '
            'No concurrent source writer, dependency mutation or compiled-source substitution.'))
    lease=c.ROOT/'.linkedspec-data/verification/signed-dart17-source-lease.json'
    assert not lease.exists()
    lease.write_text(json.dumps(dict(source=SOURCE,before=before,closed=False)))
    cases=json.loads(c.file(FIXTURE).read_bytes())['cases']
    results={}
    try:
        for name,variant in variants.items():
            c.file(SOURCE).write_bytes(variant);c.file(SOURCE).chmod(before['mode'])
            assert c.identity(SOURCE)==dict(sha256=c.sha(variant),mode=before['mode'])
            supplied=c.context([FIXTURE,'tests/signed-array-dart/observe.dart',
                'dart/test/signed_array_selector_contract_test.dart'])
            label='source-fault-'+name
            c.save(label+'-inputs.json.gz',supplied)
            executable,binary=build(label,c.PREFIX+'matrix.dart')
            run=c.run([executable,FIXTURE])
            stable=c.unchanged(supplied['inputs']) and c.identity(executable)=={
                key:binary[key] for key in ('sha256','mode')}
            c.save(label+'-run.json.gz',dict(run=run,inputs_and_executable_unchanged=stable))
            assert run['returncode']==0 and stable
            result=oracle.review(c.decode(run['stdout_base64']),cases)
            c.save(label+'-result.json.gz',result)
            ids={row['id'] for row in result['failures']}
            distinguishing={
                'legacy':{'write/last/ordinary','read/last/ordinary'},
                'missing-negative':{'write/absent_negative/ordinary','write/partial_creation_then_negative/ordinary'},
                'authored-path':{'write/negative_prefix_then_creation/ordinary'},
                'early-snapshot':{'write/selector_resize/ordinary','write/rhs_resize/ordinary',
                    'write/failure_keeps_rhs_effect/ordinary'},
                'guard':{'write/guard_precedes_evaluation/ordinary'},
            }[name]
            assert distinguishing<=ids,(name,distinguishing-ids,ids)
            results[name]=dict(failures=result['failure_count'],distinguishing=sorted(distinguishing))
            print(name,result['failure_count'],'actual mismatches',flush=True)
            c.file(SOURCE).write_bytes(raw);c.file(SOURCE).chmod(before['mode'])
            assert c.read(SOURCE)==before
    finally:
        c.file(SOURCE).write_bytes(raw);c.file(SOURCE).chmod(before['mode'])
        assert c.read(SOURCE)==before
        lease.write_text(json.dumps(dict(source=SOURCE,before=before,closed=True)))
    c.save('source-fault-result.json',dict(results=results,exact_bytes_and_mode_restored=c.read(SOURCE)==before,
        required_fresh_green='public3'))
    print('Five physical Dart source inverses RED; exact original bytes/mode restored; public3 still required.',flush=True)


if __name__=='__main__':main()
