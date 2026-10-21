"""Extend immutable-input custody to chunks without refreshing older observations."""
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c


def main():
    paths=[c.PREFIX+'context.py',c.PREFIX+'admission/collection/verify.py','docs/TASK_TREE.md']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    path=paths[0]
    assert before[path]['base64']==c.load('admission/collection/repack.json.gz')['after'][path]
    assert after[path].count("not path.endswith('.gz')")==1
    after[path]=after[path].replace("not path.endswith('.gz')","not path.endswith(('.gz','.part'))",1)
    after[path]=after[path].replace('immutable gzip inputs','immutable gzip/chunk inputs',1)
    after[path]=after[path].replace('Any later gzip change','Any later immutable-input change',1)
    path=paths[1]
    needle="    assert current==c.decode(repack['after'][fact]).decode()"
    assert after[path].count(needle)==1
    replacement='''    portable=c.load('admission/portable/prepare.json.gz')
    assert portable['before'][c.PREFIX+'context.py']['base64']==repack['after'][c.PREFIX+'context.py']
    final_path=ROOT/(c.PREFIX+'admission/portable/final-docs.json.gz')
    documents=c.load('admission/portable/final-docs.json.gz') if final_path.exists() else None
    def expected(path):
        value=repack['after'][path]
        if path in portable['after']:
            assert portable['before'][path]['base64']==value
            value=portable['after'][path]
        if documents is not None and path in documents['after']:
            assert documents['before'][path]['base64']==value
            value=documents['after'][path]
        return c.decode(value)
    assert current.encode()==expected(fact)'''
    after[path]=after[path].replace(needle,replacement,1)
    after[path]=after[path].replace("assert (ROOT/path).read_bytes()==c.decode(repack['after'][path])",
        'assert (ROOT/path).read_bytes()==expected(path)',1)
    after[path]=after[path].replace("    assert final['loaded_context']==c.read(c.PREFIX+'context.py')",
        "    historical_context=final['loaded_context']\n"
        "    assert historical_context['base64']==repack['after'][c.PREFIX+'context.py']\n"
        "    assert c.sha(c.decode(historical_context['base64']))==historical_context['sha256']\n"
        "    assert historical_context['mode']==repack['before'][c.PREFIX+'context.py']['mode']",1)
    after[paths[2]]=after[paths[2]].replace(
        '`active` / aggregate .1.2.7 done; pipeline .1.2.9 next',
        '`active` / aggregate .1.2.7 portable admission; .1.2.9 next',1)
    for path,text in after.items():
        if path.endswith('.py'):compile(text,path,'exec')
    c.write_new('admission/portable/prepare.json.gz',dict(before=before,
        after={path:c.encode(text.encode()) for path,text in after.items()},
        producer=c.read(c.PREFIX+'admission/portable/prepare.py'),
        scope='Retain immutable part identities without recursive copies. Extend the maintained '
              'reader through exact before/after source custody, treating the actual prior loaded '
              'context as historical rather than pretending it used the new code. No runtime, '
              'test, book or old measurement changes. Final documentation remains a separate epoch.'))
    for path,text in after.items():(ROOT/path).write_text(text)
    print('Immutable gzip/chunk custody prepared; exact older context and final-document overlays retained')


if __name__=='__main__':main()
