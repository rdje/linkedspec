"""Read-only publication review; never rerun dated captures or fault writers."""
import json
import re
import common as c
import book
import alias_book
import review_before as b
import review_after as a

RESERVED={'artifacts.json','publication.json','input-controls.json.gz'}


def check_inputs(manifest):
    paths={str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()
        and path.name not in RESERVED}
    assert paths==set(manifest['inputs']),'complete publication input population'
    for path,item in manifest['inputs'].items():
        assert c.identity(path)==item,'publication bytes/mode: '+path


def check():
    manifest=c.load('artifacts.json');check_inputs(manifest)
    original=b.check()
    first=a.check('after3');expanded=a.check('expanded4');restored=a.check('restored-final')
    assert expanded['cases']==restored['cases']==137
    assert expanded['observations']==restored['observations']==822
    faults=c.load('runtime-faults.json.gz');assert faults['inputs_restored']
    fault_results={}
    for name,report in faults['reports'].items():
        actual=a.check('fault-'+name,a.FOUR,False)
        assert actual==report
        fault_results[name]=len(actual['failures'])
    assert set(fault_results)=={'accepted-runtime-inverse','invent-missing-negative',
        'normalized-authored-prefix','rounded-underflow-arithmetic','receiver-guard-bypass'}
    focused=c.load('focused-final-binaries.json.gz');assert len(focused)==8
    compatibility_counts={}
    for name,executable in focused.items():
        b.binary_identity(executable['artifact'])
        run=c.load('focused-final-'+name+'-run.json.gz');assert run['returncode']==0
        identity=c.load('focused-final-'+name+'-identity.json')
        assert identity['unchanged'] and identity['before']==identity['after']==executable['before_execution']
        assert identity['before']=={key:executable['artifact'][key] for key in ('sha256','mode')}
        summaries=re.findall(r'(?m)^test result: ok\. (\d+) passed; (\d+) failed; (\d+) ignored;',
            c.decode(run['stdout_base64']).decode())
        assert summaries and tuple(map(int,summaries[-1][1:]))==(0,0)
        compatibility_counts[name]=int(summaries[-1][0])
    checks=c.load('focused-final-checks.json.gz')
    assert checks['inputs_unchanged'] and checks['book_inputs_unchanged']
    assert all(run['returncode']==0 for run in checks['checks'].values())
    cli=c.load('book-cli-runs.json.gz');b.binary_identity(cli['executable'])
    assert cli['executable_unchanged'] and set(cli['rows'])==set(book.EXAMPLES)
    for path,row in cli['rows'].items():
        assert row['run']['returncode']==0 and not c.decode(row['run']['stderr_base64'])
        assert json.loads(c.decode(row['run']['stdout_base64']))==book.EXAMPLES[path]
    assert cli['wrong']['run']['returncode']==0
    assert json.loads(c.decode(cli['wrong']['run']['stdout_base64']))!=book.EXAMPLES['examples/negative-array-write-perl.spec']
    supplied=book.check()
    aliases=alias_book.check()
    closure=c.load('first-party-include-closure.json.gz')
    for path,packet in closure['accepted_inputs'].items():
        raw=c.decode(packet['base64']);assert c.sha(raw)==packet['sha256']
        import hashlib
        oid=hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()
        assert oid==closure['accepted_git'][path]['git_oid']
        assert bool(packet['mode']&0o111)==(closure['accepted_git'][path]['git_mode']=='100755')
    control_path=c.ROOT/c.PREFIX/'input-controls.json.gz'
    if control_path.exists():
        controls=c.load('input-controls.json.gz')
        assert controls['inputs_restored']
        assert controls['baseline']['returncode']==controls['healthy']['returncode']==0
        assert set(controls['cases'])=={'missing','bytes','mode','required-omission'}
        for item in controls['cases'].values():
            assert item['red']['returncode']!=0 and item['bypass']['returncode']==0
            assert item['restored_rejection']['returncode']!=0
    return dict(owner=c.OWNER,before=dict(cases=original['test_cases'],observations=original['observations'],
        mismatches=original['mismatches'],controls=original['passing_controls']),
        first_emitted=first['observations'],expanded=expanded['observations'],restored=restored['observations'],
        runtime_fault_mismatches=fault_results,compatibility_suites=sorted(focused),
        compatibility_top_level_tests=compatibility_counts,
        compatibility_total=sum(compatibility_counts.values()),book=supplied,book_aliases=aliases,
        accepted_first_party_includes=len(closure['accepted_inputs']),
        scope='Dated64-bit Rust signed-selector evidence. Full raw outcomes and named target fields, qualified instruments, actual executable/source epochs, exact restoration and supplied book. SDK/OS/published prepared RGX outputs remain prerequisites. No whole-SDK replay, arbitrary-precision DSL arithmetic, unrelated coercion/order change, broad numeric55.1 closure,32-bit execution or portable admission.')


if __name__=='__main__':
    result=check()
    if (c.ROOT/c.PREFIX/'publication.json').exists():
        assert result==c.load('publication.json')['result']
    print(json.dumps(result,sort_keys=True))
