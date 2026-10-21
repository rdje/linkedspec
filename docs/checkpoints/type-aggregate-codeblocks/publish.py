"""Capture once, then rederive the complete aggregate claim without tracked writes."""
import json
import subprocess
import sys
import common as c
import review

MANIFEST=c.PREFIX+'publication-inputs.json.gz'
PUBLICATION=c.PREFIX+'publication.json'
CLAIM='docs/claims/'+c.OWNER+'.json'


def input_paths():
    paths=set()
    for row in subprocess.check_output(['git','ls-files','--stage','-z'],cwd=c.ROOT).split(b'\0'):
        if not row:continue
        metadata,name=row.split(b'\t',1)
        if metadata.split()[0] in (b'100644',b'100755'):paths.add(name.decode())
    for path in (c.ROOT/c.PREFIX).rglob('*'):
        if path.is_file() and '__pycache__' not in path.parts:
            assert not path.is_symlink()
            paths.add(path.relative_to(c.ROOT).as_posix())
    for path in subprocess.check_output(['git','ls-files','--others','--exclude-standard','-z'],cwd=c.ROOT).decode().split('\0'):
        if path.startswith(('docs/history/changes/','docs/history/development-notes/')):paths.add(path)
    return sorted(paths-{MANIFEST,PUBLICATION,CLAIM})


def current_inputs():
    return {path:c.identity(path) for path in input_paths()}


def validate_inputs(declared,actual):
    assert set(declared)==set(actual),'publication input population mismatch'
    for path,item in actual.items():
        assert declared[path]['sha256']==item['sha256'],'publication input byte mismatch: '+path
        assert declared[path]['mode']==item['mode'],'publication input mode mismatch: '+path


def record(result):
    producers={path for path in input_paths() if path.startswith(c.PREFIX) and path.endswith(('.py','.pl'))}
    producers.update([c.SOURCE,'perl/LinkedSpec/Numeric.pm','perl/LinkedSpec/ActionIR/MethodLowering.pm',
        't/scalar_numeric_contract.t','t/callable_codeblock_literal_contract.t',
        'tests/language-readiness/verify_objectives.py',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py',
        'tools/project_data_run.sh','tools/run_python_project_data.sh',
        'knowledge-map/scripts/check_knowledge_map.sh','knowledge-map/scripts/gen_knowledge_map.sh'])
    inputs=[dict(path=path,sha256=c.identity(path)['sha256'],role='producer') for path in sorted(producers)]
    inputs.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
    return dict(version=1,owner=c.OWNER,claims=[dict(
        name='perl-deferred-aggregate-availability',
        statement='Perl callable bodies execute six array reducers, canonical/word calls and terminal '
            'receiver forms; invalid numeric receiver shapes avoid host fallthrough and malformed '
            'serialized fluent members retain their typed invocation error.',
        scope=result['limits'],
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py',
            granularity='Fixed authored case/canonical JSON value/typed diagnostic/effect trace through '
                'descriptor, native Get/dump and fresh emitted parser. Separate public internal-kind '
                'index controls, loaded-byte historical scope, actual book bodies/rendered anchor, '
                'named retained direct-suite epochs and complete source/input recovery.',
            result=f"214 cases:212 values/two diagnostics;106 accepted-source RED/108 controls. Six aggregate "
                f"producer faults at the retained pre-guard epoch plus one actual final guard removal/restoration. "
                f"Final{result['direct_suites']} suites/{result['direct_tap']} TAP;201 added permanent cases/3 "
                f"advanced expectations/15 malformed-record assertions. Book{result['book_inputs']}/3/anchor RED. "
                f"Historical650/134/84613241/22 with zero read/write escapes remains unchanged. Whole accepted "
                f"drop10334/clean readonly0 retained. Internal kind95:3 known index failures/two scalar controls; "
                f"actual old library192 inputs/65 loaded owners verified. Rejected instrument/oracle/shadow "
                f"preparations remain exact. Canonical receipt separately admits the staged candidate."),
        falsify=dict(status='checked',
            hypothesis='A whitelist-only addition, wrong empty identity, late terminal effects, incorrect '
                'min/max overload evaluation, emitted shape fallthrough or an untyped record error passes unnoticed.',
            oracle='Independent fixed arithmetic/empty/effect values, real accepted execution owners, '
                'typed public invoke baseline, exact existing receiver-copy diagnostic protocol, '
                'internal scalar flags plus actual array-write indexes, and rendered book anchor.',
            red_control='106 exact accepted-source failures; six installed aggregate faults with fresh '
                'restorations; final guard removal returns raw Perl error and restores typed failure. '
                'Displaced heading is actually rejected. Initial shadow is rejected after loaded-owner '
                'mismatch; actual historical replay verifies loaded bytes. The claim retains legacy '
                'Boolean/selected-string behavior rather than claiming scalar-contract or95 admission.'),
        durability=dict(status='checked',mode='live',inputs=sorted(inputs,key=lambda item:item['path']))
    )])


def main():
    assert sys.argv[1:] in ([],['--capture'])
    capture=sys.argv[1:]==['--capture']
    actual=current_inputs()
    if capture:
        c.write_new('publication-inputs.json.gz',dict(base=c.BASE,inputs=actual,
            scope='Every regular tracked main-repository input, recursive new producer/data record and '
                  'new owned history segment; full filesystem modes. Every measured context has complete '
                  'before packets, immutable artifact bytes or real accepted Git recovery. Actual '
                  'source faults, rejected preparations, historical installation/recovery and book '
                  'inputs are included. Own final outputs are excluded. Gitlinks/symlink targets are '
                  'uninspected black boxes; installed system tools/core libraries and published '
                  'dependency outputs are explicit read-only prerequisites.'))
    validate_inputs(c.load('publication-inputs.json.gz')['inputs'],actual)
    result=review.check()
    validate_inputs(actual,current_inputs())
    raw=(json.dumps(record(result),separators=(',',':'))+'\n').encode()
    assert len(raw)<=131072
    publication=dict(result=result,record_base64=c.encode(raw))
    if capture:
        c.write_new('publication.json',publication)
        with (c.ROOT/CLAIM).open('xb') as output:output.write(raw)
    else:
        assert (c.ROOT/CLAIM).read_bytes()==raw and c.load('publication.json')==publication
    print('Aggregate publication PASS:',len(actual),'closed inputs;214 cases/106 RED;7 faults;',
        str(result['direct_suites'])+'/'+str(result['direct_tap']),';book'+str(result['book_inputs'])+'/3;kind95 owned;pipeline9 next')


if __name__=='__main__':main()
