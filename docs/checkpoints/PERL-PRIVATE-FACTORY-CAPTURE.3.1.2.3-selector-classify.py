"""Exercise the actual public selector classifier without changing its policies."""
import importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
path=ROOT/'tools/check_public_aggregate_selector_surface.py'
spec=importlib.util.spec_from_file_location('public_selector',path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
paths=m.public_markdown_paths()
count=m.check_exact_references(paths)
assert len(paths)==m.EXPECTED_PUBLIC_FILE_COUNT==70
assert count==m.EXPECTED_CLASSIFIED_REFERENCE_COUNT==36
print(json.dumps({'public_files':len(paths),'classified_references':count,'result':'PASS'},sort_keys=True))
