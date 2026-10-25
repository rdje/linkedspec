"""Read-only physical mutation, product-RED and exact restoration checks."""
import json
import common as c
import review_numeric as n
import review_processes as p


def check():
    names=['json-clamp','host-bound','roundtrip','signed-zero','definition-field']
    outcomes={}
    for name in names:
        stem='fault-first-'+name
        source=c.load(stem+'-source.json.gz');restored=c.load(stem+'-restoration.json.gz')
        result=c.load(stem+'-result.json.gz')
        assert source['before']!=source['after']
        assert restored['before']==restored['restored']==source['before']
        assert restored['producer_error'] is None and result['exact_source_restored']
        assert result['records']==restored['records']
        if name=='json-clamp':
            data=dict(core=n.core(stem+'-core',False),bridge=p.bridge(stem+'-bridge',False),
                emitted=n.emitted('emitted-'+stem+'-programs',False),
                functions=n.emitted('emitted-'+stem+'-functions',False,True))
            n.core(result['restored'],True)
        elif name=='host-bound':
            data=n.runtime(stem+'-runtime',False);n.runtime(result['restored'],True)
        elif name=='roundtrip':
            data=dict(core=n.core(stem+'-core',False),emitted=n.emitted('emitted-'+stem+'-programs',False),
                functions=n.emitted('emitted-'+stem+'-functions',False,True))
            n.core(result['restored'],True)
        elif name=='signed-zero':
            data=n.core(stem+'-core',False);n.core(result['restored'],True)
        else:
            red=c.load(stem+'-library-run.json.gz');green=c.load(result['restored']+'-run.json.gz')
            assert red['run']['returncode']==101 and green['run']['returncode']==0
            assert red['inputs_unchanged'] and red['executable_unchanged']
            assert green['inputs_unchanged'] and green['executable_unchanged']
            assert b'definition_ast_integer_fields_check_both_json_number_branches' in c.decode(red['run']['stderr_base64'])
            data=dict(private_reader_red=True,restored_library_green=True)
        outcomes[name]=data
    return outcomes


if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
