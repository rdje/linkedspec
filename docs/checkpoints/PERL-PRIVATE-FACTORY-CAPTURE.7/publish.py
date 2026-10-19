"""Stable readonly entrypoint; original draft/source and bounded repair stay retained."""
import hashlib
import json
from pathlib import Path
directory=Path(__file__).resolve().parent/'publication'
record=json.loads((directory/'repair.json').read_bytes())
source=directory/'publish-final.py';value=source.read_bytes()
assert hashlib.sha256(value).hexdigest()==record['final_source_sha256']
assert hashlib.sha256(Path(__file__).read_bytes()).hexdigest()==record['wrapper_sha256']
exec(compile(value,str(source),'exec'),{'__file__':str(source),'__name__':'__main__'})
