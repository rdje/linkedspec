"""Apply the actual unchanged source classifier to the two exact blocker inputs."""
import importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('actual_scan',ROOT/'tools/check_executable_aggregate_selector_sources.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
paths=['t/actionir_method_inference_capture.t','docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-selector-review.py']
positive,classified=m.scan_files(paths)
print(json.dumps({'positive':positive,'classified':classified},sort_keys=True))
raise SystemExit(1 if positive else 0)
