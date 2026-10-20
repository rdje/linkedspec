"""Recover the sole missing draft metadata before-image against its prior hash."""
import common as c


def main():
    path=c.PREFIX+'README.md'
    current=c.read(path)
    old=b'''Hash-valued keys additionally expose adjacent-brace host syntax failure. This is
an emitter defect, not a documented portable key-kind rejection. Repair the
'''
    new=b'''Hash-valued keys additionally expose raw DSL shape fallthrough and host syntax
failure. Green1 disproved the initial adjacent-brace-only hypothesis; its exact
source/error channels remain retained. This is an emitter defect, not a
documented portable key-kind rejection. Repair the
'''
    raw=c.decode(current['base64'])
    assert raw.count(new)==1
    recovered=raw.replace(new,old,1)
    wanted=c.load('green1-inputs.json.gz')['inputs'][path]
    assert c.sha(recovered)==wanted['sha256']=='9fc00b31208aab5259683374f0e579caef1454153f806af8131055617dcd8113'
    assert current['mode']==wanted['mode']==0o644
    failed=c.load('custody-before-run.json.gz')
    assert failed['run']['returncode']!=0 and b'Unrecoverable actual epoch bytes' in c.decode(failed['run']['stderr_base64'])
    c.write_new('recovered-readme.json.gz',dict(repair_owner=c.OWNER,current=current,
        recovered=dict(**wanted,base64=c.encode(recovered)),producer=c.read(c.PREFIX+'recover_readme.py'),
        source=c.read(c.PREFIX+'green1-inputs.json.gz'),
        scope='The census found exactly one missing untracked README draft before-image after its hypothesis '
              'wording correction. Reverse only that exact replacement and require the independently retained '
              'pre-edit SHA-256/full mode. Current README and all runtime observations remain unchanged. '
              'The failed census remains retained; this repairs metadata custody without inventing a revision.'))
    print('Sole draft README before-image recovered against pre-edit SHA-256 and full mode')


if __name__=='__main__':main()
