"""Retain an ineffective encoded-quote control and correct its actual HTML needle."""
from pathlib import Path
import base64, gzip, hashlib, json, subprocess
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('book-control-repair.py')
def sha(raw): return hashlib.sha256(raw).hexdigest()
def channel(raw): return {'encoding':'gzip-base64','bytes':len(raw),'sha256':sha(raw),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode()}
p=Path(PREFIX+'book.py'); original=p.read_bytes()
Path(PREFIX+'book-rejected-producer.py').write_bytes(original)
command=['bash','tools/run_python_project_data.sh',p.relative_to(ROOT).as_posix(),'--review']
r=subprocess.run(command,cwd=ROOT,capture_output=True)
assert r.returncode==1 and b'AssertionError: effective book corruption' in r.stderr
report=json.loads(Path(PREFIX+'book.json').read_bytes())
html=gzip.decompress(base64.b64decode(report['regression_html']['data']))
assert html.count(b'"unknown"')==1 and b'&quot;unknown&quot;' not in html
Path(PREFIX+'book-rejected-render.json').write_bytes(Path(PREFIX+'book.json').read_bytes())
changed=original.replace(b"b'&quot;unknown&quot;'", b"b'\"unknown\"'")
assert changed!=original and changed.count(b"b'\"unknown\"'")==1
p.write_bytes(changed)
result={'command':command,'exit':r.returncode,'stdout':channel(r.stdout),'stderr':channel(r.stderr),'before_sha256':sha(original),'after_sha256':sha(changed),'literal_needles':1,'escaped_needles':0,'instrument_sha256':sha(Path(__file__).read_bytes()),'scope':'One new book corruption used encoded quotes absent from actual mdBook text HTML; preserve RED and change only its needle to the single actual literal. No book/runtime/oracle requirement is weakened.'}
Path(PREFIX+'book-control-repair.json').write_text(json.dumps(result,indent=2)+'\n')
print('Retained actual ineffective-control RED; corrected the one literal HTML needle')
