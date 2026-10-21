"""Materialize exact recovery for the validator dataset from independently captured packets."""
import common as c


def main():
    actual=c.load('artifact-inputs.json.gz')['actual']
    doc=c.load('doc-inputs.json.gz')
    older=c.load('prepare-doc-review.json.gz')['before']
    assert set(actual)<=set(doc['inputs'])
    result=dict(base=c.BASE,inputs=actual,overrides={},new_inputs={},
        git_inputs=doc['git_inputs'],excluded=doc['excluded'],
        scope='Exact validator dataset recovery, not a new runtime observation. Doc capture supplies '
              'unchanged packets; the two actual earlier reader/pointer packets supply changed bytes. '
              'Every identity is checked before composition; immutable artifacts or real base Git '
              'recover other entries. No process environment or revision is invented.')
    for path,item in actual.items():
        if doc['inputs'][path]!=item:
            packet=older[path]
            assert {key:packet[key] for key in ('sha256','mode')}==item,path
            result['overrides'][path]=packet
        elif path in doc.get('new_inputs',{}):result['new_inputs'][path]=doc['new_inputs'][path]
        elif path in doc.get('overrides',{}):result['overrides'][path]=doc['overrides'][path]
    path=c.PREFIX+'custody.py';before=c.read(path)
    raw=c.decode(before['base64']).decode()
    old="        'library-actual-inputs.json.gz','guard-proof-inputs.json.gz','focused2-inputs.json.gz']"
    new="        'library-actual-inputs.json.gz','guard-proof-inputs.json.gz','focused2-inputs.json.gz',\n        'artifact-epoch.json.gz']"
    assert raw.count(old)==1
    after=raw.replace(old,new,1)
    c.write_new('artifact-epoch.json.gz',result)
    c.write_new('artifact-epoch-closure.json.gz',dict(before=before,after_base64=c.encode(after.encode()),
        producer=c.read(c.PREFIX+'close_artifact_epoch.py'),sources=[
            c.identity(c.PREFIX+'artifact-inputs.json.gz'),c.identity(c.PREFIX+'doc-inputs.json.gz'),
            c.identity(c.PREFIX+'prepare-doc-review.json.gz')]))
    (c.ROOT/path).write_text(after)
    print('Validator dataset fully recoverable:',len(actual),'input identities; no observation refreshed')


if __name__=='__main__':main()
