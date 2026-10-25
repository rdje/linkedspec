"""One-shot supplied-book rendering; no historical recapture on review."""
import copy
import common as c
import epoch
import book as b


def changed(packets,path,old,new):
    value=copy.deepcopy(packets);raw=c.decode(value[path]['base64'])
    assert raw.count(old)==1,(path,old)
    raw=raw.replace(old,new,1);value[path].update(base64=c.encode(raw),sha256=c.sha(raw))
    return value


def main():
    supplied=epoch.snapshot(['rust/linkedspec-runtime/tests/signed_array_selector_contract.rs','tests/signed-array-rust/cases.json'])
    packets=b.inputs()
    c.write_new('book-inputs.json.gz',dict(context=supplied,inputs=packets,
        scope='Whole current book configuration/source/recursive includes. Installed mdBook and OS are read-only prerequisites; no theme or extra assets configured.'))
    healthy=b.render(packets);b.validate(healthy,packets)
    variants={
        'heading':changed(packets,b.FLOW,b'Signed array selectors in Perl and Rust',b'Changed signed heading'),
        'support':changed(packets,b.FLOW,b'The extension is available on Perl and Rust',b'The extension is unavailable'),
        'example':changed(packets,'examples/negative-array-write-perl.spec',b'items[-2]=99',b'items[-1]=99'),
    }
    c.write_new('book-fault-inputs.json.gz',dict(overrides={name:{path:item for path,item in value.items()
        if item!=packets[path]} for name,value in variants.items()}))
    faults={}
    for name,value in variants.items():
        run=b.render(value);assert run['returncode']==0
        try:b.validate(run,packets)
        except AssertionError as error:reason=str(error)
        else:raise AssertionError('book source fault admitted: '+name)
        faults[name]=dict(run=run,reason=reason)
    unchanged=c.unchanged(supplied['inputs'])
    c.write_new('book-runs.json.gz',dict(healthy=healthy,faults=faults,inputs_unchanged=unchanged))
    assert unchanged
    print('Supplied book PASS:',len(packets),'whole inputs; three actual rendered source faults rejected.')


if __name__=='__main__':main()
