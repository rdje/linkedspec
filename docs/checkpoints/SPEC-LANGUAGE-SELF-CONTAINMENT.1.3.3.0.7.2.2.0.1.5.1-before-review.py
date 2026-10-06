"""Retained independent preflight of the staged repair's original RED capture."""
from pathlib import Path
import importlib.util,json
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('before-review.py')
p=Path(PREFIX+'review.py')
spec=importlib.util.spec_from_file_location('staged_review',p);review=importlib.util.module_from_spec(spec);spec.loader.exec_module(review)
manifest=json.loads(Path(PREFIX+'before-inputs.json').read_bytes())
report=json.loads(Path(PREFIX+'before-observations.json').read_bytes())
authored=json.loads((ROOT/(review.ORIGINAL+'cases.json')).read_bytes())
review.check_inputs(manifest,'before');channels=review.check_report(report,manifest,authored,'before')
result={'complete':True,'epoch':'before','regular_inputs':len(manifest['entries']),'commands':len(report['runs']),'original_red_groups':review.FAILED,'dedicated_seeds':len(channels),'review_producer_sha256':review.sha(p.read_bytes()),'instrument_sha256':review.sha(Path(__file__).read_bytes()),'scope':'Independent preflight of complete immutable original supply, actual five-group fixture RED, all other original groups passing and three full original dedicated channels. Final before/after proof remains pending.'}
Path(PREFIX+'before-review.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
