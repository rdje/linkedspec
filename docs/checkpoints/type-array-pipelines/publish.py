"""Capture once and rederive the closed pipeline claim without tracked writes."""
import json
import subprocess
import sys
import common as c

MANIFEST_NAME='publication3-inputs.json.gz'
MANIFEST=c.PREFIX+MANIFEST_NAME
PUBLICATION_NAME='publication3.json'
PUBLICATION=c.PREFIX+PUBLICATION_NAME
CLAIM='docs/claims/'+c.OWNER+'.json'

def input_paths():
    paths=set()
    for row in subprocess.check_output(['git','ls-files','--stage','-z'],cwd=c.ROOT).split(b'\0'):
        if row:
            metadata,path=row.split(b'\t',1)
            if metadata.split()[0] in (b'100644',b'100755'):paths.add(path.decode())
    paths.update(path for path in subprocess.check_output(['git','ls-files','--others','--exclude-standard','-z'],cwd=c.ROOT).decode().split('\0') if path)
    return sorted(paths-{MANIFEST,PUBLICATION,CLAIM})

def validate_inputs(declared,actual):
    assert set(declared)==set(actual),'publication input population mismatch'
    for path,item in actual.items():
        assert declared[path]['sha256']==item['sha256'],'publication input byte mismatch: '+path
        assert declared[path]['mode']==item['mode'],'publication input mode mismatch: '+path

def controls(name='artifact-inputs.json.gz'):
    saved=c.load(name);result={}
    for name,declared in saved['cases'].items():
        try:validate_inputs(declared,saved['actual'])
        except AssertionError as error:result[name]=dict(rejected=True,reason=str(error))
        else:result[name]=dict(rejected=False,reason='')
    return result

def record(result):
    producers=[path for path in input_paths() if path.startswith(c.PREFIX) and path.endswith(('.py','.pl'))]
    producers+=[c.SOURCE,'perl/LinkedSpec/BindingRuntime.pm','t/scalar_numeric_contract.t',
        'tools/run_python_project_data.sh','tools/project_data_run.sh']
    bindings=[dict(path=path,sha256=c.identity(path)['sha256'],role='producer') for path in sorted(set(producers))]
    bindings.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
    return dict(version=1,owner=c.OWNER,claims=[dict(name='perl-deferred-sorted-take',
        statement='Perl callable bodies execute lexical sorted and integer-prefix take in free and receiver forms, including compatible array-reducer continuations.',
        scope='Bounded sorted/take availability using existing Perl copy/count/effect/shape rules. Full accepted aggregate7 claim/publication/physical and logical custody precedes changes. Rejected88/85 fixture epochs and the failed first kind instrument remain exact. Known sorted/copy scalar-kind repair13 is next; missing count/first10, named-function/ordinary-length11 and deferred indexed-write12 stay owned. Reducer kind95, Boolean35 and constructor94 stay separate. No general pipeline, complete inventory, arbitrary deep-copy or cross-backend admission. Six aggregate-availability faults retain their exact pre-argument-guard source; a distinct final guard removal/restoration plus final85/final14 suites covers the sole typed-list-validation delta. The earlier14-suite1948-TAP run fails only its intentional old sorted-unknown expectation; that one case advances to independently verified4. Whole first10716-input unpublished claim/publication/10719 full-mode source images and actual source-readonly0 precede the console repair. The original structured result already has seven faults; the original label undercounts six. Final console fields derive from the reviewed result, and new artifact controls falsify the actual final publisher. Initial outputs remain frozen; no draft revision or runtime/test/book refresh is invented. Exact staged canonical receipt governs landing.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py',
            granularity='Individual authored value/effect/copy/arity case through descriptor, native Get/dump and fresh emitted source; retained direct-suite TAP, actual book bodies/anchor and scalar-flag/consumer observations.',
            result=f"{result['cases']} values;{result['accepted_red']} actual accepted RED/{result['accepted_controls']} controls;{len(result['faults'])} restored source faults;{result['direct_suites']}/{result['direct_tap']} TAP;{result['book_inputs']}/3 book examples/anchor RED.85 permanent cases/one advanced earlier expectation/75 malformed assertions. Three artifact denials and actual validator-removal admissions restore. Prior10608 physical/3 logical/10611 Git images and actual clean readonly0 retained. Historical audit650 unchanged; Phase0 source unchanged, so no new inverse."),
        falsify=dict(status='checked',hypothesis='Missing dispatch, numeric sorting, wrong default count, eager count effects, late receiver shape checks or source mutation can pass value-only smoke tests.',
            oracle='Fixed lexical order, independent ordinary accepted behavior, explicit effect strings, caller-side mutation and retained actual previous-runtime execution with loaded-byte verification.',
            red_control='41 accepted failures and44 controls on the fixed85 plan. Actual disabled call dispatch, numeric-sort, default-two, eager-count, receiver-arity and source-mutation faults each reject and restore at the retained pre-guard epoch. A separate actual final argument-guard removal reproduces nine raw host errors and six invalid-list acceptances; restoring it yields15 typed errors and unchanged records/callers. The actual displaced book heading rejects. Real publication input omission/byte/mode declarations reject; installing a return-only actual validator admits all three before exact restoration. Scalar-kind investigation retains actual POK/IOK and clone differences plus public array-index failure; numeric-literal controls remain numeric.'),
        durability=dict(status='checked',mode='live',inputs=sorted(bindings,key=lambda item:item['path']))
    )])

def main():
    if sys.argv[1:] in (['--controls'],['--controls','artifact2-inputs.json.gz'],['--controls','artifact3-inputs.json.gz'],['--controls','artifact4-inputs.json.gz']):
        fixture=sys.argv[2] if len(sys.argv)==3 else 'artifact-inputs.json.gz'
        print(json.dumps(controls(fixture),sort_keys=True));return
    assert sys.argv[1:] in ([],['--capture'])
    import review
    capture=sys.argv[1:]==['--capture']
    actual={path:c.identity(path) for path in input_paths()}
    if capture:
        assert c.read(CLAIM)==c.load('reference-first.json.gz')['claim']
        c.write_new(MANIFEST_NAME,dict(base=c.BASE,inputs=actual,
        scope='All regular tracked and nonignored new main-repository inputs, complete source actors, tests, book and immutable evidence. Own final outputs/claim excluded. Accepted Git and whole changed-source packets recover each measured epoch; immutable gzip/chunks are hash-gated without recursive embedding. Three ignored prior logical aliases derive from retained exact chunks. Gitlinks/symlink targets remain uninspected black boxes; installed tools/core and published dependency outputs are read-only prerequisites.'))
    validate_inputs(c.load(MANIFEST_NAME)['inputs'],actual)
    result=review.check()
    validate_inputs(actual,{path:c.identity(path) for path in input_paths()})
    raw=(json.dumps(record(result),separators=(',',':'))+'\n').encode()
    publication=dict(result=result,record_base64=c.encode(raw))
    if capture:
        c.write_new(PUBLICATION_NAME,publication)
        assert c.read(CLAIM)==c.load('reference-first.json.gz')['claim']
        (c.ROOT/CLAIM).write_bytes(raw)
    else:assert (c.ROOT/CLAIM).read_bytes()==raw and c.load(PUBLICATION_NAME)==publication
    print(f"Pipeline publication PASS: {len(actual)} closed physical inputs; "
        f"{result['cases']} values/{result['accepted_red']} accepted RED/"
        f"{len(result['faults'])} restored faults; "
        f"book{result['book_inputs']}/{result['book_examples']}; source readonly")


if __name__=='__main__':main()
