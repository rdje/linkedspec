"""Capture once, then verify the complete publication readonly across Git staging."""
import json
import sys
import common as c
import review

MANIFEST=c.PREFIX+'publication-inputs.json'
PUBLICATION=c.PREFIX+'publication.json'
CLAIM='docs/claims/'+c.OWNER+'.json'


def input_paths():
    paths=set(c.load('focused-inputs.json.gz')['inputs'])
    paths.update(c.load('doc-inputs.json.gz')['book'])
    paths.update(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file())
    paths.update(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT/'tests/drop-generated').iterdir() if path.is_file())
    paths.update(['t/drop_keys_generated.t','tests/language-readiness/drop-generated-regression-evolution.json.gz'])
    return sorted(paths-{MANIFEST,PUBLICATION,CLAIM})


def record(result):
    producers={path for path in input_paths() if path.startswith(c.PREFIX) and path.endswith(('.py','.pl'))}
    producers.update([c.SOURCE,'t/drop_keys_generated.t','tests/language-readiness/verify_objectives.py',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py',
        'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-focused.pl'])
    bindings=[dict(path=path,sha256=c.identity(path)['sha256'],role='producer') for path in sorted(producers)]
    bindings.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
    claim=dict(name='perl-generated-drop-key-evaluation',
        statement='Perl generated drop_keys captures key operands, expands explicit flat splices and lowers typed '
                  'key shapes; scalar-key parsers load under normal and fatal syntax-warning profiles.',
        scope=result['limits'],
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py',
            granularity='Fixed authored case/typed value/diagnostic across descriptor/Get/lowered/fresh normal '
                        'and FATAL syntax routes; actual source fault/restoration; retained exact suite and '
                        'historical input epochs; actual book bodies and rendered anchor.',
            result='48 current public rows:34 desired values and14 diagnostic controls; accepted failures '
                   'native10/normal28/FATAL28; four actual emitter faults/restorations; retained9 suites/1322 TAP; '
                   'five actual focused Phase0 roots including18 permanent assertions; book89/three executed '
                   'examples/heading RED; whole numeric10202/clean readonly0; historical644+6/134/84613241/22 '
                   'and two auditor faults/table-byte denial with zero healthy read-write escapes.'),
        falsify=dict(status='checked',hypothesis='Scalar slices, late operand aliases, unlowered explicit '
                     'splices/shapes or permissive historical normalization silently pass.',
            oracle='Independent fixed values/copy/side-effect controls; unchanged accepted public epoch; '
                   'normal and caller-FATAL syntax profiles; exact original historical bytes/hash and '
                   'unchanged644 reason-sensitive controls; actual rendered book anchor.',
            red_control='Accepted public failures, four installed emitter faults and fresh restored probes; '
                        'five obsolete Phase0 assertions then current five-root pass; six exact inverse '
                        'omission/duplication/corruption denials; two actual auditor faults and semantic '
                        'table-byte identity rejection restore; displaced rendered heading rejects. '
                        'Rejected preparation oracles and one metadata custody gap remain retained and repaired.'),
        durability=dict(status='checked',mode='live',inputs=sorted(bindings,key=lambda item:item['path'])))
    return dict(version=1,owner=c.OWNER,claims=[claim])


def main():
    assert sys.argv[1:] in ([],['--capture'])
    capture=sys.argv[1:]==['--capture']
    if capture:assert not (c.ROOT/CLAIM).exists()
    inputs={path:c.identity(path) for path in input_paths()}
    if capture:
        c.write_new('publication-inputs.json',dict(inputs=inputs,
            scope='Complete regular tracked context from actual focused proof, every new producer/fixture/record, '
                  'complete current book/Knowledge, full filesystem modes and SHA-256 before fresh replay. '
                  'Actual earlier drafts recover from whole packets or real accepted Git; own outputs excluded. '
                  'Gitlinks/symlink targets remain uninspected. Installed core tools are read-only prerequisites.'))
    assert c.load('publication-inputs.json')['inputs']==inputs
    result=review.check()
    assert c.unchanged(inputs)
    raw=(json.dumps(record(result),separators=(',',':'))+'\n').encode()
    assert len(raw)<=131072
    publication=dict(result=result,record_base64=c.encode(raw))
    if capture:
        c.write_new('publication.json',publication)
        (c.ROOT/CLAIM).write_bytes(raw)
    else:
        assert (c.ROOT/CLAIM).read_bytes()==raw and c.load('publication.json')==publication
    print('Current drop publication PASS:',len(inputs),
          'closed inputs;34 values/14 diagnostics;4 producer faults;9 suites/1322; historical644+6;book89/3')


if __name__=='__main__':main()
