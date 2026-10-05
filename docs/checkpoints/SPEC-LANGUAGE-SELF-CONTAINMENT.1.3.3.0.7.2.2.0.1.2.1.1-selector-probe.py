"""Execute one exact classifier producer against the current candidate inventory."""
from pathlib import Path
import argparse
import importlib.util
import sys
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('selector-probe.py')
parser=argparse.ArgumentParser();parser.add_argument('--epoch',choices=('before','after'),required=True)
epoch=parser.parse_args().epoch
path=Path(PREFIX+'before-check_executable_aggregate_selector_sources.py') if epoch=='before' else ROOT/'tools/check_executable_aggregate_selector_sources.py'
spec=importlib.util.spec_from_file_location('executed_classifier',path)
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
# Only restore the checkout root for the retained original producer's new path.
module.ROOT=ROOT;module.LOCK_DIRECTORY=ROOT/'dart/.dart_tool'
module.SCAN_LOCK_PATH=module.LOCK_DIRECTORY/'aggregate_selector_scan.lock'
module.CONCURRENCY_LOCK_PATH=module.LOCK_DIRECTORY/'aggregate_selector_concurrency.lock'
module.PROBE_DIRECTORY=ROOT
sys.exit(module.run_scan())
