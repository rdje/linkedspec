"""Re-render the retained canonical fact epoch with both exact renderer sources."""
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'tools'))
from test_knowledge_map_projection import compare, controls, projection


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(),sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw=base64.b64decode(row['base64'],validate=True)
    assert hashlib.sha256(raw).hexdigest()==row['sha256'],'retained projection packet identity'
    return raw


def review_epoch(saved):
    with tempfile.TemporaryDirectory(prefix='projection-replay-',dir=os.environ['TMPDIR']) as temporary:
        fixture=Path(temporary)
        for name,row in saved['sources'].items():
            path=Path(name)
            assert not path.is_absolute() and '..' not in path.parts and name.endswith('.md')
            target=fixture/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(decode(row))
        shim=fixture/'bin';shim.mkdir()
        (shim/'git').write_text('''#!/bin/sh
[ "$#" -eq 4 ] && [ "$1" = -C ] && [ "$3" = rev-parse ] && [ "$4" = --show-toplevel ] || exit 97
printf '%s\\n' "$LINKEDSPEC_PROJECTION_FIXTURE_ROOT"
''')
        (shim/'git').chmod(0o755)
        env={k:v for k,v in os.environ.items() if not k.startswith('KM_')}
        env.update(PATH=str(shim)+os.pathsep+env['PATH'],LINKEDSPEC_PROJECTION_FIXTURE_ROOT=str(fixture))
        rendered={}
        for version in ('before','after'):
            directory=fixture/version;directory.mkdir()
            producer=directory/'gen_knowledge_map.sh';producer.write_bytes(decode(saved['renderers'][version]))
            env['KM_OUTPUT']=version+'.md'
            subprocess.run(['bash',str(producer)],cwd=fixture,env=env,check=True,capture_output=True)
            raw=(fixture/(version+'.md')).read_bytes()
            assert raw==decode(saved['outputs'][version]),'retained renderer/output mismatch: '+version
            rendered[version]=raw.decode()
        compare(rendered['before'],rendered['after'])
        rejected=controls(rendered['before'],rendered['after'])
        return dict(facts=len(projection(rendered['after'])['facts']),rejected_mutations=rejected,
                    exact_renderers_and_outputs=True,limits='Rendering-only replay omits integration initializers; publication safety is checked through the actual project generator separately.')

def review():
    saved=json.loads(gzip.decompress((Path(__file__).parent/'projection-inputs.json.gz').read_bytes()))
    results=[review_epoch(saved)]
    for delta_path in sorted(Path(__file__).parent.glob('projection-reconciliation*.json.gz')):
        delta=json.loads(gzip.decompress(delta_path.read_bytes()))
        assert set(delta)=={'sources','outputs'}
        assert set(delta['sources'])<=set(saved['sources'])
        updated=dict(saved,sources=dict(saved['sources'],**delta['sources']),outputs=delta['outputs'])
        results.append(review_epoch(updated))
    return dict(epochs=len(results),results=results)


if __name__=='__main__':
    print(json.dumps(review(),sort_keys=True))
